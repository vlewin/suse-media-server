class DlnaController < ApplicationController
  def index
    @dlna = Dlna.all
    Rails.logger.debug "\n*** CONFIG #{@dlna.inspect}"
  end
end
