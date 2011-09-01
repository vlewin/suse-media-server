include ApplicationHelper

class SmbController < ApplicationController
  def index
    begin
      browser = Browser.new('/')
      @dirs = browser.get_content(detectHome);

    rescue RuntimeError => e
      flash[:notice] = "<div id='flash'><div class='error'><b>ERROR:</b> #{e}</div></div>";
      redirect_to(:controller => :index, :action => 'index')
    end
  end
end
