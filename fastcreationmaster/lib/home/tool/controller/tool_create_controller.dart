/*
 * @Author: cold-x
 * @Date: 2025-06-10 15:10:50
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-29 19:51:30
 * @FilePath: /fastcreationmaster/lib/home/tool/controller/tool_create_controller.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_controller.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/core/widget/view/provider_page_tracker.dart';
import 'package:fast_creation_master/home/tool/bean/item_type_bean.dart';
import 'package:fast_creation_master/home/tool/controller/tool_finish_provider.dart';
import 'package:fast_creation_master/home/tool/page/tool_finish_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/widget/view/diolog_view.dart';
import '../../../global/routes/app_pages.dart';
import '../../../profile/profile_controller.dart';

class ToolCreateController extends BaseController {
  ///创建类型
  final CreationType type;
  ToolCreateController({required this.type});

  final ProfileController user = Get.find<ProfileController>();

  final userController = Get.find<UserController>();

  ///创建参数
  Map<String, dynamic> params = {};

  ///数据标题，用于完成页展示，仅限笔名、小说名
  Map<String, String> itemTitles = {};

  ///是否是专业版
  Rx<bool> isProfessionalMode = false.obs;

  ///取数据
  var typeItems = Rx<ItemTypeBean?>(null);

  ///用户字数
  Rx<String> userWords = ''.obs;

  @override
  void onInit() {
    super.onInit();
    userWords.value = user.getUserWords();
    userController.reloadUserInfo(
      successAction: (userInfo) {
        userWords.value = user.getUserWords();
      },
    );
    fetchCreator();
  }

  ///获取底部按钮类型
  int getBottomType() {
    if ([
      CreationType.douyinAssistant,
      CreationType.xhsAssistant,
      CreationType.shortVideoScript
    ].contains(type)) {
      return isProfessionalMode.value ? 2 : 1;
    }
    return 0;
  }

  ///初始化数据内容
  void initContent(ItemTypeBean bean) {
    params = {
      'is_professional_edition': isProfessionalMode.value ? '1' : '2',
      'func': type.name,
      'generate_num': 1,
      'is_random': 2,
      "values": {}
    };
    final items = bean.items;
    for (Item item in items) {
      if (item.type == ItemType.text || item.type == ItemType.number) {
        params['values'][item.id] = '';
        // 同步更新Item对象的值
        item.value = '';
      } else if (item.type == ItemType.items) {
        ///如果是items类型，取第一个值
        ///params['values'][item.id] = [item.items?[0]];
        String? firstItem =
            item.items?.isNotEmpty == true ? item.items![0] : '';
        params['values'][item.id] = [firstItem];
        // 同步更新Item对象的selectedValue
        item.selectedValue = firstItem;
      }
    }
  }

  ///初始化生成数量标签页
  Item initGenerateNumItem() {
    Item item = Item(
        id: '',
        title: '生成数量',
        isRequisite: 0,
        itemDes: '',
        type: ItemType.items,
        isCheckBox: false,
        items: ['1', '2', '3', '4']);
    return item;
  }

  ///短故事随机生成
  void autoGenerante() {
    params['is_random'] = 1;
    if (params.keys.contains('values')) {
      params.remove('values');
    }
    nextStep();
  }

  ///类型是否是笔名或者小说名
  bool isNameType() {
    return [CreationType.penName, CreationType.novelName].contains(type);
  }

  ///获取标签内容个数
  ///如果是笔名、小说名，需要新增一条选择生成个数的item
  int getItemCount() {
    if (typeItems.value == null) {
      return 0;
    } else if (isNameType()) {
      return typeItems.value!.items.length + 1;
    } else {
      return typeItems.value!.items.length;
    }
  }

  ///更新内容
  void updateContent(String id, dynamic value) {
    // 如果用户手动修改了内容，说明不再是随机生成模式
    if (params['is_random'] == 1) {
      params['is_random'] = 2;
    }

    // 确保values存在
    if (!params.containsKey('values')) {
      params['values'] = {};
    }

    params['values'][id] = value;

    // 同步更新typeItems中对应Item对象的值，以便校验
    if (typeItems.value != null) {
      for (Item item in typeItems.value!.items) {
        if (item.id == id) {
          if (value is List<String>) {
            // 如果是List<String>类型（items类型），取第一个元素
            item.updateUserValue(value.isNotEmpty ? value[0] : '');
          } else {
            // 对文本和数字类型进行trim处理，过滤纯空格
            String trimmedValue = value.toString().trim();
            item.updateUserValue(trimmedValue);
          }
          break;
        }
      }

      // 当不是随机生成模式时，确保所有有默认值的item都被添加到params['values']中
      if (params['is_random'] == 2) {
        for (Item item in typeItems.value!.items) {
          if (!params['values'].containsKey(item.id)) {
            if (item.type == ItemType.items) {
              // 选项类型，使用selectedValue或第一个选项
              String? selectedValue = item.selectedValue ??
                  (item.items?.isNotEmpty == true ? item.items![0] : '');
              params['values'][item.id] = [selectedValue];
            } else {
              // 文本和数字类型，使用value或空字符串
              params['values'][item.id] = item.value ?? '';
            }
          }
        }
      }
    }
  }

  ///更新生成内容个数，仅限笔名和小说名
  void updateGenerateNum(int value) {
    params['generate_num'] = value;
  }

  ///更新模式,是否是专业版
  void updateIsProfessionnal(bool isProfessional) {
    isProfessionalMode.value = isProfessional;
    params['is_professional_edition'] = isProfessionalMode.value ? '1' : '2';
    fetchCreator();
  }

  ///切换专业版和普通版
  void toggleMode() {
    userController.checkPreLogin(
        source: type.name,
        actionCallback: () {
          ///非专业版切换是查询用户信息
          if (!isProfessionalMode.value) {
            if (user.userInfo?.isVip == 0) {
              userController.jumpToPayPage(source: type.name);
              return;
            }
          }
          Get.dialog(NovelDialog(
            confirmText: '确定切换',
            showCancelBtn: false,
            content: isProfessionalMode.value
                ? "切换至普通版已填写的内容将会清空"
                : "切换至专业版已填写的内容将会清空",
            onConfirm: () {
              updateIsProfessionnal(!isProfessionalMode.value);
            },
          ));
        });
  }

  ///校验必填项
  String? validateRequiredFields() {
    if (typeItems.value == null) return null;

    for (Item item in typeItems.value!.items) {
      // 只对is_requisite==1的必填项进行校验
      if (item.isRequisite == 1 && !item.finished()) {
        final isItems = item.type == ItemType.items;
        return isItems ? "请选择${item.title}" : "请填写${item.title}";
      }
    }
    return null;
  }

  ///生成内容，下一步事件
  void nextStep({int isRandom = 1}) {
    if (isRandom == 2) {
      params['is_random'] = 2;
    }
    // 添加空值校验（随机生成时跳过校验）
    if (params['is_random'] != 1 && typeItems.value != null) {
      String? validationError = validateRequiredFields();
      if (validationError != null) {
        BotToast.showText(text: validationError);
        return;
      }
    }

    createContent(
      onSuccess: (value) {
        ///笔名小说名
        if (type == CreationType.novelName || type == CreationType.penName) {
          Get.offNamed(Routes.writeNameFinish, arguments: {
            'ids': value,
            'type': type,
            'params': params,
            'titles': itemTitles
          });
        } else {
          final provider = ToolFinishProvider();
          provider.creationID = value[0];
          provider.type = type;
          provider.isStreaming = true;
          ByNavRouterUtils.push(
            Get.context!,
            trackProviderPage(
              pageId: '/tool_finish_page',
              widget: ChangeNotifierProvider(
                create: (context) => provider,
                child: const ToolFinishPage(),
              ),
            ),
          );
        }
      },
      onFailed: (code, msg) {
        if (code == 1003 || code == 1002) {
          ///1003字数不足、1002不是会员
          userController.checkPreLogin(
              source: type.name,
              actionCallback: () {
                userController.jumpToPayPage(source: type.name);
              });
        }
      },
    );
  }

  ///获取创建详情
  void fetchCreator({
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType.value = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.sendCreator,
      {
        "func": type.name,
        "is_professional_edition": isProfessionalMode.value ? '1' : '2'
      },
      success: (data) {
        if (data['status'] == 200) {
          ItemTypeBean bean = ItemTypeBean.fromJson(data["data"]);
          initContent(bean);
          typeItems.value = bean;
          statusType.value = MultiStatusType.statusContent;
          onSuccess?.call(data);
        } else {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///创建内容(小说、文案)
  void createContent({
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show(message: '内容生成中...');
    HttpUtils.post(
      NovelApis.createNovel,
      params,
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          final ids = data["data"]["ids"];
          onSuccess?.call(ids);
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }
}
