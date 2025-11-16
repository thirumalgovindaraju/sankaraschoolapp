// lib/data/services/teacher_data_initializer.dart

import 'teacher_service.dart';

class TeacherDataInitializer {
  static final TeacherService _teacherService = TeacherService();

  /// Initialize sample teacher data
  static Future<bool> initializeSampleTeachers() async {
    try {
      // Check if teachers already exist
      final existingTeachers = await _teacherService.getAllTeachers();
      if (existingTeachers.isNotEmpty) {
        print('✅ Teachers already initialized (${existingTeachers.length} teachers)');
        return true;
      }

      print('🚀 Initializing sample teacher data...');

      final sampleTeachers = [
        {
          'teacher_id': 'TCH001',
          'name': 'Dr. Rajesh Kumar',
          'email': 'rajesh.kumar@school.com',
          'phone': '+91-9876543210',
          'gender': 'Male',
          'subject': 'Mathematics',
          'qualification': 'M.Sc., B.Ed., Ph.D.',
          'experience': 15,
          'joining_date': '2010-06-15',
          'classes_assigned': ['8th', '9th', '10th'],
          'address': '123, Teachers Colony, Delhi - 110001',
        },
        {
          'teacher_id': 'TCH002',
          'name': 'Mrs. Priya Sharma',
          'email': 'priya.sharma@school.com',
          'phone': '+91-9876543211',
          'gender': 'Female',
          'subject': 'English',
          'qualification': 'M.A. English, B.Ed.',
          'experience': 12,
          'joining_date': '2012-04-20',
          'classes_assigned': ['6th', '7th', '8th', '9th'],
          'address': '456, Green Park, Delhi - 110016',
        },
        {
          'teacher_id': 'TCH003',
          'name': 'Mr. Amit Verma',
          'email': 'amit.verma@school.com',
          'phone': '+91-9876543212',
          'gender': 'Male',
          'subject': 'Science',
          'qualification': 'M.Sc. Physics, B.Ed.',
          'experience': 10,
          'joining_date': '2014-07-01',
          'classes_assigned': ['7th', '8th', '9th', '10th'],
          'address': '789, Science City, Delhi - 110020',
        },
        {
          'teacher_id': 'TCH004',
          'name': 'Ms. Neha Patel',
          'email': 'neha.patel@school.com',
          'phone': '+91-9876543213',
          'gender': 'Female',
          'subject': 'Hindi',
          'qualification': 'M.A. Hindi, B.Ed.',
          'experience': 8,
          'joining_date': '2016-08-10',
          'classes_assigned': ['5th', '6th', '7th', '8th'],
          'address': '321, Hindi Nagar, Delhi - 110025',
        },
        {
          'teacher_id': 'TCH005',
          'name': 'Mr. Suresh Reddy',
          'email': 'suresh.reddy@school.com',
          'phone': '+91-9876543214',
          'gender': 'Male',
          'subject': 'Social Studies',
          'qualification': 'M.A. History, B.Ed.',
          'experience': 14,
          'joining_date': '2011-03-15',
          'classes_assigned': ['6th', '7th', '8th', '9th', '10th'],
          'address': '654, Heritage Street, Delhi - 110030',
        },
        {
          'teacher_id': 'TCH006',
          'name': 'Mrs. Anita Desai',
          'email': 'anita.desai@school.com',
          'phone': '+91-9876543215',
          'gender': 'Female',
          'subject': 'Computer Science',
          'qualification': 'M.Tech, B.Ed.',
          'experience': 9,
          'joining_date': '2015-09-01',
          'classes_assigned': ['6th', '7th', '8th', '9th', '10th'],
          'address': '987, Tech Park, Delhi - 110035',
        },
        {
          'teacher_id': 'TCH007',
          'name': 'Mr. Vikram Singh',
          'email': 'vikram.singh@school.com',
          'phone': '+91-9876543216',
          'gender': 'Male',
          'subject': 'Physical Education',
          'qualification': 'M.P.Ed., B.P.Ed.',
          'experience': 11,
          'joining_date': '2013-05-20',
          'classes_assigned': ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'],
          'address': '147, Sports Complex, Delhi - 110040',
        },
        {
          'teacher_id': 'TCH008',
          'name': 'Ms. Kavita Menon',
          'email': 'kavita.menon@school.com',
          'phone': '+91-9876543217',
          'gender': 'Female',
          'subject': 'Art & Craft',
          'qualification': 'B.F.A., Diploma in Art Education',
          'experience': 7,
          'joining_date': '2017-06-12',
          'classes_assigned': ['Pre-KG', 'LKG', 'UKG', '1st', '2nd', '3rd'],
          'address': '258, Art Gallery Road, Delhi - 110045',
        },
        {
          'teacher_id': 'TCH009',
          'name': 'Mr. Ramesh Nair',
          'email': 'ramesh.nair@school.com',
          'phone': '+91-9876543218',
          'gender': 'Male',
          'subject': 'Chemistry',
          'qualification': 'M.Sc. Chemistry, B.Ed.',
          'experience': 13,
          'joining_date': '2012-01-10',
          'classes_assigned': ['9th', '10th'],
          'address': '369, Lab Street, Delhi - 110050',
        },
        {
          'teacher_id': 'TCH010',
          'name': 'Mrs. Lakshmi Iyer',
          'email': 'lakshmi.iyer@school.com',
          'phone': '+91-9876543219',
          'gender': 'Female',
          'subject': 'Biology',
          'qualification': 'M.Sc. Botany, B.Ed.',
          'experience': 10,
          'joining_date': '2014-08-25',
          'classes_assigned': ['9th', '10th'],
          'address': '741, Green Valley, Delhi - 110055',
        },
        {
          'teacher_id': 'TCH011',
          'name': 'Mr. Arun Gupta',
          'email': 'arun.gupta@school.com',
          'phone': '+91-9876543220',
          'gender': 'Male',
          'subject': 'Economics',
          'qualification': 'M.A. Economics, B.Ed.',
          'experience': 6,
          'joining_date': '2018-04-15',
          'classes_assigned': ['9th', '10th'],
          'address': '852, Market Road, Delhi - 110060',
        },
        {
          'teacher_id': 'TCH012',
          'name': 'Ms. Deepa Rao',
          'email': 'deepa.rao@school.com',
          'phone': '+91-9876543221',
          'gender': 'Female',
          'subject': 'Music',
          'qualification': 'Diploma in Music, B.A.',
          'experience': 5,
          'joining_date': '2019-07-01',
          'classes_assigned': ['Pre-KG', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th'],
          'address': '963, Music Lane, Delhi - 110065',
        },
      ];

      // Add all teachers
      for (var teacher in sampleTeachers) {
        await _teacherService.addTeacher(teacher);
      }

      print('✅ Successfully initialized ${sampleTeachers.length} teachers');
      return true;
    } catch (e) {
      print('❌ Error initializing teacher data: $e');
      return false;
    }
  }

  /// Get initialization status
  static Future<Map<String, dynamic>> getInitializationStatus() async {
    try {
      final teachers = await _teacherService.getAllTeachers();
      final subjectCount = await _teacherService.getTeacherCountBySubject();

      return {
        'initialized': teachers.isNotEmpty,
        'teacher_count': teachers.length,
        'subjects': subjectCount.length,
        'subject_breakdown': subjectCount,
      };
    } catch (e) {
      return {
        'initialized': false,
        'teacher_count': 0,
        'subjects': 0,
        'error': e.toString(),
      };
    }
  }

  /// Clear all teacher data (for testing)
  static Future<bool> clearAllTeachers() async {
    try {
      await _teacherService.clearAllTeachers();
      print('✅ All teacher data cleared');
      return true;
    } catch (e) {
      print('❌ Error clearing teacher data: $e');
      return false;
    }
  }

  /// Reinitialize teacher data
  static Future<bool> reinitialize() async {
    try {
      await clearAllTeachers();
      await Future.delayed(const Duration(milliseconds: 500));
      return await initializeSampleTeachers();
    } catch (e) {
      print('❌ Error reinitializing teacher data: $e');
      return false;
    }
  }
}