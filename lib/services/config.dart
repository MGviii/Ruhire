class AppConfig {
  final bool useMocks;
  final String apiBaseUrl;
  final String websocketUrl;

  const AppConfig({required this.useMocks, required this.apiBaseUrl, required this.websocketUrl});
}

const kDefaultConfig = AppConfig(
  useMocks: true,
  apiBaseUrl: 'https://api.example.com',
  websocketUrl: 'wss://ws.example.com/realtime',
);
