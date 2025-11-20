import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/business.dart';

class BusinessModel extends Business {
  const BusinessModel({
    super.id,
    required super.name,
    required super.place,
    required super.category,
    super.vatNumber,
    super.vatExpiryDate,
    super.vatImagePath,
    super.licenseNumber,
    super.licenseExpiryDate,
    super.licenseImagePath,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BusinessModel.fromMap(Map<String, dynamic> map) {
    return BusinessModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      place: map['place'] as String,
      category: map['category'] as String,
      vatNumber: map['vat_number'] as String?,
      vatExpiryDate: map['vat_expiry_date'] != null
          ? DateFormatter.parseFromDatabase(map['vat_expiry_date'] as String)
          : null,
      vatImagePath: map['vat_image_path'] as String?,
      licenseNumber: map['license_number'] as String?,
      licenseExpiryDate: map['license_expiry_date'] != null
          ? DateFormatter.parseFromDatabase(
              map['license_expiry_date'] as String)
          : null,
      licenseImagePath: map['license_image_path'] as String?,
      createdAt: DateFormatter.parseFromDatabase(map['created_at'] as String),
      updatedAt: DateFormatter.parseFromDatabase(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'place': place,
      'category': category,
      'vat_number': vatNumber,
      'vat_expiry_date': vatExpiryDate != null
          ? DateFormatter.formatForDatabase(vatExpiryDate!)
          : null,
      'vat_image_path': vatImagePath,
      'license_number': licenseNumber,
      'license_expiry_date': licenseExpiryDate != null
          ? DateFormatter.formatForDatabase(licenseExpiryDate!)
          : null,
      'license_image_path': licenseImagePath,
      'created_at': DateFormatter.formatForDatabase(createdAt),
      'updated_at': DateFormatter.formatForDatabase(updatedAt),
    };
  }

  factory BusinessModel.fromEntity(Business business) {
    return BusinessModel(
      id: business.id,
      name: business.name,
      place: business.place,
      category: business.category,
      vatNumber: business.vatNumber,
      vatExpiryDate: business.vatExpiryDate,
      vatImagePath: business.vatImagePath,
      licenseNumber: business.licenseNumber,
      licenseExpiryDate: business.licenseExpiryDate,
      licenseImagePath: business.licenseImagePath,
      createdAt: business.createdAt,
      updatedAt: business.updatedAt,
    );
  }
}
