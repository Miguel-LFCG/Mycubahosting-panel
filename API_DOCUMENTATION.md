# Heliactyl API Documentation

## Overview

The Heliactyl API v3 provides programmatic access to manage users, resources, and retrieve information about your Heliactyl instance. All API endpoints require authentication using a Bearer token.

**Base URL:** `http://your-domain.com/api`

**API Version:** v3

---

## Authentication

All API requests must include an authentication header:

```http
Authorization: Bearer YOUR_API_KEY
```

You can find or set your API key in your `config.toml` file under:
```toml
[api.client.api]
enabled = true
code = "your-api-key-here"
```

### Example Request
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://your-domain.com/api/v3/userinfo?id=123456789
```

---

## Endpoints

### 1. API Status Check

Get the current status and version of the API.

**Endpoint:** `GET /api`

**Response:**
```json
{
  "status": true,
  "version": "3.2.1-beta.1",
  "platform_codename": "Avalanche 2"
}
```

**Example:**
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://your-domain.com/api
```

---

### 2. Get User Information

Retrieve detailed information about a user including their package, resources, coins, renewal bypass status, and Pterodactyl account details.

**Endpoint:** `GET /api/v3/userinfo`

**Parameters:**
- `id` (required): User ID (Discord ID, Google ID, GitHub ID, or local user ID)

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
      "email": "user@example.com",
      "relationships": { ... }
    }
  },
  "coins": 1500
}
```

**Example:**
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "http://your-domain.com/api/v3/userinfo?id=123456789"
```

**Notes:**
- The `renewalBypass` field indicates if the user has renewal bypass:
  - `true` = User has renewal bypass (servers never expire)
  - `false` = User doesn't have bypass (servers expire normally)

**Error Responses:**
- `{ "status": "missing id" }` - User ID not provided
- `{ "status": "invalid id" }` - User not found in database

---

### 3. Set User Coins

Set the exact number of coins for a user.

**Endpoint:** `POST /api/v3/setcoins`

**Request Body:**
```json
{
  "id": "123456789",
  "coins": 1000
}
```

**Parameters:**
- `id` (string, required): User ID
- `coins` (number, required): Number of coins (0-999999999999999)

**Response:**
```json
{
  "status": "success"
}
```

**Example:**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","coins":1000}' \
  http://your-domain.com/api/v3/setcoins
```

**Error Responses:**
- `{ "status": "body must be an object" }` - Invalid request body
- `{ "status": "id must be a string" }` - Invalid ID type
- `{ "status": "invalid id" }` - User not found
- `{ "status": "coins must be number" }` - Invalid coins type
- `{ "status": "too small or big coins" }` - Coins out of range

---

### 4. Add Coins to User

Add coins to a user's existing balance.

**Endpoint:** `POST /api/v3/addcoins`

**Request Body:**
```json
{
  "id": "123456789",
  "coins": 500
}
```

**Parameters:**
- `id` (string, required): User ID
- `coins` (number, required): Number of coins to add (1-999999999999999)

**Response:**
```json
{
  "status": "success"
}
```

**Example:**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","coins":500}' \
  http://your-domain.com/api/v3/addcoins
```

**Error Responses:**
- `{ "status": "cant do that mate" }` - Attempting to add 0 coins
- Similar error responses as setcoins

---

### 5. Set User Plan/Package

Assign or remove a plan/package from a user.

**Endpoint:** `POST /api/v3/setplan`

**Request Body:**
```json
{
  "id": "123456789",
  "package": "premium"
}
```

**Parameters:**
- `id` (string, required): User ID
- `package` (string, optional): Package name from config.toml. Omit to remove package.

**Response:**
```json
{
  "status": "success"
}
```

**Example (Set Package):**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","package":"premium"}' \
  http://your-domain.com/api/v3/setplan
```

**Example (Remove Package):**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/setplan
```

**Error Responses:**
- `{ "status": "missing body" }` - No request body
- `{ "status": "missing id" }` - User ID not provided
- `{ "status": "invalid id" }` - User not found
- `{ "status": "invalid package" }` - Package doesn't exist in config

---

### 6. Set User Resources

Set extra resources for a user (adds to their package resources).

**Endpoint:** `POST /api/v3/setresources`

**Request Body:**
```json
{
  "id": "123456789",
  "ram": 1024,
  "disk": 5120,
  "cpu": 50,
  "servers": 1
}
```

