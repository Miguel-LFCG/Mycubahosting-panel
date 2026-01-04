# Heliactyl API Documentation

## 📖 Overview

The Heliactyl API v3 allows you to programmatically manage users, servers, resources, and more.

**Base URL:** `http://your-domain.com/api`  
**API Version:** v3

---

## 🔐 Authentication

All requests require a Bearer token in the header:

```http
Authorization: Bearer YOUR_API_KEY
```

**Set your API key in `config.toml`:**
```toml
[api.client.api]
enabled = true
code = "your-api-key-here"
```

**Example:**
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://your-domain.com/api/v3/userinfo?id=123456789
```

---

## 📋 API Endpoints

### 1. Check API Status

Check if the API is running and get version info.

**`GET /api`**

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" http://your-domain.com/api
```

**Response:**
```json
{
  "status": true,
  "version": "3.2.1-beta.1",
  "platform_codename": "Avalanche 2"
}
```

---

## 📋 API Endpoints

### Core Endpoints

#### 1. Check API Status

**`GET /api`**

Check if the API is running and get version information.

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://your-domain.com/api
```

**Response:**
```json
{
  "status": true,
  "version": "3.2.1-beta.1",
  "platform_codename": "Avalanche 2"
}
```

---

### 👤 User Management

#### 2. Get User Information

**`GET /api/v3/userinfo?id=USER_ID`**

Get detailed user information including package, resources, coins, and Pterodactyl account.

**Parameters:**
- `id` (required): User ID (Discord/Google/GitHub/Local ID)

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "http://your-domain.com/api/v3/userinfo?id=123456789"
```

**Response:**
```json
{
  "status": "success",
  "id": "123456789",
  "renewalBypass": true,
  "package": {
    "name": "default",
    "ram": 2048,
    "disk": 10240,
    "cpu": 100,
    "servers": 2
  },
  "extra": {
    "ram": 1024,
    "disk": 5120,
    "cpu": 50,
    "servers": 1
  },
  "userinfo": {
    "attributes": {
      "id": 1,
      "username": "user123",
      "email": "user@example.com"
    }
  },
  "coins": 1500
}
```

#### 3. Ban User

**`POST /api/v3/ban`**

Ban a user from the platform.

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","reason":"Violation","expiration":"2025-12-31T23:59:59Z"}' \
  http://your-domain.com/api/v3/ban
```

**Body:**
```json
{
  "id": "123456789",
  "reason": "Violation of terms",
  "expiration": "2025-12-31T23:59:59Z"
}
```
- `reason` (optional): Ban reason
- `expiration` (optional): ISO date for ban end, or `null` for permanent

**Response:** `{"status": "success", "message": "User banned successfully"}`

#### 4. Unban User

**`POST /api/v3/unban`**

Remove a ban from a user.

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/unban
```

**Response:** `{"status": "success", "message": "User unbanned successfully"}`

#### 5. Get User Activity/Interactions

**`GET /api/v3/userinteractions?id=USER_ID&limit=15`**

Get the last N interactions of a user from system logs.

**Parameters:**
- `id` (required): User ID
- `limit` (optional): Number of interactions (default: 15, max: 100)

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "http://your-domain.com/api/v3/userinteractions?id=123456789&limit=20"
```

**Response:**
```json
{
  "status": "success",
  "userId": "123456789",
  "limit": 15,
  "count": 12,
  "interactions": [
    {
      "timestamp": "2025-12-31 12:44:15",
      "action": "[AFK] User miguel.cuba (123456789) disconnected from cluster cluster-ojrd6k"
    }
  ]
}
```

---

### 💰 Coins & Resources

#### 6. Set User Coins

**`POST /api/v3/setcoins`**

Set the exact number of coins for a user.

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","coins":1000}' \
  http://your-domain.com/api/v3/setcoins
```

**Body:**
```json
{
  "id": "123456789",
  "coins": 1000
}
```
- `coins` must be 0-999999999999999

**Response:** `{"status": "success"}`

#### 7. Add Coins to User

**`POST /api/v3/addcoins`**

Add coins to a user's existing balance.

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","coins":500}' \
  http://your-domain.com/api/v3/addcoins
```

**Body:**
```json
{
  "id": "123456789",
  "coins": 500
}
```
- `coins` must be 1-999999999999999

**Response:** `{"status": "success"}`

#### 8. Set User Package/Plan

**`POST /api/v3/setplan`**

Assign or remove a package from a user.

```bash
# Set package
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","package":"premium"}' \
  http://your-domain.com/api/v3/setplan

# Remove package (omit package field)
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/setplan
```

**Body:**
```json
{
  "id": "123456789",
  "package": "premium"
}
```
- Omit `package` to remove user's package

**Response:** `{"status": "success"}`

#### 9. Set User Resources

**`POST /api/v3/setresources`**

Set extra resources for a user (adds to their package resources).

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","ram":1024,"disk":5120,"cpu":50,"servers":1}' \
  http://your-domain.com/api/v3/setresources
```

