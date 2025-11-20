import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final int? id;
  final int businessId;
  final String name;
  final DateTime joiningDate;
  final DateTime? visaExpiryDate;
  final String? phone;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    this.id,
    required this.businessId,
    required this.name,
    required this.joiningDate,
    this.visaExpiryDate,
    this.phone,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        businessId,
        name,
        joiningDate,
        visaExpiryDate,
        phone,
        notes,
        isActive,
        createdAt,
        updatedAt,
      ];

  Employee copyWith({
    int? id,
    int? businessId,
    String? name,
    DateTime? joiningDate,
    DateTime? visaExpiryDate,
    String? phone,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      joiningDate: joiningDate ?? this.joiningDate,
      visaExpiryDate: visaExpiryDate ?? this.visaExpiryDate,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
