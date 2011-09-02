include ApplicationHelper
      
class SmbController < ApplicationController
  def index
    begin
      now = Time.now.to_f
      @shared = Smb.all
      Rails.logger.error "\nGET SHARES #{Time.now}"

      browser = Browser.new('/')
      Rails.logger.error "BROWSER NEW #{Time.now}"

      @home = @current = detectHome
      Rails.logger.error "DETECT HOME #{Time.now}"
       
      session["home"] = @home
      @prev = @home
      #session["home"] = @prev = @home
      @dirs = browser.get_content(@home);
      endd = Time.now.to_f
      
      #Rails.logger.error "DIRS #{@dirs.inspect} \n"
      Rails.logger.error "GET CONTENT HOME #{Time.now}"
      
      Rails.logger.error "BEFORE RENDER #{endd - now}"
      render :index, :locals => {:prev => @home }

    rescue RuntimeError => e
      flash[:notice] = "<div id='flash'><div class='error'><b>ERROR:</b> #{e}</div></div>";
      redirect_to(:controller => :index, :action => 'index')
    end
  end
  
  def create
    #Rails.logger.debug "CREATE NEW SHARE #{params[:share].inspect} check number #{cookies[:shares_number]}"
    browser = Browser.new('/')
    #@shares = Share.all
    @share = Smb.new(params[:share])
    @dirs = browser.get_content(session["home"]);
    @shared = Smb.all
    
    if @share.save
      render :partial => 'directories', :locals => {:prev => session["home"] }
    end
   
    Rails.logger.error "PARAMS #{params[:share].inspect}"

  end
  
  

  def browse
    browser = Browser.new('/')
    @shared = Smb.all

    # Do not allow user to browse root directories
    #BUG: CHECK PARAMS AND HOME

    #Rails.logger.error "\n*****  *****"

    @home = session["home"]
    @location = params["dir"]
   
    #Rails.logger.error "HOME #{@home.inspect}"
    #Rails.logger.error "SESSION HOME #{session["home"].inspect}"	

    params["dir"] == session["home"]? @prev = session["home"] : @prev = File.dirname(params["dir"])

    @dirs = browser.get_content(params["dir"]);

    #Rails.logger.error "PARAM DIR #{params["dir"].inspect}"	
    #Rails.logger.error "PREVIOUS #{@prev.inspect}"
    
    #Rails.logger.error "DIRS #{@dirs.inspect} \n"

    render :partial => "directories", :locals => {:prev => @prev, :dirs => @dirs }
  end


  def notify
    @message = "JUST A MESSAGE"
    # use locals to define notification class, like "ERROR, INFO, CONFIRM ..."
    render :partial => "notification", :with => { :message => @message }
  end

end

