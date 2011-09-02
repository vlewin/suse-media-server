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

  def self.getShared
    shared = Array.new
    bus = initDBusObj
    shared = bus.shared("")[0]
    Rails.logger.error "SHARES MAP #{shared.inspect}"
    return shared
  end
  
   def save
    bus = Smb.initDBusObj
    Rails.logger.error "#{self.inspect}"

    if bus.set(self.to_hash)
      return true
    else
      Rails.logger.error "ERROR: CAN NOT SAVE SHARE"
      return false
    end
  end


end

