package com.beiyinhuanyue.aixiaosczjl.common;

//全局常量
public class GlobalConstant {
   public final  static  int  SUCCESS=200;
   public final  static  int  FAIL=-1;

    public final static String FLUTTER_CHANNEL_NAME = "com.by.ve.bridge";
    // 自定义根目录，如果为空则默认为/sdcard/Android/data/***/files/rdve
    public final  static  String VIDEO_DEFULT_LOCAL_PATH="ve";

    /**
     * request
     * */
    //头条SDK回传事件
    public final  static  String OCEANENGINE_EVENT ="oceanengineEvent";
    //App初始化
    public final  static  String APP_INIT="appInit";
    //获取App信息
    public final  static  String APP_DEVICE_INFO="appDeviceInfo";

    //获取设备user-agent
    public final  static  String USER_AGENT="getUserAgent";


}

