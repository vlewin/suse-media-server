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
  
    #TODO: Find a solution for media types (A,V,P) handling
    #a{sa{ss}} for {"a"=>{"type"=>"s", "path"=>"s"}}
    dbus_method :match, "in empty:s, out directories:a{sa{ss}}" do |path|
      augeas = init()
      
      nodes = augeas.match("#{AUG_PATH }*[label() != '#comment']")
      dirs = Hash.new
      
      nodes.each do | node |
        if node.match("media_dir")
          id = node.split('/').last
          media = augeas.get("#{AUG_PATH}#{id}")
          media.split(',').length>1? type= media.split(',').first : type="M"

          dirs[media.split(',').last] = {"id" => id, "type" => type}
        end
      end
      
     [dirs]
    end

    dbus_method :set, "in media:a{ss}, out status:b" do |media|
      augeas = init()

      id = augeas.match("#{AUG_PATH}media_dir").length + 1
      path = media["path"]
      
      #if media type add it to media path
      if media["type"]
        path = "#{media["type"]},#{media["path"]}"
      end

      augeas.set("#{AUG_PATH}media_dir[#{id}]", path)
      augeas.save
    end
    
    dbus_method :rm, "in id:s, out status:b" do |id|
      augeas = init()
      augeas.rm("#{AUG_PATH}#{id}")
      augeas.save
      true
    end
    
    #EXEC CMD
    dbus_method :exec, "in command:s, out status:b" do |cmd|

      status = `#{cmd}` #TODO ALLOW ONLY MINIDLNA COMMANDS
      string = status.split('..').last
       
      #puts "CMD #{cmd} and RETURN STRING #{string}"
      #SWITCH CASE 

      case cmd
        when "/etc/init.d/minidlna status"
          puts "#{cmd} returns #{string}"
          string.match("running")? true : false
        when "/etc/init.d/minidlna start", "/etc/init.d/minidlna stop"
          puts "#{cmd} returns #{string}"
          string.match("done")? true : false
        when "/etc/init.d/minidlna restart"
          puts "#{cmd} returns #{string}"
          string.match("done")? true : false
        else
          puts "FAILED: CMD #{cmd} RETURN STRING #{string}"   
      end
    end


  end
end

obj = AugeasDlnaService.new("/augeas/dlna/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run
