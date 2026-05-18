class EventsController < ApplicationController
  def index
    logger.debug "Checking for performer with id #{params[:performer_id]}"
    @performer = Performer.find_by(id: params[:performer_id])
    @event = Event.new
    @event.performer = @performer
    @event_list = @performer.events
  end

  def create
    @event = Event.new(event_params)
    @event_performer = Performer.find_by(id: params[:performer_id])
    @event.performer = @event_performer
    logger.debug "Creating new event: performer_id: #{@event.performer.id}, location: #{@event.location}, date: #{@event.event_date}"
    # @event.performer = current_user.performer
    @event.save
    redirect_to performer_events_path
  end

  private
  # Private method to define which parameters are permitted, this is mandatory.
  def event_params
    params.expect(event: [ :event_date, :location, :performer_id ])
  end
end
