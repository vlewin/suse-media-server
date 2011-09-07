include ApplicationHelper

class DlnaController < ApplicationController
  def index
    @media_dirs = DLNA.all
    session["home"] = detectHome
    @prev = session["home"]
    @dirs = list(session["home"])

    render :index, :locals => {:prev => session["home"] }
  end
  
  def listview
    @types = {"M" => "mixed", "A" => "music", "P" => "pictures", "V" => "videos"}
    @media_dirs = DLNA.all
    sleep(0.7) #???
    
    render :update do |page|
      page.replace_html 'listview', :partial => 'listview'
    end
  end
  
  # GET GLOBAL SETTINGS FOR MINIDLNA
  def getSettings
    @settings = DLNA.settings
    sleep(0.5) #???
    render :partial => 'settings'
  end
  
  # SET GLOBAL SETTINGS FOR MINIDLNA
  def saveSettings
    settings = DLNA.new(params["settings"])
    
    if settings.saveSettings
      @settings = DLNA.settings
      render :partial => 'settings'
    else
      @message = "Something went wrong!"
      render :partial => '/shared/notification', :locals => { :type => "error", :message => @message }
    end
  end
  
  def create
    params[:media]["type"] = params[:type] unless params[:type].empty?
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
      @message = "Directory successfully removed from the list"  
      @media_dirs = DLNA.all
      
      unless params["listview"]
        params["dir"] == session["home"]? @prev = session["home"] : @prev = File.dirname(params["dir"])
        @dirs = list(@prev)
        
        render :update do |page|
          page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
          page.replace_html 'notificationArea', :partial => '/shared/notification', :locals => { :type => "success", :message => @message }
        end
      else 
        @types = {"M" => "mixed", "A" => "music", "P" => "pictures", "V" => "videos"}
        
        @dirs = list(session["home"]);
        @prev =  session["home"]
        
        render :update do |page|
          page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
          page.replace_html 'listview', :partial => 'listview', :locals => { :media_dirs => @media_dirs }
          page.replace_html 'notificationArea', :partial => '/shared/notification', :locals => { :type => "success", :message => @message }
        end
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
  
  def action
    @status = DLNA.control
    render :nothing => true
  end
  
end
