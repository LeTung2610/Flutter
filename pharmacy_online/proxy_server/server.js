require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;
const IMGBB_API_KEY = process.env.IMGBB_API_KEY || '';

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'ImgBB Proxy Server is running' });
});

// Image upload endpoint
app.post('/upload', async (req, res) => {
  try {
    const { imageBase64 } = req.body;

    // Validate input
    if (!imageBase64 || typeof imageBase64 !== 'string') {
      return res.status(400).json({
        success: false,
        error: 'Missing or invalid imageBase64',
      });
    }

    // Check API key
    if (!IMGBB_API_KEY) {
      return res.status(500).json({
        success: false,
        error: 'Server missing IMGBB_API_KEY environment variable',
      });
    }

    // Upload to ImgBB
    const response = await axios.post(
      `https://api.imgbb.com/1/upload?key=${IMGBB_API_KEY}`,
      {
        image: imageBase64,
      },
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        timeout: 30000,
      }
    );

    // Check ImgBB response
    if (response.data.success !== true) {
      return res.status(400).json({
        success: false,
        error: response.data.error?.message || 'ImgBB upload failed',
      });
    }

    const imageUrl = response.data.data?.url;
    if (!imageUrl) {
      return res.status(400).json({
        success: false,
        error: 'ImgBB response missing image URL',
      });
    }

    // Return success
    return res.json({
      success: true,
      url: imageUrl,
    });
  } catch (error) {
    console.error('Upload error:', error.message);
    return res.status(500).json({
      success: false,
      error: error.message || 'Internal server error',
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`ImgBB Proxy Server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Upload endpoint: POST http://localhost:${PORT}/upload`);
});
