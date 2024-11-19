import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";

class StorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> getHomePageImageUrl() async {
    DocumentSnapshot snapshot = await _firestore
        .collection("articles")
        .doc("DNIrJZXcqKtNrodhoWZe")
        .get();
    if (snapshot.exists && snapshot.data() != null) {
      String gsUrl = snapshot["imageUrl"] ?? '';

      if (gsUrl.startsWith("gs://")) {
        String filePath = gsUrl.replaceFirst("gs://calmwaves-c6569.firebasestorage.app", "");
        String downloadUrl = await _storage.ref(filePath).getDownloadURL();
        return downloadUrl;
      }
    }
    return '';
  }
}
