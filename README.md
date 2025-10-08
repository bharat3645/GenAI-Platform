# GenAI Platform

A comprehensive AI-powered platform for document processing, research, and data analysis featuring advanced RAG technology, GraphRAG, ATS resume analysis, autonomous research agents, and natural language to SQL conversion.

## Features

### 1. Multi-PDF Chat with GraphRAG
- Upload multiple PDF documents simultaneously
- Intelligent chat interface powered by RAG technology
- Entity extraction and knowledge graph construction
- Context-aware responses using document relationships
- Document chunking and vector embeddings for semantic search

### 2. GraphRAG
- Advanced entity and relationship extraction from documents
- Knowledge graph visualization
- Enhanced query understanding through entity relationships
- Interactive exploration of document connections

### 3. Resume Feedback with ATS Analysis
- AI-powered resume analysis
- ATS compatibility scoring (0-100)
- Multi-agent evaluation system
- Keyword analysis and recommendations
- Job description matching
- Formatting and content quality feedback

### 4. Research Assistant
- Autonomous AI research agent
- Multi-source information gathering
- Comprehensive research report generation
- Task tracking and history
- Structured output with citations

### 5. Text to SQL
- Natural language to SQL query conversion
- Database schema visualization
- Query execution and results display
- Query history tracking
- Export results to CSV or JSON

## Tech Stack

- **Frontend**: React 18 with TypeScript
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Build Tool**: Vite

## Getting Started

### Prerequisites

- Node.js 16 or higher
- npm or yarn
- Supabase account

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables in `.env`:
   ```
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. Apply database migrations:
   - Navigate to your Supabase dashboard
   - Go to SQL Editor
   - Run the migration file in `supabase/migrations/create_initial_schema.sql`

5. Start the development server:
   ```bash
   npm run dev
   ```

### Building for Production

```bash
npm run build
```

The build output will be in the `dist` directory.

## Database Schema

The platform uses the following main tables:

- `pdf_documents` - Stores uploaded PDF documents
- `chat_sessions` - Manages chat conversations
- `chat_messages` - Stores individual messages
- `document_chunks` - Chunked text for RAG
- `graph_entities` - Extracted entities from documents
- `graph_relationships` - Entity relationships
- `resume_feedback` - Resume analysis results
- `research_tasks` - Research task tracking
- `sql_queries` - SQL query history

All tables are protected with Row Level Security (RLS) to ensure users can only access their own data.

## Security

- Email/password authentication via Supabase
- Row Level Security on all database tables
- Secure session management
- User data isolation
- Protected API endpoints

## Features in Detail

### Multi-PDF Chat
The PDF Chat feature allows users to upload multiple PDF documents and have intelligent conversations about their content. The system:
1. Extracts text from PDFs
2. Chunks documents into manageable pieces
3. Generates vector embeddings for semantic search
4. Extracts entities and relationships (GraphRAG)
5. Provides context-aware responses using RAG

### GraphRAG
GraphRAG enhances traditional RAG by understanding entity relationships within documents. It:
1. Identifies key entities (people, organizations, concepts)
2. Maps relationships between entities
3. Constructs knowledge graphs
4. Uses graph context for more accurate responses

### Resume Feedback
The ATS Resume Feedback system uses multiple specialized agents:
1. **Scoring Agent** - Calculates ATS compatibility
2. **Keyword Agent** - Analyzes keyword presence/absence
3. **Formatting Agent** - Checks structure and readability
4. **Content Agent** - Evaluates descriptions and achievements
5. **Synthesis Agent** - Combines feedback into recommendations

### Research Assistant
The autonomous research agent:
1. Plans research strategy
2. Gathers information from multiple sources
3. Analyzes and synthesizes findings
4. Generates comprehensive reports with citations
5. Tracks task progress and history

### Text to SQL
Natural language query conversion:
1. Interprets user intent
2. Generates valid SQL queries
3. Validates query safety
4. Executes queries with read-only permissions
5. Displays and exports results

## Current Implementation Status

This implementation includes:
- Complete frontend UI for all features
- Authentication system with Supabase
- Database schema with RLS policies
- Mock AI responses for demonstration

To connect real AI services, you would need to:
1. Add API keys for OpenAI or Google Gemini
2. Implement actual PDF text extraction
3. Set up vector embedding generation
4. Connect to real AI models for responses
5. Implement actual file upload to Supabase Storage

## License

MIT License
