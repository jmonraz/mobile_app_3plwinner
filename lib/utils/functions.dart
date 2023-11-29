import 'package:flutter/material.dart';
import 'api_utils.dart';
import 'package:intl/intl.dart';

Future<String> findProduct(BuildContext context, String upc, String zone,
    String locationId, int quantity) async {
  final productsResponse = await handleGetReport(context, 'upcs');
  final locationsResponse = await handleGetReport(context, 'Locations');

  Map<String, dynamic>? foundProduct;
  Map<String, dynamic>? foundLocation;

  String? newLocationId = locationId.substring(1);

  // find product in the list of products
  for (var product in productsResponse['Data']) {
    if (product['UPC'] == upc) {
      foundProduct = product;
      break;
    }
  }

  // find location in the list of locations
  for (var location in locationsResponse['Data']) {
    if (location['Location ID'].toString() == newLocationId) {
      foundLocation = location;
      break;
    }
  }


  if (foundProduct != null && foundLocation != null) {
    print('into receiving mode');
    String currentTime = getFormattedUtcDateTime();

    final receivingAlert = await handlePostReceiving(
        context,
        foundLocation['Aisle'],
        foundLocation['Rack'],
        foundLocation['Level'],
        zone,
        quantity,
        foundProduct['cusId'],
        foundProduct['productId'],
        'jorge',
        'jorge',
        currentTime);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successful Receipt {Receipt ID}: ${receivingAlert['ReceiptIDs'][0]}')),
    );

    return 'Product received!';
  } else {
    if(foundProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product not found!')),
      );
    } else if(foundLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found!')),
      );
    }
    return 'Product not found or location not found!';
  }
}

String getFormattedUtcDateTime() {
  final currentUtcDate = DateTime.now().toUtc();
  final formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
  return formatter.format(currentUtcDate);
}
