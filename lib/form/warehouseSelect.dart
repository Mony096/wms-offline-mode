import 'package:flutter/material.dart';
import 'package:wms_mobile/component/listItemDrop.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/utilies/dio_client.dart';

class WarehouseSelect extends StatefulWidget {
  WarehouseSelect({Key? key, this.indBack, this.branchId, this.allWH})
      : super(
          key: key,
        );
  final indBack;
  final branchId;
  final allWH;
  @override
  State<WarehouseSelect> createState() => _WarehouseSelectState();
}

class _WarehouseSelectState extends State<WarehouseSelect> {
  int a = 1;
  int selectedRadio = -1;
  final DioClient dio = DioClient();
  int check = 0;
  List<dynamic> data = [];

  Future<void> getList() async {
    try {
      final response = await dio.get('/Warehouses', query: {
        '\$select': "WarehouseCode,WarehouseName,BusinessPlaceID",
      });

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            check = 1;
            List<dynamic> responseData = response.data['value'];
            if (widget.branchId != null) {
              data = responseData
                  .where((e) => e['BusinessPlaceID'] == widget.branchId)
                  .toList();
            } else if (widget.allWH == "true") {
              data = response.data['value'];
            } else {
              data = [];
            }
          });
        }
      } else {
        throw ServerFailure(message: response.data['msg']);
      }
    } on Failure {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    getList();
    setState(() {
      selectedRadio = widget.indBack;
      print(widget.branchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(238, 16, 50, 171),
        title: const Text(
          'Warehouse',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 10),
          Icon(Icons.sort),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Expanded(
              child: check == 0
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2.5,
                      ),
                    )
                  : data.isEmpty
                      ? Container(
                          child: Center(
                              child: Text(
                            "No Record",
                            style: TextStyle(fontSize: 15),
                          )),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                             bool isLastIndex = index == data.length - 1;
                            return ListItem(
                                lastIndex: isLastIndex, 
                                twoRow: false,
                                index: index,
                                selectedRadio: selectedRadio,
                                onSelect: (value) {
                                  setState(() {
                                    selectedRadio = value;
                                  });
                                },
                                desc: data[index]["WarehouseCode"] +
                                        ' - ' +
                                        data[index]["WarehouseName"] ??
                                    "",
                                code: "");
                          },
                        ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 17, 18, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    final op = {
                      "name": data[selectedRadio]["WarehouseCode"] ,
                      "value": data[selectedRadio]["WarehouseCode"],
                      "index": selectedRadio
                    };
                    if (selectedRadio != -1) {
                      Navigator.pop(context, op);
                    } else {
                      Navigator.pop(context, null);
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
