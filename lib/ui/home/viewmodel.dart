import 'dart:async';
import 'package:app_music/data/repository/repository.dart';
import '../../data/model/songs.dart';
class MusicAppViewModel{
  StreamController<List<Song>> songstream = StreamController();
  void loadSong(){
    final repository = DefaulRepository();
    repository.loadData().then((value) => songstream.add(value!));
  }
}