class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enums
  enum :role, { tenant: 0, landlord: 1, agent: 2, admin: 3 }, default: :tenant

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :role, presence: true
  validates :company_name, presence: true, if: -> { agent? }
  
  # Associations
  has_many :properties, dependent: :destroy
  has_many :leads, through: :properties
  has_many :assigned_leads, class_name: 'Lead', foreign_key: 'assigned_to_id', dependent: :nullify
  has_many :lead_notes, dependent: :destroy
  has_many :favourites, dependent: :destroy
  has_many :favourited_properties, through: :favourites, source: :property
  
  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def landlord_or_agent?
    landlord? || agent?
  end
  
  def can_manage_properties?
    landlord? || agent? || admin?
  end
end
