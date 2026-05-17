class NotificationsController < ApplicationController
  def create
  end
  private
  def notification_params
    params.expect(notification: [ :performer_id, :distance ])
  end
end
