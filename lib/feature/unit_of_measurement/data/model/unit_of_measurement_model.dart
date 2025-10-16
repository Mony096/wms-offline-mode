import 'package:wms_mobile/feature/unit_of_measurement/domain/entity/unit_of_measurement_entity.dart';
import 'package:wms_mobile/helper/helper.dart';

class UnitOfMeasurementModel extends UnitOfMeasurementEntity {
  @override
  final int id;
  @override
  final String code;
  @override
  final String name;

  UnitOfMeasurementModel({
    required this.id,
    required this.code,
    required this.name,
  }) : super(
          code: code,
          name: name,
          id: id,
        );

  factory UnitOfMeasurementModel.fromJson(Map<String, dynamic> json) =>
      UnitOfMeasurementModel(
        id: json["AbsEntry"],
        code: json["Code"],
        name: getDataFromDynamic(json["Name"]),
      );
}
