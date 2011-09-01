#!/usr/bin/env ruby
require 'rubygems'
require 'augeas'
require 'dbus'
require 'syslog'

bus = DBus::system_bus
service = bus.request_service("augeas.smb.Service")

class AugeasSMBService < DBus::Object
  GLOBAL_DEFAULTS = {
    "restrict_anonymous" => "no", 
    "guest_account" => "nobody", 
    "security" => "share",
    "unix_extensions" => "yes" 
  }

  NOBODY_DEFAULTS = {
    "guest_ok" => "yes",
    "inherit_acls" => "yes",
    "read_only" => "no",
    "guest_only" => "yes",
    "browseable" => "yes",
    "writeable" => "yes",
    "available" => "yes",
    "create_mask" => "0660",
    "directory_mask" => "0770",
    "force_group" => "users"
  }

  CONF_PATH = "/etc/samba/smb.conf/"
  AUG_PATH = "/files" + CONF_PATH

  PROPERTIES = ["name", "path", "writeable", "browseable", "read_only", "guest_only", "comment"]
  GLOBAL = ["workgroup", "netbios_name", "security"]

  def init
    augeas = Augeas::open("/", "/usr/share/libaugeas0/augeas/lenses/dist", Augeas::NO_MODL_AUTOLOAD)
    augeas.transform(:lens => "Samba.lns", :incl => "/etc/samba/smb.conf")
    augeas.load
    return augeas
  end

  dbus_interface "augeas.smb.Service.Interface" do
    dbus_method :shared, "in empty:s, out paths:as" do |path|
      paths = Array.new
      aug = init()

      tmp = aug.match("#{AUG_PATH}*[label() != '#comment']")
      tmp.each do |share|
        target = share.to_s.split('/').last
        paths.push(aug.get("#{share}/path")) unless target == "target[1]"
      end
     [paths]
    end

  end
end

obj = AugeasSMBService.new("/augeas/smb/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run



