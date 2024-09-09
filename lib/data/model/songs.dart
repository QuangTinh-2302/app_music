class Song {
  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  bool favorite;
  int counter;
  int replay;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
    required this.counter,
    required this.favorite,
    required this.replay
  });

  factory Song.fromJson(Map<String,dynamic> json){
    return Song(
      id: json['id'],
      title: json['title'],
      album: json['album'],
      artist: json['artist'],
      source: json['source'],
      image: json['image'],
      duration: json['duration'] as int,
      counter: json['counter'] as int,
      favorite: json['favorite'] is bool ?
        json['favorite']
        : (json['favorite'] is int ?
        json['favorite'] == 1
        :json['favorite'].toString().toLowerCase() == 'true' || json['favorite'].toString() == '1'),
      replay: json['replay'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration, favorite: $favorite, counter: $counter, relay: $replay}';
  }
}