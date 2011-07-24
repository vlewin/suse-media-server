class Share
  PROPERTIES = [:id, :name, :path, :writeable, :browseable, :read_only, :comment]
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
    #Hash[instance_variables.map { |var| [var[1..-1].to_sym, instance_variable_get(var)] }]
    Hash[instance_variables.map { |var| [var[1..-1].to_s, instance_variable_get(var)] }]
  end

  def self.all
    shares = Array.new
    bus = Bus.new		

    shares_map = bus.find_all("samba")
    args = {}

    shares_map.each do |elem|
      elem.each do |key, value|
        args[key] = value
      end

      share = Share.new(args)
      shares << share
    end

    return shares
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
    bus = Bus.new
    state = bus.save("samba", self.to_hash)
    return state
  end

end

