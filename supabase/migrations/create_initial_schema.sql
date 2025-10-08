/*
  # GenAI Platform - Initial Database Schema

  ## Overview
  This migration creates the complete database schema for the GenAI Platform, including tables for
  PDF document management, chat functionality, GraphRAG entity extraction, resume feedback,
  research tasks, and SQL query history.

  ## New Tables

  ### 1. pdf_documents
  Stores uploaded PDF documents with metadata
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `filename` (text)
  - `file_path` (text) - Storage path in Supabase storage
  - `file_size` (bigint) - File size in bytes
  - `upload_date` (timestamptz)
  - `processed` (boolean) - Whether document has been processed
  - `chunk_count` (integer) - Number of chunks extracted

  ### 2. chat_sessions
  Manages chat sessions for PDF conversations
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `title` (text) - Auto-generated or user-defined title
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 3. chat_messages
  Stores individual messages in chat sessions
  - `id` (uuid, primary key)
  - `session_id` (uuid, references chat_sessions)
  - `role` (text) - Either 'user' or 'assistant'
  - `content` (text) - Message content
  - `created_at` (timestamptz)

  ### 4. document_chunks
  Stores chunked text from PDFs for RAG
  - `id` (uuid, primary key)
  - `document_id` (uuid, references pdf_documents)
  - `content` (text) - Chunk text content
  - `chunk_index` (integer) - Position in document
  - `embedding` (vector) - Vector embedding for semantic search
  - `created_at` (timestamptz)

  ### 5. graph_entities
  Stores extracted entities from GraphRAG processing
  - `id` (uuid, primary key)
  - `document_id` (uuid, references pdf_documents)
  - `entity_type` (text) - Type of entity (Person, Organization, Concept, etc.)
  - `entity_name` (text) - Name of the entity
  - `description` (text) - Entity description
  - `created_at` (timestamptz)

  ### 6. graph_relationships
  Stores relationships between entities
  - `id` (uuid, primary key)
  - `document_id` (uuid, references pdf_documents)
  - `source_entity_id` (uuid, references graph_entities)
  - `target_entity_id` (uuid, references graph_entities)
  - `relationship_type` (text) - Type of relationship
  - `description` (text) - Relationship description
  - `created_at` (timestamptz)

  ### 7. resume_feedback
  Stores resume analysis results
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `filename` (text)
  - `file_path` (text) - Storage path
  - `job_description` (text, nullable)
  - `ats_score` (integer) - ATS compatibility score (0-100)
  - `feedback` (jsonb) - Detailed feedback as JSON
  - `keywords_found` (text[]) - Array of found keywords
  - `keywords_missing` (text[]) - Array of missing keywords
  - `created_at` (timestamptz)

  ### 8. research_tasks
  Manages autonomous research tasks
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `query` (text) - Research query
  - `status` (text) - pending, processing, completed, failed
  - `report` (text, nullable) - Generated research report
  - `created_at` (timestamptz)
  - `completed_at` (timestamptz, nullable)

  ### 9. sql_queries
  Stores text-to-SQL query history
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `natural_language_query` (text) - Original natural language query
  - `generated_sql` (text) - Generated SQL query
  - `executed` (boolean) - Whether query was executed
  - `results` (jsonb, nullable) - Query results
  - `error` (text, nullable) - Error message if failed
  - `created_at` (timestamptz)

  ## Security
  - Enable Row Level Security on all tables
  - Create policies for authenticated users to manage their own data
  - Users can only access their own documents, chats, feedback, and queries
  - Read-only access to shared resources where applicable

  ## Indexes
  - Add indexes on foreign keys for better query performance
  - Add indexes on frequently queried columns (user_id, created_at, status)
*/

-- Create pdf_documents table
CREATE TABLE IF NOT EXISTS pdf_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  filename text NOT NULL,
  file_path text NOT NULL,
  file_size bigint NOT NULL,
  upload_date timestamptz DEFAULT now() NOT NULL,
  processed boolean DEFAULT false NOT NULL,
  chunk_count integer DEFAULT 0
);

-- Create chat_sessions table
CREATE TABLE IF NOT EXISTS chat_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL DEFAULT 'New Chat',
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid REFERENCES chat_sessions(id) ON DELETE CASCADE NOT NULL,
  role text NOT NULL CHECK (role IN ('user', 'assistant')),
  content text NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create document_chunks table
CREATE TABLE IF NOT EXISTS document_chunks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid REFERENCES pdf_documents(id) ON DELETE CASCADE NOT NULL,
  content text NOT NULL,
  chunk_index integer NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create graph_entities table
CREATE TABLE IF NOT EXISTS graph_entities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid REFERENCES pdf_documents(id) ON DELETE CASCADE NOT NULL,
  entity_type text NOT NULL,
  entity_name text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create graph_relationships table
CREATE TABLE IF NOT EXISTS graph_relationships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid REFERENCES pdf_documents(id) ON DELETE CASCADE NOT NULL,
  source_entity_id uuid REFERENCES graph_entities(id) ON DELETE CASCADE NOT NULL,
  target_entity_id uuid REFERENCES graph_entities(id) ON DELETE CASCADE NOT NULL,
  relationship_type text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create resume_feedback table
CREATE TABLE IF NOT EXISTS resume_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  filename text NOT NULL,
  file_path text NOT NULL,
  job_description text,
  ats_score integer NOT NULL CHECK (ats_score >= 0 AND ats_score <= 100),
  feedback jsonb NOT NULL DEFAULT '{}',
  keywords_found text[] DEFAULT '{}',
  keywords_missing text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create research_tasks table
