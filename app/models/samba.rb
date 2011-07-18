require "bus.rb"
class Samba
  def self.running?
    bus = Bus.new()
    ret = bus.exec("rcnmb status")
    Rails.logger.error "SAMBA running? #{ret}"
    ret
  end

  def self.start
    bus = Bus.new
    state = bus.exec("rcnmb start")
    Rails.logger.error "AFTER START SAMBA running? #{state}"
    return state
  end

  def self.stop
    bus = Bus.new
    state = bus.exec("rcnmb stop")
    Rails.logger.error "AFTER START SAMBA running? #{state}"
    return state
  end
end
