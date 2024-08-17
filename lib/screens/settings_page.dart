/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Shrayesh-Music is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Shrayesh-Music is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Shrayesh-Music, including how to contribute,
 *     please visit: https://github.com/gokadzev/Shrayesh-Music
 */

import 'package:Shreeya/API/Shreeya.dart';
import 'package:Shreeya/extensions/l10n.dart';
import 'package:Shreeya/main.dart';
import 'package:Shreeya/screens/search_page.dart';
import 'package:Shreeya/services/data_manager.dart';
import 'package:Shreeya/services/router_service.dart';
import 'package:Shreeya/services/settings_manager.dart';
import 'package:Shreeya/style/app_colors.dart';
import 'package:Shreeya/style/app_themes.dart';
import 'package:Shreeya/utilities/flutter_bottom_sheet.dart';
import 'package:Shreeya/utilities/flutter_toast.dart';
import 'package:Shreeya/widgets/confirmation_dialog.dart';
import 'package:Shreeya/widgets/custom_bar.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final activatedColor =
        Theme.of(context).colorScheme.inversePrimary; // or primaryfixeddim
    final inactivatedColor = Theme.of(context).colorScheme.secondaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n!.settings),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // CATEGORY: PREFERENCES
            _buildSectionTitle(
              primaryColor,
              context.l10n!.preferences,
            ),
            CustomBar(
              context.l10n!.accentColor,
              FluentIcons.color_24_filled,
              onTap: () => showCustomBottomSheet(
                context,
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: availableColors.length,
                  itemBuilder: (context, index) {
                    final color = availableColors[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (availableColors.length > index)
                            GestureDetector(
                              onTap: () {
                                addOrUpdateData(
                                  'settings',
                                  'accentColor',
                                  color.value,
                                );
                                Shreeya.updateAppState(
                                  context,
                                  newAccentColor: color,
                                  useSystemColor: false,
                                );
                                showToast(
                                  context,
                                  context.l10n!.accentChangeMsg,
                                );
                                Navigator.pop(context);
                              },
                              child: Material(
                                elevation: 4,
                                shape: const CircleBorder(),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: themeMode == ThemeMode.light
                                      ? color.withAlpha(150)
                                      : color,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            CustomBar(
              context.l10n!.themeMode,
              FluentIcons.weather_sunny_28_filled,
              onTap: () {
                final availableModes = [
                  ThemeMode.system,
                  ThemeMode.light,
                  ThemeMode.dark,
                ];
                showCustomBottomSheet(
                  context,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: availableModes.length,
                    itemBuilder: (context, index) {
                      final mode = availableModes[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        color: themeMode == mode
                            ? activatedColor
                            : inactivatedColor,
                        child: ListTile(
                          minTileHeight: 65,
                          title: Text(
                            mode.name,
                          ),
                          onTap: () {
                            addOrUpdateData(
                              'settings',
                              'themeMode',
                              mode.name,
                            );
                            Shreeya.updateAppState(
                              context,
                              newThemeMode: mode,
                            );

                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            CustomBar(
              context.l10n!.language,
              FluentIcons.translate_24_filled,
              onTap: () {
                final availableLanguages = appLanguages.keys.toList();
                final activeLanguageCode =
                    Localizations.localeOf(context).languageCode;
                showCustomBottomSheet(
                  context,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: availableLanguages.length,
                    itemBuilder: (context, index) {
                      final language = availableLanguages[index];
                      final languageCode = appLanguages[language] ?? 'en';
                      return Card(
                        color: activeLanguageCode == languageCode
                            ? activatedColor
                            : inactivatedColor,
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          minTileHeight: 65,
                          title: Text(
                            language,
                          ),
                          onTap: () {
                            addOrUpdateData(
                              'settings',
                              'language',
                              language,
                            );
                            Shreeya.updateAppState(
                              context,
                              newLocale: Locale(
                                languageCode,
                              ),
                            );

                            showToast(
                              context,
                              context.l10n!.languageMsg,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            CustomBar(
              context.l10n!.audioQuality,
              Icons.music_note,
              onTap: () {
                final availableQualities = ['low', 'medium', 'high'];

                showCustomBottomSheet(
                  context,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: availableQualities.length,
                    itemBuilder: (context, index) {
                      final quality = availableQualities[index];
                      final isCurrentQuality =
                          audioQualitySetting.value == quality;

                      return Card(
                        color: isCurrentQuality
                            ? activatedColor
                            : inactivatedColor,
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          minTileHeight: 65,
                          title: Text(quality),
                          onTap: () {
                            addOrUpdateData(
                              'settings',
                              'audioQuality',
                              quality,
                            );
                            audioQualitySetting.value = quality;

                            showToast(
                              context,
                              context.l10n!.audioQualityMsg,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            CustomBar(
              context.l10n!.dynamicColor,
              FluentIcons.toggle_left_24_filled,
              trailing: Switch(
                value: useSystemColor.value,
                onChanged: (value) {
                  addOrUpdateData(
                    'settings',
                    'useSystemColor',
                    value,
                  );
                  useSystemColor.value = value;
                  Shreeya.updateAppState(
                    context,
                    newAccentColor: primaryColorSetting,
                    useSystemColor: value,
                  );
                  showToast(
                    context,
                    context.l10n!.settingChangedMsg,
                  );
                },
              ),
            ),
            if (themeMode == ThemeMode.dark)
              CustomBar(
                context.l10n!.usePureBlack,
                FluentIcons.color_background_24_filled,
                trailing: Switch(
                  value: usePureBlackColor.value,
                  onChanged: (value) {
                    addOrUpdateData(
                      'settings',
                      'usePureBlackColor',
                      value,
                    );
                    usePureBlackColor.value = value;
                    Shreeya.updateAppState(context);
                    showToast(
                      context,
                      context.l10n!.settingChangedMsg,
                    );
                  },
                ),
              ),
            ValueListenableBuilder<bool>(
              valueListenable: offlineMode,
              builder: (_, value, __) {
                return CustomBar(
                  context.l10n!.offlineMode,
                  FluentIcons.arrow_download_24_regular,
                  trailing: Switch(
                    value: value,
                    onChanged: (value) {
                      addOrUpdateData(
                        'settings',
                        'offlineMode',
                        value,
                      );
                      offlineMode.value = value;
                      showToast(
                        context,
                        context.l10n!.restartAppMsg,
                      );
                    },
                  ),
                );
              },
            ),
            if (!offlineMode.value)
              Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: sponsorBlockSupport,
                    builder: (_, value, __) {
                      return CustomBar(
                        'SponsorBlock',
                        FluentIcons.presence_blocked_24_regular,
                        trailing: Switch(
                          value: value,
                          onChanged: (value) {
                            addOrUpdateData(
                              'settings',
                              'sponsorBlockSupport',
                              value,
                            );
                            sponsorBlockSupport.value = value;
                            showToast(
                              context,
                              context.l10n!.settingChangedMsg,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: playNextSongAutomatically,
                    builder: (_, value, __) {
                      return CustomBar(
                        context.l10n!.automaticSongPicker,
                        FluentIcons.music_note_2_play_20_filled,
                        trailing: Switch(
                          value: value,
                          onChanged: (value) {
                            audioHandler.changeAutoPlayNextStatus();
                            showToast(
                              context,
                              context.l10n!.settingChangedMsg,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: defaultRecommendations,
                    builder: (_, value, __) {
                      return CustomBar(
                        context.l10n!.originalRecommendations,
                        FluentIcons.channel_share_24_regular,
                        trailing: Switch(
                          value: value,
                          onChanged: (value) {
                            addOrUpdateData(
                              'settings',
                              'defaultRecommendations',
                              value,
                            );
                            defaultRecommendations.value = value;
                            showToast(
                              context,
                              context.l10n!.settingChangedMsg,
                            );
                          },
                        ),
                      );
                    },
                  ),

                  // CATEGORY: TOOLS
                  _buildSectionTitle(
                    primaryColor,
                    context.l10n!.tools,
                  ),
                  CustomBar(
                    context.l10n!.clearCache,
                    FluentIcons.broom_24_filled,
                    onTap: () {
                      clearCache();
                      showToast(
                        context,
                        '${context.l10n!.cacheMsg}!',
                      );
                    },
                  ),
                  CustomBar(
                    context.l10n!.clearSearchHistory,
                    FluentIcons.history_24_filled,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(
                            submitMessage: context.l10n!.clear,
                            confirmationMessage:
                            context.l10n!.clearSearchHistoryQuestion,
                            onCancel: () => {Navigator.of(context).pop()},
                            onSubmit: () => {
                              Navigator.of(context).pop(),
                              searchHistory = [],
                              deleteData('user', 'searchHistory'),
                              showToast(
                                context,
                                '${context.l10n!.searchHistoryMsg}!',
                              ),
                            },
                          );
                        },
                      );
                    },
                  ),
                  CustomBar(
                    context.l10n!.clearRecentlyPlayed,
                    FluentIcons.receipt_play_24_filled,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(
                            submitMessage: context.l10n!.clear,
                            confirmationMessage:
                            context.l10n!.clearRecentlyPlayedQuestion,
                            onCancel: () => {Navigator.of(context).pop()},
                            onSubmit: () => {
                              Navigator.of(context).pop(),
                              userRecentlyPlayed = [],
                              deleteData('user', 'recentlyPlayedSongs'),
                              showToast(
                                context,
                                '${context.l10n!.recentlyPlayedMsg}!',
                              ),
                            },
                          );
                        },
                      );
                    },
                  ),
                  CustomBar(
                    context.l10n!.backupUserData,
                    FluentIcons.cloud_sync_24_filled,
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(context.l10n!.folderRestrictions),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  context.l10n!.understand.toUpperCase(),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                      final response = await backupData(context);
                      showToast(context, response);
                    },
                  ),

                  CustomBar(
                    context.l10n!.restoreUserData,
                    FluentIcons.cloud_add_24_filled,
                    onTap: () async {
                      final response = await restoreData(context);
                      showToast(context, response);
                    },
                  ),
                ],
              ),
            // CATEGORY: OTHERS
            _buildSectionTitle(
              primaryColor,
              context.l10n!.others,
            ),
            CustomBar(
              context.l10n!.licenses,
              FluentIcons.document_24_filled,
              onTap: () => NavigationManager.router.go(
                '/settings/license',
              ),
            ),
            CustomBar(
              '${context.l10n!.copyLogs} (${logger.getLogCount()})',
              FluentIcons.error_circle_24_filled,
              onTap: () async =>
                  showToast(context, await logger.copyLogs(context)),
            ),
            CustomBar(
              context.l10n!.about,
              FluentIcons.book_information_24_filled,
              onTap: () => NavigationManager.router.go(
                '/settings/about',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(Color primaryColor, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
