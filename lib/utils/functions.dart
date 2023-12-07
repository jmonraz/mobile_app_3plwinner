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
    final username =
        Provider.of<ApiUserCredentialsProvider>(context, listen: false)
            .username;
    final password =
        Provider.of<ApiUserCredentialsProvider>(context, listen: false)
            .password;
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
      SnackBar(
          content: Text(
              'Successful Receipt {Receipt ID}: ${receivingAlert['ReceiptIDs'][0]}')),
    );

    return 'Product received!';
  } else {
    if (foundProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found!')),
      );
    } else if (foundLocation == null) {
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

Future<Map<String, dynamic>?> findPickSlip(BuildContext context, String pickSlip) async {
  final pickSlipsResponse =
      await handleGetReport(context, 'unshipped pick slips');
  final warehouseInventoryResponse =
      await handleGetReport(context, 'Warehouse Inventory Detail');

  Map<String, dynamic>? foundPickSlip;
  Map<String, dynamic> mappedPickSlip = {};

  String? newPickSlip = pickSlip.substring(1);

  // find pick slip in the list of pick slips
  for (var ps in pickSlipsResponse['Data']) {
    if (ps['Pick Slip ID'].toString() == newPickSlip) {
      foundPickSlip = ps;
      print('found pick slip: $ps');
      break;
    }
  }

  if (foundPickSlip == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pick slip not found!')),
    );
    return {};
  }

  // format the foundPickSlip object
  mappedPickSlip['pickSlipId'] = foundPickSlip['Pick Slip ID'];
  mappedPickSlip['orderId'] = foundPickSlip['Order ID'];
  mappedPickSlip['orderDate'] = foundPickSlip['Order Date'];
  mappedPickSlip['products'] = [];

  final productDetails = foundPickSlip['Product and Location Details'];
  final decodedText = productDetails.replaceAll('&amp;', '&');
  final productItems = decodedText.split('; ');
  productItems.removeLast();

  for (var item in productItems) {
    final parts = item.split(', ');
    final product = parts[0].split(': ')[1];
    final location = parts[1].split(': ')[1];
    final updatedLocation = location.split('*');
    final zone = updatedLocation[0];
    final aisle = updatedLocation[1];
    final rack = updatedLocation[2];
    final level = updatedLocation[3];
    final quantity = parts[2].split(': ')[1];

    mappedPickSlip['products'].add({
      'productId': product,
      'zone': zone,
      'aisle': aisle,
      'rack': rack,
      'level': level,
      'quantity': quantity,
      'verified': false,
    });
  }

  // add unit id property to each product in the mappedPickSlip
  // find the unit id by comparing locations between the warehouse inventory report and the mappedPickSlip object
  for(var id in warehouseInventoryResponse['Data']) {
    for(var product in mappedPickSlip['products']) {
      if(id['Aisle'] == product['aisle'] && id['Rack'] == product['rack'] && id['Level'] == product['level'] && id['Product ID'] == product['productId']) {
        product['unitId'] = id['Unit ID'];
      }
    }
  }

  // add upc property to each product in the mappedPickSlip
  for(var p in mappedPickSlip['products']) {
    p['upc'] = await findProductByProductId(context, p['productId']);
  }

  print('mappedPickSlip: $mappedPickSlip');
  return mappedPickSlip;
}

Future<String> findProductByProductId(BuildContext context, String productId) async {
  final productsResponse = await handleGetReport(context, 'upcs');

  Map<String, dynamic>? foundProduct;

  for (var p in productsResponse['Data']) {
    if(p['productId'] == productId) {
      foundProduct = p;
      break;
    }
  }

  return foundProduct!['UPC'];
}

Map<String, List<Map<String, dynamic>>> findScannedUpc(String scannedUpc, Map<String, List<Map<String, dynamic>>> productList) {
  for (var product in productList.entries) {
    for(var p in product.value) {
      if(p['upc'] == scannedUpc) {
        p['verified'] = true;
        print('product verified: $p');
        break;
      }
    }
  }
  return productList;
}