import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors from "cors";
import { connectDB } from "./lib/db.js";
import userRoutes from "./routes/user.route.js";
import { protectRoute } from "./middleware/auth.middleware.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5002;

app.use(express.json());
app.use(cookieParser());
app.use(
  cors({
    origin: process.env.FRONTEND_URL || "http://localhost:5173",
    credentials: true,
  })
);

app.use("/api/users", userRoutes);

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", service: "user-service" });
});

app.listen(PORT, () => {
  console.log(`User Service running on PORT: ${PORT}`);
  connectDB();
});

