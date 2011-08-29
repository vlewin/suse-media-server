include ApplicationHelper

class SharesController < ApplicationController
  def index
    begin
      @shares = Share.all
      @global = Share.find('target[1]')
      @smb = Samba.running?
      
      
      @dirs = scanHomeDirectory
      
      
    rescue RuntimeError => e
      flash[:notice] = "<div id='flash'><div class='error'><b>ERROR:</b> #{e}</div></div>";
      redirect_to(:controller => :index, :action => 'index')
    end
  end

#  def new
#    @shares = Share.all
#    target_id = @shares.length
#    Rails.logger.debug "FORM FOR NEW SHARE target[#{target_id+1}]"
#    
#    @share = Share.new({ "id" => "target[#{target_id+1}]", "name" => "#{params[:name]}"})
#    render :partial => 'form', :with => @share, :locals => {:share => @share } 
#  end
  
  def show
    @share = Share.find(params[:id])
    render :partial => 'share'
  end
  
  
  def create
    Rails.logger.debug "CREATE NEW SHARE #{params[:share].inspect}"

    @shares = Share.all
    target_id = @shares.length
    
    @share = Share.new(params[:share])
    @share.id = "target[#{target_id+1}]"
    
    Rails.logger.debug "CLASS #{@share.inspect}"
    
    if @share.save
      @shares = Share.all
      render :partial => 'shares'
    else 
      render :error
    end

  end

  def update
    @share = Share.new(params[:share])

    if @share.save
      @share = Share.find(params[:share][:id])
      render :partial => 'share', :locals => {:name => @name}
    else 
      render :error
    end

  end
  
  def destroy
    @share = Share.find(params[:id])
    
    if @share.destroy
      @shares = Share.all
      render :partial => 'shares'
    else 
      render :error
    end
  end

  #SYSTEM ACTIONS
  def smbaction
    @smb = Samba.running?
    
    if @smb.status == true 
      @state = Samba.stop
    else
      @state = Samba.start
    end
    render :nothing => true
  end
  
  
  
  
  
  

end

