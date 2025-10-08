import { ReactNode, useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import {
  Menu,
  X,
  LayoutDashboard,
  FileText,
  Network,
  Briefcase,
  Search,
  Database,
  LogOut,
  User,
} from 'lucide-react';

interface DashboardLayoutProps {
  children: ReactNode;
  currentPage: string;
  onNavigate: (page: string) => void;
}

const navigationItems = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'pdf-chat', label: 'PDF Chat', icon: FileText },
  { id: 'graphrag', label: 'GraphRAG', icon: Network },
  { id: 'resume-feedback', label: 'Resume Feedback', icon: Briefcase },
  { id: 'research', label: 'Research Assistant', icon: Search },
  { id: 'text-to-sql', label: 'Text to SQL', icon: Database },
];

export default function DashboardLayout({ children, currentPage, onNavigate }: DashboardLayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const { user, signOut } = useAuth();

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="fixed top-0 left-0 right-0 bg-white border-b border-gray-200 z-30">
        <div className="flex items-center justify-between px-4 h-16">
          <div className="flex items-center">
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="lg:hidden p-2 rounded-lg hover:bg-gray-100 mr-2"
            >
              {sidebarOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
            <div className="flex items-center">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-600 to-blue-700 rounded-lg flex items-center justify-center mr-3">
                <span className="text-white font-bold text-lg">AI</span>
              </div>
              <span className="text-xl font-bold text-gray-900">GenAI Platform</span>
            </div>
          </div>

          <div className="flex items-center space-x-4">
            <div className="hidden md:flex items-center text-sm text-gray-600">
              <User className="w-4 h-4 mr-2" />
              {user?.email}
            </div>
            <button
              onClick={signOut}
              className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <LogOut className="w-4 h-4 mr-2" />
              Sign Out
            </button>
          </div>
        </div>
      </div>

      <div
        className={`fixed inset-y-0 left-0 transform ${
          sidebarOpen ? 'translate-x-0' : '-translate-x-full'
        } lg:translate-x-0 transition-transform duration-200 ease-in-out z-20 w-64 bg-white border-r border-gray-200 pt-16`}
      >
        <nav className="p-4 space-y-1">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            const isActive = currentPage === item.id;
            return (
              <button
                key={item.id}
                onClick={() => {
                  onNavigate(item.id);
                  setSidebarOpen(false);
                }}
                className={`w-full flex items-center px-4 py-3 rounded-lg transition-all ${
                  isActive
                    ? 'bg-blue-50 text-blue-700 font-medium'
                    : 'text-gray-700 hover:bg-gray-50'
                }`}
              >
                <Icon className={`w-5 h-5 mr-3 ${isActive ? 'text-blue-700' : 'text-gray-500'}`} />
                {item.label}
              </button>
            );
          })}
        </nav>
      </div>

      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 z-10 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      <div className="lg:pl-64 pt-16">
        <main className="p-6">{children}</main>
      </div>
    </div>
  );
}