**Parameters:**
- `id` (string, required): User ID
- `ram` (number, optional): Extra RAM in MB (0-999999999999999)
- `disk` (number, optional): Extra disk in MB (0-999999999999999)
- `cpu` (number, optional): Extra CPU percentage (0-999999999999999)
- `servers` (number, optional): Extra server slots (0-999999999999999)

**Response:**
```json
{
  "status": "success"
}
```

**Example:**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","ram":1024,"disk":5120,"cpu":50,"servers":1}' \
  http://your-domain.com/api/v3/setresources
```

**Notes:**
- You can set individual resources without affecting others
- Setting all resources to 0 removes the extra resource allocation
- Resources are additive to the user's package resources

**Error Responses:**
- `{ "status": "missing body" }` - No request body
- `{ "status": "missing id" }` - User ID not provided
- `{ "status": "invalid id" }` - User not found
- `{ "status": "ram size" }` - RAM out of range
- `{ "status": "disk size" }` - Disk out of range
- `{ "status": "cpu size" }` - CPU out of range
- `{ "status": "server size" }` - Servers out of range
- `{ "status": "missing variables" }` - No resource parameters provided

---

### 7. Ban User

Ban a user from accessing the platform.

**Endpoint:** `POST /api/v3/ban`

**Request Body:**
```json
{
  "id": "123456789",
  "reason": "Violation of terms",
  "expiration": "2025-12-31T23:59:59Z"
}
```

**Parameters:**
- `id` (string, required): User ID
- `reason` (string, optional): Ban reason (default: "No reason provided")
- `expiration` (string/null, optional): ISO date string for ban expiration. `null` for permanent ban.

**Response:**
```json
{
  "status": "success",
  "message": "User banned successfully"
}
```

**Example (Permanent Ban):**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","reason":"Violation of terms"}' \
  http://your-domain.com/api/v3/ban
```

**Example (Temporary Ban):**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","reason":"Spam","expiration":"2025-12-31T23:59:59Z"}' \
  http://your-domain.com/api/v3/ban
```

**Error Responses:**
- `{ "status": "body must be an object" }` - Invalid request body
- `{ "status": "id must be a string" }` - Invalid ID type
- `{ "status": "invalid id" }` - User not found

---

### 8. Unban User

Remove a ban from a user.

**Endpoint:** `POST /api/v3/unban`

**Request Body:**
```json
{
  "id": "123456789"
}
```

**Parameters:**
- `id` (string, required): User ID

**Response:**
```json
{
  "status": "success",
  "message": "User unbanned successfully"
}
```

**Example:**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/unban
```

**Error Responses:**
- `{ "status": "body must be an object" }` - Invalid request body
- `{ "status": "id must be a string" }` - Invalid ID type
- `{ "status": "invalid id" }` - User not found

---

### 9. Get User Interactions *(NEW)*

Retrieve the last N interactions of a user from the system logs.

**Endpoint:** `GET /api/v3/userinteractions`

**Parameters:**
- `id` (required): User ID
- `limit` (optional): Number of interactions to return (default: 15, max: 100)

**Response:**
```json
{
  "status": "success",
  "userId": "849694563295690772",
  "limit": 15,
  "count": 12,
  "interactions": [
    {
      "timestamp": "2025-12-31 12:44:15",
      "action": "[AFK] User miguel.cuba (849694563295690772) disconnected from cluster cluster-ojrd6k"
    },
    {
      "timestamp": "2025-12-31 12:37:51",
      "action": "[AFK] User miguel.cuba (849694563295690772) connected on cluster cluster-ojrd6k"
    },
    {
      "timestamp": "2025-12-31 12:30:43",
      "action": "[AFK] User miguel.cuba (849694563295690772) connected on cluster cluster-bczh83"
    }
  ]
}
```

**Example:**
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "http://your-domain.com/api/v3/userinteractions?id=849694563295690772&limit=15"
```

**Notes:**
- Returns interactions in reverse chronological order (most recent first)
- Searches through the combined.log file for user activity
- Includes AFK connections/disconnections, server access, and other logged actions
- Useful for tracking user activity and last seen information

**Error Responses:**
- `{ "status": "missing id" }` - User ID not provided
- `{ "status": "id must be a string" }` - Invalid ID type
- `{ "status": "invalid id" }` - User not found in database
- `{ "status": "limit must be between 1 and 100" }` - Invalid limit value
- `{ "status": "error", "message": "Log file not found" }` - Log file doesn't exist
- `{ "status": "error", "message": "Failed to read log file" }` - Error reading logs

---

### 10. Give Renewal Bypass to User *(NEW)*

Grant renewal bypass to a user, exempting their servers from the renewal requirement.

**Endpoint:** `POST /api/v3/give_renewalbypass`

**Request Body:**
```json
{
  "id": "123456789"
}
```

**Parameters:**
- `id` (string, required): User ID

**Response:**
```json
{
  "status": "success",
  "message": "Renewal bypass granted successfully."
}
```

**Example:**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/give_renewalbypass
```

