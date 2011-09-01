include ApplicationHelper

class SmbController < ApplicationController
  def index
    begin
      @shared = Smb.shared
      Rails.logger.error(@shared.inspect)
      
      browser = Browser.new('/')
      @home = detectHome
      
      session["home"] = @prev = @home
      @dirs = browser.get_content(@home);
      render :index, :locals => {:prev => @home }

    rescue RuntimeError => e
      flash[:notice] = "<div id='flash'><div class='error'><b>ERROR:</b> #{e}</div></div>";
      redirect_to(:controller => :index, :action => 'index')
    end
  end
  
  def browse
    browser = Browser.new('/')
    @shared = Smb.shared
        
    # Do not allow user to browse root directories
    #BUG: CHECK PARAMS AND HOME
    File.dirname(params["dir"]) == session["home"]? @prev = session["home"] : @prev = File.dirname(params["dir"])
    @dirs = browser.get_content(params["dir"]);
    
    Rails.logger.error "PREVIOUS #{@prev.inspect} AND HOME FROM SESSION #{session["home"].inspect}"
    render :partial => "directories", :locals => {:prev => @prev }
  end
  
  
  def notify
    @message = "JUST A MESSAGE"
    # use locals to define notification class, like "ERROR, INFO, CONFIRM ..."
    render :partial => "notification", :with => { :message => @message }
  end
  
end
