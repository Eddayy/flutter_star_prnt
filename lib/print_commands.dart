import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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

  openCashDrawer(int actionNumber) {
    this._commands.add({"openCashDrawer": actionNumber});
  }

  /// Prints an image with a url or a file [path].
  /// Set [bothScale] to scale the image to [width] of receipt
  appendBitmap({
    required String path,
    bool diffusion = true,
    int width = 576,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
  }) {
    Map<String, dynamic> command = {
      "appendBitmap": path,
    };
    command['bothScale'] = bothScale;
    command['diffusion'] = diffusion;
    command['width'] = width;
    if (absolutePosition != null)
      command['absolutePosition'] = absolutePosition;
    if (alignment != null) command['alignment'] = alignment.text;
    if (rotation != null) command['rotation'] = rotation.text;

    this._commands.add(command);
  }

  appendBitmapByte({
    required Uint8List byteData,
    int? fontSize,
    bool diffusion = true,
    int width = 576,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
  }) {
    Map<String, dynamic> command = {
      "appendBitmapByteArray": byteData,
    };
    command['bothScale'] = bothScale;
    command['diffusion'] = diffusion;
    command['width'] = width;
    if (absolutePosition != null)
      command['absolutePosition'] = absolutePosition;
    if (alignment != null) command['alignment'] = alignment.text;
    if (rotation != null) command['rotation'] = rotation.text;

    this._commands.add(command);
  }

  appendBitmapText({
    required String text,
    int? fontSize,
    bool diffusion = true,
    int? width,
    bool bothScale = true,
    int? absolutePosition,
    StarAlignmentPosition? alignment,
    StarBitmapConverterRotation? rotation,
  }) {
    Map<String, dynamic> command = {
      "appendBitmapText": text,
    };
    command['bothScale'] = bothScale;
    command['diffusion'] = diffusion;
    if (fontSize != null) command['fontSize'] = fontSize;
    if (width != null) command['width'] = width;
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

  static Future<Uint8List?> createImageFromWidget(
    Widget widget, {
    Duration? wait,
    Size? logicalSize,
    Size? imageSize,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    logicalSize ??= ui.window.physicalSize / ui.window.devicePixelRatio;
    imageSize ??= ui.window.physicalSize;
    assert(logicalSize.aspectRatio == imageSize.aspectRatio);
    final RenderView renderView = RenderView(
      window: WidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner();

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: textDirection,
        child: IntrinsicHeight(child: IntrinsicWidth(child: widget)),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    if (wait != null) {
      await Future.delayed(wait);
    }

    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();

    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: imageSize.width / logicalSize.width,
    );
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }
}
