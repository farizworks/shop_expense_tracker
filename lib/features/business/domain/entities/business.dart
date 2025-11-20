import 'package:equatable/equatable.dart';

class Business extends Equatable {
  final int? id;
  final String name;
  final String place;
  final String category;
  final String? vatNumber;
  final DateTime? vatExpiryDate;
  final String? vatImagePath;
  final String? licenseNumber;
  final DateTime? licenseExpiryDate;
  final String? licenseImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Business({
    this.id,
    required this.name,
    required this.place,
    required this.category,
    this.vatNumber,
    this.vatExpiryDate,
    this.vatImagePath,
    this.licenseNumber,
    this.licenseExpiryDate,
    this.licenseImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        place,
        category,
        vatNumber,
        vatExpiryDate,
        vatImagePath,
        licenseNumber,
        licenseExpiryDate,
        licenseImagePath,
        createdAt,
        updatedAt,
      ];

  Business copyWith({
    int? id,
    String? name,
    String? place,
    String? category,
    String? vatNumber,
    DateTime? vatExpiryDate,
    String? vatImagePath,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    String? licenseImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      place: place ?? this.place,
      category: category ?? this.category,
      vatNumber: vatNumber ?? this.vatNumber,
      vatExpiryDate: vatExpiryDate ?? this.vatExpiryDate,
      vatImagePath: vatImagePath ?? this.vatImagePath,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      licenseImagePath: licenseImagePath ?? this.licenseImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
