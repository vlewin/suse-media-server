include ApplicationHelper

class DlnaController < ApplicationController
  def index
    @media = DLNA.all
    
    browser = Browser.new('/')
    session["home"] = @current = detectHome

    @prev = session["home"]
    @dirs = browser.get_content(session["home"]);
    render :index, :locals => {:prev => session["home"] }
  end
  
  def create
    @media = DLNA.new(params[:media])
    Rails.logger.error "MEDIA #{params[:media].inspect}"
    
    if @media.save
    #  browser = Browser.new('/')
    #  @path = params["dir"].nil? ? session["home"] : File.dirname(params["dir"])
    #  @dirs = browser.get_content(@path);
    #  @prev = File.dirname(@path) unless @path == session["home"]
    #  @shared = Smb.all
    #  @message = "Share successfully added!"
      
    #  render :update do |page|
    #    page.replace_html 'directoriesContainer', :partial => 'directories', :locals => { :prev => @prev }
    #    page.replace_html 'notificationArea', :partial => 'notification', :locals => { :type => "success", :message => @message }
    #  end

    #else
    #  @message = "Something went wrong!"
    #  render :partial => 'notification', :locals => { :type => "error", :message => @message }
    end
  end
  
  def navigate
    browser = Browser.new('/')

    @media = DLNA.all
    params["dir"] == session["home"]? @prev = session["home"] : @prev = File.dirname(params["dir"])
    @dirs = browser.get_content(params["dir"]);

    render :partial => "directories", :locals => {:prev => @prev, :dirs => @dirs }
  end
  
end
