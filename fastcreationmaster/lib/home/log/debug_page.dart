import 'dart:io';

import 'package:byhy_app_common_utils/app_common/consts/build_config.dart';
import 'package:byhy_app_common_utils/app_common/consts/environment.dart';
import 'package:byhy_app_common_utils/app_http/dio_utils.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';


class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<StatefulWidget> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final TextEditingController _controller = TextEditingController();

  String setSuccess = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("调试页面"),
      ),
      body: CustomScrollView(
        slivers: [
          ///设置网络代理
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "当前环境:${Environment.TEST}\n当前channel:${BuildConfig.instance.channelType.name};${BuildConfig.instance.channelType.channel};${BuildConfig.instance.channelType.code}"),
                const Text("设置网络代理（杀死应用后需要重新设置）"),
                TextField(
                  autofocus: false,
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: "192.169.0.1:8888"),
                ),
                TextButton(
                    onPressed: () {
                      String text = _controller.text;

                      DioUtils.instance.dio.httpClientAdapter =
                          IOHttpClientAdapter(
                        createHttpClient: () {
                          final client = HttpClient();
                          client.findProxy = (uri) {
                            // 将请求代理至 localhost:8888。
                            // 请注意，代理会在你正在运行应用的设备上生效，而不是在宿主平台生效。
                            return "PROXY ${text}";
                          };
                          // 抓Https包设置
                          client.badCertificateCallback =
                              (X509Certificate cert, String host, int port) =>
                                  true;
                          return client;
                        },
                      );
                      setState(() {
                        setSuccess = "设置成功";
                      });
                    },
                    child: Text("确认")),
                Text(setSuccess)
              ],
            ),
          )
        ],
      ),
    );
  }
}
