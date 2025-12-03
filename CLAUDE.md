# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Git Commit Guidelines

When making commits:
- Use conventional commit format (feat:, fix:, docs:, etc.)
- Keep commit messages concise and descriptive
- Do NOT include co-author tags or Claude attribution in commits

## Project Overview

**NaijaRent** - A Nigerian rental property platform with integrated CRM capabilities built with Rails 7.2.2, PostgreSQL, and Hotwire.

### Core Purpose
- Property listing and search platform focused on the Nigerian market
- Lead management CRM for landlords/agents
- Map-based property discovery
- Multi-role system (tenant, landlord, agent, admin)

## Development Commands

### Docker Setup & Management
```bash
# Initial setup (run once)
bin/docker-setup                 # Complete Docker setup with database

# Docker commands
docker-compose up                # Start all services
docker-compose up -d             # Start in background
docker-compose down              # Stop all services
docker-compose logs -f web       # View Rails logs
docker-compose ps                # Show running containers

# Rails commands in Docker
docker-compose exec web bash     # Access container shell
docker-compose exec web rails console    # Rails console
docker-compose exec web rails db:migrate # Run migrations
docker-compose exec web rails db:seed    # Seed database
docker-compose exec web bundle install   # Install gems
docker-compose exec web yarn install     # Install JS packages

# Asset compilation (development)
docker-compose --profile assets up -d    # Start CSS/JS watchers
```

### Essential Rails Commands (Non-Docker)
```bash
# Database
bin/rails db:create              # Create development and test databases
bin/rails db:migrate             # Run migrations
bin/rails db:seed                # Seed the database
bin/rails db:reset               # Drop, create, migrate, and seed

# Development Server (run all three in separate terminals or use Procfile.dev)
bin/rails server                 # Start Rails server on localhost:3000
yarn build --watch               # Watch and rebuild JavaScript
yarn build:css --watch           # Watch and rebuild CSS with Tailwind

# Or use Procfile.dev with foreman/overmind:
bin/dev                          # Runs all processes together

# Testing
bin/rails test                   # Run all tests
bin/rails test test/models       # Run model tests
bin/rails test test/controllers  # Run controller tests
bin/rails test:system            # Run system tests (browser tests)

# Code Quality
bundle exec rubocop              # Run Rubocop for code style
bundle exec rubocop -A           # Auto-fix Rubocop issues
bundle exec brakeman             # Run security analysis

# Generators
bin/rails generate model ModelName field:type
bin/rails generate controller ControllerName action1 action2
bin/rails generate scaffold ResourceName field:type
bin/rails generate migration AddFieldToTable field:type

# Console
bin/rails console                # Interactive Rails console
bin/rails c                      # Short version

# Routes
bin/rails routes                 # Show all routes
bin/rails routes | grep property # Find specific routes
```

## Architecture & Key Models

### Data Models

#### User Model
```ruby
# Core fields: first_name, last_name, email, phone_number
# role (enum): tenant, landlord, agent, admin
# Additional fields for landlords/agents: company_name, whatsapp_number
```

#### Property Model
```ruby
# Core fields: title, description, price, payment_frequency
# property_type (enum): self_contain, one_bedroom, two_bedroom, three_bedroom, duplex, flat, shop, office
# Location: state, city, lga, address, latitude, longitude
# Status (enum): available, rented, inactive
# Associations: belongs_to :user, has_many_attached :images
```

#### Lead Model (CRM Core)
```ruby
# Contact info: name, email, phone, message
# status (enum): new_lead, contacted, viewing_scheduled, offer_made, closed_won, closed_lost
# follow_up_at (datetime)
# Associations: belongs_to :property, belongs_to :assigned_to (User)
```

#### LeadNote Model
```ruby
# Timeline entries for leads
# content (text), timestamps
# Associations: belongs_to :lead, belongs_to :user
```

### Key Architectural Decisions

