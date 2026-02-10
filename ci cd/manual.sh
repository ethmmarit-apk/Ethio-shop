# 1. Setup backend
cd backend
npm install
cp .env.example .env
npm run dev

# 2. Setup mobile app
cd mobile
flutter pub get
flutter run

# 3. Setup admin dashboard
cd admin-dashboard
npm install
npm start