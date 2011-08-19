require 'fileutils'

SBIN = "/usr/local/sbin/"
SERVICES_SOURCE_DIR = File.join(RAILS_ROOT, '/package/SERVICES')
SERVICES = ["augeasDLNAService.rb", "augeasSambaService.rb"]

README = File.join(RAILS_ROOT, 'README')

DBUS_SERVICES_DIR = "/usr/share/dbus-1/system-services/"
DBUS_SERVICES = ["augeas.samba.Service.service", "augeas.dlna.Service.service"]
DBUS_SOURCE_DIR = File.join(RAILS_ROOT, '/package/DBUS-SERVICES')

DBUS_CONF_DIR = "/etc/dbus-1/system.d"
DBUS_CONFIGS = ["augeas.samba.Service.conf", "augeas.dlna.Service.conf"]
DBUS_CONF_SOURCE_DIR = File.join(RAILS_ROOT, '/package/DBUS-CONF')

desc 'Copy modified services back to package location'
task :"prepare" do

    puts "\n1) Copy services back to #{SERVICES_SOURCE_DIR}"
    Dir.chdir(SBIN) do
      files = Array.new
      
      SERVICES.each do |f|
        File.join(Dir.getwd + f)
        files << f
      end
      
      files.each do |f|
        sh %{ cp #{f} #{SERVICES_SOURCE_DIR}}
      end
    end
    
    puts "\n2) Copy DBUS Services back to #{DBUS_SOURCE_DIR}"
    Dir.chdir(DBUS_SERVICES_DIR) do
      files = Array.new
      
      DBUS_SERVICES.each do |f|
        File.join(Dir.getwd + f)
        files << f
      end
      
      files.each do |f|
        sh %{ cp #{f} #{DBUS_SOURCE_DIR}}
      end
    end
    
    puts "\n3) Copy DBUS Config files back to #{DBUS_CONF_SOURCE_DIR}"
    Dir.chdir(DBUS_CONF_DIR) do
      files = Array.new
      
      DBUS_CONFIGS.each do |f|
        File.join(Dir.getwd + f)
        files << f
      end
      
      files.each do |f|
        sh %{ cp #{f} #{DBUS_CONF_SOURCE_DIR}}
      end
    end

    puts "\n4) Change file permissions"

    readme = File.new(README, "r")
    uid = readme.stat.uid
    gid = readme.stat.gid

    Dir.chdir(SERVICES_SOURCE_DIR) do
      files = Dir.glob("*")
      files.each do |f|
        owner = "#{uid}:#{gid}"
        sh %{ chown #{owner} #{f}}
      end
    end
    
    puts "\n"
    
    Dir.chdir(DBUS_SOURCE_DIR) do
      files = Dir.glob("*")
      files.each do |f|
        owner = "#{uid}:#{gid}"
        sh %{ chown #{owner} #{f}}
      end
    end
    
    puts "\n"
        
    Dir.chdir(DBUS_CONF_SOURCE_DIR) do
      files = Dir.glob("*")
      files.each do |f|
        owner = "#{uid}:#{gid}"
        sh %{ chown #{owner} #{f}}
      end
    end
end

