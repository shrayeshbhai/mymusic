

import 'dart:io';

import 'package:Shreeya/Update/adaptive_widgets.dart';
import 'package:Shreeya/Update/check_update.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Update {
  static Future showCenterLoadingModal(BuildContext context, {String? title}) {
    if (Platform.isWindows) {
      return fluent_ui.showDialog(
        context: context,
        builder: (context) {
          return const fluent_ui.ContentDialog(
            title: Text('Checking Update..'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [fluent_ui.ProgressRing()],
            ),
          );
        },
      );
    }
    return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return const AlertDialog(
          title: Text('Checking Update..'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          ),
        );
      },
    );
  }

  static Future showUpdateDialog(BuildContext context,
      UpdateInfo? updateInfo,) =>
      showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return _updateDialog(context, updateInfo);
        },
      );
}
fluent_ui.SizedBox _updateDialog(BuildContext context, UpdateInfo? updateInfo) {
  final f = DateFormat('MMM dd yyyy, h:mm a');

  return SizedBox(
    height: MediaQuery
        .of(context)
        .size
        .height,
    width: MediaQuery
        .of(context)
        .size
        .width,
    child: LayoutBuilder(builder: (context, constraints) {
      if (Platform.isWindows) {
        return fluent_ui.ContentDialog(
          title: Column(
            children: [
              Center(
                  child: Text(
                      updateInfo != null
                          ? 'Update Available'
                          : 'Update Info',),),
              if (updateInfo != null)
                Text(
                  style: const TextStyle(fontSize: 15),
                  '${updateInfo.name}\n${f.format(
                      DateTime.parse(updateInfo.publishedAt),)}',

                ),
            ],
          ),
          content: updateInfo != null
              ? SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight - 400,
            child: Markdown(
              data: updateInfo.body,
              shrinkWrap: true,
              softLineBreak: true,
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(
                    Uri.parse(href),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
          )
              : const Text('You are already up to date.'),
          actions: [
            if (updateInfo != null)
              AdaptiveButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            AdaptiveFilledButton(
              onPressed: () {
                Navigator.pop(context);
                if (updateInfo != null) {
                  launchUrl(Uri.parse(updateInfo.downloadUrl),
                      mode: LaunchMode.externalApplication,);
                }
              },
              child: Text(updateInfo != null ? 'Update' : 'Done'),
            ),
          ],
        );
      }
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(20)),),
        scrollable: true,
        icon: Center(
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),),
            child: const Icon(
              Icons.update,
              size: 0,
            ),
          ),
        ),

        title: Column(
          children: [
            Text(updateInfo != null ? 'Update Available' : 'Update Info'),
            if (updateInfo != null)
              Text(
                style: const TextStyle( fontSize: 15),
                '${updateInfo.name}\n${f.format(

                    DateTime.parse(updateInfo.publishedAt),)}',

              ),
          ],
        ),
        content: updateInfo != null
            ? SizedBox(
          width: 200,
          height: 150,
          child: Markdown(
            data: updateInfo.body,
            shrinkWrap: true,
            softLineBreak: true,
            onTapLink: (text, href, title) {
              if (href != null) {
                launchUrl(Uri.parse(href));
              }
            },
          ),
        )
            : const Center(
          child: Text('You are already up to date.'),
        ),
        actions: [
          if (updateInfo != null)
            AdaptiveButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          AdaptiveFilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (updateInfo != null) {
                launchUrl(Uri.parse(updateInfo.downloadUrl),
                    mode: LaunchMode.externalApplication,);
              }
            },
            color: Colors.deepOrange,
            child: Text(updateInfo != null ? 'Update' : 'Done'),
          ),
        ],
      );
    },),
  );
}