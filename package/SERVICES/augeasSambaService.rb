#!/usr/bin/env ruby
require 'rubygems'
require 'augeas'
require 'dbus'

bus = DBus::system_bus
service = bus.request_service("augeas.samba.Service")

class AugeasSambaService < DBus::Object
  CONF_PATH = "/etc/samba/smb.conf/"
  AUG_PATH = "/files" + CONF_PATH

  PROPERTIES = ["workgroup", "name", "path", "writeable", "browseable", "read_only", "security", "comment"]

#  PROPERTIES.each { |p| attr_reader p }


  def init
    augeas = Augeas::open("/", "/usr/share/libaugeas0/augeas/lenses/dist", Augeas::NO_MODL_AUTOLOAD)
    augeas.transform(:lens => "Samba.lns", :incl => "/etc/samba/smb.conf")
    augeas.load
    return augeas
  end

  dbus_interface "augeas.samba.Service.Interface" do

    dbus_method :all, "in nothing:s, out matched:aa{ss}" do |path|
      shares = Array.new
      aug = init()

      paths = aug.match("/files/etc/samba/smb.conf/*[label() != '#comment']")

      paths.each do |share|
        target = share.to_s.split('/').last
        puts share.to_s.split('/').last
        shares.push({ "id" => share.to_s.split('/').last, "name" => aug.get(share)})
      end
      [shares]
    end

    dbus_method :get, "in target:s, out matched:a{ss}" do |target|
      children = Hash.new

      #get all nodes
      aug = init()
      array = aug.match("#{AUG_PATH}#{target}/*")

      children["id"] = target
      children["name"] = aug.get("#{AUG_PATH}#{target}")

      array.each do | a |
        child = a.split('/').last

        #augeas crashed if child node has a white space in his name
        if PROPERTIES.include?(child)
          if child.match(/\s/)
            child = child.gsub(/\s/, "\\ ")
            children[a.split('/').last] = aug.get("#{AUG_PATH}#{target}/#{child}")
          else
            children[a.split('/').last] = aug.get(a) unless aug.get(a).empty?
          end
        end
     end

      puts "FOUND #{children.inspect}"
      return [children]
    end

    dbus_method :exec, "in command:s, out out:b" do |cmd|
      success = system 'echo "hello $HOSTNAME"'
        ret = `#{cmd}`
        out = ret.split('..').last
        #puts "\nCOMMAND #{cmd}\n"
        #puts "MESSAGE: #{out}\n"

      case out
        when "running"
          return "true"
        when "unused"
          return "false"
        else
          return "Execution error"
        end
      end

      dbus_method :set, "in share:a{ss}, out success:b" do |share|
        aug = init()
        
        puts "CREATE NEW #{share.inspect}"

        #save ID in extra var and remove id from hash
        
        #TARGET exist?
        
        puts "#{AUG_PATH}#{share["id"]}"
        
        if aug.get("#{AUG_PATH}#{share["id"]}").nil?
		   puts "NEW SHARE"
		   aug.set("#{AUG_PATH}#{share["id"]}", share["name"])
		   puts "AFTER SET"
		   puts aug.get("#{AUG_PATH}#{share["id"]}")
        end
        
		  id = share["id"]
          
          share.delete("id")
          share.delete("name")

          share.each do |k,v|
            puts "SET #{AUG_PATH}#{id}/#{k} WITH VALUE #{v}"
            aug.set("#{AUG_PATH}#{id}/#{k}", v) unless k == "id"
         end

       
       
         saved = aug.save
         puts "SAVE OK? #{saved}"
         saved
         
      end

  end
end

obj = AugeasSambaService.new("/augeas/samba/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run

