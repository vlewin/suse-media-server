class Browser
  #init root directory (set default to user home)
  def initialize(root)
    @root = root
  end

  #TODO: Impove Dir browser, find a way to avoid Errno::EACCES and Errno::ENOENT
  def get_content(dir)
    @path = File.join(File.expand_path(@root), dir)
    @hash = Hash.new
    @dirs = Hash.new

    if File.exists?(@path) && File.readable?(@path)
      begin

        Dir.entries(@path).each do |dir|

          if File.directory?(File.join(@path, dir)) && dir[0,1]!="."
            #Rails.logger.error " - #{dir}"

            @dir = {"path" => File.join(@path, dir)}

            @subpath = File.join(File.expand_path(@path), dir)


            if File.exists?(@subpath) && File.directory?(@subpath) && File.readable?(@subpath)
              #Rails.logger.error "FILE EXIST? #{@subpath} #{File.exists?(@subpath)}"
              has_child = false


              Dir.entries(@subpath).each do |subdir|
                #Rails.logger.error "INSIDE DIR ENTRIES?"
                if File.readable?(@subpath) && File.directory?(File.join(@subpath, subdir)) && subdir[0,1]!="."
                  has_child = true
                end
              end
              @dir["children"] = has_child ?  "yes" : "no"
            end

            @hash[dir] = @dir
          end

        end
      rescue Errno::EACCES
        Rails.logger.error "ERROR: Permission denied - <#{dir}>"
        @hash = "ERROR: Permission denied - <#{dir}>"

      rescue Errno::ENOENT
        Rails.logger.error "ERROR: No such file or directory - <#{dir}>"
        @hash = "ERROR: No such file or directory - <#{dir}> "
      rescue Exception => e
        @hash = e.inspect
      end
    end

    #Rails.logger.error "CLASS #{@hash.class} HASH #{@hash.inspect}"
    return @hash.sort
  end




end

