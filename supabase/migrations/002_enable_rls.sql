-- =============================================================================
-- Migration 002: Enable Row Level Security (RLS)
-- =============================================================================

-- Ativar RLS em todas as tabelas
ALTER TABLE topics        ENABLE ROW LEVEL SECURITY;
ALTER TABLE sections      ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_notes    ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- TOPICS & SECTIONS: Leitura pública (qualquer autenticado pode ler conteúdo)
-- =============================================================================
CREATE POLICY "topics_select_authenticated"
  ON topics FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "sections_select_authenticated"
  ON sections FOR SELECT
  TO authenticated
  USING (true);

-- Admin pode inserir/atualizar/deletar conteúdo via service_role key
-- (não precisa de policy pois service_role bypassa RLS)

-- =============================================================================
-- USER_PROGRESS: Cada aluno vê e modifica apenas seu próprio progresso
-- =============================================================================
CREATE POLICY "progress_select_own"
  ON user_progress FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "progress_insert_own"
  ON user_progress FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "progress_update_own"
  ON user_progress FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "progress_delete_own"
  ON user_progress FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- =============================================================================
-- USER_NOTES: Cada aluno vê e modifica apenas suas próprias anotações
-- =============================================================================
CREATE POLICY "notes_select_own"
  ON user_notes FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "notes_insert_own"
  ON user_notes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "notes_update_own"
  ON user_notes FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "notes_delete_own"
  ON user_notes FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
