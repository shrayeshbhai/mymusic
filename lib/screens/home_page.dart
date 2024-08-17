/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Shreeya is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Shreeya is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Shreeya, including how to contribute,
 *     please visit: https://github.com/gokadzev/Shreeya
 */

import 'dart:isolate';

import 'package:Shreeya/API/Shreeya.dart';
import 'package:Shreeya/Update/check_update.dart';
import 'package:Shreeya/Update/update.dart';
import 'package:Shreeya/extensions/l10n.dart';
import 'package:Shreeya/main.dart';
import 'package:Shreeya/screens/playlist_page.dart';
import 'package:Shreeya/services/router_service.dart';
import 'package:Shreeya/services/settings_manager.dart';
import 'package:Shreeya/widgets/marque.dart';
import 'package:Shreeya/widgets/playlist_cube.dart';
import 'package:Shreeya/widgets/song_bar.dart';
import 'package:Shreeya/widgets/spinner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override

  @override
  void initState() {
    super.initState();
    _update();
  }
  _update() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final updateInfo = await Isolate.run(() async {
      return await checkUpdate(deviceInfo: deviceInfo);
    });

    if (updateInfo != null) {
      if (mounted) {
        await Update.showUpdateDialog(context, updateInfo);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildTopNavBar(),
            _buildSuggestedPlaylists(),
            _buildRecommendedSongsAndArtists(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilledButton.icon(
              onPressed: () => NavigationManager.router.go(
                '/home/userSongs/recents',
              ),
              icon: const Icon(FluentIcons.history_24_filled),
              label: Text(context.l10n!.recentlyPlayed),
            ),
            const SizedBox(width: 10),

            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: () => NavigationManager.router.go(
                '/home/userSongs/liked',
              ),
              icon: const Icon(FluentIcons.heart_24_filled),
              label: Text(context.l10n!.likedSongs),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: () => NavigationManager.router.go(
                '/home/userLikedPlaylists',
              ),
              icon: const Icon(
                Icons.library_music_outlined,
              ),
              label: Text(context.l10n!.likedPlaylists),
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedPlaylists() {
    return FutureBuilder(
      future: getPlaylists(playlistsNum: 5),
      builder: _buildSuggestedPlaylistsWidget,
    );
  }

  Widget _buildSuggestedPlaylistsWidget(
      BuildContext context,
      AsyncSnapshot<List<dynamic>> snapshot,
      ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingWidget();
    } else if (snapshot.hasError) {
      logger.log(
        'Error in _buildSuggestedPlaylistsWidget',
        snapshot.error,
        snapshot.stackTrace,
      );
      return _buildErrorWidget(context);
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const SizedBox.shrink();
    }

    final _suggestedPlaylists = snapshot.data!;
    final calculatedSize = MediaQuery.of(context).size.height * 0.25;
    final _suggestedPlaylistsSize = calculatedSize / 1.1;

    return Column(
      children: [
        _buildSectionHeader(
          context.l10n!.suggestedPlaylists,
          IconButton(
            onPressed: () {
              NavigationManager.router.go(
                '/home/playlists',
              );
            },
            icon: const Icon(CupertinoIcons.music_note_list),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        SizedBox(
          height: _suggestedPlaylistsSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemCount: _suggestedPlaylists.length,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemBuilder: (context, index) {
              final playlist = _suggestedPlaylists[index];
              return PlaylistCube(
                playlist,
                isAlbum: playlist['isAlbum'],
                size: _suggestedPlaylistsSize,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSongsAndArtists() {
    return ValueListenableBuilder<bool>(
      valueListenable: defaultRecommendations,
      builder: (_, recommendations, __) {
        return FutureBuilder(
          future: getRecommendedSongs(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            final calculatedSize = MediaQuery.of(context).size.height * 0.25;
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return _buildLoadingWidget();
              case ConnectionState.done:
                if (snapshot.hasError) {
                  logger.log(
                    'Error in _buildRecommendedSongsAndArtists',
                    snapshot.error,
                    snapshot.stackTrace,
                  );
                  return _buildErrorWidget(context);
                }
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                return _buildRecommendedContent(
                  context,
                  snapshot.data,
                  calculatedSize,
                  showArtists: !recommendations,
                );
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(35),
        child: Spinner(),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Text(
        '${context.l10n!.error}!',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildRecommendedContent(
      BuildContext context,
      List<dynamic> data,
      double calculatedSize, {
        bool showArtists = true,
      }) {
    return Column(
      children: <Widget>[
        if (showArtists) _buildSectionHeader(context.l10n!.suggestedArtists),
        if (showArtists)
          SizedBox(
            height: calculatedSize,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemCount: 5,
              itemBuilder: (context, index) {
                final artist = data[index]['artist'].split('~')[0];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistPage(
                          cubeIcon: FluentIcons.mic_sparkle_24_regular,
                          playlistId: artist,
                          isArtist: true,
                        ),
                      ),
                    );
                  },
                  child: PlaylistCube(
                    {'title': artist},
                    borderRadius: 15,
                    onClickOpen: false,
                    showFavoriteButton: false,
                    cubeIcon: FluentIcons.mic_sparkle_24_regular,
                  ),
                );
              },
            ),
          ),
        _buildSectionHeader(
          context.l10n!.recommendedForYou,
          IconButton(
            onPressed: () {
              setActivePlaylist({
                'title': context.l10n!.recommendedForYou,
                'list': data,
              });
            },
            iconSize: 30,
            icon: Icon(
              FluentIcons.play_circle_24_filled,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return SongBar(data[index], true);
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, [IconButton? actionButton]) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.4,
            child: MarqueeWidget(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (actionButton != null) actionButton,
        ],
      ),
    );
  }
}
