import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/core/enum/global.dart';
import 'package:http/http.dart' as http;
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<dynamic> goTo<T extends Widget>(BuildContext context, T route,
    {bool removeAllPreviousRoutes = false}) async {
  if (removeAllPreviousRoutes) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => route),
      (route) => false,
    );
  } else {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (bulider) => route));
    return result;
  }
}

String getDataFromDynamic(dynamic value, {bool isDate = false}) {
  try {
    if (value == null) return '';

    if (isDate) {
      return (value as String).split('T')[0];
    }

    if (value is int) return value.toString();

    if (value is double) return value.toStringAsFixed(2);

    return value;
  } catch (e) {
    return '';
  }
}

String getDataFromDynamicBin(dynamic value, {bool isDate = false}) {
  try {
    if (value == null) return 'NO BINLOCATION';

    if (isDate) {
      return (value as String).split('T')[0];
    }

    if (value is int) return value.toString();

    if (value is double) return value.toStringAsFixed(2);

    return value;
  } catch (e) {
    return 'No BinLocation';
  }
}

String getDataFromDynamicO(dynamic value, {bool isDate = false}) {
  try {
    if (value == null) return '0';
    if (value == "") return '0';
    if (isDate) {
      return (value as String).split('T')[0];
    }

    if (value is int) return value.toString();

    if (value is double) return value.toStringAsFixed(2);

    return value;
  } catch (e) {
    return '0';
  }
}

String getItemTypeQueryString(ItemType type) {
  switch (type) {
    case ItemType.sale:
      return "SalesItem eq 'tYES'";
    case ItemType.purchase:
      return "PurchaseItem eq 'tYES'";
    case ItemType.inventory:
      return "InventoryItem eq 'tYES'";
    default:
      throw Exception('Invalid item type');
  }
}

String getBPTypeQueryString(BusinessPartnerType type) {
  switch (type) {
    case BusinessPartnerType.vendor:
      return "CardType eq 'cSupplier'";
    case BusinessPartnerType.supplier:
      return "CardType eq 'cSupplier'";
    case BusinessPartnerType.customer:
      return "CardType eq 'cCustomer'";
    default:
      throw Exception('Invalid BusinessPartner type');
  }
}

String fractionDigits(double value, {int digit = 4}) {
  final formatter = NumberFormat('0.${'0' * digit}', 'en_US');
  return formatter.format(value).replaceAll(',', '');
}

String convertQuantityUoM(double baseQty, double alternativeQty, double qty) {
  String totalQty = fractionDigits(baseQty / alternativeQty, digit: 6);
  return fractionDigits(qty * double.parse(totalQty), digit: 4);
}

String formatBalance(dynamic value) {
  try {
    double parsedValue = 0.0;
    if (value is double) {
      parsedValue = value;
    } else if (value is int) {
      parsedValue = value.toDouble();
    } else if (value != null) {
      parsedValue = double.parse(value.toString());
    } else {
      return '0.00';
    }
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(parsedValue);
  } catch (e) {
    return '0.00';
  }
}

String formatQuantity(dynamic value) {
  try {
    double parsedValue = 0.0;
    if (value is double) {
      parsedValue = value;
    } else if (value is int) {
      parsedValue = value.toDouble();
    } else if (value != null && value.toString().isNotEmpty) {
      // Remove commas before parsing in case it's already formatted
      parsedValue = double.parse(value.toString().replaceAll(',', ''));
    } else {
      return '0';
    }
    final formatter = NumberFormat('#,##0.######', 'en_US');
    return formatter.format(parsedValue);
  } catch (e) {
    return '0';
  }
}

double parseQuantity(dynamic value) {
  if (value == null || value.toString().isEmpty) return 0.0;
  try {
    return double.parse(value.toString().replaceAll(',', ''));
  } catch (e) {
    return 0.0;
  }
}

