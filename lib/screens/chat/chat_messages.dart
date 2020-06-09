import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/screens/message/message_tile.dart';
import 'package:nitwixt/shared/constants.dart';
import 'package:nitwixt/shared/loading.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/services/database/database.dart' as database;

class ChatMessages extends StatefulWidget {
  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  TextEditingController textController = TextEditingController();
  int _nbMessages = 16;
  ScrollController _scrollController;

  _scrollListener() {
    if (_scrollController.position.maxScrollExtent == _scrollController.position.pixels) {
      setState(() {
        _nbMessages += 8;
      });
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final models.Chat chat = Provider.of<models.Chat>(context);
    final database.DatabaseMessage _databaseMessage = database.DatabaseMessage(chatId: chat.id);

    return StreamBuilder<List<models.Message>>(
      stream: _databaseMessage.getMessageList(limit: _nbMessages),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        } else {
          List<models.Message> messageList = snapshot.data;
          double height = MediaQuery.of(context).size.height;

          return SizedBox(
            height: height,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messageList.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      models.Message message = messageList[index];
                      return MessageTile(message: message);
                    },
                    shrinkWrap: true,
                  ),
                ),
                TextFormField(
                  controller: textController,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Type your message',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        if (textController.text.trim().isNotEmpty) {
                          await _databaseMessage.sendMessage(text: textController.text.trim(), userid: user.id);
                          WidgetsBinding.instance.addPostFrameCallback((_) => textController.clear());
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
