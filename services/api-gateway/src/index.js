import express from "express";
import { createProxyMiddleware } from "http-proxy-middleware";
import cookieParser from "cookie-parser";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());
app.use(cookieParser());
app.use(
  cors({
    origin: process.env.FRONTEND_URL || "http://localhost:5173",
    credentials: true,
  })
);

// Service URLs
const AUTH_SERVICE = process.env.AUTH_SERVICE_URL || "http://auth-service:5001";
const USER_SERVICE = process.env.USER_SERVICE_URL || "http://user-service:5002";
const MESSAGE_SERVICE = process.env.MESSAGE_SERVICE_URL || "http://message-service:5003";
const SOCKET_SERVICE = process.env.SOCKET_SERVICE_URL || "http://socket-service:5004";

// Proxy middleware options
const proxyOptions = {
  changeOrigin: true,
  cookieDomainRewrite: "localhost",
  onProxyReq: (proxyReq, req, res) => {
    // Forward cookies
    if (req.headers.cookie) {
      proxyReq.setHeader("Cookie", req.headers.cookie);
    }
  },
  onProxyRes: (proxyRes, req, res) => {
    // Forward Set-Cookie headers
    if (proxyRes.headers["set-cookie"]) {
      proxyRes.headers["set-cookie"] = proxyRes.headers["set-cookie"].map((cookie) =>
        cookie.replace(/;\s*secure/gi, "").replace(/;\s*SameSite=None/gi, "; SameSite=Lax")
      );
    }
  },
};

// Routes
app.use("/api/auth", createProxyMiddleware({ target: AUTH_SERVICE, ...proxyOptions }));
app.use("/api/users", createProxyMiddleware({ target: USER_SERVICE, ...proxyOptions }));
app.use("/api/messages", createProxyMiddleware({ target: MESSAGE_SERVICE, ...proxyOptions }));

// Health check
app.get("/health", (req, res) => {
  res.status(200).json({ 
    status: "ok", 
    service: "api-gateway",
    services: {
      auth: AUTH_SERVICE,
      user: USER_SERVICE,
      message: MESSAGE_SERVICE,
      socket: SOCKET_SERVICE,
    }
  });
});

app.listen(PORT, () => {
  console.log(`API Gateway running on PORT: ${PORT}`);
});

