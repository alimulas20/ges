import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_ges_360/global/constant/theme.dart';
import 'package:smart_ges_360/global/widgets/custom_navbar.dart';
import 'package:smart_ges_360/pages/device/view/device_setup_list_view.dart';
import 'package:smart_ges_360/pages/plant/views/plant_list_view.dart';
import 'package:smart_ges_360/pages/profile/view/profile_view.dart';

import 'global/managers/dio_service.dart';
import 'global/managers/token_manager.dart';

import 'pages/login/views/login_view.dart';
import 'pages/login/viewmodels/login_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getInitialPage() async {
    final auth = await TokenManager.getAuth();
    if (auth != null) {
      return CustomNavbar(pages: [PlantListView(), DeviceSetupListView(), ProfileView()], icons: [Icon(Icons.home), Icon(Icons.devices), Icon(Icons.person_4_rounded)]);
    } else {
      return LoginView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData.light().textTheme);
    return MaterialApp(
      title: 'PV Monitoring',
      theme: materialTheme.light(),
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
      routes: {
        '/login': (_) => ChangeNotifierProvider(create: (_) => LoginViewModel(), child: LoginView()),
        '/home': (_) => CustomNavbar(pages: [PlantListView(), DeviceSetupListView(), ProfileView()], icons: [Icon(Icons.home), Icon(Icons.devices), Icon(Icons.person_4_rounded)]),
      },
    );
  }
}
