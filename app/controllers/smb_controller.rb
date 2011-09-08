include ApplicationHelper
      
class SmbController < ApplicationController
  def index
    begin
      @shared = Smb.all
      browser = Browser.new('/')
      session["home"] = @current = detectHome
      @prev = session["home"]
      @dirs = browser.get_content(session["home"]);
      
      render :index, :locals => {:prev => session["home"] }
      
    rescue RuntimeError => e
      flash[:notice] = "<div id='flash'><div class='error'><b>ERROR:</b> #{e}</div></div>";
      redirect_to(:controller => :index, :action => 'index')
    end
  end
  
  def all
    @shared = Smb.all
    sleep(0.5) #???
    
    render :update do |page|
      page.replace_html 'listview', :partial => 'listview', :locals => { :shared => @shared }
    end
  end
  
  def create
    @share = Smb.new(params[:share])
    
    if @share.save
      browser = Browser.new('/')
      @path = params["dir"].nil? ? session["home"] : File.dirname(params["dir"])
      @dirs = browser.get_content(@path);
      @prev = File.dirname(@path) unless @path == session["home"]
      @shared = Smb.all
      @message = "Directory successfully added!"
      
      render :update do |page|
        page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
#        page.replace_html 'notificationArea', :partial => 'notification', :locals => { :type => "success", :message => @message }
        page.replace_html 'notificationArea', :partial => '/shared/notification', :locals => { :type => "success", :message => @message }
      end

    else
      @message = "Something went wrong!"
      render :partial => '/shared/notification', :locals => { :type => "error", :message => @message }
    end
  end
  
  def destroy
    @share = Smb.new(params["share"])
    
    if @share.destroy
      @shared = Smb.all
      @message = "Directory successfully removed form the list!"
      browser = Browser.new('/')
            
      unless params["listview"]
        @path = params["dir"].nil? ? session["home"] : File.dirname(params["dir"])
        @dirs = browser.get_content(@path);
        @prev = File.dirname(@path) unless @path == session["home"]
        
        render :update do |page|
          page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
          page.replace_html 'notificationArea', :partial => '/shared/notification', :locals => { :type => "success", :message => @message }
        end
      else 
        @dirs = browser.get_content(session["home"]);
        @prev =  session["home"]
        
        render :update do |page|
          page.replace_html 'listview', :partial => 'listview', :locals => { :shared => @shared }
          #page.replace_html 'notificationArea', :partial => 'notification', :locals => { :type => "success", :message => @message }
          page.replace_html 'notificationArea', :partial => '/shared/notification', :locals => { :type => "success", :message => @message }          
          page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
        end
      end
    end
  end


  def getSettings
    global = Smb.find("target[1]")
    render :partial => 'settings', :locals => { :global => global }
  end
  
  def saveSettings
    share = Smb.new(params["share"])
    
    if share.save
      share = Smb.find(params[:share][:id])
      render :partial => 'settings', :locals => { :global => share }
    else
      @message = "Something went wrong!"
#      render :partial => 'notification', :locals => { :type => "error", :message => @message }
      render :partial => '/shared/notification', :locals => { :type => "error", :message => @message }
    end
  end
  
  def navigate
    browser = Browser.new('/')
    @shared = Smb.all
    #@home = session["home"]

    #@location = params["dir"]
    # Do not allow user to browse root directories
    
    params["dir"] == session["home"]? @prev = session["home"] : @prev = File.dirname(params["dir"])
    @dirs = browser.get_content(params["dir"]);

    #render :partial => '/shared/notification', :locals => { :type => "success", :message => @message }
    render :partial => "directories", :locals => {:prev => @prev, :dirs => @dirs }
  end


  def action
    @status = Smb.control
    render :nothing => true
  end
  
  def restart
    if Smb.restart
      @message = "Services successfully restarted!"      
      render :partial => '/shared/notification', :locals => { :type => "success", :message => @message }      
    else
      @message = "An error occurred during services restart"
      render :partial => '/shared/notification', :locals => { :type => "error", :message => @message }
    end
  end
  
  def permissions
    if Smb.permissions
      @message = "Write permissions granted!"
      render :partial => '/shared/notification', :locals => { :type => "success", :message => @message }      
    else
      @message = "Operation not permitted!"
      render :partial => '/shared/notification', :locals => { :type => "error", :message => @message }
    end
  end

end

