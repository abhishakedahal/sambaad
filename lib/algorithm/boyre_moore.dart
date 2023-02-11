// ignore: file_names
import 'dart:math';

class BMAlgorithm{

 // ignore: non_constant_identifier_names
 static bool BoyerMoore(String searchText, String message) {
  int n = message.length;
  int m = searchText.length;
  List<int> right = List.filled(256, -1);

  for (int j = 0; j < m; j++) {
    right[searchText.codeUnitAt(j)] = j;
  }

  int skip;
  for (int i = 0; i <= n - m; i += skip) {
    skip = 0;
    for (int j = m - 1; j >= 0; j--) {
      if (searchText[j] != message[i + j]) {
        skip = max(1, j - right[message.codeUnitAt(i + j)]);
        break;
      }
    }
    if (skip == 0) {
      return true;
    }
  }
  return false;
}
}