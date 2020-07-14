import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/services/database/database.dart';

class MessageKeys {
  static final String id = 'id';
  static final String date = 'date';
  static final String text = 'text';
  static final String userid = 'userid';
  static final String reacts = 'reacts';
  static final String previousMessageId = 'previousMessageId';
  static final String images = 'images';
  static final String chatid = 'chatid';
}

class Message {
  String id; // Id of the message
  final Timestamp date; // When the message has been sent
  String text; // The text of the message
  String userid; // The user who sent the message
  MessageReacts reacts;
  String previousMessageId;
  List<String> images = [];
  String chatid;

  Message({
    this.id,
    this.date,
    this.text,
    this.userid,
    this.reacts,
    this.previousMessageId='',
    this.images,
    this.chatid,
  }) {
    if (this.reacts == null) {
      this.reacts = MessageReacts();
    }
  }

  Map<String, Object> toFirebaseObject() {
    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject[MessageKeys.id] = this.id;
    firebaseObject[MessageKeys.date] = this.date;
    firebaseObject[MessageKeys.text] = this.text;
    firebaseObject[MessageKeys.userid] = this.userid;
    firebaseObject[MessageKeys.reacts] = this.reacts.toFirebaseObject();
    firebaseObject[MessageKeys.previousMessageId] = this.previousMessageId;
    firebaseObject[MessageKeys.images] = this.images;
    firebaseObject[MessageKeys.chatid] = this.chatid;

    return firebaseObject;
  }

  Message.fromFirebaseObject(String id, Map firebaseObject)
      : id = id,
        date = firebaseObject[MessageKeys.date] {
    this.text = firebaseObject.containsKey(MessageKeys.text) ? firebaseObject[MessageKeys.text] : '';
    this.userid = firebaseObject.containsKey(MessageKeys.userid) ? firebaseObject[MessageKeys.userid] : '';
    this.reacts = firebaseObject.containsKey(MessageKeys.reacts) ? MessageReacts.fromFirebaseObject(firebaseObject[MessageKeys.reacts]) : MessageReacts();
    this.previousMessageId = firebaseObject.containsKey(MessageKeys.previousMessageId) ? firebaseObject[MessageKeys.previousMessageId].toString() : '';
    this.images = firebaseObject.containsKey(MessageKeys.images) ? List.from(firebaseObject[MessageKeys.images]) : [];
    this.chatid = firebaseObject.containsKey(MessageKeys.chatid) ? firebaseObject[MessageKeys.chatid] : '';
  }

  Future<Message> answersToMessage(String chatId) async {
    if (this.previousMessageId.isEmpty) {
      return null;
    } else {
      return await DatabaseMessage(chatId: chatId).getMessageFuture(this.previousMessageId);
    }
  }

  void setNumImages(int numImages, {String chatId}) {
    print('this chat id ${this.chatid}');
    assert(!((this.chatid == null || this.chatid.isEmpty) && (chatId == null || chatId.isEmpty)), 'message.chatid and chatId can t be both null or empty');
    chatId ??= this.chatid;
    this.images = [];
    for (var i=0; i < numImages; i++) {
      this.images.add('chats/$chatId/messages/${this.id}/image_$i');
    }
  }

  Future<String> get imageUrl async {
    if (this.images.isEmpty) {
      return '';
    } else {
      return await DatabaseFiles(path: this.images[0]).url;
    }
  }
}

class MessageReacts {
  Map<String, String> reactMap;

  MessageReacts({
    this.reactMap,
  }) {
    if (this.reactMap == null) {
      this.reactMap = Map<String, String>();
    }
  }

  Map<String, Object> toFirebaseObject() {
    return reactMap;
  }

  MessageReacts.fromFirebaseObject(Map firebaseObject) {
    this.reactMap = firebaseObject == null ? Map<String, String>() : Map.from(firebaseObject);
  }

  bool containsKey(String key) {
    return this.reactMap.containsKey(key);
  }

  String operator [](String key) {
    return this.reactMap[key];
  }

  void operator []=(String key, String value) {
    this.reactMap[key] = value;
  }

  String remove(String key) {
    return this.reactMap.remove(key);
  }

  int get length {
    return this.reactMap.values.length;
  }

  bool get isEmpty {
    return this.reactMap.isEmpty;
  }

  bool get isNotEmpty {
    return this.reactMap.isNotEmpty;
  }


  List<String> reactList({bool unique=true}) {
    List<String> reacts = this.reactMap.values.toList();
    if (unique) {
      final Map<String, int> map = Map<String, int>();
      for (final String react in reacts) {
        map[react] = map.containsKey(react) ? map[react] + 1 : 1;
      }
      reacts = map.keys.toList(growable: false);
      reacts.sort((String react1, String react2) => map[react2].compareTo(map[react1]));
    }
    return reacts;
  }
}
