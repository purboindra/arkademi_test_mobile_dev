import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:arkademi_test/app/data/model/save_video_model.dart';
import 'package:arkademi_test/app/data/model/video_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  Map<int, SaveVideoModel> saveItems = {};

  var isPlay = false.obs;

  var indexData = 0.obs;

  final _dataVideo = {}.obs;
  RxMap<dynamic, dynamic> get dataVideo => _dataVideo;

  RxList<Curriculum> videoDataList = <Curriculum>[].obs;

  late VideoPlayerController videoPlayerController;

  void changePlay(int index) {
    print(index);
  }

  void playVideo() {
    if (isPlay.isTrue) {
      videoPlayerController.play();
      isPlay.toggle();
    } else {
      videoPlayerController.pause();
      isPlay.toggle();
    }

    update();
  }

  // int globalIndex(int index) {
  //   return indexData.value = index;
  // }

  Future<void> getVideo(RxInt index) async {
    print(videoDataList[indexData.value].onlineVideoLink);
    initializeVideoPlayer(index);
    update();
  }

  Future<RxList<Curriculum>> fetchCurriculumData() async {
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

  Future<void> initializeVideoPlayer(RxInt index) async {
    videoPlayerController = VideoPlayerController.network(
        //when i use videoDataList[indexData.value].onlineVideoLink! for the data of video
        //Its getting error
        //The error talking about late initialized of videoPlayerController
        //As u know, i have initialize the videoPlayerController here
        //But still, its getting error there
        //But, when i hardcore the data of video by directly to link of video
        //its working
        "https://storage.googleapis.com/samplevid-bucket/offline_arsenal_westham.mp4"
        // videoDataList[index.value].onlineVideoLink!,
        );
    await Future.wait([videoPlayerController.initialize()]);
    update();
  }

  // void saveVideo(Curriculum curriculum) {
  //   if (!isSaveVideo(curriculum).value) {
  //     print("prev ${saveItems.length}");
  //     saveItems.putIfAbsent(curriculum.key!, () {
  //       Get.snackbar(
  //         "Success",
  //         "Save ${curriculum.title}",
  //         overlayBlur: 0,
  //         backgroundColor: Colors.teal,
  //         colorText: Colors.white,
  //       );
  //       return SaveVideoModel(
  //         key: curriculum.key,
  //         id: curriculum.id,
  //         type: curriculum.type,
  //         title: curriculum.title,
  //         duration: curriculum.duration,
  //         content: curriculum.content,
  //         status: curriculum.status,
  //         onlineVideoLink: curriculum.onlineVideoLink,
  //         offlineVideoLink: curriculum.offlineVideoLink,
  //       );
  //     });
  //     print("current ${saveItems.length}");
  //   } else {
  //     saveItems.remove(curriculum.key);
  //     print("current video ${saveItems.length}");
  //     print("UnSave");
  //   }
  //   update();
  // }

  // RxBool isSaveVideo(Curriculum curriculum) {
  //   if (saveItems.containsKey(curriculum.key)) {
  //     print("true");
  //     return true.obs;
  //   } else {
  //     print("false");
  //     return false.obs;
  //   }
  // }

  Future openFile({required String url, String? fileName}) async {
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
    initializeVideoPlayer(indexData);
    // getVideo(indexData);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    videoPlayerController.dispose();
    super.onClose();
  }
}
