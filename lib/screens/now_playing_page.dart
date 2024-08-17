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

import 'package:audio_service/audio_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:Shreeya/API/Shreeya.dart';
import 'package:Shreeya/extensions/l10n.dart';
import 'package:Shreeya/main.dart';
import 'package:Shreeya/models/position_data.dart';
import 'package:Shreeya/services/settings_manager.dart';

import 'package:Shreeya/utilities/formatter.dart';
import 'package:Shreeya/utilities/mediaitem.dart';
import 'package:Shreeya/widgets/marque.dart';
import 'package:Shreeya/widgets/playback_icon_button.dart';
import 'package:Shreeya/widgets/song_artwork.dart';
import 'package:Shreeya/widgets/song_bar.dart';
import 'package:Shreeya/widgets/spinner.dart';
import 'package:Shreeya/widgets/squiggly_slider.dart';

final _lyricsController = FlipCardController();

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          if (snapshot.data == null || !snapshot.hasData) {
            return const SizedBox.shrink();
          } else {
            final metadata = snapshot.data!;
            final screenHeight = size.height;

            return Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                buildArtwork(context, size, metadata),
                SizedBox(height: screenHeight * 0.01),
                if (!(metadata.extras?['isLive'] ?? false))
                  _buildPlayer(
                    context,
                    size,
                    metadata.extras?['ytid'],
                    metadata,
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildArtwork(BuildContext context, Size size, MediaItem metadata) {
    const _padding = 70;
    const _radius = 17.0;
    final screen = (size.width + size.height) / 3.05;
    final imageSize = screen - _padding;

    return FlipCard(
      rotateSide: RotateSide.right,
      onTapFlipping: !offlineMode.value,
      controller: _lyricsController,
      frontWidget: SongArtworkWidget(
        metadata: metadata,
        size: imageSize,
        errorWidgetIconSize: size.width / 8,
        borderRadius: _radius,
      ),
      backWidget: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: ValueListenableBuilder<String?>(
          valueListenable: lyrics,
          builder: (_, value, __) {
            if (lastFetchedLyrics != '${metadata.artist} - ${metadata.title}') {
              getSongLyrics(
                metadata.artist ?? '',
                metadata.title,
              );
            }
            if (value != null && value != 'not found') {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (value == null) {
              return const Spinner();
            } else {
              return Center(
                child: Text(
                  context.l10n!.lyricsNotAvailable,
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildMarqueeText(
      String text,
      Color fontColor,
      double fontSize,
      FontWeight fontWeight,
      ) {
    return MarqueeWidget(
      backDuration: const Duration(seconds: 1),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
    );
  }

  Widget _buildPlayer(
      BuildContext context,
      Size size,
      dynamic audioId,
      MediaItem mediaItem,
      ) {
    const iconSize = 20.0;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildMarqueeText(
                  mediaItem.title,
                  Theme.of(context).colorScheme.primary,
                  screenHeight * 0.028,
                  FontWeight.w600,
                ),
                SizedBox(height: screenHeight * 0.005),
                if (mediaItem.artist != null)
                  buildMarqueeText(
                    mediaItem.artist!,
                    Theme.of(context).colorScheme.secondary,
                    screenHeight * 0.017,
                    FontWeight.w500,
                  ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          buildPositionSlider(),
          buildPlayerControls(context, size, mediaItem, iconSize),
          SizedBox(height: size.height * 0.055),
          buildBottomActions(context, audioId, mediaItem, iconSize),
        ],
      ),
    );
  }

  Widget buildPositionSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: StreamBuilder<PositionData>(
        stream: audioHandler.positionDataStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final positionData = snapshot.data!;
          final primaryColor = Theme.of(context).colorScheme.primary;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSlider(
                positionData,
              ),
              buildPositionRow(
                primaryColor,
                positionData,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSlider(
      PositionData positionData,
      ) {
    return SquigglySlider(
      value: positionData.position.inSeconds.toDouble(),
      onChanged: (value) {
        audioHandler.seek(Duration(seconds: value.toInt()));
      },
      max: positionData.duration.inSeconds.toDouble(),
      squiggleSpeed: 0,
    );
  }

  Widget buildPositionRow(Color fontColor, PositionData positionData) {
    final positionText = formatDuration(positionData.position.inSeconds);
    final durationText = formatDuration(positionData.duration.inSeconds);
    final textStyle = TextStyle(fontSize: 15, color: fontColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(positionText, style: textStyle),
          Text(durationText, style: textStyle),
        ],
      ),
    );
  }

  Widget buildPlayerControls(
      BuildContext context,
      Size size,
      MediaItem mediaItem,
      double iconSize,
      ) {
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _secondaryColor = Theme.of(context).colorScheme.secondaryContainer;

    final screen = ((size.width + size.height) / 4) - 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: shuffleNotifier,
            builder: (_, value, __) {
              return value
                  ? IconButton.filled(
                icon: const Icon(
                  Icons.shuffle_rounded,
                ),
                iconSize: 30,
                onPressed: () {
                  audioHandler.setShuffleMode(
                    AudioServiceShuffleMode.none,
                  );
                },
              )
                  : IconButton(
                icon: Icon(
                  Icons.shuffle_rounded,
                  color: _primaryColor,
                ),
                iconSize: 30,
                onPressed: () {
                  audioHandler.setShuffleMode(
                    AudioServiceShuffleMode.all,
                  );
                },
              );
            },
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  FluentIcons.previous_24_filled,
                  color: audioHandler.hasPrevious
                      ? _primaryColor
                      : _secondaryColor,
                ),
                iconSize: 30,
                onPressed: () => audioHandler.skipToPrevious(),
                splashColor: Colors.transparent,
              ),
              const SizedBox(width: 5),
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  return buildPlaybackIconButton(
                    snapshot.data,
                    screen * 0.15,
                    _primaryColor,
                    _secondaryColor,
                    elevation: 0,
                    padding: EdgeInsets.all(screen * 0.08),
                  );
                },
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: Icon(
                  FluentIcons.next_24_filled,
                  color: audioHandler.hasNext ? _primaryColor : _secondaryColor,
                ),
                iconSize: 30,
                onPressed: () => audioHandler.skipToNext(),
                splashColor: Colors.transparent,
              ),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: repeatNotifier,
            builder: (_, value, __) {
              return value
                  ? IconButton(
                icon: Icon(
                  Icons.repeat_one_rounded,
                  color: _primaryColor,
                ),
                iconSize: 30,
                onPressed: () {
                  audioHandler.setRepeatMode(
                    AudioServiceRepeatMode.none,
                  );
                },
              )
                  : IconButton(
                icon: Icon(
                  Icons.repeat_rounded,
                  color: _primaryColor,
                ),
                iconSize: 30,
                onPressed: () {
                  audioHandler.setRepeatMode(
                    AudioServiceRepeatMode.all,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
  Widget buildBottomActions(
      BuildContext context,
      dynamic audioId,
      MediaItem mediaItem,
      double iconSize,
      ) {
    final songLikeStatus = ValueNotifier<bool>(isSongAlreadyLiked(audioId));
    late final songOfflineStatus =
    ValueNotifier<bool>(isSongAlreadyOffline(audioId));

    final _primaryColor = Theme.of(context).colorScheme.primary;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 78,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: songOfflineStatus,
          builder: (_, value, __) {
            return IconButton(
              icon: Icon(
                value
                    ? Icons.download_done_rounded
                    : Icons.download_rounded,
                color: _primaryColor,
              ),
              iconSize: 30,
              onPressed: () {
                if (value) {
                  removeSongFromOffline(audioId);
                } else {
                  makeSongOffline(mediaItemToMap(mediaItem));
                }

                songOfflineStatus.value = !songOfflineStatus.value;
              },
            );
          },
        ),
        if (!offlineMode.value)
          IconButton(
            icon: Icon(
              Icons.playlist_add_rounded,
              color: _primaryColor,
            ),
            iconSize: 30,
            onPressed: () {
              showAddToPlaylistDialog(context, mediaItemToMap(mediaItem));
            },
          ),

        if (!offlineMode.value)
          ValueListenableBuilder<bool>(
            valueListenable: songLikeStatus,
            builder: (_, value, __) {
              return IconButton(
                icon: Icon(
                  value
                      ? FluentIcons.heart_24_filled
                      : FluentIcons.heart_24_regular,
                  color: _primaryColor,
                ),
                iconSize: 30,
                onPressed: () {
                  updateSongLikeStatus(audioId, !songLikeStatus.value);
                  songLikeStatus.value = !songLikeStatus.value;
                },
              );
            },
          ),
      ],
    );
  }
}
