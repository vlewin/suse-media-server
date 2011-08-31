require 'json'
include ApplicationHelper

class SharesController < ApplicationController
  #session :on
  
  def index
    begin
      #@shares = Share.all
      cookies[:shares_number] = @shares.length unless @shares.nil?
      
      Rails.logger.error "\n*** CHECK number #{cookies[:shares_number]}"
      @smb = Samba.running?
      
      
      browser = Browser.new('/')
      @dirs = browser.get_content(detectHome);
      
    rescue RuntimeError => e
      flash[:notice] = "<div id='flash'><div class='error'><b>ERROR:</b> #{e}</div></div>";
      redirect_to(:controller => :index, :action => 'index')
    end
  end

  def show
    @share = Share.find(params[:id])
    render :partial => 'share'
  end
  
  def create
    Rails.logger.debug "CREATE NEW SHARE #{params[:share].inspect} check number #{cookies[:shares_number]}"

    #@shares = Share.all
    @share = Share.new(params[:share])
    
    if params["id"].nil?
      number = cookies[:shares_number].to_i + 2
      target = "target[#{number}]"
      @share.id = target
    end
    
    if @share.save
      @shares = Share.all
      cookies[:shares_number] = @shares.length unless @shares.nil?
      
      render :update do |page|
        page.replace_html 'all-container', :partial => 'shares'
        page.replace_html 'new-container', :partial => 'new'
      end
    end

  end

  def update
    @share = Share.new(params[:share])
    if @share.save
      @share = Share.find(params[:share][:id])
      render :partial => 'share'
    else 
      render :text => "Can not save share"
    end
  end
  
  def saveSettings
    @share = Share.new(params[:share])
    if @share.save
      @share = Share.find(params[:share][:id])
      render :partial => 'settings'
    else 
      render :error
    end
  end
  
  
  def destroy
    if params["share"]
      Rails.logger.debug "DESTROY SHARE WITH ID #{params["share"]["id"].inspect}"
      @share = Share.find(params["share"]["id"])
    else 
      Rails.logger.debug "DESTROY SHARE WITH ID #{params["id"].inspect}"    
      @share = Share.find(params["id"])
    end
  
    if @share.destroy
      @shares = Share.all
      cookies[:shares_number] = @shares.length unless @shares.nil?
      
      render :update do |page|
        page.replace_html 'all-container', :partial => 'shares'
        page.replace_html 'new-container', :partial => 'new'
      end
    else 
      render :text => "Something went wrong, please contact developer"
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

