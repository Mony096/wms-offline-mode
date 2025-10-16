import 'package:wms_mobile/feature/bin_location/domain/entity/bin_entity.dart';
import 'package:wms_mobile/feature/good_receipt_type/domain/entity/grt_entity.dart';
import 'package:wms_mobile/helper/helper.dart';

class Grt extends GrtEntity {
  final String code;
  final String name;

  Grt({
    required this.code,
    required this.name,
  }) : super(
          code: code,
          name: name,
        );

  factory Grt.fromJson(Map<String, dynamic> json) => Grt(
        code: json["Code"],
        name: getDataFromDynamic(json["Name"]),
      );
}
