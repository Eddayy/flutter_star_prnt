import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_star_prnt_method_channel.dart';

abstract class FlutterStarPrntPlatform extends PlatformInterface {
  /// Constructs a FlutterStarPrntPlatform.
  FlutterStarPrntPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterStarPrntPlatform _instance = MethodChannelFlutterStarPrnt();

  /// The default instance of [FlutterStarPrntPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterStarPrnt].
  static FlutterStarPrntPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterStarPrntPlatform] when
  /// they register themselves.
  static set instance(FlutterStarPrntPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
