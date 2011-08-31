# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def detectHome
  # Try to get logged in user (LINUX -> users)
    users = `users`
    users = users.split(" ").uniq
    
    if users.length == 1 
      #one user is loged in
      #Rails.logger.error "*** DEBUG: ONE USER IS LOGGED IN:"
      user = "~#{users.first}"
      #Rails.logger.debug "*** INFO: <#{user}> IS LOGGED IN"
    else 
      #Rails.logger.debug "*** DEBUG: MORE THAN ONE USERS IS LOGGED IN:"

      # DO NOT USE ROOT HOME DIR
      users.each do |user|
        unless user == "root"
          user = "~#{user}"
          #Rails.logger.debug "*** INFO: <#{user}> IS LOGGED IN"
        end
      end
    end
     
    # use <system user home> if user is not defined
    if defined?(user)
      home = File.expand_path(user)
      #Rails.logger.debug "*** INFO: SCAN HOME DIRECTORY: <#{home}>"
    else
      # WebServer is running as USER --> <AUGEAS???> than use /home/augeas as default
      unless ENV['USERNAME'].nil?
        user = ENV['USERNAME']
        home = ENV['HOME']
        
        #Rails.logger.debug "*** INFO: IF NO USER LLOGED IN USE WEB SERVER USER (SHOULD BE AUGEAS)"
        #Rails.logger.debug "SYSTEM USER:\t #{ENV['USERNAME']}"
        #Rails.logger.debug "SYSTEM HOME:\t #{ENV['HOME']}\n\n"
      end
    end
    
    return home
    
  end
  
  #TODO: USER CHECK MOVE TO SHARE OR USER MODEL !!!
  
  def scanHomeDirectory
    home = detectHome
    dirs = ["Videos", "Video", "Bilder", "Pictures", "Musik", "Documents", "Dokumente"]
    directories = Hash.new
    
    Dir.entries(home).each do |dir|
      if File.directory?(File.join(home, dir)) && dir[0,1]!="." && dirs.include?(File.basename(dir))
        #Rails.logger.debug "DIRECTORIES IN HOME:\t #{dir}"
        directories[dir] = File.join(home, dir)
      end
    end
    
    #Rails.logger.debug "HOME #{home} INSPECT #{directories.inspect}"
    return directories
  end
  
  def shared?(path)
    @shares = Share.all
    isShared = false
    @shares.each do |s|
      #Rails.logger.debug "SHARE #{s.name.inspect}"
      if s.path == path
        #Rails.logger.debug "RETURN TRUE FOR #{s.id}"
        isShared = s.id
        break
      end
    end
    isShared
  end
end
