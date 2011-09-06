require "bus.rb"



class Samba
  attr_accessor :status

  def initialize(status)
    @status = status
  end

  def self.running?
    bus = Bus.new()
    result = bus.exec("smb", "/etc/init.d/smb status")
    Rails.logger.error "SAMBA status from DBUS #{result}"
    smb = Samba.new(result)
    smb
  end


  #DRY !!!
  def self.start
    bus = Bus.new
    
    smbd = bus.exec("smb", "/etc/init.d/smb start")
    nmbd = bus.exec("smb", "/etc/init.d/nmb start")
    
    #start rcnmb and rcsmb if both OK return true
    if smbd && nmbd
      return true
    else
      return false
    end

  end

  #DRY !!!
  def self.stop
    bus = Bus.new
    smbd = bus.exec("smb", "/etc/init.d/smb stop")
    nmbd = bus.exec("smb", "/etc/init.d/nmb stop")

    if smbd && nmbd
      Rails.logger.error "SAMBA STOP smb #{smbd} and nmb #{nmbd}"
      return true
    else
      return false
    end

  end
end

