export interface User {
  id: string;
  email: string;
  created_at: string;
}

export interface PDFDocument {
  id: string;
  user_id: string;
  filename: string;
  file_path: string;
  file_size: number;
  upload_date: string;
  processed: boolean;
  chunk_count?: number;
}

export interface ChatSession {
  id: string;
  user_id: string;
  title: string;
  created_at: string;
  updated_at: string;
}

export interface ChatMessage {
  id: string;
  session_id: string;
  role: 'user' | 'assistant';
  content: string;
  created_at: string;
}

export interface DocumentChunk {
  id: string;
  document_id: string;
  content: string;
  chunk_index: number;
  embedding?: number[];
}

export interface GraphEntity {
  id: string;
  document_id: string;
  entity_type: string;
  entity_name: string;
  description?: string;
  created_at: string;
}

export interface GraphRelationship {
  id: string;
  document_id: string;
  source_entity_id: string;
  target_entity_id: string;
  relationship_type: string;
  description?: string;
  created_at: string;
}

export interface ResumeFeedback {
  id: string;
  user_id: string;
  filename: string;
  file_path: string;
  job_description?: string;
  ats_score: number;
  feedback: string;
  keywords_found: string[];
  keywords_missing: string[];
  created_at: string;
}

export interface ResearchTask {
  id: string;
  user_id: string;
  query: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  report?: string;
  created_at: string;
  completed_at?: string;
}

export interface SQLQuery {
  id: string;
  user_id: string;
  natural_language_query: string;
  generated_sql: string;
  executed: boolean;
  results?: any;
  error?: string;
  created_at: string;
}
