require 'rubygems'
require "dbus"

class Bus
 attr_accessor :method

 def bus(serv)
  case serv
    when "smb"
      bus = DBus.system_bus
      ruby_service = bus.service("augeas.samba.Service")
      obj = ruby_service.object("/augeas/samba/Service/Interface")
      obj.introspect
      obj.default_iface = "augeas.samba.Service.Interface"
      return obj
    when "dlna"
      bus = DBus.system_bus
      ruby_service = bus.service("augeas.dlna.Service")
      obj = ruby_service.object("/augeas/dlna/Service/Interface")
      obj.introspect
      obj.default_iface = "augeas.dlna.Service.Interface"
      return obj
    else
      raise "unknown dbus service #{serv}"
      Rails.logger.error "unknown dbus service"
    end
end  
#  if serv != "dlna"
#    bus = DBus.system_bus
#    ruby_service = bus.service("augeas.samba.Service")
#    obj = ruby_service.object("/augeas/samba/Service/Interface")
#    obj.introspect
#    obj.default_iface = "augeas.samba.Service.Interface"
#  else
#    bus = DBus.system_bus
#    ruby_service = bus.service("augeas.dlna.Service")
#    obj = ruby_service.object("/augeas/dlna/Service/Interface")
#    obj.introspect
#    obj.default_iface = "augeas.dlna.Service.Interface"
#  end
#  return obj
# end


 def send(srv, args)
   dbus = self.bus(srv)
   ret = dbus.match('all')[0]
 end

 def find_all(srv)
   dbus = self.bus(srv)
   ret = dbus.all(' ')[0]
 end
 
 def match(srv)
   dbus = self.bus(srv)
   ret = dbus.match(' ')[0]
 end

 def find(srv, id)
   dbus = self.bus(srv)
   dbus.get(id)[0]
 end

 def save(srv, share)
   dbus = self.bus(srv)
   dbus.set(share)[0]
 end
 
 def destroy(srv, share)
   dbus = self.bus(srv)
   returns = dbus.rm(share)[0]
   returns
 end

 def exec(srv, cmd)
   dbus = self.bus(srv)
   dbus.exec(cmd)[0]
 end
end

