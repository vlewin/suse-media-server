require "bus.rb"



class Samba
  attr_accessor :status

  def initialize(status)
    @status = status
  end

  def self.running?
    bus = Bus.new()
#    result = bus.exec("rcsmb status")
    result = bus.exec("/etc/init.d/smb status")
    Rails.logger.error "SAMBA status from DBUS #{result}"
    smb = Samba.new(result)
    smb
  end


  #DRY !!!
  def self.start
    bus = Bus.new
    
    smbd = bus.exec("/etc/init.d/smb start")
    nmbd = bus.exec("/etc/init.d/nmb start")
    
   # smbd = bus.exec("rcsmb start")
   # nmbd = bus.exec("rcnmb start")

    #start rcnmb and rcsmb if both OK return true
    if smbd && nmbd
      Rails.logger.error "SAMBA START smb #{smbd} and nmb #{nmbd}"
      return true
    else
      return false
    end

  end

  #DRY !!!
  def self.stop
    bus = Bus.new
    
    smbd = bus.exec("/etc/init.d/smb stop")
    nmbd = bus.exec("/etc/init.d/nmb stop")
    
#    smbd = bus.exec("rcsmb stop")
#    nmbd = bus.exec("rcnmb stop")

    if smbd && nmbd
      Rails.logger.error "SAMBA STOP smb #{smbd} and nmb #{nmbd}"
      return true
    else
      return false
    end

  end
end

