class Lead < ApplicationRecord
  belongs_to :property
  belongs_to :assigned_to, class_name: 'User', optional: true
  has_many :lead_notes, dependent: :destroy
  has_many :lead_activities, dependent: :destroy
  
  # Enums
  enum :status, { 
    new_lead: 0, 
    contacted: 1, 
    viewing_scheduled: 2, 
    offer_made: 3, 
    negotiating: 4,
    closed_won: 5, 
    closed_lost: 6 
  }, default: :new_lead
  
  enum :priority, {
    low: 0,
    medium: 1,
    high: 2,
    urgent: 3
  }, default: :medium
  
  enum :lead_source, {
    website: 0,
    social_media: 1,
    referral: 2,
    phone_call: 3,
    email: 4,
    walk_in: 5
  }, default: :website
  
  # Validations
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :message, presence: true
  validates :source, presence: true
  validates :status, presence: true
  validates :budget, numericality: { greater_than: 0 }, allow_blank: true
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :new_leads, -> { where(status: :new_lead) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :needs_follow_up, -> { where('follow_up_at <= ?', Time.current).where.not(status: [:closed_won, :closed_lost]) }
  scope :overdue, -> { where('follow_up_at < ?', Time.current).where.not(status: [:closed_won, :closed_lost]) }
  scope :for_user, ->(user) { joins(:property).where(property: { user_id: user.id }) }
  scope :hot_leads, -> { where(priority: [:high, :urgent]).where.not(status: [:closed_won, :closed_lost]) }
  scope :conversion_ready, -> { where(status: [:viewing_scheduled, :offer_made, :negotiating]) }
  scope :this_week, -> { where(created_at: 1.week.ago..Time.current) }
  scope :this_month, -> { where(created_at: 1.month.ago..Time.current) }
  
  # Callbacks
  after_create :assign_to_property_owner, :log_status_change
  after_update :log_status_change, if: :saved_change_to_status?
  before_save :set_priority_based_on_budget
  
  # Methods
  def status_color
    case status
    when 'new_lead' then 'blue'
    when 'contacted' then 'yellow'
    when 'viewing_scheduled' then 'purple'
    when 'offer_made' then 'orange'
    when 'negotiating' then 'indigo'
    when 'closed_won' then 'green'
    when 'closed_lost' then 'red'
    end
  end
  
  def priority_color
    case priority
    when 'low' then 'gray'
    when 'medium' then 'blue'
    when 'high' then 'orange'
    when 'urgent' then 'red'
    end
  end
  
  def days_old
    ((Time.current - created_at) / 1.day).round
  end
  
  def overdue?
    follow_up_at.present? && follow_up_at < Time.current && ![:closed_won, :closed_lost].include?(status.to_sym)
  end
  
  def next_action
    case status
    when 'new_lead'
      'Contact lead'
    when 'contacted'
      'Schedule viewing'
    when 'viewing_scheduled'
      'Conduct viewing'
    when 'offer_made'
      'Follow up on offer'
    when 'negotiating'
      'Continue negotiation'
    when 'closed_won'
      'Property sold/rented'
    when 'closed_lost'
      'Lead lost'
    end
  end
  
  def conversion_probability
    case status
    when 'new_lead' then 10
    when 'contacted' then 25
    when 'viewing_scheduled' then 50
    when 'offer_made' then 70
    when 'negotiating' then 85
    when 'closed_won' then 100
    when 'closed_lost' then 0
    end
  end
  
  def advance_status!
    case status
    when 'new_lead'
      update!(status: :contacted, follow_up_at: 1.day.from_now)
    when 'contacted'
      update!(status: :viewing_scheduled, follow_up_at: 3.days.from_now)
    when 'viewing_scheduled'
      update!(status: :offer_made, follow_up_at: 1.day.from_now)
    when 'offer_made'
      update!(status: :negotiating, follow_up_at: 1.day.from_now)
    when 'negotiating'
      update!(status: :closed_won, follow_up_at: nil)
    end
  end
  
  def mark_as_lost!(reason = nil)
    update!(
      status: :closed_lost,
      follow_up_at: nil,
      lost_reason: reason
    )
  end
  
  def days_in_pipeline
    ((Time.current - created_at) / 1.day).round
  end
  
  def time_in_current_status
    last_activity = lead_activities.where(activity_type: 'status_change').last
    return days_old unless last_activity
    
    ((Time.current - last_activity.created_at) / 1.day).round
  end
  
  def estimated_value
    return 0 unless budget.present?
    
    # Calculate based on conversion probability and budget
    (budget * (conversion_probability / 100.0)).round
  end
  
  private
  
  def assign_to_property_owner
    self.assigned_to ||= property.user
    save if persisted?
  end
  
  def log_status_change
    return unless status_changed? || new_record?
    
    LeadActivity.create!(
      lead: self,
      user: assigned_to,
      activity_type: 'status_change',
      description: "Status changed to #{status.humanize}",
      details: {
        from_status: status_was,
        to_status: status,
        changed_at: Time.current
      }
    )
  end
  
  def set_priority_based_on_budget
    return unless budget.present?
    
    property_price = property&.price || 0
    
    if budget >= property_price
      self.priority = :high
    elsif budget >= (property_price * 0.8)
      self.priority = :medium
    else
      self.priority = :low
    end
  end
end