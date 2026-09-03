import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bda_signal_platform_interface.dart';

/// An implementation of [BdaSignalPlatform] that uses method channels.
class MethodChannelBdaSignal extends BdaSignalPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bda_signal');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
