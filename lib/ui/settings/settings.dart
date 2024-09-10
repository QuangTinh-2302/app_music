import 'package:app_music/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingTab();
  }
}
class _SettingTab extends StatefulWidget {
  const _SettingTab({super.key});

  @override
  State<_SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<_SettingTab> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true ,
      ),
      body: Consumer<UiProvider>(
        builder: (context, UiProvider notifier,child) {
          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Chế độ tối'),
                trailing: Switch(
                    value: notifier.isDark,
                    onChanged: (value) => notifier.changeTheme()
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
