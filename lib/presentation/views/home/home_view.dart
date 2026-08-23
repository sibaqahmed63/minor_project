// lib/presentation/views/home/home_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/theme_provider.dart';
import 'home_viewmodel.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(homeViewModelProvider);
    final vmNotifier = ref.read(homeViewModelProvider.notifier);

    final asyncTheme = ref.watch(themeModeProvider);
    final isDark =
        (asyncTheme.asData?.value ?? AppThemeMode.light) ==
            AppThemeMode.dark;

    return asyncState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      error: (err, st) => Scaffold(
        appBar: AppBar(
          title: const Text('Overview'),
        ),
        body: Center(
          child: Text('Error loading home: $err'),
        ),
      ),

      data: (state) {
        final selected = state.environments.firstWhere(
              (e) => e.id == state.selectedEnvironmentId,
          orElse: () => state.environments.first,
        );

        return Scaffold(
          backgroundColor:
          isDark
              ? AppColors.surfaceDark
              : const Color(0xFFF5F7FB),

          // ------------------------------------------------------------------
          // PREMIUM HEADER
          // ------------------------------------------------------------------
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(112),
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF111A30),
                    Color(0xFF25345F),
                  ],
                )
                    : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF2B3A67),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      isDark ? 0.25 : 0.12,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    12,
                    14,
                    16,
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ------------------------------------------------------
                      // TITLE
                      // ------------------------------------------------------
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overview',
                              style: AppTypography.displaySmall.copyWith(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              'Monitor your fields at a glance',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------------------
                      // THEME BUTTON
                      // ------------------------------------------------------
                      Material(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            ref
                                .read(themeModeProvider.notifier)
                                .toggleTheme();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(11),
                            child: Icon(
                              isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: AppColors.accentGold,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // BODY
          // ------------------------------------------------------------------
          body: RefreshIndicator(
            color: AppColors.primaryGradientEnd,

            onRefresh: () => vmNotifier.refresh(),

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                28,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ----------------------------------------------------------
                  // SECTION LABEL
                  // ----------------------------------------------------------
                  _sectionLabel(
                    context,
                    'Your environments',
                    'Select a field to monitor',
                  ),

                  const SizedBox(height: 12),

                  // ----------------------------------------------------------
                  // ENVIRONMENT SELECTOR
                  // ----------------------------------------------------------
                  _buildEnvironmentSelector(
                    context,
                    state,
                    vmNotifier,
                    isDark,
                  ),

                  const SizedBox(height: 22),

                  // ----------------------------------------------------------
                  // SELECTED FIELD INFO
                  // ----------------------------------------------------------
                  _buildFieldHeader(
                    context,
                    selected,
                    isDark,
                  ),

                  const SizedBox(height: 14),

                  // ----------------------------------------------------------
                  // METRICS
                  // ----------------------------------------------------------
                  _buildSummaryCards(
                    context,
                    selected,
                    isDark,
                  ),

                  const SizedBox(height: 20),

                  // ----------------------------------------------------------
                  // QUICK ACTIONS
                  // ----------------------------------------------------------
                  _buildQuickActions(
                    context,
                    isDark,
                  ),

                  const SizedBox(height: 26),

                  // ----------------------------------------------------------
                  // ACTIVITY HEADER
                  // ----------------------------------------------------------
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Recent activity',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : const Color(0xFF101C2B),
                        ),
                      ),

                      Text(
                        'View all',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.accentGold
                              : AppColors.primaryGradientEnd,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ----------------------------------------------------------
                  // ACTIVITY
                  // ----------------------------------------------------------
                  _buildRecentActivityMock(
                    context,
                    isDark,
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // BOTTOM NAV
          // ------------------------------------------------------------------
          bottomNavigationBar: _buildBottomNav(
            context,
            isDark,
          ),

          // ------------------------------------------------------------------
          // FAB
          // ------------------------------------------------------------------
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withOpacity(0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: FloatingActionButton(
              heroTag: 'simulation_fab',

              backgroundColor: AppColors.accentGold,

              foregroundColor: Colors.black,

              elevation: 0,

              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/simulation',
                );
              },

              child: const Icon(
                Icons.play_arrow_rounded,
                size: 25,
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // SECTION LABEL
  // ==========================================================================

  Widget _sectionLabel(
      BuildContext context,
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withOpacity(0.70),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ENVIRONMENT SELECTOR
  // ==========================================================================

  Widget _buildEnvironmentSelector(
      BuildContext context,
      HomeState state,
      HomeNotifier vmNotifier,
      bool isDark,
      ) {
    return SizedBox(
      height: 58,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: state.environments.length,

        separatorBuilder: (_, __) =>
        const SizedBox(width: 10),

        itemBuilder: (context, index) {
          final env = state.environments[index];

          final selected =
              env.id == state.selectedEnvironmentId;

          return GestureDetector(
            onTap: () {
              vmNotifier.selectEnvironment(env.id);
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),

              constraints: const BoxConstraints(
                minWidth: 150,
                maxWidth: 235,
              ),

              decoration: BoxDecoration(
                gradient: selected
                    ? AppColors.goldAccentGradient
                    : null,

                color: selected
                    ? null
                    : isDark
                    ? AppColors.surfaceMutedDark
                    : Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : isDark
                      ? AppColors.borderDark
                      : const Color(0xFFE1E6ED),
                ),

                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: AppColors.accentGold
                        .withOpacity(0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
                    : [],
              ),

              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,

                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withOpacity(0.42)
                          : isDark
                          ? Colors.white.withOpacity(0.06)
                          : const Color(0xFFF0F3F7),

                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      Icons.terrain_rounded,

                      size: 18,

                      color: selected
                          ? Colors.black
                          : isDark
                          ? AppColors.accentGold
                          : AppColors.primaryGradientEnd,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      env.name,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: selected
                            ? Colors.black
                            : isDark
                            ? AppColors.textPrimaryDark
                            : const Color(0xFF172033),

                        fontSize: 13,

                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),

                  if (selected) ...[
                    const SizedBox(width: 7),

                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.black,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // SELECTED FIELD HEADER
  // ==========================================================================

  Widget _buildFieldHeader(
      BuildContext context,
      EnvironmentSummary env,
      bool isDark,
      ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),

      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceMutedDark
            : Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : const Color(0xFFE2E7ED),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.accentGold.withOpacity(0.12)
                  : const Color(0xFFFFF4D8),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(
              Icons.agriculture_rounded,
              size: 20,
              color: AppColors.accentAmber,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  env.name,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF172033),

                    fontSize: 14,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,

                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      'Environment active',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF718078),

                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SUMMARY CARDS
  // ==========================================================================

  Widget _buildSummaryCards(
      BuildContext context,
      EnvironmentSummary env,
      bool isDark,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Expanded(
          child: _metricCard(
            context,
            title: 'Temperature',
            value: '${env.avgTempC}°',
            unit: 'C',
            icon: Icons.thermostat_rounded,
            accent: AppColors.info,
            isDark: isDark,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _metricCard(
            context,
            title: 'Soil moisture',
            value: '${env.avgSoilMoisturePct}',
            unit: '%',
            icon: Icons.water_drop_rounded,
            accent: AppColors.primaryGradientEnd,
            isDark: isDark,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _metricCard(
            context,
            title: 'Alerts',
            value: '${env.activeAlerts}',
            unit: 'active',
            icon: Icons.warning_rounded,
            accent: AppColors.warning,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SINGLE METRIC CARD
  // ==========================================================================

  Widget _metricCard(
      BuildContext context, {
        required String title,
        required String value,
        required String unit,
        required IconData icon,
        required Color accent,
        required bool isDark,
      }) {
    return Container(
      height: 137,

      padding: const EdgeInsets.all(11),

      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceMutedDark
            : Colors.white,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : const Color(0xFFE1E6ED),
        ),

        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Icon
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: accent.withOpacity(
                isDark ? 0.16 : 0.11,
              ),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(
              icon,
              color: accent,
              size: 18,
            ),
          ),

          const Spacer(),

          // Value
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.baseline,

            textBaseline: TextBaseline.alphabetic,

            children: [
              Flexible(
                child: Text(
                  value,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF172033),

                    fontSize: 20,

                    fontWeight: FontWeight.w700,

                    letterSpacing: -0.4,
                  ),
                ),
              ),

              const SizedBox(width: 2),

              Text(
                unit,

                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF718078),

                  fontSize: 10,

                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // Title
          Text(
            title,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF687770),

              fontSize: 10.5,

              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: 0.6,

              minHeight: 3,

              color: accent,

              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFFE8ECF0),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // QUICK ACTIONS
  // ==========================================================================

  Widget _buildQuickActions(
      BuildContext context,
      bool isDark,
      ) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,

            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/map',
                );
              },

              icon: const Icon(
                Icons.map_outlined,
                size: 18,
              ),

              label: const Text(
                'Open Map',
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: SizedBox(
            height: 48,

            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/alerts',
                );
              },

              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 18,
              ),

              label: const Text(
                'View Alerts',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // RECENT ACTIVITY
  // ==========================================================================

  Widget _buildRecentActivityMock(
      BuildContext context,
      bool isDark,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceMutedDark
            : Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : const Color(0xFFE3E8ED),
        ),
      ),

      child: Column(
        children: List.generate(
          3,
              (i) {
            return _activityItem(
              context,
              index: i,
              isDark: isDark,
            );
          },
        ),
      ),
    );
  }

  Widget _activityItem(
      BuildContext context, {
        required int index,
        required bool isDark,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),

      child: Row(
        children: [
          // Info icon
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(
                isDark ? 0.15 : 0.10,
              ),

              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.info,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  'Node ${index + 1} reported high temperature',

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF172033),

                    fontSize: 13,

                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '2 minutes ago',

                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : const Color(0xFF7A8782),

                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(
            Icons.chevron_right_rounded,

            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF7C8984),

            size: 21,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BOTTOM NAVIGATION
  // ==========================================================================

  Widget _buildBottomNav(
      BuildContext context,
      bool isDark,
      ) {
    return BottomNavigationBar(
      currentIndex: 0,

      onTap: (index) {
        switch (index) {
          case 0:
            break;

          case 1:
            Navigator.pushNamed(
              context,
              '/map',
            );
            break;

          case 2:
            Navigator.pushNamed(
              context,
              '/alerts',
            );
            break;

          case 3:
            Navigator.pushNamed(
              context,
              '/settings',
            );
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_outlined,
          ),
          activeIcon: Icon(
            Icons.home_rounded,
          ),
          label: 'Home',
        ),

        BottomNavigationBarItem(
          icon: Icon(
            Icons.map_outlined,
          ),
          activeIcon: Icon(
            Icons.map_rounded,
          ),
          label: 'Map',
        ),

        BottomNavigationBarItem(
          icon: Icon(
            Icons.notifications_none_rounded,
          ),
          activeIcon: Icon(
            Icons.notifications_rounded,
          ),
          label: 'Alerts',
        ),

        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings_outlined,
          ),
          activeIcon: Icon(
            Icons.settings_rounded,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}