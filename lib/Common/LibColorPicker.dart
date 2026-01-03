import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Data/Constants.dart';
import '../Data/Functions.dart';

enum PickMode {
  color,
  grey,
  normal,
  temp
}

/// A listener which receives an color in int representation. as used
/// by [BarColorPicker.colorListener] and [CircleColorPicker.colorListener].
typedef ColorListener = void Function(int value);

/// Constant color of thumb shadow
const _kThumbShadowColor = kMainColor;

/// A padding used to calculate bar height(thumbRadius * 2 - kBarPadding).
const _kBarPadding = 5;

/// A bar color picker
class BarColorPicker extends StatefulWidget {

  /// mode enum of pick a normal color or pick a grey color
  final PickMode pickMode;

  /// width of bar, if this widget is horizontal, than
  /// bar width is this value, if this widget is vertical
  /// bar height is this value
  final double width;

  /// A listener receives color pick events.
  final ColorListener colorListener;

  final ColorListener colorEndListener;

  /// corner radius of the picker bar, for each corners
  final double cornerRadius;

  /// specifies the bar orientation
  final bool horizontal;

  /// thumb fill color
  final Color thumbColor;

  /// radius of thumb
  final double thumbRadius;

  /// initial color of this color picker.

  late  double percent;

  BarColorPicker({
    Key? key,
    this.pickMode = PickMode.color,
    this.horizontal = true,
    this.width = 200,
    this.cornerRadius = 0.0,
    this.thumbRadius = 8,
    this.percent = 0.5,
    this.thumbColor = Colors.black,
    required this.colorListener,
    required this.colorEndListener,
  }) : super(key: key);

  @override
  _BarColorPickerState createState() => _BarColorPickerState();
}

class _BarColorPickerState extends State<BarColorPicker> {

  late List<Color> colors;
  late double barWidth, barHeight;

  @override
  void initState() {
    super.initState();
    if (widget.horizontal) {
      barWidth = widget.width;
      barHeight = widget.thumbRadius * 4 - _kBarPadding;
    } else {
      barWidth = widget.thumbRadius * 4 - _kBarPadding;
      barHeight = widget.width;
    }
    switch (widget.pickMode) {
      case PickMode.color:
        colors = const [
          Color(0xffff0000),
          Color(0xffffff00),
          Color(0xff00ff00),
          Color(0xff00ffff),
          Color(0xff0000ff),
          Color(0xffff00ff),
          Color(0xffff0000)
        ];
        break;
      case PickMode.grey:
        colors = const [
          Color(0xff000000),
          Color(0xffffffff)
        ];
        break;
      case PickMode.temp:
        colors = const [
          Color(0xffFFB16E),
          Color(0xffFFFEFA)
        ];
        break;
      case PickMode.normal:
        colors =  [
          kMainColor,
          kMainColor,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final double thumbRadius = widget.thumbRadius;
    final bool horizontal = widget.horizontal;

    double thumbLeft = 0, thumbTop = 0;
    if (horizontal) {
      thumbLeft = (barWidth - thumbRadius * 4) * widget.percent;
      thumbTop = _kBarPadding * 2.0;
    } else {
      thumbTop = (barHeight - thumbRadius * 4) * widget.percent;
      thumbLeft = _kBarPadding * 2.0;
    }
    // build thumb
    Widget thumb = Positioned(
        left: thumbLeft,
        top: thumbTop,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: kMainColor,
                  spreadRadius: _kBarPadding * 1.0,
                  // blurRadius: 3,
                )
              ],
              color: widget.thumbColor,
              borderRadius: BorderRadius.all(Radius.circular(14))
          ),
        )
    );

    // build frame
    double frameWidth, frameHeight;
    if (horizontal) {
      frameWidth = barWidth;
      frameHeight = thumbRadius * 2;
    } else {
      frameWidth = thumbRadius * 2;
      frameHeight = barHeight;
    }
    Widget frame = SizedBox(width: frameWidth, height: frameHeight);

    // build content
    Gradient gradient;
    double left, top;
    if (horizontal) {
      gradient = LinearGradient(colors: colors) ;//: SweepGradient(colors: colors, stops: const <double>[0.25,0.75]);
      left = thumbRadius;
      top =  barHeight / 2 + _kBarPadding;
    } else {
      gradient = widget.pickMode != PickMode.temp ? LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
      ) : SweepGradient(colors: colors, stops: const <double>[0.25,0.75]);
      left = barWidth / 2 + _kBarPadding;
      top = thumbRadius;
    }

    Widget content = Positioned(
      left: left,
      top: top,
      child: Container(
        width: horizontal ? (barWidth - left) : ((thumbRadius * 2)),
        height: horizontal ? (thumbRadius * 2) : (barHeight - top),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(widget.cornerRadius)),
            gradient: gradient
        ),
      ),
    );

    return GestureDetector(
      onPanDown: (details) => handleTouch(details.localPosition, context),
      onPanStart: (details) => handleTouch(details.localPosition, context),
      onPanUpdate: (details) => handleTouch(details.localPosition, context),
      onPanEnd: (details) => handleEndPan(),
      child: SizedBox(
        width: horizontal ? barWidth : (thumbRadius * 6 + 2 * _kBarPadding),
        height: horizontal ? (thumbRadius * 6 + 2 * _kBarPadding) : barHeight,
        child: Stack(children: [frame, content, thumb]),
      ),
    );
  }

  void handleEndPan () {
    widget.colorEndListener((widget.percent * 1000).toInt());
  }
  /// calculate colors picked from palette and update our states.
  void handleTouch(Offset localPosition, BuildContext context) {
    double percent = 0;

    if (widget.horizontal) {
      percent = (localPosition.dx - widget.thumbRadius) / barWidth;
    } else {
      percent = (localPosition.dy - widget.thumbRadius) / barHeight;
    }
    percent = min(max(0.0, percent), 1.0);
    printDebug("local: $percent ${localPosition.dx} - ${widget.thumbRadius} - $barWidth");
    setState(() {
      widget.percent = percent;
    });
    widget.colorListener((percent * 1000).toInt());
    // switch (widget.pickMode) {
    //   case PickMode.color:
    //     // Color color = HSVColor.fromAHSV(1.0, percent * 360, 1.0, 1.0).toColor();
    //     int hueValue = (percent * 360).toInt();
    //     widget.colorListener(hueValue);
    //     break;
    //   case PickMode.grey:
    //     final int channel = (0xff * percent).toInt();
    //     widget.colorListener(Color
    //         .fromARGB(0xff, channel, channel, channel)
    //         .value);
    //     break;
    // }
  }
}

/// A circle palette color picker.
class CircleColorPicker extends StatefulWidget {
  // radius of the color palette, note that radius * 2 is not the final
  // width of this widget, instead is (radius + thumbRadius) * 2.
  final double radius;

  /// thumb fill color.
  final Color thumbColor;

  /// radius of thumb.
  final double thumbRadius;

  /// A listener receives color pick events.
  final ColorListener colorListener;

  /// initial color of this color picker.
  final Color initialColor;

