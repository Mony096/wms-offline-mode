import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/create_purchase_return_screen.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/cubit/purchase_return_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return/presentation/cubit/purchase_return_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/purchase_return_request/presentation/cubit/purchase_return_request_offline_cubit.dart';
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
      'purchase_return_request',
      'failed_purchase_return',
      'purchase_return'
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
    await Hive.box('purchase_return_request').put('data', [po()]);
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
          BlocProvider(create: (_) => PurchaseReturnRequestOfflineCubit()),
          BlocProvider(create: (_) => PurchaseReturnFailedOfflineCubit()),
          BlocProvider(create: (_) => PurchaseReturnOfflineCubit()),
        ],
        child: ResponsiveSizer(
            builder: (_, __, ___) =>
                MaterialApp(home: CreatePurchaseReturnScreen(isEdit: edit)))));
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(CreatePurchaseReturnScreen));
    if (edit == null) {
      state.loadPurchaseReturnRequest(po());
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
      await Hive.box('purchase_return').flush();
      await Hive.box('purchase_return_request').flush();
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
    final records = Hive.box('purchase_return').get('data') as List;
    expect(records, hasLength(1));
    final saved = Map<String, dynamic>.from(records.single);
    final row = saved['DocumentLines'].single;
    expect(row['CostingCode'], 'B');
    expect(row.containsKey('CostingCodeName'), isFalse);
    expect(row['Quantity'], '2.5');
    expect(row['BaseEntry'], '10');
    expect(row['BaseLine'].toString(), '2');
    expect(row['BaseType'], 234000032);
    expect(
        Hive.box('purchase_return_request')
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
    expect(Hive.box('purchase_return').get('data'), hasLength(1));
    expect(
        Hive.box('purchase_return_request')
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
  testWidgets(
      'same item on separate document lines keeps the correct base line',
      (tester) async {
    final dynamic state = await open(tester);
    final request = po();
    final first = Map<String, dynamic>.from(request['DocumentLines'].first);
    request['DocumentLines'] = [
      first,
      {...first, 'LineNum': 6, 'CostingCode': 'B'}
    ];
    await tester.runAsync(() async {
      await Hive.box('purchase_return_request').put('data', [request]);
    });
    state.loadPurchaseReturnRequest(request);
    await tester.pumpAndSettle();
    expect(state.items, hasLength(2));
    state.onEdit(state.items[1], 1);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Item'));
    await tester.pumpAndSettle();
    state.quantity.text = '2.5';
    state.onAddItem();
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Save (2)'));
      await Hive.box('purchase_return').flush();
      await Hive.box('purchase_return_request').flush();
    });
    await tester.pumpAndSettle();
    final saved = Hive.box('purchase_return').get('data').single;
    expect(saved['DocumentLines'].single['BaseLine'].toString(), '6');
    expect(saved['DocumentLines'].single['CostingCode'], 'B');
    final lines =
        Hive.box('purchase_return_request').get('data').single['DocumentLines'];
    expect(lines[0]['RemainingOpenQuantity'], 10.0);
    expect(lines[1]['RemainingOpenQuantity'], 7.5);
    expect(tester.takeException(), isNull);
  });
  testWidgets('outbound batch quantity and allocation survive row editing',
      (tester) async {
    await tester.runAsync(() async {
      final item =
          Map<String, dynamic>.from(Hive.box('item').get('data').single);
      item['ManageBatchNumbers'] = 'tYES';
      await Hive.box('item').put('data', [item]);
    });
    final dynamic state = await open(tester);
    await editFirst(tester, state);
    expect(state.isSerialOrBatch, isTrue);
    state.quantity.text = '2.5';
    state.binId.text = '11';
    state.binCode.text = 'BIN1';
    state.batchesInput.text = jsonEncode([
      {'BatchNumber': 'BATCH1', 'Quantity': '2.5'}
    ]);
    state.onAddItem();
    await tester.pumpAndSettle();
    await save(tester);
    final row =
        Hive.box('purchase_return').get('data').single['DocumentLines'].single;
    expect(row['BatchNumbers'].single['BatchNumber'], 'BATCH1');
    expect(row['DocumentLinesBinAllocations'].single['BinAbsEntry'], '11');
    expect(
        row['DocumentLinesBinAllocations']
            .single['SerialAndBatchNumbersBaseLine'],
        0);
    expect(double.parse(row['DocumentLinesBinAllocations'].single['Quantity']),
        2.5);
    expect(tester.takeException(), isNull);
  });
}
