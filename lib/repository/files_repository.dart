import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final filesProvider = FutureProvider((ref) {
  final filesRepository = ref.watch(filesRepositoryProvider);
  return filesRepository.getProtectedFiles();
});

final filesRepositoryProvider = Provider((ref) {
  final filesRepository = FilesRepository();
  return filesRepository;
});

class FilesRepository {
  Future<List<String>> getProtectedFiles() async {
    final filesDir = await getApplicationSupportDirectory();
    List<String> filePaths = [];
    for (var file in filesDir.listSync()) {
      filePaths.add(file.path);
    }

    return filePaths;
  }
}
