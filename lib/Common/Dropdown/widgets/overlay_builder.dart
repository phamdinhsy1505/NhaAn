part of '../custom_dropdown.dart';

class _OverlayBuilder extends StatefulWidget {
  final Widget Function(Size, VoidCallback hide) overlay;
  final Widget Function(VoidCallback show) child;
  final bool isShowExpand;

  const _OverlayBuilder({
    super.key,
    required this.overlay,
    required this.child,
    required this.isShowExpand,
  });

  @override
  _OverlayBuilderState createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<_OverlayBuilder> {
  final overlayController = OverlayPortalController();
  bool isShow = true;

  @override
  void initState() {
    super.initState();
    //keys = new Keys();
    if (widget.isShowExpand) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isShow) {
          isShow = false;
          overlayController.show();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: overlayController,
      overlayChildBuilder: (_) {
        final renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        return widget.overlay(size, (){
          if (widget.isShowExpand) {
            Navigator.of(context).pop();
          } else {
            overlayController.hide();
          }
        });
      },
      child: widget.child(overlayController.show),
    );
  }
}
