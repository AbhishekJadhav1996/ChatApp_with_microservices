import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors from "cors";

import path from "path";

import { connectDB } from "./lib/db.js";

import authRoutes from "./routes/auth.route.js";
import messageRoutes from "./routes/message.route.js";
import { app, server } from "./lib/socket.js";

dotenv.config();

const PORT = process.env.PORT;
const __dirname = path.resolve();

app.use(express.json());
app.use(cookieParser());

// CORS configuration - allow requests from frontend
// In production, frontend and backend are on the same domain via ingress
const corsOrigin = process.env.FRONTEND_URL === "*" || process.env.CORS_ORIGIN === "*" 
  ? true 
  : (process.env.FRONTEND_URL || process.env.CORS_ORIGIN || "http://localhost:5173");
const corsOptions = {
  origin: corsOrigin,
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
};

app.use(cors(corsOptions));

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", service: "backend" });
});

app.use("/api/auth", authRoutes);
app.use("/api/messages", messageRoutes);

// Note: Frontend is deployed separately, so we don't serve static files here
// If you need to serve frontend from backend, uncomment the following:
// if (process.env.NODE_ENV === "production" && process.env.SERVE_FRONTEND === "true") {
//   app.use(express.static(path.join(__dirname, "../frontend/dist")));
//   app.get("*", (req, res) => {
//     res.sendFile(path.join(__dirname, "../frontend", "dist", "index.html"));
//   });
// }

server.listen(PORT, () => {
  console.log("server is running on PORT:" + PORT);
  connectDB();
});
