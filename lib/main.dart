import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'global/constant/theme.dart';
import 'global/managers/dio_service.dart';
import 'global/managers/token_manager.dart';

import 'global/widgets/custom_navbar.dart';
import 'pages/alarm/views/alarm_view.dart';
import 'pages/device/view/device_setup_list_view.dart';
import 'pages/login/views/login_view.dart';
import 'pages/login/viewmodels/login_view_model.dart';
import 'pages/plant/services/plant_service.dart';
import 'pages/plant/views/plant_list_view.dart';
import 'pages/profile/service/user_service.dart';
import 'pages/profile/view/user_list_view.dart';
import 'pages/profile/viewmodel/user_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  DioService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getInitialPage() async {
    final auth = await TokenManager.getAuth();
    if (auth != null) {
      return MultiProvider(
        providers: [
          // Tüm uygulama boyunca kullanılacak Provider'ları burada tanımlayın
          ChangeNotifierProvider(create: (_) => UserViewModel(UserService(), PlantService())),
          // Diğer ViewModel'ler...
        ],
        child: CustomNavbar(
          pages: [PlantListView(), AlarmsPage(), DeviceSetupListView(), UserListView()],
          icons: [Icon(Icons.home), Icon(Icons.error), Icon(Icons.devices), Icon(Icons.person_4_rounded)],
        ),
      );
    } else {
      return ChangeNotifierProvider(create: (_) => LoginViewModel(), child: LoginView());
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    if (kIsWeb) return;
    final messaging = FirebaseMessaging.instance;

    // Arkaplanda gelen bildirimler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Uygulama kapalıyken gelen bildirimler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // Uygulama tamamen kapalıyken gelen bildirim
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
  }

  void _showNotification(RemoteMessage message) {
    // Bildirimi göster
    // FlutterLocalNotificationsPlugin kullanabilirsiniz
  }

  void _handleNotificationClick(RemoteMessage message) {
    // Bildirime tıklandığında yapılacak işlemler
    // Örneğin belirli bir sayfaya yönlendirme
  }
  static Future<void> _setupFirebaseToken() async {
    if (kIsWeb) return;
    try {
      // Firebase Messaging instance'ını al
      final messaging = FirebaseMessaging.instance;

      // Notification izinlerini iste (iOS için önemli)
      await messaging.requestPermission();

      // Token'i al
      final token = await messaging.getToken();
      if (token != null) {
        // Token'i backend'e kaydet
        await UserService().setFirebaseToken(token);

        // Token değişikliklerini dinle
        messaging.onTokenRefresh.listen((newToken) async {
          await UserService().setFirebaseToken(newToken);
        });
      }
    } catch (e) {
      debugPrint('Firebase token error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData.light().textTheme);
    return MaterialApp(
      navigatorKey: DioService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'PV Monitoring',
      theme: materialTheme.light(),
      home: FutureBuilder<Widget>(
        future: getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData) {
            _setupFirebaseToken();
            _setupFirebaseMessaging();
            return snapshot.data!; // Provider'lar zaten tanımlı
          } else {
            return const Scaffold(body: Center(child: Text("Bir hata oluştu")));
          }
        },
      ),
      routes: {
        '/login': (_) => ChangeNotifierProvider(create: (_) => LoginViewModel(), child: LoginView()),
        '/home':
            (_) => MultiProvider(
              providers: [ChangeNotifierProvider(create: (_) => UserViewModel(UserService(), PlantService()))],
              child: CustomNavbar(
                pages: [PlantListView(), AlarmsPage(), DeviceSetupListView(), UserListView()],
                icons: [Icon(Icons.home), Icon(Icons.error), Icon(Icons.devices), Icon(Icons.person_4_rounded)],
              ),
            ),
      },
    );
  }
}
