require 'json'


class BrowserController < ApplicationController
  
  def get
#    browser = Browser.new('/work')
#    @dirs = browser.get_dirs();
    @json = { :parent => ["f1", "f2", "f3"], :date => Time.now }
    @json = { :parent => [{:f1 => ["s1", "s2"]}, :f2, :f3], :date => Time.now }
    render :json => @json.to_json

  end
end
