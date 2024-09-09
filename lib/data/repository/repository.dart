import 'package:app_music/data/source/source.dart';

import '../model/songs.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
}

class DefaulRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    final remoteSongs = await _remoteDataSource.loadData();
    if (remoteSongs != null) {
      songs.addAll(remoteSongs);
    } else {
      final localSongs = await _localDataSource.loadData();
      if (localSongs != null) {
        songs.addAll(localSongs);
      }
    }
    return songs;
  }
}