**Notes:**
- Users with renewal bypass have servers that never expire
- Bypass is permanent until explicitly removed
- All servers created by users with bypass will not require renewal
- This action is logged to Discord webhooks

**Error Responses:**
- `{ "status": "missing body" }` - No request body
- `{ "status": "missing id" }` - User ID not provided
- `{ "status": "invalid id" }` - User not found in database

---

### 11. Remove Renewal Bypass from User *(NEW)*

Remove renewal bypass from a user, subjecting their servers to the renewal requirement again.

**Endpoint:** `POST /api/v3/remove_renewalbypass`

**Request Body:**
```json
{
  "id": "123456789"
}
```

**Parameters:**
- `id` (string, required): User ID

**Response:**
```json
{
  "status": "success",
  "message": "Renewal bypass removed successfully."
}
```

**Example:**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/remove_renewalbypass
```

**Notes:**
- Removing bypass will reactivate renewal requirements for future servers
- Existing servers will have their renewal timers reset when next accessed
- If auto-delete is enabled, expired servers will be deleted after the threshold

**Error Responses:**
- `{ "status": "missing body" }` - No request body
- `{ "status": "missing id" }` - User ID not provided
- `{ "status": "invalid id" }` - User not found in database

---

### 12. Check User Renewal Bypass Status

Get renewal bypass status for a user (via userinfo endpoint).

**Endpoint:** `GET /api/v3/userinfo`

**Parameters:**
- `id` (required): User ID

**Response:**
```json
{
  "status": "success",
  "id": "123456789",
  "renewalBypass": true,
  "package": { ... },
  "extra": { ... },
  "userinfo": { ... },
  "coins": 1500
}
```

**Example:**
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "http://your-domain.com/api/v3/userinfo?id=123456789"
```

**Notes:**
- The `renewalBypass` field indicates if the user has renewal bypass:
  - `true` = User has renewal bypass (servers never expire)
  - `false` or absent = User doesn't have bypass (servers expire normally)
- Check this field before granting or to verify current status

---

## Error Handling

### Common Error Responses

**API Disabled:**
```json
{
  "status": "error",
  "message": "API is disabled"
}
```
HTTP Status: 403

**Missing Authorization:**
```json
{
  "status": "error",
  "message": "Missing authorization header"
}
```
HTTP Status: 401

**Invalid API Key:**
```json
{
  "status": "error",
  "message": "Invalid API key"
}
```
HTTP Status: 403

---

## Rate Limiting

The API may implement rate limiting to prevent abuse. Check your `config.toml` for rate limit settings.

---

## Best Practices

1. **Secure Your API Key**: Never expose your API key in client-side code or public repositories.

2. **Error Handling**: Always check the `status` field in responses before processing data.

3. **User ID Format**: Use the correct user ID format based on the authentication method:
   - Discord OAuth: Discord User ID (e.g., "849694563295690772")
   - Google OAuth: Google User ID
   - GitHub OAuth: GitHub User ID
   - Local Auth: Generated UUID

4. **Resource Limits**: When setting resources, ensure values are within reasonable ranges to prevent system issues.

5. **Logging**: All API actions are logged to Discord webhooks (if configured) for audit purposes.

---

## Examples

### Complete User Management Workflow

```bash
# 1. Check API status
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://your-domain.com/api

# 2. Get user information (includes renewal bypass status)
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "http://your-domain.com/api/v3/userinfo?id=123456789"

# 3. Check if user has renewal bypass (look for renewalBypass field in response)
# If renewalBypass is true, user has bypass
# If renewalBypass is false, user requires server renewals

# 4. Give renewal bypass to user
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/give_renewalbypass

# 5. Remove renewal bypass from user
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789"}' \
  http://your-domain.com/api/v3/remove_renewalbypass

# 6. Set user to premium package
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","package":"2"}' \
  http://your-domain.com/api/v3/setplan

# 7. Add extra resources
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","ram":2048,"disk":10240,"servers":2}' \
  http://your-domain.com/api/v3/setresources

# 8. Give coins as reward
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"123456789","coins":500}' \
  http://your-domain.com/api/v3/addcoins

# 9. Check user's recent activity
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "http://your-domain.com/api/v3/userinteractions?id=123456789&limit=20"
```

