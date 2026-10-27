import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/create_quick_count_screen.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/create_physical_count_screen.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/create_bin_count_screen.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_offline_cubit.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/cubit/bin_count_offline_cubit.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_find_stock_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_cycle_count_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_offline_cubit.dart';
import 'package:wms_mobile/feature/unit_of_measurement/presentation/cubit/uom_group_offline_cubit.dart';

const definitions = [
  {'AlternateUoM': 1, 'BaseQuantity': 1, 'AlternateQuantity': 1}
];
const modes = ['quick_count', 'cycle_count', 'physical_count', 'bin_count'];
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
    temp = await Directory.systemTemp.createTemp('counting_ui');
    Hive.init(temp.path);
    for (final name in [
      ...modes,
      'bin',
      'item',
      'item_barcode',
      'item_find_stock',
      'item_cycle_count',
      'uom',
      'uom_group'
    ]) {
      await Hive.openBox(name);
    }
    await Hive.box('item').put('data', [
      {
        'ItemCode': 'ITEM1',
        'ItemName': 'Test Item',
        'UoMGroupEntry': 1,
        'InventoryUoMEntry': 1,
        'InventoryUOM': 'EA',
        'ManageSerialNumbers': 'tNO',
        'ManageBatchNumbers': 'tNO'
      }
    ]);
    await Hive.box('bin').put('data', [
      {'AbsEntry': 11, 'BinCode': 'BIN1', 'Warehouse': 'W1'}
    ]);
    await Hive.box('item_find_stock').put('data', [
      {'ItemCode': 'ITEM1', 'WhsCode': 'W1', 'BinID': 11, 'OnHandQty': 10.5}
    ]);
    await Hive.box('item_cycle_count').put('data', [
      {'ItemCode': 'ITEM1', 'WhsCode': 'W1', 'CostingCode': 'A'}
    ]);
    await Hive.box('uom').put('data', [
      {'AbsEntry': 1, 'Code': 'EA', 'Name': 'Each'}
    ]);
    await Hive.box('uom_group').put('data', [
      {'AbsEntry': 1, 'BaseUoM': 1, 'UoMGroupDefinitionCollection': definitions}
    ]);
  });
  tearDown(() async {
    await Hive.close();
    await temp.delete(recursive: true);
  });

  Future<dynamic> open(WidgetTester tester, String mode,
      {dynamic edit, Size size = const Size(1100, 1400)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final Widget screen = switch (mode) {
      'physical_count' => CreatePhysicalCountScreen(isEdit: edit),
      'bin_count' => CreateBinCountScreen(isEdit: edit),
      _ => CreateQuickCountScreen(
          isQuickCount: mode == 'quick_count', isEdit: edit),
    };
    await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ItemOfflineCubit()),
          BlocProvider(create: (_) => ItemBarcodeOfflineCubit()),
          BlocProvider(create: (_) => ItemFindStockOfflineCubit()),
          BlocProvider(create: (_) => ItemCycleCountOfflineCubit()),
          BlocProvider(create: (_) => UOMOfflineCubit()),
          BlocProvider(create: (_) => UOMGroupOfflineCubit()),
          BlocProvider(create: (_) => BinOfflineCubit()),
          BlocProvider(create: (_) => QuickCountOfflineCubit()),
          BlocProvider(create: (_) => CycleCountOfflineCubit()),
          BlocProvider(create: (_) => PhysicalCountOfflineCubit()),
          BlocProvider(create: (_) => BinCountOfflineCubit()),
        ],
        child: ResponsiveSizer(
            builder: (_, __, ___) => MaterialApp(home: screen))));
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byWidget(screen));
    if (mode == 'physical_count' && edit == null) {
      state.onSetCosTemp({
        'DocumentEntry': 20,
        'DocumentNumber': 200,
        'InventoryCountingLines': [
          {
            'ItemCode': 'ITEM1',
            'ItemDescription': 'Test Item',
            'WarehouseCode': 'W1',
            'UoMCode': 'EA',
            'UoMEntry': 1,
            'BinEntry': 11,
            'CountedQuantity': 0,
            'Counted': 'tNO',
            'InWarehouseQuantity': 10.5,
            'CostingCode': 'A',
            'InventoryCountingLineUoMs': []
          }
        ]
      });
      await tester.pumpAndSettle();
    }
    return state;
  }

  Future<void> edit(WidgetTester tester, dynamic state) async {
    state.onEdit(state.items.first, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Item'));
    await tester.pumpAndSettle();
  }

  Future<void> draft(WidgetTester tester, dynamic state, String count) async {
    if (state.items.isNotEmpty) await edit(tester, state);
    state.itemCode.text = 'ITEM1';
    state.itemName.text = 'Test Item';
    state.uom.text = 'EA';
    state.uomAbEntry.text = '1';
    state.quantity.text = count;
    state.binId.text = '11';
    state.binCode.text = 'BIN1';
    state.inWhsQty.text = '10.5';
    state.uoMGroupDefinitionCollection.text = jsonEncode(definitions);
    state.onAddItem();
    await tester.pumpAndSettle();
  }

  for (final mode in modes) {
    testWidgets('$mode: dimensions, row edit, cancel and decimal variance',
        (tester) async {
      final dynamic state = await open(tester, mode);
      state.onHeaderDimensionChange(1, 'A', 'Operations');
      await draft(tester, state, '2.5');
      expect(state.items.single['CostingCode'], 'A');
      expect(state.items.single['Variance'], '-8');
      await edit(tester, state);
      await tester.ensureVisible(find.text('Operations').first);
      await tester.tap(find.text('Operations').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sales'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Update Item'));
      await tester.tap(find.text('Update Item'));
      await tester.pumpAndSettle();
      expect(state.items.single['CostingCode'], 'B');
      await edit(tester, state);
      state.quantity.text = '9';
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(state.items.single['Quantity'], '2.5');
      state.onHeaderDimensionChange(1, 'A', 'Operations');
      await tester.pumpAndSettle();
      expect(state.items.single['CostingCode'], 'A');
      expect(tester.takeException(), isNull);
    });
    testWidgets('$mode: zero count and dimensions save and reopen',
        (tester) async {
      final dynamic state = await open(tester, mode);
      state.onHeaderDimensionChange(1, 'B', 'Sales');
      state.onHeaderDimensionChange(5, 'REGION', 'Region');
      await draft(tester, state, '0');
      await tester.runAsync(() async {
        await tester.tap(find.text('Save (1)'));
        await Hive.box(mode).flush();
      });
      await tester.pumpAndSettle();
      final data = Hive.box(mode).get('data');
      expect(data, isNotNull,
          reason: tester
              .widgetList<Text>(find.byType(Text))
              .map((text) => text.data)
              .join(' | '));
      final saved = Map<String, dynamic>.from((data as List).single);
      final key = mode == 'quick_count' || mode == 'cycle_count'
          ? 'InventoryPostingLines'
          : 'InventoryCountingLines';
      final row = saved[key].single;
      expect(row['CountedQuantity'], '0');
      expect(row['CostingCode'], 'B');
      expect(row['CostingCode5'], 'REGION');
      expect(row['BinEntry'], '11');
      expect(row['InWarehouseQuantity'], 10.5);
      if (key == 'InventoryPostingLines') expect(row['Variance'], -10.5);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      final dynamic reopened = await open(tester, mode, edit: saved);
      expect(reopened.items.single['CostingCode'], 'B');
      expect(find.text('Sales'), findsOneWidget);
      await edit(tester, reopened);
      expect(reopened.binId.text, '11');
      expect(reopened.inWhsQty.text, '10.5');
      expect(tester.takeException(), isNull);
    });
    testWidgets('$mode: phone layout and right aligned collapse arrows',
        (tester) async {
      final dynamic state =
          await open(tester, mode, size: const Size(390, 844));
      final arrow =
          find.byWidgetPredicate((widget) => widget is AnimatedRotation).at(1);
      expect(tester.getCenter(arrow).dx, greaterThan(330));
      await tester.tap(find.text('General Information'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('hdr_chip')), findsNothing);
      state.inWhsQty.text = '10.5';
      final quantityField = find.byWidgetPredicate((widget) =>
          widget is TextFormField && widget.controller == state.quantity);
      await tester.ensureVisible(quantityField);
      await tester.enterText(quantityField, '2.5');
      await tester.pumpAndSettle();
      expect(state.variance.text, '-8');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('cycle saves a genuine zero but excludes an uncounted row',
      (tester) async {
    await tester.runAsync(() async {
      await Hive.box('item_cycle_count').put('data', [
        {'ItemCode': 'ITEM1', 'WhsCode': 'W1', 'CostingCode': 'A'},
        {'ItemCode': 'ITEM1', 'WhsCode': 'W1', 'CostingCode': 'B'},
      ]);
    });
    final dynamic state = await open(tester, 'cycle_count');
    expect(state.items, hasLength(2));
    expect(state.items[1]['Quantity'], isNull);
    await draft(tester, state, '0');
    await tester.runAsync(() async {
      state.onPostToSAP();
      await Hive.box('cycle_count').flush();
    });
    await tester.pumpAndSettle();
    final rows =
        Hive.box('cycle_count').get('data').single['InventoryPostingLines'];
    expect(rows, hasLength(1));
    expect(rows.single['CountedQuantity'], '0');
    expect(tester.takeException(), isNull);
  });

  testWidgets('bin picker refreshes warehouse stock and decimal variance',
      (tester) async {
    final dynamic state = await open(tester, 'bin_count');
    state.itemCode.text = 'ITEM1';
    state.quantity.text = '2.5';
    state.onChangeBin();
    await tester.pumpAndSettle();
    await tester.tap(find.text('BIN1').last);
    await tester.pumpAndSettle();
    expect(state.binId.text, '11');
    expect(state.inWhsQty.text, '10.5');
    expect(state.variance.text, '-8');
    expect(tester.takeException(), isNull);
  });
}
