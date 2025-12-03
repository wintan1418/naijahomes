class Lead < ApplicationRecord
  belongs_to :property
  belongs_to :assigned_to, class_name: 'User', optional: true
  has_many :lead_notes, dependent: :destroy
  
  # Enums
  enum :status, { 
    new_lead: 0, 
    contacted: 1, 
    viewing_scheduled: 2, 
    offer_made: 3, 
    closed_won: 4, 
    closed_lost: 5 
  }, default: :new_lead
  
  # Validations
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :message, presence: true
  validates :source, presence: true
  validates :status, presence: true
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :needs_follow_up, -> { where('follow_up_at <= ?', Time.current).where.not(status: [:closed_won, :closed_lost]) }
  scope :for_user, ->(user) { joins(:property).where(property: { user_id: user.id }) }
  
  # Callbacks
  after_create :assign_to_property_owner
  
  # Methods
  def status_color
    case status
    when 'new_lead' then 'blue'
    when 'contacted' then 'yellow'
    when 'viewing_scheduled' then 'purple'
    when 'offer_made' then 'orange'
    when 'closed_won' then 'green'
    when 'closed_lost' then 'red'
    end
  end
  
  def days_old
    ((Time.current - created_at) / 1.day).round
  end
  
  private
  
  def assign_to_property_owner
    self.assigned_to ||= property.user
    save if persisted?
  end
end