require 'fileutils'

vars = ['PACKAGE', 'POLICY', 'DBUS_CONF', 'USR']

PACKAGE = File.join(RAILS_ROOT, '/package')
POLICY = "/usr/share/PolicyKit/policy/"
DBUS_CONF = "/etc/dbus-1/system.d/"
USR = "/usr/local/sbin/"

desc 'Install policy and dbus configurate files'
task :"install" do

    #install policy files
    puts "\nInstall policy files"
    Dir.chdir("#{PACKAGE}/POLKIT") do 
      files = Dir.glob("*")
      puts files.inspect    
      files.each do |f|
        sh %{ cp #{f} #{POLICY}}
        puts "\n#{PACKAGE}/POLKIT/#{f}"
      end
    end
    
    #install dbus configuration files
    puts "\nInstall dbus configuration files"
    Dir.chdir("#{PACKAGE}/DBUS") do 
      files = Dir.glob("*")
      puts files.inspect    
      files.each do |f|
        sh %{ cp #{f} #{DBUS_CONF}}
        puts "\n#{PACKAGE}/DBUS/#{f}"
      end
    end
    
    
    #install dbus service files
    puts "\nInstall dbus services"
    Dir.chdir("#{PACKAGE}/SERVICES") do 
      files = Dir.glob("*")
      puts files.inspect    
      files.each do |f|
        sh %{ cp #{f} #{USR}}
        puts "\n#{PACKAGE}/SERVICES/#{f}"
      end
    end    
end


