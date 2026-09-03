import 'package:flutter_test/flutter_test.dart';
import 'package:bda_signal/bda_signal.dart';
import 'package:bda_signal/bda_signal_platform_interface.dart';
import 'package:bda_signal/bda_signal_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBdaSignalPlatform
    with MockPlatformInterfaceMixin
    implements BdaSignalPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BdaSignalPlatform initialPlatform = BdaSignalPlatform.instance;

  test('$MethodChannelBdaSignal is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBdaSignal>());
  });

  test('getPlatformVersion', () async {
    BdaSignal bdaSignalPlugin = BdaSignal();
    MockBdaSignalPlatform fakePlatform = MockBdaSignalPlatform();
    BdaSignalPlatform.instance = fakePlatform;

    expect(await bdaSignalPlugin.getPlatformVersion(), '42');
  });
}
