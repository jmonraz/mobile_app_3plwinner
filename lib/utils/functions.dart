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

Future<Map<String, dynamic>?> findPickSlip(
    BuildContext context, String pickSlip) async {
  final pickSlipsResponse =
      await handleGetReport(context, 'unshipped pick slips');
  final warehouseInventoryResponse =
      await handleGetReport(context, 'Warehouse Inventory Detail');

  Map<String, dynamic>? foundPickSlip;
  Map<String, dynamic> mappedPickSlip = {};

  String? newPickSlip;
  if (pickSlip.startsWith('M') || pickSlip.startsWith('m')) {
    newPickSlip = pickSlip.substring(1);
  } else {
    newPickSlip = pickSlip;
  }

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
  for (var id in warehouseInventoryResponse['Data']) {
    for (var product in mappedPickSlip['products']) {
      if (id['Aisle'] == product['aisle'] &&
          id['Rack'] == product['rack'] &&
          id['Level'] == product['level'] &&
          id['Product ID'] == product['productId']) {
        product['unitId'] = id['Unit ID'];
      }
    }
  }

  print('here before upcs');

  // add upc property to each product in the mappedPickSlip
  final productIds =
      mappedPickSlip['products'].map((e) => e['productId']).toSet().toList();
  print('productIds: $productIds');
  // fetch 'upc' values for the product IDs in batches
  final upcsMap = await findProductByProductIds(context, productIds);
  print('upcsMap: $upcsMap');

  // add 'upc' property to each product in the mappedPickSlip
  for (var product in mappedPickSlip['products']) {
    product['upc'] = upcsMap[product['productId']];
  }

  print('mappedPickSlip: $mappedPickSlip');
  return mappedPickSlip;
}

Future<Map<String, String>> findProductByProductIds(
    BuildContext context, List<dynamic> productIds) async {
  final productsResponse = await handleGetReport(context, 'upcs');

  final Map<String, String> upcsMap = {};

  for (var p in productsResponse['Data']) {
    final productId = p['productId'];
    final upc = p['UPC'];

    if (productIds.contains(productId)) {
      if (upc == null) {
        upcsMap[productId] = 'no upc in system';
        continue;
      } else {
        upcsMap[productId] = upc;
      }
    }
  }
  return upcsMap;
}

String findScannedUpc(String scannedUpc, Map<String, dynamic> productList) {
  for (var product in productList.entries) {
    for (var p in product.value) {
      if (p['upc'] == scannedUpc) {
        return p['upc'];
      }
    }
  }
  return 'not found';
}

String verifyScannedUnitId(
    String scannedUnitId, String upc, Map<String, dynamic> productList) {
  if (scannedUnitId.startsWith('N') || scannedUnitId.startsWith('n')) {
    scannedUnitId = scannedUnitId.substring(1);
  }

  for (var product in productList.entries) {
    for (var p in product.value) {
      if (p['upc'].toString() == upc &&
          p['unitId'].toString() == scannedUnitId) {
        return 'verified unit id: $scannedUnitId';
      }
    }
  }
  return 'incorrect unit id';
}

String verifyScannedQuantity(String scannedUnitId, String upc, String quantity,
    Map<String, dynamic> productList) {
  print('scannedUnitId: $scannedUnitId');
  print('upc: $upc');
  print('quantity: $quantity');
  for (var product in productList.entries) {
    for (var p in product.value) {
      if (p['upc'].toString() == upc &&
          p['unitId'].toString() == scannedUnitId &&
          p['quantity'].toString() == quantity) {
        return 'quantity verified';
      }
    }
  }
  return 'incorrect quantity';
}

Map<String, dynamic> updateVerifiedStatus(String scannedUnitId, String upc,
    String quantity, Map<String, dynamic> productList) {
  for (var product in productList.entries) {
    for (var p in product.value) {
      if (p['upc'].toString() == upc &&
          p['unitId'].toString() == scannedUnitId &&
          p['quantity'].toString() == quantity) {
        p['verified'] = true;
      }
    }
  }
  print('productList: $productList');
  return productList;
}

String convertToCsv(Map<String, dynamic> groupedProducts,
    Map<String, dynamic> pickSlipDetails) {
  List<List<dynamic>> rows = [];

  // adding header row
  rows.add(['Pick Slip ID', 'Order ID', 'OrderDate']);

  // adding pick slip details
  rows.add([
    pickSlipDetails['pickSlipId'],
    pickSlipDetails['orderId'],
    pickSlipDetails['orderDate']
  ]);

  // adding header row
  rows.add(['Product ID', 'UPC', 'Unit ID', 'Quantity', 'Verified']);

  // extracting the data
  for (var product in groupedProducts.entries) {
    for (var p in product.value) {
      rows.add([
        p['productId'],
        p['upc'],
        p['unitId'],
        p['quantity'],
        p['verified']
      ]);
    }
  }

  String csv = rows.map((row) => row.join(',')).join('\n');
  print(csv);
  return csv;
}
