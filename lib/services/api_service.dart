import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>?> signIn(
      String username, String password, String systemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'userName': username,
        'password': password,
        'systemId': systemId,
      }),
    );

    if (response.statusCode == 200) {
      // successful API call, parse and return data
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      // handle error cases, return null or throw an exception
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    }
  }

  Future<Map<String, dynamic>> getTaskId(
      String reportName, String? token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/reports'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, String>{
        'reportName': reportName,
      }),
    );

    if (response.statusCode == 200) {
      // successful API call, parse and return data
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      // handle error cases, return null or throw an exception
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    }
  }

  Future<Map<String, dynamic>> getTaskIdStatus(
      String taskId, String token) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/reports/$taskId/status'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      // successful API call, parse and return data
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      // handle error cases, return null or throw an exception
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    }
  }

  Future<Map<String, dynamic>> getReport(String taskId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reports/$taskId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      // successful API call, parse and return data
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      // handle error cases, return null or throw an exception
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    }
  }

  Future<Map<String, dynamic>> postReceiving(
      String aisle,
      String rack,
      String level,
      String zone,
      int quantity,
      String cusId,
      String productId,
      String username,
      String password,
      String receiptDate) async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "AuthenticationHeader": {
          "Username": username,
          "Password": password,
        },
        "SingleProductInventoryReceivingWSObject": {
          "Shipments": [
            {
              "ReceiptdateTime": receiptDate,
              "UTCReceiptDateTime": receiptDate,
              "ReceivingStation": {"Description": "Main Receiving Station"},
              "ShipFrom": "",
              "ShipMethod": "",
              "FreigthBill": "",
              "CustomerReference": "",
              "ShipmentComments": "",
              "Receipts": [
                {
                  "Product": {
                    "Owner": {"ID": cusId},
                    "ProductID": productId,
                    "AutoLocate": false,
                    "SystemID": cusId
                  },
                  "ReceiptDetails": [
                    {
                      "UnitType": {"Description": "Pallet"},
                      "ContainerType": {"Description": "Carton"},
                      "PiecesPerContainer": 0,
                      "Containers": 0,
                      "Loose": quantity,
                      "Location": {
                        "Building": {"ID": "01"},
                        "Zone": {"ID": zone},
                        "Aisle": aisle,
                        "Rack": rack,
                        "Level": level
                      }
                    }
                  ]
                }
              ]
            }
          ]
        }
      }),
    ); // end of http.post

    if (response.statusCode == 200) {
      // successful API call, parse and return data
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      // handle error cases, return null or throw an exception
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    }
  }
}
