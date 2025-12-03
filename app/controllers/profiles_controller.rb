class ProfilesController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @user = current_user
    @recent_enquiries = current_user.tenant? ? Lead.where(email: current_user.email).recent.limit(5) : []
    @saved_properties = current_user.favourited_properties.includes(:images_attachments).limit(6)
    @my_properties = current_user.can_manage_properties? ? current_user.properties.recent.limit(6) : []
  end
end