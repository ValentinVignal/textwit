import 'package:flutter/material.dart';
import 'package:nitwixt/shared/constants.dart';

class InputTextMessage extends StatefulWidget {
  Function sendMessage;

  InputTextMessage({
    @required this.sendMessage,
  }) : super();

  @override
  _InputTextMessageState createState() => _InputTextMessageState();
}

class _InputTextMessageState extends State<InputTextMessage> {
  TextEditingController _textController = TextEditingController();
  bool showSendButton = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _textListener() {
    setState(() {
      showSendButton = _textController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    _textController.addListener(_textListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 7,
              style: TextStyle(color: Colors.white),
              controller: _textController,
              decoration: textInputDecorationMessage.copyWith(
                hintText: 'Type your message',
              ),
            ),
          ),
          SizedBox(width: 5.0),
          showSendButton
              ? IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.blue,
            ),
            onPressed: () {
              widget.sendMessage(_textController.text.trim());
              WidgetsBinding.instance.addPostFrameCallback((_) => _textController.clear());
            },
          )
              : SizedBox(width: 0.0),
          SizedBox(width: _textController.text.isEmpty ? 0.0 : 5.0),
        ],
      ),
    );
  }
}