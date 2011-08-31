
class Dlna
  PROPERTIES = [:id, :media_dir1, :media_dir2, :media_dir3, :friendly_name, :inotify, :serial, :model_number]
  attr_accessor *PROPERTIES

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

  def self.all
    begin
      shares = Array.new
      bus = Bus.new()
      map = bus.send("dlna", {})
      args = {}

      map.each do |key, value|
        args[key] = value
      end

      share = Dlna.new(args)
      return share
    
    rescue DBus::Error => dbe
      if dbe.dbus_message.instance_variables.include?("@error_name") && dbe.dbus_message.error_name == "org.freedesktop.DBus.Error.AccessDenied"
        Rails.logger.error "*** DLNA DBUS: ACCESS DENIED #{dbe.dbus_message.error_name.inspect}"
        raise "You have no permissions!"
      else
        Rails.logger.error "*** DLNA DBUS:ERROR #{dbe.inspect}"
        raise "Generic exception please report this issue:
          <a href='https://github.com/vlewin/suse-media-server/issues'>github bugtracker</a>"
      end

    rescue Exception => e
      Rails.logger.error "Caught exception: #{e.inspect}"
      raise "Generic exception"
    end
  end

end

