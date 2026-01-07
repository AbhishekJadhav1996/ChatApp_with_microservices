import { useChatStore } from "../store/useChatStore";
import { useEffect, useRef } from "react";

import ChatHeader from "./ChatHeader";
import MessageInput from "./MessageInput";
import MessageSkeleton from "./skeletons/MessageSkeleton";
import { useAuthStore } from "../store/useAuthStore";
import { formatMessageTime } from "../lib/utils";

const ChatContainer = () => {
  const {
    messages,
    getMessages,
    isMessagesLoading,
    selectedUser,
    subscribeToMessages,
    unsubscribeFromMessages,
  } = useChatStore();
  const { authUser } = useAuthStore();
  const messageEndRef = useRef(null);

  useEffect(() => {
    getMessages(selectedUser._id);

    subscribeToMessages();

    return () => unsubscribeFromMessages();
  }, [selectedUser._id, getMessages, subscribeToMessages, unsubscribeFromMessages]);

  useEffect(() => {
    if (messageEndRef.current && messages) {
      messageEndRef.current.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages]);

  if (isMessagesLoading) {
    return (
      <div className="flex-1 flex flex-col overflow-auto">
        <ChatHeader />
        <MessageSkeleton />
        <MessageInput />
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col overflow-auto bg-gradient-to-b from-base-100 to-base-200/50">
      <ChatHeader />

      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-pattern">
        {messages.map((message) => (
          <div
            key={message._id}
            className={`chat ${message.senderId === authUser._id ? "chat-end" : "chat-start"} animate-in fade-in slide-in-from-bottom-2 duration-300`}
            ref={messageEndRef}
          >
            <div className="chat-image avatar">
              <div className="size-10 rounded-full border-2 border-primary/20 shadow-lg ring-2 ring-base-300">
                <img
                  src={
                    message.senderId === authUser._id
                      ? authUser.profilePic || "/avatar.png"
                      : selectedUser.profilePic || "/avatar.png"
                  }
                  alt="profile pic"
                  className="object-cover"
                />
              </div>
            </div>
            <div className="chat-header mb-1">
              <time className="text-xs opacity-60 font-medium">
                {formatMessageTime(message.createdAt)}
              </time>
            </div>
            <div className={`chat-bubble flex flex-col shadow-lg transition-all hover:shadow-xl ${
              message.senderId === authUser._id 
                ? "bg-gradient-to-br from-primary to-primary/90 text-primary-content" 
                : "bg-base-200 text-base-content border border-base-300"
            }`}>
              {message.image && (
                <img
                  src={message.image}
                  alt="Attachment"
                  className="sm:max-w-[200px] rounded-lg mb-2 shadow-md border border-base-300"
                />
              )}
              {message.text && <p className="break-words">{message.text}</p>}
            </div>
          </div>
        ))}
      </div>

      <MessageInput />
    </div>
  );
};
export default ChatContainer;
