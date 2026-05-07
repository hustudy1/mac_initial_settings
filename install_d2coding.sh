#!/bin/bash
#================================================================
# D2Coding 폰트 설치 스크립트 (macOS)
#================================================================

set -e

echo "================================================"
echo "  D2Coding 폰트 설치 스크립트"
echo "================================================"
echo ""

# 1. 이미 설치되어 있는지 확인
if fc-list 2>/dev/null | grep -i "D2Coding" > /dev/null 2>&1; then
    echo "✅ D2Coding 폰트가 이미 설치되어 있습니다!"
    exit 0
fi

if ls ~/Library/Fonts/D2Coding* > /dev/null 2>&1 || ls /Library/Fonts/D2Coding* > /dev/null 2>&1; then
    echo "✅ D2Coding 폰트가 이미 설치되어 있습니다!"
    exit 0
fi

# 2. 다운로드
DOWNLOAD_PATH="/tmp/D2Coding.zip"
D2CODING_URL="https://github.com/naver/d2codingfont/releases/download/VER1.3.2/D2Coding-Ver1.3.2-20180524.zip"

echo "📥 D2Coding 폰트 다운로드 중..."
curl -L -o "$DOWNLOAD_PATH" "$D2CODING_URL" --progress-bar

if [ ! -f "$DOWNLOAD_PATH" ]; then
    echo "❌ 다운로드 실패!"
    exit 1
fi

echo "✅ 다운로드 완료!"
echo ""

# 3. 압축 해제
echo "📦 압축 해제 중..."
EXTRACT_DIR="/tmp/D2Coding_extracted"
rm -rf "$EXTRACT_DIR"
unzip -o -q "$DOWNLOAD_PATH" -d "$EXTRACT_DIR"
echo "✅ 압축 해제 완료"
echo ""

# 4. 폰트 설치 (사용자 폰트 폴더로 복사)
echo "📁 폰트 설치 중..."
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"

# ttf 또는 otf 파일 찾아서 복사
FONT_COUNT=0
find "$EXTRACT_DIR" -name "*.ttf" -o -name "*.otf" | while read font_file; do
    cp "$font_file" "$FONT_DIR/"
    echo "   ✅ $(basename "$font_file") 설치됨"
done

echo ""
echo "✅ D2Coding 폰트 설치 완료!"
echo ""

# 5. 임시 파일 정리
rm -f "$DOWNLOAD_PATH"
rm -rf "$EXTRACT_DIR"
echo "🗑️  임시 파일 정리 완료"
echo ""

echo "================================================"
echo "  ✅ D2Coding 폰트 설치 완료!"
echo "================================================"
echo ""
echo "  iTerm2에서 폰트 적용 방법:"
echo "  1. iTerm2 실행"
echo "  2. 메뉴: iTerm2 → Settings (⌘,)"
echo "  3. Profiles → Text 탭"
echo "  4. Font에서 'D2Coding' 선택"
echo "  5. 추천 크기: 14pt"
echo ""
