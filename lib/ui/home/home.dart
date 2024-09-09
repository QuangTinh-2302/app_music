import 'package:app_music/ui/discovery/discovery.dart';
import 'package:app_music/ui/home/viewmodel.dart';
import 'package:app_music/ui/play/audio_player_manager.dart';
import 'package:app_music/ui/settings/settings.dart';
import 'package:app_music/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/songs.dart';
import '../play/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent)),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab()
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('MusicApp'),
        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.album), label: 'Discovery'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Account'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings'),
            ],
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          ),
          tabBuilder: (BuildContext context, int index) {
            return _tabs[index];
          },
        ));
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    // TODO: implement initState
    _viewModel = MusicAppViewModel();
    _viewModel.loadSong();
    obsereveData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _viewModel.songstream.close();
    AudioPlayerManager().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  Widget getBody() {
    bool showloading = songs.isEmpty;
    if (showloading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(index) {
    return _SongItemSelection(parent: this,song: songs[index],);
  }

  void obsereveData() {
    _viewModel.songstream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }
  void showBottomSheet(){
    showModalBottomSheet(context: context, builder: (context){
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: Container(
          height: 400,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Modal Bottom Sheet'),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Bottom Sheet')
              )
            ],
          ),
        ),
      );
    });
  }
  void navigate(Song song){
    Navigator.push(context,
        CupertinoPageRoute(
            builder: (context){
              return NowPlaying(
                songs : songs,
                playingSong: song
              );
            }
        )
    );
  }
}

class _SongItemSelection extends StatelessWidget {
  const _SongItemSelection({required this.parent, required this.song});

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itunes.png',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/itunes.png',
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(onPressed: () {
        parent.showBottomSheet();
      },
          icon: const Icon(Icons.more_vert)
      ),
      onTap:(){
        parent.navigate(song);
      },
    );
  }
}
