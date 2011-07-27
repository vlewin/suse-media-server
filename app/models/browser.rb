class Browser

  #init root directory (set default to user home)
  def initialize(root)
    @root = root
  end

    #RETURN @json = {:dirs => [{:f1 => "class"}, "f2", "f3" ]}
  def get_content(dir)
    Rails.logger.error "\n ### LIST DIRECTORIES ### \n"

    @path = File.join(File.expand_path(@root), dir)
    @hash = Hash.new
    @dirs = Hash.new

    if File.exists?(@path)
      Dir.entries(@path).each do |dir|
        
        if File.directory?(File.join(@path, dir)) && dir[0,1]!="."
          
          Rails.logger.error " - #{dir}"
          
          @dir = {"path" => File.join(@path, dir)}
          

          @subpath = File.join(File.expand_path(@path), dir)

          if File.exists?(@subpath)
              has_child = false
              
              Dir.entries(@subpath).each do |subdir|
                if File.directory?(File.join(@subpath, subdir)) && subdir[0,1]!="." 
                  has_child = true
                end
              end

              if has_child
                @dir["children"] = "yes" 
              else
                @dir["children"] = "no" 
              end
          end
          
          @hash[dir] = @dir
        end

      end
    end

    return @hash
  end









  #RETURN @json = {:dirs => [{:f1 => "class"}, "f2", "f3" ]}
  def get_dirs(dir)
    
    @hash = {}
    @array = []
    
    @path = File.join(File.expand_path(@root), dir)
    @dirs = []

    Rails.logger.error "\n ### LIST DIRECTORIES ### \n"
    
#    @array << @path

    #return {[:dir1 => {}]}

    if File.exists?(@path)
      Dir.entries(@path).each do |dir|
        
        if File.directory?(File.join(@path, dir)) && dir[0,1]!="."
          
          Rails.logger.error " - #{dir}"
          @subpath = File.join(File.expand_path(@path), dir)
          
          @shash = {}
          @sarray = []
      
          if File.exists?(@subpath)
              has_child = false
              Dir.entries(@subpath).each do |subdir|
                if File.directory?(File.join(@subpath, subdir)) && subdir[0,1]!="." 
                  has_child = true
                  Rails.logger.error " -- #{subdir}"
                  @shash[dir] = @subpath
                end
              end
              
              if has_child
                Rails.logger.error "== #{dir} => Has children"
                @array << @shash
              else
                @array << dir
                  
              end
              
          end
          
#          @array << dir
          
          
        end
      end
    end

    @hash[:dirs] = @array
    
    Rails.logger.error "HASH #{@hash.inspect}"
    
    return @hash
  end

  


  #RETURN @json = {:dirs => [{:f1 => ["s1", "s2"]}, "f2", "f3" ]}
#  def get_dirs_with_subdirs(dir)
#    
#    @hash = {}
#    @array = []
#    
#    @path = File.join(File.expand_path(@root), dir)
#    @dirs = []

#    if File.exists?(@path)
#      Dir.entries(@path).each do |dir|
#        if File.directory?(File.join(@path, dir)) && dir[0,1]!="."
#          
#          Rails.logger.error " - #{dir}"
#          @subpath = File.join(File.expand_path(@path), dir)
#          
#          
#          @shash = {}
#          @sarray = []
#      
#          if File.exists?(@subpath) && Dir.entries(@subpath).count > 2
#            Dir.entries(@subpath).each do |subdir|
#              if File.directory?(File.join(@subpath, subdir)) && subdir[0,1]!="."
#                Rails.logger.error " -- #{subdir}"
#                #@array << ":#{dir} => subdir"
#                @sarray << subdir
#                
#              end
#            end
#            
#            @shash[dir] = @sarray
#            @array << @shash
#          else
#            @array << dir
#          end
#          
#          @dirs << dir
#          
#        end
#      end
#    end

#    @hash[:dirs] = @array
#    Rails.logger.error "HASH #{@hash.inspect}"
##    @dirs = {:dirs => @dirs}
#    
#    return @hash
#  end

end

