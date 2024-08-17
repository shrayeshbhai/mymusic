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

import 'package:Shreeya/extensions/l10n.dart';
import 'package:Shreeya/main.dart';
import 'package:Shreeya/services/settings_manager.dart';
import 'package:Shreeya/widgets/mini_player.dart';
import 'package:audio_service/audio_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    super.key,
    required this.child,
  });

  final StatefulNavigationShell child;

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  final _selectedIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    // can be wrapped in the SafeArea:
    // body: SafeArea(
    //   child: widget.child,
    // ),

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                logger.log(
                  'Error in mini player bar',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              }
              final metadata = snapshot.data;
              if (metadata == null) {
                return const SizedBox.shrink();
              } else {
                return MiniPlayer(metadata: metadata);
              }
            },
          ),
          NavigationBar(
            selectedIndex: _selectedIndex.value,
            labelBehavior: languageSetting == const Locale('en', '')
                ? NavigationDestinationLabelBehavior.onlyShowSelected
                : NavigationDestinationLabelBehavior.alwaysHide,
            onDestinationSelected: (index) {
              widget.child.goBranch(
                index,
                initialLocation: index == widget.child.currentIndex,
              );
              setState(() {
                _selectedIndex.value = index;
              });
            },
            destinations: !offlineMode.value
                ? [
              NavigationDestination(
                icon: const Icon(FluentIcons.home_24_regular),
                selectedIcon: const Icon(FluentIcons.home_24_filled),
                label: context.l10n?.home ?? 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.download_rounded),
                selectedIcon: const Icon(Icons.download_done_rounded),
                label: context.l10n?.download ?? 'offlineSongs',
              ),
              NavigationDestination(
                icon: const Icon(Icons.library_music),
                selectedIcon: const Icon(Icons.library_music_outlined),
                label: context.l10n?.userPlaylists ?? 'User Playlists',
              ),
              NavigationDestination(
                icon: const Icon(
                  FluentIcons.settings_24_regular,
                ),
                selectedIcon: const Icon(
                  FluentIcons.settings_24_filled,
                ),
                label: context.l10n?.settings ?? 'Settings',
              ),
            ]
                : [
              NavigationDestination(
                icon: const Icon(FluentIcons.home_24_regular),
                selectedIcon: const Icon(FluentIcons.home_24_filled),
                label: context.l10n?.home ?? 'Home',
              ),
              NavigationDestination(
                icon: const Icon(
                  FluentIcons.settings_24_regular,
                ),
                selectedIcon: const Icon(
                  FluentIcons.settings_24_filled,
                ),
                label: context.l10n?.settings ?? 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
