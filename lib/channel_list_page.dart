import 'package:elive/video_player.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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