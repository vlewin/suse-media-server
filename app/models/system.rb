require "dbus"

#class System
#  def self.initDBusObj
#    bus = DBus.system_bus
#    ruby_service = bus.service("augeas.smb.Service")
#    obj = ruby_service.object("/augeas/smb/Service/Interface")
#    obj.introspect
#    obj.default_iface = "augeas.smb.Service.Interface"
#    return obj
#  end

#  def reboot
#    Rails.logger.error "SYSTEM REBOOT"
#  end

#  def shutdown
#    Rails.logger.error "SYSTEM SHUTDOWN"
#  end
#end

