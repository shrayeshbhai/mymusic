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
import 'package:Shreeya/screens/playlist_page.dart';
import 'package:Shreeya/widgets/like_button.dart';
import 'package:Shreeya/widgets/no_artwork_cube.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class PlaylistCube extends StatelessWidget {
  PlaylistCube(
    this.playlist, {
    super.key,
    this.playlistData,
    this.onClickOpen = true,
    this.showFavoriteButton = true,
    this.cubeIcon = FluentIcons.music_note_1_24_regular,
    this.size = 220,
    this.borderRadius = 13,
    this.isAlbum = false,
  });

  final Map? playlistData;
  final Map playlist;
  final bool onClickOpen;
  final bool showFavoriteButton;
  final IconData cubeIcon;
  final double size;
  final double borderRadius;
  final bool? isAlbum;

  final likeStatusToIconMapper = {
    true: FluentIcons.heart_24_filled,
    false: FluentIcons.heart_24_regular,
  };

  late final playlistLikeStatus =
      ValueNotifier<bool>(isPlaylistAlreadyLiked(playlist['ytid']));

  @override
  Widget build(BuildContext context) {
    final _secondaryColor = Theme.of(context).colorScheme.secondary;
    final _onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap:
              onClickOpen && (playlist['ytid'] != null || playlistData != null)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistPage(
                            playlistId: playlist['ytid'],
                            playlistData: playlistData,
                          ),
                        ),
                      );
                    }
                  : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: playlist['image'] != null
                ? CachedNetworkImage(
                    key: Key(playlist['image'].toString()),
                    height: size,
                    width: size,
                    imageUrl: playlist['image'].toString(),
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => NullArtworkWidget(
                      icon: cubeIcon,
                      iconSize: 30,
                      size: size,
                      title: playlist['title'],
                    ),
                  )
                : NullArtworkWidget(
                    icon: cubeIcon,
                    iconSize: 30,
                    size: size,
                    title: playlist['title'],
                  ),
          ),
        ),
        if (playlist['ytid'] != null && showFavoriteButton)
          ValueListenableBuilder<bool>(
            valueListenable: playlistLikeStatus,
            builder: (_, value, __) {
              return Positioned(
                bottom: 5,
                right: 5,
                child: LikeButton(
                  onPrimaryColor: _onPrimaryColor,
                  onSecondaryColor: _secondaryColor,
                  isLiked: value,
                  onPressed: () {
                    playlistLikeStatus.value = !playlistLikeStatus.value;
                    updatePlaylistLikeStatus(
                      playlist,
                      playlistLikeStatus.value,
                    );
                    currentLikedPlaylistsLength.value = value
                        ? currentLikedPlaylistsLength.value + 1
                        : currentLikedPlaylistsLength.value - 1;
                  },
                ),
              );
            },
          ),
        if (isAlbum ?? false)
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                color: _secondaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(4),
              child: Text(
                context.l10n!.album,
                style: TextStyle(
                  color: _onPrimaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
