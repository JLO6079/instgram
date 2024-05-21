import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:insta_app22/models/usermodel.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethod {
  Future<UserModel> userdetalis({required userid}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(userid).get();
    return UserModel.convertsnaptomodel(snap);
  }

  addpost({required Map postmap}) async {
    if (postmap['likes'].contains(FirebaseAuth.instance.currentUser!.uid)) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postmap['postid'])
          .update({
        'likes':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postmap['postid'])
          .update({
        'likes': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      });
    }
  }

  updateUser({required userMap}) async {
    // Get a reference to the user document
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userMap['uid']);

    // Update the user document with the provided userMap
    await userRef.update(userMap);
  }

  delete_user({required userId}) async {
    if (FirebaseAuth.instance.currentUser!.uid == userId) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    }
  }

  delete_post({required Map postmap}) async {
    if (FirebaseAuth.instance.currentUser!.uid == postmap['uid']) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postmap['postid'])
          .delete();
    }
  }

  delete_all_post({required Map postmap}) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postmap['postid'])
        .delete();
  }

  addcomment(
      {required comment,
      required userimage,
      required uid,
      required postid,
      required name}) async {
    final uuid = Uuid().v4();

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postid)
        .collection('comments')
        .doc(uuid)
        .set({
      'name': name,
      'comment': comment,
      'userimage': userimage,
      'uid': uid,
      'postid': postid,
      'commentid': uuid,
    });
  }

  follow_user({required userid}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'following': FieldValue.arrayUnion([userid])
    });

    await FirebaseFirestore.instance.collection('users').doc(userid).update({
      'followers':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });
  }

  unfollow_user({required userid}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'following': FieldValue.arrayRemove([userid])
    });

    await FirebaseFirestore.instance.collection('users').doc(userid).update({
      'followers':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
  }

  delete_story({required Map story}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(story['uid'])
        .update({
      'stories': FieldValue.arrayRemove([story])
    });
  }

  deleteAfter24h({required Map story}) {
    Duration difference = DateTime.now().difference(story['date'].toDate());

    if (difference.inMinutes > 15) {
      delete_story(story: story);
    }
  }

  delete_chat({required chatroomid}) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatroomid)
        .delete();
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatroomid)
        .collection('messages')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  delete_message({required chatroomid, required messageid}) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatroomid)
        .collection('messages')
        .doc(messageid)
        .delete();
  }

  upload_story(
      {required media,
      required type,
      required followers,
      required username,
      required userimage}) async {
    final uuid = Uuid().v4();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'stories': FieldValue.arrayUnion([
        {
          'content': media,
          'type': type,
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'date': Timestamp.now(),
          'storyid': uuid,
          'duration': 1
        }
      ])
    });

    print('done');
  }
}
