import express from "express";
import { protectRoute } from "../middleware/auth.middleware.js";
import { getUsersForSidebar, updateProfile, getUserById } from "../controllers/user.controller.js";

const router = express.Router();

router.get("/", protectRoute, getUsersForSidebar);
router.put("/profile", protectRoute, updateProfile);
router.get("/:id", protectRoute, getUserById);

export default router;

