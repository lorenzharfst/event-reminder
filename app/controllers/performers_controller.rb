class PerformersController < ApplicationController
  def index
    logger.debug "Checking for performer with id #{params[:performer_id]}"
    @performer = Performer.find_by(id: params[:performer_id])
  end
  def name
    @performer = Performer.find_by(id: params[:performer_id])
    logger.debug "Setting name: #{params[:performer][:name]} for #{@performer.id}"
    @performer.name = params[:performer][:name]
    @performer.save
    redirect_to performer_path
  end
end
