# Quick Setup Guide

## Prerequisites

1. **Flutter SDK** (>= 3.0.0)
   ```bash
   # Install Flutter: https://flutter.dev/docs/get-started/install
   flutter --version
   ```

2. **Python 3.7+** with required packages
   ```bash
   # Install Python dependencies
   pip install requests lxml playwright
   playwright install chromium
   ```

3. **XHS Python SDK** (should be in parent directory)
   ```bash
   # Verify XHS SDK is available
   cd ..
   python3 -c "import xhs; print('XHS SDK is ready')"
   ```

## Quick Start

1. **Clone and setup**
   ```bash
   cd flutter
   flutter pub get
   ```

2. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env and add your XHS cookie
   ```

4. **Start the server**
   ```bash
   ./scripts/start.sh
   ```

5. **Test the API**
   ```bash
   # Basic health check
   curl http://localhost:8080/health
   
   # Configure with your cookie
   curl -X POST http://localhost:8080/api/config \
     -H "Content-Type: application/json" \
     -d '{"cookie": "your_cookie_here"}'
   
   # Run comprehensive tests
   ./scripts/test-api.sh
   ```

## Docker Deployment

```bash
# Build and run with Docker
cd docker
docker-compose up --build

# Or run individual container
docker build -t xhs-flutter-api .
docker run -p 8080:8080 xhs-flutter-api
```

## Getting XHS Cookie

1. Open xiaohongshu.com in your browser
2. Login to your account
3. Open Developer Tools (F12)
4. Go to Application/Storage tab
5. Find Cookies for xiaohongshu.com
6. Copy the entire cookie string

## Common Issues

- **Python import errors**: Ensure XHS SDK is in the correct path
- **Playwright errors**: Run `playwright install chromium`
- **Port conflicts**: Change PORT in .env file
- **Permission errors**: Make sure scripts are executable (`chmod +x scripts/*.sh`)

## API Usage Examples

```bash
# Search notes
curl "http://localhost:8080/api/notes/search?keyword=美食&page=1&page_size=10"

# Get user info
curl "http://localhost:8080/api/users/USER_ID_HERE"

# Get home feed
curl "http://localhost:8080/api/feed/food"
```

For detailed API documentation, see [README.md](README.md).