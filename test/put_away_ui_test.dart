import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/create_put_away_screen.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/cubit/put_away_offline_cubit.dart';
import 'package:wms_mobile/feature/inbound/put_away/presentation/cubit/put_away_failed_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_offline_cubit.dart';

const definitions = [
  {'AlternateUoM': 1, 'BaseQuantity': 1, 'AlternateQuantity': 1}
];
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
      'failed_put_away',
      'put_away'
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
    await Hive.box('bin').put('data', [
      {'AbsEntry': 11, 'BinCode': 'SOURCE', 'Warehouse': 'W1'},
      {'AbsEntry': 12, 'BinCode': 'TARGET', 'Warehouse': 'W1'},
      {'AbsEntry': 13, 'BinCode': 'OTHER', 'Warehouse': 'W2'},
    ]);
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
          BlocProvider(create: (_) => PutAwayFailedOfflineCubit()),
          BlocProvider(create: (_) => PutAwayOfflineCubit()),
        ],
        child: ResponsiveSizer(
            builder: (_, __, ___) =>
                MaterialApp(home: CreatePutAwayScreen(isEdit: edit)))));
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(CreatePutAwayScreen));
    return state;
  }

  Future<void> editFirst(WidgetTester tester, dynamic state) async {
    state.onEdit(state.items.first, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Item'));
    await tester.pumpAndSettle();
  }

  void addLine(dynamic state, {bool tracked = false}) {
    state.itemCode.text = 'ITEM1';
    state.itemName.text = 'Test Item';
    state.uom.text = 'EA';
    state.uomAbEntry.text = '1';
    state.quantity.text = '2.5';
    state.sbinId.text = '11';
    state.sbinCode.text = 'SOURCE';
    state.tbinId.text = '12';
    state.tbinCode.text = 'TARGET';
    state.uoMGroupDefinitionCollection.text = jsonEncode(definitions);
    if (tracked) {
      state.isBatch.text = 'tYES';
      state.batchesInput.text = jsonEncode([
        {'BatchNumber': 'BATCH1', 'Quantity': '2.5'}
      ]);
    }
    state.onAddItem();
  }

  Future<Map<String, dynamic>> save(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.tap(find.text('Save (1)'));
      await Hive.box('put_away').flush();
    });
    await tester.pumpAndSettle();
    final data = Hive.box('put_away').get('data');
    expect(data, isNotNull,
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data)
            .join(' | '));
    return Map<String, dynamic>.from((data as List).single);
  }

  testWidgets('header dimensions, row override and cancel preserve both bins',
      (tester) async {
    final dynamic state = await open(tester);
    state.onHeaderDimensionChange(1, 'A', 'Operations');
    addLine(state);
    await tester.pumpAndSettle();
    expect(state.items.single['CostingCode'], 'A');
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
    expect(state.items.single['CostingCode'], 'B');
    expect(state.items.single['SBinId'], '11');
    expect(state.items.single['TBinId'], '12');
    await editFirst(tester, state);
    state.quantity.text = '8';
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(state.items.single['Quantity'], '3');
    state.onHeaderDimensionChange(1, 'A', 'Operations');
    await tester.pumpAndSettle();
    expect(state.items.single['CostingCode'], 'A');
    expect(tester.takeException(), isNull);
  });

  for (final tracked in [false, true]) {
    testWidgets(
        'save/reopen dimensions and ${tracked ? 'batch' : 'ordinary'} bin allocations',
        (tester) async {
      await tester.runAsync(() async {
        final item =
            Map<String, dynamic>.from(Hive.box('item').get('data').single);
        item['ManageBatchNumbers'] = tracked ? 'tYES' : 'tNO';
        await Hive.box('item').put('data', [item]);
      });
      final dynamic state = await open(tester);
      state.onHeaderDimensionChange(1, 'B', 'Sales');
      addLine(state, tracked: tracked);
      await tester.pumpAndSettle();
      final saved = await save(tester);
      final row = saved['StockTransferLines'].single;
      expect(row['DistributionRule'], 'B');
      expect(row.containsKey('CostingCode'), isFalse);
      expect(row['Quantity'], '2.5');
      expect(saved['FromWarehouse'], 'W1');
      expect(saved['ToWarehouse'], 'W1');
      final allocations = row['StockTransferLinesBinAllocations'] as List;
      expect(allocations, hasLength(2));
      expect(allocations[0]['BinActionType'], 'batFromWarehouse');
      expect(allocations[0]['BinAbsEntry'], '11');
      expect(allocations[1]['BinActionType'], 'batToWarehouse');
      expect(allocations[1]['BinAbsEntry'], '12');
      if (tracked) {
        expect(row['BatchNumbers'].single['BatchNumber'], 'BATCH1');
      }
      // Reopening identifies direction by allocation type, even if records are reordered.
      row['StockTransferLinesBinAllocations'] = allocations.reversed.toList();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      final dynamic reopened = await open(tester, edit: saved);
      expect(reopened.items.single['CostingCode'], 'B');
      expect(find.text('Sales'), findsOneWidget);
      expect(reopened.items.single['SBinId'], '11');
      expect(reopened.items.single['TBinId'], '12');
      await editFirst(tester, reopened);
      expect(reopened.sbinCode.text, 'SOURCE');
      expect(reopened.tbinCode.text, 'TARGET');
      expect(reopened.isSerialOrBatch, tracked);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'phone layout, right aligned arrow and warehouse filtered bin picker',
      (tester) async {
    final dynamic state = await open(tester, size: const Size(390, 844));
    final arrow =
        find.byWidgetPredicate((widget) => widget is AnimatedRotation).at(1);
    expect(tester.getCenter(arrow).dx, greaterThan(330));
    await tester.tap(find.text('General Information'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hdr_chip')), findsNothing);
    state.onChangeSBin();
    await tester.pumpAndSettle();
    expect(find.text('OTHER'), findsNothing);
    await tester.tap(find.text('SOURCE').last);
    await tester.pumpAndSettle();
    expect(state.sbinId.text, '11');
    expect(tester.takeException(), isNull);
  });
}
