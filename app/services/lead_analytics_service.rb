class LeadAnalyticsService
  attr_reader :user, :date_range
  
  def initialize(user, date_range = 1.month.ago..Time.current)
    @user = user
    @date_range = date_range
  end
  
  def dashboard_metrics
    leads_scope = user_leads
    
    {
      overview: overview_metrics(leads_scope),
      pipeline: pipeline_metrics(leads_scope),
      performance: performance_metrics(leads_scope),
      sources: source_analysis(leads_scope),
      trends: trend_analysis,
      hottest_leads: hottest_leads(leads_scope),
      overdue_leads: overdue_leads(leads_scope)
    }
  end
  
  private
  
  def user_leads
    Lead.for_user(user).where(created_at: date_range)
  end
  
  def overview_metrics(leads_scope)
    all_leads = leads_scope
    
    {
      total_leads: all_leads.count,
      new_leads: all_leads.new_leads.count,
      hot_leads: all_leads.hot_leads.count,
      conversion_rate: calculate_conversion_rate(all_leads),
      avg_deal_size: calculate_avg_deal_size(all_leads),
      total_pipeline_value: calculate_pipeline_value(all_leads)
    }
  end
  
  def pipeline_metrics(leads_scope)
    Lead.statuses.map do |status, value|
      leads = leads_scope.where(status: status)
      {
        status: status.humanize,
        count: leads.count,
        percentage: leads_scope.count > 0 ? (leads.count.to_f / leads_scope.count * 100).round(1) : 0,
        total_value: leads.sum(&:estimated_value),
        avg_time_in_status: calculate_avg_time_in_status(leads, status)
      }
    end
  end
  
  def performance_metrics(leads_scope)
    {
      avg_response_time: calculate_avg_response_time(leads_scope),
      avg_conversion_time: calculate_avg_conversion_time(leads_scope),
      leads_this_week: leads_scope.this_week.count,
      leads_this_month: leads_scope.this_month.count,
      won_deals: leads_scope.where(status: :closed_won).count,
      lost_deals: leads_scope.where(status: :closed_lost).count
    }
  end
  
  def source_analysis(leads_scope)
    leads_scope.group(:lead_source).count.map do |source, count|
      source_leads = leads_scope.where(lead_source: source)
      {
        source: source&.humanize || 'Unknown',
        count: count,
        conversion_rate: calculate_conversion_rate(source_leads),
        avg_value: source_leads.average(:budget)&.to_f&.round(2) || 0
      }
    end.sort_by { |s| s[:count] }.reverse
  end
  
  def trend_analysis
    # Weekly trend for the last 12 weeks
    weeks = 12.downto(0).map do |weeks_ago|
      start_date = weeks_ago.weeks.ago.beginning_of_week
      end_date = weeks_ago.weeks.ago.end_of_week
      
      week_leads = Lead.for_user(user).where(created_at: start_date..end_date)
      
      {
        week: start_date.strftime('%b %d'),
        leads: week_leads.count,
        conversions: week_leads.where(status: :closed_won).count,
        pipeline_value: week_leads.sum(&:estimated_value)
      }
    end
    
    weeks
  end
  
  def hottest_leads(leads_scope)
    leads_scope
      .where.not(status: [:closed_won, :closed_lost])
      .includes(:property, :lead_notes)
      .order(priority: :desc, created_at: :desc)
      .limit(10)
      .map do |lead|
        {
          id: lead.id,
          name: lead.name,
          property_title: lead.property.title,
          status: lead.status.humanize,
          priority: lead.priority.humanize,
          conversion_probability: lead.conversion_probability,
          estimated_value: lead.estimated_value,
          days_old: lead.days_old,
          next_action: lead.next_action,
          overdue: lead.overdue?
        }
      end
  end
  
  def overdue_leads(leads_scope)
    leads_scope
      .overdue
      .includes(:property)
      .limit(10)
      .map do |lead|
        {
          id: lead.id,
          name: lead.name,
          property_title: lead.property.title,
          status: lead.status.humanize,
          follow_up_at: lead.follow_up_at,
          days_overdue: (Time.current.to_date - lead.follow_up_at.to_date).to_i
        }
      end
  end
  
  def calculate_conversion_rate(leads_scope)
    return 0 if leads_scope.count == 0
    
    converted = leads_scope.where(status: :closed_won).count
    (converted.to_f / leads_scope.count * 100).round(1)
  end
  
  def calculate_avg_deal_size(leads_scope)
    won_leads = leads_scope.where(status: :closed_won)
    return 0 if won_leads.count == 0
    
    won_leads.average(:budget)&.to_f&.round(2) || 0
  end
  
  def calculate_pipeline_value(leads_scope)
    leads_scope
      .where.not(status: [:closed_won, :closed_lost])
      .sum(&:estimated_value)
  end
  
  def calculate_avg_time_in_status(leads_scope, status)
    return 0 if leads_scope.count == 0
    
    # Calculate average time leads spend in this status
    total_time = leads_scope.sum do |lead|
      if lead.status == status
        lead.time_in_current_status
      else
        # For historical leads, estimate based on activities
        lead.days_in_pipeline / Lead.statuses.count
      end
    end
    
    (total_time.to_f / leads_scope.count).round(1)
  end
  
  def calculate_avg_response_time(leads_scope)
    # Average time to first contact
    response_times = leads_scope.joins(:lead_activities)
                               .where(lead_activities: { activity_type: :status_change })
                               .where("lead_activities.details->>'to_status' = 'contacted'")
                               .group('leads.id')
                               .minimum('lead_activities.created_at - leads.created_at')
    
    return 0 if response_times.empty?
    
    avg_seconds = response_times.values.sum / response_times.count
    (avg_seconds / 1.hour).round(1) # Return in hours
  end
  
  def calculate_avg_conversion_time(leads_scope)
    # Average time from lead to closed won
    won_leads = leads_scope.where(status: :closed_won)
    return 0 if won_leads.count == 0
    
    total_days = won_leads.sum(&:days_in_pipeline)
    (total_days.to_f / won_leads.count).round(1)
  end
end