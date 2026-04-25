const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");

const imgbbApiKey = defineSecret("IMGBB_API_KEY");

exports.uploadImageToImgBB = onRequest(
  {
    cors: true,
    region: "us-central1",
    secrets: [imgbbApiKey],
  },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        return res.status(405).json({ error: "Method not allowed" });
      }

      const imageBase64 = req.body?.imageBase64;
      if (!imageBase64 || typeof imageBase64 !== "string") {
        return res.status(400).json({ error: "Missing imageBase64" });
      }

      const apiKey = imgbbApiKey.value();
      if (!apiKey) {
        return res.status(500).json({ error: "Server missing IMGBB_API_KEY" });
      }

      const formBody = new URLSearchParams({ image: imageBase64 }).toString();
      const upstream = await fetch(`https://api.imgbb.com/1/upload?key=${apiKey}`, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: formBody,
      });

      const body = await upstream.json();
      if (!upstream.ok || body?.success !== true) {
        return res.status(502).json({
          error: body?.error?.message || `ImgBB error HTTP ${upstream.status}`,
          raw: body,
        });
      }

      const url = body?.data?.url;
      if (!url) {
        return res.status(502).json({ error: "ImgBB response missing url" });
      }

      return res.status(200).json({ url });
    } catch (error) {
      return res.status(500).json({
        error: error?.message || "Internal server error",
      });
    }
  }
);
