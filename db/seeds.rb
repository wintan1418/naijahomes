# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample users
tenant = User.find_or_create_by!(email: 'tenant@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'John'
  u.last_name = 'Doe'
  u.phone_number = '08012345678'
  u.role = 'tenant'
end

landlord = User.find_or_create_by!(email: 'landlord@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'Sarah'
  u.last_name = 'Johnson'
  u.phone_number = '08023456789'
  u.role = 'landlord'
end

agent = User.find_or_create_by!(email: 'agent@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'Mike'
  u.last_name = 'Williams'
  u.phone_number = '08034567890'
  u.role = 'agent'
  u.company_name = 'Premium Properties Ltd'
  u.whatsapp_number = '08034567890'
end

admin = User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.password = 'password123'
  u.first_name = 'Admin'
  u.last_name = 'User'
  u.phone_number = '08045678901'
  u.role = 'admin'
end

puts "Created #{User.count} users"

# Create sample properties
property_data = [
  {
    user: landlord,
    title: "Luxury 3 Bedroom Flat in Victoria Island",
    description: "Beautiful 3 bedroom flat with modern amenities, 24/7 power supply, swimming pool, gym, and security. Close to shopping malls and restaurants.",
    price: 3500000,
    payment_frequency: 'yearly',
    property_type: 'three_bedroom',
    bedrooms: 3,
    bathrooms: 3,
    toilets: 4,
    state: 'Lagos',
    city: 'Victoria Island',
    lga: 'Eti-Osa',
    address: '123 Adeola Odeku Street',
    status: 'available',
    featured: true
  },
  {
    user: landlord,
    title: "Cozy Self Contain in Yaba",
    description: "Affordable self-contained apartment perfect for students and young professionals. Steady electricity, water, and good security.",
    price: 250000,
    payment_frequency: 'yearly',
    property_type: 'self_contain',
    bedrooms: 0,
    bathrooms: 1,
    toilets: 1,
    state: 'Lagos',
    city: 'Yaba',
    lga: 'Mainland',
    address: '45 Herbert Macaulay Way',
    status: 'available'
  },
  {
    user: agent,
    title: "Modern 2 Bedroom Apartment in Lekki Phase 1",
    description: "Newly built 2 bedroom apartment with excellent finishing. Serviced apartment with 24hrs power, cleaning service, and security.",
    price: 200000,
    payment_frequency: 'monthly',
    property_type: 'two_bedroom',
    bedrooms: 2,
    bathrooms: 2,
    toilets: 2,
    state: 'Lagos',
    city: 'Lekki',
    lga: 'Eti-Osa',
    address: '78 Admiralty Way',
    status: 'available',
    featured: true
  },
  {
    user: agent,
    title: "Spacious Office Space in Abuja CBD",
    description: "Prime office space in the heart of Abuja's Central Business District. Open floor plan, conference room, and parking space for 10 cars.",
    price: 5000000,
    payment_frequency: 'yearly',
    property_type: 'office',
    state: 'FCT',
    city: 'Abuja',
    lga: 'Central Business District',
    address: '12 Aminu Kano Crescent, Wuse 2',
    status: 'available'
  },
  {
    user: landlord,
    title: "4 Bedroom Duplex in Gwarinpa",
    description: "Tastefully finished 4 bedroom duplex with BQ, large compound, and modern facilities. Located in a serene environment.",
    price: 3000000,
    payment_frequency: 'yearly',
    property_type: 'duplex',
    bedrooms: 4,
    bathrooms: 5,
    toilets: 6,
    state: 'FCT',
    city: 'Abuja',
    lga: 'Gwarinpa',
    address: '34 6th Avenue, Gwarinpa Estate',
    status: 'available'
  },
  {
    user: agent,
    title: "Shop Space at Ikeja Computer Village",
    description: "Strategic shop space in the busy Computer Village market. High foot traffic, perfect for electronics or computer business.",
    price: 1200000,
    payment_frequency: 'yearly',
    property_type: 'shop',
    state: 'Lagos',
    city: 'Ikeja',
    lga: 'Ikeja',
    address: 'Otigba Street, Computer Village',
    status: 'available'
  }
]

property_data.each do |data|
  property = Property.find_or_create_by!(
    title: data[:title],
    user: data[:user]
  ) do |p|
    p.attributes = data
  end
  
  # Create some sample leads for properties
  if rand(1..3) == 1
    lead = Lead.create!(
      property: property,
      name: "Interested Tenant #{property.id}",
      email: "tenant#{property.id}@example.com",
      phone: "080#{rand(10000000..99999999)}",
      message: "I am interested in this property. When can I schedule a viewing?",
      source: 'web_form',
      status: ['new_lead', 'contacted', 'viewing_scheduled'].sample
    )
    
    LeadNote.create!(
      lead: lead,
      user: property.user,
      content: "Initial contact made via platform"
    )
  end
end

puts "Created #{Property.count} properties"
puts "Created #{Lead.count} leads"
puts "Created #{LeadNote.count} lead notes"

puts "\nSample user credentials:"
puts "Tenant: tenant@example.com / password123"
puts "Landlord: landlord@example.com / password123"
puts "Agent: agent@example.com / password123"
puts "Admin: admin@example.com / password123"