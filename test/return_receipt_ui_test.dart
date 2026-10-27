import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/create_return_receipt_screen.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/cubit/return_receipt_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/presentation/cubit/return_receipt_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/return_receipt_request/presentation/cubit/return_receipt_request_offline_cubit.dart';
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
      'CardCode': 'C1',
      'CardName': 'Customer',
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
      'return_receipt_request',
      'return_receipt_failed',
      'return_receipt'
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
    await Hive.box('return_receipt_request').put('data', [po()]);
  });
  tearDown(() async {
    await Hive.close();
    await temp.delete(recursive: true);
  });
  Future<dynamic> open(WidgetTester tester,
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
          BlocProvider(create: (_) => ReturnReceiptRequestOfflineCubit()),
          BlocProvider(create: (_) => ReturnReceiptFailedOfflineCubit()),
          BlocProvider(create: (_) => ReturnReceiptOfflineCubit()),
        ],
        child: ResponsiveSizer(
            builder: (_, __, ___) =>
                MaterialApp(home: CreateReturnReceiptScreen(isEdit: edit)))));
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(CreateReturnReceiptScreen));
    if (edit == null) {
      state.loadReturnReceiptRequest(po());
      await tester.pumpAndSettle();
    }
    return state;
  }

  Future<void> editFirst(WidgetTester tester, dynamic state) async {
    state.onEdit(state.items.first, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Item'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.tap(find.text('Save (1)'));
      await Hive.box('return_receipt').flush();
      await Hive.box('return_receipt_request').flush();
    });
    await tester.pumpAndSettle();
  }

  testWidgets(
      'request dimensions, line override, cancel and header propagation',
      (tester) async {
    final dynamic state = await open(tester);
    expect(state.items.single['CostingCode'], 'A');
    expect(find.text('Operations'), findsOneWidget);
    await editFirst(tester, state);
    await tester.ensureVisible(find.text('Operations').first);
    await tester.tap(find.text('Operations').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sales'));
    await tester.pumpAndSettle();
    state.quantity.text = '2.5';
    await tester.ensureVisible(find.text('Update Item'));
    await tester.tap(find.text('Update Item'));
    await tester.pumpAndSettle();
    expect(state.items.single['CostingCode'], 'B');
    await editFirst(tester, state);
    state.quantity.text = '8';
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(state.items.single['Quantity'], '2.5');
    expect(state.docEntry.text, '10');
    state.onHeaderDimensionChange(1, 'A', 'Operations');
    await tester.pumpAndSettle();
    expect(state.items.single['CostingCode'], 'A');
    expect(tester.takeException(), isNull);
  });

  testWidgets('decimal quantities and dimensions survive saving and reopening',
      (tester) async {
    final dynamic state = await open(tester);
    state.onHeaderDimensionChange(1, 'B', 'Sales');
    await editFirst(tester, state);
    state.quantity.text = '2.5';
    state.onAddItem();
    await tester.pumpAndSettle();
    await save(tester);
    final records = Hive.box('return_receipt').get('data') as List;
    expect(records, hasLength(1));
    final saved = Map<String, dynamic>.from(records.single);
    final row = saved['DocumentLines'].single;
    expect(row['CostingCode'], 'B');
    expect(row.containsKey('CostingCodeName'), isFalse);
    expect(row['Quantity'], '2.5');
    expect(row['BaseEntry'], '10');
    expect(row['BaseLine'].toString(), '2');
    expect(row['BaseType'], 234000031);
    expect(
        Hive.box('return_receipt_request')
            .get('data')
            .single['DocumentLines']
            .single['RemainingOpenQuantity'],
        7.5);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    final dynamic reopened = await open(tester, edit: saved);
    expect(reopened.items.single['CostingCode'], 'B');
    expect(find.text('Sales'), findsOneWidget);
    // Editing the saved receipt changes only the quantity difference on the request.
    await editFirst(tester, reopened);
    reopened.quantity.text = '1.5';
    reopened.onAddItem();
    await tester.pumpAndSettle();
    await save(tester);
    expect(Hive.box('return_receipt').get('data'), hasLength(1));
    expect(
        Hive.box('return_receipt_request')
            .get('data')
            .single['DocumentLines']
            .single['RemainingOpenQuantity'],
        8.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cleared line dimension stays blank when edited again',
      (tester) async {
    final dynamic state = await open(tester);
    await editFirst(tester, state);
    await tester.ensureVisible(find.text('Operations').first);
    await tester.tap(find.text('Operations').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('None (Blank / Unselect)'));
    await tester.pumpAndSettle();
    state.quantity.text = '1';
    state.onAddItem();
    await tester.pumpAndSettle();
    expect(state.items.single['CostingCode'], '');
    await editFirst(tester, state);
    expect(find.text('Operations'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone header arrow stays right and delete needs confirmation',
      (tester) async {
    final dynamic state = await open(tester, size: const Size(390, 844));
    final arrow =
        find.byWidgetPredicate((widget) => widget is AnimatedRotation).at(1);
    expect(tester.getCenter(arrow).dx, greaterThan(330));
    await tester.tap(find.text('General Information'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hdr_chip')), findsNothing);
    state.onEdit(state.items.first, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(state.items, hasLength(1));
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
