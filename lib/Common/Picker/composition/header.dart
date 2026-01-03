import 'package:flutter/material.dart';

import '../provider/time_picker.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = TimePickerProvider.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Text(provider.sheetTitle, style: provider.sheetTitleStyle, textAlign: TextAlign.center,)),
          if (provider.rightWidget != null)
            provider.rightWidget!
        ],
      ),
    );
  }
}
