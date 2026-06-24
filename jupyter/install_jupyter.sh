#!/usr/bin/env bash
# =============================================================================
# Jupyter Notebook 독립 설치 스크립트
# 대상 환경 : macOS / Python 3.13.13
# 설치 위치 : 이 스크립트가 있는 폴더
# Python    : python.org 공식 PKG로 직접 설치
# 라이선스  : 설치 패키지 전체 BSD / MIT / PSF (무료, 상업적 이용 가능)
# =============================================================================

set -e

# ── 색상 ──────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

STEP=0
TOTAL=5

step() {
    STEP=$((STEP + 1))
    echo ""
    echo -e "${CYAN}${BOLD}[$STEP/$TOTAL] $1${RESET}"
}
ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
fail() { echo -e "  ${RED}✗ 오류: $1${RESET}"; exit 1; }

# ── 경로 설정 ─────────────────────────────────────────────────────────────────
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$BASE_DIR/.venv"
NOTEBOOKS_DIR="$BASE_DIR/notebooks"
TARGET_PYTHON_VER="3.13.13"
PYTHON_MINOR="3.13"
PYTHON_FRAMEWORK="/Library/Frameworks/Python.framework/Versions/$PYTHON_MINOR/bin/python$PYTHON_MINOR"
PKG_URL="https://www.python.org/ftp/python/$TARGET_PYTHON_VER/python-$TARGET_PYTHON_VER-macos11.pkg"
PKG_FILE="/tmp/python-$TARGET_PYTHON_VER.pkg"

echo ""
echo -e "${BOLD}================================================${RESET}"
echo -e "${BOLD}  Jupyter Notebook 설치 스크립트${RESET}"
echo -e "${BOLD}  설치 경로: $BASE_DIR${RESET}"
echo -e "${BOLD}  Python 버전: $TARGET_PYTHON_VER${RESET}"
echo -e "${BOLD}================================================${RESET}"

# ─────────────────────────────────────────────────────────────────────────────
step "환경 확인"
# ─────────────────────────────────────────────────────────────────────────────

if [[ "$(uname)" != "Darwin" ]]; then
    fail "macOS 환경에서만 실행 가능합니다. (현재: $(uname))"
fi
ok "macOS 확인"

if ! command -v curl &>/dev/null; then
    fail "curl이 필요합니다. macOS 기본 내장 도구입니다."
fi
ok "curl 확인"

# ─────────────────────────────────────────────────────────────────────────────
step "Python $TARGET_PYTHON_VER 설치"
# ─────────────────────────────────────────────────────────────────────────────

PYTHON=""