  const CircleColorPicker({
    required Key key,
    this.radius = 120,
    this.initialColor = const Color(0xffff0000),
    this.thumbColor = Colors.black,
    this.thumbRadius = 8,
    required this.colorListener
  }) : super(key: key);


  @override
  State<CircleColorPicker> createState() {
    return _CircleColorPickerState();
  }
}

enum PaletteType {
  hsv,
  hsvWithHue,
  hsvWithValue,
  hsvWithSaturation,
  hsl,
  hslWithHue,
  hslWithLightness,
  hslWithSaturation,
  rgbWithBlue,
  rgbWithGreen,
  rgbWithRed,
  hueWheel,
}

/// Track types for slider picker.
enum TrackType {
  hue,
  saturation,
  saturationForHSL,
  value,
  lightness,
  red,
  green,
  blue,
  alpha,
}


class _CircleColorPickerState extends State<CircleColorPicker> {
  static const List<Color> colors = [
    Color(0xffff0000),
    Color(0xffffff00),
    Color(0xff00ff00),
    Color(0xff00ffff),
    Color(0xff0000ff),
    Color(0xffff00ff),
    Color(0xffff0000)
  ];

  double thumbDistanceToCenter = 0;
  double thumbRadians = 0;

  @override
  void initState() {
    super.initState();
    thumbDistanceToCenter = widget.radius;
    final double hue = HSVColor
        .fromColor(widget.initialColor)
        .hue;
    thumbRadians = degreesToRadians(270 - hue);
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.radius;
    final double thumbRadius = widget.thumbRadius;

    // compute thumb center coordinate
    final double thumbCenterX = radius +
        thumbDistanceToCenter * sin(thumbRadians);
    final double thumbCenterY = radius +
        thumbDistanceToCenter * cos(thumbRadians);

    // build thumb widget
    Widget thumb = Positioned(
        left: thumbCenterX,
        top: thumbCenterY,
        child: Container(
          width: thumbRadius * 2,
          height: thumbRadius * 2,
          decoration: BoxDecoration(
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: _kThumbShadowColor,
                  spreadRadius: 2,
                  blurRadius: 3,
                )
              ],
              color: widget.thumbColor,
              borderRadius: BorderRadius.all(Radius.circular(thumbRadius))
          ),
        )
    );
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (details) => handleTouch(details.localPosition),
        onPanStart: (details) => handleTouch(details.localPosition),
        onPanUpdate: (details) => handleTouch(details.localPosition),
        child: Stack(
          children: <Widget>[
            SizedBox(
                width: (radius + thumbRadius) * 2,
                height: (radius + thumbRadius) * 2
            ),
            Positioned(
              left: thumbRadius,
              top: thumbRadius,
              child: Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(radius)),
                    gradient: const SweepGradient(colors: colors)
                ),
              ),
            ),
            thumb
          ],
        )
    );
  }

  /// calculate colors picked from palette and update our states.
  void handleTouch(Offset localPosition) {
    final double centerX = widget.radius;
    final double centerY = widget.radius;
    final double deltaX = localPosition.dx - centerX;
    final double deltaY = localPosition.dy - centerY;
    final double distanceToCenter = sqrt(deltaX * deltaX + deltaY * deltaY);
    double theta = atan2(deltaX, deltaY);
    double degree = 270 - radiansToDegrees(theta);
    if (degree < 0) degree = 360 + degree;
    widget.colorListener(HSVColor
        .fromAHSV(1, degree, 1, 1)
        .toColor()
        .value);
    setState(() {
      thumbDistanceToCenter = min(distanceToCenter, widget.radius);
      thumbRadians = theta;
    });
  }

  /// convert an angle value from radian to degree representation.
  double radiansToDegrees(double radians) {
    return (radians + pi) / pi * 180;
  }

  /// convert an angle value from degree to radian representation.
  double degreesToRadians(double degrees) {
    return degrees / 180 * pi - pi;
  }
}

String _padRadix(int value) => value.toRadixString(16).padLeft(2, '0');

String colorToHex(
    Color color, {
      bool includeHashSign = false,
      bool enableAlpha = true,
      bool toUpperCase = true,
    }) {
  final String hex = (includeHashSign ? '#' : '') +
      (enableAlpha ? _padRadix(color.alpha) : '') +
      _padRadix(color.red) +
      _padRadix(color.green) +
      _padRadix(color.blue);
  return toUpperCase ? hex.toUpperCase() : hex;
}
/// The default layout of Color Picker.
class ColorPicker extends StatefulWidget {
  const ColorPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.onColorEndChanged,
    this.pickerHsvColor,
    this.onHsvColorChanged,
    this.paletteType = PaletteType.hsvWithHue,
    this.enableAlpha = true,
    this.displayThumbColor = false,
    this.portraitOnly = false,
    this.colorPickerWidth = 300.0,
    this.pickerAreaHeightPercent = 1.0,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
    this.hexInputBar = false,
    this.hexInputController,
    this.colorHistory,
    this.onHistoryChanged,
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<int>? onColorEndChanged;
  final HSVColor? pickerHsvColor;
  final ValueChanged<HSVColor>? onHsvColorChanged;
  final PaletteType paletteType;
  final bool enableAlpha;
  final bool displayThumbColor;
  final bool portraitOnly;
  final double colorPickerWidth;
  final double pickerAreaHeightPercent;
  final BorderRadius pickerAreaBorderRadius;
  final bool hexInputBar;

