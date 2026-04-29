class PerformersController < ApplicationController
  before_action :authenticate_user!
  def show
    logger.debug "Checking for performer with id #{params[:id]}"
    @performer = Performer.find_by(id: params[:id])
  end
  def update
    @performer = Performer.find_by(id: params[:id])
    logger.debug "Setting name: #{params[:performer][:name]} for #{@performer.id}"
    @performer.name = params[:performer][:name]
    @performer.save
    redirect_to performer_path
  end
end
