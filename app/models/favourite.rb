class Favourite < ApplicationRecord
  belongs_to :user
  belongs_to :property
  
  # Validations
  validates :user_id, uniqueness: { scope: :property_id }
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
end