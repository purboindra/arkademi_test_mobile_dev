import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:arkademi_test/app/data/model/save_video_model.dart';
import 'package:arkademi_test/app/data/model/video_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final List<Tab> myTabs = [
    Tab(text: 'Kurikulum'),
    Tab(text: 'Ikhtisar'),
    Tab(text: 'Lampiran'),
  ];
  RxMap<int, SaveVideoModel> saveItems = <int, SaveVideoModel>{}.obs;
  VideoPlayerController? videoCont;
  VideoPlayerController? controllerVideo;
  var isPlay = false.obs;
  RxBool isPlaying = false.obs;
  RxBool isVideoPlaying = false.obs;
  var isPlayingIndex = -1;
  var indexData = 0.obs;
  final _dataVideo = {}.obs;
  RxMap<dynamic, dynamic> get dataVideo => _dataVideo;
  RxList<Curriculum> videoDataList = <Curriculum>[].obs;
  var isSelect = false.obs;
  bool disposeVideoController = false;
  RxBool noMute = false.obs;

  String? parsedTitle;

  void muteVideo() {
    noMute.value = (controllerVideo?.value.volume ?? 0) > 0;
    if (noMute.value) {
      controllerVideo?.setVolume(0);
    } else {
      controllerVideo?.setVolume(1.0);
    }
    update();
  }

  var onUpdateControllerTime;
  void onControllerUpdate() async {
    if (disposeVideoController) {
      return;
    }
    onUpdateControllerTime = 0;
    final now = DateTime.now().microsecondsSinceEpoch;
    if (onUpdateControllerTime > now) {
      return;
    }

    onUpdateControllerTime = now + 500;

    controllerVideo;
    if (controllerVideo == null) {
      print("VIDEO DATA NULL");
      return;
    }
    if (!controllerVideo!.value.isInitialized) {
      print("controller can not initialized");
      return;
    }
    final playing = controllerVideo!.value.isPlaying;
    isPlaying.value = playing;
    update();
  }

  void playVideo(int index) {
    final videoPlayerController = VideoPlayerController.network(
        videoDataList[index].onlineVideoLink != null
            ? videoDataList[index].onlineVideoLink!
            : "");

    final oldVideoController = controllerVideo;
    controllerVideo = videoPlayerController;

    update();
    videoPlayerController.initialize().then(
      (_) {
        if (oldVideoController != null) {
          oldVideoController.dispose();
        }
        isPlayingIndex = index;
        videoPlayerController.addListener(onControllerUpdate);
        videoPlayerController.play();
        update();
      },
    );
    update();
  }

  Future<RxList<Curriculum>> fetchCurriculumData(int index) async {
    await fetchAllData().then((value) {
      List data = value["curriculum"];
      for (var element in data) {
        videoDataList.add(Curriculum.fromJson(element));
      }
    });

    update();

    return videoDataList;
  }

  Future<RxMap<dynamic, dynamic>> fetchAllData() async {
    final url =
        Uri.parse("https://engineer-test-eight.vercel.app/course-status.json");
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      _dataVideo.value = jsonResponse as Map<String, dynamic>;
      update();
    } else {
      throw Exception("ERROR");
    }
    return _dataVideo;
  }

  Future openFile({required String url, String? fileName}) async {
    Get.snackbar(
      "Download",
      "Download this video, please wait untill end!",
      backgroundColor: Colors.teal,
      colorText: Colors.white,
    );
    final file = await downloadFile(url, fileName!);
    if (file == null) return;
    print("Path ${file.path}");

    OpenFile.open(file.path);
  }

  Future<File?> downloadFile(String url, String name) async {
    try {
      print("On going");
      final appStorage = await getApplicationDocumentsDirectory();
      final file = File("${appStorage.path}/$name");

      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: 0,
        ),
      );

      final raf = file.openSync(mode: FileMode.write);

      raf.writeFromSync(response.data);
      await raf.close();
      print("DONE");

      return file;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  void onInit() async {
    tabController = TabController(vsync: this, length: myTabs.length);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    controllerVideo!.pause();
    controllerVideo!.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.onClose();
  }
}
