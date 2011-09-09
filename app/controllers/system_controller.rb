class SystemController < ApplicationController
  def reboot
    Rails.logger.error "REBOOT"
    render :nothing => true
  end
end
