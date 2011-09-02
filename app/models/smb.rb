require "dbus"

class Smb
  PROPERTIES = [:id, :name, :path]
  GLOBAL = [:workgroup, :security]

  attr_accessor *PROPERTIES
  attr_accessor *GLOBAL

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
    ruby_service = bus.service("augeas.smb.Service")
    obj = ruby_service.object("/augeas/smb/Service/Interface")
    obj.introspect
    obj.default_iface = "augeas.smb.Service.Interface"
    return obj
  end

  def self.all
    shared = Array.new
    bus = initDBusObj
    shared = bus.match("")[0]
    return shared
  end
  
   def save
    bus = Smb.initDBusObj
    ret = bus.set(self.to_hash)
    ret
  end
  
  def destroy
    bus = Smb.initDBusObj
#    bus.destroy("smb", self.to_hash) ? true : false
    ret = bus.rm(self.id) ? true : false
  end


end

