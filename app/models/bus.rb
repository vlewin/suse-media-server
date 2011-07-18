require 'rubygems'
require "dbus"

class Bus
 attr_accessor :method

# def initialize(args)
#  @methode = args
#  Rails.logger.error "Methode #{@methode.inspect}"
# end

 def bus(serv)
  Rails.logger.error "service #{serv.inspect}"

  if serv != "dlna"
    bus = DBus.system_bus
    ruby_service = bus.service("augeas.samba.Service")
    obj = ruby_service.object("/augeas/samba/Service/Interface")
    obj.introspect
    obj.default_iface = "augeas.samba.Service.Interface"
  else
    bus = DBus.system_bus
    ruby_service = bus.service("augeas.dlna.Service")
    obj = ruby_service.object("/augeas/dlna/Service/Interface")
    obj.introspect
    obj.default_iface = "augeas.dlna.Service.Interface"
  end
  return obj
 end


 def send(srv, args)
   Rails.logger.error "#{srv}"
   Rails.logger.error "#{args}"
   dbus = self.bus(srv)
   ret = dbus.match('all')[0]
 end

 def find_all(srv)
#   dbus = self.init()
   dbus = self.bus(srv)
   ret = dbus.all(' ')[0]
 end

 def find(srv, id)
   dbus = self.bus(srv)
   dbus.get(id)[0]
 end

 def save(srv, share)
   dbus = self.bus(srv)
   dbus.set(share)[0]
 end

 def exec(srv, cmd)
   dbus = self.bus(srv)
   dbus.exec(cmd)[0]
 end
end

