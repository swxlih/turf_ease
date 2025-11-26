import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Auth/authservice/fsm.dart';
import 'package:medical_app/Features/UserApp/Splashpage/view/splash_page.dart';
import 'package:medical_app/Features/UserApp/provider/booking_provider.dart';
import 'package:medical_app/Features/UserApp/provider/user_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => BookingProvider()),
      ],
      child: ScreenUtilInit(
        designSize:  Size(360, 804),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(debugShowCheckedModeBanner: false, home: child);
        },
        child: SplashPage(),
      ),
    );
  }
}
