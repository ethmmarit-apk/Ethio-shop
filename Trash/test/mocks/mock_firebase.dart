import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Generate mocks for Firebase services
@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  FirebaseStorage,
  Reference,
  UploadTask,
  TaskSnapshot,
])
export 'mock_firebase.mocks.dart';