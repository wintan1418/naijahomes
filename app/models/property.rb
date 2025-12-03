class Property < ApplicationRecord
  belongs_to :user
  
  # Associations
  has_many_attached :images
  has_many :leads, dependent: :destroy
  has_many :favourites, dependent: :destroy
  has_many :favourited_by_users, through: :favourites, source: :user
  
  # Enums
  enum :payment_frequency, { monthly: 0, yearly: 1, negotiable: 2 }, default: :monthly
  enum :property_type, { 
    self_contain: 0, 
    one_bedroom: 1, 
    two_bedroom: 2, 
    three_bedroom: 3, 
    duplex: 4, 
    flat: 5, 
    shop: 6, 
    office: 7 
  }
  enum :status, { available: 0, rented: 1, inactive: 2 }, default: :available
  
  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :payment_frequency, presence: true
  validates :property_type, presence: true
  validates :bedrooms, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :bathrooms, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :toilets, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :state, presence: true
  validates :city, presence: true
  validates :address, presence: true
  validates :status, presence: true
  validate :image_type
  validate :image_size
  
  # Scopes
  scope :active, -> { where(status: [:available, :rented]) }
  scope :available_only, -> { where(status: :available) }
  scope :featured_first, -> { order(featured: :desc, created_at: :desc) }
  scope :by_state, ->(state) { where(state: state) if state.present? }
  scope :by_city, ->(city) { where("LOWER(city) LIKE ?", "%#{city.downcase}%") if city.present? }
  scope :by_property_type, ->(type) { where(property_type: type) if type.present? }
  scope :price_between, ->(min, max) { where(price: min..max) if min.present? && max.present? }
  scope :by_bedrooms, ->(count) { where(bedrooms: count) if count.present? }
  
  # Nigerian States
  NIGERIAN_STATES = [
    "Abia", "Adamawa", "Akwa Ibom", "Anambra", "Bauchi", "Bayelsa", "Benue", "Borno", 
    "Cross River", "Delta", "Ebonyi", "Edo", "Ekiti", "Enugu", "FCT", "Gombe", 
    "Imo", "Jigawa", "Kaduna", "Kano", "Katsina", "Kebbi", "Kogi", "Kwara", 
    "Lagos", "Nasarawa", "Niger", "Ogun", "Ondo", "Osun", "Oyo", "Plateau", 
    "Rivers", "Sokoto", "Taraba", "Yobe", "Zamfara"
  ].freeze
  
  # Methods
  def price_display
    "₦#{price.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, '\\1,')}"
  end
  
  def payment_text
    case payment_frequency
    when "monthly"
      "per month"
    when "yearly"
      "per year"
    else
      "(negotiable)"
    end
  end
  
  def full_price_text
    "#{price_display} #{payment_text}"
  end
  
  def location_text
    "#{city}, #{state}"
  end
  
  def bedroom_text
    return property_type.humanize if property_type.in?(['self_contain', 'shop', 'office'])
    "#{bedrooms} Bedroom#{bedrooms != 1 ? 's' : ''}"
  end
  
  private
  
  def image_type
    return unless images.attached?
    
    images.each do |image|
      unless image.content_type.in?(%w[image/jpeg image/jpg image/png image/webp])
        errors.add(:images, 'must be a JPEG, PNG, or WebP file')
      end
    end
  end
  
  def image_size
    return unless images.attached?
    
    images.each do |image|
      if image.byte_size > 5.megabytes
        errors.add(:images, 'size should be less than 5MB')
      end
    end
  end
end