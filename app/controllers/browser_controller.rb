class BrowserController < ApplicationController
#  USER = ENV['USER']
#  HOME = ENV['HOME'] #or File.expand_path('~')
  
  def get
    browser = Browser.new('/')
    @dirs = browser.get_content(params["dir"]);
    render :json => @dirs.to_json
  end
  
end

