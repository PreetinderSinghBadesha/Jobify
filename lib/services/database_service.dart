import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jobify/models/project_model.dart';
import 'package:jobify/models/user_model.dart';

const String USER_COLLECTION_REF = "Users";
const String PROJECT_COLLECTION_REF = "Projects";

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _userRef;
  late final CollectionReference _projectRef;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DatabaseService() {
    _userRef =
        _firestore.collection(USER_COLLECTION_REF).withConverter<UserModel>(
            fromFirestore: (snapshots, _) => UserModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (user, _) => user.toJson());
    _projectRef =
        _firestore.collection(PROJECT_COLLECTION_REF).withConverter<ProjectModel>(
            fromFirestore: (snapshots, _) => ProjectModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (project, _) => project.toJson());
  }

  Stream<DocumentSnapshot<UserModel>> getUserDetails(String userId) {
    return _userRef
        .doc(userId)
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        )
        .snapshots();
  }

  Stream<DocumentSnapshot<ProjectModel>> getProjectDetails(String projectId) {
    return _projectRef
        .doc(projectId)
        .withConverter<ProjectModel>(
          fromFirestore: (snapshots, _) =>
              ProjectModel.fromJson(snapshots.data()!),
          toFirestore: (project, _) => project.toJson(),
        )
        .snapshots();
  }

  Future<String> uploadReadmeFile(String userId, String readmeContent) async {
    try {
      // Create a reference to the Firebase Storage location
      final ref = _storage.ref().child('profileReadme').child('$userId.md');

      // Upload the .md file
      await ref.putString(readmeContent);

      // Get the download URL of the uploaded file
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload ReadMe file: $e");
    }
  }

  

  void addUser(UserModel userDetails, User? user) async {
    await _userRef.doc(user!.uid).set(userDetails);
  }

  void addProject(ProjectModel projectDetails, String projectId) async {
    await _projectRef.doc(projectId).set(projectDetails);
  }

  Future<void> updateUserDetails(String userId, Map<String, Object?> updatedData) async {
    await _userRef.doc(userId).update(updatedData);
  }

  Future<void> updateProjectDetails(String projectId, Map<String, Object?> updatedData) async {
    await _projectRef.doc(projectId).update(updatedData);
  }
}
