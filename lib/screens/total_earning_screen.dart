import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/total_earning_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/total_earning_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/base_scaffold_widget.dart';
import '../components/empty_error_state_widget.dart';

class TotalEarningScreen extends StatefulWidget {
  const TotalEarningScreen({Key? key}) : super(key: key);

  @override
  _TotalEarningScreenState createState() => _TotalEarningScreenState();
}

class _TotalEarningScreenState extends State<TotalEarningScreen> {
  List<TotalData> totalEarning = [];

  int totalPage = 0;
  int currentPage = 1;
  int totalItems = 0;

  bool hasError = false;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);

    await getTotalEarningList(currentPage).then((value) {
      appStore.setLoading(false);
      errorMsg = '';
      hasError = false;
      totalItems = value.pagination!.totalItems;

      if (currentPage == 1) {
        totalEarning.clear();
      }

      if (totalItems >= 1) {
        totalEarning.addAll(value.data!);
        totalPage = value.pagination!.totalPages!;
        currentPage = value.pagination!.currentPage!;
      }
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      hasError = true;
      errorMsg = e.toString();

      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.lblEarningList,
      body: Stack(
        children: [
          AnimatedListView(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: totalEarning.length,
            itemBuilder: (_, index) {
              return TotalEarningWidget(totalEarning: totalEarning[index]);
            },
            emptyWidget: NoDataWidget(
              title: languages.lblNoEarningFound,
              imageWidget: EmptyStateWidget(),
            ).visible(!hasError),
            onNextPage: () {
              currentPage++;
              init();
            },
            onSwipeRefresh: () async {
              currentPage = 1;

              init();
              setState(() {});

              return await 2.seconds.delay;
            },
          ),
          NoDataWidget(
            title: languages.somethingWentWrong,
            subTitle: errorMsg,
            retryText: languages.reload,
            imageWidget: ErrorStateWidget(),
            onRetry: () {
              currentPage = 1;
              init();
            },
          ).center().visible(hasError),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
