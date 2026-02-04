import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/theme.dart';
import '../../services/prayer_service.dart';
import 'adhkar_screen.dart';
import 'tasbih_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Hijri setup
    HijriCalendar.setLocal('ar');
    final hijriDate = HijriCalendar.now();
    final gregDate = DateTime.now();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Defines shadow that is subtle in light mode and invisible/dark in dark mode
    final List<BoxShadow> adaptiveShadow = isDark
        ? [] // No shadow in dark mode for cleaner look
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            children: [
              _buildHeader(theme),
              const SizedBox(height: 30),
              _buildPrayerRing(theme, isDark),
              const SizedBox(height: 25),
              // Dates Section
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: adaptiveShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      hijriDate.toFormat("dd MMMM yyyy"),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE، d MMMM yyyy', 'ar').format(gregDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Grid (Row)
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      context,
                      "الأذكار",
                      "Adhkar",
                      HugeIcons.strokeRoundedBookOpen01,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdhkarScreen())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      context,
                      "التسبيح",
                      "Tasbih",
                      HugeIcons.strokeRoundedFingerPrint, // Updated Icon
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TasbihScreen())),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Aligned to start
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("السلام عليكم",
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)),
            Text("فخر الدين",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        // Notification Icon Removed
      ],
    );
  }

  Widget _buildPrayerRing(ThemeData theme, bool isDark) {
    return Consumer<PrayerService>(
      builder: (context, prayerService, _) {
        final nextPrayer = prayerService.nextPrayer;

        String prayerName = "جاري التحميل...";
        String prayerTime = "--:--";
        dynamic icon = HugeIcons.strokeRoundedMoon02;
        String nextPrayerName = "الصلاة القادمة";

        if (prayerService.prayerTimes != null) {
          final adjustedNext = prayerService.getAdjustedTime(nextPrayer);

          // Map English names to Arabic
          switch (nextPrayer) {
            case adhan.Prayer.fajr:
              prayerName = "الفجر";
              icon = HugeIcons.strokeRoundedSun02;
              break;
            case adhan.Prayer.dhuhr:
              prayerName = "الظهر";
              icon = HugeIcons.strokeRoundedSun03;
              break;
            case adhan.Prayer.asr:
              prayerName = "العصر";
              icon = HugeIcons.strokeRoundedSun01;
              break;
            case adhan.Prayer.maghrib:
              prayerName = "المغرب";
              icon = HugeIcons.strokeRoundedSunset;
              break;
            case adhan.Prayer.isha:
              prayerName = "العشاء";
              icon = HugeIcons.strokeRoundedMoon01;
              break;
            case adhan.Prayer.none:
              prayerName = "الفجر";
              icon = HugeIcons.strokeRoundedSun02;
              break;
            default:
              prayerName = "الفجر";
          }

          if (adjustedNext != null) {
            prayerTime = DateFormat.jm().format(adjustedNext);
          } else if (nextPrayer == adhan.Prayer.none) {
            final fajr = prayerService.fajr;
            if (fajr != null) {
              prayerTime = DateFormat.jm().format(fajr);
            }
          }
        }

        return Container(
          height: 240,
          width: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.08),
                AppTheme.primaryColor.withValues(alpha: 0.03),
              ],
            ),
            border: Border.all(
                color: isDark
                    ? Colors.white12
                    : Colors.white.withValues(alpha: 0.6),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(icon: icon, color: AppTheme.primaryColor, size: 32),
              const SizedBox(height: 12),
              Text(prayerName,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontSize: 22, fontWeight: FontWeight.w500)),
              Text(prayerTime,
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme
                          .primaryColor, // Changed to primary for consistency in dark mode
                      height: 1.0)),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(nextPrayerName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, String titleAr, String titleEn,
      dynamic icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor, // Dynamic background
                borderRadius: BorderRadius.circular(18),
              ),
              child:
                  HugeIcon(icon: icon, color: AppTheme.primaryColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(titleEn,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(titleAr,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
