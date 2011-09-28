
require "pty"
require "expect"
require "stringio"
require "pty"
require 'popen4'

class TerminalController < ApplicationController

  def index
  end

  def exec
   # Rails.logger.error "#{params.inspect}"
   # output = `LANG=POSIX #{params["cmd"]} 2>&1`
   render :text => "\033[0;31m""$@""\033[0m"





  end
end

