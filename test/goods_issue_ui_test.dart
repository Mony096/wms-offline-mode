import 'package:wms_mobile/feature/good_isuse_select/presentation/cubit/isuse_type_offline_cubit.dart';
import 'package:wms_mobile/feature/lk_act/presentation/cubit/lk_act_offline_cubit.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:wms_mobile/feature/bin_location/presentation/cubit/bin_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/create_good_issue_screen.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/cubit/goods_issue_offline_cubit.dart';
import 'package:wms_mobile/feature/outbounce/good_issue/presentation/cubit/good_issue_failed_offline_cubit.dart';
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
      'failed_good_issue',
      'lk_act',
      'goods_issue'
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
          BlocProvider(create: (_) => GoodIssueFailedOfflineCubit()),
          BlocProvider(create: (_) => IssueTypeOfflineCubit()),
          BlocProvider(create: (_) => LkActOfflineCubit()),
          BlocProvider(create: (_) => GoodsIssueOfflineCubit()),
        ],
        child: ResponsiveSizer(
            builder: (_, __, ___) =>
                MaterialApp(home: CreateGoodIssueScreen(isEdit: edit)))));
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(CreateGoodIssueScreen));
    return state;
  }

  Future<void> editFirst(WidgetTester tester, dynamic state) async {
    state.onEdit(state.items.first, 0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Item'));
    await tester.pumpAndSettle();
  }

  void addLine(dynamic state) {
    state.giType.text = 'SA';
    state.giTypeName.text = 'Stock Adjustment';
    state.itemCode.text = 'ITEM1';
    state.itemName.text = 'Test Item';
    state.quantity.text = '2.5';
    state.uom.text = 'EA';
    state.uomAbEntry.text = '1';
    state.accountCode.text = 'GL1';
    state.binId.text = '11';
    state.binCode.text = 'SOURCE';
    state.uoMGroupDefinitionCollection.text = jsonEncode(definitions);
    state.onAddItem();
  }

  testWidgets('dimensions override, cancel and propagate across issue rows',
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
    await tester.ensureVisible(find.text('Update Item'));
    await tester.tap(find.text('Update Item'));
    await tester.pumpAndSettle();
    expect(state.items.single['CostingCode'], 'B');
    expect(state.items.single['AccountCode'], 'GL1');
    await editFirst(tester, state);
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
  testWidgets('save and reopen issue type, account, dimensions and bin',
      (tester) async {
    final dynamic state = await open(tester);
    state.onHeaderDimensionChange(1, 'B', 'Sales');
    addLine(state);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Save (1)'));
      await Hive.box('goods_issue').flush();
    });
    await tester.pumpAndSettle();
    final saved =
        Map<String, dynamic>.from(Hive.box('goods_issue').get('data').single);
    expect(saved['U_LK_Type'], 'SA');
    expect(saved['U_lk_whsdesc'], 'W1');
    final row = saved['DocumentLines'].single;
    expect(row['CostingCode'], 'B');
    expect(row['AccountCode'], 'GL1');
    expect(row['Quantity'], '2.5');
    expect(row['DocumentLinesBinAllocations'].single['BinAbsEntry'], '11');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    final dynamic reopened = await open(tester, edit: saved);
    expect(reopened.items.single['CostingCode'], 'B');
    expect(reopened.items.single['BinId'], '11');
    expect(find.text('Stock Adjustment'), findsOneWidget);
    await editFirst(tester, reopened);
    expect(reopened.accountCode.text, 'GL1');
    expect(tester.takeException(), isNull);
  });
  testWidgets('phone collapse arrows and changing issue type clears old draft',
      (tester) async {
    final dynamic state = await open(tester, size: const Size(390, 844));
    final arrow =
        find.byWidgetPredicate((widget) => widget is AnimatedRotation).at(1);
    expect(tester.getCenter(arrow).dx, greaterThan(330));
    state.onHeaderDimensionChange(1, 'A', 'Operations');
    addLine(state);
    await tester.pumpAndSettle();
    await editFirst(tester, state);
    state.onChangeGit();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Write off'));
    await tester.pumpAndSettle();
    expect(state.giType.text, 'WO');
    expect(state.items, isEmpty);
    expect(state.isEdit, -1);
    expect(state.accountCode.text, '');
    await tester.ensureVisible(find.text('General Information'));
    await tester.tap(find.text('General Information'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hdr_chip')), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('G/L account picker follows the selected issue type',
      (tester) async {
    await tester.runAsync(() async {
      await Hive.box('lk_act').put('data', [
        {
          'Code': 'SA',
          'AccountsCollection': [
            {'U_LK_Acct': 'GL1', 'AcctName': 'Adjustment Account'}
          ]
        },
        {
          'Code': 'WO',
          'AccountsCollection': [
            {'U_LK_Acct': 'GL2', 'AcctName': 'Write Off Account'}
          ]
        },
      ]);
    });
    final dynamic state = await open(tester);
    state.giType.text = 'SA';
    state.onChangeAccount();
    await tester.pumpAndSettle();
    expect(find.text('Write Off Account'), findsNothing);
    await tester.tap(find.text('Adjustment Account'));
    await tester.pumpAndSettle();
    expect(state.accountCode.text, 'GL1');
    expect(tester.takeException(), isNull);
  });
}