Future<dynamic> postToSAP({
  required String host,
  required String port,
  required String token,
  required String endpoint,
  required dynamic body,
}) async {
  try {
    // 🧠 Build the full URL
    final uri = Uri.parse('$host:$port/b1s/v1/$endpoint');

    // 🧠 Log for debugging
    debugPrint('📡 [SAP POST] Endpoint: /b1s/v1/$endpoint');
    debugPrint('📤 [Body] ${jsonEncode(body)}');
    debugPrint('🌐 [Full URL] $uri');

    // Send POST request
    final response = await http.post(
      uri,
      headers: {
        "Cookie": "B1SESSION=$token; ROUTEID=.node3",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    // 🧾 Check response
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('✅ [SAP POST Success] ${response.statusCode}');
      return jsonDecode(response.body);
    } else {
      debugPrint(
          '❌ [SAP POST Failed] → ${response.statusCode}: ${response.body}');
      throw Exception(
          'SAP POST request failed: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    debugPrint('⚠️ [SAP POST Error] $e');
    rethrow;
  }
}

Future<dynamic> getFromSAP({
  required String host,
  required String port,
  required String token,
  required String endpoint,
  Map<String, String>? queryParams,
}) async {
  try {
    // Build query string
    final queryString = _buildQueryString(queryParams);
    final uri = Uri.parse('$host:$port/b1s/v1/$endpoint$queryString');

    // 🧠 Log for debugging
    debugPrint('📡 [SAP GET] Endpoint: /b1s/v1/$endpoint');
    if (queryString.isNotEmpty) {
      debugPrint('🔍 [Query Params] $queryString');
    }
    debugPrint('🌐 [Full URL] $uri');

    // Send GET request
    final response = await http.get(uri, headers: {
      "Cookie": "B1SESSION=$token; ROUTEID=.node3",
      "Content-Type": "application/json",
    });

    // Check response
    if (response.statusCode == 200) {
      debugPrint('✅ [SAP GET Success] ${response.statusCode}');
      return jsonDecode(response.body);
    } else {
      debugPrint(
          '❌ [SAP GET Failed] → ${response.statusCode}: ${response.body}');
      throw Exception('SAP GET request failed: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('⚠️ [SAP GET Error] $e');
    rethrow;
  }
}

// Helper to build query string manually
String _buildQueryString(Map<String, String>? params) {
  if (params == null || params.isEmpty) return '';
  final query = params.entries
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');
  return '?$query';
}

Map<String, dynamic>? findFullItemInformation(
    BuildContext context, String itemCode) {
  try {
    final itemList = context.read<ItemOfflineCubit>().state;

    // Find the item
    final matchedItem = itemList.firstWhere(
      (e) => e['ItemCode'] == itemCode,
      orElse: () => null,
    );

    if (matchedItem == null) {
      MaterialDialog.warning(
        context,
        title: 'Oops.',
        body: "Item not found",
      );
      return null;
    }

    // Find UoM group
    final uomGroupCubit = context.read<UOMGroupOfflineCubit>();
    final uomGroup = uomGroupCubit.state.firstWhere(
      (u) => u['AbsEntry'] == matchedItem['UoMGroupEntry'],
      orElse: () => {},
    );

    // Merge item info with UoM group info
    final Map<String, dynamic> itemMapped = {
      ...matchedItem,
      "BaseUoM": uomGroup['BaseUoM'],
      "UoMGroupDefinitionCollection": uomGroup['UoMGroupDefinitionCollection'],
    };

    return itemMapped;
  } catch (e) {
    debugPrint('⚠️ [findFullItemInformation Error] $e');
    return null;
  }
}

Future<bool> hasInternet() async {
  // 1. Check basic network connection state (Wi-Fi, Mobile, Ethernet, etc.)
  final connectivityResult = await (Connectivity().checkConnectivity());

  // Check if *any* type of connection is present.
  // Note: connectivity_plus returns a List<ConnectivityResult> since version 5.0.0
  // but many tutorials still use the old style.
  // Let's adapt for the modern version which returns a List:
  final isConnected = connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi) ||
      connectivityResult.contains(ConnectivityResult.ethernet) ||
      connectivityResult.contains(ConnectivityResult.vpn);

  if (!isConnected) {
    // No active network interface is found
    return false;
  }

  // 2. Perform a deeper check: Ping an external reliable server (like Google)
  //    to confirm actual internet access (not just a connection to a local router).
  try {
    // Attempt to lookup a known domain.
    // Setting a short timeout is often wise in real-world apps (e.g., .timeout(Duration(seconds: 5))).
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));

    if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
      // Lookup was successful and returned at least one IP address
      return true;
    }
  } on SocketException catch (_) {
    // The lookup failed, indicating no actual internet access.
    return false;
  } on TimeoutException catch (_) {
    // The lookup timed out.
    return false;
  }

  // Failsafe return, though the logic above should cover all cases.
  return false;
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String text = newValue.text;
    if (text.startsWith('.')) {
      text = '0' + text;
    }
    if (RegExp(r'[^0-9.]').hasMatch(text.replaceAll(',', ''))) {
      return oldValue;
    }
    if (text.split('.').length > 2) {
      return oldValue;
    }
    List<String> parts = text.replaceAll(',', '').split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.' + parts[1] : '';

    String formattedInteger = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) {
        formattedInteger = ',' + formattedInteger;
      }
      formattedInteger = integerPart[i] + formattedInteger;
      count++;
    }

    String formattedText = formattedInteger + decimalPart;
    int cursorOffset = newValue.selection.end +
        (formattedText.length - newValue.text.length);
    if (cursorOffset < 0) cursorOffset = 0;
    if (cursorOffset > formattedText.length) cursorOffset = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}

String getWarehouseName(BuildContext context, String warehouseCode) {
  try {
    final whsState = context.read<WarehouseOfflineCubit>().state;
    final matched = whsState.firstWhere((w) => w['WarehouseCode'] == warehouseCode, orElse: () => {});
    return matched.isNotEmpty && matched['WarehouseName'] != null ? matched['WarehouseName'] : warehouseCode;
  } catch (e) {
    return warehouseCode;
  }
}


void showJsonDialog(BuildContext context, Map<dynamic, dynamic> record) {
  final data = Map<String, dynamic>.from(record);
  data.remove('SaveId');
  data.remove('status');
  data.remove('error');
  data.remove('timestamp');
  
  final jsonString = const JsonEncoder.withIndent('  ').convert(data);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payload JSON', style: TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonString));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(jsonString, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
