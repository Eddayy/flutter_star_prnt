import 'package:flutter/foundation.dart';
import 'package:flutter_star_prnt/enums.dart';

class PrintCommands {
  List<Map<String, dynamic>> _commands = [];

  List<Map<String, dynamic>> getCommands() {
    return _commands;
  }

  appendEncoding(StarEncoding encoding) {
    this._commands.add({"appendEncoding": encoding.text});
  }

  appendCutPaper(StarCutPaperAction action) {
    this._commands.add({"appendCutPaper": action.text});
  }

  appendBitmapText({
    @required String text,
    int fontSize,
    bool diffusion = true,
    int width,
    bool bothScale = true,
    int absolutePosition,
    StarAlignmentPosition alignment,
    StarBitmapConverterRotation rotation,
  }) {
    Map<String, dynamic> command = {
      "appendBitmapText": text,
    };
    if (fontSize != null) command['fontSize'] = fontSize;
    if (width != null) command['width'] = fontSize;
    if (bothScale != null) command['bothScale'] = bothScale;
    if (absolutePosition != null)
      command['absolutePosition'] = absolutePosition;
    if (alignment != null) command['alignment'] = alignment.text;
    if (rotation != null) command['rotation'] = rotation.text;

    this._commands.add(command);
  }

  push(Map<String, dynamic> command) {
    this._commands.add(command);
  }

  clear() {
    this._commands.clear();
  }
}
