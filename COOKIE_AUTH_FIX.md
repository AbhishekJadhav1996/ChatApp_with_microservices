# Cookie Authentication Fix

## Issues Fixed

### 1. 401 Unauthorized on `/api/auth/check`

**Root Cause**: Cookies were set with `secure: true`, which requires HTTPS. Since the application is accessed via HTTP (`http://3.230.154.46`), browsers refuse to send the cookie, causing 401 errors.

**Fix**: Made cookie settings conditional:
- `secure: false` for HTTP connections
- `secure: true` only when `USE_HTTPS=true` environment variable is set
- `sameSite: "lax"` for HTTP (works better than "none")
- `sameSite: "none"` for HTTPS (required for cross-origin)
- Added `path: "/"` to ensure cookie is sent for all routes

### 2. User Logged Out on Page Refresh

**Root Cause**: 
- Cookies weren't being sent due to `secure: true` on HTTP
- Frontend was clearing `authUser` on any error, including network errors
- No persistence mechanism for auth state

**Fixes**:
1. **Backend**: Fixed cookie settings to work with HTTP
2. **Frontend**: Improved error handling in `checkAuth()`:
   - Only clears `authUser` on actual 401 errors
   - Preserves `authUser` on network errors (allows persistence across refresh)
   - Better error logging

## Changes Made

### Backend Changes

1. **`backend/src/lib/utils.js`**:
   - Conditional cookie settings based on HTTPS usage
   - Added `path: "/"` to cookie
   - Changed `sameSite` based on security context

2. **`backend/src/controllers/auth.controller.js`**:
   - Updated `logout()` to use same conditional cookie settings

3. **`backend/src/middleware/auth.middleware.js`**:
   - Better JWT error handling
   - More specific error messages for expired/invalid tokens

### Frontend Changes

1. **`frontend/src/store/useAuthStore.js`**:
   - Improved `checkAuth()` error handling
   - Only clears auth on real 401 errors, not network errors
   - Preserves auth state across page refresh

2. **`frontend/src/lib/axios.js`**:
   - Added response interceptor for better error handling

## Environment Variables

The backend now checks for `USE_HTTPS` environment variable:

- **HTTP (Current Setup)**: Don't set `USE_HTTPS` or set `USE_HTTPS=false`
  - Cookies use `secure: false` and `sameSite: "lax"`

- **HTTPS (Future)**: Set `USE_HTTPS=true` in backend deployment
  - Cookies use `secure: true` and `sameSite: "none"`

## Deployment

### Current Setup (HTTP)

No changes needed to deployment - cookies will work with HTTP automatically.

### If Upgrading to HTTPS

Update `k8s/backend-deployment.yml`:
```yaml
env:
- name: USE_HTTPS
  value: "true"
```

## Testing

After redeployment:

1. **Login**: Should set cookie correctly
2. **Page Refresh**: User should remain logged in
3. **Check Auth**: `/api/auth/check` should return 200 (not 401)
4. **Cookie Persistence**: Cookie should persist for 7 days

## Verification

Check cookies in browser DevTools:
1. Open DevTools → Application → Cookies
2. Look for `jwt` cookie
3. Verify:
   - `HttpOnly: true` ✓
   - `Secure: false` (for HTTP) ✓
   - `SameSite: Lax` (for HTTP) ✓
   - `Path: /` ✓
   - `Expires`: 7 days from now ✓

## Troubleshooting

### Still Getting 401?

1. **Clear cookies** and login again:
   ```javascript
   // In browser console
   document.cookie.split(";").forEach(c => {
     document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/");
   });
   ```

2. **Check backend logs**:
   ```bash
   kubectl logs -n chat-app -l app=backend --tail=50
   ```

3. **Verify cookie is being set**:
   ```bash
   # Check response headers
   curl -v http://<EC2_IP>/api/auth/login -X POST \
     -H "Content-Type: application/json" \
     -d '{"email":"test@test.com","password":"test123"}' \
     -c cookies.txt
   ```

4. **Verify cookie is being sent**:
   ```bash
   # Use saved cookie
   curl -v http://<EC2_IP>/api/auth/check \
     -b cookies.txt
   ```

