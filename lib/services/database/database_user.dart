import 'package:cloud_firestore/cloud_firestore.dart';

import 'collections.dart' as collections;
import 'package:nitwixt/models/models.dart' as models;

class DatabaseUser {
  final String id;

  DatabaseUser({this.id});

  final CollectionReference userCollection = collections.userCollection;

  static models.User userFromDocumentSnapshot(DocumentSnapshot snapshot) {
    return models.User.fromFirebaseObject(snapshot.documentID, snapshot.data);
  }

  Stream<models.User> get userStream {
    return userCollection.document(id).snapshots().map(userFromDocumentSnapshot);
  }

  Future<models.User> get userFuture async {
    DocumentSnapshot documentSnapshot = await userCollection.document(id).get();
    return userFromDocumentSnapshot(documentSnapshot);
  }

  static List<models.User> userFromQuerySnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map(userFromDocumentSnapshot).toList();
  }

  static Stream<List<models.User>> getUserList({List<String> userIdList}) {
    if (userIdList == null || userIdList.isEmpty) {
      return new Stream.value([]);
    } else {
      Query query = collections.userCollection.where('id', whereIn: userIdList);
      return query.snapshots().map(userFromQuerySnapshot);
    }
  }

  static Future createEmptyUser({String id}) async {
    /// id is used when I when to create a user with a fixed id (from the FirebaseUser id)
    /// If id is not provided, an automatic id will be generated by Firebase
    models.User user = models.User();
    if (id == null || id.isEmpty) {
      // Create a new user and send back the id
      DocumentReference documentReference = await collections.userCollection.add(user.toFirebaseObject());
      await collections.userCollection.document(documentReference.documentID).updateData({
        'id': documentReference.documentID,
      });
      return documentReference.documentID;
    } else {
      // The id is provided, then I have to create the user and document with the specified id
      user.id = id;
      return await collections.userCollection.document(id).setData(user.toFirebaseObject());
    }
  }

  static Future createUser({String id, models.User user}) async {
    /// id is used when I when to create a user with a fixed id (from the FirebaseUser id)
    /// If user if not provided, an empty one is created
    /// If id is not provided, an automatic id will be generated by Firebase
    if (user == null) {
      return createEmptyUser(id: id);
    } else {
      String id_;   // The final id
      if (id == null || id.isEmpty) {
        id_ = user.id;
      } else {
        id_ = id;
      }
      if (id_ == null || id_.isEmpty) {
        // There is no id provided as an argument or in the user
        DocumentReference documentReference = await collections.userCollection.add(user.toFirebaseObject());
        await collections.userCollection.document(documentReference.documentID).updateData({
          'id': documentReference.documentID,
        });
        return documentReference.documentID;

      } else {
        // I have an id to consider
        user.id = id_;
        return await collections.userCollection.document(id_).setData(user.toFirebaseObject());
      }
    }
  }

  static Future<bool> userIdExists({String id}) async {
    DocumentSnapshot documents = await collections.userCollection.document(id).get();
    return documents.exists;
  }

  Future<bool> exists() {
    return userIdExists(id: this.id);
  }
}

