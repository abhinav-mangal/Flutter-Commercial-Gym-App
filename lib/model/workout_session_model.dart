import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSessionModel {
  String? workoutType;
  int? ftpValue;
  int? peakPower;
  int? totalPower;
  DateTime? workoutTimeStart;
  DateTime? workoutTimeEnd;
  DocumentReference? deviceUuid;

  WorkoutSessionModel(
      {this.workoutTimeStart,
      this.workoutType,
      this.ftpValue,
      this.workoutTimeEnd,
      this.peakPower,
      this.deviceUuid,
      this.totalPower
      });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['workout_time_start'] = workoutTimeStart;
    data['workout_type'] = workoutType;
    data['ftp_value'] = ftpValue;
    data['peak_power'] = peakPower;
    data['total_power'] = totalPower;
    data['workout_time_end'] = workoutTimeEnd;
    data['device_uuid'] = deviceUuid;

    return data;
  }
}