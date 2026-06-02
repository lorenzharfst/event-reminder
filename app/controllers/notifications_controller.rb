class NotificationsController < ApplicationController
  before_action :authenticate_user!, except: [ :unsubscribe ]
  before_action :set_notification, only: [ :edit, :update, :destroy ]

  def index
    @notifications = current_user.fan.notifications.includes(:performer)
  end

  def edit
  end

  def update
    if @notification.update(notification_update_params)
      redirect_to notifications_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path
  end

  def unsubscribe
    notification = Notification.find_signed(params[:token], purpose: :unsubscribe)
    if notification
      notification.destroy
      redirect_to root_path, notice: t("notifications.unsubscribed")
    else
      redirect_to root_path, alert: t("notifications.unsubscribe_invalid")
    end
  end

  def create
    logger.debug "Creating a new notification with location: #{notification_params[:location]}, distance: #{notification_params[:distance]}, performer_id: #{notification_params[:performer_id]}"
    performer = Performer.find_by(id: notification_params[:performer_id])
    @notification = Notification.find_or_initialize_by(fan: current_user.fan, performer: performer)
    @notification.assign_attributes(notification_params.except(:performer_id))
    @notification.save!
    logger.debug "Saved notification with id: #{@notification.id}"

    future_events = performer.events.where("event_date >= ?", Date.current)
    future_events.each do |event|
      RoutingRequestService.call(event.location, @notification.location, @notification.distance, @notification.fan.id, performer.id, event.id)
    end
    # TODO: Decide whether we just put a notification or redirect the fan to their list of notifications
  end
  private

  def set_notification
    @notification = current_user.fan.notifications.find(params[:id])
  end

  def notification_params
    params.expect(notification: [ :distance, :location, :performer_id ])
  end

  def notification_update_params
    params.expect(notification: [ :distance, :location ])
  end
end
