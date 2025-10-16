abstract class BaseEntity {
  final int id;

  BaseEntity(this.id);
}

abstract class BaseOTP {
  final String phone;

  BaseOTP({
    required this.phone,
  });
}

abstract class BaseProduct {
  final int id;
  final String name;
  final String unitPrice;
  final String salePrice;
  final String shopName;
  final String imageName;
  final double discount;
  final String brandName;
  final String categoryName;
  final int unitId;
  final String unitName;
  final String description;

  BaseProduct({
    required this.id,
    required this.name,
    required this.brandName,
    required this.categoryName,
    required this.description,
    required this.discount,
    required this.imageName,
    required this.salePrice,
    required this.shopName,
    required this.unitPrice,
    required this.unitName,
    required this.unitId,
  });
}

abstract class BaseShop {
  final int id;
  final String name;
  final String contactNumber;
  final double lat;
  final double lng;
  final String addressText;
  final String description;
  final String logo;
  final String cover;

  const BaseShop({
    required this.id,
    required this.name,
    required this.contactNumber,
    this.lat = 0,
    this.lng = 0,
    this.addressText = '',
    this.description = '',
    this.logo = '',
    this.cover = '',
  });
}
