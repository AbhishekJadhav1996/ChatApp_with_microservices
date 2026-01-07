import { MessageSquare } from "lucide-react";

const NoChatSelected = () => {
  return (
    <div className="w-full flex flex-1 flex-col items-center justify-center p-16 bg-gradient-to-br from-base-100/50 via-base-200/30 to-base-100/50 relative overflow-hidden">
      {/* Animated background circles */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-64 h-64 bg-primary/5 rounded-full blur-3xl animate-float"></div>
        <div className="absolute bottom-1/4 right-1/4 w-64 h-64 bg-secondary/5 rounded-full blur-3xl animate-float" style={{ animationDelay: '1.5s' }}></div>
      </div>
      
      <div className="max-w-md text-center space-y-6 relative z-10">
        {/* Icon Display */}
        <div className="flex justify-center gap-4 mb-4">
          <div className="relative">
            <div className="absolute inset-0 bg-primary/20 rounded-2xl blur-xl animate-pulse"></div>
            <div className="relative w-20 h-20 rounded-2xl bg-gradient-to-br from-primary/20 to-secondary/20 flex items-center justify-center shadow-lg border border-primary/20 animate-float">
              <MessageSquare className="w-10 h-10 text-primary" />
            </div>
          </div>
        </div>

        {/* Welcome Text */}
        <h2 className="text-3xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
          Welcome to Chatty!
        </h2>
        <p className="text-base-content/70 text-lg">
          Select a conversation from the sidebar to start chatting
        </p>
        <div className="flex justify-center gap-2 pt-4">
          <div className="w-2 h-2 bg-primary rounded-full animate-bounce" style={{ animationDelay: '0s' }}></div>
          <div className="w-2 h-2 bg-secondary rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
          <div className="w-2 h-2 bg-primary rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
        </div>
      </div>
    </div>
  );
};

export default NoChatSelected;
