import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModelSelector extends StatelessWidget {
  final List<String> models;
  final int selectedIndex;

  const ModelSelector({
    Key? key,
    required this.models,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Model:", style: TextStyle(color: Colors.white, fontSize: 12.sp)),
        SizedBox(width: 10.w),
        DropdownButton<int>(
          value: selectedIndex,
          items: models.asMap().entries.map((entry) {
            int idx = entry.key;
            String model = entry.value;
            return DropdownMenuItem<int>(
              value: idx,
              child: Text(model, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
            );
          }).toList(),
          onChanged: (newIndex) {
            // Update the selected index
          },
        ),
      ],
    );
  }
}
