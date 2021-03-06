import 'package:flutter/material.dart';
import 'file:///D:/Valentin/Code/Nitwixt/Nitwixt/lib/screens/loading_screen.dart';
import 'package:nitwixt/screens/home/notifications_wrapper.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/home/set_username.dart';
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/view/themes/theme.dart';

class UserProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // FlutterStatusbarcolor.setStatusBarColor(Colors.black);

    final models.UserAuth userAuth = Provider.of<models.UserAuth>(context);

    final database.DatabaseUser databaseUser = database.DatabaseUser(id: userAuth.id);

    final GlobalKey<NavigatorState> _mainNavigatorKey = GlobalKey<NavigatorState>();


    return StreamProvider<models.User>.value(
      // * Provides the User to all the app
      value: databaseUser.stream,
      child: MaterialApp(
        navigatorKey: _mainNavigatorKey,
        themeMode: ThemeMode.dark,
        theme: theme,
        darkTheme: theme,
        home: UserReceiver(),
      ),
    );
  }
}

class UserReceiver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final models.UserAuth userAuth = Provider.of<models.UserAuth>(context);

    if (user == null) {
      // No user yet
//      return Scaffold(
//        body: LoadingCircle(),
//      );
    return LoadingScreen();
    } else if (user.hasNoUsername) {
//    } else if (true) {
      // No record for now on database, we have to create it
      return SetUsername();
    } else {
      if (userAuth.hasPhoto && (userAuth.photoUrl != user.defaultPictureUrl)) {
//        user.defaultPhotoUrl = userAuth.photoUrl;
        database.DatabaseUser(id: user.id).update(<String, dynamic>{
          models.UserKeys.defaultPictureUrl: user.toFirebaseObject()[models.UserKeys.defaultPictureUrl],
        });
      }
      return NotificationsWrapper(
        user: user,
      );
    }
  }
}
