#!/bin/bash

echo "🔥 Firebase Setup for Ethio Marketplace"

# Create mobile/android/app/google-services.json
cat > mobile/android/app/google-services.json << 'EOF'
{
  "project_info": {
    "project_number": "15344436312",
    "project_id": "ethio-shop-01525861",
    "storage_bucket": "ethio-shop-01525861.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:15344436312:android:3424355210f2b20449b62d",
        "android_client_info": {
          "package_name": "com.ethio.shop"
        }
      },
      "oauth_client": [
        {
          "client_id": "15344436312-udq1rn2j1jd0r1p52i90qb8rvlr69q02.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": {
            "package_name": "com.ethio.shop",
            "certificate_hash": "5e6add74ffe573e69d194c9e9cc0c7416f395d84"
          }
        },
        {
          "client_id": "15344436312-plqn7vfoh0rp9ept13l1i1eh5esifrhf.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyBFznFs5Sp1XnOdydNO3DMXoab8Ubl_po8"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            {
              "client_id": "15344436312-plqn7vfoh0rp9ept13l1i1eh5esifrhf.apps.googleusercontent.com",
              "client_type": 3
            }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
EOF

echo "✅ Firebase configuration created: mobile/android/app/google-services.json"
echo ""
echo "📋 Next Steps for Firebase:"
echo "1. Go to Firebase Console: https://console.firebase.google.com/"
echo "2. Select project: ethio-shop-01525861"
echo "3. Download service account:"
echo "   - Project Settings → Service Accounts"
echo "   - Click 'Generate New Private Key'"
echo "   - Save as: backend/service-account.json"
echo ""
echo "4. Enable Authentication providers:"
echo "   - Email/Password"
echo "   - Phone (for Ethiopian numbers)"
echo ""
echo "5. Deploy security rules:"
echo "   - Copy rules from firestore.rules and storage.rules"
echo ""
echo "🔥 Firebase setup completed!"