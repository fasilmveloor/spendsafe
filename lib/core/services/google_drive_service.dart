import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      drive.DriveApi.driveAppdataScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  // Sign in to Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        final client = await _googleSignIn.authenticatedClient();
        if (client != null) {
          _driveApi = drive.DriveApi(client);
        }
      }
      return _currentUser;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    _currentUser = null;
    _driveApi = null;
  }

  // Check if signed in
  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  // Get current user email
  String? get currentUserEmail => _currentUser?.email;

  // Upload database backup
  Future<String?> uploadBackup(File dbFile) async {
    if (_driveApi == null) return null;

    try {
      final fileName = 'spendsafe_backup_${DateTime.now().toIso8601String()}.db';
      
      // File Metadata
      final driveFile = drive.File();
      driveFile.name = fileName;
      driveFile.parents = ['appDataFolder']; // Store in hidden app folder
      
      // File Content
      final media = drive.Media(
        dbFile.openRead(),
        dbFile.lengthSync(),
      );

      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );
      
      return result.id;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  // List available backups
  Future<List<drive.File>> listBackups() async {
    if (_driveApi == null) return [];

    try {
      final fileList = await _driveApi!.files.list(
        q: "name contains 'spendsafe_backup_'",
        spaces: 'appDataFolder',
        $fields: 'files(id, name, createdTime, size)',
        orderBy: 'createdTime desc',
      );
      return fileList.files ?? [];
    } catch (e) {
      print('List error: $e');
      return [];
    }
  }

  // Restore backup
  Future<File?> downloadBackup(String fileId) async {
    if (_driveApi == null) return null;

    try {
      final drive.Media media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final appDir = await getApplicationDocumentsDirectory();
      final restoreFile = File(path.join(appDir.path, 'restore_temp.db'));
      
      final sink = restoreFile.openWrite();
      await media.stream.pipe(sink);
      await sink.close();

      return restoreFile;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }
}
