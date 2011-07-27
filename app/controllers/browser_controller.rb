#require 'json'


class BrowserController < ApplicationController

  def get
    browser = Browser.new('/')
    @dirs = browser.get_dirs(params["dir"]);
    
    Rails.logger.error "\n *** PARAMS #{params['dir'].inspect} *** \n"

    render :json => @dirs.to_json

  end
end

