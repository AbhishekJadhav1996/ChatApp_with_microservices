import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors from "cors";
import { connectDB } from "./lib/db.js";
import messageRoutes from "./routes/message.route.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5003;

app.use(express.json());
app.use(cookieParser());
app.use(
  cors({
    origin: process.env.FRONTEND_URL || "http://localhost:5173",
    credentials: true,
  })
);

app.use("/api/messages", messageRoutes);

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", service: "message-service" });
});

app.listen(PORT, () => {
  console.log(`Message Service running on PORT: ${PORT}`);
  connectDB();
});

