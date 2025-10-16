import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../../core/enum/global.dart';
import '../../../../utilies/dialog/dialog.dart';
import '/helper/helper.dart';
import '../cubit/item_cubit.dart';
import '/constant/style.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key, required this.type});

  final ItemType type;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final ScrollController _scrollController = ScrollController();

  String query =
      "?\$top=10&\$skip=0&\$select=ItemCode,ItemName,PurchaseItem,InventoryItem,SalesItem,InventoryUOM,UoMGroupEntry,InventoryUoMEntry,DefaultPurchasingUoMEntry,DefaultSalesUoMEntry, ManageSerialNumbers, ManageBatchNumbers";

  final int _skip = 0;
  final DioClient dio = DioClient();

  int check = 1;
  TextEditingController filter = TextEditingController();
  List<dynamic> data = [];
  late ItemCubit _bloc;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _bloc = context.read<ItemCubit>();
      final state = context.read<ItemCubit>().state;

      if (state is ItemData) {
        data = state.entities;
      }

      if (data.length == 0) {
        query = "$query&\$filter=${getItemTypeQueryString(widget.type)}";
        _bloc.get(query).then((value) {
          setState(() => data = value);
          _bloc.set(value);
        });
      }

      setState(() {
        data;
      });

      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          final state = BlocProvider.of<ItemCubit>(context).state;
          if (state is ItemData && data.length > 0) {
            _bloc
                .next(
                    "?\$top=10&\$skip=${data.length}&\$filter=${getItemTypeQueryString(widget.type)} and contains(ItemCode,'${filter.text}')")
                .then((value) {
              if (!mounted) return;
              _bloc.set([...data, ...value]);
              setState(() => data = [...data, ...value]);
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    filter.dispose();

    super.dispose();
  }

  void onFilter() async {
    setState(() {
      data = [];
    });
    _bloc
        .get(
            "$query&\$filter=${getItemTypeQueryString(widget.type)} and contains(ItemCode, '${filter.text}')",
            cache: false)
        .then((value) {
      if (!mounted) return;

      setState(() => data = value);
    });
  }

  void onFind(dynamic item) async {
    try {
      if (!mounted) return;
      // print("geting..");
      MaterialDialog.loading(context);
      // final response = await _bloc.find("('$code')");
      if (mounted) {
        final uomGroup = await dio.get(
          '/UnitOfMeasurementGroups(${item['UoMGroupEntry']})',
        );
        final itemMappde = {
          ...item,
          "BaseUoM": uomGroup.data['BaseUoM'],
          "UoMGroupDefinitionCollection":
              uomGroup.data['UoMGroupDefinitionCollection'],
        };
        MaterialDialog.close(context);

        Navigator.pop(context, itemMappde);
      }
    } catch (e) {
      if (mounted) {
        MaterialDialog.success(context,
            title: 'Invalid', body: 'Item not found ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: IconThemeData(color: Colors.white),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 70),
            child: Text(
              "Item Lists",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: MyBottomSheet(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: filter,
                      decoration: InputDecoration(
                        hintText: 'Search Item Lists',
                        filled: true,
                        fillColor:
                            Color.fromARGB(255, 243, 243, 243), // bg-slate
                        prefixIcon: Icon(Icons.search,
                            color: PRIMARY_COLOR), // left icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: PRIMARY_COLOR, width: 0.2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: PRIMARY_COLOR, // search button background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: onFilter,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // const Divider(thickness: 0.1, height: 15),
            Expanded(
              child: BlocConsumer<ItemCubit, ItemState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RequestingItem) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    controller: _scrollController,
                    children: [
                      ...data
                          .map(
                            (item) => GestureDetector(
                              onTap: () => onFind(item),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromARGB(255, 243, 243, 243),
                                ),
                                margin: const EdgeInsets.only(
                                    bottom: 8, left: 15, right: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getDataFromDynamic(item['ItemCode']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(getDataFromDynamic(item['ItemName'])),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      if (state is RequestingPaginationItem)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
