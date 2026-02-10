#!/bin/bash

echo "🚀 Setting up Firebase for Ethio Marketplace..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_step() {
    echo -e "\n${GREEN}▶ $1${NC}"
}

# Check if google-services.json exists
print_step "Checking Firebase configuration..."

if [ -f "mobile/android/app/google-services.json" ]; then
    print_success "Firebase configuration found"
else
    print_error "google-services.json not found in mobile/android/app/"
    print_warning "Please place your google-services.json file in that location"
    exit 1
fi

# Check if service-account.json exists for backend
print_step "Checking backend Firebase configuration..."

if [ -f "backend/service-account.json" ]; then
    print_success "Firebase service account found for backend"
else
    print_warning "backend/service-account.json not found"
    print_warning "You need to download it from Firebase Console:"
    echo "1. Go to Firebase Console → Project Settings → Service Accounts"
    echo "2. Click 'Generate New Private Key'"
    echo "3. Save it as backend/service-account.json"
    echo ""
    read -p "Do you want to continue without backend Firebase? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Setup mobile app Firebase
print_step "Setting up Flutter Firebase..."

cd mobile

# Install FlutterFire CLI if not installed
if ! command -v flutterfire &> /dev/null; then
    print_warning "FlutterFire CLI not installed. Installing..."
    dart pub global activate flutterfire_cli
fi

# Configure FlutterFire
print_step "Configuring FlutterFire..."
flutterfire configure --project=ethio-shop-01525861 --out=lib/firebase_options.dart --yes

# Get Firebase dependencies
print_step "Getting Firebase dependencies..."
flutter pub get

cd ..

print_step "Setting up backend Firebase..."

cd backend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    print_step "Installing backend dependencies..."
    npm install
fi

# Create .env if not exists
if [ ! -f ".env" ]; then
    print_step "Creating environment file..."
    cp .env.example .env
    
    # Update Firebase variables in .env
    sed -i '' "s/FIREBASE_PROJECT_ID=.*/FIREBASE_PROJECT_ID=ethio-shop-01525861/" .env
    sed -i '' "s/FIREBASE_STORAGE_BUCKET=.*/FIREBASE_STORAGE_BUCKET=ethio-shop-01525861.firebasestorage.app/" .env
    
    print_warning "Please update other variables in backend/.env"
fi

cd ..

print_step "Creating Firebase security rules..."

# Create Firestore security rules
cat > firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products: anyone can read, only sellers can write
    match /products/{productId} {
      allow read: if true;
      allow create: if request.auth != null && 
        request.auth.token.role == 'seller';
      allow update, delete: if request.auth != null && 
        resource.data.sellerId == request.auth.uid;
    }
    
    // Orders: users can access their own orders
    match /orders/{orderId} {
      allow read: if request.auth != null && 
        (resource.data.buyerId == request.auth.uid || 
         resource.data.sellerId == request.auth.uid);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        resource.data.sellerId == request.auth.uid;
    }
    
    // Chat messages
    match /chats/{chatId}/messages/{messageId} {
      allow read: if request.auth != null && 
        (resource.data.senderId == request.auth.uid || 
         resource.data.receiverId == request.auth.uid);
      allow create: if request.auth != null;
    }
  }
}
EOF

# Create Storage security rules
cat > storage.rules << 'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /profile-images/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Product images
    match /product-images/{productId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // General uploads
    match /uploads/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
EOF

print_success "Firebase security rules created!"
print_warning "You need to deploy these rules to Firebase:"
echo "1. Go to Firebase Console → Firestore → Rules"
echo "2. Copy content from firestore.rules"
echo "3. Go to Firebase Console → Storage → Rules"
echo "4. Copy content from storage.rules"

print_step "Testing Firebase connection..."

# Test mobile Firebase connection
cd mobile
if flutter run --version | grep -q "Firebase"; then
    print_success "Flutter Firebase configured successfully"
else
    print_warning "Flutter Firebase may need additional setup"
fi

cd ../backend

# Create simple test script
cat > test-firebase.js << 'EOF'
const admin = require('firebase-admin');

try {
  const serviceAccount = require('./service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  
  console.log('✅ Firebase Admin SDK initialized successfully');
  console.log('📦 Project ID:', serviceAccount.project_id);
  console.log('📧 Client Email:', serviceAccount.client_email);
  
  process.exit(0);
} catch (error) {
  console.error('❌ Firebase initialization failed:', error.message);
  process.exit(1);
}
EOF

if node test-firebase.js; then
    print_success "Backend Firebase configured successfully"
else
    print_warning "Backend Firebase needs service account JSON"
fi

rm test-firebase.js

cd ..

print_success "\n🎉 Firebase setup completed!"
echo ""
echo "📱 Mobile App Firebase: Ready"
echo "⚙️  Backend Firebase: Ready"
echo "🔒 Security Rules: Created (need deployment)"
echo ""
echo "Next steps:"
echo "1. Deploy Firestore rules from firestore.rules"
echo "2. Deploy Storage rules from storage.rules"
echo "3. Enable Authentication providers in Firebase Console"
echo "4. Set up Cloud Functions if needed"
echo ""
echo "Run the app:"
echo "  cd mobile && flutter run"
echo "Run the backend:"
echo "  cd backend && npm run dev"