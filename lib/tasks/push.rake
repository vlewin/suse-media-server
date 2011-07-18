require 'fileutils'

vars = ['SERVICES']

SERVICES = "/usr/local/sbin/"
SOURCE = File.join(RAILS_ROOT, '/package/SERVICES')
README = File.join(RAILS_ROOT, 'README')

desc 'Copy modified services back to package location'
task :"prepare" do

    puts "\nCopy services back to source directory"
    Dir.chdir(SERVICES) do
      files = Dir.glob("*")
      files.each do |f|
        sh %{ cp #{f} #{SOURCE}}
      end
    end

    puts "\nChange file permissions"

    readme = File.new(README, "w")
    uid = readme.stat.uid
    gid = readme.stat.gid

    Dir.chdir(SOURCE) do
      files = Dir.glob("*")
      files.each do |f|
        owner = "#{uid}:#{gid}"
        sh %{ chown #{owner} #{f}}
      end
    end
end

