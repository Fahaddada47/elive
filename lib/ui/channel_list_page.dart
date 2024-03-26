import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:StreamFlix/widget/channel_list_widget.dart';

class ChannelDataFetcher {
  Stream<QuerySnapshot> getChannelStream() {
    return FirebaseFirestore.instance.collection('tvlist').snapshots();
  }
}

class ChannelListPage extends StatelessWidget {
  const ChannelListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Live Event'),
      ),
      body: ChannelListView(),
    );
  }
}

class ChannelListView extends StatelessWidget {
  final ChannelDataFetcher _dataFetcher = ChannelDataFetcher();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dataFetcher.getChannelStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var matchData = documents[index].data() as Map<String, dynamic>?;
            if (matchData == null ||
                !matchData.containsKey('matchName') ||
                !matchData.containsKey('videoUrl')) {
              return const ListTile(
                title: Text('Invalid match data'),
              );
            }

            var matchName = matchData['matchName'];
            var videoUrl = matchData['videoUrl'];

            return ChannelCard(
              matchName: matchName,
              videoUrl: videoUrl,
            );
          },
        );
      },
    );
  }
}



