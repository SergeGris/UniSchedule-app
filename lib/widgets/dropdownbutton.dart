import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class UniScheduleDropDownButton extends StatelessWidget {
    const UniScheduleDropDownButton({
            required this.hint,
            required this.initialSelection,
            required this.items,
            required this.onSelected,
            this.alignment = Alignment.center,
            super.key,
    });

    final String hint;
    final String? initialSelection;
    final List<DropdownMenuItem<String>> items;
    final ValueChanged<String?>? onSelected;
    final Alignment alignment;

    @override
    Widget build(BuildContext context) {
        return DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
                isExpanded: false,
                isDense: false,
                alignment: alignment,
                hint: Text(hint, maxLines: 1, overflow: TextOverflow.fade),
                items: items,
                value: initialSelection,
                onChanged: onSelected,

                iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down),
                    openMenuIcon: Icon(Icons.arrow_drop_up),
                ),

                buttonStyleData: ButtonStyleData(
                    // padding: const EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // For elevation effect
                    ),
                    elevation: 0,
                ),

                dropdownStyleData: DropdownStyleData(
                    // isOverButton: true,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),

                    scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(16),
                        thickness: MaterialStateProperty.all<double>(16),
                        thumbVisibility: MaterialStateProperty.all<bool>(true),
                    ),
                ),

                menuItemStyleData: const MenuItemStyleData(
                    // height: 40,
                    //padding: EdgeInsets.only(left: 16, right: 16),
                ),
            ),
        );
    }
}
