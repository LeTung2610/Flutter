class ImageUploadConfig {
  // 1. Proxy server URL (Nếu bạn dùng Web và gặp lỗi CORS)
  static const String proxyUrl = "https://your-proxy-url.com/upload"; 

  // 2. API Key mới của bạn
  static const String imgbbApiKey = "62cb5047f16f2c9e14958574e061a9cd"; 

  // ImgBB API endpoint
  static const String imgbbApiUrl = "https://api.imgbb.com/1/upload";

  static bool get isProxyConfigured => 
      proxyUrl.trim().isNotEmpty && !proxyUrl.contains("your-proxy-url");

  // Đã sửa hàm này: Chỉ cần Key không trống là hợp lệ
  static bool get isConfigured => imgbbApiKey.trim().isNotEmpty;
}