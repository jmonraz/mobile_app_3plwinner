import 'package:flutter/material.dart';
import 'package:mobile_3plwinner/providers/api_unshipped_pick_slips_taskid_provider.dart';
import 'package:mobile_3plwinner/providers/api_warehouse_inventory_detail_taskid_provider.dart';
import 'package:mobile_3plwinner/screens/dashboard.dart';
import 'package:mobile_3plwinner/screens/login_screen.dart';
import 'package:mobile_3plwinner/screens/receiving_screen.dart';
import 'package:mobile_3plwinner/screens/scan_verification.dart';
import 'providers/api_key_provider.dart';
import 'providers/api_upcreport_taskid_provider.dart';
import 'providers/api_locationreport_taskid_provider.dart';
import 'providers/api_user_credentials_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ApiKeyProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ApiUPCReportTaskIdProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ApiLocationReportTaskIdProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ApiUserCredentialsProvider(),
        ),
        ChangeNotifierProvider(
            create: (_) => ApiUnshippedPickSlipsTaskIdProvider()),
        ChangeNotifierProvider(
            create: (_) => ApiWarehouseInventoryDetailTaskIdProvider()),
      ],
      //create an instance of the provider
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginScreen(),
        // LoginScreen(),
        routes: {
          '/receiving': (context) => const ReceivingScreen(),
          '/scan_verification': (context) => const ScanVerification(),
          '/dashboard': (context) => DashboardScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
