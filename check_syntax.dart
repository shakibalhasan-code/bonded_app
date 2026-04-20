import 'dart:io';

void main() {
  var file = File('lib/screens/circles/circle_details_screen.dart');
  var content = file.readAsStringSync();
  int openBraces = 0;
  for (int i = 0; i < content.length; i++) {
    if (content[i] == '{') openBraces++;
    if (content[i] == '}') openBraces--;
  }
  print('Brace balance: $openBraces');
}
