require 'etc'

class PlaygroundController < ApplicationController
  USER = Etc.getlogin

  def index
    Rails.logger.debug "*** Render INDEX ***\n"
  end

  def new
    render :partial => 'new'
  end

  def remove
    Rails.logger.error "*** Render DELETE ***"
    render :partial => 'remove'
  end

  def settings
    Rails.logger.error "*** Render SETTINGS ***"
    render :partial => 'settings'
  end


  def getContent
    @parent = "/home/#{USER}" unless params['dir']
    @dir = Filetree.new(@parent).get_content
    render :partial => 'folders'
  end
end

