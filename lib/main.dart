import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/widgets/custom_navbar.dart';
import 'package:smart_ges_360/pages/plant/views/plant_list_view.dart';

import 'global/managers/dio_service.dart';
import 'global/managers/token_manager.dart';

import 'pages/login/views/login_view.dart';
import 'pages/login/viewmodels/login_view_model.dart';
import 'pages/map/views/map_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getInitialPage() async {
    final auth = await TokenManager.getAuth();
    if (auth != null) {
      return CustomNavbar(pages: [PlantListView(), Container(), Container()], icons: [Icon(Icons.home), Icon(Icons.abc), Icon(Icons.person_4_rounded)], title: "Tesisler");
    } else {
      return LoginView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PV Monitoring',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue.shade700,
          secondary: Colors.teal.shade400,
          surface: Colors.white,
          primaryContainer: Colors.blue.shade50,
          secondaryContainer: Colors.teal.shade50,
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade400)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue.shade700,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textTheme: TextTheme(headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), bodyMedium: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
      ),
      home: FutureBuilder<Widget>(
        future: getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData) {
            DioService.init(context);
            final page = snapshot.data!;
            if (page is LoginView) {
              return ChangeNotifierProvider(create: (_) => LoginViewModel(), child: page);
            }
            return page;
          } else {
            return const Scaffold(body: Center(child: Text("Bir hata oluştu")));
          }
        },
      ),
      routes: {'/login': (_) => ChangeNotifierProvider(create: (_) => LoginViewModel(), child: LoginView()), '/home': (_) => const MapView(plantId: 4)},
    );
  }
}
