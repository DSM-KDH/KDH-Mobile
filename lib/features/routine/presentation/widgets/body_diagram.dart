import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';

class BodyDiagram extends StatelessWidget {
  const BodyDiagram({super.key, required this.selectedMuscles});

  final Set<String> selectedMuscles;

  bool _hl(List<String> muscles) =>
      muscles.any((m) => selectedMuscles.contains(m));

  Color _bg(bool h) => h ? KdhColor.red200 : KdhColor.red50;
  Color _fg(bool h) => h ? KdhColor.background : KdhColor.gray800;

  Widget _cell(
    String label,
    bool highlighted, {
    double w = 30,
    double h = 58,
  }) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: _bg(highlighted),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: KdhTextStyle.caption4.copyWith(color: _fg(highlighted)),
          textAlign: TextAlign.center,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final chest = _hl(['가슴', '등']);
    final shoulder = _hl(['어깨']);
    final arm = _hl(['팔']);
    final core = _hl(['복근', '코어']);
    final thigh = _hl(['허벅지']);
    final calf = _hl(['종아리']);

    const g = SizedBox(width: 2);
    const vg = SizedBox(height: 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: KdhColor.red50,
            shape: BoxShape.circle,
          ),
        ),
        vg,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cell('어', shoulder, w: 20, h: 18),
            g,
            _cell('가슴', chest, w: 42, h: 30),
            g,
            _cell('깨', shoulder, w: 20, h: 18),
          ],
        ),
        vg,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cell('팔', arm, w: 20, h: 50),
            g,
            _cell('복근', core, w: 42, h: 37),
            g,
            _cell('팔', arm, w: 20, h: 50),
          ],
        ),
        vg,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cell('허벅지', thigh, w: 20, h: 50),
            g,
            _cell('허벅지', thigh, w: 20, h: 50),
          ],
        ),
        vg,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cell('종아리', calf, w: 20, h: 48),
            g,
            _cell('종아리', calf, w: 20, h: 48),
          ],
        ),
      ],
    );
  }
}
