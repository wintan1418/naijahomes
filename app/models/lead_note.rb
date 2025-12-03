class LeadNote < ApplicationRecord
  belongs_to :lead
  belongs_to :user
  
  # Enums
  enum :note_type, {
    general: 0,
    follow_up: 1,
    call_note: 2,
    meeting_note: 3,
    email_note: 4,
    internal: 5
  }, default: :general
  
  # Validations
  validates :content, presence: true, length: { minimum: 5, maximum: 2000 }
  validates :note_type, presence: true
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(note_type: type) if type.present? }
  scope :for_lead, ->(lead_id) { where(lead_id: lead_id) }
  scope :this_week, -> { where(created_at: 1.week.ago..Time.current) }
  scope :this_month, -> { where(created_at: 1.month.ago..Time.current) }
  
  # Callbacks
  after_create :log_activity
  
  # Methods
  def author_name
    user.name
  end
  
  def note_type_color
    case note_type
    when 'general' then 'gray'
    when 'follow_up' then 'yellow'
    when 'call_note' then 'blue'
    when 'meeting_note' then 'purple'
    when 'email_note' then 'green'
    when 'internal' then 'red'
    end
  end
  
  def note_type_icon
    case note_type
    when 'general' then 'document-text'
    when 'follow_up' then 'clock'
    when 'call_note' then 'phone'
    when 'meeting_note' then 'calendar'
    when 'email_note' then 'mail'
    when 'internal' then 'lock-closed'
    end
  end
  
  def truncated_content(limit = 100)
    content.length > limit ? "#{content[0...limit]}..." : content
  end
  
  private
  
  def log_activity
    lead.lead_activities.create!(
      user: user,
      activity_type: :note_added,
      description: "Added #{note_type.humanize.downcase} note",
      details: {
        note_id: id,
        note_type: note_type,
        content_preview: truncated_content(50)
      }
    )
  end
end