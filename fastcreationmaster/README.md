<!--
 * @Author: cold-x
 * @Date: 2025-05-28 10:09:05
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-04 15:10:41
 * @FilePath: /fastcreationmaster/README.md
 * @Description: 
-->

# AI小说创作精灵项目(flutter)
---------------------

## 名词定义和约束

`APP` : 以下指AI小说创作精灵

`novel` 小说的通用简称

`user` APP用户--所有用户，包括注册和未注册

`tool` 小说工具类，包含生成小说名、笔名、小说推广文案等等

## 工程主要目录说明

- `ios` 

iOS的相关配置

- `android`

Android的相关配置

- `script`

app的自动打包脚本

  -  ──────script
  
    -       ├──────output 自动打包脚本apk、ipa输出路径
    -       ├──────soure.txt 打包渠道汇总
    -       ├──────pkg.sh 自动脚本入口
    -       └──────main.py 用于自动打包的核心实现

- `lib`

flutter工程代码的主目录，用于各个功能核心模块的开发。

  -    ──────core

    -         ├──────cache 本地化缓存服务
    -         ├──────controller Getx通用的controller
    -         ├──────model 通用模型
    -         ├──────network 网络层服务
    -         ├──────pay 支付相关服务
    -         ├──────service 一些通用服务类型，如分享、防抖、本地化流式输出等等
    -         ├──────util 工具类型 如屏幕宽高、渠道配置等等
    -         └──────widget 通用组件
    
  -    ──────global

    -         ├──────const 常量设置
    -         ├──────initialize app初始化设置，包含通用库、SDK的初始化
    -         ├──────launch 启动设置，包含引导页
    -         ├──────login 登录模块
    -         ├──────main 主页面以及各个tab页
    -         ├──────other 其它全局模块，例如违禁词模块、小说字数相关配置模块
    -         ├──────permission app权限配置模块
    -         ├──────push app推送模块
    -         ├──────routes 路由设置
    -         └──────ui 小说app通用ui

  -    ──────home

    -         ├──────dialog 主页弹窗
    -         ├──────long_novel 长文、短文、短故事二级页面模块
    -         ├──────main_page 主tab主页页面(第一个tab)
    -         ├──────share_sales 赚钱邀请模块
    -         └──────tool 主页面中各个工具的二级页面功能模块，包含小说名、推广文、笔名、社媒推广等等

  -    ──────profile

    -         ├──────about_us app关于我们，包含app升级
    -         ├──────setup 个人中心设置模块
    -         ├──────member 各个付费页模块
    -         └──────profile.dart 个人中心页(第三个tab)

  -    ──────square

  -           └──────square.dart 攻略模块(第二个tab)

  -    ──────main.dart app的主入口文件。

  -    ──────README.md 服务说明

## 自动打包启动脚本

###

执行顺序：
1. 当前目录拉取最新代码(详细参考git操作)
  `git pull`
  如若遇到忽略本地需要提交的文件时，拉取前执行
  `git reset --hard HEAD`
2. 执行脚本
  `bash script/pkg.sh`
  等待脚本执行，输出包名均在output文件夹内
  备注，上述脚本只生成单个apk文件，用于测试, 位于output/one文件夹
  所有渠道包使用以下脚本，包位于output/all文件夹
  `bash script/pkg.sh --all`
  单个iOS包使用以下脚本，包位于output/ios文件夹
  `bash script/pkg.sh --ios`