class Browser

  def initialize(root)
    @root = root
  end

  def get_dirs(path=".")
    path = "" if path.nil?
    
    
    @path = File.join(File.expand_path(@root), path)
    @dirs = []
    
    if File.exists?(@path)
      Dir.entries(@path).each do |dir|
        if File.directory?(File.join(@path, dir)) && dir[0,1]!="."
          @dirs << dir
        end
      end
    end

    @dirs
    
#    @dirs = {:dirs => @dirs}
    
  end

  def get_content(path=".")
    get_dirs(path)
  end

end
