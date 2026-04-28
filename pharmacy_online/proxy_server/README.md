# ImgBB Proxy Server

Simple backend proxy server để upload ảnh lên ImgBB API, giải quyết vấn đề CORS trên Web.

## Setup Cục Bộ

### 1. Cài đặt dependencies
```bash
npm install
```

### 2. Tạo file .env
```bash
cp .env.example .env
```

Rồi điền ImgBB API key:
```
IMGBB_API_KEY=your_api_key_here
```

### 3. Chạy server
```bash
npm start
```

Server sẽ chạy trên http://localhost:3000

### 4. Test upload
```bash
curl -X POST http://localhost:3000/upload \
  -H "Content-Type: application/json" \
  -d '{"imageBase64":"data:image/png;base64,iVBORw0KGgo..."}'
```

---

## Deploy lên Replit (Miễn phí)

### 1. Tạo project trên Replit
- Vào https://replit.com
- Click "Create" → "Import from GitHub" hoặc "Create Repl"
- Chọn template: Node.js

### 2. Upload files
- Tạo `package.json` với nội dung ở trên
- Tạo `server.js` với nội dung ở trên
- Tạo `.env` với ImgBB API key

### 3. Chạy
- Replit sẽ auto-run hoặc click "Run"
- URL proxy sẽ như: `https://your-project.replit.dev`

### 4. Update Flutter config
Vào `lib/config/image_upload_config.dart`:
```dart
static const String uploadProxyUrl = "https://your-project.replit.dev/upload";
```

---

## Deploy lên Render (Miễn phí)

### 1. Push code lên GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git push origin main
```

### 2. Tạo New Web Service trên Render
- Vào https://render.com
- Click "New" → "Web Service"
- Connect GitHub repo
- Build command: `npm install`
- Start command: `npm start`
- Add environment variable: `IMGBB_API_KEY=your_key`

### 3. Deploy
- Render sẽ auto-deploy
- URL proxy sẽ như: `https://your-project.onrender.com`

### 4. Update Flutter config
```dart
static const String uploadProxyUrl = "https://your-project.onrender.com/upload";
```

---

## API Endpoint

### POST /upload
Upload ảnh qua base64

**Request:**
```json
{
  "imageBase64": "base64_string_here"
}
```

**Response (Success):**
```json
{
  "success": true,
  "url": "https://i.ibb.co/..."
}
```

**Response (Error):**
```json
{
  "success": false,
  "error": "Error message here"
}
```

---

## Notes

- Proxy này cần `IMGBB_API_KEY` để hoạt động
- API key nên được giữ bí mật (dùng environment variable)
- Server có timeout 30 giây cho mỗi upload
- Max size ảnh: 32MB (ImgBB limit)
