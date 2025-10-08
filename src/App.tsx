import { useState } from 'react';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import LoginPage from './components/auth/LoginPage';
import DashboardLayout from './components/layout/DashboardLayout';
import Dashboard from './pages/Dashboard';
import PDFChat from './pages/PDFChat';
import GraphRAG from './pages/GraphRAG';
import ResumeFeedback from './pages/ResumeFeedback';
import ResearchAssistant from './pages/ResearchAssistant';
import TextToSQL from './pages/TextToSQL';

function AppContent() {
  const { user, loading } = useAuth();
  const [currentPage, setCurrentPage] = useState('dashboard');

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <LoginPage />;
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return <Dashboard onNavigate={setCurrentPage} />;
      case 'pdf-chat':
        return <PDFChat />;
      case 'graphrag':
        return <GraphRAG />;
      case 'resume-feedback':
        return <ResumeFeedback />;
      case 'research':
        return <ResearchAssistant />;
      case 'text-to-sql':
        return <TextToSQL />;
      default:
        return <Dashboard onNavigate={setCurrentPage} />;
    }
  };

  return (
    <DashboardLayout currentPage={currentPage} onNavigate={setCurrentPage}>
      {renderPage()}
    </DashboardLayout>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;
