import 'package:flutter/material.dart';
import 'package:wms_mobile/component/blockList.dart';
import 'package:wms_mobile/presentations/inventory/good_issue/good_issue_detail_screen.dart';


class ListOffLineDocument extends StatefulWidget {
  const ListOffLineDocument({super.key});

  @override
  State<ListOffLineDocument> createState() => _ListOffLineDocumentState();
}

class _ListOffLineDocumentState extends State<ListOffLineDocument> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 236, 233, 233),
      height: double.infinity,
      width: double.infinity,
      child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          shrinkWrap: true,
          itemCount: 4,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GoodIssueDetailScreens(giById: {},)),
                );
              },
              child: const BlockList(
                name: "230010455 - Chea Narath",
                date: "23-3-2023",
                status: "OPEN",
                qty: "50/300", colorStatus:Colors.blue,
              ),
            );
          }),
    );
  }
}
