import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DatePickerField extends StatefulWidget {
  final String label;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onChanged;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  Future<void> _openCupertinoPicker() async {
    final now = DateTime.now();

    // geçici seçim tutmak için local variable
    DateTime tempPicked =
        widget.value ?? DateTime(now.year - 18, now.month, now.day);

    // showModalBottomSheet ile iOS tarzı sheet açıyoruz
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // köşeler için
      isScrollControlled: true, // büyük açılabilsin
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgePadding(), // Bunu birazdan tanımlayacağız
          child: _CupertinoDatePickerSheet(
            initialDate: tempPicked,
            minDate: widget.firstDate ?? DateTime(1900),
            maxDate: widget.lastDate ?? now,
            onDateChanged: (d) {
              tempPicked = d;
            },
            onDone: () {
              Navigator.of(ctx).pop(); // sheet kapat
              widget.onChanged(tempPicked); // parent'a bildir
            },
            onCancel: () {
              Navigator.of(ctx).pop(); // hiçbir şey yapmadan kapat
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.value != null
        ? DateFormat('dd.MM.yyyy').format(widget.value!)
        : 'Gün / Ay / Yıl';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.getAuthHeadText(context),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _openCupertinoPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getAuthInputBorder(context),
                width: 1,
              ),
              color: AppTheme.getAuthInputBg(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: widget.value == null
                        ? AppTheme.getAuthInputHint(context)
                        : AppTheme.getAuthInputText(context),
                  ),
                ),

                Icon(
                  LucideIcons.calendar400,
                  size: 18.sp,
                  color: AppTheme.getAuthInputHint(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Küçük padding helper'ı (sheet içi boşluklar için güzel oluyor)
class EdgePadding extends EdgeInsets {
  const EdgePadding()
    : super.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 24 + 12, // picker altına biraz nefes
      );
}

// Bu widget aslında bottom sheet'in içini çiziyor
class _CupertinoDatePickerSheet extends StatelessWidget {
  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;
  final void Function(DateTime) onDateChanged;
  final VoidCallback onDone;
  final VoidCallback onCancel;

  const _CupertinoDatePickerSheet({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    required this.onDateChanged,
    required this.onDone,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false, // üst çentik boşluğu zaten modal dışında
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // header (Cancel / Done)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text(
                  'İptal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ),
              const Text(
                'Doğum Tarihi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: onDone,
                child: const Text(
                  'Bitti',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 200, // tipik iOS picker yüksekliği
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: initialDate,
              minimumDate: minDate,
              maximumDate: maxDate,
              use24hFormat: true,
              onDateTimeChanged: onDateChanged,
            ),
          ),
        ],
      ),
    );
  }
}
