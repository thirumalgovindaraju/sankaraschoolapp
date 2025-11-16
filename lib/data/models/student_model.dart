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

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      className: json['class'] ?? '',
      section: json['section'] ?? '',
      rollNumber: json['roll_number'] ?? 0,
      email: json['email'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      address: json['address'] ?? '',
      admissionDate: json['admission_date'] ?? '',
      parentDetails: ParentDetails.fromJson(json['parent_details'] ?? {}),
    );
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
      fatherName: json['father_name'] ?? '',
      fatherPhone: json['father_phone'] ?? '',
      fatherEmail: json['father_email'] ?? '',
      fatherOccupation: json['father_occupation'] ?? '',
      motherName: json['mother_name'] ?? '',
      motherPhone: json['mother_phone'] ?? '',
      motherEmail: json['mother_email'] ?? '',
      motherOccupation: json['mother_occupation'] ?? '',
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