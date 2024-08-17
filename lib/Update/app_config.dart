AppConfig appConfig = AppConfig(version: 26, codeName: '1.0.8');

class AppConfig {
  AppConfig({required this.version, required this.codeName});
  int version;
  String codeName;
  Uri updateUri = Uri.parse(
      'https://api.github.com/repos/shrayeshbhai/mymusic/releases/latest',);
}
