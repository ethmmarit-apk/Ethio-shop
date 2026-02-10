#!/bin/bash

# Ethio Marketplace Setup Script
echo "🚀 Setting up Ethio Marketplace..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js $NODE_VERSION"
    else
        print_error "Node.js is not installed"
        print_warning "Please install Node.js 18+ from https://nodejs.org/"
        exit 1
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        print_success "npm $(npm --version)"
    else
        print_error "npm is not installed"
        exit 1
    fi
    
    # Check Flutter
    if command -v flutter &> /dev/null; then
        print_success "Flutter $(flutter --version | grep -o 'Flutter [0-9.]*' | head -1)"
    else
        print_warning "Flutter is not installed. Mobile app setup will be limited."
    fi
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker $(docker --version | grep -o 'version [0-9.]*')"
    else
        print_warning "Docker is not installed. Docker setup will be skipped."
    fi
    
    print_success "Prerequisites check completed"
}

# Setup backend
setup_backend() {
    print_step "Setting up backend API..."
    
    cd backend
    
    # Install dependencies
    if [ ! -d "node_modules" ]; then
        print_step "Installing dependencies..."
        npm install
    fi
    
    # Setup environment
    if [ ! -f ".env" ]; then
        print_step "Creating environment file..."
        cp .env.example .env
        
        # Generate secrets
        echo "JWT_SECRET=$(openssl rand -hex 32)" >> .env
        echo "DB_PASSWORD=$(openssl rand -hex 16)" >> .env
        
        print_warning "Please review backend/.env file and update configurations"
    fi
    
    cd ..
    print_success "Backend setup completed"
}

# Setup mobile app
setup_mobile() {
    print_step "Setting up mobile app..."
    
    cd mobile
    
    # Check if Flutter is available
    if ! command -v flutter &> /dev/null; then
        print_warning "Flutter not available. Skipping mobile setup."
        cd ..
        return
    fi
    
    # Get dependencies
    print_step "Getting Flutter dependencies..."
    flutter pub get
    
    # Setup environment
    if [ ! -f ".env" ]; then
        print_step "Creating environment file..."
        cp .env.example .env
        print_warning "Please update mobile/.env with your API URLs"
    fi
    
    cd ..
    print_success "Mobile app setup completed"
}

# Setup admin dashboard
setup_admin() {
    print_step "Setting up admin dashboard..."
    
    cd admin-dashboard
    
    # Install dependencies
    if [ ! -d "node_modules" ]; then
        print_step "Installing dependencies..."
        npm install
    fi
    
    # Setup environment
    if [ ! -f ".env" ]; then
        print_step "Creating environment file..."
        cp .env.example .env
    fi
    
    cd ..
    print_success "Admin dashboard setup completed"
}

# Setup Docker
setup_docker() {
    print_step "Setting up Docker..."
    
    if ! command -v docker &> /dev/null; then
        print_warning "Docker not available. Skipping Docker setup."
        return
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_warning "Docker Compose not available. Skipping Docker setup."
        return
    fi
    
    print_success "Docker setup completed"
    print_warning "Run 'docker-compose up' to start all services"
}

# Display setup summary
show_summary() {
    print_step "🎉 Setup Summary"
    echo ""
    echo "${GREEN}✅ Backend API:${NC}"
    echo "   Location: backend/"
    echo "   Run: cd backend && npm run dev"
    echo "   API: http://localhost:8080"
    echo "   Docs: http://localhost:8080/api-docs"
    echo ""
    
    echo "${GREEN}✅ Mobile App:${NC}"
    echo "   Location: mobile/"
    if command -v flutter &> /dev/null; then
        echo "   Run: cd mobile && flutter run"
    else
        echo "   Status: Flutter not installed"
    fi
    echo ""
    
    echo "${GREEN}✅ Admin Dashboard:${NC}"
    echo "   Location: admin-dashboard/"
    echo "   Run: cd admin-dashboard && npm start"
    echo "   URL: http://localhost:3000"
    echo ""
    
    echo "${GREEN}✅ Docker Services:${NC}"
    if command -v docker &> /dev/null; then
        echo "   Run: docker-compose up"
        echo "   PostgreSQL: localhost:5432"
        echo "   Redis: localhost:6379"
        echo "   pgAdmin: http://localhost:5050"
    else
        echo "   Status: Docker not installed"
    fi
    echo ""
    
    echo "${YELLOW}📋 Next Steps:${NC}"
    echo "1. Update environment files:"
    echo "   - backend/.env"
    echo "   - mobile/.env"
    echo "   - admin-dashboard/.env"
    echo "2. Download Firebase service account:"
    echo "   Firebase Console → Project Settings → Service Accounts"
    echo "   Save as: backend/service-account.json"
    echo "3. Run the application:"
    echo "   - Backend: cd backend && npm run dev"
    echo "   - Mobile: cd mobile && flutter run"
    echo "   - Docker: docker-compose up (all services)"
    echo ""
    
    echo "${BLUE}🔧 Default Admin Credentials:${NC}"
    echo "   Email: admin@ethiomarketplace.com"
    echo "   Password: Admin123!"
    echo ""
    
    print_success "Ethio Marketplace setup completed! 🎉"
}

# Main execution
main() {
    echo -e "${GREEN}"
    cat << "EOF"
███████╗████████╗██╗  ██╗██╗ ██████╗     ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗██████╗  █████╗  ██████╗███████╗
██╔════╝╚══██╔══╝██║  ██║██║██╔════╝     ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝
█████╗     ██║   ███████║██║██║          ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║   ██████╔╝███████║██║     █████╗  
██╔══╝     ██║   ██╔══██║██║██║          ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═██╗ ██╔══╝     ██║   ██╔══██╗██╔══██║██║     ██╔══╝  
███████╗   ██║   ██║  ██║██║╚██████╗     ██║ ╚═╝ ██║██║  ██║██║     ██║  ██╗███████╗   ██║   ██████╔╝██║  ██║╚██████╗███████╗
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚══════╝
EOF
    echo -e "${NC}"
    
    check_prerequisites
    setup_backend
    setup_mobile
    setup_admin
    setup_docker
    show_summary
}

# Run setup
main "$@"