import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberAgreementWidget extends StatelessWidget {
  final RxBool agreementChecked;
  final int tabCurrentIndex;
  final List vipTypeList;
  final int selectedPackageIndex;
  final String? wordsPackIllustrate;
  final dynamic vipPageBean;
  final Function(bool) onAgreementChanged;

  const MemberAgreementWidget({
    Key? key,
    required this.agreementChecked,
    required this.tabCurrentIndex,
    required this.vipTypeList,
    required this.selectedPackageIndex,
    required this.onAgreementChanged,
    this.wordsPackIllustrate,
    this.vipPageBean,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onAgreementChanged(!agreementChecked.value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  agreementChecked.value
                      ? "assets/profile/member/member_2.png"
                      : "assets/profile/member/member_1.png",
                  height: 14,
                  width: 14,
                  fit: BoxFit.contain,
                ),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: ' 我已阅读并同意',
                              style: TextStyle(
                                fontSize: 12,
                                color: ByColorUtil.colorF2,
                              ),
                            ),
                            if (tabCurrentIndex == 0 &&
                                vipTypeList.isNotEmpty &&
                                selectedPackageIndex < vipTypeList.length)
                              TextSpan(
                                text: "《会员服务协议》",
                                style: const TextStyle(
                                  color: ByColorUtil.colorF1,
                                  fontSize: 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (vipPageBean?.user.protocolUrl.isEmpty ??
                                        true) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                        Get.context!,
                                        "",
                                        vipPageBean?.user.protocolUrl ?? "");
                                  },
                              ),
                            if (tabCurrentIndex == 1)
                              TextSpan(
                                text: "《字数包说明》",
                                style: const TextStyle(
                                  color: ByColorUtil.colorF1,
                                  fontSize: 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (wordsPackIllustrate == null ||
                                        wordsPackIllustrate!.isEmpty) {
                                      return;
                                    }
                                    ByNavRouterUtils.jumpWebViewPage(
                                        Get.context!,
                                        "",
                                        wordsPackIllustrate ?? "");
                                  },
                              ),
                            if (tabCurrentIndex == 0 &&
                                vipTypeList.isNotEmpty &&
                                selectedPackageIndex < vipTypeList.length &&
                                vipTypeList[selectedPackageIndex].isSubscribe ==
                                    1)
                              TextSpan(
                                text: "《自动续费服务协议》",
                                style: const TextStyle(
                                  color: ByColorUtil.colorF1,
                                  fontSize: 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (vipPageBean?.user.subScribeProtocolUrl
                                            .isEmpty ??
                                        true) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                        Get.context!,
                                        "",
                                        vipPageBean
                                                ?.user.subScribeProtocolUrl ??
                                            "");
                                  },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
