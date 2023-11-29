import 'package:flutter/material.dart';
import '../widgets/input.dart';
import '../widgets/button.dart';
import '../utils/functions.dart';

class ReceivingScreen extends StatefulWidget {
  const ReceivingScreen({super.key});

  @override
  State<ReceivingScreen> createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
    final _formKey = GlobalKey<FormState>(); // GlobalKey for the form
    final TextEditingController _productUpcController = TextEditingController();
    final TextEditingController _productQuantityController = TextEditingController();
    final TextEditingController _productZoneController = TextEditingController();
    final TextEditingController _productLocationController = TextEditingController();
    bool isLoading = false;

    @override
    void initState() {
      super.initState();
      _productZoneController.text = 'Bins';
    }

    @override
    Widget build(BuildContext context) {
      return
      Scaffold(
        body:
        Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child:
          SingleChildScrollView(
            child:
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form (
                key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Receving', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 16.0),
                  Input(
                    hintText: 'UPC',
                    controller: _productUpcController,
                    keyboardType: TextInputType.text,

                  ),
                  const SizedBox(height: 8.0),
                  Input(
                    hintText: 'Quantity',
                    controller: _productQuantityController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8.0),
                  Input(
                    enabled: false,
                    hintText: 'Zone',
                    controller: _productZoneController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 8.0),
                  Input(
                    hintText: 'Location',
                    controller: _productLocationController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Button(
                        text: 'Find Product',
                        onPressed: isLoading ? null : () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            final int? quantity = int.tryParse(_productQuantityController.text);
                            if (quantity != null) {
                              final response = await findProduct(context, _productUpcController.text, _productZoneController.text, _productLocationController.text, quantity);
                              setState(() {
                                isLoading = false;
                                _productUpcController.text = '';
                                _productQuantityController.text = '';
                                _productLocationController.text = '';
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Quantity must be a number!')),
                              );
                            }
                          }
                        },
                        child: isLoading ? CircularProgressIndicator(): const Text('Receive Product', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
        ),
      );
    }
}