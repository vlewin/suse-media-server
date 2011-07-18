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

#  PROPERTIES.each { |p| attr_reader p }


  def init
    augeas = Augeas::open("/", "/usr/share/libaugeas0/augeas/lenses/dist", Augeas::NO_MODL_AUTOLOAD)
    augeas.transform(:lens => "Minidlna.lns", :incl => "/etc/minidlna.conf")
    augeas.load
    return augeas
  end

  dbus_interface "augeas.dlna.Service.Interface" do

    dbus_method :match, "in tmp:s, out matched:a{ss}" do |path|
      config = Hash.new
      aug = init()

      parents = aug.match("#{AUG_PATH }*[label() != '#comment']")

      puts parents
      puts "\n"


      parents.each do | p |
        value = aug.get(p)
        key = p.split('/').last

        
        if key.match("media_dir")
          puts key.sub('[', '').chomp(']')
          key = key.sub('[', '').chomp(']')
          #key.sub('[', '_').sub(']', '')
          config[key] = value.sub('[', '_')
        else 
          if PROPERTIES.include?(key)
            config[key] = value
          end
        end
      end

      [config]
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

