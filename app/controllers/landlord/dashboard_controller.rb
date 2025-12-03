class Landlord::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_landlord_or_agent
  
  def index
    @total_properties = current_user.properties.count
    @available_properties = current_user.properties.available_only.count
    @rented_properties = current_user.properties.rented_only.count
    
    @recent_leads = current_user.leads.recent.limit(5).includes(:property)
    @total_leads = current_user.leads.count
    @new_leads = current_user.leads.new_leads.count
    
    @recent_properties = current_user.properties.includes(:images_attachments).recent.limit(6)
    
    # Monthly leads chart data
    @monthly_leads_data = current_user.leads
                                     .group_by_month(:created_at, last: 6)
                                     .count
    
    # Properties by status
    @properties_by_status = current_user.properties.group(:status).count
  end
  
  private
  
  def ensure_landlord_or_agent
    unless current_user.landlord_or_agent? || current_user.admin?
      redirect_to root_path, alert: 'You are not authorized to access this page.'
    end
  end
end