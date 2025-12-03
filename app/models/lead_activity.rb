class LeadActivity < ApplicationRecord
  belongs_to :lead
  belongs_to :user, optional: true
  
  # Enums
  enum :activity_type, {
    status_change: 0,
    note_added: 1,
    email_sent: 2,
    call_made: 3,
    meeting_scheduled: 4,
    viewing_conducted: 5,
    offer_received: 6,
    offer_sent: 7,
    follow_up: 8,
    other: 9
  }
  
  # Validations
  validates :activity_type, presence: true
  validates :description, presence: true
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_lead, ->(lead_id) { where(lead_id: lead_id) }
  scope :by_type, ->(type) { where(activity_type: type) if type.present? }
  scope :this_week, -> { where(created_at: 1.week.ago..Time.current) }
  scope :this_month, -> { where(created_at: 1.month.ago..Time.current) }
  
  # Methods
  def activity_icon
    case activity_type
    when 'status_change' then 'refresh'
    when 'note_added' then 'document-text'
    when 'email_sent' then 'mail'
    when 'call_made' then 'phone'
    when 'meeting_scheduled' then 'calendar'
    when 'viewing_conducted' then 'eye'
    when 'offer_received' then 'arrow-down'
    when 'offer_sent' then 'arrow-up'
    when 'follow_up' then 'clock'
    when 'other' then 'dots-horizontal'
    end
  end
  
  def activity_color
    case activity_type
    when 'status_change' then 'blue'
    when 'note_added' then 'gray'
    when 'email_sent' then 'green'
    when 'call_made' then 'purple'
    when 'meeting_scheduled' then 'yellow'
    when 'viewing_conducted' then 'indigo'
    when 'offer_received' then 'emerald'
    when 'offer_sent' then 'orange'
    when 'follow_up' then 'red'
    when 'other' then 'gray'
    end
  end
  
  def formatted_details
    return {} unless details.present?
    
    case details
    when String
      begin
        JSON.parse(details)
      rescue JSON::ParserError
        { raw: details }
      end
    when Hash
      details
    else
      { raw: details.to_s }
    end
  end
end