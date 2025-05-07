
extension StringExtension on String? {
  /// Check if string is null or blank
  bool isBlank() {
    if (this == null) {
      return true;
    } else {
      if (this!.isEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }

  /// Get first character of word(s)
  String? getFirstWordOfTitle({int countWord = 2}) {
    if (this != null) {
      List<String> splitWord = this!.split(' ');
      String initial = '';
      int countedWord = 0;
      for (var i = 0; i < splitWord.length; i++) {
        if (countedWord < countWord) {
          if (splitWord[i].isNotEmpty) {
            countedWord++;
            initial += splitWord[i].substring(0, 1);
          }
        } else {
          break;
        }
      }
      String name = initial.toUpperCase();
      return name;
    } else {
      return '';
    }
  }

  /// Check whether words contains any keyword
  /// ignoring any case
  bool containsIgnoreCase(String? keyword) {
    if (this == null) {
      return false;
    } else {
      if (keyword == null) {
        return false;
      } else {
        return this!.toLowerCase().contains(keyword.toLowerCase());
      }
    }
  }

  /// Check whether words equals some keyword
  /// ignoring any case
  bool equalsIgnoreCase(String? keyword) {
    if (this == null) {
      return false;
    } else {
      if (keyword == null) {
        return false;
      } else {
        return this!.toLowerCase() == keyword.toLowerCase();
      }
    }
  }

  /// Split string based on length of character
  /// [lengthSplit] and return list of String
  List<String> stringSplitter(int lengthSplit) {
    if (this == null) {
      return [];
    } else {
      List<String> listString = this!.split(' ');
      List<String> newListString = [];
      if (listString.isNotEmpty) {
        String tempString = listString[0];
        for (int i = 0; i < listString.length; i++) {
          if (i < (listString.length - 1)) {
            final int lengthString = 1 + tempString.length + listString[i + 1].length;
            if (lengthString <= lengthSplit) {
              tempString += ' ${listString[i + 1]}';
            } else {
              newListString.add(tempString);
              if (i < (listString.length - 1)) {
                tempString = listString[i + 1];
              }
            }
          } else {
            newListString.add(tempString);
          }
        }
      }
      return newListString;
    }
  }

  /// Extract data base64 inside string text
  /// separated by comma and return String
  String extractBase64() {
    if (this != null) {
      final List<String> splitString = this!.split(',');
      if (splitString.isNotEmpty) {
        return splitString.last;
      } else {
        return '';
      }
    } else {
      return '';
    }
  }
}
