import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String channelUrl;

  const VideoPlayerWidget({Key? key, required this.channelUrl}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  bool isLoading = true;
  bool isFullScreen = false;
  bool showControls = true;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    Wakelock.disable();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  showControls = true;
                  _startTimer();
                });
              },
              child: AspectRatio(
                aspectRatio: isFullScreen
                    ? MediaQuery.of(context).size.aspectRatio
                    : _videoPlayerController.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_videoPlayerController),
                    if (isLoading)
                      Center(child: const CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
            if (!isLoading && showControls) ...[
              Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isFullScreen) ...[
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isFullScreen = true;
                            _enterFullScreen();
                          });
                        },
                        icon: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isFullScreen = false;
                            _exitFullScreen();
                          });
                        },
                        icon: const Icon(
                          Icons.fullscreen_exit,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_videoPlayerController.value.isPlaying) {
                            _videoPlayerController.pause();
                          } else {
                            _videoPlayerController.play();
                          }
                        });
                      },
                      icon: Icon(
                        _videoPlayerController.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.channelUrl);

    await _videoPlayerController.initialize();
    setState(() {
      isLoading = false;
    });
    _videoPlayerController.play();
    Wakelock.enable();
    _startTimer();
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        showControls = false;
      });
    });
  }
}
