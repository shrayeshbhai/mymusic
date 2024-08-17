import 'package:Shreeya/Update/app_config.dart';
import 'package:Shreeya/Update/check_update.dart';
import 'package:Shreeya/Update/color_icon.dart';
import 'package:Shreeya/Update/icons.dart';
import 'package:Shreeya/Update/listtile.dart';
import 'package:Shreeya/Update/scaffold.dart';
import 'package:Shreeya/Update/text_styles.dart';
import 'package:Shreeya/Update/update.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    const Wrap(
                      alignment: WrapAlignment.center,
                    ),
                    const SizedBox(height: 16),
                    AdaptiveListTile(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      leading: const ColorIcon(icon: Icons.other_houses, color: Colors.redAccent),
                      title: Text(
                        'Shreeya Music',
                        style: textStyle(context, bold: false)
                            .copyWith(fontSize: 16),
                      ),
                      trailing: const Text(
                        'Music',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AdaptiveListTile(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      leading: const ColorIcon(
                          color: Colors.blueAccent, icon: Icons.new_releases,),
                      title: const Text(
                        'Version',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      trailing: Text(
                        appConfig.codeName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),

                      ),
                    ),
                    AdaptiveListTile(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      leading: const ColorIcon(
                          color: Colors.greenAccent, icon: CupertinoIcons.person,),
                      title: const Text(
                        'Developer',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),


                      trailing: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                        'Bhupendra Dahal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                          const SizedBox(width: 8),
                          Icon(AdaptiveIcons.chevron_right)
                        ,],
                      ),
                      onTap: () => launchUrl(
                          Uri.parse('https://github.com/shrayesh1234'),
                          mode: LaunchMode.externalApplication,),
                    ),


                    AdaptiveListTile(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      leading: const ColorIcon(color: Colors.deepOrangeAccent, icon: Icons.code),
                      title: const Text(
                        'Source Code',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      trailing: Icon(AdaptiveIcons.chevron_right),
                      onTap: () => launchUrl(
                          Uri.parse('https://github.com/Dahalshrayesh/shrayesh'),
                          mode: LaunchMode.externalApplication,),
                    ),
                    AdaptiveListTile(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      leading:
                      const ColorIcon(color: Colors.cyan, icon: Icons.bug_report),
                      title: const Text(
                        'Bug Report',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      trailing: Icon(AdaptiveIcons.chevron_right),
                      onTap: () => launchUrl(
                          Uri.parse(
                              'https://github.com/Dahalshrayesh/shrayesh/issues/new?assignees=&labels=bug&projects=&template=bug_report.yaml',),
                          mode: LaunchMode.externalApplication,),
                    ),
                    AdaptiveListTile(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      leading: const ColorIcon(
                          color: Colors.deepOrangeAccent, icon: Icons.request_page,),
                      title: const Text(
                        'Feature Request',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      trailing: Icon(AdaptiveIcons.chevron_right),
                      onTap: () => launchUrl(
                          Uri.parse(
                              'https://github.com/Dahalshrayesh/shrayesh/issues/new?assignees=sheikhhaziq&labels=enhancement%2CFeature+Request&projects=&template=feature_request.yaml',),
                          mode: LaunchMode.externalApplication,),
                    ),
                    AdaptiveListTile(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        leading: const ColorIcon(
                            color: Colors.green, icon: Icons.update_outlined,),
                        title: const Text(
                          'Software Update',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        trailing: Icon(AdaptiveIcons.chevron_right),
                        onTap: () {
                          Update.showCenterLoadingModal(context);
                          checkUpdate().then((updateInfo) {
                            Navigator.pop(context);
                            Update.showUpdateDialog(context, updateInfo);
                          },
                          );
                        }

                    ,),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
