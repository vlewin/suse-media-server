class Share
  PROPERTIES = [:id, :name, :path, :writeable, :browseable]
  GLOBAL = [:workgroup, :security]

  attr_accessor *PROPERTIES
  attr_accessor *GLOBAL

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
    shares = Array.new
    bus = Bus.new

    begin
      #shares_map = bus.find_all("samba")
      args = {}
      
      shares_map = bus.match("samba")

      shares_map.each do |elem|
        elem.each do |key, value|
          args[key] = value
        end

        share = Share.new(args)
        shares << share
      end

      Rails.logger.error "*** DBUS RETURN #{shares.inspect}"
      return shares

    rescue DBus::Error => dbe
      if dbe.dbus_message.instance_variables.include?("@error_name") && dbe.dbus_message.error_name == "org.freedesktop.DBus.Error.AccessDenied"
        Rails.logger.error "*** DBUS:ERROR #{dbe.dbus_message.error_name.inspect}"
        raise "You have no permissions!"
      else
        Rails.logger.error "*** DBUS:ERROR #{dbe.inspect}"
        raise "Generic exception please report this issue:
          <a href='https://github.com/vlewin/suse-media-server/issues'>github bugtracker</a>"
      end

    rescue Exception => e
      Rails.logger.error "Caught exception: #{e.inspect}"
      raise "Generic exception"
    end

  end

  def self.find(id)
    bus = Bus.new
    hash = bus.find("samba", id)
    args = {}

    hash.each do | key, value |
      args[key] = value
    end

    share = Share.new(args)
    return share
  end
  
  

  def save
    Rails.logger.error "INFO: SAVE ACTION #{self.inspect}"
    bus = Bus.new
    state = Samba.start

    if bus.save("samba", self.to_hash)
      return true
    else
      Rails.logger.error "ERROR: CAN NOT SAVE SHARE"
      return true
    end
  end

  def destroy
    bus = Bus.new
    bus.destroy("samba", self.to_hash) ? true : false
  end
  
end

