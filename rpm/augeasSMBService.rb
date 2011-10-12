#!/usr/bin/env ruby
require 'rubygems'
require 'augeas'
require 'dbus'
#require 'syslog'

bus = DBus::system_bus
service = bus.request_service("augeas.smb.Service")

class AugeasSMBService < DBus::Object
#   DEFAULTS

#   workgroup = WORKGROUP
#   security = share
#   restrict anonymous = no
#   guest account = nobody
#   map to guest = Bad User

#   netbios name = Linux
#   usershare allow guests = Yes

#   NOT USED
#   "unix_extensions" => "yes" 
  GLOBAL_DEFAULTS = {
    "security" => "share",
    "restrict_anonymous" => "no", 
    "guest_account" => "nobody", 
    "map_to_guest" => "Bad User",
    "usershare_allow_guests" => "Yes"
  }

#   WORKING DEFAULTS

#   read only = no
#   available = yes
#   guest ok = yes
#   force group = users
#   inherit acls = yes
#   writeable = yes
#   browseable = yes
#   guest only = yes
#   path = /home/mrstealth/SAMBA/Musik

  #BUG: WRITE ACCESS
  #ONLY WITH CHMOD 775
  NOBODY_DEFAULTS = {
    "read_only" => "no",
    "available" => "yes",
    "guest_ok" => "yes",
    "inherit_acls" => "yes",
    "writeable" => "yes",
    "browseable" => "yes",
    "guest_only" => "yes",
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

    #MATCH ALL SHARES
    dbus_method :match, "in empty:s, out paths:a{ss}" do |path|
      hash = Hash.new
      aug = init()
     
      puts "MATCH"
      tmp = aug.match("#{AUG_PATH}*[label() != '#comment']")
      
      unless tmp.length < 2
	tmp.each do |share|
          target = share.to_s.split('/').last
          puts "PATH #{share}/path"
          puts "GET TARGET NAME #{aug.get("#{share}/path").inspect}"
          hash[aug.get("#{share}/path")] = target unless target == "target[1]" || aug.get("#{share}/path").nil?
	end
      else 
        hash["nil"] = "nil"
      end
      
     puts hash.inspect
     #[paths]
     [hash] 
    end
    
    
    #GET NODE BY TARGET ID
    dbus_method :get, "in target:s, out matched:a{ss}" do |target|
      #children = Hash.new

      aug = init()
      keys = aug.match("#{AUG_PATH}#{target}/*")

      hash = Hash.new
      hash["id"] = target
      
      keys.each do | key |
        #augeas crashed if attribute has whitespace

        name = key.split('/').last.match(/\s/)? key.split('/').last.gsub(/\s/, "_") : key.split('/').last        
        key = key.match(/\s/)? key.gsub(/\s/, "\\ ") : key

        if GLOBAL.include?(name)
          hash[name] = aug.get(key)
        end
      end

      return [hash]
    end

    #SAVE SHARE
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
         key = key.gsub(/_/, "\\ ")
         puts "*** SET USER SETTINGS #{AUG_PATH}#{id}/#{key} WITH VALUE #{value}"
         aug.set("#{AUG_PATH}#{id}/#{key}", value)
       end	  
       
       save = aug.save
       puts "\n\nINFO: SMS: SAVE OK? #{save}\n\n"
       save
    end
    
    #DELETE SHARE
    dbus_method :rm, "in shareID:s, out success:b" do |share|
      puts "SMS: DESTROY share with ID #{share}"
      puts "SMS: SHARE PATH #{AUG_PATH}#{share}"
      
      aug = init()
      path = "#{AUG_PATH}#{share}"
      aug.rm(path)
      
      saved = aug.save
      puts "SMS: SAVE SUCCESSFUL? #{saved}"
      saved
    end


    dbus_method :exec, "in command:s, out status:b" do |cmd|
      status = `#{cmd}` #TODO ALLOW ONLY SMB COMMANDS
      string = status.split('..').last
       
      success = false

      case cmd
        when "/etc/init.d/smb status", "/etc/init.d/nmb status"
          if string.match("running")
	    success = true
	  end
        when "/etc/init.d/smb start", "/etc/init.d/nmb start"
	  if string.match("done")
	    success = true
	  end
        when "/etc/init.d/smb stop", "/etc/init.d/nmb stop"
	  if string.match("done")
	    success = true
	  end
        when "/etc/init.d/smb restart", "/etc/init.d/nmb restart"
          if string.match("done")
	    success = true
	  end
        else
          puts "FAILED: CMD #{cmd} RETURN STRING #{string}"   
	end
      
      #puts "CMD #{cmd} and RETURN STRING #{string} and SUCCESS IS #{success}"
      success
    end
    
        
    dbus_method :permissions, "in empty:s, out status:b" do
      puts "FIX WRITE PERMISSIONS FOR SHARED FOLDERS"
      augeas = init()

      success = false
      nodes = augeas.match("#{AUG_PATH}*[label() != '#comment']")
      
      nodes.each do |node|
	dir = augeas.get("#{node}/path")
	unless dir.nil?
	  #Operation not permitted
	  output = `LANG=POSIX chmod 777 #{dir} 2>&1`
	  puts "ERROR: #{output.inspect}" unless output.nil?
	  success = output.match("Operation not permitted")? false : true
	end
      end
      
      puts "SUC #{success}"
      success
      
    end

  end
end

obj = AugeasSMBService.new("/augeas/smb/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run



