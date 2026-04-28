class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @performer_id = current_user.performer.id
    logger.debug "Loading homepage for performer id: #{@performer_id}"
    redirect_to performer_path(current_user.performer)
  end
end
