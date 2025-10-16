import 'package:wms_mobile/feature/good_isuse_select/domain/entity/grt_entity.dart';
import 'package:wms_mobile/helper/helper.dart';

class GoodIssueSelect extends GoodIssueSelectEntity {
  final String code;
  final String name;

  GoodIssueSelect({
    required this.code,
    required this.name,
  }) : super(
          code: code,
          name: name,
        );

  factory GoodIssueSelect.fromJson(Map<String, dynamic> json) => GoodIssueSelect(
        code: json["Code"],
        name: getDataFromDynamic(json["Name"]),
      );
}
