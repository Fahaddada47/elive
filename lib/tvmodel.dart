import 'package:cloud_firestore/cloud_firestore.dart';

class TvModel {
  String name;
  String url;

  TvModel({
    required this.name,
    required this.url,
  });

  TvModel.fromJson(Map<String , Object> josn) : this
}
