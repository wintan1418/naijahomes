class LeadNote < ApplicationRecord
  belongs_to :lead
  belongs_to :user
  
  # Validations
  validates :content, presence: true
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  
  # Methods
  def author_name
    user.full_name
  end
end