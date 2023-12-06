import 'package:flutter/material.dart';
import 'package:mobile_3plwinner/widgets/ProductTile.dart';
import 'package:mobile_3plwinner/widgets/button.dart';
import 'package:mobile_3plwinner/widgets/input.dart';

class ScanVerification extends StatefulWidget {
  const ScanVerification({super.key});

  @override
  State<ScanVerification> createState() => _ScanVerificationState();
}

class _ScanVerificationState extends State<ScanVerification> {
  final TextEditingController _upcController = TextEditingController();
  final TextEditingController _pickSlipController = TextEditingController();
  bool pickSlipFound = false;
  bool isLoading = false;
  final String errorMessage = '';

  void verifyPickSlip() {
    setState(() {
      isLoading = true;
    });
    // perform search algorithm to find pick slip
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        pickSlipFound = true;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!pickSlipFound)
              Column(
                children: [
                  Input(
                    hintText: 'Scan pick slip...',
                    controller: _pickSlipController,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(
                      Icons.document_scanner,
                      color: Colors.blueGrey,
                      size: 20.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  isLoading ? const CircularProgressIndicator() :
                  Button(
                      text: 'Verify Pick Slip',
                      onPressed: () {
                        verifyPickSlip();
                      },
                      child: const Text('Verify Pick Slip')),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            if (pickSlipFound)
              Expanded(
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
                    ),
                    const SizedBox(height: 16.0),
                    Flexible(
                      child: ListView(
                        children: [
                          ProductTile(
                              productName: 'Product A',
                              numberOfLines: 4,
                              totalQuantity: 1000),
                          ProductTile(
                              productName: 'Product B',
                              numberOfLines: 2,
                              totalQuantity: 750),
                          ProductTile(
                              productName: 'Product C',
                              numberOfLines: 20,
                              totalQuantity: 6000)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
