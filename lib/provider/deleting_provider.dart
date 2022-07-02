import 'package:flutter/foundation.dart';

class DeleteProvider extends ChangeNotifier {
  bool deleting;
  String chatDocIndex;
  bool get getDeleting {
    return deleting;
  }

  String get getChatDocIndex {
    return chatDocIndex;
  }

  void changeDeleting(bool input, String chatInd) {
    deleting = input;
    chatDocIndex = chatInd;
    notifyListeners();
  }
}
