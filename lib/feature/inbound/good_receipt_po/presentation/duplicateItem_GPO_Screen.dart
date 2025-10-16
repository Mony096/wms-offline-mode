import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_mobile/helper/helper.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import '/constant/style.dart';

class DuplicateItemGPOPage extends StatefulWidget {
  const DuplicateItemGPOPage({super.key, this.barCode, required this.items});

  final dynamic barCode;
  final List<dynamic> items;
  @override
  State<DuplicateItemGPOPage> createState() => _DuplicateItemGPOPageState();
}

class _DuplicateItemGPOPageState extends State<DuplicateItemGPOPage> {
  String query = "?\$top=100&\$select=AbsEntry,BinCode,Warehouse,Sublevel1";

  int check = -1;

  List<dynamic> data = [];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text("Duplicate ItemCode (${widget.barCode})")));
    });
    setState(() {
      print(widget.items);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY_COLOR,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Duplicate ItemCode',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      // bottomNavigationBar: MyBottomSheet(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // color: Color.fromARGB(255, 243, 243, 243),
        child: Column(
          children: [
            const Divider(thickness: 0.001, height: 15),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  bottom: BorderSide(width: 0.1),
                  top: BorderSide(width: 0.1),
                ),
              ),
              child: Row(
                children: const [
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Item No.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Text('UoM')),
                  Expanded(child: Text('Qty/Op.')),
                ],
              ),
            ),
            const Divider(thickness: 0.01, height: 10),
            Expanded(
                child: ListView(
              children: [
                ...widget.items
                    .map(
                      (i) => GestureDetector(
                        onTap: () => Navigator.of(context).pop(i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 0.1))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                   SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      getDataFromDynamic(i['ItemCode']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Text(
                                          getDataFromDynamic(i['UoMCode']))),
                                  Expanded(child: Text('${getDataFromDynamic(i['TotalQuantity'])}/${i['Quantity']}')),
                                ],
                              ),
                              SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(getDataFromDynamic(i['ItemDescription'])),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
