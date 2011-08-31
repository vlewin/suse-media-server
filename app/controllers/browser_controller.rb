class BrowserController < ApplicationController
  def get
    browser = Browser.new('/')
    @dirs = browser.get_content(params["dir"]);
    render :json => @dirs.to_json
  end
end

