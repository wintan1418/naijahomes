class Landlord::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_landlord_or_agent
  
  def index
    @date_range = filter_date_range
    
    begin
      @analytics = LeadAnalyticsService.new(current_user, @date_range).dashboard_metrics
    rescue NameError => e
      # Fallback if service not loaded
      @analytics = {
        overview: {
          total_leads: Lead.for_user(current_user).count,
          new_leads: Lead.for_user(current_user).new_leads.count,
          hot_leads: Lead.for_user(current_user).hot_leads.count,
          conversion_rate: 0,
          total_pipeline_value: 0
        },
        pipeline: []
      }
      Rails.logger.error "LeadAnalyticsService not found: #{e.message}"
    end
    
    # Property metrics
    @total_properties = current_user.properties.count
    @available_properties = current_user.properties.available.count
    @rented_properties = current_user.properties.rented.count
    
    # Recent activity
    @recent_leads = Lead.for_user(current_user)
                       .recent
                       .includes(:property, :lead_notes)
                       .limit(5)
    
    @recent_properties = current_user.properties
                                   .recent
                                   .includes(:images_attachments)
                                   .limit(6)
    
    # Quick stats for compatibility
    @total_leads = Lead.for_user(current_user).count
    @new_leads = Lead.for_user(current_user).new_leads.count
    
    # Properties by status
    @properties_by_status = current_user.properties.group(:status).count
  end
  
  private
  
  def filter_date_range
    case params[:period]
    when 'this_week'
      1.week.ago..Time.current
    when 'this_month'
      1.month.ago..Time.current
    when 'last_month'
      2.months.ago..1.month.ago
    when 'last_3_months'
      3.months.ago..Time.current
    when 'this_year'
      1.year.ago..Time.current
    else
      1.month.ago..Time.current
    end
  end
  
  def ensure_landlord_or_agent
    unless current_user.can_manage_properties?
      redirect_to root_path, alert: 'Access denied. This area is for property managers only.'
    end
  end
end