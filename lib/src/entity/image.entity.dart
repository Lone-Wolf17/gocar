import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gocar/src/infra/infra.dart';

class MyImage {
  MyImage({this.url = '', this.code = '', this.indicatesOnLine = true});

  String url;
  String code;
  bool indicatesOnLine;

  /*if true, get it from the internet*/

  MyImage.fromSnapshotJson(DocumentSnapshot snapshot)
      : url = snapshot.data["image"]["url"],
        indicatesOnLine = snapshot.data["image"]["indicatesOnLine"],
        code = snapshot.data["image"]["code"];

  MyImage.fromMap(Map<dynamic, dynamic> data)
      : url = data["url"],
        indicatesOnLine = data["indicatesOnLine"],
        code = data["code"];

  toJson() {
    return {
      "url": this.url,
      "indicatesOnLine": this.indicatesOnLine,
      "code": this.code == '' ? HelpService.generateCode(12) : this.code,
    };
  }
}
