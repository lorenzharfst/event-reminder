class PerformersController < ApplicationController
  def index
    logger.debug "Checking for performer with id #{params[:performer_id]}"
    @performer = Performer.find_by(id: params[:performer_id])
  end
end
