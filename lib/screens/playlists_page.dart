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

import 'package:flutter/material.dart';
import 'package:Shreeya/API/Shreeya.dart';
import 'package:Shreeya/extensions/l10n.dart';
import 'package:Shreeya/main.dart';
import 'package:Shreeya/widgets/custom_search_bar.dart';
import 'package:Shreeya/widgets/playlist_cube.dart';
import 'package:Shreeya/widgets/spinner.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final TextEditingController _searchBar = TextEditingController();
  final FocusNode _inputNode = FocusNode();
  bool _showOnlyAlbums = false;

  void toggleShowOnlyAlbums(bool value) {
    setState(() {
      _showOnlyAlbums = value;
    });
  }

  @override
  void dispose() {
    _searchBar.dispose();
    _inputNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n!.playlists),
      ),
      body: Column(
        children: <Widget>[
          CustomSearchBar(
            onSubmitted: (String value) {
              setState(() {});
            },
            controller: _searchBar,
            focusNode: _inputNode,
            labelText: '${context.l10n!.search}...',
          ),
          Expanded(
            child: FutureBuilder(
              future: getPlaylists(
                query: _searchBar.text.isEmpty ? null : _searchBar.text,
                type: _showOnlyAlbums ? 'album' : 'playlist',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Spinner();
                } else if (snapshot.hasError) {
                  logger.log(
                    'Error on playlists page',
                    snapshot.error,
                    snapshot.stackTrace,
                  );
                  return Center(
                    child: Text(context.l10n!.error),
                  );
                }

                final _playlists = snapshot.data as List;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _playlists.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (BuildContext context, index) {
                    final playlist = _playlists[index];

                    return PlaylistCube(
                      playlist,
                      isAlbum: playlist['isAlbum'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
