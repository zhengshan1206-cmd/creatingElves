/*
 * @Author: cold-x
 * @Date: 2025-05-28 10:09:05
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-06-08 17:04:59
 * @FilePath: /fastcreationmaster/lib/main.dart
 * @Description: 
 */
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_common_utils.dart';
import 'package:byhy_app_common_utils/app_common/consts/build_config.dart';
import 'package:byhy_app_common_utils/app_common/consts/environment.dart';
import 'package:byhy_app_common_utils/app_common/consts/environment_config.dart';
import 'package:byhy_app_common_utils/app_http/channel.dart';
import 'package:fast_creation_master/core/cache/global_controller.dart';
import 'package:fast_creation_master/global/initialize/initialize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'global/routes/app_pages.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'global/routes/navogator_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  FlutterBugly.postCatchedException(
    () {
      BuildConfig.instantiate(
        envType: Environment.PRODUCTION,
        envConfig: EnvironmentConfig(),
      channelType: ChannelType.oppo,
      );

      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setPreferredOrientations([
        // 强制竖屏
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      ///app 初始化
      InitializeManager.initializition();

      runApp(const MyApp());
    },
    onException: (FlutterErrorDetails details) {
      byDebugPrint("检测到异常：\n${details.exception}");
      FlutterBugly.uploadException(
          message: "长文小说App异常捕获", detail: "${details.exception}");
    },
    debugUpload: true,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        title: 'Ai小说创作精灵',
        navigatorKey: navigatorKey,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
            )),
        supportedLocales: const [
          Locale('zh', 'CN'), // 简体中文
        ],
        locale: Get.deviceLocale, // 默认语言
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.launch,
        initialBinding: GlobalBinding(),
        defaultTransition: Platform.isIOS ? Transition.native : Transition.fadeIn,
        builder: (context, child) {
          // return BotToastInit()(context, child);
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: BotToastInit()(context, child));
        },
        navigatorObservers: [
          BotToastNavigatorObserver(),
          routeObserver,
          MyRouteObserver()
        ],
      ),
    );
  }
}
