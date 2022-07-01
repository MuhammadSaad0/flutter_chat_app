import 'package:flutter/foundation.dart';

class Reply extends ChangeNotifier {
  String reply = "";

  String get getreply {
    return reply;
  }

  void changeReply(String input) async {
    reply = input;
    await notifyListeners();
  }

  void removeReply() {
    reply = "";
    notifyListeners();
  }
}
