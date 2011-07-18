
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
    #Hash[instance_variables.map { |var| [var[1..-1].to_sym, instance_variable_get(var)] }]
    Hash[instance_variables.map { |var| [var[1..-1].to_s, instance_variable_get(var)] }]
  end

  def self.all
    shares = Array.new

    Rails.logger.error "DLNA BUS"
    bus = Bus.new()

    map = bus.send("dlna", {})
    args = {}

      map.each do |key, value|
        args[key] = value
      end

      share = Dlna.new(args)
#      shares << share

    return share
  end

#  def self.find(id)
#    bus = Bus.new
#    hash = bus.find(id)
#    args = {}

#    hash.each do | key, value |
#      args[key] = value
#    end

#    share = Share.new(args)
#    return share
#  end

 def save
    bus = Bus.new
    ret = bus.save(self.to_hash)
  end

end

