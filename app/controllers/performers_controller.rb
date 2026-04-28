class PerformersController < ApplicationController
  def index
    logger.debug "Checking for performer with id #{params[:performer_id]}"
    @performer = Performer.find_by(id: params[:performer_id])
  end
  def name
    logger.debug "Setting name #{params[:performer_name]} for performer id #{params[:performer_id]}"
    @user = User.find_by(id: current_user.id)
    @user.performer.name = params[:performer_name]
    @user.performer.save
  end
end
