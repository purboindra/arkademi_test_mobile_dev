import 'package:arkademi_test/app/data/model/video_model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:video_player/video_player.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    double percent = 0;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 65,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        title: FutureBuilder<RxMap<dynamic, dynamic>>(
            future: controller.fetchAllData(),
            builder: (context, snapshotAppBar) {
              if (snapshotAppBar.connectionState == ConnectionState.waiting) {
                return SizedBox();
              }
              if (snapshotAppBar.hasData) {
                RxMap<dynamic, dynamic> data = snapshotAppBar.data!;
                return Row(
                  children: [
                    Icon(
                      Icons.arrow_back_sharp,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        data["course_name"],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              } else {
                return SizedBox();
              }
            }),
        actions: [
          FutureBuilder<RxMap<dynamic, dynamic>>(
              future: controller.fetchAllData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data;

                  var percentParse = double.parse(data!["progress"]);
                  double resultPercent = percentParse * 10 / 100 / 10;
                  percent = resultPercent;
                  return CircularPercentIndicator(
                    radius: 23,
                    lineWidth: 4,
                    percent: percent,
                    center: Text(
                      "${data["progress"]}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              }),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<RxList<Curriculum>>(
                future:
                    controller.fetchCurriculumData(controller.indexData.value),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Something Wrong"),
                    );
                  }
                  if (snapshot.hasData) {
                    RxList<Curriculum> data = snapshot.data!;

                    return PageView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, indexP) {
                          return CustomScrollView(
                            physics: BouncingScrollPhysics(),
                            slivers: [
                              //VIDEO
                              SliverToBoxAdapter(
                                child: _videoSection(data),
                              ),
                              // SliverToBoxAdapter(
                              //   child: _controlView(),
                              // ),
                              _tabBar(),
                              SliverToBoxAdapter(
                                child: _bodyListView(data),
                              )
                            ],
                          );
                        });
                  }
                  return Center(
                    child: Text("data"),
                  );
                }),
          ),
        ],
      ),
      bottomNavigationBar: NextAndPrevButton(),
      floatingActionButton: FloatingActionButton(
        tooltip: "Download Video",
        child: Center(
          child: Icon(Icons.add),
        ),
        onPressed: () {
          //If video not showing up
          //try to restart app
          if (controller
                  .videoDataList[controller.indexData.value].onlineVideoLink !=
              null) {
            controller.openFile(
              url: controller
                  .videoDataList[controller.indexData.value].onlineVideoLink!,
              fileName: "video.mp4",
            );
          } else {
            Get.snackbar(
              "Ooops",
              "There is no available video for now!",
            );
          }
        },
      ),
    );
  }

  Widget _controlView() {
    return Container(
      height: 60,
      width: Get.width,
      child: Obx(() => Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: controller.videoDataList[controller.indexData.value]
                              .onlineVideoLink !=
                          null
                      ? InkWell(
                          onTap: () {
                            controller.muteVideo();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 2.0,
                                    color: Color.fromARGB(
                                      50,
                                      0,
                                      0,
                                      0,
                                    ),
                                  ),
                                ],
                              ),
                              child: Icon(
                                controller.noMute.isTrue
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final index = controller.isPlayingIndex - 1;
                      if (index >= 0 &&
                          controller.controllerVideo != null &&
                          controller.videoDataList[index].onlineVideoLink !=
                              null) {
                        controller.playVideo(index);
                      } else {
                        Get.snackbar('OOppps', "Something wrong");
                      }
                    },
                    icon: Icon(Icons.fast_rewind),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (controller.videoDataList[controller.indexData.value]
                              .onlineVideoLink !=
                          null) {
                        if (controller.isPlaying.value) {
                          controller.controllerVideo!.pause();
                        } else {
                          controller.controllerVideo!.play();
                        }
                      }
                    },
                    icon: Icon(controller.isPlaying.isTrue
                        ? Icons.pause
                        : Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: () async {
                      final index = controller.isPlayingIndex + 1;
                      if (index <= 0 &&
                          controller.controllerVideo != null &&
                          controller.videoDataList[index].onlineVideoLink !=
                              null) {
                        controller.playVideo(index);
                      } else {
                        Get.snackbar('OOppps', "No more video");
                      }
                    },
                    icon: Icon(Icons.fast_forward),
                  ),
                ],
              ),
              Expanded(
                  child: Container(
                height: 60,
              )),
            ],
          )),
    );
  }

  SizedBox _videoSection(RxList<Curriculum> data) {
    return SizedBox(
      height: 350,
      child: Obx(
        () => Column(
          children: [
            InkWell(
              onTap: () {},
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GetBuilder<HomeController>(builder: (homeC) {
                    return AspectRatio(
                      aspectRatio: 16 / 9,
                      child: homeC.videoDataList[controller.indexData.value]
                                      .onlineVideoLink !=
                                  null &&
                              homeC.controllerVideo!.value.isInitialized
                          ? VideoPlayer(homeC.controllerVideo!)
                          // ? Center(
                          //     child: Text("data"),
                          //   )
                          : Center(
                              child: Icon(
                                Icons.error,
                                size: 48,
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            _controlView(),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              alignment: Alignment.bottomLeft,
              child: Text(
                "${data[controller.indexData.value].title}",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _bodyListView(List<Curriculum> data) {
    return SizedBox(
      height: Get.height,
      child: TabBarView(
        controller: controller.tabController,
        children: [
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              var doc = parse(data[index].title);
              if (doc.documentElement != null) {
                String parsedString = doc.documentElement!.text;
                controller.parsedTitle = parsedString;
              }
              return Container(
                margin: EdgeInsets.only(
                  bottom: 10,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                color: data[index].title == 'PENGANTAR' ||
                        data[index].title == 'PENUTUP'
                    ? Colors.grey.shade300
                    : Colors.white,
                child: Row(
                  children: [
                    Material(
                      child: InkWell(
                        onTap: () {},
                        child: data[index].title == 'PENGANTAR' ||
                                data[index].title == 'PENUTUP'
                            ? SizedBox()
                            : ClipOval(
                                child: Container(
                                padding: EdgeInsets.all(
                                  5,
                                ),
                                color: Colors.grey.shade400,
                                child: Icon(
                                  // controller.playButton(index).isTrue
                                  //     ? Icons.pause
                                  //     : Icons.play_arrow,
                                  Icons.play_arrow,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              )),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          controller.indexData.value = data[index].key!;
                          controller.playVideo(data[index].key!);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.parsedTitle!,
                              maxLines: 2,
                              style: TextStyle(
                                  fontWeight:
                                      data[index].title == 'PENGANTAR' ||
                                              data[index].title == 'PENUTUP'
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${data[index].type}",
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GetBuilder<HomeController>(
                      init: HomeController(),
                      builder: (homec) {
                        return data[index].title == 'PENGANTAR' ||
                                data[index].title == 'PENUTUP'
                            ? SizedBox()
                            : InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Simpan",
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      // Icon(
                                      //   Icons.check,
                                      //   color: Colors.blue,
                                      //   size: 16,
                                      // ),
                                    ],
                                  ),
                                ),
                              );
                      },
                    )
                  ],
                ),
              );
            },
          ),
          Center(
            child: Text("Ikhtisar"),
          ),
          Center(
            child: Text("Lampiran"),
          ),
        ],
      ),
    );
  }

  SliverAppBar _tabBar() {
    return SliverAppBar(
      elevation: 0.5,
      pinned: true,
      floating: true,
      backgroundColor: Colors.white,
      flexibleSpace: TabBar(
        indicatorWeight: 5,
        indicatorColor: Colors.blue,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 16,
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black45,
        tabs: controller.myTabs,
        controller: controller.tabController,
      ),
      toolbarHeight: 50,
    );
  }
}

class NextAndPrevButton extends StatelessWidget {
  const NextAndPrevButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      width: Get.width,
      child: SafeArea(
        minimum: EdgeInsets.symmetric(
          vertical: 10,
        ),
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.chevron_left, size: 32),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Sebelumnya",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Selanjutnya",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 32,
                  color: Colors.grey.shade500,
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
