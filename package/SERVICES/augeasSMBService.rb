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

    dbus_method :match, "in empty:s, out paths:as" do |path|
      paths = Array.new
      aug = init()

      tmp = aug.match("#{AUG_PATH}*[label() != '#comment']")
      tmp.each do |share|
        target = share.to_s.split('/').last
        paths.push(aug.get("#{share}/path")) unless target == "target[1]"
      end
     [paths]
    end

    #SET NODE
    dbus_method :set, "in share:a{ss}, out success:b" do |share|
      aug = init()

      puts "INFO: INSECT SHARE BEFORE SET #{share.inspect}"      

      #store ID and NAME BEFORE YOU DELETE THEM
      id = share["id"]
      name = share["name"]
      
      #delete ID and SHARE NAME from HASH
      share.delete("id")
      share.delete("name")
      
      targets = Array.new

      #get nubmer of existing shares and set ID for new share
      if id.nil? 
        id = "target[#{aug.match("#{AUG_PATH}*[label() != '#comment']").length + 1}]"
        puts "ID IS NOT DEF #{id}"
      end
      
      unless aug.get("#{AUG_PATH}#{id}") == "global"
	    nodes = aug.match("#{AUG_PATH}*[label() != '#comment']")
    	nodes.each do | target |
	      targets << aug.get(target)
	   end
	
	#IF NAME IS NOT EXIST
	unless targets.include?(name)   
	  puts "INFO: CREATE NEW NODE <#{name}>"
	  puts "DEBUG: AUG.SET: #{AUG_PATH}#{id} \tNAME  #{name}"
	  aug.set("#{AUG_PATH}#{id}", name)
	else
	  puts "INFO: UPDATE EXISTING NODE <#{name}>"
	end
	
	    #WRITE NOBODY DEFAULT SETTINGS
        NOBODY_DEFAULTS.each do |key,value|
     	  key = key.gsub(/_/, "\\ ")
	      puts "*** SET NOBODY DEFAULT SETTINGS #{key} #{value}"
 	      aug.set("#{AUG_PATH}#{id}/#{key}", value)
        end
            
      else
        # WRITE GLOBAL DEFAULT SETTINGS
	    GLOBAL_DEFAULTS.each do |key,value|
    	  key = key.gsub(/_/, "\\ ")
	      puts "*** SET GLOBAL DEFAULT SETTINGS #{key} #{value}"
          aug.set("#{AUG_PATH}#{id}/#{key}", value)
	    end
      end
       
       # WRITE USER SETTINGS FOR GLOBAL AND SHARE
       share.each do |key,value|
         puts "*** SET USER SETTINGS #{AUG_PATH}#{id}/#{key} WITH VALUE #{value}"
         aug.set("#{AUG_PATH}#{id}/#{key}", value)
       end	  
       
       save = aug.save
       puts "\n\nINFO: SMS: SAVE OK? #{save}\n\n"
       save
    end



  end
end

obj = AugeasSMBService.new("/augeas/smb/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run



