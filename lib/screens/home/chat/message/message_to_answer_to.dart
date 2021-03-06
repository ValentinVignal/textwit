import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;

class MessageToAnswerTo extends StatelessWidget {
  const MessageToAnswerTo({
    @required this.message,
    this.onCancel,
  }) : super();
  final models.Message message;
  final void Function() onCancel;

  Color get color => const Color(0xFFBBBBBB);

  Color get backgroundColor => const Color(0xFF101010);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              Icons.reply,
              color: color,
            ),
          ),
          Expanded(
            child: Text(
              message.text.replaceAll('\n', ' '),
              style: TextStyle(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.clear,
              color: color,
            ),
            onPressed: onCancel,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension - 10,
            ),
          ),
        ],
      ),
    );
  }
}
