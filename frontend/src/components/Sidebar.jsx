import { useEffect, useState } from "react";
import { useChatStore } from "../store/useChatStore";
import { useAuthStore } from "../store/useAuthStore";
import SidebarSkeleton from "./skeletons/SidebarSkeleton";
import { Users } from "lucide-react";

const Sidebar = () => {
  const { getUsers, users, selectedUser, setSelectedUser, isUsersLoading } = useChatStore();

  const { onlineUsers } = useAuthStore();
  const [showOnlineOnly, setShowOnlineOnly] = useState(false);

  useEffect(() => {
    getUsers();
  }, [getUsers]);

  const filteredUsers = showOnlineOnly
    ? users.filter((user) => onlineUsers.includes(user._id))
    : users;

  if (isUsersLoading) return <SidebarSkeleton />;

  return (
    <aside className="h-full w-20 lg:w-72 border-r border-base-300/50 bg-base-100/50 backdrop-blur-sm flex flex-col transition-all duration-300 shadow-lg">
      <div className="border-b border-base-300/50 w-full p-5 bg-gradient-to-r from-base-100 to-base-200/50">
        <div className="flex items-center gap-2">
          <div className="p-2 rounded-lg bg-primary/10">
            <Users className="size-5 text-primary" />
          </div>
          <span className="font-bold text-lg hidden lg:block bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">Contacts</span>
        </div>
        {/* TODO: Online filter toggle */}
        <div className="mt-3 hidden lg:flex items-center gap-2">
          <label className="cursor-pointer flex items-center gap-2">
            <input
              type="checkbox"
              checked={showOnlineOnly}
              onChange={(e) => setShowOnlineOnly(e.target.checked)}
              className="checkbox checkbox-sm checkbox-primary"
            />
            <span className="text-sm font-medium">Show online only</span>
          </label>
          <span className="text-xs text-base-content/60 bg-base-200 px-2 py-1 rounded-full">
            {onlineUsers.length - 1} online
          </span>
        </div>
      </div>

      <div className="overflow-y-auto w-full py-3 scrollbar-thin scrollbar-thumb-primary/20 scrollbar-track-transparent">
        {filteredUsers.map((user) => (
          <button
            key={user._id}
            onClick={() => setSelectedUser(user)}
            className={`
              w-full p-3 flex items-center gap-3 mx-2 rounded-xl
              hover:bg-base-200/80 transition-all duration-200 hover:shadow-md
              ${selectedUser?._id === user._id 
                ? "bg-gradient-to-r from-primary/20 to-secondary/20 ring-2 ring-primary/30 shadow-md" 
                : ""
              }
            `}
          >
            <div className="relative mx-auto lg:mx-0">
              <div className={`size-12 rounded-full p-0.5 ${
                onlineUsers.includes(user._id) 
                  ? "bg-gradient-to-r from-green-400 to-emerald-500" 
                  : "bg-base-300"
              }`}>
                <img
                  src={user.profilePic || "/avatar.png"}
                  alt={user.name}
                  className="size-full object-cover rounded-full border-2 border-base-100"
                />
              </div>
              {onlineUsers.includes(user._id) && (
                <span
                  className="absolute bottom-0 right-0 size-3.5 bg-green-500 
                  rounded-full ring-2 ring-base-100 animate-pulse"
                />
              )}
            </div>

            {/* User info - only visible on larger screens */}
            <div className="hidden lg:block text-left min-w-0 flex-1">
              <div className="font-semibold truncate text-base-content">{user.fullName}</div>
              <div className={`text-xs font-medium ${
                onlineUsers.includes(user._id) 
                  ? "text-green-500" 
                  : "text-base-content/50"
              }`}>
                {onlineUsers.includes(user._id) ? "● Online" : "○ Offline"}
              </div>
            </div>
          </button>
        ))}

        {filteredUsers.length === 0 && (
          <div className="text-center text-base-content/50 py-8">
            <Users className="size-12 mx-auto mb-2 opacity-30" />
            <p className="text-sm">No users found</p>
          </div>
        )}
      </div>
    </aside>
  );
};
export default Sidebar;
