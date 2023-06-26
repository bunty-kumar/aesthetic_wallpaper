import 'dart:convert';
import 'dart:developer';
import 'package:aesthetic_wallpaper/set_wallpaperScreen.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'constants.dart';

class WallpaperApp extends StatefulWidget {
  const WallpaperApp({Key? key}) : super(key: key);

  @override
  State<WallpaperApp> createState() => _WallpaperAppState();
}

class _WallpaperAppState extends State<WallpaperApp> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  TextEditingController searchController = TextEditingController();
  List<String> wallpaperUrls = [];
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWallpapers("refresh");
  }

  Future<void> fetchWallpapers(String type) async {
    const apiKey = appKey;
    const perPage = 40;
    if (type != "Loading") {
      setState(() {
        isLoading = true;
      });
    }
    final response = await http.get(
      Uri.parse(
          'https://api.pexels.com/v1/curated?page=$currentPage&per_page=$perPage'),
      headers: {'Authorization': apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> photosData = data['photos'];

      setState(() {
        wallpaperUrls.addAll(photosData.map<String>((photoData) {
          return photoData['src']['large2x'];
        }));
        isLoading = false;
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
      });
      log("response success $photosData");
    } else {
      isLoading = false;
      _refreshController.refreshFailed();
      _refreshController.loadFailed();
      log("response failed ${response.statusCode}");
      setState(() {});
    }
  }

  void _onRefresh() {
    setState(() {
      wallpaperUrls.clear();
      currentPage = 1;
    });
    if (searchController.text.isNotEmpty) {
      searchWallpapers("refresh", searchController.text);
    } else {
      fetchWallpapers("refresh");
    }
  }

  void _onLoading() {
    currentPage++;
    if (searchController.text.isNotEmpty) {
      searchWallpapers("Loading", searchController.text);
    } else {
      fetchWallpapers("Loading");
    }
  }

  Future<void> searchWallpapers(String type, String query) async {
    const apiKey = appKey;
    const perPage = 40;
    if (type != "Loading") {
      setState(() {
        isLoading = true;
      });
    }
    final response = await http.get(
      Uri.parse(
          "https://api.pexels.com/v1/search?query=$query&page=$currentPage&per_page=$perPage"),
      headers: {'Authorization': apiKey},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> photosData = data['photos'];
      setState(() {
        if (type != "Loading") {
          wallpaperUrls.clear();
        }
        wallpaperUrls.addAll(photosData.map<String>((photoData) {
          return photoData['src']['large2x'];
        }));
        isLoading = false;
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
      });
      log("response success $photosData");
    } else {
      isLoading = false;
      _refreshController.refreshFailed();
      _refreshController.loadFailed();
      setState(() {});
      log("response failed ${response.statusCode}");
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper App'),
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to exit'),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: TextField(
                  controller: searchController,
                  onSubmitted: (value) {
                    searchWallpapers(
                        "refresh", searchController.text.toString().trim());
                  },
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      hintText: "Search here...",
                      suffixIcon: InkWell(
                          onTap: () {
                            searchWallpapers("refresh",
                                searchController.text.toString().trim());
                          },
                          child: const Icon(Icons.search)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide())),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                  child: isLoading
                      ? GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 15,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: mediumGreyColor,
                              highlightColor: lightGreyColor,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 12, right: 12, bottom: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.grey,
                                    height: 250,
                                  ),
                                ),
                              ),
                            );
                          },
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                        )
                      : SmartRefresher(
                          controller: _refreshController,
                          enablePullDown: true,
                          enablePullUp: true,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          child: wallpaperUrls.isNotEmpty
                              ? GridView.builder(
                                  itemCount: wallpaperUrls.length,
                                  itemBuilder: (context, index) {
                                    final wallpaperUrl = wallpaperUrls[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SetWallpaperScreen(
                                              wallpaperUrl: wallpaperUrl,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 12, right: 12, bottom: 16),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: CachedNetworkImage(
                                            width: double.infinity,
                                            height: 250,
                                            imageUrl: wallpaperUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Shimmer.fromColors(
                                              baseColor: mediumGreyColor,
                                              highlightColor: lightGreyColor,
                                              child: Container(
                                                color: Colors.grey,
                                                height: 250,
                                                width: double.infinity,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                )
                              : const Center(child: Text("No Image Found")),
                        )),
            ],
          ),
        ),
      ),
    );
  }
}
