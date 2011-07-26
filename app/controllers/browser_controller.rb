require 'json'


class BrowserController < ApplicationController
  
  def get
    browser = Browser.new('/work')
    @dirs = browser.get_dirs(params["dir"]);
#    @json = { :parent => ["f1", "f2", "f3"], :date => Time.now }
 
#    @json = { :parent => [{:f1 => ["s1", "s2"]}, :f2, :f3], :date => Time.now }
    
#    @json = {:dirs => [{:f1 => ["s1", "s2"]}, "f2", "f3" ]}


    Rails.logger.error "DIR #{params['dir'].inspect}"
    
    Rails.logger.error @dirs
    #Rails.logger.error browser.get_dirs(@dirs[0])
    
    #only dirs
#    @json = {:dirs => ["f1", "f2", "f3" ]}
    
    #only one dir with subdirs
#    @json = {:dirs => [{:f1 => ["s1", "s2"]}, "f2", "f3" ]}
    
    #two dirs with subdirs
#    @json = {:dirs => [{:f1 => ["s1", "s2"]}, {:f2 => ["s1", "s2"]} ]}
    
    #tree dirs with subdirs
#    @json = {:dirs => [{:f1 => ["s1", "s2"]}, {:f2 => ["s1", "s2"]}, {:f2 => ["s1", "s2", "s3", "s4"]} ]}
    
    render :json => @dirs.to_json

  end
end
