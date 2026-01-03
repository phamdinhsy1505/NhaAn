import '../Common/SpinKitSpinningLines.dart';
import '../Data/DataManager.dart';
import 'package:flutter/material.dart';

import '../Data/Constants.dart';

class OverlayLoadingProgress {
  static OverlayEntry? _overlay;

  static start(
      BuildContext context, {
        Color? barrierColor = Colors.black54,
        Widget? widget,
        Color color = Colors.black38,
        String? gifOrImagePath,
        bool barrierDismissible = false,
        bool isBlockUI = true,
        double? loadingWidth,
      }) async {

    if (!DataManager().isShowOverlayLoading && _overlay != null) return;
    _overlay = OverlayEntry(builder: (BuildContext context) {
      return _LoadingWidget(
        color: color,
        barrierColor: isBlockUI ? barrierColor : Colors.transparent,
        widget: widget ?? const SpinKitThreeBounce(color: kMainColor),
        gifOrImagePath: gifOrImagePath,
        barrierDismissible: !isBlockUI,
        loadingWidth: loadingWidth,
      );
    });
    Overlay.of(context).insert(_overlay!);
  }

  static stop() {
    if (DataManager().isShowOverlayLoading && _overlay == null) return;
    DataManager().isShowOverlayLoading = false;
    if (_overlay != null) {
      _overlay?.remove();
    }
    _overlay = null;
  }
}

class _LoadingWidget extends StatelessWidget {
  final Widget? widget;
  final Color? color;
  final Color? barrierColor;
  final String? gifOrImagePath;
  final bool barrierDismissible;
  final double? loadingWidth;

  const _LoadingWidget({
    Key? key,
    this.widget,
    this.color,
    this.barrierColor,
    this.gifOrImagePath,
    required this.barrierDismissible,
    this.loadingWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: barrierDismissible ? OverlayLoadingProgress.stop : null,
      child: Container(
        constraints: const BoxConstraints.expand(),
        color: barrierColor,
        child: GestureDetector(
          onTap: () {},
          child: Center(
            child: widget ??
                SizedBox.square(
                  dimension: loadingWidth,
                  child: gifOrImagePath != null
                      ? Image.asset(gifOrImagePath!)
                      : const CircularProgressIndicator(strokeWidth: 3),
                ),
          ),
        ),
      ),
    );
  }
}