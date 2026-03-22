import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/child_model.dart';
import '../models/creche_model.dart';
import '../models/guardian_model.dart';
import '../models/attendance_model.dart';
import '../models/sick_leave_model.dart';
import '../models/tracker_location_model.dart';
import '../../core/constants/app_constants.dart';

part 'repositories/user_repository.dart';
part 'repositories/creche_repository.dart';
part 'repositories/child_repository.dart';
part 'repositories/guardian_repository.dart';
part 'repositories/attendance_repository.dart';
part 'repositories/sick_leave_repository.dart';
part 'repositories/tracker_repository.dart';
part 'repositories/bootstrap_repository.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
