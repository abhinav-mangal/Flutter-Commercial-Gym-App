import 'package:energym/src/import.dart';

typedef RouteWidgetBuilder = Widget Function(
  BuildContext context,
  RouteSettings settings,
);

final Map<String, Function> routes = {
  Splash.routeName: (BuildContext context) => const Splash(),
  Connect.routeName: (BuildContext context) => const Connect(),
  WorkoutSelection.routeName: (BuildContext context) =>
      const WorkoutSelection(),
};

class RoutesArgs {
  RoutesArgs({this.isHeroTransition = false});

  final bool isHeroTransition;
}

class Routers {
  static String initialRoute = Splash.routeName;
  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    if (routes.containsKey(routeSettings.name)) {
      return _getPageRoute(routeSettings);
      // } else if (dialogRoutes.containsKey(routeSettings.name)) {
      //   return _getDialogRoute(routeSettings);
    } else {
      return null;
    }
  }

  static Route<dynamic> _getPageRoute(RouteSettings routeSettings) {
    final Function builder = routes[routeSettings.name]!;
    // ignore: lines_longer_than_80_chars
    final WidgetBuilder widgetBuilder =
        _getWidgetBuilder(builder, routeSettings) as WidgetBuilder;
    if (routeSettings.name == '/CompleteWorkout') {
      return MyCustomRoute(
        builder: (context) => widgetBuilder(context),
        settings: routeSettings,
      );
    } else {
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return widgetBuilder(context);
        },
      );
    }
  }

  static dynamic _getWidgetBuilder(
      Function builder, RouteSettings routeSettings) {
    return builder is WidgetBuilder ? builder : builder(routeSettings);
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder? builder, RouteSettings? settings})
      : super(builder: builder!, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // if (settings.arguments) return child;
    return FadeTransition(opacity: animation, child: child);
  }
}
