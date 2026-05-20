class NotificationsController < ApplicationController
  def create
    logger.debug "Creating a new notification with location: #{notification_params[:location]}, distance: #{notification_params[:distance]}, performer_id: #{notification_params[:performer_id]}"
    performer = Performer.find_by(id: notification_params[:performer_id])
    @notification = Notification.find_or_initialize_by(fan: current_user.fan, performer: performer)
    @notification.assign_attributes(notification_params.except(:performer_id))
    @notification.save!
    logger.debug "Saved notification with id: #{@notification.id}"
    # TODO: Decide whether we just put a notification or redirect the fan to their list of notifications
  end
  private
  def notification_params
    params.expect(notification: [ :distance, :location, :performer_id ])
  end
end
