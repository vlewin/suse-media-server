class Browser

  def initialize(root)
    @root = root
  end


#  def get_dirs(path=".")
  def get_dirs(dir)
    path = "" if path.nil?


    @path = File.join(File.expand_path(@root), dir)

    Rails.logger.error "PATH #{@path}"

    @dirs = []

    if File.exists?(@path)
      Dir.entries(@path).each do |dir|
        if File.directory?(File.join(@path, dir)) && dir[0,1]!="."
          Rails.logger.error "DIR #{dir}"
          @dirs << dir
        end
      end
    end

    Rails.logger.error "DIRs #{@dirs}"

#    @dirs

    @dirs = {:dirs => @dirs}

  end

  def get_content(path=".")
    get_dirs(path)
  end

end

