
import 'package:fluent_ui/fluent_ui.dart';

class AppContext extends ChangeNotifier {

  final List<String> _messages = [];

  List<String> get messages => _messages;

  void addMessage(String message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

}