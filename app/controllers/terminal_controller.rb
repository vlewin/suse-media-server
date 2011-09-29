class TerminalController < ApplicationController
  def index
  end

  def settings
    render :partial => 'settings'
  end
end

