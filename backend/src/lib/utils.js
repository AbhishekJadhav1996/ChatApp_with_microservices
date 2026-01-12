import jwt from "jsonwebtoken";

export const generateToken = (userId, res) => {
  const token = jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: "7d",
  });

  // Cookie settings - adjust based on environment
  // For HTTP (development/local), use secure: false
  // For HTTPS (production), use secure: true
  const isSecure = process.env.NODE_ENV === "production" && process.env.USE_HTTPS === "true";
  const sameSiteSetting = isSecure ? "none" : "lax";
  
  res.cookie("jwt", token, {
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    httpOnly: true, // Prevent XSS attacks
    sameSite: sameSiteSetting,
    secure: isSecure, // Only secure over HTTPS
    path: "/", // Ensure cookie is sent for all routes
  });

  return token;
};
