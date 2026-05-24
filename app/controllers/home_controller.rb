class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    if current_user.performer.present?
      @performer_id = current_user.performer.id
    else
      current_user.performer = Performer.new
      current_user.save
      @performer_id = current_user.performer.id
    end
    logger.debug "Loading homepage for performer id: #{@performer_id}"
    redirect_to performer_events_path(current_user.performer)
  end
end
