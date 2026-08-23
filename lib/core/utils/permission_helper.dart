import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermission() async {
    //para android 13+
    final photosStatus = await Permission.photos.status;
    final videosStatus = await Permission.videos.status;

    if (photosStatus.isGranted || videosStatus.isGranted) {
      return true;
    }

    // para andoroid 12 o inferior
    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return true;
    }

    final statuses = await [
      Permission.storage,
      Permission.photos,
      Permission.videos,
    ].request();

    return statuses[Permission.storage]?.isGranted == true ||
        statuses[Permission.photos]?.isGranted == true ||
        statuses[Permission.videos]?.isGranted == true;
  }
}
