class ImageUploadConfig {
  // Get FREE API key at https://api.imgbb.com/ (1 minute to register)
  // Paste your key here:
  static const String imgbbApiKey = "85db63e3d8241ff2ee56590e06d04435";

  static bool get isConfigured =>
      imgbbApiKey.isNotEmpty && imgbbApiKey != "YOUR_IMGBB_API_KEY";
}
