-- =============================================================================
-- Migration 001: Create Core Tables
-- Plataforma de Estudos Jurídicos
-- =============================================================================

-- TOPICS: armazena o tópico geral (ex: "Direito Constitucional - Artigo 5º")
CREATE TABLE IF NOT EXISTS topics (
  topic_id   TEXT PRIMARY KEY,
  title      TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE topics IS 'Tópicos principais de estudo jurídico';

-- SECTIONS: cada seção de conteúdo, ligada a um tópico via FK
-- Usa JSONB para callouts, mnemonics e flashcards evitando explosão de tabelas
CREATE TABLE IF NOT EXISTS sections (
  section_id       TEXT PRIMARY KEY,
  topic_id         TEXT NOT NULL REFERENCES topics(topic_id) ON DELETE CASCADE,
  title            TEXT NOT NULL,
  content_markdown TEXT,
  callouts         JSONB NOT NULL DEFAULT '[]'::jsonb,
  mnemonics        JSONB NOT NULL DEFAULT '[]'::jsonb,
  flashcards       JSONB NOT NULL DEFAULT '[]'::jsonb,
  mermaid_mindmap  TEXT,
  sort_order       INT NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE sections IS 'Seções de conteúdo didático dentro de um tópico';

-- USER_PROGRESS: checkbox de conclusão de leitura por seção
CREATE TABLE IF NOT EXISTS user_progress (
  user_id    UUID NOT NULL,
  section_id TEXT NOT NULL REFERENCES sections(section_id) ON DELETE CASCADE,
  completed  BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, section_id)
);

COMMENT ON TABLE user_progress IS 'Rastreamento de progresso de leitura por aluno';

-- USER_NOTES: anotações estilo Google Keep, 1 por seção por usuário
CREATE TABLE IF NOT EXISTS user_notes (
  user_id    UUID NOT NULL,
  section_id TEXT NOT NULL REFERENCES sections(section_id) ON DELETE CASCADE,
  content    TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, section_id)
);

COMMENT ON TABLE user_notes IS 'Anotações pessoais do aluno por seção';

-- =============================================================================
-- Índices para queries frequentes
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_sections_topic_id    ON sections(topic_id);
CREATE INDEX IF NOT EXISTS idx_sections_sort_order  ON sections(topic_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_progress_user_id     ON user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_user_id        ON user_notes(user_id);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_user_progress_updated_at
  BEFORE UPDATE ON user_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER trigger_user_notes_updated_at
  BEFORE UPDATE ON user_notes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
