import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/core/enum/global.dart';
import 'package:http/http.dart' as http;

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
