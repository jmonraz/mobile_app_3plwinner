import 'package:flutter/material.dart';
import 'package:mobile_3plwinner/widgets/input.dart';

class ScanVerification extends StatefulWidget {
  const ScanVerification({super.key});

  @override
  State<ScanVerification> createState() => _ScanVerificationState();
}

class _ScanVerificationState extends State<ScanVerification> {
  final TextEditingController _upcController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Input(
            hintText: 'Scan upc...',
            controller: _upcController,
            keyboardType: TextInputType.text,
            prefixIcon: const Icon(
              Icons.barcode_reader,
              color: Colors.blueGrey,
              size: 20.0,
            ),
          )
        ],
      ),
    )));
  }
}
