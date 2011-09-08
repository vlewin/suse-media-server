#!/usr/bin/env ruby
require 'rubygems'
require 'augeas'
require 'dbus'

bus = DBus::system_bus
service = bus.request_service("augeas.dlna.Service")

class AugeasDlnaService < DBus::Object
  CONF_PATH = "/etc/minidlna.conf/"
  AUG_PATH = "/files" + CONF_PATH

  GLOBALS = ["network_interface", "friendly_name", "inotify"]

  def init
    augeas = Augeas::open("/", "/usr/share/libaugeas0/augeas/lenses/dist", Augeas::NO_MODL_AUTOLOAD)
    augeas.transform(:lens => "Minidlna.lns", :incl => "/etc/minidlna.conf")
    augeas.load
    return augeas
  end

  dbus_interface "augeas.dlna.Service.Interface" do
  
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
    
    dbus_method :settings, "in empty:s, out globals:a{ss}" do |path|
      augeas = init()
      
      nodes = augeas.match("#{AUG_PATH }*[label() != '#comment']")
      dirs = Hash.new
      settings = Hash.new
     
      nodes.each do | node |
        target = node.split('/').last
        if GLOBALS.include?(target)
          settings[target] = augeas.get(node)
        end
      end
     
     puts "*** RETURN #{settings.inspect}"
     [settings]
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
    
    dbus_method :setSettings, "in settings:a{ss}, out status:b" do |settings|
      augeas = init()
      puts "*** SETTINGS #{settings.inspect}"
      settings.each do |key, value|
        augeas.set("#{AUG_PATH}#{key}", value)
      end
      
      augeas.save
    end
    
    dbus_method :rm, "in id:s, out status:b" do |id|
      augeas = init()
      augeas.rm("#{AUG_PATH}#{id}")
      augeas.save
    end
    
    #EXEC CMD
    dbus_method :exec, "in command:s, out status:b" do |cmd|
      status = `#{cmd}` #TODO ALLOW ONLY MINIDLNA COMMANDS
      string = status.split('..').last
       
      #puts "CMD #{cmd} and RETURN STRING #{string}"

      case cmd
        when "/etc/init.d/minidlna status"
          string.match("running")? true : false
        when "/etc/init.d/minidlna start", "/etc/init.d/minidlna stop"
          string.match("done")? true : false
        when "/etc/init.d/minidlna restart", "/etc/init.d/minidlna rescan"
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
