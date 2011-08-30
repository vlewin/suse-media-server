include ApplicationHelper

class SharesController < ApplicationController
  def index
    begin
      @shares = Share.all
      @smb = Samba.running?
    rescue RuntimeError => e
      flash[:notice] = "<div id='flash'><div class='error'><b>ERROR:</b> #{e}</div></div>";
      redirect_to(:controller => :index, :action => 'index')
    end
  end

#  def new
#    @shares = Share.all
#    target_id = @shares.length
#    Rails.logger.debug "FORM FOR NEW SHARE target[#{target_id+1}]"
#    
#    @share = Share.new({ "id" => "target[#{target_id+1}]", "name" => "#{params[:name]}"})
#    render :partial => 'form', :with => @share, :locals => {:share => @share } 
#  end
  
  def show
    @share = Share.find(params[:id])
    render :partial => 'share'
  end
  
  
  def create
    Rails.logger.debug "CREATE NEW SHARE #{params[:share].inspect}"

    @shares = Share.all
    @share = Share.new(params[:share])
    
    Rails.logger.debug "PARAMS ID? #{params[id].inspect}"
    
    if params["id"].nil?
      target = "target[#{@shares.length+2}]"
      @share.id = target
      Rails.logger.debug "target #{target.inspect}"
    end
    
    Rails.logger.debug "NEW SHARE #{@share.inspect}"
    
    #if @share.save
#      @shares = Share.all
#      render :partial => 'shares'
#    else 
#      render :error
#    end
    
    if @share.save
      @shares = Share.all
 
      render :update do |page|
        page.replace_html 'all-container', :partial => 'shares'
        page.replace_html 'new-container', :partial => 'new'
      end
    else 
      render :error
    end

  end

  def update
    @share = Share.new(params[:share])

    if @share.save
      @share = Share.find(params[:share][:id])
      render :partial => 'share', :locals => {:name => @name}
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
    
    #if @share.destroy
    #  @shares = Share.all
    #  render :partial => 'shares'
    #else 
    #  render :error
    #end
    
#    <%= remote_function (:url =>{ :action => "codeviewer", :id => @assignment.id, :uid => @uid },
#                   :with => "'fid='+fid", :after => "$('working').hide();")%>

  
    if @share.destroy
      @shares = Share.all
      
      render :update do |page|
        page.replace_html 'all-container', :partial => 'shares'
        #Also update the annotation_summary_list
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