1. **Authentication**: Use Devise gem for user authentication
2. **Authorization**: Use Pundit or CanCanCan for role-based access
3. **File Storage**: Rails Active Storage for property images
4. **Frontend**: Server-side rendering with Hotwire (Turbo + Stimulus)
5. **Styling**: Tailwind CSS v4 with custom Nigerian market-friendly design
6. **Maps**: Mapbox or Leaflet + OpenStreetMap for property locations
7. **Search**: PostgreSQL full-text search with location-based filtering

## Nigerian Market Specifics

### States List
The platform should include all 36 Nigerian states + FCT (Federal Capital Territory).

### Property Types
- Self Contain (Studio)
- 1 Bedroom, 2 Bedroom, 3 Bedroom apartments
- Duplex
- Flat
- Shop
- Office

### Payment Frequencies
- Monthly
- Yearly
- Negotiable (common in Nigerian market)

### Contact Methods
- Phone numbers (Nigerian format: +234)
- WhatsApp integration (very popular in Nigeria)
- Email

## Development Phases

### Phase 1 (Current) - Core Platform
- User authentication with roles
- Property CRUD for landlords/agents
- Basic property search with filters
- Property detail pages with contact forms
- Lead creation from contact forms

### Phase 2 - CRM Enhancement
- Full lead pipeline management
- Lead notes and status tracking
- Landlord dashboard with KPIs
- Tenant favorites functionality

### Phase 3 - Map Integration
- Interactive map with property pins
- Location-based search
- Geocoding for addresses

### Phase 4 - Advanced Features
- Email/SMS notifications
- Payment integration (Paystack/Flutterwave)
- Property verification system

## Testing Guidelines

```bash
# Model tests - test validations, associations, methods
bin/rails test test/models/property_test.rb

# Controller tests - test permissions, responses
bin/rails test test/controllers/properties_controller_test.rb  

# System tests - full user workflows
bin/rails test test/system/property_management_test.rb

# Run specific test
bin/rails test test/models/property_test.rb:42
```

## Security Considerations

1. **Authentication**: All user actions require authentication except property browsing
2. **Authorization**: 
   - Only property owners can edit/delete their listings
   - Only assigned agents see their leads
   - Admins have full access
3. **File Uploads**: Restrict to images only (jpg, png, webp) with size limits
4. **API Security**: Rate limiting on contact forms to prevent spam

## Performance Optimizations

### Database Indexes
```ruby
# Critical indexes to add:
add_index :properties, :state
add_index :properties, :status
add_index :properties, [:latitude, :longitude]
add_index :properties, :user_id
add_index :properties, :price
add_index :leads, :property_id
add_index :leads, :assigned_to_id
add_index :leads, :status
```

### Query Optimizations
- Use `includes` to avoid N+1 queries
- Paginate all lists (properties, leads)
- Cache property counts and statistics

## Common Workflows

### Adding a New Property Field
1. Generate migration: `bin/rails g migration AddFieldToProperties field_name:type`
2. Update Property model with validations
3. Add to property form views
4. Update property serializers/API responses
5. Add to search filters if applicable

### Creating a New User Role
1. Add to User model role enum
2. Update Devise registration to handle role
3. Create role-specific dashboards/views
4. Update authorization policies

### Implementing a New Lead Status
1. Add to Lead model status enum
2. Update lead pipeline views
3. Add status change validations
4. Update CRM dashboard statistics

## API Endpoints (for Map Integration)

```ruby
# Properties within map bounds
GET /api/properties/map_search
Params: sw_lat, sw_lng, ne_lat, ne_lng, filters

# Property details (JSON)
GET /api/properties/:id

# Lead creation
POST /api/leads
Body: { property_id, name, email, phone, message }
```

## Environment Variables

```bash
# Required for production
DATABASE_URL
RAILS_MASTER_KEY
MAPBOX_API_KEY (or equivalent map service)

# Optional services
REDIS_URL (for ActionCable/caching)
AWS_ACCESS_KEY_ID (for S3 storage)
AWS_SECRET_ACCESS_KEY
SENDGRID_API_KEY (for emails)
```