  /// Allows setting the color using text input, via [TextEditingController].
  ///
  /// Listens to [String] input and trying to convert it to the valid [Color].
  /// Contains basic validator, that requires final input to be provided
  /// in one of those formats:
  ///
  /// * RGB
  /// * #RGB
  /// * RRGGBB
  /// * #RRGGBB
  /// * AARRGGBB
  /// * #AARRGGBB
  ///
  /// Where: A stands for Alpha, R for Red, G for Green, and B for blue color.
  /// It will only accept 3/6/8 long HEXs with an optional hash (`#`) at the beginning.
  /// Allowed characters are Latin A-F case insensitive and numbers 0-9.
  /// It does respect the [enableAlpha] flag, so if alpha is disabled, all inputs
  /// with transparency are also converted to non-transparent color values.
  /// ```dart
  ///   MaterialButton(
  ///    elevation: 3.0,
  ///    onPressed: () {
  ///      // The initial value can be provided directly to the controller.
  ///      final textController =
  ///          TextEditingController(text: '#2F19DB');
  ///      showDialog(
  ///        context: context,
  ///        builder: (BuildContext context) {
  ///          return AlertDialog(
  ///            scrollable: true,
  ///            titlePadding: const EdgeInsets.all(0.0),
  ///            contentPadding: const EdgeInsets.all(0.0),
  ///            content: Column(
  ///              children: [
  ///                ColorPicker(
  ///                  pickerColor: currentColor,
  ///                  onColorChanged: changeColor,
  ///                  colorPickerWidth: 300.0,
  ///                  pickerAreaHeightPercent: 0.7,
  ///                  enableAlpha:
  ///                      true, // hexInputController will respect it too.
  ///                  displayThumbColor: true,
  ///                  showLabel: true,
  ///                  paletteType: PaletteType.hsv,
  ///                  pickerAreaBorderRadius: const BorderRadius.only(
  ///                    topLeft: const Radius.circular(2.0),
  ///                    topRight: const Radius.circular(2.0),
  ///                  ),
  ///                  hexInputController: textController, // <- here
  ///                  portraitOnly: true,
  ///                ),
  ///                Padding(
  ///                  padding: const EdgeInsets.all(16),
  ///                  /* It can be any text field, for example:
  ///                  * TextField
  ///                  * TextFormField
  ///                  * CupertinoTextField
  ///                  * EditableText
  ///                  * any text field from 3-rd party package
  ///                  * your own text field
  ///                  so basically anything that supports/uses
  ///                  a TextEditingController for an editable text.
  ///                  */
  ///                  child: CupertinoTextField(
  ///                    controller: textController,
  ///                    // Everything below is purely optional.
  ///                    prefix: Padding(
  ///                      padding: const EdgeInsets.only(left: 8),
  ///                      child: const Icon(Icons.tag),
  ///                    ),
  ///                    suffix: IconButton(
  ///                      icon:
  ///                          const Icon(Icons.content_paste_rounded),
  ///                      onPressed: () async =>
  ///                          copyToClipboard(textController.text),
  ///                    ),
  ///                    autofocus: true,
  ///                    maxLength: 9,
  ///                    inputFormatters: [
  ///                      // Any custom input formatter can be passed
  ///                      // here or use any Form validator you want.
  ///                      UpperCaseTextFormatter(),
  ///                      FilteringTextInputFormatter.allow(
  ///                          RegExp(kValidHexPattern)),
  ///                    ],
  ///                  ),
  ///                )
  ///              ],
  ///            ),
  ///          );
  ///        },
  ///      );
  ///    },
  ///    child: const Text('Change me via text input'),
  ///    color: currentColor,
  ///    textColor: useWhiteForeground(currentColor)
  ///        ? const Color(0xffffffff)
  ///        : const Color(0xff000000),
  ///  ),
  /// ```
  ///
  /// Do not forget to `dispose()` your [TextEditingController] if you creating
  /// it inside any kind of [StatefulWidget]'s [State].
  /// Reference: https://en.wikipedia.org/wiki/Web_colors#Hex_triplet
  final TextEditingController? hexInputController;
  final List<Color>? colorHistory;
  final ValueChanged<List<Color>>? onHistoryChanged;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);
  List<Color> colorHistory = [];

  @override
  void initState() {
    currentHsvColor =
    (widget.pickerHsvColor != null) ? widget.pickerHsvColor as HSVColor : HSVColor.fromColor(widget.pickerColor);
    // If there's no initial text in `hexInputController`,
    if (widget.hexInputController?.text.isEmpty == true) {
      // set it to the current's color HEX value.
      widget.hexInputController?.text = colorToHex(
        currentHsvColor.toColor(),
        enableAlpha: widget.enableAlpha,
      );
    }
    // Listen to the text input, If there is an `hexInputController` provided.
    widget.hexInputController?.addListener(colorPickerTextInputListener);
    if (widget.colorHistory != null && widget.onHistoryChanged != null) {
      colorHistory = widget.colorHistory ?? [];
    }
    super.initState();
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor =
    (widget.pickerHsvColor != null) ? widget.pickerHsvColor as HSVColor : HSVColor.fromColor(widget.pickerColor);
  }

  void colorPickerTextInputListener() {
    // It can't be null really, since it's only listening if the controller
    // is provided, but it may help to calm the Dart analyzer in the future.
    if (widget.hexInputController == null) return;
    // If a user is inserting/typing any text — try to get the color value from it,
    // and interpret its transparency, dependent on the widget's settings.
    final Color? color = colorFromHex(widget.hexInputController!.text, enableAlpha: widget.enableAlpha);
    // If it's the valid color:
    if (color != null) {
      // set it as the current color and
      setState(() => currentHsvColor = HSVColor.fromColor(color));
      // notify with a callback.
      widget.onColorChanged(color.value);
      widget.onColorChanged(color.value);
      if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
    }
  }

  @override
  void dispose() {
    widget.hexInputController?.removeListener(colorPickerTextInputListener);
    super.dispose();
  }

  Widget colorPickerSlider(TrackType trackType) {
    return ColorPickerSlider(
      trackType,
      currentHsvColor,
          (HSVColor color) {
        // Update text in `hexInputController` if provided.
        widget.hexInputController?.text = colorToHex(color.toColor(), enableAlpha: widget.enableAlpha);
        setState(() => currentHsvColor = color);
        widget.onColorChanged(currentHsvColor.toColor().value);
        if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
      },
            (HSVColor color) {
              if (widget.onColorEndChanged != null) {
                widget.onColorEndChanged!(currentHsvColor.toColor().value);
              }
    },
      displayThumbColor: widget.displayThumbColor,
    );
  }

  void onColorChanging(HSVColor color) {
    // Update text in `hexInputController` if provided.
    widget.hexInputController?.text = colorToHex(color.toColor(), enableAlpha: widget.enableAlpha);
    setState(() => currentHsvColor = color);
    widget.onColorChanged(currentHsvColor.toColor().value);
    if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
  }

  void onColorEndChanged(HSVColor color) {
    if (widget.onColorEndChanged != null) {
      widget.onColorEndChanged!(currentHsvColor.toColor().value);
    }
  }

  Widget colorPicker() {
    return ClipRRect(
      borderRadius: widget.pickerAreaBorderRadius,
      child: Padding(
        padding: EdgeInsets.all(widget.paletteType == PaletteType.hueWheel ? 10 : 0),
        child: ColorPickerArea(currentHsvColor, onColorChanging, onColorEndChanged, widget.paletteType),
      ),
    );
  }

  Widget sliderByPaletteType() {
    switch (widget.paletteType) {
      case PaletteType.hsv:
      case PaletteType.hsvWithHue:
      case PaletteType.hsl:
      case PaletteType.hslWithHue:
        return colorPickerSlider(TrackType.hue);
      case PaletteType.hsvWithValue:
      case PaletteType.hueWheel:
        return colorPickerSlider(TrackType.value);
      case PaletteType.hsvWithSaturation:
        return colorPickerSlider(TrackType.saturation);
      case PaletteType.hslWithLightness:
        return colorPickerSlider(TrackType.lightness);
      case PaletteType.hslWithSaturation:
        return colorPickerSlider(TrackType.saturationForHSL);
      case PaletteType.rgbWithBlue:
        return colorPickerSlider(TrackType.blue);
      case PaletteType.rgbWithGreen:
        return colorPickerSlider(TrackType.green);
      case PaletteType.rgbWithRed:
        return colorPickerSlider(TrackType.red);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait || widget.portraitOnly) {
      return Column(
        children: <Widget>[
          SizedBox(
            width: widget.colorPickerWidth,
            height: widget.colorPickerWidth * widget.pickerAreaHeightPercent,
            child: colorPicker(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () => setState(() {
                    if (widget.onHistoryChanged != null && !colorHistory.contains(currentHsvColor.toColor())) {
                      colorHistory.add(currentHsvColor.toColor());
                      widget.onHistoryChanged!(colorHistory);
                    }
                  }),
                  child: ColorIndicator(currentHsvColor),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 40.0, width: widget.colorPickerWidth - 75.0, child: sliderByPaletteType()),
                      if (widget.enableAlpha)
                        SizedBox(
                          height: 40.0,
                          width: widget.colorPickerWidth - 75.0,
                          child: colorPickerSlider(TrackType.alpha),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (colorHistory.isNotEmpty)
            SizedBox(
              width: widget.colorPickerWidth,
              height: 50,
              child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
                for (Color color in colorHistory)
                  Padding(
                    key: Key(color.hashCode.toString()),
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 10),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => onColorChanging(HSVColor.fromColor(color)),
                        child: ColorIndicator(HSVColor.fromColor(color), width: 30, height: 30),
                      ),
                    ),
                  ),
                const SizedBox(width: 15),
              ]),
            ),
          if (widget.hexInputBar)
            ColorPickerInput(
              currentHsvColor.toColor(),
                  (Color color) {
                setState(() => currentHsvColor = HSVColor.fromColor(color));
                widget.onColorChanged(currentHsvColor.toColor().value);
                if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
              },
              enableAlpha: widget.enableAlpha,
              embeddedText: false,
            ),
          const SizedBox(height: 20.0),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          SizedBox(
              width: widget.colorPickerWidth,
              height: widget.colorPickerWidth * widget.pickerAreaHeightPercent,
              child: colorPicker()),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const SizedBox(width: 20.0),
                  GestureDetector(
                    onTap: () => setState(() {
                      if (widget.onHistoryChanged != null && !colorHistory.contains(currentHsvColor.toColor())) {
                        colorHistory.add(currentHsvColor.toColor());
                        widget.onHistoryChanged!(colorHistory);
                      }
                    }),
                    child: ColorIndicator(currentHsvColor),
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(height: 40.0, width: 260.0, child: sliderByPaletteType()),
                      if (widget.enableAlpha)
                        SizedBox(height: 40.0, width: 260.0, child: colorPickerSlider(TrackType.alpha)),
                    ],
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
              if (colorHistory.isNotEmpty)
                SizedBox(
                  width: widget.colorPickerWidth,
                  height: 50,
                  child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
                    for (Color color in colorHistory)
                      Padding(
                        key: Key(color.hashCode.toString()),
                        padding: const EdgeInsets.fromLTRB(15, 18, 0, 0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => onColorChanging(HSVColor.fromColor(color)),
                            onLongPress: () {
                              if (colorHistory.remove(color)) {
                                widget.onHistoryChanged!(colorHistory);
                                setState(() {});
                              }
                            },
                            child: ColorIndicator(HSVColor.fromColor(color), width: 30, height: 30),
                          ),
                        ),
                      ),
                    const SizedBox(width: 15),
                  ]),
                ),
              const SizedBox(height: 20.0),
              if (widget.hexInputBar)
                ColorPickerInput(
                  currentHsvColor.toColor(),
                      (Color color) {
                    setState(() => currentHsvColor = HSVColor.fromColor(color));
                    widget.onColorChanged(currentHsvColor.toColor().value);
                    if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
                  },
                  enableAlpha: widget.enableAlpha,
                  embeddedText: false,
                ),
              const SizedBox(height: 5),
            ],
          ),
        ],
      );
    }
  }
}

