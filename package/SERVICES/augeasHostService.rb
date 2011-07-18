#!/usr/bin/env ruby
require 'rubygems'
require 'augeas'
require 'dbus'

############# IMPORTANT !!! ############################
#hashes = {"test", "test2"} ==> matched:a{ss}
#return [{"test", "test2"}]

#hashes = [{"test" => "ss", "test2" => "ss"}] ==> matched:aa{ss}
#return [[{"test", "test2"}]]
############# IMPORTANT !!! ############################

bus = DBus::system_bus
service = bus.request_service("augeas.host.Service")

class AugeasHostService < DBus::Object

  def init
    augeas = Augeas::open("/", "/usr/share/libaugeas0/augeas/lenses/dist", Augeas::NO_MODL_AUTOLOAD)
    augeas.transform(:lens => "Hosts.lns", :incl => "/etc/hosts")
    augeas.load
    return augeas
  end

  dbus_interface "augeas.host.Service.Interface" do

    dbus_method :all, "in path:s, out matched:aa{ss}" do |path|
      puts "INFO: FIND ALL NODES"
      array = []
      aug = init()
      nodes = aug.match("/files/etc/hosts/*[label() != '#comment']")

      nodes.each_with_index do | child, i |
        array.push({ "canonical" => aug.get("#{child}/canonical"),
                     "ipaddr" => aug.get("#{child}/ipaddr"),
                     "aliasname" => aug.get("#{child}/alias").nil? ? " " : aug.get("#{child}/alias")
        })
      end

      return [array]
    end


    dbus_method :get_parents, "in path:s, out matched:aa{ss}" do |path|
      puts "INFO: FIND ALL SAMBA NODES"
      shares = Array.new
      samba = Array.new

      Augeas::open("/", "/usr/share/libaugeas0/augeas/lenses/dist", Augeas::NO_MODL_AUTOLOAD) do | aug |
      aug.transform(:lens => "Samba.lns", :incl => "/etc/samba/smb.conf")
      aug.load
  #    Augeas::open do |aug|
         paths = aug.match("/files/etc/samba/smb.conf/*[label() != '#comment']")


      #shares = Hash.new


      paths.each do |share|
        shares.push({ "name" => aug.get(share), "path" => share.to_s.split('/').last})
        #tmp = aug.match(share + "/*")
        #puts "AUG GET #{tmp.class}"

        #tmp.each do | t |
        #  puts "TTT #{t.split('/').last}"
        #end
      end

      puts "ARRAY #{shares.inspect}"
      puts shares.inspect

      shares[0].each do |key, value|
        puts key
        puts value
        puts "\n"
      end

      end
      [shares]
    end

    dbus_method :get_children, "in target:s, out matched:a{ss}" do |target|
      puts "INFO: FIND ALL NODES"
      children = Hash.new

     Augeas::open do |aug|
      array = aug.match("/files/etc/samba/smb.conf/#{target}/*")
      puts array.inspect
      array.each do | a |
        puts a.split('/').last
        child = a.split('/').last
        #.gsub(/\s/, "\\ ")
        path = "/files/etc/samba/smb.conf/#{target}/guest\ ok"
        puts aug.get("/files/etc/samba/smb.conf/#{target}/"+child)
        puts child

        if child.match(/\s/)
          #child = child.gsub(/\s/, "\\ ")
          child = child.gsub(/\s/, "\\ ")
          puts "CHILD #{child}"
          children[a.split('/').last] = aug.get("/files/etc/samba/smb.conf/#{target}/"+child)
        else
          children[a.split('/').last] = aug.get(a)
        end

        #{a => aug.get(path + a)}
      end

      puts children.inspect

    end
      return [children]
    end

    dbus_method :get, "in path:s, out value:a{ss}" do |path|
      puts "INFO: FIND NODES #{path}"
      hashes = Hash.new
      aug = init()
      hashes["canonical"] = aug.get("#{path}/canonical")
      hashes["ipaddr"] = aug.get("#{path}/ipaddr")
      hashes["alias"] = aug.get("#{path}/alias") unless aug.get("#{path}/alias").nil?
      aug.get("#{path}/alias").nil? ? hashes["aliasname"] = "none" : hashes["aliasname"] = aug.get("#{path}/alias")
      return [hashes]
    end

    dbus_method :set, "in path:a{ss}, out value:b" do |args|
      puts "INFO: CREATE/UPDATE ACTION"
      aug = init()
      aug.set(args['path']+ "/ipaddr", args['ip'])
      aug.set(args['path']+ "/canonical", args['hostname'])
      aug.set(args['path']+ "/alias", args['alias'])
      aug.save == 'true' ? true : false
    end

    dbus_method :rm, "in path:s, out value:b" do |path|
      puts "\n INFO: DESTROY ACTION"
      aug = init()
      aug.rm(path)
      aug.save == 'true' ? true : false
    end

  end
end

obj = AugeasHostService.new("/augeas/host/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run

