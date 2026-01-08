# Microservices Information

## ✅ Microservices Used in This Application

This application uses a **simplified microservices architecture** with the following services:

### 1. **Backend Service** (Port 5001)
- **Purpose**: Main API service handling all REST endpoints
- **Endpoints**:
  - `/api/auth` - User authentication (signup, login, logout, check auth)
  - `/api/messages` - Message CRUD operations and user list
- **Features**:
  - JWT-based authentication with HTTP-only cookies
  - MongoDB integration for data persistence
  - Cloudinary integration for image uploads
  - Socket.io integration for real-time updates
- **Deployment**: `k8s/backend-deployment.yml`
- **Service**: `k8s/backend-service.yml`
- **HPA**: `k8s/backend-hpa.yml` (auto-scales 2-6 replicas)

### 2. **Socket Service** (Port 5004)
- **Purpose**: WebSocket connection management
- **Features**:
  - Manages Socket.io connections
  - Tracks online users
  - Broadcasts real-time messages and online status updates
- **Deployment**: `k8s/socket-service-deployment.yml`
- **Service**: `k8s/socket-service-service.yml`
- **HPA**: `k8s/socket-service-hpa.yml` (auto-scales 2-9 replicas)

### 3. **Frontend** (Port 80)
- **Purpose**: React-based user interface
- **Features**:
  - Served via Nginx
  - Communicates with Backend API (`/api/*`)
  - Connects to Socket Service (`/socket.io/*`)
- **Deployment**: `k8s/frontend-deployment.yml`
- **Service**: `k8s/frontend-service.yml`

### 4. **MongoDB** (Port 27017)
- **Purpose**: Database for users and messages
- **Features**:
  - Persistent storage with Kubernetes volumes
  - Authentication enabled
- **Deployment**: `k8s/mongodb-deployment.yml`
- **Service**: `k8s/mongodb-service.yml`
- **Storage**: `k8s/mongodb-pv.yml` and `k8s/mongodb-pvc.yml`

## ❌ Microservices NOT Used (Removed)

The following microservices were **removed** as their functionality is integrated into the Backend Service:

- **Auth Service** - Authentication logic is in Backend Service
- **User Service** - User management is in Backend Service
- **Message Service** - Message handling is in Backend Service
- **API Gateway** - Not needed with simplified architecture

## 🔧 Configuration Changes Made

1. **JWT Secret Updated**: Updated `k8s/secrets.yml` with the provided JWT key
2. **CORS Configuration**: Updated to allow all origins (`*`) for production via ingress
3. **Cookie Settings**: Updated to use `sameSite: "none"` and `secure: true` for cross-origin cookie support
4. **Socket Service CORS**: Updated to allow connections from any origin
5. **Ingress WebSocket**: Added WebSocket upgrade annotations for Socket.io support

## 📝 Notes

- All unused microservice directories and Kubernetes manifests have been removed
- The application now uses a simplified 3-service architecture (Backend, Socket Service, Frontend)
- MongoDB is used for persistent storage
- All services are deployed via Kubernetes with HPA for auto-scaling

