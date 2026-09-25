# 실행 검증

2026-09-25 로컬 복사본 기준. 전체 캠페인 검증 결과가 아닙니다.

## 확인됨

- Godot 4.3 웹 내보내기 성공. 로컬 HTTP 서버에서 로딩, 역사 오프닝, 1장 전투, 결과 화면, 다음 챕터 선택까지 확인.
- `python3 tools/build_site.py` 완료. 배포 대상 HTML의 로컬 파일 경로 점검에서 누락 없음.

- 깨끗한 Git worktree checkout에서 `python3 tools/build_site.py`가 성공하고 `dist/index.html`이 생성됨.

## 아직 확인 필요

- 2장 이후 전투, 브라우저 재시작 후 저장 상태, 모바일 조작은 아직 확인하지 못함.
- GitHub Pages 공개 주소에서의 재실행은 배포 후 확인해야 합니다.
