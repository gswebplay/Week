-- ============================================================
-- 프로젝트/작업단계 기능을 위한 Supabase 마이그레이션
-- SQL Editor에서 이 파일 내용을 그대로 실행하세요.
-- ============================================================

-- 1) work_logs 테이블에 "작업단계"(예: 모델링작업, 도면작업) 칸 추가
ALTER TABLE work_logs ADD COLUMN IF NOT EXISTS stage text;

-- 2) 부서별로 "프로젝트 목록"과 "프로젝트별 작업단계 목록"을 저장해두는 테이블
--    재고관리 앱의 "강관→규격" 관리 방식과 동일한 구조입니다.
--    data 칸 예시: {"projects":["GS-W805","GS-806"], "stages":{"GS-W805":["모델링작업","도면작업","매뉴얼작업"]}}
CREATE TABLE IF NOT EXISTS project_options (
  department text PRIMARY KEY,
  data jsonb NOT NULL DEFAULT '{"projects":[],"stages":{}}'::jsonb,
  updated_at timestamptz DEFAULT now()
);

-- 3) 다른 테이블들과 동일하게, 이 테이블도 "누구나 읽기/쓰기 가능"하도록 RLS를 열어둡니다.
--    (이미 RLS를 비활성화해서 쓰고 계신 경우엔 이 부분은 필요 없을 수 있습니다 - 기존 테이블 설정과 맞춰주세요)
ALTER TABLE project_options ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "누구나 읽기/쓰기 가능" ON project_options;
CREATE POLICY "누구나 읽기/쓰기 가능" ON project_options FOR ALL USING (true) WITH CHECK (true);
