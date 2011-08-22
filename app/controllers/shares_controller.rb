require "share.rb"

class SharesController < ApplicationController
  def index
#    @shares = Share.all
#    @global = Share.find('target[1]')
#    @smb = Samba.running?
    begin
      @shares = Share.all
      @global = Share.find('target[1]')
      @smb = Samba.running?
      
    rescue RuntimeError => e
      flash[:notice] = "<div id='flash'><div class='error'><b>ERROR:</b> #{e}</div></div>";
      redirect_to(:controller => :index, :action => 'index')
    end
  end

  def show
    @share = Share.find(params[:id])
    render :partial => 'share'
  end
  
  def new
    @shares = Share.all
    target_id = @shares.length
    @share = Share.new({ "id" => "target[#{target_id+1}]", "name" => "#{params[:name]}"})
    render :partial => 'form', :with => @share, :locals => {:share => @share } 
  end
  
  
  def create
    @share = Share.new(params[:share])
    
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

