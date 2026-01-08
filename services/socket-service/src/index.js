import { Server } from "socket.io";
import http from "http";
import express from "express";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const server = http.createServer(app);

app.use(cors({
  origin: process.env.FRONTEND_URL === "*" ? true : (process.env.FRONTEND_URL || process.env.CORS_ORIGIN || "http://localhost:5173"),
  credentials: true,
}));

app.use(express.json());

const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL === "*" ? true : (process.env.FRONTEND_URL || process.env.CORS_ORIGIN || "http://localhost:5173"),
    credentials: true,
  },
});

// Store user socket mappings
const userSocketMap = {};

export function getReceiverSocketId(userId) {
  return userSocketMap[userId];
}

io.on("connection", (socket) => {
  console.log("A user connected", socket.id);

  const userId = socket.handshake.query.userId;
  if (userId) {
    userSocketMap[userId] = socket.id;
  }

  // Emit online users to all clients
  io.emit("getOnlineUsers", Object.keys(userSocketMap));

  socket.on("disconnect", () => {
    console.log("A user disconnected", socket.id);
    if (userId) {
      delete userSocketMap[userId];
    }
    io.emit("getOnlineUsers", Object.keys(userSocketMap));
  });
});

// HTTP endpoint for other services to emit messages
app.post("/api/socket/emit-message", (req, res) => {
  const { receiverId, message } = req.body;
  const receiverSocketId = getReceiverSocketId(receiverId);
  
  if (receiverSocketId) {
    io.to(receiverSocketId).emit("newMessage", message);
    res.status(200).json({ success: true });
  } else {
    res.status(200).json({ success: false, message: "User not online" });
  }
});

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", service: "socket-service" });
});

const PORT = process.env.PORT || 5004;

server.listen(PORT, () => {
  console.log(`Socket Service running on PORT: ${PORT}`);
});

export { io };

