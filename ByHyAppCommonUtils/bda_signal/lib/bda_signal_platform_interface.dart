import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bda_signal_method_channel.dart';

abstract class BdaSignalPlatform extends PlatformInterface {
  /// Constructs a BdaSignalPlatform.
  BdaSignalPlatform() : super(token: _token);

  static final Object _token = Object();

  static BdaSignalPlatform _instance = MethodChannelBdaSignal();

  /// The default instance of [BdaSignalPlatform] to use.
  ///
  /// Defaults to [MethodChannelBdaSignal].
  static BdaSignalPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BdaSignalPlatform] when
  /// they register themselves.
  static set instance(BdaSignalPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
