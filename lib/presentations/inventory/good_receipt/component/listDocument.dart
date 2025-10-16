import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wms_mobile/component/blockList.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/presentations/inventory/good_issue/good_issue_detail_screen.dart';
import 'package:wms_mobile/presentations/inventory/good_receipt/good_receipt_detail_screen.dart';
import 'package:wms_mobile/utilies/dialog/dialog.dart';
import 'package:wms_mobile/utilies/dio_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wms_mobile/utilies/formart.dart';

class ListDocument extends StatefulWidget {
  final RefreshController refreshController;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final int check;
  List<dynamic> data = [];
  ListDocument(
      {Key? key,
      required this.refreshController,
      required this.onRefresh,
      required this.onLoading,
      required this.check,
      required this.data})
      : super(key: key);

  @override
  State<ListDocument> createState() => _ListDocumentState();
}

class _ListDocumentState extends State<ListDocument> {
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      controller: widget.refreshController,
      onRefresh: widget.onRefresh,
      onLoading: widget.onLoading,
      child: widget.check == 0
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2.5,
              ),
            )
          : widget.data.isEmpty
              ? Container(
                  child: const Center(
                      child: Text(
                    "No Record",
                    style: TextStyle(fontSize: 15),
                  )),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  shrinkWrap: true,
                  itemCount: widget.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoodReceiptDetailScreens(
                              giById: widget.data[index],
                            ),
                          ),
                        );
                      },
                      child: BlockList(
                        colorStatus: Color.fromARGB(255, 101, 106, 109),
                        name:
                            "${widget.data[index]["DocNum"]} - ${widget.data[index]["Comments"] == '' || widget.data[index]["Comments"] == null ? 'No Comments' : widget.data[index]["Comments"]}",
                        date: splitDate(widget.data[index]["DocDate"]),
                        status: widget.data[index]["U_tl_whsdesc"] ?? "N/A",
                        qty: "50/300",
                      ),
                    );
                  },
                ),
    );
  }
}
