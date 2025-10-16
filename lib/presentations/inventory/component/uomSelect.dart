import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wms_mobile/component/listItemDrop.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/utilies/dio_client.dart';

class UoMSelect extends StatefulWidget {
  const UoMSelect({Key? key, this.indBack, this.item,this.qty})
      : super(
          key: key,
        );
  final indBack;
  final item;
  final qty;
  @override
  State<UoMSelect> createState() => _UoMSelectState();
}

class _UoMSelectState extends State<UoMSelect> {
  int a = 1;
  int selectedRadio = -1;
  final DioClient dio = DioClient();
  int check = 0;
  List<dynamic> data = [];
  Map<String, dynamic> uomGroupEntry = {};
  Map<String, dynamic> groups = {};
  List<dynamic> unitOfMeasGroup = [];
  List<dynamic> uomLists = [];

  String fractionDigits(double value, {int digit = 4}) {
    final formatter = NumberFormat()
      ..minimumFractionDigits = digit
      ..maximumFractionDigits = digit;

    return formatter.format(value).replaceAll(',', '');
  }

  String calculateUOM(double baseQty, double alternativeQty, double qty) {
    double totalQty = baseQty / alternativeQty;
    String formattedTotalQty = fractionDigits(totalQty, digit: 6);
    totalQty = qty * totalQty;
    return fractionDigits(totalQty, digit: 4);
  }

  Future<void> getUoMGroup(String item) async {
    try {
      final uomEntry = await dio.get("/Items('$item')", query: {
        '\$select': "UoMGroupEntry",
      });
      if (uomEntry.statusCode == 200) {
        if (mounted) {
          setState(() {
            uomGroupEntry["UoMGroupEntry"] = uomEntry.data["UoMGroupEntry"];
          });
        }
      }
      final uomGroup = await dio
          .get("/UnitOfMeasurementGroups(${uomGroupEntry["UoMGroupEntry"]})");
      if (uomGroup.statusCode == 200) {
        if (mounted) {
          setState(() {
            groups.addAll(uomGroup.data);
          });
        }
      }
    } on Failure {
      rethrow;
    }
  }

  Future<void> getUoMList() async {
    try {
      final uomlist = await dio.get("/UnitOfMeasurements", query: {
        '\$select': "Code,Name,AbsEntry",
      });
      if (uomlist.statusCode == 200) {
        if (mounted) {
          setState(() {
            uomLists.addAll(uomlist.data["value"]);
          });
        }
      }
    } on Failure {
      rethrow;
    }
  }

  Future<void> getAll() async {
    try {
      await getUoMGroup(widget.item);
      await getUoMList();
      if (widget.item != null && groups.isNotEmpty && uomLists.isNotEmpty) {
        final uomGroup = await groups["UoMGroupDefinitionCollection"]
            .map((e) => e["AlternateUoM"])
            .toList();
        final result =
            uomLists.where((e) => uomGroup.contains(e["AbsEntry"])).toList();
        setState(() {
          check = 1;
          data.addAll(result);
        });
      } else {
        data = [];
      }
    } on Failure {
      rethrow;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAll();
    setState(() {
      selectedRadio = widget.indBack;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: const Text(
          'UoM',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                  : data.length == 0
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
                                desc: data[index]["Code"] ?? "",
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
                    final selectedUoM = groups["UoMGroupDefinitionCollection"]
                        .firstWhere((e) =>
                            e["AlternateUoM"] ==
                            data[selectedRadio]["AbsEntry"]);
                    // (e: any) => e.AlternateUoM === event.target.value
                    // );
                    final op = {
                      "name": data[selectedRadio]["Code"],
                      "value": data[selectedRadio]["AbsEntry"],
                      "quantity": calculateUOM(selectedUoM["BaseQuantity"],
                          selectedUoM["AlternateQuantity"],widget.qty),
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
