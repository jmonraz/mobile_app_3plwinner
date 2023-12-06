import 'package:flutter/material.dart';
import '../widgets/tile.dart';
import '../utils/api_utils.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
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
                final response = await handleGetScanVerificationReports(context);
                Navigator.pushNamed(context, '/scan_verification');
              },
            )
          ],
        ),
      ),
    ));
  }
}
