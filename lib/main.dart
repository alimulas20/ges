import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import 'firebase_options.dart';
import 'global/constant/theme.dart';
import 'global/managers/dio_service.dart';
import 'global/managers/token_manager.dart';
import 'global/widgets/custom_navbar.dart';
import 'pages/alarm/views/alarm_view.dart';
import 'pages/device/view/device_setup_list_view.dart';
import 'pages/login/viewmodels/login_view_model.dart';
import 'pages/login/views/login_view.dart';
import 'pages/plant/services/plant_service.dart';
import 'pages/plant/views/plant_list_view.dart';
import 'pages/profile/service/user_service.dart';
import 'pages/profile/view/user_list_view.dart';
import 'pages/profile/viewmodel/user_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initializationFuture = _AppInitializer.initialize();
  DioService.init();
  runApp(MyApp(initializationFuture: initializationFuture));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initializationFuture});

  final Future<void> initializationFuture;

  @override
  State<MyApp> createState() => _MyAppState();

  Future<Widget> _getInitialPage(Future<void> initializationFuture) async {
    // Sadece access_token kontrolü yap, daha hızlı
    final accessToken = await TokenManager.getAccessToken();
    if (accessToken != null) {
      // Firebase setup işlemlerini arka planda çalıştır, widget'ı hemen döndür
      initializationFuture.then((_) {
        MyApp.setupFirebaseToken().catchError((e) => debugPrint('Firebase token setup error: $e'));
        MyApp.setupFirebaseMessaging().catchError((e) => debugPrint('Firebase messaging setup error: $e'));
      });
      return MultiProvider(
        providers: [
          // Tüm uygulama boyunca kullanılacak Provider'ları burada tanımlayın
          ChangeNotifierProvider(create: (_) => UserViewModel(UserService(), PlantService())),
          // Diğer ViewModel'ler...
        ],
        child: CustomNavbar(
          pages: [PlantListView(), DeviceSetupListView(), AlarmsPage(), UserListView()],
          tabs: const [
            Tab(icon: Icon(Icons.home), text: "Tesisler"),
            Tab(icon: Icon(Icons.ad_units_outlined), text: "Cihazlar"),
            Tab(icon: Icon(Icons.error), text: "Alarmlar"),
            Tab(icon: Icon(Icons.person_4_rounded), text: "Profil"),
          ],
        ),
      );
    }
    return ChangeNotifierProvider(create: (_) => LoginViewModel(), child: LoginView());
  }

  static Future<void> setupFirebaseMessaging() async {
    await _AppInitializer.initialize();
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

  static void _showNotification(RemoteMessage message) {
    // Bildirimi göster
    // FlutterLocalNotificationsPlugin kullanabilirsiniz
  }

  static void _handleNotificationClick(RemoteMessage message) {
    // Bildirime tıklandığında yapılacak işlemler
    // Örneğin belirli bir sayfaya yönlendirme
  }

  static Future<void> setupFirebaseToken() async {
    await _AppInitializer.initialize();
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
}

class _MyAppState extends State<MyApp> {
  late final Future<Widget> _initialPageFuture = widget._getInitialPage(widget.initializationFuture);

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData.light().textTheme);
    return MaterialApp(
      navigatorKey: DioService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'PV Monitoring',
      theme: materialTheme.light(),
      home: FutureBuilder<Widget>(
        future: _initialPageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData) {
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
                pages: [PlantListView(), DeviceSetupListView(), AlarmsPage(), UserListView()],
                tabs: const [
                  Tab(icon: Icon(Icons.home), text: "Tesisler"),
                  Tab(icon: Icon(Icons.ad_units_outlined), text: "Cihazlar"),
                  Tab(icon: Icon(Icons.error), text: "Alarmlar"),
                  Tab(icon: Icon(Icons.person_4_rounded), text: "Profil"),
                ],
              ),
            ),
      },
    );
  }
}

class _AppInitializer {
  static Future<void>? _initialization;

  static Future<void> initialize() {
    _initialization ??= _runInitialization();
    return _initialization!;
  }

  static Future<void> _runInitialization() async {
    await Future.wait([_initRive(), _initIntl(), _initFirebase()]);
  }

  static Future<void> _initRive() async {
    await RiveNative.init();
  }

  static Future<void> _initIntl() async {
    await initializeDateFormatting('tr_TR', null);
    Intl.defaultLocale = 'tr_TR';
  }

  static Future<void> _initFirebase() async {
    if (kIsWeb) return;
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