CREATE TABLE IF NOT EXISTS research_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  query text NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  report text,
  created_at timestamptz DEFAULT now() NOT NULL,
  completed_at timestamptz
);

-- Create sql_queries table
CREATE TABLE IF NOT EXISTS sql_queries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  natural_language_query text NOT NULL,
  generated_sql text NOT NULL,
  executed boolean DEFAULT false NOT NULL,
  results jsonb,
  error text,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Enable Row Level Security on all tables
ALTER TABLE pdf_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_chunks ENABLE ROW LEVEL SECURITY;
ALTER TABLE graph_entities ENABLE ROW LEVEL SECURITY;
ALTER TABLE graph_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE resume_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE research_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE sql_queries ENABLE ROW LEVEL SECURITY;

-- RLS Policies for pdf_documents
CREATE POLICY "Users can view own PDF documents"
  ON pdf_documents FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own PDF documents"
  ON pdf_documents FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own PDF documents"
  ON pdf_documents FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own PDF documents"
  ON pdf_documents FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- RLS Policies for chat_sessions
CREATE POLICY "Users can view own chat sessions"
  ON chat_sessions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat sessions"
  ON chat_sessions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own chat sessions"
  ON chat_sessions FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat sessions"
  ON chat_sessions FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- RLS Policies for chat_messages
CREATE POLICY "Users can view messages in own sessions"
  ON chat_messages FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM chat_sessions
      WHERE chat_sessions.id = chat_messages.session_id
      AND chat_sessions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert messages in own sessions"
  ON chat_messages FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM chat_sessions
      WHERE chat_sessions.id = chat_messages.session_id
      AND chat_sessions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete messages in own sessions"
  ON chat_messages FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM chat_sessions
      WHERE chat_sessions.id = chat_messages.session_id
      AND chat_sessions.user_id = auth.uid()
    )
  );

-- RLS Policies for document_chunks
CREATE POLICY "Users can view chunks of own documents"
  ON document_chunks FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM pdf_documents
      WHERE pdf_documents.id = document_chunks.document_id
      AND pdf_documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert chunks for own documents"
  ON document_chunks FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM pdf_documents
      WHERE pdf_documents.id = document_chunks.document_id
      AND pdf_documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete chunks of own documents"
  ON document_chunks FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM pdf_documents
      WHERE pdf_documents.id = document_chunks.document_id
      AND pdf_documents.user_id = auth.uid()
    )
  );

-- RLS Policies for graph_entities
CREATE POLICY "Users can view entities from own documents"
  ON graph_entities FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM pdf_documents
      WHERE pdf_documents.id = graph_entities.document_id
      AND pdf_documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert entities for own documents"
  ON graph_entities FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM pdf_documents
      WHERE pdf_documents.id = graph_entities.document_id
      AND pdf_documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete entities from own documents"
  ON graph_entities FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM pdf_documents
      WHERE pdf_documents.id = graph_entities.document_id
      AND pdf_documents.user_id = auth.uid()
    )
  );

-- RLS Policies for graph_relationships
CREATE POLICY "Users can view relationships from own documents"
  ON graph_relationships FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM pdf_documents
      WHERE pdf_documents.id = graph_relationships.document_id
      AND pdf_documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert relationships for own documents"
  ON graph_relationships FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM pdf_documents
      WHERE pdf_documents.id = graph_relationships.document_id
      AND pdf_documents.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete relationships from own documents"
  ON graph_relationships FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM pdf_documents
      WHERE pdf_documents.id = graph_relationships.document_id
      AND pdf_documents.user_id = auth.uid()
    )
  );

-- RLS Policies for resume_feedback
CREATE POLICY "Users can view own resume feedback"
  ON resume_feedback FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own resume feedback"
  ON resume_feedback FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own resume feedback"
  ON resume_feedback FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- RLS Policies for research_tasks
CREATE POLICY "Users can view own research tasks"
  ON research_tasks FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own research tasks"
  ON research_tasks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own research tasks"
  ON research_tasks FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own research tasks"
  ON research_tasks FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- RLS Policies for sql_queries
CREATE POLICY "Users can view own SQL queries"
  ON sql_queries FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own SQL queries"
  ON sql_queries FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own SQL queries"
  ON sql_queries FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_pdf_documents_user_id ON pdf_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_pdf_documents_upload_date ON pdf_documents(upload_date DESC);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_user_id ON chat_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_updated_at ON chat_sessions(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_document_chunks_document_id ON document_chunks(document_id);
CREATE INDEX IF NOT EXISTS idx_graph_entities_document_id ON graph_entities(document_id);
CREATE INDEX IF NOT EXISTS idx_graph_relationships_document_id ON graph_relationships(document_id);
CREATE INDEX IF NOT EXISTS idx_resume_feedback_user_id ON resume_feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_resume_feedback_created_at ON resume_feedback(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_research_tasks_user_id ON research_tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_research_tasks_status ON research_tasks(status);
CREATE INDEX IF NOT EXISTS idx_research_tasks_created_at ON research_tasks(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sql_queries_user_id ON sql_queries(user_id);
CREATE INDEX IF NOT EXISTS idx_sql_queries_created_at ON sql_queries(created_at DESC);
