import 'package:flutter/material.dart';
import 'package:mobile_3plwinner/utils/functions.dart';
import 'package:mobile_3plwinner/widgets/product_tile.dart';
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
  Map<String, dynamic> pickSlipData = {};
  String errorMessage = '';

  // group products by productId
  Map<String, List<Map<String, dynamic>>> groupedProducts = {};

  void groupProducts() {
    for (var product in pickSlipData['products']) {
      if (groupedProducts.containsKey(product['productId'])) {
        groupedProducts[product['productId']]!.add(product);
      } else {
        groupedProducts[product['productId']] = [product];
      }
    }
    print(groupedProducts);
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
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (_pickSlipController.text.isEmpty) {
                          setState(() {
                            isLoading = false;
                            errorMessage = 'Please enter a pick slip';
                          });
                          return;
                        }
                        pickSlipData = (await findPickSlip(context, _pickSlipController.text))!;
                        setState(() {
                          isLoading = false;
                        });
                        if(pickSlipData.isNotEmpty) {
                          groupProducts();
                          setState(() {
                            pickSlipFound = true;
                            errorMessage = '';
                          });
                        }
                      },
                      child: const Text('Verify Pick Slip')),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
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
                    Text('Pick Slip: ${pickSlipData['pickSlipId']}'),
                    Flexible(
                      child: ListView(
                        children: [
                          for (var product in groupedProducts.entries)
                            ProductTile(
                              productId: product.key,
                              productList: product.value,
                            )
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

