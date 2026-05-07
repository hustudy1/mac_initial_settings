#!/bin/bash
#================================================================
# iTerm2 설치 스크립트 (macOS)
#================================================================

set -e

echo "================================================"
echo "  iTerm2 설치 스크립트"
echo "================================================"
echo ""

# 1. 이미 설치되어 있는지 확인
if [ -d "/Applications/iTerm.app" ]; then
    echo "✅ iTerm2가 이미 설치되어 있습니다!"
    exit 0
fi

# 2. 다운로드
DOWNLOAD_PATH="/tmp/iTerm2.zip"
ITERM_URL="https://iterm2.com/downloads/stable/latest"

echo "📥 iTerm2 다운로드 중..."
curl -L -o "$DOWNLOAD_PATH" "$ITERM_URL" --progress-bar

if [ ! -f "$DOWNLOAD_PATH" ]; then
    echo "❌ 다운로드 실패!"
    exit 1
fi

FILE_SIZE=$(ls -lh "$DOWNLOAD_PATH" | awk '{print $5}')
echo "✅ 다운로드 완료! (파일 크기: $FILE_SIZE)"
echo ""

# 3. 압축 해제
echo "📦 압축 해제 중..."
unzip -o -q "$DOWNLOAD_PATH" -d /tmp/iTerm2_extracted
echo "✅ 압축 해제 완료"
echo ""

# 4. Applications 폴더로 복사
echo "📁 iTerm.app을 Applications 폴더로 복사 중..."
cp -R /tmp/iTerm2_extracted/iTerm.app /Applications/
echo "✅ 복사 완료"
echo ""

# 5. 임시 파일 정리
rm -f "$DOWNLOAD_PATH"
rm -rf /tmp/iTerm2_extracted
echo "🗑️  임시 파일 정리 완료"
echo ""

# 6. iTerm2 실행
echo "🚀 iTerm2 실행 중..."
open /Applications/iTerm.app
echo ""

echo "================================================"
echo "  ✅ iTerm2 설치 완료!"
echo "================================================"
echo ""
