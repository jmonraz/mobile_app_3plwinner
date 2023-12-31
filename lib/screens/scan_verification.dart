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
  final TextEditingController _unitIdController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  bool pickSlipFound = false;
  bool isLoading = false;
  bool isDialogOpen = false;
  bool isEmailSent = false;
  bool isCompleted = false;

  Map<String, dynamic> pickSlipData = {};
  String errorMessage = '';
  String unitIdMessage = '';
  String quantityMessage = '';
  String scanVerificationMessage = '';
  String upcMessage = '';

  // current upc being scanned
  String currentScannedUpc = '';
  String currentScannedUnitId = '';
  String currentScannedQuantity = '';

  // group products by productId
  Map<String, dynamic> groupedProducts = {};

  void groupProducts() {
    for (var product in pickSlipData['products']) {
      if (groupedProducts.containsKey(product['productId'])) {
        groupedProducts[product['productId']]!.add(product);
      } else {
        groupedProducts[product['productId']] = [product];
      }
    }
  }

  void isProductCompleted(String upc) {
    isCompleted = false;
    for (var product in groupedProducts.entries) {
      for (var p in product.value) {
        if (p['upc'] == upc) {
          if (product.value.every((element) => element['verified'] == true)) {
            setState(() {
              isCompleted = true;
              quantityMessage = '';
              unitIdMessage = '';
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
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
                    onSubmitted: (value) async {
                      setState(() {
                        isLoading = true;
                        errorMessage = '';
                      });
                      if (_pickSlipController.text.isEmpty) {
                        setState(() {
                          isLoading = false;
                          errorMessage = 'Please enter a pick slip';
                        });
                        return;
                      }
                      pickSlipData = (await findPickSlip(
                          context, _pickSlipController.text))!;
                      setState(() {
                        isLoading = false;
                      });
                      if (pickSlipData.isNotEmpty) {
                        groupProducts();
                        setState(() {
                          pickSlipFound = true;
                          errorMessage = '';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Button(
                          text: 'Verify Pick Slip',
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                              errorMessage = '';
                            });
                            if (_pickSlipController.text.isEmpty) {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Please enter a pick slip';
                              });
                              return;
                            }
                            pickSlipData = (await findPickSlip(
                                context, _pickSlipController.text))!;
                            setState(() {
                              isLoading = false;
                            });
                            if (pickSlipData.isNotEmpty) {
                              groupProducts();
                              setState(() {
                                pickSlipFound = true;
                                errorMessage = '';
                              });
                            } else {
                              setState(() {
                                errorMessage = 'Pick slip not found';
                              });
                            }
                          },
                          child: const Text('Verify Pick Slip',
                              style: TextStyle(color: Colors.white))),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
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
                      onSubmitted: (value) {
                        if (_upcController.text.isEmpty) {
                          return;
                        }
                        setState(() {
                          _upcController.text = '';
                          currentScannedUpc =
                              findScannedUpc(value!, groupedProducts);
                          if (currentScannedUpc == 'not found') {
                            upcMessage = 'Product not found on pick slip';
                          }
                        });
                        if (currentScannedUpc != 'not found') {
                          // open the dialog box
                          setState(() {
                            upcMessage = '';
                          });
                          openVerificationDialog();
                          isProductCompleted(currentScannedUpc);
                        }
                      },
                    ),
                    if (upcMessage.isNotEmpty)
                      Text(
                        upcMessage,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 16.0),
                    Text('Pick Slip: ${pickSlipData['pickSlipId']}',
                        style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey)),
                    Flexible(
                      child: ListView(
                        children: [
                          for (var product in groupedProducts.entries)
                            ProductTile(
                              productId: product.key,
                              productList: product.value,
                            ),
                          Button(
                            text: 'text',
                            onPressed: () async {
                              setState(() {
                                isEmailSent = true;
                              });
                              if (groupedProducts.values.any((element) =>
                                  element.any((element) =>
                                      element['verified'] == false))) {
                                setState(() {
                                  scanVerificationMessage =
                                      'Please verify all products!';
                                  isEmailSent = false;
                                });
                                return;
                              }
                              String csv = convertToCsv(
                                  context, groupedProducts, pickSlipData);
                              String response = await sendCsvAsEmail(csv,
                                  'scan_verification_pick_slip_${pickSlipData['pickSlipId']}');
                              setState(() {
                                scanVerificationMessage = response;
                                isEmailSent = false;
                              });
                            },
                            child: !isEmailSent
                                ? const Text(
                                    'Finish Verification',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  )
                                : const CircularProgressIndicator(),
                          ),
                          if (scanVerificationMessage.isNotEmpty)
                            Text(
                              scanVerificationMessage,
                              style: TextStyle(
                                  color: scanVerificationMessage !=
                                          'Email sent successfully'
                                      ? Colors.red
                                      : Colors.green),
                            ),
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

  void openVerificationDialog() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Verify Product',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16.0),
                  Input(
                    hintText: 'Quantity...',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(
                      Icons.format_list_numbered,
                      color: Colors.blueGrey,
                      size: 20.0,
                    ),
                    onSubmitted: (value) {
                      if (_quantityController.text.isEmpty) {
                        return;
                      }
                      currentScannedQuantity = value.toString();
                      setState(() {
                        quantityMessage = verifyScannedQuantity(
                            currentScannedUpc,
                            currentScannedQuantity,
                            groupedProducts);
                        if (quantityMessage == 'quantity verified') {
                          currentScannedQuantity = value!;
                          _unitIdController.text = '';
                          unitIdMessage = '';
                        } else {
                          _quantityController.text = '';
                          unitIdMessage = '';
                        }
                      });
                    },
                  ),
                  if (quantityMessage.isNotEmpty)
                    Text(
                      quantityMessage,
                      style: TextStyle(
                          color: quantityMessage != "quantity verified"
                              ? Colors.red
                              : Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 16.0),
                  Input(
                    hintText: 'Scan Unit ID...',
                    controller: _unitIdController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(
                      Icons.barcode_reader,
                      color: Colors.blueGrey,
                      size: 20.0,
                    ),
                    onSubmitted: (value) {
                      if (_unitIdController.text.isEmpty) {
                        return;
                      }
                      if (currentScannedQuantity.isEmpty) {
                        setState(() {
                          unitIdMessage = 'Please scan quantity first';
                          _unitIdController.text = '';
                        });
                        return;
                      } else if (quantityMessage != 'quantity verified') {
                        setState(() {
                          unitIdMessage = 'Please verify quantity first';
                          _unitIdController.text = '';
                        });
                        return;
                      } else {
                        setState(() {
                          currentScannedUnitId = value.toString();
                          unitIdMessage = verifyScannedUnitId(
                              currentScannedUnitId,
                              currentScannedUpc,
                              currentScannedQuantity,
                              groupedProducts);
                          if (unitIdMessage ==
                              'unit id verified, continue with next line') {
                            _quantityController.text = '';
                            _unitIdController.text = '';
                            quantityMessage = '';
                            groupedProducts = updateVerifiedStatus(
                                currentScannedUnitId,
                                currentScannedUpc,
                                currentScannedQuantity,
                                groupedProducts);
                            isProductCompleted(currentScannedUpc);
                          }
                        });
                      }
                    },
                  ),
                  if (unitIdMessage.isNotEmpty)
                    Text(
                      unitIdMessage,
                      style: TextStyle(
                          color: unitIdMessage !=
                                  'unit id verified, continue with next line'
                              ? Colors.red
                              : Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 16.0),
                  isCompleted
                      ? const Center(
                          child: Text(
                            'All lines verified',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          );
        }).then((_) {
      setState(() {
        isDialogOpen = false;
        currentScannedUnitId = '';
        currentScannedUpc = '';
        unitIdMessage = '';
        quantityMessage = '';
        _upcController.text = '';
        _unitIdController.text = '';
        _quantityController.text = '';
      });
    });
  }
}
