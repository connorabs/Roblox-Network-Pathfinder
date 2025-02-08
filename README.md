# Roblox Network Pathfinder

## Overview

This script finds the shortest connection path between two Roblox users by analyzing their friend lists. It uses a **bidirectional breadth-first search (BFS)** to efficiently explore possible links between users.

Since Roblox enforces strict rate limits (500 requests per minute), the script includes:

- **Rate limit handling** to prevent exceeding API limits.
- **Caching** to store previously retrieved friend lists.
- **Exponential backoff** for handling failed requests.

## Features

✅ **Bidirectional BFS** – Reduces search time by expanding from both start and target users.\
✅ **Friend List Caching** – Prevents redundant API calls and speeds up subsequent searches.\
✅ **Rate Limit Management** – Ensures the script waits when necessary to stay within limits.\
✅ **Retry Mechanism** – Uses exponential backoff for failed API requests.

---

## How It Works

### 1. **Rate Limit Management (**\`\`**)**

- Keeps track of the last **500 API requests**.
- If the script reaches the limit, it pauses execution until the cooldown expires.

### 2. **Fetching Friends (**\`\`**)**

- Retrieves a user’s friends using `PlayersService:GetFriendsAsync(userId)`.
- Stores results in a cache (`friendCache`) to prevent redundant requests.
- Handles pagination when fetching large friend lists.

### 3. **Finding Connections (**\`\`**)**

- Uses **bidirectional BFS**, alternating search layers between both users.
- Expands from the **smaller queue** to minimize search depth.
- If a common user is found, reconstructs the shortest path between the two.

#### **Step-by-Step Process**

1. Initializes two queues:
   - `queueA` (starting user)
   - `queueB` (target user)
2. Tracks visited users and their predecessors.
3. Expands the search one layer at a time, checking for intersections.
4. Fetches friends of the current user and adds them to the queue.
5. If a mutual friend is found, the function reconstructs the shortest path.

### 4. **Retrying on Failure**

- If a user’s friends cannot be retrieved (due to errors or rate limits),
  - The script **waits** and retries with increasing delays (`1s → 2s → 4s … max 60s`).

---

## Usage

### Example Code:

```lua
local targetuser1 = 362690
local targetuser2 = 47586595

print("Searching for connection between " .. targetuser1 .. " and " .. targetuser2)
local connectionPath = findConnection(targetuser1, targetuser2)

if connectionPath then
    print("Path found:")
    for _, playerId in ipairs(connectionPath) do
        print("UserId: " .. playerId)
    end
else
    print("No connection path found.")
end
```

### Example Output:

```
Searching for connection between 362690 and 47586595
Path found:
UserId: 362690
UserId: 1284937
UserId: 9845231
UserId: 47586595
```

(This means **User 362690 → User 1284937 → User 9845231 → User 47586595** are connected.)


---


## Installation & Setup

1. Copy and paste the script into your Roblox environment.
2. Replace `targetuser1` and `targetuser2` with the user IDs you want to check.
3. Run the script and view the results in the output.


---


## Credits

- **Author:** CNR
- **Contributors:** ChatGPT(since icba to make a documentation about how this shit works LOLOLOL)
- **Roblox API Documentation:** [developer.roblox.com](https://developer.roblox.com/)

