import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_barcode_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_find_stock_offline_cubit.dart';
import 'package:wms_mobile/feature/item/presentation/cubit/items_offline_cubit.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/screen/item_page.dart';
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_offline_cubit.dart';
import 'package:wms_mobile/feature/warehouse/presentation/cubit/warhouse_offline_cubit.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../item/presentation/cubit/item_cubit.dart';
import '/component/button/button.dart';
import '/core/enum/global.dart';
import '/feature/item/presentation/screen/item_page.dart';
import '/helper/helper.dart';
import '/utilies/dialog/dialog.dart';
import '/utilies/storage/locale_storage.dart';
// import 'package:iscan_data_plugin/iscan_data_plugin.dart';
import '../../../../constant/style.dart';
import 'cubit/product_lookup_cubit.dart';

class CreateProductLookUpScreen extends StatefulWidget {
  const CreateProductLookUpScreen({super.key});

  @override
  State<CreateProductLookUpScreen> createState() =>
      _CreateProductLookUpScreenState();
}

class _CreateProductLookUpScreenState extends State<CreateProductLookUpScreen> {
  final warehouse = TextEditingController();
  final warehouseNameUI = TextEditingController();
  final itemCode = TextEditingController();
  final itemName = TextEditingController();

  late ProductLookUpCubit _bloc;
  late ItemCubit _blocItem;
  final barCode = TextEditingController();
  final DioClient dio = DioClient();
  List<dynamic> itemCodeFilter = [];
  List<dynamic> items = [];
  List<dynamic> serialOrBatchList = [];
  bool loading = false;
  bool isClickScanItem = false;
  final FocusNode _itemCode = FocusNode();
  final FocusNode _quantity = FocusNode();
  final FocusNode _bin = FocusNode();
  @override
  void initState() {
    init();
    _bloc = context.read<ProductLookUpCubit>();
    _blocItem = context.read<ItemCubit>();

    //
    try {
      // IscanDataPlugin.methodChannel
      //     .setMethodCallHandler((MethodCall call) async {
      //   if (call.method == "onScanResults") {
      //     if (loading) return;

      //     setState(() {
      //       if (call.arguments['data'] == "decode error") return;
      //       barCode.text = call.arguments['data'];
      //       onCompleteTextEditItem();
      //     });
      //   }
      // });
    } catch (e) {
      print("Error setting method call handler: $e");
    }
    super.initState();
  }

  void init() async {
    final whs = await LocalStorageManger.getString('warehouse');
    warehouse.text = whs;
    final whsName = await LocalStorageManger.getString('warehouseName');
    warehouseNameUI.text = whsName.isNotEmpty ? whsName : warehouse.text;
  }

  void onSelectItem() async {
    goTo(context, ItemPage(type: ItemType.inventory)).then((value) {
      if (value == null) return;

      onSetItemTemp(value);
    });
  }

  // void onCompleteTextEditItem() async {
  //   try {
  //     if (itemCode.text == '') return;

  //     //
  //     MaterialDialog.loading(context);
  //     final item = await _blocItem.find("('${itemCode.text}')");
  //     if (getDataFromDynamic(item['PurchaseItem']) == '' ||
  //         getDataFromDynamic(item['PurchaseItem']) == 'tNO') {
  //       throw Exception('${itemCode.text} is not purchase item.');
  //     }
  //     if (mounted) {
  //       MaterialDialog.close(context);
  //     }

