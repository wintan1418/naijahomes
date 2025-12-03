class Landlord::LeadsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_landlord_or_agent
  before_action :set_lead, only: [:show, :edit, :update, :destroy, :advance_status, :mark_as_lost]
  
  def index
    @leads = filtered_leads.includes(:property, :lead_notes, :lead_activities)
                          .order(sort_column => sort_direction)
                          .limit(50)
    
    @analytics = LeadAnalyticsService.new(current_user, filter_date_range).dashboard_metrics
    
    respond_to do |format|
      format.html
      format.json { render json: { leads: @leads, analytics: @analytics } }
    end
  end
  
  def show
    @lead_notes = @lead.lead_notes.recent.includes(:user)
    @lead_activities = @lead.lead_activities.recent.includes(:user)
    @new_note = @lead.lead_notes.build
  end
  
  def advance_status
    begin
      @lead.advance_status!
      
      @lead.lead_activities.create!(
        user: current_user,
        activity_type: :status_change,
        description: "Status advanced to #{@lead.status.humanize}",
        details: { advanced_by: current_user.id }
      )
      
      render json: { 
        status: 'success', 
        new_status: @lead.status.humanize,
        next_action: @lead.next_action,
        conversion_probability: @lead.conversion_probability
      }
    rescue ActiveRecord::RecordInvalid => e
      render json: { status: 'error', message: e.message }, status: :unprocessable_entity
    end
  end
  
  def mark_as_lost
    reason = params[:reason] || 'No reason provided'
    
    @lead.mark_as_lost!(reason)
    
    @lead.lead_activities.create!(
      user: current_user,
      activity_type: :status_change,
      description: "Lead marked as lost: #{reason}",
      details: { lost_reason: reason, marked_by: current_user.id }
    )
    
    render json: { status: 'success', message: 'Lead marked as lost' }
  end
  
  def analytics
    date_range = filter_date_range
    @analytics = LeadAnalyticsService.new(current_user, date_range).dashboard_metrics
    
    respond_to do |format|
      format.html
      format.json { render json: @analytics }
    end
  end
  
  private
  
  def set_lead
    @lead = Lead.for_user(current_user).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to landlord_leads_path, alert: 'Lead not found.'
  end
  
  def filtered_leads
    leads = Lead.for_user(current_user)
    
    leads = leads.by_status(params[:status]) if params[:status].present?
    leads = leads.by_priority(params[:priority]) if params[:priority].present?
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      leads = leads.joins(:property)
                   .where("leads.name ILIKE ? OR leads.email ILIKE ? OR properties.title ILIKE ?", 
                          search_term, search_term, search_term)
    end
    
    leads = leads.overdue if params[:overdue] == 'true'
    leads = leads.hot_leads if params[:hot] == 'true'
    
    leads
  end
  
  def filter_date_range
    case params[:date_range]
    when 'this_week' then 1.week.ago..Time.current
    when 'this_month' then 1.month.ago..Time.current
    when 'last_month' then 2.months.ago..1.month.ago
    when 'last_3_months' then 3.months.ago..Time.current
    else 1.month.ago..Time.current
    end
  end
  
  def lead_params
    params.require(:lead).permit(
      :name, :email, :phone, :message, :status, :priority, 
      :budget, :follow_up_at, :lost_reason, :source, :lead_source
    )
  end
  
  def sort_column
    %w[name created_at status priority follow_up_at].include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end
  
  def ensure_landlord_or_agent
    unless current_user.can_manage_properties?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end