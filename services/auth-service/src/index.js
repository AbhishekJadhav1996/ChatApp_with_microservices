import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors from "cors";
import { connectDB } from "./lib/db.js";
import authRoutes from "./routes/auth.route.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

app.use(express.json());
app.use(cookieParser());
app.use(
  cors({
    origin: process.env.FRONTEND_URL || "http://localhost:5173",
    credentials: true,
  })
);

app.use("/api/auth", authRoutes);

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", service: "auth-service" });
});

app.listen(PORT, () => {
  console.log(`Auth Service running on PORT: ${PORT}`);
  connectDB();
});

