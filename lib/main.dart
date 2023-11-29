import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/receiving_screen.dart';
import 'providers/api_key_provider.dart';
import 'providers/api_upcreport_taskid_provider.dart';
import 'providers/api_locationreport_taskid_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
      MultiProvider(providers:  [
          ChangeNotifierProvider(
          create: (_) => ApiKeyProvider(),
        ),
          ChangeNotifierProvider(
          create: (_) => ApiUPCReportTaskIdProvider(),
        ),
          ChangeNotifierProvider(
            create: (_) => ApiLocationReportTaskIdProvider(),
          ),
      ],
       //create an instance of the provider
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
        routes: {
          '/receiving': (context) => ReceivingScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

