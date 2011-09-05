include ApplicationHelper
      
class SmbController < ApplicationController
  def index
    begin
      now = Time.now.to_f
      @shared = Smb.all
      Rails.logger.error "\nGET SHARES #{Time.now}"

      browser = Browser.new('/')
      Rails.logger.error "BROWSER NEW #{Time.now}"

      session["home"] = @current = detectHome
      Rails.logger.error "DETECT HOME #{Time.now}"
       
      @prev = session["home"]
      @dirs = browser.get_content(session["home"]);
      endd = Time.now.to_f
      
      Rails.logger.error "GET CONTENT HOME #{Time.now}"
      Rails.logger.error "BEFORE RENDER #{endd - now}"
      
      render :index, :locals => {:prev => session["home"] }
      

    rescue RuntimeError => e
      flash[:notice] = "<div id='flash'><div class='error'><b>ERROR:</b> #{e}</div></div>";
      redirect_to(:controller => :index, :action => 'index')
    end
  end
  
  def all
    @shared = Smb.all
    
    sleep(0.5)
    Rails.logger.error "\nLISTVIEW SHARED #{@shared.inspect}"
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
      
      @message = "Share successfully added!"
      
      render :update do |page|
        page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
        page.replace_html 'notificationArea', :partial => 'notification', :locals => { :type => "success", :message => @message }
      end
      
    else
      @message = "Something went wrong!"
      render :partial => 'notification', :locals => { :type => "error", :message => @message }
    end
  end
  
  def destroy
    @share = Smb.new(params["share"])


    
    if @share.destroy
      @shared = Smb.all
      Rails.logger.error "\nAFTER DESTROY #{@shared.inspect}"
      
      @message = "Share successfully destroyed!"
      browser = Browser.new('/')
      @path = params["dir"].nil? ? session["home"] : File.dirname(params["dir"])
      @dirs = browser.get_content(@path);
      @prev = File.dirname(@path) unless @path == session["home"]
      
      unless params["listview"]
        
        render :update do |page|
          page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
          page.replace_html 'notificationArea', :partial => 'notification', :locals => { :type => "success", :message => @message }
        end
      else 
        render :update do |page|
          page.replace_html 'listview', :partial => 'listview', :locals => { :shared => @shared }
          page.replace_html 'notificationArea', :partial => 'notification', :locals => { :type => "success", :message => @message }
          page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
        end
      end
    end
  end

  def browse
    browser = Browser.new('/')
    @shared = Smb.all

    @home = session["home"]
    @location = params["dir"]
    # Do not allow user to browse root directories
    params["dir"] == session["home"]? @prev = session["home"] : @prev = File.dirname(params["dir"])
    @dirs = browser.get_content(params["dir"]);

    render :partial => "directories", :locals => {:prev => @prev, :dirs => @dirs }
  end


  def notify(type, message)
    @message = "JUST A MESSAGE"
    # use locals to define notification class, like "ERROR, INFO, CONFIRM ..."
    render :partial => "notification", :locals => {:type => type, :message => message }
  end

end

