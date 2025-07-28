# XHS Flutter API

Flutter API interface for xiaohongshu (小红书) web scraping SDK. This project provides a RESTful API server built with Flutter that wraps the Python XHS SDK functionality.

## Features

- 🔍 **Search Notes**: Search xiaohongshu notes by keywords with various filters
- 👤 **User Information**: Retrieve user profiles and their published notes
- 📱 **Note Details**: Get detailed information about specific notes including comments
- 🏠 **Home Feed**: Access different category feeds (fashion, food, cosmetics, etc.)
- 🔄 **Real-time Data**: Direct integration with xiaohongshu through the Python SDK
- 🌐 **RESTful API**: Clean, well-structured API endpoints
- 📊 **JSON Responses**: Structured JSON responses with proper error handling

## Architecture

```
Flutter API Server
       ↓
Python XHS SDK
       ↓
Xiaohongshu Website
```

## Prerequisites

- Flutter SDK (>= 3.0.0)
- Python 3.7+
- XHS Python SDK (included in parent directory)
- Playwright (for browser automation)

## Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd flutter
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Install Python dependencies** (if not already installed):
   ```bash
   cd ..
   pip install -r requirements.txt
   pip install playwright
   playwright install chromium
   ```

4. **Generate JSON serialization code**:
   ```bash
   flutter packages pub run build_runner build
   ```

## Configuration

Before using the API, you need to configure it with your xiaohongshu cookie:

```bash
curl -X POST http://localhost:8080/api/config \
  -H "Content-Type: application/json" \
  -d '{
    "cookie": "your_xiaohongshu_cookie_here",
    "python_api_url": "http://localhost:5005"
  }'
```

## Usage

### Start the Server

```bash
flutter run --release
```

The server will start on `http://localhost:8080` by default.

### API Endpoints

#### Health Check
```
GET /health
```

#### Configuration
```
POST /api/config          # Set cookie and configuration
GET  /api/config          # Get current configuration status
```

#### Notes
```
GET /api/notes/{noteId}                    # Get note by ID
GET /api/notes/search?keyword={keyword}    # Search notes
GET /api/notes/{noteId}/comments           # Get note comments
```

#### Users
```
GET /api/users/{userId}                    # Get user information
GET /api/users/{userId}/notes              # Get user's notes
GET /api/users/search?keyword={keyword}    # Search users
```

#### Feeds
```
GET /api/feed/{feedType}                   # Get home feed by type
```

### Example Requests

#### Search Notes
```bash
curl "http://localhost:8080/api/notes/search?keyword=美食&page=1&page_size=10&sort=latest&note_type=all"
```

#### Get Note Details
```bash
curl "http://localhost:8080/api/notes/64f8a1b2000000001f001234?xsec_token=your_token"
```

#### Get User Information
```bash
curl "http://localhost:8080/api/users/64f8a1b2000000001f001234"
```

#### Get Home Feed
```bash
curl "http://localhost:8080/api/feed/food"
```

### Response Format

All API responses follow this structure:

```json
{
  "success": true,
  "data": { ... },
  "message": null,
  "code": null
}
```

Error responses:

```json
{
  "success": false,
  "data": null,
  "message": "Error description",
  "code": 500
}
```

## Available Feed Types

- `recommend` - 推荐
- `fashion` - 穿搭
- `food` - 美食
- `cosmetics` - 彩妆
- `movie` - 影视
- `career` - 职场
- `emotion` - 情感
- `house` - 家居
- `game` - 游戏
- `travel` - 旅行
- `fitness` - 健身

## Search Parameters

### Notes Search
- `keyword` (required): Search keyword
- `page`: Page number (default: 1)
- `page_size`: Items per page (default: 20)
- `sort`: Sort type (`general`, `most_popular`, `latest`)
- `note_type`: Note type (`all`, `video`, `image`)

### Users Search
- `keyword` (required): Search keyword
- `page`: Page number (default: 1)
- `page_size`: Items per page (default: 20)

## Data Models

### XhsNote
```dart
{
  "noteId": "string",
  "title": "string",
  "desc": "string",
  "type": "normal|video",
  "user": XhsUser,
  "imgUrls": ["string"],
  "videoUrl": "string?",
  "tagList": ["string"],
  "atUserList": ["string"],
  "collectedCount": "string",
  "commentCount": "string",
  "likedCount": "string",
  "shareCount": "string",
  "time": number,
  "lastUpdateTime": number
}
```

### XhsUser
```dart
{
  "userId": "string",
  "nickname": "string",
  "avatar": "string",
  "desc": "string?",
  "followCount": number?,
  "fansCount": number?,
  "noteCount": number?,
  "isFollowed": boolean?
}
```

### XhsComment
```dart
{
  "commentId": "string",
  "content": "string",
  "user": XhsUser,
  "createTime": number,
  "likedCount": number,
  "subComments": [XhsComment]?
}
```

## Environment Variables

- `PORT`: Server port (default: 8080)
- `PYTHON_PATH`: Path to Python executable (default: python3)
- `XHS_MODULE_PATH`: Path to XHS module (default: ../)

## Development

### Project Structure

```
flutter/
├── lib/
│   ├── main.dart                    # Server entry point
│   └── src/
│       ├── models/
│       │   └── xhs_models.dart      # Data models
│       ├── services/
│       │   ├── xhs_service.dart     # XHS service layer
│       │   └── python_bridge.dart   # Python integration
│       ├── routes/
│       │   └── api_routes.dart      # API route handlers
│       └── middleware/
│           ├── error_middleware.dart    # Error handling
│           └── logging_middleware.dart  # Request logging
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

### Building and Running

Development mode:
```bash
flutter run
```

Production build:
```bash
flutter build <target>
```

### Testing

```bash
flutter test
```

## Notes

- This API requires valid xiaohongshu cookies to function
- Rate limiting may apply based on xiaohongshu's policies
- Some endpoints require additional tokens (xsec_token) for security
- The Python XHS SDK handles signature generation and request signing

## License

This project follows the same license as the parent XHS SDK project.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Support

For issues related to:
- Flutter API: Open an issue in this repository
- XHS SDK: Refer to the parent project documentation
- Xiaohongshu changes: Check for SDK updates