require "bus.rb"



class Samba
  attr_accessor :status
  
  def initialize(status)
    @status = status
  end
  
  def self.running?
    bus = Bus.new()
    result = bus.exec("rcsmb status")
    Rails.logger.error "SAMBA status from DBUS #{result}"
    smb = Samba.new(result)
    smb
  end

  def self.start
    bus = Bus.new
    state = bus.exec("rcsmb start")
    Rails.logger.error "AFTER START SAMBA running? #{state}"
    return state
  end

  def self.stop
    bus = Bus.new
    state = bus.exec("rcsmb stop")
    Rails.logger.error "AFTER START SAMBA running? #{state}"
    return state
  end
end
