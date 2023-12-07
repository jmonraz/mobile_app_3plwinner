import 'package:flutter/material.dart';
import 'package:mobile_3plwinner/providers/api_locationreport_taskid_provider.dart';
import '../providers/api_unshipped_pick_slips_taskid_provider.dart';
import '../providers/api_warehouse_inventory_detail_taskid_provider.dart';
import '../services/api_service.dart';
import '../providers/api_key_provider.dart';
import '../providers/api_upcreport_taskid_provider.dart';
import '../providers/api_user_credentials_provider.dart';
import 'package:provider/provider.dart';

Future<Map<String, dynamic>?> handleSignIn(
    BuildContext context, String username, String password,
    {String systemId = "3plwhs"}) async {
  final apiService =
      ApiService(baseUrl: 'https://wms.3plwinner.com/veracore/public.api');
  final result = await apiService.signIn(username, password, systemId);

  // capture the BuildContext before the asynchronous operation
  final scaffoldContext = context;

  if (result != null) {
    if (result['Token'] != null) {
      final apiKey = result['Token'];
      final apiKeyProvider =
          Provider.of<ApiKeyProvider>(context, listen: false);
      apiKeyProvider.setApiKey(apiKey);
      final apiUserCredentialsProvider =
          Provider.of<ApiUserCredentialsProvider>(context, listen: false);
      apiUserCredentialsProvider.setUsername(username);
      apiUserCredentialsProvider.setPassword(password);
      final upcReportTaskId = await handleGetTaskId(context, 'upcs');
      final locationReportTaskId = await handleGetTaskId(context, 'Locations');

      print('API Response from key provider: ${apiKeyProvider.apiKey}');
      // handle successful response
      // you can navigate to a new screen, show a success message, etc.
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Sign in successful!')),
      );
    } else {
      print('API Response for null value: $result');
      // handle error response
      // you can show an error message or take other actions
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Sign in failed!')),
      );
    }
  } else {
    // handle error response
    // you can show an error message or take other actions
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      const SnackBar(content: Text('Sign in failed!')),
    );
  }
  return result;
}

Future<String?> handleGetScanVerificationReports(
    BuildContext context) async {
  final warehouseInventoryDetailTaskId =
      await handleGetTaskId(context, 'Warehouse Inventory Detail');
  final unshippedPickSlipsTaskId =
      await handleGetTaskId(context, 'unshipped pick slips');

  return 'Reports generated!';
}

Future<String?> handleGetTaskId(BuildContext context, String reportName) async {
  final apiService =
      ApiService(baseUrl: 'https://wms.3plwinner.com/veracore/public.api');
  final apiKey = Provider.of<ApiKeyProvider>(context, listen: false).apiKey;
  final response = await apiService.getTaskId(reportName, apiKey);

  Map<String, dynamic> taskIdStatus;

  if (reportName == 'upcs') {
    final apiTaskIdProvider =
        Provider.of<ApiUPCReportTaskIdProvider>(context, listen: false);
    apiTaskIdProvider.setTaskId(response['TaskId']);
    do {
      await Future.delayed(const Duration(seconds: 1));
      taskIdStatus =
          await apiService.getTaskIdStatus(response['TaskId'], apiKey!);
      print('API Response from getUPCTaskId: $response');
      if (taskIdStatus['Status'] == 'Done') {
        break;
      }
    } while (taskIdStatus['Status'] != 'Done');
  } else if (reportName == 'Locations') {
    final apiTaskIdProvider =
        Provider.of<ApiLocationReportTaskIdProvider>(context, listen: false);
    apiTaskIdProvider.setTaskId(response['TaskId']);
    do {
      await Future.delayed(const Duration(seconds: 1));
      taskIdStatus =
          await apiService.getTaskIdStatus(response['TaskId'], apiKey!);
      print('API Response from getLocationTaskId: $response');
      if (taskIdStatus['Status'] == 'Done') {
        break;
      }
    } while (taskIdStatus['Status'] != 'Done');
  } else if (reportName == 'Warehouse Inventory Detail') {
    final apiTaskIdProvider =
        Provider.of<ApiWarehouseInventoryDetailTaskIdProvider>(context,
            listen: false);
    apiTaskIdProvider.setTaskId(response['TaskId']);
    do {
      await Future.delayed(const Duration(seconds: 1));
      taskIdStatus =
          await apiService.getTaskIdStatus(response['TaskId'], apiKey!);
      print('API Response from getWarehouseInventoryDetailTaskId: $response');
      if (taskIdStatus['Status'] == 'Done') {
        break;
      }
    } while (taskIdStatus['Status'] != 'Done');
  } else if (reportName == 'unshipped pick slips') {
    final apiTaskIdProvider = Provider.of<ApiUnshippedPickSlipsTaskIdProvider>(
        context,
        listen: false);
    apiTaskIdProvider.setTaskId(response['TaskId']);
    do {
      await Future.delayed(const Duration(seconds: 1));
      taskIdStatus =
          await apiService.getTaskIdStatus(response['TaskId'], apiKey!);
      print('API Response from getUnshippedPickSlipsTaskId: $response');
      if (taskIdStatus['Status'] == 'Done') {
        break;
      }
    } while (taskIdStatus['Status'] != 'Done');
  }

  return response['TaskId'];
}

Future<Map<String, dynamic>> handleGetReport(
    BuildContext context, String reportName) async {
  final apiService =
      ApiService(baseUrl: 'https://wms.3plwinner.com/veracore/public.api');
  final apiKey = Provider.of<ApiKeyProvider>(context, listen: false).apiKey;
  String? taskId;
  if (reportName == 'upcs') {
    taskId =
        Provider.of<ApiUPCReportTaskIdProvider>(context, listen: false).taskId;
  } else if (reportName == 'Locations') {
    taskId =
        Provider.of<ApiLocationReportTaskIdProvider>(context, listen: false)
            .taskId;
  } else if (reportName == 'Warehouse Inventory Detail') {
    taskId = Provider.of<ApiWarehouseInventoryDetailTaskIdProvider>(context,
            listen: false)
        .taskId;
  } else if (reportName == 'unshipped pick slips') {
    taskId =
        Provider.of<ApiUnshippedPickSlipsTaskIdProvider>(context, listen: false)
            .taskId;
  }

  final response = await apiService.getReport(taskId!, apiKey!);

  return response;
}

Future<Map<String, dynamic>> handlePostReceiving(
    BuildContext context,
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
  final apiService = ApiService(
    baseUrl:
        'https://wms.3plwinner.com/PMWarehouse/services/InventoryReceiving.svc/SingleProductInventoryReceiving',
  );

  final result = await apiService.postReceiving(aisle, rack, level, zone,
      quantity, cusId, productId, username, password, receiptDate);

  return result;
}
