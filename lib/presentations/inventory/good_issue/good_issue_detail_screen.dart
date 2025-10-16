import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/presentations/inventory/good_Issue/component/general.dart';
import 'package:wms_mobile/presentations/inventory/good_Issue/create_screen/good_Issue_create_screen.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/dio_client.dart';

/// Flutter code sample for [TabBar].

class GoodIssueDetailScreens extends StatefulWidget {
  final Map<String, dynamic> giById;
  const GoodIssueDetailScreens({super.key, required this.giById});
  @override
  State<GoodIssueDetailScreens> createState() => _GoodIssueDetailScreensState();
}

class _GoodIssueDetailScreensState extends State<GoodIssueDetailScreens>
    with TickerProviderStateMixin {
  final DioClient dio = DioClient();
  int check = 0;
  Map<String, dynamic> data = {};
  List<dynamic> _seriesList = [];
  List<dynamic> _employee = [];
  List<dynamic> _giTypeList = [];
  List<dynamic> _binLocationList = [];

  Future<void> getById() async {
    try {
      final response =
          await dio.get('/InventoryGenExits(${widget.giById["DocEntry"]})');
      await getLabelApi();
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            data.addAll(response.data);
            check = 1;
          });
        }
      } else {
        throw ServerFailure(message: response.data['msg']);
      }
    } on Failure {
      rethrow;
    }
  }

  Future<void> getLabelApi() async {
    Map<String, dynamic> payload = {
      'DocumentTypeParams': {'Document': '60'},
    };
    await dio
        .post('/SeriesService_GetDocumentSeries', data: payload)
        .then((res) => {
              if (mounted)
                {
                  setState(() {
                    _seriesList.addAll(res.data["value"]);
                  })
                }
            })
        .catchError((e) => throw e);
    await dio
        .get('/EmployeesInfo?\$select=EmployeeID,LastName,FirstName')
        .then((res) => {
              if (mounted)
                {
                  setState(() {
                    _employee.addAll(res.data["value"]);
                  })
                }
            })
        .catchError((e) => throw e);
    await dio
        .get('/LK_OIGE?\$select=Name,Code')
        .then((res) => {
              if (mounted)
                {
                  setState(() {
                    _giTypeList.addAll(res.data["value"]);
                  })
                }
            })
        .catchError((e) => throw e);
    await dio
        .get('/sml.svc/BIZ_BIN_QUERY?\$select=BinCode,BinID')
        .then((res) => {
              if (mounted)
                {
                  setState(() {
                    _binLocationList.addAll(res.data["value"]);
                  })
                }
            })
        .catchError((e) => throw e);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getById();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 17, 18, 48),
        title: GestureDetector(
          child: const Text(
            'Good Issue',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_rounded),
            onPressed: () {
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text(
                          'Sync To SAP',
                          style: TextStyle(fontSize: 18),
                        ),
                        content: Row(
                          children: const [
                            Text('Are you sure want to sync this to'),
                            SizedBox(width: 5),
                            Text(
                              'SAP ?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('No',
                                style: TextStyle(color: Colors.black)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: Container(
                                width: 75,
                                height: 30,
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 17, 18, 48),
                                    borderRadius: BorderRadius.circular(4)),
                                child: const Center(
                                    child: Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.white),
                                ))),
                          ),
                        ],
                      ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 230,
                    color: const Color.fromARGB(255, 237, 236, 236),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);

                              showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: const Text(
                                          'Good Issue',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        content: SizedBox(
                                          width: double.infinity,
                                          height: 120,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                  'Closing a document is irreversible. Document '
                                                  'status will be change to "Closed" and a clearing'
                                                  'transactions will be created.'),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Text("Do you want to continue ?")
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context, 'Cancel'),
                                            child: const Text('No',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'OK'),
                                            child: Container(
                                                width: 75,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 17, 18, 48),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                child: const Center(
                                                    child: Text(
                                                  'Yes',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ))),
                                          ),
                                        ],
                                      ));
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  border: Border(
                                    left: BorderSide(
                                      color: Color.fromARGB(255, 200, 196, 196),
                                      width: 0.5,
                                    ),
                                    bottom: BorderSide(
                                      color: Color.fromARGB(255, 188, 183, 183),
                                      width: 0.5,
                                    ),
                                    right: BorderSide(
                                      color: Color.fromARGB(255, 192, 188, 188),
                                      width: 0.5,
                                    ),
                                    top: BorderSide(
                                      color: Color.fromARGB(255, 192, 188, 188),
                                      width: 0.5,
                                    ),
                                  )),
                              child: const Center(
                                  child: Text(
                                "Close",
                                style: TextStyle(fontSize: 15),
                              )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  border: Border(
                                    left: BorderSide(
                                      color: Color.fromARGB(255, 200, 196, 196),
                                      width: 0.5,
                                    ),
                                    bottom: BorderSide(
                                      color: Color.fromARGB(255, 188, 183, 183),
                                      width: 0.5,
                                    ),
                                    right: BorderSide(
                                      color: Color.fromARGB(255, 192, 188, 188),
                                      width: 0.5,
                                    ),
                                  )),
                              child: const Center(
                                  child: Text(
                                "Cancel Good Issue ",
                                style: TextStyle(fontSize: 15),
                              )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  border: Border(
                                    left: BorderSide(
                                      color: Color.fromARGB(255, 200, 196, 196),
                                      width: 0.5,
                                    ),
                                    bottom: BorderSide(
                                      color: Color.fromARGB(255, 188, 183, 183),
                                      width: 0.5,
                                    ),
                                    right: BorderSide(
                                      color: Color.fromARGB(255, 192, 188, 188),
                                      width: 0.5,
                                    ),
                                  )),
                              child: const Center(
                                  child: Text(
                                "Duplicate",
                                style: TextStyle(fontSize: 15),
                              )),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  border: Border(
                                    left: BorderSide(
                                      color: Color.fromARGB(255, 200, 196, 196),
                                      width: 0.5,
                                    ),
                                    bottom: BorderSide(
                                      color: Color.fromARGB(255, 188, 183, 183),
                                      width: 0.5,
                                    ),
                                    right: BorderSide(
                                      color: Color.fromARGB(255, 192, 188, 188),
                                      width: 0.5,
                                    ),
                                    top: BorderSide(
                                      color: Color.fromARGB(255, 192, 188, 188),
                                      width: 0.5,
                                    ),
                                  )),
                              child: const Center(
                                  child: Text(
                                "Cancel",
                                style: TextStyle(fontSize: 15),
                              )),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      body: check == 0
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2.5,
              ),
            )
          : Stack(
              children: [
                General(
                    giTypeList: _giTypeList,
                    employee: _employee,
                    seriesList: _seriesList,
                    gHeader: data,
                    binlocationList: _binLocationList),
                Positioned(
                    bottom: 30,
                    right: 30,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GoodIssueCreateScreen(
                                  id: true,
                                  dataById: data,
                                  seriesList: _seriesList,
                                  listIssueType: _giTypeList,
                                  employeeList: _employee,
                                  binlocationList: _binLocationList)),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 111, 115, 119),
                                blurRadius: 10,
                                offset: Offset(2, 5), // Shadow position
                              ),
                            ],
                            color: const Color.fromARGB(255, 17, 18, 48),
                            borderRadius: BorderRadius.circular(100.0)),
                        width: 60,
                        height: 60,
                        child: Center(
                            child: SvgPicture.asset(
                          "images/svg/edit.svg",
                          color: Colors.white,
                        )),
                      ),
                    ))
              ],
            ),
    );
  }
}
