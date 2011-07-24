require 'etc'


class PlaygroundController < ApplicationController
  USER = Etc.getlogin

  def index
    Rails.logger.debug "*** Render INDEX ***\n"
  end

  def new
    @parent = "/home/#{USER}"
    @dir = Filetree.new(@parent).get_content

    Rails.logger.error "*** Render NEW ***"
    Rails.logger.error "*** DIR #{@dir.inspect} ***"

    render :partial => 'new'
  end

  def remove
    Rails.logger.error "*** Render REMOVE ***"
    render :partial => 'destroy'
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

  def destroy
    #Rails.logger.error "*** Render NEW ***"
    #render :partial => 'new'
  end
end

