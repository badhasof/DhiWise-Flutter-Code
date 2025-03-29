import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_reading_service.dart';
import '../services/user_service.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return const FirebaseTestScreen();
  }

  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final UserService _userService = UserService();
  final UserReadingService _userReadingService = UserReadingService();
  String _statusMessage = "Ready to test";
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Test'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserInfoCard(),
            SizedBox(height: 16),
            _buildTestActions(),
            SizedBox(height: 16),
            _buildStatusCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserInfoCard() {
    final user = FirebaseAuth.instance.currentUser;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('User Logged In: ${user != null ? 'Yes' : 'No'}'),
            if (user != null) ...[
              Text('User ID: ${user.uid}'),
              Text('Email: ${user.email ?? 'Not provided'}'),
              Text('Display Name: ${user.displayName ?? 'Not provided'}'),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testFirestorePermissions,
              child: Text('Test Firestore Permissions'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testUserInitialization,
              child: Text('Test User Initialization'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testStoryCompletion,
              child: Text('Test Story Completion'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_statusMessage),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _testFirestorePermissions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Testing Firestore permissions...";
    });
    
    try {
      bool result = await _userReadingService.testFirestorePermissions();
      
      setState(() {
        _statusMessage = result 
            ? "✅ Firestore permissions test successful!" 
            : "❌ Firestore permissions test failed. Check the debug console for details.";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _testUserInitialization() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Testing user initialization...";
    });
    
    try {
      await _userService.initializeUserDataIfNeeded();
      
      // Check if user data exists
      final userData = await _userService.getUserData();
      
      setState(() {
        if (userData != null) {
          _statusMessage = "✅ User data initialized successfully: $userData";
        } else {
          _statusMessage = "❌ User data initialization failed or user not logged in.";
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _testStoryCompletion() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Testing story completion...";
    });
    
    try {
      // Use a test story ID
      const testStoryId = "test_story_123";
      
      await _userReadingService.recordCompletedStory(testStoryId);
      
      // Check if the story was recorded
      final totalStories = await _userReadingService.getTotalCompletedStories();
      
      setState(() {
        _statusMessage = "✅ Story completion test finished. Total stories: $totalStories";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 