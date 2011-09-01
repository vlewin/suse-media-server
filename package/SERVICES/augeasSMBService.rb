#!/usr/bin/env ruby
require 'rubygems'
require 'augeas'
require 'dbus'
require 'syslog'

bus = DBus::system_bus
service = bus.request_service("augeas.smb.Service")

class AugeasSMBService < DBus::Object
  GLOBAL_DEFAULTS = {"restrict_anonymous" => "no", "guest_account" => "nobody", "security" => "share", "unix_extensions" => "yes" }
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

  def syslog(message)
    Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s|
      s.info "--- SMS INFO MESSAGE ---"
      s.info "*** #{message} ***"
      s.info "-------------------------"
    }
  end
  
  def init
    augeas = Augeas::open("/", "/usr/share/libaugeas0/augeas/lenses/dist", Augeas::NO_MODL_AUTOLOAD)
    augeas.transform(:lens => "Samba.lns", :incl => "/etc/samba/smb.conf")
    augeas.load
    return augeas
  end

  dbus_interface "augeas.samba.Service.Interface" do

     dbus_method :match, "in nothing:s, out matched:aa{ss}" do |path|
      shares = Array.new
      attr_array = ["path"]
      
      aug = init()

      paths = aug.match("#{AUG_PATH}*[label() != '#comment']")

      paths.each do |path|
        id = path.to_s.split('/').last
        puts "TARGET: #{id.inspect}"
	
	
	unless id == "target[1]"
	  attributes = aug.match("#{AUG_PATH}#{id}/*")
	  attributes.each do |a|
	    attr_name = a.split('/').last
	    name = aug.get("#{AUG_PATH}#{id}")
	    #attr_id = target
	    
	    if(attr_array.include?(attr_name))
	      shares.push({ "id"=> id, "name" => name, attr_name => aug.get("#{AUG_PATH}#{id}/#{attr_name}")})
	      puts "ATTR #{a.split('/').last}"
	    end
	  end
	else 
	  puts "GLOBAL IN SEPARATE FUNCTION?? #{id}"  
	end
      end
      
      puts "SHARES  #{shares.inspect}"

     [shares]
    end

    #MATCH with VALUES
    dbus_method :all, "in nothing:s, out matched:aa{ss}" do |path|
      shares = Array.new
      aug = init()

      paths = aug.match("#{AUG_PATH}*[label() != '#comment']")

      paths.each do |share|
        target = share.to_s.split('/').last
        shares.push({ "id" => share.to_s.split('/').last, "name" => aug.get(share)})
      end

     [shares]
    end

  end
end

obj = AugeasSMBService.new("/augeas/smb/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run


