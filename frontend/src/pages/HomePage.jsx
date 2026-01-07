import { useChatStore } from "../store/useChatStore";

import Sidebar from "../components/Sidebar";
import NoChatSelected from "../components/NoChatSelected";
import ChatContainer from "../components/ChatContainer";

const HomePage = () => {
  const { selectedUser } = useChatStore();

  return (
    <div className="h-screen bg-gradient-to-br from-base-200 via-base-300 to-base-200 relative overflow-hidden">
      {/* Animated background elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-primary/5 rounded-full blur-3xl animate-float"></div>
        <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-secondary/5 rounded-full blur-3xl animate-float" style={{ animationDelay: '1s' }}></div>
      </div>
      
      <div className="flex items-center justify-center pt-20 px-4 relative z-10">
        <div className="bg-base-100/80 backdrop-blur-xl rounded-2xl shadow-2xl border border-base-300/50 w-full max-w-6xl h-[calc(100vh-8rem)] overflow-hidden">
          <div className="flex h-full rounded-2xl overflow-hidden">
            <Sidebar />

            {!selectedUser ? <NoChatSelected /> : <ChatContainer />}
          </div>
        </div>
      </div>
    </div>
  );
};
export default HomePage;
