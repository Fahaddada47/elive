import 'package:flutter/material.dart';
import 'package:StreamFlix/ui/video_player.dart';
class ChannelCard extends StatelessWidget {
  final String? matchName;
  final String? videoUrl;

  const ChannelCard({Key? key, this.matchName, this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white70,
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () {
          if (videoUrl != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerWidget(channelUrl: videoUrl!),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.live_tv, size: 40.0, color: Colors.blue),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  matchName ?? 'No match name',
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
              const Icon(Icons.play_arrow, size: 40.0, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}