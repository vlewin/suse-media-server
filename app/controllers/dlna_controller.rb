include ApplicationHelper

class DlnaController < ApplicationController
  def index
    @media_dirs = DLNA.all
    session["home"] = detectHome
    @prev = session["home"]
    @dirs = list(session["home"])

    Rails.logger.error "MEDIA DIRS #{@media_dirs.inspect}"
    render :index, :locals => {:prev => session["home"] }
  end
  
  def create
    @media = DLNA.new(params[:media])
    
    if @media.save
      params["dir"] == session["home"]? @prev = session["home"] : @prev = File.dirname(params["dir"])
      @dirs = list(@prev)
      @media_dirs = DLNA.all

      @message = "Directory successfully added!"
      
      render :update do |page|
        page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
        page.replace_html 'notificationArea', :partial => '/shared/notification', :locals => { :type => "success", :message => @message }
      end

    else
      @message = "Something went wrong!"
      render :partial => '/shared/notification', :locals => { :type => "error", :message => @message }
    end
  end
  
  def destroy
    @media = DLNA.new(params[:media])
    
    if @media.destroy
      params["dir"] == session["home"]? @prev = session["home"] : @prev = File.dirname(params["dir"])
      @dirs = list(@prev)
      @media_dirs = DLNA.all

      @message = "Directory successfully destroyed!"
      
      render :update do |page|
        page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
        page.replace_html 'notificationArea', :partial => '/shared/notification', :locals => { :type => "success", :message => @message }
      end
    end
  end
  
  def navigate
    @media_dirs = DLNA.all
    params["dir"] == session["home"]? @prev = session["home"] : @prev = File.dirname(params["dir"])
    @dirs = list(params["dir"])

    render :partial => "directories", :locals => {:prev => @prev, :dirs => @dirs }
  end
  
  def list(path)
    browser = Browser.new('/')
    dirs = browser.get_content(path);
    return dirs
  end
  
end
