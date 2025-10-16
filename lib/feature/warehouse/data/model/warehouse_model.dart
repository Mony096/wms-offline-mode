import 'package:wms_mobile/helper/helper.dart';

import '/feature/warehouse/domain/entity/warehouse_entity.dart';

class Warehouse extends WarehouseEntity {
  @override
  final String code;
  final String name;
  final dynamic defBin;
  Warehouse({required this.code, required this.name, this.defBin})
      : super(code: code, name: name, defBin: defBin);

  Warehouse copyWith({String? code, String? name, dynamic defBin}) => Warehouse(
      name: name ?? this.name,
      code: code ?? this.code,
      defBin: defBin ?? this.defBin);

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
        code: json["WarehouseCode"],
        name: getDataFromDynamic(json["WarehouseName"]),
        defBin: getDataFromDynamic(json["DefaultBin"]),
      );
}