  //     onSetItemTemp(item);
  //   } catch (e) {
  //     if (mounted) {
  //       MaterialDialog.close(context);
  //       if (e is ServerFailure) {
  //         MaterialDialog.success(context, title: 'Failed', body: e.message);
  //       }
  //     }
  //   }
  // }
  void onCompleteTextEditItem() async {
    try {
      if (barCode.text == '') return;
      // Get all offline barcode data
      final barcodeList = context.read<ItemBarcodeOfflineCubit>().state;

      // Find matching barcodes
      final matchedBarcodes =
          barcodeList.where((e) => e['BarCode'] == barCode.text).toList();

      if (matchedBarcodes.isEmpty) {
        clear();
        MaterialDialog.success(context, title: 'Oops.', body: "No Item");
        return;
      }

      if (matchedBarcodes.length > 1) {
        for (var element in matchedBarcodes) {
          itemCodeFilter.add(element['ItemCode']);
        }

        goTo(
          context,
          ItemByCodePage(
            type: ItemType.purchase,
            itemCode: itemCodeFilter
                .map((item) => "ItemCode eq '$item'")
                .join(' or '),
          ),
        ).then((value) {
          if (value == null) return;
          if (mounted) MaterialDialog.close(context);
          onSetItemTemp(value);
        });

        return;
      }

      // Only one barcode match
      final first = matchedBarcodes.first;
      final itemList = context.read<ItemOfflineCubit>().state;
      final matchedItem = itemList.firstWhere(
          (e) => e['ItemCode'] == first['ItemCode'],
          orElse: () => null);

      if (matchedItem == null) {
        MaterialDialog.success(context, title: 'Oops.', body: "Item not found");
        return;
      }

      onSetItemTemp(matchedItem);
    } catch (e) {
      if (mounted) {
        MaterialDialog.close(context);
        if (e is ServerFailure) {
          MaterialDialog.warning(context, title: 'Failed', body: e.message);
        } else {
          MaterialDialog.warning(context, title: 'Failed', body: e.toString());
        }
      }
    }
  }
  // void onChangeBin() async {
  //   goTo(context, BinPage(warehouse: warehouse.text)).then((value) {
  //     if (value == null) return;

  //     binId.text = getDataFromDynamic((value as BinEntity).id);
  //     binCode.text = getDataFromDynamic(value.code);
  //   });
  // }

  void onGetItem() async {
    try {
      MaterialDialog.loading(context);

      // Add a smooth 2 second loading delay for better UX
      await Future.delayed(const Duration(seconds: 1));

      final itemStockCubit = context.read<ItemFindStockOfflineCubit>();
      final batchListCubit = context.read<BatchListOfflineCubit>();

      // Get offline stock data
      final itemStockList = itemStockCubit.getJsonData();

      // Step 1: Find item in offline stock list
      final matchedItemStock = itemStockList
          .where(
            (item) =>
                (itemCode.text.isEmpty || item['ItemCode'] == itemCode.text) &&
                item['WhsCode'] == warehouse.text,
          )
          .toList();

      if (matchedItemStock.isEmpty) {
        setState(() {
          items = [];
          serialOrBatchList = [];
        });
        MaterialDialog.close(context);
        MaterialDialog.success(context, title: 'Oops.', body: "No Items");
        return;
      }

      List<dynamic> allSerialsOrBatches = [];

      for (var itemData in matchedItemStock) {
        final isSerialOrBatch =
            itemData["IsSerial"] == "Y" || itemData["IsBatch"] == "Y";

        if (isSerialOrBatch) {
          // Get offline batch/serial data
          final batchList = batchListCubit.getJsonData();
          final matchedSerialOrBatch = batchList
              .where(
                (b) =>
                    b['ItemCode'] == itemData['ItemCode'] &&
                    b['WhsCode'] == warehouse.text,
              )
              .toList();
          allSerialsOrBatches.addAll(matchedSerialOrBatch);
        }
      }

      setState(() {
        items = matchedItemStock;
        serialOrBatchList = allSerialsOrBatches;
      });

      MaterialDialog.close(context);
    } catch (e) {
      if (mounted) {
        MaterialDialog.close(context);
        MaterialDialog.success(context, title: 'Error.', body: e.toString());
      }
    }
  }

  void clear() {
    itemCode.text = '';
    itemName.text = '';
  }