# 이미 동일 버전 설치되어 있는지 확인
if [[ -x "$PYTHON_FRAMEWORK" ]]; then
    INSTALLED_VER=$("$PYTHON_FRAMEWORK" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
    if [[ "$INSTALLED_VER" == "$TARGET_PYTHON_VER" ]]; then
        ok "Python $TARGET_PYTHON_VER 이미 설치됨 ($PYTHON_FRAMEWORK)"
        PYTHON="$PYTHON_FRAMEWORK"
    else
        warn "Python $INSTALLED_VER 설치됨 — $TARGET_PYTHON_VER 로 업데이트합니다."
    fi
fi

# 설치 필요한 경우 python.org에서 PKG 다운로드 후 설치
if [[ -z "$PYTHON" ]]; then
    echo "  python.org 에서 PKG 다운로드 중..."
    echo "  URL: $PKG_URL"
    curl -L "$PKG_URL" -o "$PKG_FILE" --progress-bar 2>&1 \
        || fail "다운로드 실패. 네트워크 연결을 확인하세요."
    ok "다운로드 완료: $PKG_FILE"

    echo "  설치 중... (sudo 권한이 필요합니다)"
    sudo installer -pkg "$PKG_FILE" -target / \
        || fail "설치 실패. 권한을 확인하세요."
    rm -f "$PKG_FILE"

    PYTHON="$PYTHON_FRAMEWORK"
    ok "Python $TARGET_PYTHON_VER 설치 완료"
fi

PYTHON_VER=$("$PYTHON" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
ok "Python $PYTHON_VER 준비 완료 ($PYTHON)"

# ─────────────────────────────────────────────────────────────────────────────
step "가상환경 생성"
# ─────────────────────────────────────────────────────────────────────────────

if [[ -d "$VENV_DIR" ]]; then
    VENV_VER=$("$VENV_DIR/bin/python" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
    if [[ "$VENV_VER" != "$PYTHON_VER" ]]; then
        warn "가상환경($VENV_VER)과 현재 Python($PYTHON_VER) 버전이 다릅니다."
        warn "버전을 맞추려면 '.venv' 폴더를 삭제 후 재실행하세요: rm -rf $VENV_DIR"
    else
        warn "이미 가상환경이 존재합니다. 재사용합니다: $VENV_DIR"
    fi
else
    "$PYTHON" -m venv "$VENV_DIR"
    ok "가상환경 생성: $VENV_DIR"
fi

PIP="$VENV_DIR/bin/pip"
PYTHON_VENV="$VENV_DIR/bin/python"

"$PIP" install --upgrade pip --quiet
ok "pip 최신화 완료"

# ─────────────────────────────────────────────────────────────────────────────
step "패키지 설치"
# ─────────────────────────────────────────────────────────────────────────────

# notebook    BSD 3-Clause  (Jupyter 노트북 서버)
# ipykernel   BSD 3-Clause  (Python 커널)
# pandas      BSD 3-Clause  (데이터 처리)
# matplotlib  PSF / BSD     (시각화)

install_pkg() {
    local pkg="$1"
    local desc="$2"
    echo -n "  설치 중: $pkg  "
    "$PIP" install "$pkg" --quiet
    local VER
    VER=$("$PIP" show "$pkg" 2>/dev/null | grep "^Version" | awk '{print $2}')
    echo -e "${GREEN}완료 v$VER${RESET}  — $desc"
}

install_pkg "notebook"   "Jupyter 노트북 서버 (BSD 3-Clause)"
install_pkg "ipykernel"  "Python 커널 (BSD 3-Clause)"
install_pkg "pandas"     "데이터 처리 (BSD 3-Clause)"
install_pkg "matplotlib" "시각화 (PSF/BSD)"

# ─────────────────────────────────────────────────────────────────────────────
step "Jupyter 커널 등록 및 노트북 폴더 생성"
# ─────────────────────────────────────────────────────────────────────────────

KERNEL_NAME="jupyter-local"
KERNEL_DISPLAY="Jupyter Local (Python $PYTHON_VER)"

"$PYTHON_VENV" -m ipykernel install \
    --user \
    --name "$KERNEL_NAME" \
    --display-name "$KERNEL_DISPLAY" \
    2>/dev/null
ok "커널 등록: $KERNEL_DISPLAY"

mkdir -p "$NOTEBOOKS_DIR"
ok "노트북 폴더: $NOTEBOOKS_DIR"

SAMPLE="$NOTEBOOKS_DIR/시작하기.ipynb"
if [[ ! -f "$SAMPLE" ]]; then
cat > "$SAMPLE" << 'NOTEBOOK'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": ["# 시작하기\n\n이 노트북은 Jupyter 환경이 정상적으로 설치되었는지 확인하는 샘플입니다."]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import sys\n",
    "print(f'Python 버전: {sys.version}')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "\n",
    "df = pd.DataFrame({'항목': ['A', 'B', 'C'], '값': [10, 25, 15]})\n",
    "df.plot(kind='bar', x='항목', y='값', legend=False)\n",
    "plt.title('샘플 차트')\n",
    "plt.tight_layout()\n",
    "plt.show()\n",
    "df"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Jupyter Local (Python 3.13.13)",
   "language": "python",
   "name": "jupyter-local"
  },
  "language_info": {"name": "python", "version": "3.13.13"}
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
NOTEBOOK
    ok "샘플 노트북 생성: $SAMPLE"
else
    warn "샘플 노트북이 이미 존재합니다. 덮어쓰지 않습니다."
fi

# ─────────────────────────────────────────────────────────────────────────────
# GUIDE.md 자동 생성
# ─────────────────────────────────────────────────────────────────────────────

GUIDE="$BASE_DIR/GUIDE.md"
NB_VER=$("$PIP" show notebook    2>/dev/null | grep "^Version" | awk '{print $2}')
IK_VER=$("$PIP" show ipykernel   2>/dev/null | grep "^Version" | awk '{print $2}')
PD_VER=$("$PIP" show pandas      2>/dev/null | grep "^Version" | awk '{print $2}')
MP_VER=$("$PIP" show matplotlib  2>/dev/null | grep "^Version" | awk '{print $2}')

cat > "$GUIDE" << GUIDE_EOF
# Jupyter 사용 가이드

> 이 파일은 \`bash install_jupyter.sh\` 실행 시 자동 생성됩니다.

## 환경 정보

| 항목 | 내용 |
|---|---|
| Python | $PYTHON_VER |
| Python 경로 | $PYTHON_FRAMEWORK |
| 설치 경로 | $BASE_DIR |
| 가상환경 | $VENV_DIR |
| 노트북 저장 위치 | $NOTEBOOKS_DIR |
| Jupyter 실행 파일 | $VENV_DIR/bin/jupyter |

## 설치된 패키지

| 패키지 | 버전 | 라이선스 |
|---|---|---|
| notebook | $NB_VER | BSD 3-Clause |
| ipykernel | $IK_VER | BSD 3-Clause |
| pandas | $PD_VER | BSD 3-Clause |
| matplotlib | $MP_VER | PSF/BSD |

## 실행

\`\`\`bash
# 방법 1: 전체 경로로 실행 (어느 위치에서든 가능)
$VENV_DIR/bin/jupyter notebook --notebook-dir="$NOTEBOOKS_DIR"

# 방법 2: 설치 폴더로 이동 후 실행
cd $BASE_DIR
.venv/bin/jupyter notebook --notebook-dir=notebooks
\`\`\`

브라우저가 자동으로 열립니다. 안 열리면 직접 접속:
\`\`\`
http://localhost:8888
\`\`\`

서버 종료: 터미널에서 \`Ctrl+C\`

### 백그라운드 실행 (터미널을 닫아도 유지)

\`\`\`bash
nohup $VENV_DIR/bin/jupyter notebook --notebook-dir="$NOTEBOOKS_DIR" > $BASE_DIR/jupyter.log 2>&1 &

# 토큰 확인
cat $BASE_DIR/jupyter.log
\`\`\`

### 백그라운드 서버 종료

\`\`\`bash
lsof -ti :8888 | xargs kill
\`\`\`

## 노트북 사용법

1. 브라우저에서 \`http://localhost:8888\` 접속
2. \`notebooks/\` 폴더에서 기존 파일 열기 또는 \`New\` 버튼으로 새 노트북 생성
3. 커널 선택: \`Kernel > Change Kernel > Jupyter Local (Python $PYTHON_VER)\`
4. 셀에 코드 입력 후 \`Shift + Enter\` 로 실행

## 접속 인증

### 방법 1: 토큰 (기본값)

서버 실행 시 터미널에 아래와 같이 출력됩니다. 해당 URL을 브라우저에 붙여넣으면 바로 접속됩니다.

\`\`\`
http://localhost:8888/?token=abc123def456...
\`\`\`

### 방법 2: 비밀번호 설정

Jupyter Notebook v7부터 내부 엔진이 \`jupyter-server\`로 변경되었습니다.
반드시 아래 명령어를 사용해야 합니다. (\`jupyter notebook password\` 는 동작하지 않습니다)

\`\`\`bash
$VENV_DIR/bin/jupyter server password
\`\`\`

실행 후 비밀번호를 두 번 입력하면 설정 완료됩니다.
비밀번호는 \`~/.jupyter/jupyter_server_config.json\` 에 저장됩니다.

### 비밀번호 초기화 (비밀번호를 잊어버린 경우)

\`\`\`bash
rm -f ~/.jupyter/jupyter_server_config.json
$VENV_DIR/bin/jupyter server password
\`\`\`

## 재설치 / Python 버전 변경

가상환경만 초기화합니다. 설치된 Python은 유지됩니다.

\`\`\`bash
rm -rf $VENV_DIR
bash $BASE_DIR/install_jupyter.sh
\`\`\`

Python 버전을 바꾸려면 스크립트 내 \`TARGET_PYTHON_VER\` 값을 수정 후 실행합니다.

\`\`\`bash
# install_jupyter.sh 에서 아래 줄 수정
TARGET_PYTHON_VER="3.13.13"  # 원하는 버전으로 변경
\`\`\`
GUIDE_EOF

ok "GUIDE.md 생성: $GUIDE"

# ─────────────────────────────────────────────────────────────────────────────
# 완료 요약
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}================================================${RESET}"
echo -e "${GREEN}${BOLD}  설치 완료${RESET}"
echo -e "${GREEN}${BOLD}================================================${RESET}"
echo ""
echo -e "  자세한 사용법은 ${BOLD}GUIDE.md${RESET} 를 확인하세요."
echo "  $GUIDE"
echo ""
echo -e "${BOLD}[ 빠른 실행 ]${RESET}"
echo "  cd $BASE_DIR"
echo "  .venv/bin/jupyter notebook --notebook-dir=notebooks"
echo ""
