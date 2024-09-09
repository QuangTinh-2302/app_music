import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/songs.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(playingSong: playingSong, songs: songs);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowplayingPageState();
}

class _NowplayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  double _currentAnimationPosition = 0.0;
  bool _isShuffle = false;
  late LoopMode _loopMode;

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _imageAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 20000));
    _audioPlayerManager = AudioPlayerManager();
    if(_audioPlayerManager.songUrl.compareTo(_song.source) != 0){
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    }else{
      _audioPlayerManager.prepare(isNewSong: false);
    }
    _selectedItemIndex = widget.songs.indexOf(_song);
    _loopMode = LoopMode.off;
    _autoNext();
  }
  void _autoNext(){
    _audioPlayerManager.player.processingStateStream.listen((state){
      if(state == ProcessingState.completed){
        setNextSong();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 100;
    final radius = (screenWidth - delta) / 2;
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('NowPlaying'),
          trailing:
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ),
        child: Scaffold(
          body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30,),
                  Text(
                    _song.album,
                  ),
                  const Text('_ ___ _'),
                  const SizedBox(
                    height: 30,
                  ),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(_imageAnimationController),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/itunes.png',
                        image: _song.image,
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/itunes.png',
                            height: screenWidth - delta,
                            width: screenWidth - delta,
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 10),
                    child: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.share),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Column(
                            children: [
                              Text(
                                _song.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                widget.playingSong.artist,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color),
                              )
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_outline),
                            color: Theme.of(context).colorScheme.primary,
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32,left: 24,right: 24,bottom: 10),
                    child: _progressBar(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32,left: 24,right: 24,bottom: 10),
                    child: _mediaButton(),
                  ),
              ],
            )
          ),
        )
    );
  }

  @override
  void dispose() {
    _imageAnimationController.dispose();
    super.dispose();
  }
  StreamBuilder<DurationState> _progressBar(){
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context,snapshot){
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffer = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffer,
            onSeek: _audioPlayerManager.player.seek,
            barHeight: 5,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.withOpacity(0.5),
            //progressBarColor: Colors.blueGrey, màu nút đã đi qua
            bufferedBarColor: Colors.grey.withOpacity(0.5),
            //thumbColor: Colors.green, màu nút tròn
          );
        }
    );
  }


  StreamBuilder<PlayerState> _playButton(){
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot){
          final playState = snapshot.data;
          final progressingState = playState?.processingState;
          final playing = playState?.playing;
          if(progressingState == ProcessingState.loading
          || progressingState == ProcessingState.buffering){
            _pauseRotationAmin();
            return Container(
              margin: const EdgeInsets.all(8),
              width: 48,
              height: 48,
              child: const CircularProgressIndicator(),
            );
          }else if(playing != true){
            return MediaButtonControl(function: (){
              _audioPlayerManager.player.play();
            },
                icon: Icons.play_arrow,
                color: null,
                size: 48
            );
          }else{
            _playRotationAmin();
            return MediaButtonControl(function: (){
              _audioPlayerManager.player.pause();
              _pauseRotationAmin();
            },
                icon: Icons.pause,
                color: null,
                size: 48
            );
          }
        },
    );
  }

  void setNextSong(){
    if(_isShuffle){
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    }else if(_selectedItemIndex < widget.songs.length - 1){
      ++_selectedItemIndex;
    }else if(_loopMode == LoopMode.all && _selectedItemIndex == widget.songs.length - 1){
      _selectedItemIndex = 0;
    }
    if(_selectedItemIndex >= widget.songs.length){
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _audioPlayerManager.player.play();
    _audioPlayerManager.prepare(isNewSong: true);
    _resetRotationAmin();
    _imageAnimationController.repeat();
    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong(){
    if(_isShuffle){
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    }else if(_selectedItemIndex > 0){
      --_selectedItemIndex;
    }else if(_loopMode == LoopMode.all && _selectedItemIndex == 0){
      _selectedItemIndex = widget.songs.length - 1;
    }
    if(_selectedItemIndex < 0){
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.player.play();
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _audioPlayerManager.prepare(isNewSong: true);
    _resetRotationAmin();
    setState(() {
      _song = nextSong;
    });
  }
  void _playRotationAmin(){
    _imageAnimationController.forward(from: _currentAnimationPosition);
    _imageAnimationController.repeat();
  }

  void _pauseRotationAmin(){
    _stopRotationAmin();
    _currentAnimationPosition = _imageAnimationController.value;
  }

  void _stopRotationAmin(){
    _imageAnimationController.stop();
  }

  void _resetRotationAmin(){
    _currentAnimationPosition = 0.0; //gia tri vi tri quay
    _imageAnimationController.forward(from: _currentAnimationPosition);
  }

  void _setShuffle(){
    setState(() {
      _isShuffle = !_isShuffle;
      _currentAnimationPosition = _imageAnimationController.value;
    });
  }

  Color? _getShuffleColor(){
    return _isShuffle ? Theme.of(context).colorScheme.primary : Colors.grey;
  }

  IconData _repetingIcon(){
    return switch(_loopMode){
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ =>Icons.repeat
    };
  }

  Color? _getRepeatingIconColor(){
    return _loopMode == LoopMode.off ?  Colors.grey : Theme.of(context).colorScheme.primary;
  }

  void _setRepeatOption(){
    if(_loopMode == LoopMode.off){
      _loopMode = LoopMode.one;
    }else if(_loopMode == LoopMode.one){
      _loopMode = LoopMode.all;
    }else{
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
      _currentAnimationPosition = _imageAnimationController.value;
    });
  }

  Widget _mediaButton(){
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(function: _setShuffle, icon: Icons.shuffle, color: _getShuffleColor(), size: 24),
          MediaButtonControl(function: _setPrevSong, icon: Icons.skip_previous, color: Theme.of(context).colorScheme.primary, size: 36),
          _playButton(),
          MediaButtonControl(function: setNextSong, icon: Icons.skip_next, color: Theme.of(context).colorScheme.primary, size: 36),
          MediaButtonControl(function: _setRepeatOption, icon: _repetingIcon(), color: _getRepeatingIconColor(), size: 24),
        ],
      ),
    );
  }
}

class MediaButtonControl extends StatefulWidget{
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size
});
  final void Function()? function;
  final IconData icon;
  final Color? color;
  final double? size;
  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();

}

class _MediaButtonControlState extends State<MediaButtonControl>{
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}