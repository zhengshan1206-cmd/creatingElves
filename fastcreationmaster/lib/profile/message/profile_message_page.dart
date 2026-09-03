import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProfileMessagePage extends BasePage {
  ProfileMessagePage({super.key});

  @override
  String get title => "消息";

  @override
  Widget buildBody(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) {
        return [
          _activityNotice(),
        ];
      },
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: ByColorUtil.colorB1,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/profile/profile_trend_14.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '系统通知',
                            style: TextStyle(
                              fontSize: 15,
                              color: ByColorUtil.colorF1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '今天 12:55',
                            style: TextStyle(
                              fontSize: 12,
                              color: ByColorUtil.colorF3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(width: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              '您的长文小说已生成完成，请及时查看。',
                              style: TextStyle(
                                fontSize: 12,
                                color: ByColorUtil.colorF2,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: ByColorUtil.colorG4,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ///活动通知
  Widget _activityNotice() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 24),
        child: Container(
          width: double.infinity,
          height: 195,
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
          ),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/profile/profile_trend_15.png',
              ),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    '活动通知',
                    style: TextStyle(
                      fontSize: 16,
                      color: ByColorUtil.colorF1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Image.asset(
                    'assets/profile/profile_trend_13.png',
                    width: 10,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://www.keaitupian.cn/cjpic/frombd/2/253/3810755577/3802575188.jpg',
                  width: double.infinity,
                  height: 104,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '新手一定要学的写作技巧',
                    style: TextStyle(
                      fontSize: 14,
                      color: ByColorUtil.colorF1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Row(
                    children: [
                      const Text(
                        '查看详情',
                        style: TextStyle(
                          fontSize: 12,
                          color: ByColorUtil.colorF2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        'assets/profile/profile_right-icon.png',
                        width: 12,
                        fit: BoxFit.fitWidth,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
