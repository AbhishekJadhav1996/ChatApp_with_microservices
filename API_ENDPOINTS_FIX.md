# API Endpoints Fix

## Issues Fixed

### 1. `/api/users` 404 Error

**Problem**: Frontend was calling `/api/users` but backend route is `/api/messages/users`

**Fix**: Updated `frontend/src/store/useChatStore.js`:
- Changed from: `axiosInstance.get("/users")`
- Changed to: `axiosInstance.get("/messages/users")`

### 2. `/users/profile` 404 Error

**Problem**: Frontend was calling `/api/users/profile` but backend route is `/api/auth/update-profile`

**Fix**: Updated `frontend/src/store/useAuthStore.js`:
- Changed from: `axiosInstance.put("/users/profile", data)`
- Changed to: `axiosInstance.put("/auth/update-profile", data)`

### 3. Socket.io 400 Bad Request Error

**Problem**: Socket.io connection failing with 400 errors and WebSocket connection issues

**Fixes Applied**:

1. **Frontend Socket.io Configuration** (`frontend/src/store/useAuthStore.js`):
   - Added explicit `path: "/socket.io/"`
   - Added `transports: ["websocket", "polling"]` for fallback
   - Added reconnection settings
   - Added error handlers

2. **Socket Service Configuration** (`services/socket-service/src/index.js`):
   - Added explicit `path: "/socket.io/"`
   - Added `transports: ["websocket", "polling"]`
   - Added `allowEIO3: true` for compatibility
   - Enhanced CORS configuration

## Backend API Routes

### Auth Routes (`/api/auth`)
- `POST /api/auth/signup` - User signup
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/check` - Check authentication status
- `PUT /api/auth/update-profile` - Update user profile

### Message Routes (`/api/messages`)
- `GET /api/messages/users` - Get users for sidebar
- `GET /api/messages/:id` - Get messages with a user
- `POST /api/messages/send/:id` - Send a message

### Socket.io Routes
- `WS /socket.io/` - WebSocket connection (via socket-service)

## Next Steps

1. **Rebuild Frontend**:
   ```bash
   cd frontend
   docker build -t abhishekjadhav1996/chatapp-frontend:latest .
   ```

2. **Rebuild Socket Service**:
   ```bash
   cd services/socket-service
   docker build -t abhishekjadhav1996/chatapp-socket-service:latest .
   ```

3. **Redeploy**:
   ```bash
   kubectl rollout restart deployment/frontend-deployment -n chat-app
   kubectl rollout restart deployment/socket-service-deployment -n chat-app
   ```

4. **Verify**:
   ```bash
   # Check pods
   kubectl get pods -n chat-app
   
   # Check logs
   kubectl logs -n chat-app -l app=frontend --tail=50
   kubectl logs -n chat-app -l app=socket-service --tail=50
   ```

## Testing

After redeployment, test:
1. Login/Signup should work
2. User list should load (no more 404 on `/api/users`)
3. Profile update should work (no more 404 on `/users/profile`)
4. Socket.io connection should establish (no more 400 errors)
5. Real-time messaging should work

