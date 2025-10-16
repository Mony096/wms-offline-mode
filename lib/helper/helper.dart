import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/core/enum/global.dart';

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
