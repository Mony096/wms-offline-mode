import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/create_good_receipt_screen.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/good_receipt_po_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/presentation/cubit/quick_good_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/purchase_order/presentation/cubit/purchase_order_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_offline_cubit.dart';

const definitions = [
  {'AlternateUoM': 1, 'BaseQuantity': 1, 'AlternateQuantity': 1}
];
Map<String, dynamic> po() => {
      'DocEntry': 10,
      'DocNum': 100,
      'CardCode': 'S1',
      'CardName': 'Supplier',
      'DocumentLines': [
        {
          'ItemCode': 'ITEM1',
          'ItemDescription': 'Test Item',
          'UoMEntry': 1,
          'UoMCode': 'EA',
          'LineNum': 2,
          'LineStatus': 'bost_Open',
          'RemainingOpenQuantity': 10.0,
          'CostingCode': 'A'
        }
      ]
    };
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({
      'warehouse': 'W1',
      'warehouseName': 'Main Warehouse',
      'dimension_v2': jsonEncode([
        {
          'DimensionCode': 1,
          'DimensionDescription': 'Department',
          'IsActive': 'tYES',
          'rules': [
            {'FactorCode': 'A', 'FactorDescription': 'Operations'},
            {'FactorCode': 'B', 'FactorDescription': 'Sales'}
          ]
        }
      ])
    });
    temp = await Directory.systemTemp.createTemp('receipt_ui');
    Hive.init(temp.path);
    for (final name in [
      'bin',
      'item',
      'item_barcode',
      'uom_group',
      'uom',
      'purchase_order',
      'quick_goods_receipt',
      'goods_receipt_po'
    ]) {
      await Hive.openBox(name);
    }
    await Hive.box('item').put('data', [
      {
        'ItemCode': 'ITEM1',
        'ItemName': 'Test Item',
        'UoMGroupEntry': 1,
        'ManageSerialNumbers': 'tNO',
        'ManageBatchNumbers': 'tNO'
      }
    ]);
    await Hive.box('uom_group').put('data', [
      {'AbsEntry': 1, 'BaseUoM': 1, 'UoMGroupDefinitionCollection': definitions}
    ]);
    await Hive.box('uom').put('data', [
      {'AbsEntry': 1, 'Code': 'EA', 'Name': 'Each'}
    ]);
    await Hive.box('purchase_order').put('data', [po()]);
  });
  tearDown(() async {
    await Hive.close();
    await temp.delete(recursive: true);
  });
  Future<dynamic> open(WidgetTester tester, bool quick,
      {dynamic edit, Size size = const Size(1100, 1400)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ItemOfflineCubit()),
          BlocProvider(create: (_) => ItemBarcodeOfflineCubit()),
          BlocProvider(create: (_) => UOMOfflineCubit()),
          BlocProvider(create: (_) => UOMGroupOfflineCubit()),
          BlocProvider(create: (_) => BinOfflineCubit()),
          BlocProvider(create: (_) => PurchaseOrderOfflineCubit()),
          BlocProvider(create: (_) => QuickGoodReceiptOfflineCubit()),
          BlocProvider(create: (_) => GoodReceiptPoOfflineCubit()),
        ],
        child: ResponsiveSizer(
            builder: (_, __, ___) => MaterialApp(
                home: CreateGoodReceiptPOScreen(
                    quickReceipt: quick,
                    po: quick || edit != null ? null : po(),
                    isEdit: edit)))));
    await tester.pumpAndSettle();
    return tester.state(find.byType(CreateGoodReceiptPOScreen));
  }

  void add(dynamic state) {
    state.itemCode.text = 'ITEM1';
    state.itemName.text = 'Test Item';
    state.uom.text = 'EA';
    state.uomAbEntry.text = '1';
    state.quantity.text = '3';
    state.uoMGroupDefinitionCollection.text = jsonEncode(definitions);
    state.onAddItem();
  }

  Future<void> editFirst(WidgetTester tester, dynamic state) async {
    state.onEdit(state.items.first, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Item'));
    await tester.pumpAndSettle();
  }

  for (final quick in [true, false]) {
    final mode = quick ? 'Quick' : 'PO';
    testWidgets('$mode: dimension override, cancel and header propagation',
        (tester) async {
      final dynamic state = await open(tester, quick);
      state.onHeaderDimensionChange(1, 'A', 'Operations');
      if (quick) add(state);
      await tester.pumpAndSettle();
      expect(state.items.first['CostingCode'], 'A');
      await editFirst(tester, state);
      await tester.ensureVisible(find.text('Operations').first);
      await tester.tap(find.text('Operations').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sales'));
      await tester.pumpAndSettle();
      state.quantity.text = '3';
      await tester.ensureVisible(find.text('Update Item'));
      await tester.tap(find.text('Update Item'));
      await tester.pumpAndSettle();
      expect(state.items.first['CostingCode'], 'B');
      await editFirst(tester, state);
      state.quantity.text = '8';
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(state.items.first['Quantity'], '3');
      expect(state.items.first['CostingCode'], 'B');
      state.onHeaderDimensionChange(1, 'A', 'Operations');
      await tester.pumpAndSettle();
      expect(state.items.first['CostingCode'], 'A');
      expect(tester.takeException(), isNull);
    });
    testWidgets(
        '$mode: offline save and reopen retain dimensions and PO references',
        (tester) async {
      final dynamic state = await open(tester, quick);
      state.onHeaderDimensionChange(1, 'B', 'Sales');
      if (quick) {
        state.cardCode.text = 'S1';
        state.cardName.text = 'Supplier';
        add(state);
      } else {
        await editFirst(tester, state);
        state.quantity.text = '3';
        state.onAddItem();
      }
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Save (1)'));
        await Hive.box(quick ? 'quick_goods_receipt' : 'goods_receipt_po')
            .flush();
        await Hive.box('purchase_order').flush();
      });
      await tester.pumpAndSettle();
      final data = Hive.box(quick ? 'quick_goods_receipt' : 'goods_receipt_po')
          .get('data');
      expect(data, isNotNull,
          reason: tester
              .widgetList<Text>(find.byType(Text))
              .map((t) => t.data)
              .join(' | '));
      final saved = Map<String, dynamic>.from((data as List).single);
      expect(saved['DocumentLines'].single['CostingCode'], 'B');
      expect(saved['DocumentLines'].single.containsKey('CostingCodeName'),
          isFalse);
      if (!quick) {
        expect(saved['DocumentLines'].single['BaseLine'].toString(), '2');
        expect(saved['DocumentLines'].single['BaseEntry'], 10);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      final dynamic reopened = await open(tester, quick, edit: saved);
      expect(reopened.items.single['CostingCode'], 'B');
      expect(find.text('Sales'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('phone layout and delete confirmation', (tester) async {
    final dynamic state = await open(tester, false, size: const Size(390, 844));
    expect(find.text('Open QTY'), findsOneWidget);
    state.onEdit(state.items.first, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Item'));
    await tester.pumpAndSettle();
    expect(state.items.length, 1);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(state.items.length, 1);
    state.onEdit(state.items.first, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(state.items, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
