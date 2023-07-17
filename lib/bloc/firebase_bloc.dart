import 'dart:io';

import 'package:energym/src/import.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';

import '../model/bike_collection_model.dart';

typedef SuccessResponseCallback<T> = T Function(Map<String, dynamic> jsonData);
typedef ErrorResponseCallback<T> = T Function(Map<String, dynamic> jsonData);

// Common bloc class it contains all common functions
class FirebaseBloc {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  ///Here we are creating the [bike] collection
  createBikeDoc() {
    final bikeDocumentReference =
        FirebaseFirestore.instance.collection('bike').doc(bikeId);
    return bikeDocumentReference;
  }

  ///Here we are creating the [workout_session] collection
  createWorkoutSessionDoc() {
    final workoutSessionDocumentReference =
        FirebaseFirestore.instance.collection('workout_session').doc();
    return workoutSessionDocumentReference;
  }

  void eventLogs(String name, Map<String, Object?> parameters) async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        parameters.addAll({
          'os_version': androidInfo.version.release,
          'device_id': androidInfo.androidId,
          'device_type': 'Android'
        });
      } else if (Platform.isIOS) {
        IosDeviceInfo iOSInfo = await deviceInfo.iosInfo;
        parameters.addAll({
          'os_version': iOSInfo.systemVersion,
          'device_id': iOSInfo.identifierForVendor,
          'device_type': 'iOS'
        });
      }
      parameters.addAll({
        'version': 'v$version+$buildNumber',
        'name': name,
        'time_stamp': DateTime.now(),
        'expire_at': DateTime.now().add(const Duration(
            days:
                5)), // To auto delete log after 5 days, as this field is configured in firestore ttl policy.
        'bike_id': bikeId ?? '',
        'short_bike_id': shortBikeId ?? '',
      });
      // await FirebaseAnalytics.instance
      //     .logEvent(name: name, parameters: parameters)
      //     .catchError((onError) {
      //   print(onError);
      // });
      await FirebaseFirestore.instance
          .collection('Logs')
          .doc()
          .set(parameters)
          .onError((error, stackTrace) {});
    } on Exception {
      rethrow;
    }
  }

  // This function save data on firebase gym collection
  Future<void> saveDataInToGymUserCollection<T>({
    required Map<String, dynamic>? data,
    required String docID,
    // required BuildContext context,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('workout_session')
          .doc(docID)
          .set(data!)
          .then(
        (_) {
          if (data.isNotEmpty) {
            return onSuccess!(data);
          } else {
            final Map<String, dynamic> errorResponse = <String, dynamic>{};
            errorResponse[AppKeyConstant.message] = AppConstants.somethingWrong;
            errorResponse[AppKeyConstant.code] = '201';
            return onError!(errorResponse);
          }
        },
        onError: (error) {
          final Map<String, dynamic> errorResponse = <String, dynamic>{};
          errorResponse[AppKeyConstant.message] = error.message;
          errorResponse[AppKeyConstant.code] = error.code;
          return onError!(errorResponse);
        },
      );
    } on Exception {
      rethrow;
    }
  }

  /// This func saves data to the collection named as [bike]
  Future<void> saveDataInToBikeIdCollection<T>({
    required Map<String, dynamic>? data,
    required String bikeDocID,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('bike')
          .doc(bikeDocID)
          .set(data!)
          .then(
        (_) {
          if (data.isNotEmpty) {
            return onSuccess!(data);
          } else {
            final Map<String, dynamic> errorResponse = <String, dynamic>{};
            errorResponse[AppKeyConstant.message] = AppConstants.somethingWrong;
            errorResponse[AppKeyConstant.code] = '201';
            return onError!(errorResponse);
          }
        },
        onError: (error) {
          final Map<String, dynamic> errorResponse = <String, dynamic>{};
          errorResponse[AppKeyConstant.message] = error.message;
          errorResponse[AppKeyConstant.code] = error.code;
          return onError!(errorResponse);
        },
      );
    } on Exception {
      rethrow;
    }
  }

  /// This func saves data to the collection named as [tenant]
  Future<void> saveDataInToTenantCollection<T>({
    required Map<String, dynamic>? data,
    required BuildContext context,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('tenant')
          .doc(tenantId)
          .collection('location')
          .doc(locationId)
          .collection('instant_workout')
          .doc()
          .set(data!)
          .then(
        (_) {
          if (data.isNotEmpty) {
            return onSuccess!(data);
          } else {
            final Map<String, dynamic> errorResponse = <String, dynamic>{};
            errorResponse[AppKeyConstant.message] = AppConstants.somethingWrong;
            errorResponse[AppKeyConstant.code] = '201';
            return onError!(errorResponse);
          }
        },
        onError: (error) {
          final Map<String, dynamic> errorResponse = <String, dynamic>{};
          errorResponse[AppKeyConstant.message] = error.message;
          errorResponse[AppKeyConstant.code] = error.code;
          return onError!(errorResponse);
        },
      );
    } on Exception {
      rethrow;
    }
  }

  /// Upload bike data to [bike] collection.
  addingDataToBikeCollection(bikeDocId) async {
    try {
      BikeCollectionModel bikeModel = BikeCollectionModel(
          shortBikeId: shortBikeId ?? '',
          uuid: bikeId,
          status: true,
          tenantId: tenantId,
          locationId: locationId);
      await saveDataInToBikeIdCollection(
        data: bikeModel.toJson(),
        bikeDocID: bikeDocId,
        onSuccess: (data) {},
      );
    } on Exception {
      rethrow;
    }
  }

  /// fetching [bikeCollectionData] from firebase and then accessing [tenantId] & [locationId]
  fetchBikeInfo() async {
    try {
      final bikeDocumentReference = createBikeDoc();
      var bikeCollectionData = await bikeDocumentReference?.get();
      Map<String, dynamic>? bikeData = bikeCollectionData?.data();
      if (bikeData == null) {
        addingDataToBikeCollection(bikeDocumentReference?.id);
      } else {
        if (bikeData.keys.contains('tenant_id') &&
            bikeData.keys.contains('location_id')) {
          tenantId = bikeData['tenant_id'];
          locationId = bikeData['location_id'];
        }
      }
    } on Exception {
      rethrow;
    }
  }
}
