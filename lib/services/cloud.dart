import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/models/post.dart';
import 'package:social_media/services/storage.dart';
import 'package:uuid/uuid.dart';

class CloudMethods {
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  uploadPost({
    required String description,
    required String uid,
    required Uint8List file,
    String? profilePic,
    required String displayName,
    required String username,
  }) async {
    String res = "Some Error";
    try {
      String postId = Uuid().v1(); 
      String postImage =
          await StorageMethods().uploadImageToStorage(file, 'posts', true);
      PostModel postModel = PostModel(
        uid: uid,
        date: DateTime.now(),
        like: [],
        displayName: username,
        description: description,
        postId: postId,
        postImage: postImage,
        profilePic: profilePic ?? "",
        username: username,
      );

      posts.doc(postId).set(postModel.toJson());
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  commentToPost({
    required String postId,
    required String uid,
    required String commentText,
    required String profilePic,
    required String displayName,
    required String username,
  }) async {
    String res = "some error";
    try {
      if (commentText.isNotEmpty) {
        String commentId = Uuid().v1();
        await posts.doc(postId).collection('comments').doc(commentId).set({
          "uid": uid,
          'postId': postId,
          'commentId': commentId,
          "commentText": commentText,
          "date": DateTime.now(),
          "profilePic": profilePic,
          "displayName": displayName,
          "username": username,
        });
        res = "success";
      }
    } on Exception catch (e) {
      // TODO
    }
    return res;
  }


  likePost({
    required String postId,
    required String uid,
    required List like,
    }) async {

    String res = "some error";
    try {
      if(like.contains(uid)) {
        await posts.doc(postId).update({
          "like": FieldValue.arrayRemove([uid])
        });
      } else {
        await posts.doc(postId).update({
          "like": FieldValue.arrayUnion([uid])
        });
      }
      res = "success";
    } on Exception catch (e) {
      // TODO
    }
    return res;

  }

  editProfile({
    required String uid,
    required String displayName,
    required String username,
    Uint8List? file,
    String bio = "",
    String profilePic = "",
  }) async {
    String res = "some error";
    try {
      profilePic = file != null
          ? await StorageMethods().uploadImageToStorage(file, 'users', false)
          : "";
      if (displayName != "" && username != "") {
        users.doc(uid).update({
          "displayName": displayName,
          "username": username,
          "bio": bio,
          "profilePic": profilePic
        });
        res = "success";
      }
      return res;
    } on Exception catch (e) {
      res = e.toString();
    }
  }

  followUser({
    required String uid,
    required String followUserId,
  }) async {
    DocumentSnapshot doc = await users.doc(uid).get();
    List following = (doc.data() as dynamic)['following'];
    if (following.contains(followUserId)) {
      await users.doc(uid).update({
        "following": FieldValue.arrayRemove([followUserId])
      });
      await users.doc(followUserId).update({
        "followers": FieldValue.arrayRemove([uid])
      });
    } else {
      await users.doc(uid).update({
        "following": FieldValue.arrayUnion([followUserId])
      });
      await users.doc(followUserId).update({
        "followers": FieldValue.arrayUnion([uid])
      });
    }
  }

  deletePost(String postId) async {
    String res = "some error";
    try {
      await posts.doc(postId).delete();
      res = "success";
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }
}
