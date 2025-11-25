class StudentModel {
  final String studentId;
  final String name;
  final String className;
  final String section;
  final int rollNumber;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String address;
  final String admissionDate;
  final ParentDetails parentDetails;

  StudentModel({
    required this.studentId,
    required this.name,
    required this.className,
    required this.section,
    required this.rollNumber,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.admissionDate,
    required this.parentDetails,
  });

  //----------------------------------------------------------
  //   // ✅ Added Getters (Fixes "getter 'currentClass' not defined")
  //   // ----------------------------------------------------------
  //
  //   /// Allows your UI code to continue using student.currentClass
  String get currentClass => className;
  //
  //   /// Useful if any screen/provider filters by combined class-section
  String get classId => '$className-$section';
  //
  //   // ----------------------------------------------------------

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      // Handle student_id - ensure it's always a String
      studentId: _toString(json['student_id']) ?? '',
      name: _toString(json['name']) ?? '',
      className: _toString(json['class']) ?? '',
      section: _toString(json['section']) ?? '',
      // Handle roll_number - convert to int if it's stored as String
      rollNumber: _toInt(json['roll_number']) ?? 0,
      email: _toString(json['email']) ?? '',
      dateOfBirth: _toString(json['date_of_birth']) ?? '',
      gender: _toString(json['gender']) ?? '',
      bloodGroup: _toString(json['blood_group']) ?? '',
      address: _toString(json['address']) ?? '',
      admissionDate: _toString(json['admission_date']) ?? '',
      parentDetails: ParentDetails.fromJson(json['parent_details'] ?? {}),
    );
  }

  // Helper method to safely convert any value to String
  static String? _toString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  // Helper method to safely convert any value to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'class': className,
      'section': section,
      'roll_number': rollNumber,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'blood_group': bloodGroup,
      'address': address,
      'admission_date': admissionDate,
      'parent_details': parentDetails.toJson(),
    };
  }

  StudentModel copyWith({
    String? studentId,
    String? name,
    String? className,
    String? section,
    int? rollNumber,
    String? email,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? address,
    String? admissionDate,
    ParentDetails? parentDetails,
  }) {
    return StudentModel(
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      className: className ?? this.className,
      section: section ?? this.section,
      rollNumber: rollNumber ?? this.rollNumber,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      admissionDate: admissionDate ?? this.admissionDate,
      parentDetails: parentDetails ?? this.parentDetails,
    );
  }
}

class ParentDetails {
  final String fatherName;
  final String fatherPhone;
  final String fatherEmail;
  final String fatherOccupation;
  final String motherName;
  final String motherPhone;
  final String motherEmail;
  final String motherOccupation;

  ParentDetails({
    required this.fatherName,
    required this.fatherPhone,
    required this.fatherEmail,
    required this.fatherOccupation,
    required this.motherName,
    required this.motherPhone,
    required this.motherEmail,
    required this.motherOccupation,
  });

  factory ParentDetails.fromJson(Map<String, dynamic> json) {
    return ParentDetails(
      fatherName: json['father_name']?.toString() ?? '',
      fatherPhone: json['father_phone']?.toString() ?? '',
      fatherEmail: json['father_email']?.toString() ?? '',
      fatherOccupation: json['father_occupation']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      motherPhone: json['mother_phone']?.toString() ?? '',
      motherEmail: json['mother_email']?.toString() ?? '',
      motherOccupation: json['mother_occupation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'father_name': fatherName,
      'father_phone': fatherPhone,
      'father_email': fatherEmail,
      'father_occupation': fatherOccupation,
      'mother_name': motherName,
      'mother_phone': motherPhone,
      'mother_email': motherEmail,
      'mother_occupation': motherOccupation,
    };
  }
}