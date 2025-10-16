import 'package:wms_mobile/feature/bin_location/domain/entity/bin_entity.dart';
import 'package:wms_mobile/helper/helper.dart';

class Bin extends BinEntity {
  @override
  final int id;
  @override
  final String code;
  @override
  final String warehouse;
  @override
  final String subLevel1;

  Bin({
    required this.id,
    required this.code,
    required this.warehouse,
    required this.subLevel1,
  }) : super(
          code: code,
          warehouse: warehouse,
          subLevel1: subLevel1,
          id: id,
        );

  factory Bin.fromJson(Map<String, dynamic> json) => Bin(
        id: json["AbsEntry"],
        code: json["BinCode"],
        warehouse: getDataFromDynamic(json["Warehouse"]),
        subLevel1: getDataFromDynamic(json["Sublevel1"]),
      );
}