### Python Example

```python
import requests

API_KEY = "your-api-key-here"
BASE_URL = "http://your-domain.com/api"
HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# Get user info
response = requests.get(
    f"{BASE_URL}/v3/userinfo",
    headers=HEADERS,
    params={"id": "123456789"}
)
user_data = response.json()
print(f"User coins: {user_data['coins']}")
print(f"Has renewal bypass: {user_data.get('renewalBypass', False)}")

# Add coins
response = requests.post(
    f"{BASE_URL}/v3/addcoins",
    headers=HEADERS,
    json={"id": "123456789", "coins": 100}
)
print(response.json())

# Give renewal bypass
response = requests.post(
    f"{BASE_URL}/v3/give_renewalbypass",
    headers=HEADERS,
    json={"id": "123456789"}
)
print(f"Bypass granted: {response.json()}")

# Remove renewal bypass
response = requests.post(
    f"{BASE_URL}/v3/remove_renewalbypass",
    headers=HEADERS,
    json={"id": "123456789"}
)
print(f"Bypass removed: {response.json()}")

# Get user interactions
response = requests.get(
    f"{BASE_URL}/v3/userinteractions",
    headers=HEADERS,
    params={"id": "123456789", "limit": 10}
)
interactions = response.json()
print(f"Found {interactions['count']} interactions")
for interaction in interactions['interactions']:
    print(f"[{interaction['timestamp']}] {interaction['action']}")
```

### JavaScript/Node.js Example

```javascript
const axios = require('axios');

const API_KEY = 'your-api-key-here';
const BASE_URL = 'http://your-domain.com/api';
const BASE_URL_NO_API = 'http://your-domain.com';
const headers = {
  'Authorization': `Bearer ${API_KEY}`,
  'Content-Type': 'application/json'
};

// Get user info (includes renewal bypass status)
async function getUserInfo(userId) {
  try {
    const response = await axios.get(`${BASE_URL}/v3/userinfo`, {
      headers,
      params: { id: userId }
    });
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Add coins
async function addCoins(userId, amount) {
  try {
    const response = await axios.post(`${BASE_URL}/v3/addcoins`, 
      { id: userId, coins: amount },
      { headers }
    );
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Give renewal bypass
async function giveRenewalBypass(userId) {
  try {
    const response = await axios.post(`${BASE_URL}/v3/give_renewalbypass`, 
      { id: userId },
      { headers }
    );
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Remove renewal bypass
async function removeRenewalBypass(userId) {
  try {
    const response = await axios.post(`${BASE_URL}/v3/remove_renewalbypass`, 
      { id: userId },
      { headers }
    );
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Get user interactions
async function getUserInteractions(userId, limit = 15) {
  try {
    const response = await axios.get(`${BASE_URL}/v3/userinteractions`, {
      headers,
      params: { id: userId, limit }
    });
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Usage
(async () => {
  const userId = '123456789';
  
  // Get user info and check renewal bypass status
  const userInfo = await getUserInfo(userId);
  console.log('User Info:', userInfo);
  console.log(`Renewal Bypass Enabled: ${userInfo.renewalBypass}`);
  
  // Add coins
  const addResult = await addCoins(userId, 500);
  console.log('Add Coins Result:', addResult);
  
  // Give renewal bypass
  const bypassResult = await giveRenewalBypass(userId);
  console.log('Bypass Given:', bypassResult);
  
  // Verify renewal bypass was granted
  const updatedUserInfo = await getUserInfo(userId);
  console.log(`Renewal Bypass Now: ${updatedUserInfo.renewalBypass}`);
  
  // Get user interactions
  const interactions = await getUserInteractions(userId, 20);
  console.log(`Found ${interactions.count} interactions`);
  interactions.interactions.forEach(int => {
    console.log(`[${int.timestamp}] ${int.action}`);
  });
})();
```

---

## Support

For issues or questions about the API:
- Check your `config.toml` configuration
- Review the logs in `logs/combined.log`
- Ensure the API is enabled in your configuration
- Verify your API key is correct

---

## Changelog

### v3.2.1-beta.1
- Added `/api/v3/userinteractions` endpoint for retrieving user activity logs
- Improved error handling and validation
- Added ban/unban functionality
- Enhanced Discord logging for all API actions

---

**Last Updated:** December 31, 2025
