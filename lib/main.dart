import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:expense_tracker_app/Services/auth_service.dart';
import 'package:expense_tracker_app/Services/stream_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 1. 🔔 Top-Level Background Handler
/// Must be outside any class and marked with @pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

/// 🔔 Global Notifications Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔔 Android Notification Channel
const AndroidNotificationChannel highImportanceChannel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Register Background Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Setup Android Channel (Mandatory for Android 8+)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(highImportanceChannel);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final authService = AuthService();
  final streamService = ExpenseStreamService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setupPushNotifications();
    setupInteractions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden || 
        state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached) {
      streamService.dispose();
      debugPrint("App Lifecycle: Stream Service Closed");
    } else if (state == AppLifecycleState.resumed) {
      streamService.reset();
      debugPrint("App Lifecycle: Stream Service Reset");
    }
  }

  /// 4. 🔔 Full Notification Setup
  void setupPushNotifications() async {
    // A. Request Permissions (iOS & Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // B. Initialize Local Notifications Plugin (CRITICAL)
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click while app is open
        debugPrint("Notification tapped: ${details.payload}");
      },
    );

    // C. Get & Save FCM Token
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint("🔥 FCM Token: $token");
    if (token != null) {
      _saveTokenToFirestore(token);
    }

    // D. Foreground Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              highImportanceChannel.id,
              highImportanceChannel.name,
              channelDescription: highImportanceChannel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: message.data.toString(),
        );
      }
    });
  }

  /// 5. 🖱️ Handle Clicks (Background/Terminated States)
  void setupInteractions() async {
    // Terminated State: App opened from a notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      debugPrint("App opened from Terminated state via notification");
    }

    // Background State: App resumed from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("App resumed from Background state via notification");
    });
  }

  void _saveTokenToFirestore(String token) async {
    final uid = authService.currentUserId;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}
