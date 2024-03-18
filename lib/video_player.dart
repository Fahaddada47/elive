import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);

    return Scaffold(
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
      )
          : OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoPlayerController.value.isPlaying) {
                      _videoPlayerController.pause();
                    } else {
                      _videoPlayerController.play();
                    }
                  });
                },
                child: AspectRatio(
                  aspectRatio: _calculateAspectRatio(orientation),
                  child: VideoPlayer(_videoPlayerController),
                ),
              ),
              Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isFullScreen = !isFullScreen;
                          if (isFullScreen) {
                            _enterFullScreen();
                          } else {
                            _exitFullScreen();
                          }
                        });
                      },
                      icon: Icon(
                        isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                      ),
                    ),
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
          );
        },
      ),
    );
  }

  double _calculateAspectRatio(Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return _videoPlayerController.value.aspectRatio;
    } else {
      // Landscape mode
      return MediaQuery.of(context).size.aspectRatio;
    }
  }

  void _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.channelUrl);

    await _videoPlayerController.initialize();
    setState(() {
      isLoading = false;
    });
    _videoPlayerController.play();
    Wakelock.enable();
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() {
      isFullScreen = true;
    });
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    setState(() {
      isFullScreen = false;
    });
  }
}

class ChannelListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matches'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tvlist').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var matchData = documents[index].data() as Map<String, dynamic>?;

              if (matchData == null || !matchData.containsKey('matchName') || !matchData.containsKey('videoUrl')) {
                return ListTile(
                  title: Text('Invalid match data'),
                );
              }

              var matchName = matchData['matchName'];
              var videoUrl = matchData['videoUrl'];

              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    if (videoUrl != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerWidget(channelUrl: videoUrl),
                        ),
                      );
                    } else {
                      // Handle null or missing video URL if necessary
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.sports_soccer, size: 40.0, color: Colors.blue),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            matchName ?? 'No match name',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        Icon(Icons.play_arrow, size: 40.0, color: Colors.green),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

