class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @performer_id = current_user.performer.id
    logger.debug "Loading placeholder homepage for performer id: #{@performer_id}"
  end
end
