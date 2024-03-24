import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:StreamFlix/ui/video_player.dart';

class ChannelListWidget extends StatelessWidget {
  const ChannelListWidget({
    Key? key,
    required this.documents,
  }) : super(key: key);

  final List<DocumentSnapshot<Object?>> documents;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        var matchData = documents[index].data() as Map<String, dynamic>?;

        if (matchData == null || !matchData.containsKey('matchName') || !matchData.containsKey('videoUrl')) {
          return const ListTile(
            title: Text('Invalid match data'),
          );
        }

        var matchName = matchData['matchName'];
        var videoUrl = matchData['videoUrl'];

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
                    builder: (context) => VideoPlayerWidget(channelUrl: videoUrl),
                  ),
                );
              } else {

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
      },
    );
  }
}
