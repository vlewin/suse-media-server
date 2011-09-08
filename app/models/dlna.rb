require "dbus"

module System
  def self.exec(cmd)
    bus = DLNA.initDBusObj
    state = bus.exec(cmd)[0]
    return state
  end
end

class DLNA
  include System
  
  PROPERTIES = [:id, :path, :type]
  SETTINGS = [:friendly_name, :inotify, :network_interface]

  attr_accessor *PROPERTIES
  attr_accessor *SETTINGS

  def initialize(args)
    if args.is_a? Hash
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end

  def to_hash
    Hash[instance_variables.map { |var| [var[1..-1].to_s, instance_variable_get(var)] }]
  end

  def self.initDBusObj
    bus = DBus.system_bus
    ruby_service = bus.service("augeas.dlna.Service")
    obj = ruby_service.object("/augeas/dlna/Service/Interface")
    obj.introspect
    obj.default_iface = "augeas.dlna.Service.Interface"
    return obj
  end

  def self.all
    bus = initDBusObj
    #args = Hash.new
    dirs = bus.match("")[0]
    dirs
  end
  
  def self.settings
    bus = initDBusObj

    args = Hash.new
    hash = bus.settings("")[0]
    
    hash.each do | key, value |
      Rails.logger.debug "KEY #{key} VALUE #{value}"
      args[key] = value
    end

    settings = DLNA.new(args)
    settings
  end
  
  def save
    bus = DLNA.initDBusObj
    state = bus.set(self.to_hash)
    restart = DLNA.restart
    
    state && restart ? true : false
  end
  
  def saveSettings
    bus = DLNA.initDBusObj
    state = bus.setSettings(self.to_hash)
    restart = DLNA.restart
    state && restart ? true : false
  end
  
  def destroy
    bus = DLNA.initDBusObj
    state = bus.rm(self.id)
    restart = DLNA.restart
    
    state && restart ? true : false
   end
   
   def self.running?
    state = System.exec("/etc/init.d/minidlna status")
    #Rails.logger.error "\nDLNA RUNNING #{state.inspect}"
    state
   end
  
   def self.restart
    state = System.exec("/etc/init.d/minidlna restart")
    #Rails.logger.error "\nDLNA RESTART #{state.inspect}"
    state
   end
   
   def self.rescan
    state = System.exec("/etc/init.d/minidlna rescan")
    #Rails.logger.error "\nDLNA RESCAN #{state.inspect}"
    state
   end
   
   def self.control
    if DLNA.running?
      state = System.exec("/etc/init.d/minidlna stop")
      #Rails.logger.error "\nDLNA STOP #{state.inspect}"
    else
      state = System.exec("/etc/init.d/minidlna start")
      #Rails.logger.error "\nDLNA START #{state.inspect}"
    end
    
    state
  end
  
end

