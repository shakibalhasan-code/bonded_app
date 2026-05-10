import 'user_model.dart';

class HighlightModel {
  final String? id;
  final HighlightEvent? event;
  final UserModel? creator;
  final List<HighlightImage>? images;
  final List<HighlightVideo>? videos;
  final String? caption;
  final List<UserModel>? taggedAttendees;
  final List<HighlightCircle>? taggedCircles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HighlightModel({
    this.id,
    this.event,
    this.creator,
    this.images,
    this.videos,
    this.caption,
    this.taggedAttendees,
    this.taggedCircles,
    this.createdAt,
    this.updatedAt,
  });

  factory HighlightModel.fromJson(Map<String, dynamic> json) {
    return HighlightModel(
      id: json['_id'],
      event: json['event'] != null ? HighlightEvent.fromJson(json['event']) : null,
      creator: json['creator'] != null ? UserModel.fromJson(json['creator']) : null,
      images: (json['images'] as List?)?.map((i) => HighlightImage.fromJson(i)).toList(),
      videos: (json['videos'] as List?)?.map((v) => HighlightVideo.fromJson(v)).toList(),
      caption: json['caption'],
      taggedAttendees: (json['taggedAttendees'] as List?)
          ?.map((a) => UserModel.fromJson(a))
          .toList(),
      taggedCircles: (json['taggedCircles'] as List?)
          ?.map((c) => HighlightCircle.fromJson(c))
          .toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']).toLocal() : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']).toLocal() : null,
    );
  }
}

class HighlightEvent {
  final String? id;
  final String? title;
  final String? visibility;
  final String? circleId;

  HighlightEvent({this.id, this.title, this.visibility, this.circleId});

  factory HighlightEvent.fromJson(Map<String, dynamic> json) {
    return HighlightEvent(
      id: json['_id'],
      title: json['title'],
      visibility: json['visibility'],
      circleId: json['circleId'],
    );
  }
}

class HighlightImage {
  final String? url;

  HighlightImage({this.url});

  factory HighlightImage.fromJson(Map<String, dynamic> json) {
    return HighlightImage(url: json['url']);
  }
}

class HighlightVideo {
  final String? url;
  final int? durationSeconds;

  HighlightVideo({this.url, this.durationSeconds});

  factory HighlightVideo.fromJson(Map<String, dynamic> json) {
    return HighlightVideo(
      url: json['url'],
      durationSeconds: json['durationSeconds'],
    );
  }
}

class HighlightCircle {
  final String? id;
  final String? name;

  HighlightCircle({this.id, this.name});

  factory HighlightCircle.fromJson(Map<String, dynamic> json) {
    return HighlightCircle(
      id: json['_id'],
      name: json['name'],
    );
  }
}
