#!/bin/bash
#================================================================
# Docker Desktop 설치 스크립트 (macOS Apple Silicon)
#================================================================

set -e

echo "================================================"
echo "  Docker Desktop 설치 스크립트"
echo "  macOS Apple Silicon (arm64)"
echo "================================================"
echo ""

# 1. 이미 설치되어 있는지 확인
if command -v docker &> /dev/null; then
    echo "✅ Docker가 이미 설치되어 있습니다!"
    docker --version
    echo ""
    echo "Docker Desktop이 실행 중인지 확인 중..."
    if docker info &> /dev/null; then
        echo "✅ Docker Desktop이 실행 중입니다."
    else
        echo "⚠️  Docker Desktop을 실행해 주세요."
        echo "   Applications 폴더에서 Docker.app을 실행하세요."
    fi
    exit 0
fi

# 2. 아키텍처 확인
ARCH=$(uname -m)
echo "🔍 시스템 아키텍처: $ARCH"

if [ "$ARCH" = "arm64" ]; then
    DOCKER_DMG_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
    echo "   → Apple Silicon (arm64) 버전을 다운로드합니다."
elif [ "$ARCH" = "x86_64" ]; then
    DOCKER_DMG_URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
    echo "   → Intel (amd64) 버전을 다운로드합니다."
else
    echo "❌ 지원하지 않는 아키텍처입니다: $ARCH"
    exit 1
fi
echo ""

# 3. Docker Desktop DMG 다운로드
DOWNLOAD_PATH="/tmp/Docker.dmg"
echo "📥 Docker Desktop 다운로드 중..."
echo "   URL: $DOCKER_DMG_URL"
echo "   저장 위치: $DOWNLOAD_PATH"
echo ""

curl -L -o "$DOWNLOAD_PATH" "$DOCKER_DMG_URL" --progress-bar

if [ ! -f "$DOWNLOAD_PATH" ]; then
    echo "❌ 다운로드 실패!"
    exit 1
fi

FILE_SIZE=$(ls -lh "$DOWNLOAD_PATH" | awk '{print $5}')
echo "✅ 다운로드 완료! (파일 크기: $FILE_SIZE)"
echo ""

# 4. DMG 마운트
echo "📦 DMG 마운트 중..."
hdiutil attach "$DOWNLOAD_PATH" -quiet
echo "✅ DMG 마운트 완료"
echo ""

# 5. Docker.app 복사
echo "📁 Docker.app을 Applications 폴더로 복사 중..."
cp -R "/Volumes/Docker/Docker.app" "/Applications/"
echo "✅ 복사 완료"
echo ""

# 6. DMG 언마운트
echo "🔧 DMG 언마운트 중..."
hdiutil detach "/Volumes/Docker" -quiet
echo "✅ 언마운트 완료"
echo ""

# 7. 다운로드 파일 정리
rm -f "$DOWNLOAD_PATH"
echo "🗑️  임시 파일 정리 완료"
echo ""

# 8. Docker Desktop 실행
echo "🚀 Docker Desktop 실행 중..."
open /Applications/Docker.app
echo ""

echo "================================================"
echo "  ✅ Docker Desktop 설치 완료!"
echo "================================================"
echo ""
echo "⏳ Docker Desktop이 초기화되는 동안 잠시 기다려주세요."
echo "   (처음 실행 시 1~2분 소요될 수 있습니다)"
echo ""
echo "   초기화 완료 후 터미널에서 확인:"
echo "   $ docker --version"
echo "   $ docker run hello-world"
echo ""
