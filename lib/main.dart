import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      return const MapView(plantId: 4);
    } else {
      return LoginView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PV Monitoring',
      theme: ThemeData(primarySwatch: Colors.blue),
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
