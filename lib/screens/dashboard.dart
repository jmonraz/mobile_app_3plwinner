import 'package:flutter/material.dart';
import '../widgets/tile.dart';
import '../utils/api_utils.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: isLoading
            ? const Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.0),
                  Text('Downloading Reports...',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 18.0)),
                ],
              ))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tile(
                    title: 'Receiving',
                    onTap: () {
                      Navigator.pushNamed(context, '/receiving');
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Tile(
                    title: 'Scan Verification',
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      final response =
                          await handleGetScanVerificationReports(context);
                      setState(() {
                        isLoading = false;
                      });
                      print(response);
                      Navigator.pushNamed(context, '/scan_verification');
                    },
                  )
                ],
              ),
      ),
    ));
  }
}
