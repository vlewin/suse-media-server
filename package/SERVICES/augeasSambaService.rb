#!/usr/bin/env ruby
require 'rubygems'
require 'augeas'
require 'dbus'
require 'syslog'

bus = DBus::system_bus
service = bus.request_service("augeas.samba.Service")

class AugeasSambaService < DBus::Object

  #set default values otherwise overwrite with user settings
  #GLOBAL_DEFAULTS = { "passdb_backend" => "tdbsam", "map_to_guest" => "Bad User", "usershare_allow_guests" => "Yes" }

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
	
	#shares.push({ "id" => target.to_s.split('/').last, "name" => aug.get(target)})
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

    #GET ALL NODES
    dbus_method :get, "in target:s, out matched:a{ss}" do |target|
      children = Hash.new

      aug = init()
      array = aug.match("#{AUG_PATH}#{target}/*")

      children["id"] = target

      #resolve name from id
      name = aug.get("#{AUG_PATH}#{target}")
      children["name"] = name

      array.each do | a |
        child = a.split('/').last

        if children["name"] == "global"
	  if GLOBAL.include?(child)
	    children[child] = aug.get(a) unless aug.get(a).empty?
	  end
	else
          if PROPERTIES.include?(child)
            #augeas crashed if child node has a white space in his name
            if child.match(/\s/)
              child = child.gsub(/\s/, "\\ ")
              children[child] = aug.get("#{AUG_PATH}#{target}/#{child}")
            else
              children[child] = aug.get(a) unless aug.get(a).empty?
            end
          end

        end #GLOBAL
      end #EACH

      return [children]
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
      
      targets = []

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


    dbus_method :rm, "in share:a{ss}, out success:b" do |share|
      aug = init()
      path = "#{AUG_PATH}#{share["id"]}"
      aug.rm(path)
      
      saved = aug.save
      saved
    end

    #EXEC
    dbus_method :exec, "in command:s, out out:b" do |cmd|
      message = `#{cmd}`
      result = message.split('..').last
      success = false
      puts "\n\INFO: SAMBA CMD #{cmd.inspect} SAMBA is #{result}"
            
      # TODO: return result instead of boolean and handle it in smb modell !!!
      unless result.nil?
        if result.match("running")
          success = true
        elsif result.match("unused")
          success = false
        elsif result.match("done")
          success = true
        end
      else
        success = false
      end
      
      success
    end

  end
end

obj = AugeasSambaService.new("/augeas/samba/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run

