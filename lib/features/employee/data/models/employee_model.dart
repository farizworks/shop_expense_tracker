import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    super.id,
    required super.businessId,
    required super.name,
    required super.joiningDate,
    super.visaExpiryDate,
    super.phone,
    super.notes,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] as int?,
      businessId: map['business_id'] as int,
      name: map['name'] as String,
      joiningDate:
          DateFormatter.parseFromDatabase(map['joining_date'] as String),
      visaExpiryDate: map['visa_expiry_date'] != null
          ? DateFormatter.parseFromDatabase(
              map['visa_expiry_date'] as String)
          : null,
      phone: map['phone'] as String?,
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateFormatter.parseFromDatabase(map['created_at'] as String),
      updatedAt: DateFormatter.parseFromDatabase(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'business_id': businessId,
      'name': name,
      'joining_date': DateFormatter.formatForDatabase(joiningDate),
      'visa_expiry_date': visaExpiryDate != null
          ? DateFormatter.formatForDatabase(visaExpiryDate!)
          : null,
      'phone': phone,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': DateFormatter.formatForDatabase(createdAt),
      'updated_at': DateFormatter.formatForDatabase(updatedAt),
    };
  }

  factory EmployeeModel.fromEntity(Employee employee) {
    return EmployeeModel(
      id: employee.id,
      businessId: employee.businessId,
      name: employee.name,
      joiningDate: employee.joiningDate,
      visaExpiryDate: employee.visaExpiryDate,
      phone: employee.phone,
      notes: employee.notes,
      isActive: employee.isActive,
      createdAt: employee.createdAt,
      updatedAt: employee.updatedAt,
    );
  }
}
