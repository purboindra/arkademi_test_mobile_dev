import 'package:arkademi_test/app/data/model/video_model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:video_player/video_player.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    controller.fetchCurriculumData();

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
            child: FutureBuilder<List<Curriculum>>(
                future: controller.fetchCurriculumData(),
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
                    List<Curriculum> data = snapshot.data!;
                    return PageView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, indexP) {
                          return CustomScrollView(
                            physics: BouncingScrollPhysics(),
                            slivers: [
                              //VIDEO
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 320,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            controller.playVideo();
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: controller
                                                            .videoDataList[
                                                                controller
                                                                    .indexData
                                                                    .value]
                                                            .onlineVideoLink !=
                                                        null
                                                    ? VideoPlayer(controller
                                                        .videoPlayerController)
                                                    : Center(
                                                        child: Icon(
                                                          Icons.error,
                                                          size: 48,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                                ),
                              ),

                              //TAB BAR
                              SliverAppBar(
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
                              ),

                              //CONTENT LIST
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: Get.height,
                                  child: TabBarView(
                                    controller: controller.tabController,
                                    children: [
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: data.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 10,
                                            ),
                                            color: data[index].title ==
                                                        'PENGANTAR' ||
                                                    data[index].title ==
                                                        'PENUTUP'
                                                ? Colors.grey.shade300
                                                : Colors.white,
                                            child: Row(
                                              children: [
                                                Obx(
                                                  () => InkWell(
                                                    onTap: () {
                                                      controller
                                                              .indexData.value =
                                                          data[index].key!;
                                                      // controller.isSaveVideo(
                                                      //     data[controller
                                                      //         .indexData
                                                      //         .value]);
                                                      // controller.playVideo();
                                                      // controller.changePlay(
                                                      //   data[controller
                                                      //       .indexData.value],
                                                      //   controller
                                                      //       .indexData.value,
                                                      // );
                                                    },
                                                    child: data[index].title ==
                                                                'PENGANTAR' ||
                                                            data[index].title ==
                                                                'PENUTUP'
                                                        ? SizedBox()
                                                        : ClipOval(
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                5,
                                                              ),
                                                              color: Colors.grey
                                                                  .shade400,
                                                              child: Icon(
                                                                // controller
                                                                //         .isSaveVideo(data[
                                                                //             index])
                                                                //         .isTrue
                                                                //     ? Icons
                                                                //         .pause
                                                                //     : Icons
                                                                //         .play_arrow,
                                                                Icons
                                                                    .play_arrow,
                                                                size: 20,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller
                                                              .indexData.value =
                                                          data[index].key!;

                                                      // controller.globalIndex(
                                                      //     controller
                                                      //         .indexData.value);
                                                      controller.getVideo(
                                                          controller.indexData);
                                                    },
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${data[index].title}",
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              fontWeight: data[index]
                                                                              .title ==
                                                                          'PENGANTAR' ||
                                                                      data[index]
                                                                              .title ==
                                                                          'PENUTUP'
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .w500,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
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
                                                data[index].title ==
                                                            'PENGANTAR' ||
                                                        data[index].title ==
                                                            'PENUTUP'
                                                    ? SizedBox()
                                                    : InkWell(
                                                        onTap: () {
                                                          // controller.saveVideo(
                                                          //     data[controller
                                                          //         .indexData
                                                          // .value]);
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 15,
                                                            vertical: 7,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .shade500,
                                                            ),
                                                          ),
                                                          child: GetBuilder<
                                                              HomeController>(
                                                            builder: (homeC) {
                                                              return Row(
                                                                children: [
                                                                  Text(
                                                                    // homeC
                                                                    //         .isSaveVideo(data[index])
                                                                    //         .isTrue
                                                                    //     ? "Tersimpan"
                                                                    //     : "Simpan",
                                                                    "Simpan",
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  // Icon(
                                                                  //   Icons.check,
                                                                  //   color:
                                                                  //       Colors.blue,
                                                                  //   size: 16,
                                                                  // ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
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
                                ),
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
          controller.openFile(
            url:
                "https://storage.googleapis.com/samplevid-bucket/offline_arsenal_westham.mp4",
            fileName: "video.mp4",
          );
        },
      ),
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