  void onChangeWhs() {
    List<dynamic> whs = [];
    try {
      final cubit = context.read<WarehouseOfflineCubit>();
      cubit.loadData();
      whs = cubit.state;
    } catch (_) {}
    if (whs.isEmpty) {
      try {
        final box = Hive.box('warehouse');
        whs = box.get('data', defaultValue: []).cast<dynamic>();
      } catch (_) {}
    }

    _openGenericPickerModal<dynamic>(
      title: 'Select Warehouse',
      subtitle: 'Destination warehouse',
      icon: Icons.warehouse_outlined,
      items: whs,
      currentCode: warehouse.text,
      getCode: (item) {
        final c = getDataFromDynamic(item['WarehouseCode']);
        return c.isNotEmpty ? c : getDataFromDynamic(item['code']);
      },
      getName: (item) {
        final n = getDataFromDynamic(item['WarehouseName']);
        return n.isNotEmpty ? n : getDataFromDynamic(item['name']);
      },
      allowClear: false,
      onSelected: (item) {
        if (item == null) return;
        final code = getDataFromDynamic(item['WarehouseCode']).isNotEmpty
            ? getDataFromDynamic(item['WarehouseCode'])
            : getDataFromDynamic(item['code']);
        final name = getDataFromDynamic(item['WarehouseName']).isNotEmpty
            ? getDataFromDynamic(item['WarehouseName'])
            : getDataFromDynamic(item['name']);
        warehouse.text = code;
        warehouseNameUI.text = name.isNotEmpty ? name : code;
        setState(() {});
      },
    );
  }