class HueRingPicker extends StatefulWidget {
  const HueRingPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    required this.onColorEndChanged,
    this.portraitOnly = false,
    this.colorPickerHeight = 250.0,
    this.hueRingStrokeWidth = 20.0,
    this.enableAlpha = false,
    this.displayThumbColor = true,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<int> onColorEndChanged;
  final bool portraitOnly;
  final double colorPickerHeight;
  final double hueRingStrokeWidth;
  final bool enableAlpha;
  final bool displayThumbColor;
  final BorderRadius pickerAreaBorderRadius;

  @override
  State<HueRingPicker> createState() => _HueRingPickerState();
}

class _HueRingPickerState extends State<HueRingPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);

  @override
  void initState() {
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
    super.initState();
  }

  @override
  void didUpdateWidget(HueRingPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  void onColorChanging(HSVColor color) {
    setState(() => currentHsvColor = color);
    widget.onColorChanged(currentHsvColor.toColor().value);
  }

  void onColorEndChanged(HSVColor color) {
    setState(() => currentHsvColor = color);
    widget.onColorEndChanged(currentHsvColor.toColor().value);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait || widget.portraitOnly) {
      return Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: widget.pickerAreaBorderRadius,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Stack(alignment: AlignmentDirectional.center, children: <Widget>[
                SizedBox(
                  width: widget.colorPickerHeight,
                  height: widget.colorPickerHeight,
                  child: ColorPickerHueRing(
                    currentHsvColor,
                    onColorChanging,
                    displayThumbColor: widget.displayThumbColor,
                    strokeWidth: widget.hueRingStrokeWidth,
                  ),
                ),
                SizedBox(
                  width: widget.colorPickerHeight / 2,
                  height: widget.colorPickerHeight / 2,
                  child: ColorPickerArea(currentHsvColor, onColorChanging, onColorEndChanged, PaletteType.hsv),
                )
              ]),
            ),
          ),
          if (widget.enableAlpha)
            SizedBox(
              height: 40.0,
              width: widget.colorPickerHeight,
              child: ColorPickerSlider(
                TrackType.alpha,
                currentHsvColor,
                onColorChanging,
                onColorEndChanged,
                displayThumbColor: widget.displayThumbColor,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 10),
                ColorIndicator(currentHsvColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
                    child: ColorPickerInput(
                      currentHsvColor.toColor(),
                          (Color color) {
                        setState(() => currentHsvColor = HSVColor.fromColor(color));
                        widget.onColorChanged(currentHsvColor.toColor().value);
                      },
                      enableAlpha: widget.enableAlpha,
                      embeddedText: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: SizedBox(
              width: 300.0,
              height: widget.colorPickerHeight,
              child: ClipRRect(
                borderRadius: widget.pickerAreaBorderRadius,
                child: ColorPickerArea(currentHsvColor, onColorChanging, onColorEndChanged, PaletteType.hsv),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: widget.pickerAreaBorderRadius,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Stack(alignment: AlignmentDirectional.topCenter, children: <Widget>[
                SizedBox(
                  width: widget.colorPickerHeight - widget.hueRingStrokeWidth * 2,
                  height: widget.colorPickerHeight - widget.hueRingStrokeWidth * 2,
                  child: ColorPickerHueRing(currentHsvColor, onColorChanging, strokeWidth: widget.hueRingStrokeWidth),
                ),
                Column(
                  children: [
                    SizedBox(height: widget.colorPickerHeight / 8.5),
                    ColorIndicator(currentHsvColor),
                    const SizedBox(height: 10),
                    ColorPickerInput(
                      currentHsvColor.toColor(),
                          (Color color) {
                        setState(() => currentHsvColor = HSVColor.fromColor(color));
                        widget.onColorChanged(currentHsvColor.toColor().value);
                      },
                      enableAlpha: widget.enableAlpha,
                      embeddedText: true,
                      disable: true,
                    ),
                    if (widget.enableAlpha) const SizedBox(height: 5),
                    if (widget.enableAlpha)
                      SizedBox(
                        height: 40.0,
                        width: (widget.colorPickerHeight - widget.hueRingStrokeWidth * 2) / 2,
                        child: ColorPickerSlider(
                          TrackType.alpha,
                          currentHsvColor,
                          onColorChanging,
                          onColorEndChanged,
                          displayThumbColor: true,
                        ),
                      ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      );
    }
  }
}

class ColorPickerInput extends StatefulWidget {
  const ColorPickerInput(
      this.color,
      this.onColorChanged, {
        Key? key,
        this.enableAlpha = true,
        this.embeddedText = false,
        this.disable = false,
      }) : super(key: key);

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool enableAlpha;
  final bool embeddedText;
  final bool disable;

  @override
  State<ColorPickerInput> createState() => _ColorPickerInputState();
}

class _ColorPickerInputState extends State<ColorPickerInput> {
  TextEditingController textEditingController = TextEditingController();
  int inputColor = 0;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (inputColor != widget.color.value) {
      // ignore: prefer_interpolation_to_compose_strings
      textEditingController.text = '#' +
          widget.color.red.toRadixString(16).toUpperCase().padLeft(2, '0') +
          widget.color.green.toRadixString(16).toUpperCase().padLeft(2, '0') +
          widget.color.blue.toRadixString(16).toUpperCase().padLeft(2, '0') +
          (widget.enableAlpha ? widget.color.alpha.toRadixString(16).toUpperCase().padLeft(2, '0') : '');
    }
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (!widget.embeddedText) Text('Hex', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(width: 10),
        SizedBox(
          width: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * 10,
          child: TextField(
            enabled: !widget.disable,
            controller: textEditingController,
            inputFormatters: [
              UpperCaseTextFormatter(),
              FilteringTextInputFormatter.allow(RegExp(kValidHexPattern)),
            ],
            decoration: InputDecoration(
              isDense: true,
              label: widget.embeddedText ? const Text('Hex') : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
            ),
            onChanged: (String value) {
              String input = value;
              if (value.length == 9) {
                input = value.split('').getRange(7, 9).join() + value.split('').getRange(1, 7).join();
              }
              final Color? color = colorFromHex(input);
              if (color != null) {
                widget.onColorChanged(color);
                inputColor = color.value;
              }
            },
          ),
        ),
      ]),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(oldValue, TextEditingValue newValue) =>
      TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
}


class ColorIndicator extends StatelessWidget {
  const ColorIndicator(
      this.hsvColor, {
        Key? key,
        this.width = 50.0,
        this.height = 50.0,
      }) : super(key: key);

  final HSVColor hsvColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(1000.0)),
        border: Border.all(color: const Color(0xffdddddd)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(1000.0)),
        child: CustomPaint(painter: IndicatorPainter(hsvColor.toColor())),
      ),
    );
  }
}


class ColorPickerHueRing extends StatelessWidget {
  const ColorPickerHueRing(
      this.hsvColor,
      this.onColorChanged, {
        Key? key,
        this.displayThumbColor = true,
        this.strokeWidth = 5.0,
      }) : super(key: key);

  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onColorChanged;
  final bool displayThumbColor;
  final double strokeWidth;

  void _handleGesture(Offset position, BuildContext context, double height, double width) {
    RenderBox? getBox = context.findRenderObject() as RenderBox?;
    if (getBox == null) return;

    Offset localOffset = getBox.globalToLocal(position);
    double horizontal = localOffset.dx.clamp(0.0, width);
    double vertical = localOffset.dy.clamp(0.0, height);

    Offset center = Offset(width / 2, height / 2);
    double radio = width <= height ? width / 2 : height / 2;
    double dist = sqrt(pow(horizontal - center.dx, 2) + pow(vertical - center.dy, 2)) / radio;
    double rad = (atan2(horizontal - center.dx, vertical - center.dy) / pi + 1) / 2 * 360;
    if (dist > 0.7 && dist < 1.3) onColorChanged(hsvColor.withHue(((rad + 90) % 360).clamp(0, 360)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        return RawGestureDetector(
          gestures: {
            _AlwaysWinPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<_AlwaysWinPanGestureRecognizer>(
                  () => _AlwaysWinPanGestureRecognizer(),
                  (_AlwaysWinPanGestureRecognizer instance) {
                instance
                  ..onDown = ((details) => _handleGesture(details.globalPosition, context, height, width))
                  ..onUpdate = ((details) => _handleGesture(details.globalPosition, context, height, width));
              },
            ),
          },
          child: CustomPaint(
            painter: HueRingPainter(hsvColor, displayThumbColor: displayThumbColor, strokeWidth: strokeWidth),
          ),
        );
      },
    );
  }
}

class _AlwaysWinPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'alwaysWin';
}

