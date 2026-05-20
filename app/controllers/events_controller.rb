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
    @event.save
    if !@event.id.nil?
      relevant_notifications = Notification.where(performer_id: @event.performer.id)
      if relevant_notifications.nil?
        logger.debug "No notifications were found with this performer"
      else
        relevant_notifications.each do
          |n| RoutingRequestService.call(@event.location, n.location, n.distance, n.fan_id, @event.performer.id)
        end
      end
    end
    redirect_to performer_events_path
  end

  private
  # Private method to define which parameters are permitted, this is mandatory.
  def event_params
    params.expect(event: [ :event_date, :location, :performer_id ])
  end
end