  void _openGenericPickerModal<T>({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<T> items,
    required String currentCode,
    required String Function(T item) getCode,
    required String Function(T item) getName,
    String Function(T item)? getExtraInfo,
    bool showCode = true,
    bool allowClear = false,
    String clearLabel = 'None (Blank / Unselect)',
    required void Function(T? selectedItem) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomCtx) {
        String query = '';
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            final q = query.trim().toLowerCase();
            final filteredList = items.where((item) {
              if (q.isEmpty) return true;
              final code = getCode(item).toLowerCase();
              final name = getName(item).toLowerCase();
              final extra =
                  getExtraInfo != null ? getExtraInfo(item).toLowerCase() : '';
              return code.contains(q) || name.contains(q) || extra.contains(q);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomCtx).viewInsets.bottom,
              ),
              child: Material(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: MediaQuery.of(bottomCtx).size.height * 0.75,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 8),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: PRIMARY_COLOR.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                size: 20,
                                color: PRIMARY_COLOR,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: AppFontSize.dialogTitle,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (subtitle.isNotEmpty)
                                    Text(
                                      subtitle,
                                      style: TextStyle(
                                        fontSize: AppFontSize.md,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              color: Colors.grey.shade600,
                              onPressed: () => Navigator.of(bottomCtx).pop(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: searchCtrl,
                            onChanged: (val) {
                              setModalState(() {
                                query = val;
                              });
                            },
                            style: TextStyle(fontSize: AppFontSize.input),
                            decoration: InputDecoration(
                              hintText: 'Search by code or description...',
                              hintStyle: TextStyle(
                                  fontSize: AppFontSize.hint,
                                  color: Colors.grey.shade500),
                              prefixIcon: Icon(Icons.search_rounded,
                                  size: 20, color: Colors.grey.shade500),
                              suffixIcon: query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded,
                                          size: 18),
                                      onPressed: () {
                                        searchCtrl.clear();
                                        setModalState(() {
                                          query = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, thickness: 0.5),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          children: [
                            if (allowClear &&
                                (q.isEmpty ||
                                    'none'.contains(q) ||
                                    'blank'.contains(q) ||
                                    'clear'.contains(q))) ...[
                              ListTile(
                                dense: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                tileColor: currentCode.isEmpty
                                    ? PRIMARY_COLOR.withValues(alpha: 0.06)
                                    : null,
                                leading: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: currentCode.isEmpty
                                        ? PRIMARY_COLOR
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.block_rounded,
                                    size: 16,
                                    color: currentCode.isEmpty
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                title: Text(
                                  clearLabel,
                                  style: TextStyle(
                                    fontSize: AppFontSize.value,
                                    fontWeight: currentCode.isEmpty
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: currentCode.isEmpty
                                        ? PRIMARY_COLOR
                                        : const Color(0xFF334155),
                                  ),
                                ),
                                trailing: currentCode.isEmpty
                                    ? const Icon(Icons.check_circle_rounded,
                                        color: PRIMARY_COLOR, size: 20)
                                    : null,
                                onTap: () {
                                  onSelected(null);
                                  Navigator.of(bottomCtx).pop();
                                },
                              ),
                              const Divider(height: 8, thickness: 0.5),
                            ],
                            if (filteredList.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.search_off_rounded,
                                          size: 40,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 8),
                                      Text(
                                        q.isEmpty
                                            ? 'No items found'
                                            : 'No items matching "$query"',
                                        style: TextStyle(
                                            fontSize: AppFontSize.label,
                                            color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...filteredList.map((item) {
                                final code = getCode(item);
                                final name = getName(item);
                                final extra = getExtraInfo != null
                                    ? getExtraInfo(item)
                                    : '';
                                final isSelected = currentCode.isNotEmpty &&
                                    currentCode == code;

                                return ListTile(
                                  dense: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  tileColor: isSelected
                                      ? PRIMARY_COLOR.withValues(alpha: 0.06)
                                      : null,
                                  leading: showCode && code.isNotEmpty
                                      ? Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 90),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? PRIMARY_COLOR
                                                : const Color(0xFFF1F5F9),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            code,
                                            style: TextStyle(
                                              fontSize: AppFontSize.badge,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF1E293B),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        )
                                      : null,
                                  title: Text(
                                    name.isNotEmpty ? name : code,
                                    style: TextStyle(
                                      fontSize: AppFontSize.value,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? PRIMARY_COLOR
                                          : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: extra.isNotEmpty
                                      ? Text(
                                          extra,
                                          style: TextStyle(
                                            fontSize: AppFontSize.md,
                                            color: const Color(0xFF64748B),
                                          ),
                                        )
                                      : null,
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle_rounded,
                                          color: PRIMARY_COLOR, size: 20)
                                      : null,
                                  onTap: () {
                                    onSelected(item);
                                    Navigator.of(bottomCtx).pop();
                                  },
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void onSetItemTemp(dynamic value) {
    try {
      if (value == null) return;
      FocusScope.of(context).requestFocus(FocusNode());
      itemCode.text = getDataFromDynamic(value['ItemCode']);
      itemName.text = getDataFromDynamic(value['ItemName']);
    } catch (e) {
      print(e);
    }
  }

  void _requestFocus(FocusNode node) {
    if (!node.hasFocus) {
      // Use microtask for stability with fast, external keyboard input
      Future.microtask(() => node.requestFocus());
    }
  }

  void _handleScanSubmitted(String barcode, FocusNode submittedNode) {
    debugPrint("📦 Scanned Supplier Code: $barcode");

    setState(() {
      // Check which input currently has focus
      if (_itemCode.hasFocus) {
        // ✅ If filter input is focused → set scanned value
        barCode.text = barcode;
        itemCode.clear();
        onCompleteTextEditItem();
        onGetItem();

        isClickScanItem = false;
      }
    });
  }

  Widget _buildSelectorTile({
    required String label,
    required String value,
    required bool isEmpty,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.label,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: AppFontSize.value,
                        fontWeight:
                            isEmpty ? FontWeight.normal : FontWeight.w600,
                        color: isEmpty
                            ? Colors.grey.shade400
                            : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLookupScannerField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isScanning,
    required VoidCallback onChoose,
    required VoidCallback onStartScan,
    required ValueChanged<String> onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSize.label,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (isScanning)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onStartScan,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 8, right: 4, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.green.shade400, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ready to Scan',
                          style: TextStyle(
                            fontSize: AppFontSize.badge,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color:
                                Colors.green.shade800.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.close_rounded,
                            size: 11,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isScanning
                        ? Colors.green.shade600
                        : Colors.grey.shade300,
                    width: isScanning ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        readOnly: !isScanning,
                        keyboardType: TextInputType.none,
                        onTap: isScanning ? null : onChoose,
                        onFieldSubmitted: onSubmitted,
                        style: TextStyle(
                          fontSize: AppFontSize.input,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          hintText: placeholder,
                          hintStyle: TextStyle(
                            fontSize: AppFontSize.hint,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onChoose,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: PRIMARY_COLOR,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onStartScan,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: isScanning
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isScanning
                        ? Colors.green.shade600
                        : Colors.grey.shade300,
                  ),
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: isScanning ? Colors.green.shade700 : PRIMARY_COLOR,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.label,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            controller.text.isEmpty ? placeholder : controller.text,
            style: TextStyle(
              fontSize: AppFontSize.value,
              fontWeight: controller.text.isEmpty
                  ? FontWeight.normal
                  : FontWeight.w600,
              color: controller.text.isEmpty
                  ? Colors.grey.shade400
                  : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: IconThemeData(color: Colors.white),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 65),
            child: const Text(
              'Product  Lookup',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: PRIMARY_COLOR.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: PRIMARY_COLOR.withValues(alpha: 0.15),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.manage_search_rounded,
                          size: 18,
                          color: PRIMARY_COLOR,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Lookup Criteria',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppFontSize.cardTitle,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 12),
                  _buildSelectorTile(
                    label: 'Warehouse',
                    value: warehouseNameUI.text.isEmpty
                        ? 'Select Warehouse'
                        : warehouseNameUI.text,
                    isEmpty: warehouseNameUI.text.isEmpty,
                    icon: Icons.warehouse_outlined,
                    onTap: onChangeWhs,
                  ),
                  const SizedBox(height: 10),
                  _buildLookupScannerField(
                    label: 'Item Code',
                    placeholder: 'Choose or scan item code',
                    controller: itemCode,
                    focusNode: _itemCode,
                    isScanning: isClickScanItem,
                    onChoose: onSelectItem,
                    onStartScan: () {
                      setState(() {
                        isClickScanItem = !isClickScanItem;
                        if (isClickScanItem) {
                          itemCode.clear();
                          itemName.clear();
                        }
                      });
                      if (isClickScanItem) {
                        Future.delayed(const Duration(milliseconds: 100),
                            () => _requestFocus(_itemCode));
                      } else {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    onSubmitted: (value) =>
                        _handleScanSubmitted(value, _itemCode),
                  ),
                  const SizedBox(height: 10),
                  _buildReadOnlyField(
                    label: 'Description',
                    placeholder: 'Item description',
                    controller: itemName,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
              // List Header
              Container(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: PRIMARY_COLOR,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Item Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(right: 17.0),
                      child: Text(
                        'Qty',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isEmpty)
                Container(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text(
                      "No Item available",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                ),
              if (items.isNotEmpty)
                Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.fromLTRB(6, 10, 6, 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade200),
                      right: BorderSide(color: Colors.grey.shade200),
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    children: items
                        .where((f) => f["OnHandQty"] > 0)
                        .map((item) => Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Header: ItemCode + Qty badge ──
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          getDataFromDynamic(item['ItemCode']),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: PRIMARY_COLOR,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: PRIMARY_COLOR.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          formatQuantity(item['OnHandQty']),
                                          style: TextStyle(
                                            color: PRIMARY_COLOR,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  // ── Item Name ──
                                  Text(
                                    getDataFromDynamic(item['ItemName']),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Divider(
                                      height: 1, color: Colors.grey.shade200),
                                  SizedBox(height: 10),
                                  // ── Info row: Bin + UoM ──
                                  Row(
                                    children: [
                                      Icon(
                                        (item['BinCode'] == null ||
                                                item['BinCode']
                                                    .toString()
                                                    .trim()
                                                    .isEmpty)
                                            ? Icons.layers_outlined
                                            : Icons.location_on_outlined,
                                        size: 15,
                                        color: (item['BinCode'] == null ||
                                                item['BinCode']
                                                    .toString()
                                                    .trim()
                                                    .isEmpty)
                                            ? Colors.grey.shade400
                                            : PRIMARY_COLOR,
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          (item['BinCode'] == null ||
                                                  item['BinCode']
                                                      .toString()
                                                      .trim()
                                                      .isEmpty)
                                              ? 'No Bin Location'
                                              : getDataFromDynamicBin(
                                                  item['BinCode']),
                                          style: TextStyle(
                                            color: (item['BinCode'] == null ||
                                                    item['BinCode']
                                                        .toString()
                                                        .trim()
                                                        .isEmpty)
                                                ? Colors.grey.shade400
                                                : Colors.black87,
                                            fontSize: 13,
                                            fontWeight:
                                                (item['BinCode'] == null ||
                                                        item['BinCode']
                                                            .toString()
                                                            .trim()
                                                            .isEmpty)
                                                    ? FontWeight.normal
                                                    : FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (getDataFromDynamic(item['InvntryUom'])
                                          .isNotEmpty)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            getDataFromDynamic(
                                                item['InvntryUom']),
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  // ── Batch / Serial link ──
                                  if (item["IsSerial"] == "Y" ||
                                      item["IsBatch"] == "Y")
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () {
                                            try {
                                              final isBatch =
                                                  item["IsBatch"] == "Y";
                                              final list = serialOrBatchList
                                                  .where((e) =>
                                                      e["AbsEntry"] ==
                                                      item["BinID"])
                                                  .toList();
                                              _showBatchSerialDialog(
                                                  context, item, list, isBatch);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content:
                                                          Text("Error: $e")));
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  item["IsBatch"] == "Y"
                                                      ? "Batch Info"
                                                      : "Serial Info",
                                                  style: TextStyle(
                                                    color: PRIMARY_COLOR,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 11,
                                                  color: PRIMARY_COLOR,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
        child: Button(
          bgColor: PRIMARY_COLOR,
          onPressed: onGetItem,
          child: Text(
            "Search",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showBatchSerialDialog(
      BuildContext context, dynamic item, List<dynamic> list, bool isBatch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──
              Container(
                margin: EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ── Header ──
              Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 8, 12),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: PRIMARY_COLOR.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isBatch
                            ? Icons.inventory_2_outlined
                            : Icons.qr_code_2_outlined,
                        color: PRIMARY_COLOR,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBatch ? "Batch Details" : "Serial Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            getDataFromDynamic(item['ItemCode']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Total : ",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: "${list.length}",
                            style: TextStyle(
                              color: PRIMARY_COLOR,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 20, color: Colors.grey.shade500),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              // ── List ──
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isBatch
                                  ? Icons.inventory_2_outlined
                                  : Icons.qr_code_2_outlined,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 12),
                            Text("No data found.",
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16, 12, 8, 12),
                        itemCount: list.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 24, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final e = list[index];
                          return Row(
                            children: [
                              // ── Index number ──
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    // fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getDataFromDynamic(e["Batch_Serial"]),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                    if (isBatch &&
                                        getDataFromDynamic(e['ExpDate'])
                                            .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          "Exp: ${getDataFromDynamic(e['ExpDate'])}",
                                          style: TextStyle(
                                              color: Colors.red.shade400,
                                              fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: PRIMARY_COLOR.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formatQuantity(isBatch ? e['Quantity'] : 1),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: PRIMARY_COLOR),
                                ),
                              ),
                              // Spacer to align with header close button
                              SizedBox(width: 4),
                              SizedBox(width: 48),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContentHeader extends StatelessWidget {
  const ContentHeader({super.key, this.hideOpenQty});
  final dynamic hideOpenQty;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PRIMARY_COLOR, // Dark navy header
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Item / Bin Info',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'UoM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Qty',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemRow extends StatelessWidget {
  const ItemRow({super.key, required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  getDataFromDynamic(item['ItemCode']),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Text(getDataFromDynamic(item['UoMCode']))),
              Expanded(child: Text('${formatQuantity(item['Quantity'])}/0')),
            ],
          ),
          SizedBox(height: 6),
          Text(getDataFromDynamic(item['ItemDescription']))
        ],
      ),
    );
  }
}
