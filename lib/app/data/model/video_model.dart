class VideoModel {
  String? courseName;
  String? progress;
  List<Curriculum>? curriculum;

  VideoModel({this.courseName, this.progress, this.curriculum});

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    var list = json["curriculum"] as List;
    List<Curriculum> curriculumList =
        list.map((i) => Curriculum.fromJson(i)).toList();
    return VideoModel(
      courseName: json['course_name'],
      progress: json['progress'],
      // if (json['curriculum'] != null) {
      //   curriculum = <Curriculum>[];
      //   json['curriculum'].forEach((v) {
      //     curriculum!.add(Curriculum.fromJson(v));
      //   });
      // }
      curriculum: curriculumList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['course_name'] = courseName;
    data['progress'] = progress;
    if (curriculum != null) {
      data['curriculum'] = curriculum!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Curriculum {
  int? key;
  dynamic id;
  String? type;
  String? title;
  int? duration;
  String? content;
  List<dynamic>? meta;
  int? status;
  String? onlineVideoLink;
  String? offlineVideoLink;

  Curriculum(
      {this.key,
      this.id,
      this.type,
      this.title,
      this.duration,
      this.content,
      this.meta,
      this.status,
      this.onlineVideoLink,
      this.offlineVideoLink});

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      key: json['key'],
      id: json['id'],
      type: json['type'],
      title: json['title'],
      duration: json['duration'],
      content: json['content'],
      meta: json["meta"],
      status: json['status'],
      onlineVideoLink: json['online_video_link'],
      offlineVideoLink: json['offline_video_link'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['key'] = key;
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['duration'] = duration;
    data['content'] = content;
    if (meta != null) {
      data['meta'] = meta!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['online_video_link'] = onlineVideoLink;
    data['offline_video_link'] = offlineVideoLink;
    return data;
  }
}
