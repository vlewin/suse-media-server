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
  NOBODY_DEFAULTS = { "guest_ok" => "yes",
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
  GLOBAL = ["workgroup", "security"]

  def init
    augeas = Augeas::open("/", "/usr/share/libaugeas0/augeas/lenses/dist", Augeas::NO_MODL_AUTOLOAD)
    augeas.transform(:lens => "Samba.lns", :incl => "/etc/samba/smb.conf")
    augeas.load
    return augeas
  end

  dbus_interface "augeas.samba.Service.Interface" do

    #MATCH with VALUES
    dbus_method :all, "in nothing:s, out matched:aa{ss}" do |path|
      shares = Array.new
      aug = init()

      paths = aug.match("#{AUG_PATH}*[label() != '#comment']")

      paths.each do |share|
        target = share.to_s.split('/').last
        puts share.to_s.split('/').last
        shares.push({ "id" => share.to_s.split('/').last, "name" => aug.get(share)})
      end

      #Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.info "*** existing shares" }
      #Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.info shares.inspect }

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
            puts "GLOBAL SETTINGS"
	    children[child] = aug.get(a) unless aug.get(a).empty?
            puts "CHILD #{child} and value #{aug.get(a)}"
            puts "*** \n"
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

      puts "FOUND #{children.inspect}"
      return [children]
    end

    #SET NODE
    dbus_method :set, "in share:a{ss}, out success:b" do |share|
      aug = init()

      puts "#{AUG_PATH}#{share["id"]}"

      #new smb share if not exist?
      if aug.get("#{AUG_PATH}#{share["id"]}").nil?
        aug.set("#{AUG_PATH}#{share["id"]}", share["name"])
      end


      puts "SHARE #{share.inspect }"

      #store id and name and remove from hash
      id = share["id"]
      name = share["name"]

      share.delete("id")
      share.delete("name")

      #TODO: check if key in SHARE and set user value otherwise set default GLOBAL values for nobody without password

      puts "NAME #{name}"


      #TODO: find better way to detect GLOBAL section
      if id == "target[1]"
        puts "WRITE GLOBAL SETTINGS"
        GLOBAL_DEFAULTS.each do |key,value|
	  key = key.gsub(/_/, "\\ ")
          aug.set("#{AUG_PATH}#{id}/#{key}", value)
	end
      else
         puts "WRITE SHARE SETTINGS"
        NOBODY_DEFAULTS.each do |key,value|
	        key = key.gsub(/_/, "\\ ")
          aug.set("#{AUG_PATH}#{id}/#{key}", value)
        end

      end

      share.each do |k,v|
        puts "\n\n*** SHARE SET #{AUG_PATH}#{id}/#{k} WITH VALUE #{v}"
        aug.set("#{AUG_PATH}#{id}/#{k}", v)
      end

      saved = aug.save

      #TODO: better check for command execution status (make it DRY)
      ret = `rcsmb restart`

      puts "SAVE OK? #{saved}"
      saved
    end



    #EXEC
    dbus_method :exec, "in command:s, out out:b" do |cmd|
      message = `#{cmd}`
      result = message.split('..').last

      Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s|
        s.info "SMS: Execute CMD #{cmd.inspect} and return exit code #{result.inspect}"
      }

      # TODO: return result instead of boolean and handle it in smb modell !!!
      unless result.nil?
        if result.match("running")
          return true
        elsif result.match("unused")
          return false
        elsif result.match("done")
          return true
        end
      else
        Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s|
          s.warning "SMS: Unknown exit code #{result.inspect}!"
        }
        return false
      end
    end

  end
end

obj = AugeasSambaService.new("/augeas/samba/Service/Interface")
service.export(obj)
main = DBus::Main.new
main << bus
main.run

