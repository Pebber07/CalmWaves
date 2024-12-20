import 'package:calmwaves_app/widgets/profile_pic_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicturePicker extends StatefulWidget {
  const ProfilePicturePicker({super.key});

  @override
  State<ProfilePicturePicker> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProfilePicturePicker> {
  Uint8List? _image;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileImage(); // Képernyő visszatérés
  }

  Future<void> _loadProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userInfo = userDoc.data()?['userinfo'] as Map<String, dynamic>?;
      if (userInfo != null && userInfo['profileImage'] != null) {
        setState(() {
          _imageUrl = userInfo['profileImage'];
        });
      }
    }
  }

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);

    if (img != null) {
      setState(() {
        _image = img;
      });
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) {
      Fluttertoast.showToast(
        msg: "Nincs kiválasztott kép!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    try {
      // Egyedi fájlnév
      String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${FirebaseAuth.instance.currentUser?.uid}.jpg";

      // Storage referencia
      Reference storageRef =
          FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
      UploadTask uploadTask = storageRef.putData(_image!);

      // Feltöltés és url lekérdezés
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'userinfo.profileImage': imageUrl,
        });

        setState(() {
          _imageUrl = imageUrl;
        });

        Fluttertoast.showToast(
          msg: "Profilkép sikeresen feltöltve!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Hiba történt a kép feltöltésekor.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              _image != null || _imageUrl != null
                  ? CircleAvatar(
                      radius: 72,
                      backgroundImage: _image != null
                          ? MemoryImage(_image!)
                          : NetworkImage(_imageUrl!) as ImageProvider,
                    )
                  : const CircleAvatar(
                      radius: 72,
                      backgroundImage:
                          AssetImage("assets/images/template_profile_pic.png"),
                    ),
              Positioned(
                bottom: -10,
                left: 80,
                child: IconButton(
                  onPressed: () async {
                    selectImage();
                    await uploadImage();
                  },
                  icon: const Icon(Icons.add_a_photo),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