class HueRingPainter extends CustomPainter {
  const HueRingPainter(this.hsvColor, {this.displayThumbColor = true, this.strokeWidth = 5});

  final HSVColor hsvColor;
  final bool displayThumbColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radio = size.width <= size.height ? size.width / 2 : size.height / 2;

    final List<Color> colors = [
      const HSVColor.fromAHSV(1.0, 360.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 300.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 180.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 60.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
    ];
    canvas.drawCircle(
      center,
      radio,
      Paint()
        ..shader = SweepGradient(colors: colors).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final Offset offset = Offset(
      center.dx + radio * cos((hsvColor.hue * pi / 180)),
      center.dy - radio * sin((hsvColor.hue * pi / 180)),
    );
    canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: offset, radius: 12)), Colors.black, 3.0, true);
    canvas.drawCircle(
      offset,
      size.height * 0.04,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    if (displayThumbColor) {
      canvas.drawCircle(
        offset,
        size.height * 0.03,
        Paint()
          ..color = hsvColor.toColor()
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ColorPickerSlider extends StatelessWidget {
  ColorPickerSlider(
      this.trackType,
      this.hsvColor,
      this.onColorChanged,
      this.onColorEndChanged,
      {
        Key? key,
        this.displayThumbColor = false,
        this.fullThumbColor = false,
      }) : super(key: key);

  final TrackType trackType;
  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onColorChanged;
  final ValueChanged<HSVColor> onColorEndChanged;
  final bool displayThumbColor;
  final bool fullThumbColor;
  double localDx = 0;

  void handleSlideEvent(BoxConstraints box, ValueChanged<HSVColor> onChanged) {
    double progress = max(0.01, localDx.clamp(0.0, box.maxWidth - 30.0) / (box.maxWidth - 30.0));
    switch (trackType) {
      case TrackType.hue:
      // 360 is the same as zero
      // if set to 360, sliding to end goes to zero
        onChanged(hsvColor.withHue(progress * 359));
        break;
      case TrackType.saturation:
        onChanged(hsvColor.withSaturation(progress));
        break;
      case TrackType.saturationForHSL:
        onChanged(hslToHsv(hsvToHsl(hsvColor).withSaturation(progress)));
        break;
      case TrackType.value:
        onChanged(hsvColor.withValue(progress));
        break;
      case TrackType.lightness:
        onChanged(hslToHsv(hsvToHsl(hsvColor).withLightness(progress)));
        break;
      case TrackType.red:
        onChanged(HSVColor.fromColor(hsvColor.toColor().withRed((progress * 0xff).round())));
        break;
      case TrackType.green:
        onChanged(HSVColor.fromColor(hsvColor.toColor().withGreen((progress * 0xff).round())));
        break;
      case TrackType.blue:
        onChanged(HSVColor.fromColor(hsvColor.toColor().withBlue((progress * 0xff).round())));
        break;
      case TrackType.alpha:
        onChanged(hsvColor.withAlpha(localDx.clamp(0.0, box.maxWidth - 30.0) / (box.maxWidth - 30.0)));
        break;
    }
  }


  void slideEvent(RenderBox getBox, BoxConstraints box, Offset globalPosition, ValueChanged<HSVColor> onChanged) {
    localDx = getBox.globalToLocal(globalPosition).dx - 15.0;
    handleSlideEvent(box, onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints box) {
      double thumbOffset = 15.0;
      Color thumbColor;
      switch (trackType) {
        case TrackType.hue:
          thumbOffset += (box.maxWidth - 30.0) * hsvColor.hue / 360;
          thumbColor = HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 1.0).toColor();
          break;
        case TrackType.saturation:
          thumbOffset += (box.maxWidth - 30.0) * hsvColor.saturation;
          thumbColor = HSVColor.fromAHSV(1.0, hsvColor.hue, hsvColor.saturation, 1.0).toColor();
          break;
        case TrackType.saturationForHSL:
          thumbOffset += (box.maxWidth - 30.0) * hsvToHsl(hsvColor).saturation;
          thumbColor = HSLColor.fromAHSL(1.0, hsvColor.hue, hsvToHsl(hsvColor).saturation, 0.5).toColor();
          break;
        case TrackType.value:
          thumbOffset += (box.maxWidth - 30.0) * hsvColor.value;
          thumbColor = HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, hsvColor.value).toColor();
          break;
        case TrackType.lightness:
          thumbOffset += (box.maxWidth - 30.0) * hsvToHsl(hsvColor).lightness;
          thumbColor = HSLColor.fromAHSL(1.0, hsvColor.hue, 1.0, hsvToHsl(hsvColor).lightness).toColor();
          break;
        case TrackType.red:
          thumbOffset += (box.maxWidth - 30.0) * hsvColor.toColor().red / 0xff;
          thumbColor = hsvColor.toColor().withOpacity(1.0);
          break;
        case TrackType.green:
          thumbOffset += (box.maxWidth - 30.0) * hsvColor.toColor().green / 0xff;
          thumbColor = hsvColor.toColor().withOpacity(1.0);
          break;
        case TrackType.blue:
          thumbOffset += (box.maxWidth - 30.0) * hsvColor.toColor().blue / 0xff;
          thumbColor = hsvColor.toColor().withOpacity(1.0);
          break;
        case TrackType.alpha:
          thumbOffset += (box.maxWidth - 30.0) * hsvColor.toColor().opacity;
          thumbColor = hsvColor.toColor().withOpacity(hsvColor.alpha);
          break;
      }

      return CustomMultiChildLayout(
        delegate: _SliderLayout(),
        children: <Widget>[
          LayoutId(
            id: _SliderLayout.track,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(50.0)),
              child: CustomPaint(
                  painter: TrackPainter(
                    trackType,
                    hsvColor,
                  )),
            ),
          ),
          LayoutId(
            id: _SliderLayout.thumb,
            child: Transform.translate(
              offset: Offset(thumbOffset, 0.0),
              child: CustomPaint(
                painter: ThumbPainter(
                  thumbColor: displayThumbColor ? thumbColor : null,
                  fullThumbColor: fullThumbColor,
                ),
              ),
            ),
          ),
          LayoutId(
            id: _SliderLayout.gestureContainer,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints box) {
                RenderBox? getBox = context.findRenderObject() as RenderBox?;
                return GestureDetector(
                  onPanEnd: (detail) {
                    handleSlideEvent(box, onColorEndChanged);
                  },
                  onPanDown: (DragDownDetails details) =>
                  getBox != null ? slideEvent(getBox, box, details.globalPosition, onColorChanged) : null,
                  onPanUpdate: (DragUpdateDetails details) =>
                  getBox != null ? slideEvent(getBox, box, details.globalPosition, onColorChanged) : null,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _SliderLayout extends MultiChildLayoutDelegate {
  static const String track = 'track';
  static const String thumb = 'thumb';
  static const String gestureContainer = 'gesturecontainer';

  @override
  void performLayout(Size size) {
    layoutChild(
      track,
      BoxConstraints.tightFor(
        width: size.width - 30.0,
        height: size.height / 5,
      ),
    );
    positionChild(track, Offset(15.0, size.height * 0.4));
    layoutChild(
      thumb,
      BoxConstraints.tightFor(width: 5.0, height: size.height / 4),
    );
    positionChild(thumb, Offset(0.0, size.height * 0.4));
    layoutChild(
      gestureContainer,
      BoxConstraints.tightFor(width: size.width, height: size.height),
    );
    positionChild(gestureContainer, Offset.zero);
  }

  @override
  bool shouldRelayout(_SliderLayout oldDelegate) => false;
}

/// Painter for all kinds of track types.
class TrackPainter extends CustomPainter {
  const TrackPainter(this.trackType, this.hsvColor);

  final TrackType trackType;
  final HSVColor hsvColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    if (trackType == TrackType.alpha) {
      final Size chessSize = Size(size.height / 2, size.height / 2);
      Paint chessPaintB = Paint()..color = const Color(0xffcccccc);
      Paint chessPaintW = Paint()..color = Colors.white;
      List.generate((size.height / chessSize.height).round(), (int y) {
        List.generate((size.width / chessSize.width).round(), (int x) {
          canvas.drawRect(
            Offset(chessSize.width * x, chessSize.width * y) & chessSize,
            (x + y) % 2 != 0 ? chessPaintW : chessPaintB,
          );
        });
      });
    }

    switch (trackType) {
      case TrackType.hue:
        final List<Color> colors = [
          const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 60.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 180.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 300.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 360.0, 1.0, 1.0).toColor(),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
      case TrackType.saturation:
        final List<Color> colors = [
          HSVColor.fromAHSV(1.0, hsvColor.hue, 0.0, 1.0).toColor(),
          HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 1.0).toColor(),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
      case TrackType.saturationForHSL:
        final List<Color> colors = [
          HSLColor.fromAHSL(1.0, hsvColor.hue, 0.0, 0.5).toColor(),
          HSLColor.fromAHSL(1.0, hsvColor.hue, 1.0, 0.5).toColor(),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
      case TrackType.value:
        final List<Color> colors = [
          HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 0.0).toColor(),
          HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 1.0).toColor(),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
      case TrackType.lightness:
        final List<Color> colors = [
          HSLColor.fromAHSL(1.0, hsvColor.hue, 1.0, 0.0).toColor(),
          HSLColor.fromAHSL(1.0, hsvColor.hue, 1.0, 0.5).toColor(),
          HSLColor.fromAHSL(1.0, hsvColor.hue, 1.0, 1.0).toColor(),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
      case TrackType.red:
        final List<Color> colors = [
          hsvColor.toColor().withRed(0).withOpacity(1.0),
          hsvColor.toColor().withRed(255).withOpacity(1.0),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
      case TrackType.green:
        final List<Color> colors = [
          hsvColor.toColor().withGreen(0).withOpacity(1.0),
          hsvColor.toColor().withGreen(255).withOpacity(1.0),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
      case TrackType.blue:
        final List<Color> colors = [
          hsvColor.toColor().withBlue(0).withOpacity(1.0),
          hsvColor.toColor().withBlue(255).withOpacity(1.0),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
      case TrackType.alpha:
        final List<Color> colors = [
          hsvColor.toColor().withOpacity(0.0),
          hsvColor.toColor().withOpacity(1.0),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ThumbPainter extends CustomPainter {
  const ThumbPainter({this.thumbColor, this.fullThumbColor = false});

  final Color? thumbColor;
  final bool fullThumbColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(
      Path()
        ..addOval(
          Rect.fromCircle(center: const Offset(0.5, 2.0), radius: size.width * 1.8),
        ),
      Colors.black,
      3.0,
      true,
    );
    canvas.drawCircle(
        Offset(0.0, size.height * 0.4),
        size.height,
        Paint()
          ..color = kMainColor
          ..style = PaintingStyle.fill);
    if (thumbColor != null) {
      canvas.drawCircle(
          Offset(0.0, size.height * 0.4),
          size.height * (fullThumbColor ? 1.0 : 0.65),
          Paint()
            ..color = thumbColor!
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Painter for chess type alpha background in color indicator widget.
class IndicatorPainter extends CustomPainter {
  const IndicatorPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Size chessSize = Size(size.width / 10, size.height / 10);
    final Paint chessPaintB = Paint()..color = const Color(0xFFCCCCCC);
    final Paint chessPaintW = Paint()..color = Colors.white;
    List.generate((size.height / chessSize.height).round(), (int y) {
      List.generate((size.width / chessSize.width).round(), (int x) {
        canvas.drawRect(
          Offset(chessSize.width * x, chessSize.height * y) & chessSize,
          (x + y) % 2 != 0 ? chessPaintW : chessPaintB,
        );
      });
    });

    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.height / 2,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ColorPickerArea extends StatelessWidget {
  ColorPickerArea(
      this.hsvColor,
      this.onColorChanged,
      this.onColorEndChanged,
      this.paletteType, {
        Key? key,
      }) : super(key: key);

  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onColorChanged;
  final ValueChanged<HSVColor> onColorEndChanged;
  final PaletteType paletteType;
  Offset localOffset = Offset.zero;

  void _handleColorRectChange(double horizontal, double vertical, ValueChanged<HSVColor> onChanged) {
    switch (paletteType) {
      case PaletteType.hsv:
      case PaletteType.hsvWithHue:
      onChanged(hsvColor.withSaturation(horizontal).withValue(vertical));
        break;
      case PaletteType.hsvWithSaturation:
        onChanged(hsvColor.withHue(horizontal * 360).withValue(vertical));
        break;
      case PaletteType.hsvWithValue:
        onChanged(hsvColor.withHue(horizontal * 360).withSaturation(vertical));
        break;
      case PaletteType.hsl:
      case PaletteType.hslWithHue:
      onChanged(hslToHsv(
          hsvToHsl(hsvColor).withSaturation(horizontal).withLightness(vertical),
        ));
        break;
      case PaletteType.hslWithSaturation:
        onChanged(hslToHsv(
          hsvToHsl(hsvColor).withHue(horizontal * 360).withLightness(vertical),
        ));
        break;
      case PaletteType.hslWithLightness:
        onChanged(hslToHsv(
          hsvToHsl(hsvColor).withHue(horizontal * 360).withSaturation(vertical),
        ));
        break;
      case PaletteType.rgbWithRed:
        onChanged(HSVColor.fromColor(
          hsvColor.toColor().withBlue((horizontal * 255).round()).withGreen((vertical * 255).round()),
        ));
        break;
      case PaletteType.rgbWithGreen:
        onChanged(HSVColor.fromColor(
          hsvColor.toColor().withBlue((horizontal * 255).round()).withRed((vertical * 255).round()),
        ));
        break;
      case PaletteType.rgbWithBlue:
        onChanged(HSVColor.fromColor(
          hsvColor.toColor().withRed((horizontal * 255).round()).withGreen((vertical * 255).round()),
        ));
        break;
      default:
        break;
    }
  }

  void _handleColorWheelChange(double hue, double radio, ValueChanged<HSVColor> onChanged) {
    onChanged(hsvColor.withHue(hue).withSaturation(radio));
  }

  void handleNewOffset (double height, double width, ValueChanged<HSVColor> onChanged) {
    double horizontal = localOffset.dx.clamp(0.0, width);
    double vertical = localOffset.dy.clamp(0.0, height);

    if (paletteType == PaletteType.hueWheel) {
      Offset center = Offset(width / 2, height / 2);
      double radio = width <= height ? width / 2 : height / 2;
      double dist = sqrt(pow(horizontal - center.dx, 2) + pow(vertical - center.dy, 2)) / radio;
      double rad = (atan2(horizontal - center.dx, vertical - center.dy) / pi + 1) / 2 * 360;
      _handleColorWheelChange(((rad + 90) % 360).clamp(0, 360), dist.clamp(0, 1), onChanged);
    } else {
      _handleColorRectChange(horizontal / width, 1 - vertical / height, onChanged);
    }
  }
  
  void _handleGesture(Offset position, BuildContext context, double height, double width, ValueChanged<HSVColor> onChanged) {
    RenderBox? getBox = context.findRenderObject() as RenderBox?;
    if (getBox == null) return;

    localOffset = getBox.globalToLocal(position);
    handleNewOffset(height, width, onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        return RawGestureDetector(
          gestures: {
            _AlwaysWinPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<_AlwaysWinPanGestureRecognizer>(
                  () => _AlwaysWinPanGestureRecognizer(),
                  (_AlwaysWinPanGestureRecognizer instance) {
                instance
                  ..onEnd = ((detail) => handleNewOffset(height, width, onColorEndChanged))
                  ..onDown = ((details) => _handleGesture(details.globalPosition, context, height, width, onColorChanged))
                  ..onUpdate = ((details) => _handleGesture(details.globalPosition, context, height, width, onColorChanged));
              },
            ),
          },
          child: Builder(
            builder: (BuildContext _) {
              switch (paletteType) {
                case PaletteType.hsv:
                case PaletteType.hsvWithHue:
                  return CustomPaint(painter: HSVWithHueColorPainter(hsvColor));
                // case PaletteType.hsvWithSaturation:
                //   return CustomPaint(painter: HSVWithSaturationColorPainter(hsvColor));
                // case PaletteType.hsvWithValue:
                //   return CustomPaint(painter: HSVWithValueColorPainter(hsvColor));
                // case PaletteType.hsl:
                // case PaletteType.hslWithHue:
                //   return CustomPaint(painter: HSLWithHueColorPainter(hsvToHsl(hsvColor)));
                // case PaletteType.hslWithSaturation:
                //   return CustomPaint(painter: HSLWithSaturationColorPainter(hsvToHsl(hsvColor)));
                // case PaletteType.hslWithLightness:
                //   return CustomPaint(painter: HSLWithLightnessColorPainter(hsvToHsl(hsvColor)));
                // case PaletteType.rgbWithRed:
                //   return CustomPaint(painter: RGBWithRedColorPainter(hsvColor.toColor()));
                // case PaletteType.rgbWithGreen:
                //   return CustomPaint(painter: RGBWithGreenColorPainter(hsvColor.toColor()));
                // case PaletteType.rgbWithBlue:
                //   return CustomPaint(painter: RGBWithBlueColorPainter(hsvColor.toColor()));
                case PaletteType.hueWheel:
                  return CustomPaint(painter: HUEColorWheelPainter(hsvColor));
                default:
                  return const CustomPaint();
              }
            },
          ),
        );
      },
    );
  }
}

class HUEColorWheelPainter extends CustomPainter {
  const HUEColorWheelPainter(this.hsvColor, {this.pointerColor});

  final HSVColor hsvColor;
  final Color? pointerColor;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radio = size.width <= size.height ? size.width / 2 : size.height / 2;

    final List<Color> colors = [
      const HSVColor.fromAHSV(1.0, 360.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 300.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 180.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 60.0, 1.0, 1.0).toColor(),
      const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
    ];
    final Gradient gradientS = SweepGradient(colors: colors);
    const Gradient gradientR = RadialGradient(
      colors: [
        Colors.white,
        Color(0x00FFFFFF),
      ],
    );
    canvas.drawCircle(center, radio, Paint()..shader = gradientS.createShader(rect));
    canvas.drawCircle(center, radio, Paint()..shader = gradientR.createShader(rect));
    canvas.drawCircle(center, radio, Paint()..color = Colors.black.withOpacity(1 - hsvColor.value));

    canvas.drawCircle(
      Offset(
        center.dx + hsvColor.saturation * radio * cos((hsvColor.hue * pi / 180)),
        center.dy - hsvColor.saturation * radio * sin((hsvColor.hue * pi / 180)),
      ),
      size.height * 0.04,
      Paint()
        ..color = pointerColor ?? (useWhiteForeground(hsvColor.toColor()) ? Colors.white : Colors.black)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HSVWithHueColorPainter extends CustomPainter {
  const HSVWithHueColorPainter(this.hsvColor, {this.pointerColor});

  final HSVColor hsvColor;
  final Color? pointerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const Gradient gradientV = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Colors.black],
    );
    final Gradient gradientH = LinearGradient(
      colors: [
        Colors.white,
        HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 1.0).toColor(),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradientV.createShader(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = gradientH.createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * hsvColor.saturation, size.height * (1 - hsvColor.value)),
      size.height * 0.04,
      Paint()
        ..color = pointerColor ?? (useWhiteForeground(hsvColor.toColor()) ? Colors.white : Colors.black)
        ..strokeWidth = 1.5
        ..blendMode = BlendMode.luminosity
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
  // Old:
  // return 1.05 / (color.computeLuminance() + 0.05) > 4.5;

  // New:
  int v = sqrt(pow(backgroundColor.red, 2) * 0.299 +
      pow(backgroundColor.green, 2) * 0.587 +
      pow(backgroundColor.blue, 2) * 0.114)
      .round();
  return v < 130 + bias ? true : false;
}

HSVColor hslToHsv(HSLColor color) {
  double s = 0.0;
  double v = 0.0;

  v = color.lightness + color.saturation * (color.lightness < 0.5 ? color.lightness : 1 - color.lightness);
  if (v != 0) s = 2 - 2 * color.lightness / v;

  return HSVColor.fromAHSV(
    color.alpha,
    color.hue,
    s.clamp(0.0, 1.0),
    v.clamp(0.0, 1.0),
  );
}

const String kValidHexPattern = r'^#?[0-9a-fA-F]{1,8}';
const String kCompleteValidHexPattern = r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$';

HSLColor hsvToHsl(HSVColor color) {
  double s = 0.0;
  double l = 0.0;
  l = (2 - color.saturation) * color.value / 2;
  if (l != 0) {
    if (l == 1) {
      s = 0.0;
    } else if (l < 0.5) {
      s = color.saturation * color.value / (l * 2);
    } else {
      s = color.saturation * color.value / (2 - l * 2);
    }
  }
  return HSLColor.fromAHSL(
    color.alpha,
    color.hue,
    s.clamp(0.0, 1.0),
    l.clamp(0.0, 1.0),
  );
}

Color? colorFromHex(String inputString, {bool enableAlpha = true}) {
  // Registers validator for exactly 6 or 8 digits long HEX (with optional #).
  final RegExp hexValidator = RegExp(kCompleteValidHexPattern);
  // Validating input, if it does not match — it's not proper HEX.
  if (!hexValidator.hasMatch(inputString)) return null;
  // Remove optional hash if exists and convert HEX to UPPER CASE.
  String hexToParse = inputString.replaceFirst('#', '').toUpperCase();
  // It may allow HEXs with transparency information even if alpha is disabled,
  if (!enableAlpha && hexToParse.length == 8) {
    // but it will replace this info with 100% non-transparent value (FF).
    hexToParse = 'FF${hexToParse.substring(2)}';
  }
  // HEX may be provided in 3-digits format, let's just duplicate each letter.
  if (hexToParse.length == 3) {
    hexToParse = hexToParse.split('').expand((i) => [i * 2]).join();
  }
  // We will need 8 digits to parse the color, let's add missing digits.
  if (hexToParse.length == 6) hexToParse = 'FF$hexToParse';
  // HEX must be valid now, but as a precaution, it will just "try" to parse it.
  final intColorValue = int.tryParse(hexToParse, radix: 16);
  // If for some reason HEX is not valid — abort the operation, return nothing.
  if (intColorValue == null) return null;
  // Register output color for the last step.
  final color = Color(intColorValue);
  // Decide to return color with transparency information or not.
  return enableAlpha ? color : color.withAlpha(255);
}