**Body:**
```json
{
  "id": "123456789",
  "ram": 1024,
  "disk": 5120,
  "cpu": 50,
  "servers": 1
}
```
- All resource fields are optional
- Resources are additive to package resources
- Each value must be 0-999999999999999

**Response:** `{"status": "success"}`

---

### 🔄 Renewal Bypass

#### 10. Give Renewal Bypass

**`POST /api/v3/give_renewalbypass`**

Grant renewal bypass to a user (servers never expire).

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/give_renewalbypass
```

**Response:** `{"status": "success", "message": "Renewal bypass granted successfully."}`

#### 11. Remove Renewal Bypass

**`POST /api/v3/remove_renewalbypass`**

Remove renewal bypass from a user.

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/remove_renewalbypass
```

**Response:** `{"status": "success", "message": "Renewal bypass removed successfully."}`

---

### 🖥️ Server Management

#### 12. Get User Server IDs ✨ NEW

**`GET /api/v3/userservers?id=USER_ID`**

Get a list of all server IDs and basic info for a user.

**Parameters:**
- `id` (required): User ID

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "http://your-domain.com/api/v3/userservers?id=123456789"
```

**Response:**
```json
{
  "status": "success",
  "userId": "123456789",
  "serverCount": 3,
  "servers": [
    {
      "id": 42,
      "identifier": "abc123def",
      "name": "My Minecraft Server"
    },
    {
      "id": 43,
      "identifier": "xyz789ghi",
      "name": "My Game Server"
    }
  ]
}
```

**What this returns:**
- `id`: Internal server ID (numeric)
- `identifier`: Server UUID (used for web access)
- `name`: Server name

#### 13. Get User Server Details ✨ NEW

**`GET /api/v3/userserverdetails?id=USER_ID`**

Get detailed information about all servers owned by a user.

**Parameters:**
- `id` (required): User ID

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "http://your-domain.com/api/v3/userserverdetails?id=123456789"
```

**Response:**
```json
{
  "status": "success",
  "userId": "123456789",
  "serverCount": 2,
  "servers": [
    {
      "id": 42,
      "identifier": "abc123def",
      "uuid": "abc123def-456-789-ghi-jkl012mno",
      "name": "My Minecraft Server",
      "description": "My awesome server",
      "status": "running",
      "limits": {
        "memory": 2048,
        "disk": 10240,
        "cpu": 100,
        "swap": 0,
        "io": 500
      },
      "featureLimits": {
        "databases": 2,
        "allocations": 1,
        "backups": 3
      },
      "suspended": false,
      "node": 1,
      "allocation": 5,
      "egg": 1
    }
  ]
}
```

**What this returns:**
- **id**: Internal server ID
- **identifier**: Server UUID for web access
- **uuid**: Full Pterodactyl UUID
- **name**: Server name
- **description**: Server description
- **status**: Current status (running, stopped, etc.)
- **limits**: Resource limits (RAM, disk, CPU, swap, IO)
- **featureLimits**: Feature limits (databases, allocations, backups)
- **suspended**: Whether server is suspended
- **node**: Node ID where server is hosted
- **allocation**: Primary allocation ID
- **egg**: Egg/game type ID

---

## ❌ Error Responses

All endpoints may return these common errors:

**API Disabled:**
```json
{
  "status": "error",
  "message": "API is disabled"
}
```

**Missing Authorization:**
```json
{
  "status": "error",
  "message": "Missing authorization header"
}
```

**Invalid API Key:**
```json
{
  "status": "error",
  "message": "Invalid API key"
}
```

**Missing/Invalid ID:**
```json
{
  "status": "missing id"
}
```
```json
{
  "status": "invalid id"
}
```

---

## 💡 Usage Examples

### JavaScript/Node.js

```javascript
const axios = require('axios');

const API_KEY = 'your-api-key-here';
const BASE_URL = 'http://your-domain.com/api';

const api = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Authorization': `Bearer ${API_KEY}`,
    'Content-Type': 'application/json'
  }
});

// Get user info
const userInfo = await api.get('/v3/userinfo', { params: { id: '123456789' } });
console.log('User coins:', userInfo.data.coins);
console.log('Has renewal bypass:', userInfo.data.renewalBypass);

// Get user servers
const servers = await api.get('/v3/userservers', { params: { id: '123456789' } });
console.log(`User has ${servers.data.serverCount} servers`);

// Get detailed server info
const serverDetails = await api.get('/v3/userserverdetails', { params: { id: '123456789' } });
serverDetails.data.servers.forEach(server => {
  console.log(`${server.name}: ${server.limits.memory}MB RAM, ${server.limits.disk}MB Disk`);
});

// Add coins
await api.post('/v3/addcoins', { id: '123456789', coins: 100 });

// Grant renewal bypass
await api.post('/v3/give_renewalbypass', { id: '123456789' });
```

