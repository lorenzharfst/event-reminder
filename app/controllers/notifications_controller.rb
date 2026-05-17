class NotificationsController < ApplicationController
  def create
    @notification = Notification.new(params[:notification])
    @notification.fan = current_user.fan
    @notification.performer = Performer.find_by(params[:performer_id])
    @notification.save
    # TODO: Decide whether we just put a notification or redirect the fan to their list of notifications
  end
  private
  def notification_params
    params.expect({ notification: [ :distance ], performer_id: string })
  end
end
