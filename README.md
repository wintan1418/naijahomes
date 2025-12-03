# NaijaRent - Nigerian Property Rental Platform

A comprehensive property rental platform designed for the Nigerian market, featuring property listings, search functionality, and an integrated CRM for landlords and agents.

## Features

- **Multi-role System**: Support for tenants, landlords, agents, and administrators
- **Property Management**: Full CRUD operations for property listings with image uploads
- **Advanced Search**: Filter properties by location, price, type, and amenities
- **Map Integration**: Interactive map-based property discovery (Phase 3)
- **Lead Management CRM**: Track and manage inquiries from potential tenants
- **Nigerian Market Focus**: Tailored for Nigerian states, cities, and payment patterns

## Tech Stack

- **Backend**: Ruby on Rails 7.2.2
- **Database**: PostgreSQL 16
- **Frontend**: Hotwire (Turbo + Stimulus) with Tailwind CSS v4
- **Caching**: Redis
- **File Storage**: Active Storage (local in dev, cloud in production)
- **Authentication**: Devise
- **Authorization**: Pundit

## Development Setup

### Prerequisites

- Docker and Docker Compose
- Git

### Quick Start with Docker

1. Clone the repository:
```bash
git clone <repository-url>
cd naija_rentals
```

2. Run the setup script:
```bash
bin/docker-setup
```

This will:
- Build Docker images
- Create and setup the database
- Install dependencies
- Start all services

3. Access the application:
- Rails app: http://localhost:3000
- PostgreSQL: localhost:5432
- Redis: localhost:6379

### Docker Commands

```bash
# Start all services
docker-compose up

# Stop all services
docker-compose down

# View logs
docker-compose logs -f web

# Access Rails console
docker-compose exec web rails console

# Run migrations
docker-compose exec web rails db:migrate

# Run tests
docker-compose exec web rails test
```

### Manual Setup (Without Docker)

1. Install dependencies:
   - Ruby 3.3.5
   - PostgreSQL 16+
   - Redis
   - Node.js 20+
   - Yarn

2. Install gems and packages:
```bash
bundle install
yarn install
```

3. Setup database:
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

4. Start the servers:
```bash
# In separate terminals:
bin/rails server
yarn build --watch
yarn build:css --watch

# Or use foreman/overmind:
bin/dev
```

## Project Structure

```
app/
├── controllers/     # Request handlers
├── models/         # Business logic and data models
├── views/          # ERB templates
├── javascript/     # Stimulus controllers
├── assets/         # Compiled CSS/JS
└── jobs/           # Background jobs

config/
├── database.yml    # Database configuration
├── routes.rb       # Application routes
└── environments/   # Environment-specific settings
```

## Key Models

- **User**: Authentication and roles (tenant, landlord, agent, admin)
- **Property**: Rental listings with location, price, and features
- **Lead**: Contact inquiries from potential tenants
- **LeadNote**: Timeline entries for lead management

## Development Workflow

1. Check the todo list in code
2. Create feature branch
3. Implement changes with tests
4. Run linters: `docker-compose exec web rubocop`
5. Submit PR

## Testing

```bash
# Run all tests
docker-compose exec web rails test

# Run specific test file
docker-compose exec web rails test test/models/property_test.rb

# Run system tests
docker-compose exec web rails test:system
```

## Deployment

The application is containerized and ready for deployment on:
- Render
- Fly.io
- Railway
- Heroku
- Any Docker-compatible platform

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

[License information here]# naijahomes
