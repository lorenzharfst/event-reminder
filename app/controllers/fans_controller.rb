class FansController < ApplicationController
  def create
    @fan = Fan.new(params[:fan])
  end
end