### Python

```python
import requests

API_KEY = 'your-api-key-here'
BASE_URL = 'http://your-domain.com/api'
HEADERS = {
    'Authorization': f'Bearer {API_KEY}',
    'Content-Type': 'application/json'
}

# Get user info
response = requests.get(f'{BASE_URL}/v3/userinfo', headers=HEADERS, params={'id': '123456789'})
user_data = response.json()
print(f"User coins: {user_data['coins']}")
print(f"Has renewal bypass: {user_data.get('renewalBypass', False)}")

# Get user servers
response = requests.get(f'{BASE_URL}/v3/userservers', headers=HEADERS, params={'id': '123456789'})
servers = response.json()
print(f"User has {servers['serverCount']} servers")
for server in servers['servers']:
    print(f"  - {server['name']} (ID: {server['id']})")

# Get detailed server info
response = requests.get(f'{BASE_URL}/v3/userserverdetails', headers=HEADERS, params={'id': '123456789'})
details = response.json()
for server in details['servers']:
    print(f"{server['name']}: {server['limits']['memory']}MB RAM, Status: {server['status']}")

# Add coins
response = requests.post(f'{BASE_URL}/v3/addcoins', headers=HEADERS, json={'id': '123456789', 'coins': 100})
print(response.json())

# Grant renewal bypass
response = requests.post(f'{BASE_URL}/v3/give_renewalbypass', headers=HEADERS, json={'id': '123456789'})
print(response.json())
```

### cURL Complete Workflow

```bash
API_KEY="your-api-key-here"
BASE_URL="http://your-domain.com/api"
USER_ID="123456789"

# Check API status
curl -H "Authorization: Bearer $API_KEY" "$BASE_URL"

# Get user information
curl -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/v3/userinfo?id=$USER_ID"

# Get user's server IDs
curl -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/v3/userservers?id=$USER_ID"

# Get detailed server information
curl -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/v3/userserverdetails?id=$USER_ID"

# Get user activity
curl -H "Authorization: Bearer $API_KEY" \
  "$BASE_URL/v3/userinteractions?id=$USER_ID&limit=20"

# Add coins
curl -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"$USER_ID\",\"coins\":500}" \
  "$BASE_URL/v3/addcoins"

# Set package
curl -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"$USER_ID\",\"package\":\"premium\"}" \
  "$BASE_URL/v3/setplan"

# Give renewal bypass
curl -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"$USER_ID\"}" \
  "$BASE_URL/v3/give_renewalbypass"
```

---

## 🎯 Common Use Cases

### 1. Monitor User Servers

```bash
# Get all servers for a user
curl -H "Authorization: Bearer $API_KEY" \
  "http://your-domain.com/api/v3/userserverdetails?id=123456789"

# Check which servers are running
# Parse the JSON response to filter by "status": "running"
```

### 2. Reward System

```bash
# Check user's current coins
USER_INFO=$(curl -H "Authorization: Bearer $API_KEY" \
  "http://your-domain.com/api/v3/userinfo?id=123456789")

# Add reward coins
curl -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","coins":100}' \
  "http://your-domain.com/api/v3/addcoins"
```

### 3. User Activity Tracking

```bash
# Get last 50 user actions
curl -H "Authorization: Bearer $API_KEY" \
  "http://your-domain.com/api/v3/userinteractions?id=123456789&limit=50"

# Check if user is active (has recent interactions)
```

### 4. Upgrade User Resources

```bash
# Give extra resources
curl -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","ram":2048,"disk":10240,"servers":2}' \
  "http://your-domain.com/api/v3/setresources"

# Set premium package
curl -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","package":"premium"}' \
  "http://your-domain.com/api/v3/setplan"
```

---

## 📝 Notes

- **User IDs**: Use Discord/Google/GitHub ID or local UUID depending on auth method
- **All actions are logged**: API actions are logged to Discord webhooks (if configured)
- **Rate limiting**: May be enabled in your config.toml
- **Secure your API key**: Never expose it in client-side code or public repos
- **Resource values**: Must be within 0-999999999999999 range
- **Server tracking**: New endpoints make it easy to monitor all user servers

---

## 🆕 What's New in This Version

### New Endpoints (v3.2.1)
- **`GET /api/v3/userservers`**: Get list of server IDs for a user
- **`GET /api/v3/userserverdetails`**: Get detailed info for all user servers
- **`GET /api/v3/userinteractions`**: Track user activity from logs

### Improvements
- Simplified API documentation
- Better error handling
- More consistent response formats
- Comprehensive examples for all endpoints

---

**Last Updated:** January 4, 2026
