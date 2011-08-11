require 'fileutils'

#vars = ['PACKAGE', 'POLICY', 'DBUS_CONF', 'USR']

PACKAGE = File.join(RAILS_ROOT, '/package')

POLKIT_DIR = "/usr/share/PolicyKit/policy/"

DBUS_SERVICES = ["augeas.samba.Service.service", "augeas.dlna.Service.service"]
DBUS_SOURCE_DIR = File.join(RAILS_ROOT, '/package/DBUS-SERVICES')

DBUS_CONF_DIR = "/etc/dbus-1/system.d/"
DBUS_SERVICES_DIR = "/usr/share/dbus-1/system-services/"

SBIN = "/usr/local/sbin/"

desc 'Install policy and dbus configurate files'
task :"install" do

    #install policy files
    puts "\n1) Install policy files"
    
    Dir.chdir("#{PACKAGE}/POLKIT") do 
      files = Dir.glob("*")

      files.each do |f|
        sh %{ cp #{f} #{POLKIT_DIR}}
      end
    end
    
    #install dbus configuration files
    puts "\n2) Install dbus configuration files"

    Dir.chdir("#{PACKAGE}/DBUS") do 
      files = Dir.glob("*")

      files.each do |f|
        sh %{ cp #{f} #{DBUS_CONF_DIR}}
      end
    end
    
    
    #install dbus configuration files
    puts "\n3) Install ruby dbus services"
    Dir.chdir("#{PACKAGE}/SERVICES") do 
      files = Dir.glob("*")

      files.each do |f|
        sh %{ cp #{f} #{SBIN}}
      end
    end
    
    #install dbus configuration files
    puts "\n4) Install dbus services"
    Dir.chdir("#{PACKAGE}/DBUS-SERVICES") do 
      files = Dir.glob("*")

      files.each do |f|
        sh %{ cp #{f} #{DBUS_SERVICES_DIR}}
      end
    end
end


