import { X } from "lucide-react";
import { useAuthStore } from "../store/useAuthStore";
import { useChatStore } from "../store/useChatStore";

const ChatHeader = () => {
  const { selectedUser, setSelectedUser } = useChatStore();
  const { onlineUsers } = useAuthStore();

  return (
    <div className="p-4 border-b border-base-300/50 bg-gradient-to-r from-base-100 to-base-200/50 backdrop-blur-sm shadow-sm">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          {/* Avatar */}
          <div className="avatar relative">
            <div className={`size-12 rounded-full relative ring-2 ${
              onlineUsers.includes(selectedUser._id) 
                ? "ring-green-500/50" 
                : "ring-base-300"
            }`}>
              <img 
                src={selectedUser.profilePic || "/avatar.png"} 
                alt={selectedUser.fullName}
                className="object-cover"
              />
            </div>
            {onlineUsers.includes(selectedUser._id) && (
              <span className="absolute bottom-0 right-0 size-3.5 bg-green-500 rounded-full ring-2 ring-base-100 animate-pulse"></span>
            )}
          </div>

          {/* User info */}
          <div>
            <h3 className="font-bold text-lg text-base-content">{selectedUser.fullName}</h3>
            <p className={`text-sm font-medium flex items-center gap-1 ${
              onlineUsers.includes(selectedUser._id) 
                ? "text-green-500" 
                : "text-base-content/60"
            }`}>
              <span className={`size-2 rounded-full ${
                onlineUsers.includes(selectedUser._id) 
                  ? "bg-green-500 animate-pulse" 
                  : "bg-base-content/40"
              }`}></span>
              {onlineUsers.includes(selectedUser._id) ? "Online" : "Offline"}
            </p>
          </div>
        </div>

        {/* Close button */}
        <button 
          onClick={() => setSelectedUser(null)}
          className="btn btn-ghost btn-sm btn-circle hover:bg-base-200 transition-all"
        >
          <X className="size-5" />
        </button>
      </div>
    </div>
  );
};
export default ChatHeader;
