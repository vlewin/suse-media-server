#!/usr/bin/env ruby
require 'rubygems'
require 'augeas'
require 'dbus'

bus = DBus::system_bus
service = bus.request_service("augeas.dlna.Service")

class AugeasDlnaService < DBus::Object
  CONF_PATH = "/etc/minidlna.conf/"
  AUG_PATH = "/files" + CONF_PATH

  PROPERTIES = ["media_dir", "inotify", "friendly_name", "serial", "model_number"]

  def init
    augeas = Augeas::open("/", "/usr/share/libaugeas0/augeas/lenses/dist", Augeas::NO_MODL_AUTOLOAD)
    augeas.transform(:lens => "Minidlna.lns", :incl => "/etc/minidlna.conf")
    augeas.load
    return augeas
  end

  dbus_interface "augeas.dlna.Service.Interface" do
  
    #TODO: Find a better solution for media types (A,V,P) handling
    #a{sa{ss}} for {"a"=>{"type"=>"s", "path"=>"s"}}
    dbus_method :match, "in empty:s, out directories:a{sa{ss}}" do |path|
      augeas = init()
      
      nodes = augeas.match("#{AUG_PATH }*[label() != '#comment']")
      dirs = Hash.new
      
      nodes.each do | node |
        if node.match("media_dir")
          id = node.split('/').last
          media = augeas.get("#{AUG_PATH}#{id}")
          dirs[media.split(',').last] = {"id" => id, "type" => media.split(',').first}
        end
      end
      
     [dirs]
    end

    dbus_method :set, "in media:a{ss}, out status:b" do |media|
      augeas = init()
      
      #puts "MEDIA DIR #{media.inspect} ***"
      #puts "GET NODES"
      
      count = augeas.match("#{AUG_PATH}media_dir").length
      puts media["path"]
      
      
      
      id = count + 1
      augeas.set("#{AUG_PATH}media_dir[#{id}]",media["path"])
      augeas.save
    end


    dbus_method :get, "in target:s, out matched:a{ss}" do |target|
      children = Hash.new

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

  end
end

obj = AugeasDlnaService.new("/augeas/dlna/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run
