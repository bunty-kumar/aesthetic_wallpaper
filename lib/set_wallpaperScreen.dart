import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:shimmer/shimmer.dart';
import 'constants.dart';

class SetWallpaperScreen extends StatefulWidget {
  final String wallpaperUrl;

  const SetWallpaperScreen({Key? key, required this.wallpaperUrl})
      : super(key: key);

  @override
  State<SetWallpaperScreen> createState() => _SetWallpaperScreenState();
}

class _SetWallpaperScreenState extends State<SetWallpaperScreen> {
  String _wallpaperUrlHome = 'Unknown';
  String _wallpaperUrlLock = 'Unknown';
  String _wallpaperUrlBoth = 'Unknown';

  bool isLoading = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> setWallpaperHome() async {
    setState(() {
      _wallpaperUrlHome = 'Loading';
    });
    String result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await AsyncWallpaper.setWallpaper(
        url: widget.wallpaperUrl,
        wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
        toastDetails: ToastDetails.success(),
        errorToastDetails: ToastDetails.error(),
      )
          ? 'Wallpaper set'
          : 'Failed to get wallpaper.';
      setState(() {
        _wallpaperUrlHome = 'Unknown';
      });
    } on PlatformException {
      setState(() {
        _wallpaperUrlHome = 'Unknown';
      });
      result = 'Failed to get wallpaper.';
    }
    if (!mounted) return;
    setState(() {
      _wallpaperUrlHome = result;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> setWallpaperLock() async {
    setState(() {
      _wallpaperUrlLock = 'Loading';
    });
    String result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await AsyncWallpaper.setWallpaper(
        url: widget.wallpaperUrl,
        wallpaperLocation: AsyncWallpaper.LOCK_SCREEN,
        toastDetails: ToastDetails.success(),
        errorToastDetails: ToastDetails.error(),
      )
          ? 'Wallpaper set'
          : 'Failed to get wallpaper.';
      setState(() {
        _wallpaperUrlLock = 'Unknown';
      });
    } on PlatformException {
      setState(() {
        _wallpaperUrlLock = 'Unknown';
      });
      result = 'Failed to get wallpaper.';
    }
    if (!mounted) return;

    setState(() {
      _wallpaperUrlLock = result;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> setWallpaperBoth() async {
    setState(() {
      _wallpaperUrlBoth = 'Loading';
    });
    String result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await AsyncWallpaper.setWallpaper(
        url: widget.wallpaperUrl,
        wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
        toastDetails: ToastDetails.success(),
        errorToastDetails: ToastDetails.error(),
      )
          ? 'Wallpaper set'
          : 'Failed to get wallpaper.';
      setState(() {
        _wallpaperUrlBoth = 'Unknown';
      });
    } on PlatformException {
      setState(() {
        _wallpaperUrlBoth = 'Unknown';
      });
      result = 'Failed to get wallpaper.';
    }
    if (!mounted) return;

    setState(() {
      _wallpaperUrlBoth = result;
    });
  }

  void _saveNetworkImage() async {
    setState(() {
      isLoading = true;
    });
    String path = widget.wallpaperUrl;
    GallerySaver.saveImage(path).then((value) {
      if (value != null && value) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image Saved Successfully")));
        setState(() {
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Some error occurred in downloading image")));
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Wallpaper"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == '1') {
                setWallpaperHome();
              } else if (value == '2') {
                setWallpaperLock();
              } else if (value == '3') {
                setWallpaperBoth();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: '1',
                  child: Text('Set On Home Screen'),
                ),
                const PopupMenuItem(
                  value: '2',
                  child: Text('Set on Lock Screen'),
                ),
                const PopupMenuItem(
                  value: '3',
                  child: Text('Set on Home And Lock Screen'),
                ),
                // Add more menu items as needed
              ];
            },
          ),
        ],
      ),
      body: Container(
          margin:
              const EdgeInsets.only(left: 12, right: 16, top: 16, bottom: 16),
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  width: double.infinity,
                  imageUrl: widget.wallpaperUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: mediumGreyColor,
                    highlightColor: lightGreyColor,
                    child: Container(
                      color: Colors.grey,
                      width: double.infinity,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              _wallpaperUrlHome == "Loading" ||
                      _wallpaperUrlLock == "Loading" ||
                      _wallpaperUrlBoth == "Loading" ||
                      isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColorLight,
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _saveNetworkImage,
                        child: const Text(
                          'Download',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
            ],
          )),
    );
  }
}
