import 'package:flutter/material.dart';
import 'api_utils.dart';
import 'package:intl/intl.dart';
import '../providers/api_user_credentials_provider.dart';
import 'package:provider/provider.dart';

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
    final username = Provider.of<ApiUserCredentialsProvider>(context, listen: false).username;
    final password = Provider.of<ApiUserCredentialsProvider>(context, listen: false).password;
    final receivingAlert = await handlePostReceiving(
        context,
        foundLocation['Aisle'],
        foundLocation['Rack'],
        foundLocation['Level'],
        zone,
        quantity,
        foundProduct['cusId'],
        foundProduct['productId'],
        username!,
        password!,
        currentTime);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successful Receipt {Receipt ID}: ${receivingAlert['ReceiptIDs'][0]}')),
    );

    return 'Product received!';
  } else {
    if(foundProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found!')),
      );
    } else if(foundLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not found!')),
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

Future<String> findPickSlip(BuildContext context, String pickSlip) async {
    final pickSlipsResponse = await handleGetReport(context, 'unshipped pick slips');
    final warehouseInventoryResponse = await handleGetReport(context, 'Warehouse Inventory Detail');

    Map<String, dynamic>? foundPickSlip;
    Map<String, dynamic>? foundInventory;

    String? newPickSlip = pickSlip.substring(1);

    // find pick slip in the list of pick slips
    for (var ps in pickSlipsResponse['Data']) {
      if (ps['Pick Slip'] == newPickSlip) {
        foundPickSlip = ps;
        print('found pick slip: $ps');
        break;
      }
    }

    return 'ok';
}