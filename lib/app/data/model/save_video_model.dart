class SaveVideoModel {
  int? key;
  dynamic id;
  String? type;
  String? title;
  int? duration;
  String? content;
  int? status;
  String? onlineVideoLink;
  String? offlineVideoLink;

  SaveVideoModel(
      {this.key,
      this.id,
      this.type,
      this.title,
      this.duration,
      this.content,
      this.status,
      this.onlineVideoLink,
      this.offlineVideoLink});

  factory SaveVideoModel.fromJson(Map<String, dynamic> json) {
    return SaveVideoModel(
      key: json['key'],
      id: json['id'],
      type: json['type'],
      title: json['title'],
      duration: json['duration'],
      content: json['content'],
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

    data['status'] = status;
    data['online_video_link'] = onlineVideoLink;
    data['offline_video_link'] = offlineVideoLink;
    return data;
  }
}
