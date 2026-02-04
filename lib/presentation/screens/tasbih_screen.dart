import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/utils/number_converter.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;
  int _target = 33;
  int _presetIndex = 0;
  final _presets = [
    {'ar': 'سُبْحَانَ اللَّهِ', 'en': 'Subhanallah', 't': 33},
    {'ar': 'الْحَمْدُ لِلَّهِ', 'en': 'Alhamdulillah', 't': 33},
    {'ar': 'اللَّهُ أَكْبَرُ', 'en': 'Allahu Akbar', 't': 34},
  ];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) => setState(() {
          _count = p.getInt('tasbih_c') ?? 0;
          _presetIndex = p.getInt('tasbih_p') ?? 0;
          // Ensure index is valid
          if (_presetIndex < 0 || _presetIndex >= _presets.length) {
            _presetIndex = 0;
          }
          _target = _presets[_presetIndex]['t'] as int;
        }));
  }

  void _update(int c) {
    setState(() => _count = c);
    SharedPreferences.getInstance().then((p) => p.setInt('tasbih_c', c));
  }

  @override
  Widget build(BuildContext context) {
    final p = _presets[_presetIndex];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("المسبحة"), leading: const BackButton()),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () {
                  setState(() {
                    _presetIndex = i;
                    _target = _presets[i]['t'] as int;
                    _count = 0;
                  });
                  SharedPreferences.getInstance()
                      .then((p) => p.setInt('tasbih_p', i));
                },
                child: Chip(
                  label: Text(
                      "${_presets[i]['ar']} (${_presets[i]['t']})"
                          .toWesternArabic,
                      style: const TextStyle(fontFamily: 'Cairo')),
                  backgroundColor:
                      _presetIndex == i ? AppTheme.primaryColor : Colors.white,
                  labelStyle: TextStyle(
                      color: _presetIndex == i ? Colors.white : Colors.black),
                  side: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 20)
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p['ar'] as String,
                      style: const TextStyle(
                          fontSize: 32,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold)),
                  Text(p['en'] as String,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),
                  Text("$_count".toWesternArabic,
                      style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor)),
                  Text("of $_target".toWesternArabic,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: LinearProgressIndicator(
                        value: _count / _target,
                        color: AppTheme.primaryColor,
                        backgroundColor: Colors.grey[100]),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _btn(HugeIcons.strokeRoundedMinusSign,
                    () => _count > 0 ? _update(_count - 1) : null),
                const SizedBox(width: 20),
                _btn(HugeIcons.strokeRoundedPlusSign, () {
                  if (_count < _target) {
                    HapticFeedback.lightImpact();
                    _update(_count + 1);
                  } else {
                    HapticFeedback.heavyImpact();
                    _update(0);
                  }
                }, isBig: true),
                const SizedBox(width: 20),
                _btn(HugeIcons.strokeRoundedRefresh, () => _update(0)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _btn(dynamic icon, VoidCallback onTap, {bool isBig = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isBig ? 24 : 16),
        decoration: BoxDecoration(
            color: isBig ? AppTheme.primaryColor : Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10)
            ]),
        child: HugeIcon(
            icon: icon,
            color: isBig ? Colors.white : AppTheme.primaryColor,
            size: isBig ? 32 : 24),
      ),
    );
  }
}
