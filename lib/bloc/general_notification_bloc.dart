import 'package:rxdart/rxdart.dart';

class GeneralNotificationBloc {
  final BehaviorSubject<String> type = BehaviorSubject<String>.seeded('');
  final BehaviorSubject<String> name = BehaviorSubject<String>.seeded('');
  final BehaviorSubject<String> entityId = BehaviorSubject<String>();
  final BehaviorSubject<bool> isOpenFromNotification =
      BehaviorSubject<bool>.seeded(false);

  bool getIsOpenFromNotification() {
    return isOpenFromNotification.valueWrapper?.value ?? false;
  }

  String getPushType() {
    return type.valueWrapper?.value ?? '';
  }

  String getPushName() {
    return name.valueWrapper?.value ?? '';
  }

  String getPushEntityId() {
    return entityId.valueWrapper?.value ?? '';
  }

  void updateType(String? tagValue) {
    type.sink.add(tagValue!);
  }

  void updateEntity(String? nameValue) {
    entityId.sink.add(nameValue!);
  }

  void updateIsOpenFromNotification(bool? value) {
    isOpenFromNotification.sink.add(value!);
  }

  void dispose() {
    type.close();
    name.close();
    entityId.close();
    isOpenFromNotification.close();
  }
}

final GeneralNotificationBloc generalNotificationBloc =
    GeneralNotificationBloc();