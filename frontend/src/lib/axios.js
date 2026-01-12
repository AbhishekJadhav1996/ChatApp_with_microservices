import axios from "axios";

export const axiosInstance = axios.create({
  baseURL: import.meta.env.MODE === "development" ? "http://localhost:5000/api" : "/api",
  withCredentials: true,
});

// Add response interceptor to handle errors gracefully
axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    // Log error but don't throw for 401 on checkAuth
    if (error.config?.url?.includes("/auth/check")) {
      // This is handled in useAuthStore
      return Promise.reject(error);
    }
    return Promise.reject(error);
  }
);