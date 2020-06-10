import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/chat/chat_home.dart';
import 'package:nitwixt/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart';

class MembersProvider extends StatelessWidget {
  final models.Chat chat;

  MembersProvider({this.chat});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<models.User>>.value(
      value: DatabaseUser.getUserList(userIdList: chat.members),
      child: MembersReceiver(),
    );
  }
}

class MembersReceiver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<models.User> membersList = Provider.of<List<models.User>>(context);
    Map<String, models.User> membersMap;

    if (membersList == null) {
      return Scaffold(
        body: Loading(),
      );
    } else {
      membersMap = membersList.asMap().map<String, models.User>((int index, models.User user) {
        return MapEntry(user.id, user);
      });
      return Provider<Map<String, models.User>>.value(
        value: membersMap,
        child: MembersMapReceiver(),
      );
    }
  }
}

class MembersMapReceiver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, models.User> membersMap = Provider.of<Map<String, models.User>>(context);

    if (membersMap == null) {
      return Scaffold(
        body: Loading(),
      );
    } else {
      return ChatHome();
    }
  }
}