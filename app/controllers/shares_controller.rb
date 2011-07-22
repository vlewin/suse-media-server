require "share.rb"

class SharesController < ApplicationController
  def index
    @shares = Share.all
    @global = Share.find('target[1]')

    @smb = Samba.running?
    
    Rails.logger.error "SAMBA is running #{@smb.status}"
    Rails.logger.debug "\n*** INDEX:: ALL SHAREs #{@shares.inspect}"
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
    Rails.logger.debug "\n*** CREATE NEW SHARE "
    @share = Share.new(params[:share])
    
    if @share.save
      @shares = Share.all
      Rails.logger.debug "CREATE:: ALL SHARES"
      Rails.logger.debug @shares.inspect
      Rails.logger.debug "\n END"
      
      render :partial => 'shares', :locals => {:shares => @shares } 
      
      #render :update do |page|
      #  page.replace_html  'mcontent', :partial => "shares", :object => [@shares]
      #end

      
      #redirect_to :shares
    else 
      render :text => "ERROR"
    end

  end

  def update
    Rails.logger.debug "\n*** UPDATE SHARE #{params.inspect} and NAME #{params[:share][:name]}"

    @share = Share.new(params[:share])

    if @share.save
      @share = Share.find(params[:share][:id])
      render :partial => 'share', :locals => {:name => @name}
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

