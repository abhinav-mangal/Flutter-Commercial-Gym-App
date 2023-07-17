import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_blue/flutter_blue.dart';

String currentUserID = '';

enum HealthKitDays { today, days7, days30 }

enum WorkoutType {
  resistance,
  watts,
  calories,
  cadence,
  activityMinutes,
  energyGenerated,
  caloriesBurned
}

class ImgConstants {
  //Splash
  static const String splash = 'assets/other/splash.png';
  static const String energymLogo = 'assets/images/png/EnergymLogo.png';
  static const String background = 'assets/images/png/background.png';
  static const String connect = 'assets/images/png/connect.png';
  static const String topView = 'assets/images/png/top_view.png';
  static const String logoWithGrey = 'assets/images/png/logo_with_grey.png';
  static const String logoWithGreen = 'assets/images/png/logo_with_green.png';
  static const String energymSelectionLogo =
      'assets/images/png/Energym_selection_logo.png';
  static const String instantWorkoutSelection =
      'assets/images/png/instant_workout_selection.png';
  static const String groupChallengeSelection =
      'assets/images/png/group_challenge_selection.png';
  static const String downArrow = 'assets/images/svg/ic_down_arrow.svg';
  static const String power = 'assets/images/png/power.png';
  static const String watts = 'assets/images/png/watts.png';
  static const String cycle = 'assets/images/png/cycle.png';
  static const String stopWatch = 'assets/images/png/stop_watch.png';
  static const String settings = 'assets/images/png/settings.png';
}

//declare your error constant message over here as well as in language JSON file
class MsgConstants {}

class AppConstants {
  static String cancel = 'Cancel'.tr();
  static String hiveGymUser = 'gym_user'.tr();
  static String hiveBikeId = 'bike_id'.tr();
  static String seconds = 'Seconds'.tr();
  static String workoutStarting = 'Workout Starting in:'.tr();
  static String home = 'Home'.tr();
  static String endWorkout = 'End Workout'.tr();
  static String noInternetTitle = 'Connection'.tr();
  static String noInternetMsg =
      'It seems to be no active wifi or data connection'.tr();
  static String ok = 'Ok'.tr();
  static String yes = 'Yes'.tr();
  static String no = 'No'.tr();
  static String somethingWrong = 'Something went wrong'.tr();
  static String searching = 'Searching...'.tr();
  static String reConnecting = 'Re:connecting...'.tr();
  static String selectRegen = 'SELECT YOUR RE:GEN'.tr();
  static String connectRegen = 'CONNECT RE:GEN'.tr();
  static String confirm = 'Confirm'.tr();
  static String back = 'Back'.tr();
  static String restart = 'Restart'.tr();
  static String refresh = 'Refresh'.tr();
  static String goToSettings = 'Go to settings'.tr();
  static String connect = 'Connect'.tr();
  static String connected = 'Connected'.tr();
  static String disconnect = 'Disconnect'.tr();
  static String setBikeId = 'SET RE:GEN ID #'.tr();
  static String enterBikeId = 'Enter ID #'.tr();
  static String setOtherIds = 'SET Other IDs #'.tr();
  static String enterTenantId = 'Enter Tenant ID #'.tr();
  static String enterLocationId = 'Enter Location ID #'.tr();
  static String change = 'CHANGE'.tr();
  static String bleDataNotAccessible =
      'This BLE device having advertisement is not accessible. '.tr();
  static String appName = 'Gym'.tr();
  static String pairingComplete = 'Pairing Complete'.tr();
  static String readyToRide = 'You’re ready to ride for the future.'.tr();
  static String instantWorkout = 'Instant Workout'.tr();
  static String groupChallenge = 'Group Challenge'.tr();
  static String titleFTP = 'What is your current FTP?'.tr();
  static String hintFTP = 'FTP'.tr();
  static String orSelectFTP = 'OR SELECT'.tr();
  static String beginnerFTP = 'Beginner'.tr();
  static String intermediateFTP = 'Intermediate'.tr();
  static String athleteFTP = 'Athlete'.tr();
  static String ftpDescription =
      'Don’t worry if you’re not sure of your FTP score, we can estimate this for you for now based on your fitness level. '
          .tr();
  static String totalPower = 'Total Power'.tr();
  static String rpm = 'RPM'.tr();
  static String maxPower = 'Max Power'.tr();
  static String currentPower = 'Current Power'.tr();
  static String resistance = 'Resistance:'.tr();
  static String resistanceUp = '+ Resistance'.tr();
  static String resistanceDown = '- Resistance'.tr();
  static String resistances = 'Resistance'.tr();
  static String whatName = 'What is your name?'.tr();
  static String searchingForRiders = 'Searching for riders...'.tr();
  static String sizing = '“Sizing up the “competition”...'.tr();
  static String planning = 'Planning victory dance...'.tr();
  static String youSmashedIt = 'You Smashed It'.tr();
  static String wattsGenerated = 'Watts Generated'.tr();
  static String wattHours = 'Total Power Generated\n(Wh)'.tr();
  static String milesCovered = 'Duration'.tr();
  static String endWorkoutMessage =
      'Are you sure you want to end workout?'.tr();
  static String disconnectMessage = 'Would you like to disconnect'.tr();
  static String bluetoothOffMessage = 'Bluetooth is not turned on, Please turn on the Bluetooth to connect.'.tr();
  static String bluetoothPermissionMessage = 'Bluetooth/Location permissions not granted. Kindly grant permissions to move on.'.tr();
  static String disconnecting = 'Disconnecting...'.tr();
}

class AppKeyConstant {
  static String title = 'title';
  static String message = 'message';
  static String code = 'code';
  static String shortBikeId = 'BikeId';
  static String sessionStatus = 'sessionStatus';
  static String deviceId = '"deviceId"';
  static String version = 'version';
  static String buildNumber = 'buildNumber';
  static String tenantId = 'tenantId';
  static String locationId = 'locationId';
}

// SharedPrefsHelper sharedPrefsHelper = serviceLocator!<SharedPrefsHelper>();

FlutterBlue flutterInstance = FlutterBlue.instance;
