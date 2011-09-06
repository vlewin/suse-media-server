require "dbus"

module System
  #attr_accessor :return

  #def initialize(status)
  #  @status = status
  #end

  def self.exec(cmd)
    bus = Smb.initDBusObj
    answer = bus.exec(cmd)[0]
    answer
  end
end


class Smb
  include System

  PROPERTIES = [:id, :name, :path]
  GLOBAL = [:workgroup, :security, :netbios_name]

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
    #TODO: Detect first start and save/destroy action, cache results
    shared = Array.new
    bus = initDBusObj
    shared = bus.match("")[0]
    return shared
  end

  def self.find(id)
    bus = Smb.initDBusObj
    hash = bus.get(id)[0]
    args = Hash.new

    hash.each do | key, value |
      args[key] = value
    end

    share = Smb.new(args)
    return share
  end

   def save
    bus = Smb.initDBusObj
    ret = bus.set(self.to_hash)

    #TODO: check exit value
    status = Smb.restart
    ret
  end

  def destroy
    bus = Smb.initDBusObj
    ret = bus.rm(self.id) ? true : false

    #TODO: check exit value
    status = Smb.restart
    ret
   end

  def self.running?
    status = System.exec("/etc/init.d/smb status")
    status
  end

  def self.restart
    smbd = System.exec("/etc/init.d/smb restart")
    nmbd = System.exec("/etc/init.d/nmb restart")
    smbd && nmbd ? true : false
  end

  def self.control
    if Smb.running?
      smbd = System.exec("/etc/init.d/smb stop")
      nmbd = System.exec("/etc/init.d/nmb stop")
    else
      smbd = System.exec("/etc/init.d/smb start")
      nmbd = System.exec("/etc/init.d/nmb start")
    end

    smbd && nmbd ? true : false
  end
end

