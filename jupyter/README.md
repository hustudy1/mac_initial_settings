# Jupyter Notebook 설치 스크립트

macOS에서 Jupyter Notebook 환경을 한 번에 설치하는 독립 실행형 스크립트입니다.
Python 설치부터 패키지 구성까지 자동으로 처리합니다.

## 요구사항

- macOS
- curl (macOS 기본 내장)
- sudo 권한 (Python 설치 시 필요)

Python 3.13.13은 스크립트 실행 시 **python.org 공식 PKG를 직접 다운로드하여 설치**합니다.

## 설치

이 `jupyter/` 폴더 안에서 실행합니다. `.venv`, `notebooks/`, `GUIDE.md` 등 모든 산출물이 이 폴더 안에 생성됩니다.

```bash
cd jupyter
bash install_jupyter.sh
```

설치가 완료되면 실행 경로와 사용 방법이 담긴 `GUIDE.md` 파일이 자동으로 생성됩니다.

## 사용 (설치 후)

`jupyter/` 폴더로 이동해 실행합니다. 자세한 내용은 생성된 `GUIDE.md`를 참고하세요.

```bash
cd jupyter
.venv/bin/jupyter notebook --notebook-dir=notebooks
```

- 브라우저가 자동으로 열립니다. 안 열리면 `http://localhost:8888` 직접 접속
- 서버 종료: 터미널에서 `Ctrl + C`
- `GUIDE.md`에 백그라운드 실행, 비밀번호 설정 등 상세 사용법이 정리되어 있습니다.

## 설치 단계

| 단계 | 내용 |
|---|---|
| [1/5] 환경 확인 | macOS, curl 설치 여부 확인 |
| [2/5] Python 설치 | python.org에서 PKG 다운로드 → sudo로 설치 |
| [3/5] 가상환경 생성 | Python 3.13.13 기반 `.venv` 생성 |
| [4/5] 패키지 설치 | notebook, ipykernel, pandas, matplotlib |
| [5/5] 커널 등록 및 폴더 생성 | Jupyter 커널 등록, `notebooks/` 폴더 및 샘플 생성 |

> Python 설치 시 sudo 비밀번호 입력이 필요합니다.

## 설치 패키지 및 라이선스

| 패키지 | 라이선스 | 용도 |
|---|---|---|
| Python 3.13.13 | PSF | python.org 공식 배포 |
| notebook | BSD 3-Clause | Jupyter 노트북 서버 |
| ipykernel | BSD 3-Clause | Python 커널 |
| pandas | BSD 3-Clause | 데이터 처리 |
| matplotlib | PSF/BSD | 시각화 |

전체 무료, 상업적 이용 가능.

## 재설치 / Python 버전 변경

가상환경만 초기화합니다. 설치된 Python은 유지됩니다.

```bash
rm -rf .venv
bash install_jupyter.sh
```

Python 버전을 바꾸려면 스크립트 내 `TARGET_PYTHON_VER` 값을 수정 후 실행합니다.
