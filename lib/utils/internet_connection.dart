import 'dart:async';
import 'dart:developer';
import 'package:energym/src/import.dart';
import 'package:provider/provider.dart';

enum ConnectionStatus {
  online,
  recentlyBackOnline,
  offline,
}

class InternetConnection with ChangeNotifier {
  ConnectionStatus? status = ConnectionStatus.online;
  Timer? backOnlineTimer;
  StreamSubscription<ConnectivityResult>? connectivitySub;

  static InternetConnection of(BuildContext context) {
    return Provider.of<InternetConnection>(context);
  }

  InternetConnection() {
    Connectivity().checkConnectivity().then((result) {
      status = result == ConnectivityResult.none
          ? ConnectionStatus.offline
          : ConnectionStatus.online;
      notifyListeners();
    });

    connectivitySub =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      if (backOnlineTimer != null) {
        backOnlineTimer!.cancel();
      }
      status = ConnectionStatus.offline;
      notifyListeners();
    } else if (status != ConnectionStatus.online) {
      // not already online
      status = ConnectionStatus.recentlyBackOnline;
      backOnlineTimer = Timer(
        const Duration(seconds: 2),
        () {
          if (status == ConnectionStatus.recentlyBackOnline) {
            status = ConnectionStatus.online;
            notifyListeners();
          }
        },
      );
      notifyListeners();
    }
  }

  bool get isOnline => !isOffline;

  bool get isOffline => status == ConnectionStatus.offline;

  @override
  void dispose() {
    log('dispose InternetConnection');
    if (backOnlineTimer != null) {
      backOnlineTimer!.cancel();
    }
    connectivitySub!.cancel();
    super.dispose();
  }
}
