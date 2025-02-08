local HttpService = game:GetService("HttpService")
local PlayersService = game:GetService("Players")
local friendCache = {}
local requestCount = 0
local lastRequestTime = os.time()
local requestTimes = {}
local queued = {}

-- half of this script was made by chatgpt and other half by me so its all over the place SORRY!!!

local function waitForRateLimit()
	local currentTime = os.time()
	for i = #requestTimes, 1, -1 do
		if currentTime - requestTimes[i] >= 60 then
			table.remove(requestTimes, i)
		end
	end
	if #requestTimes >= 500 then
		local waitTime = 60 - (currentTime - requestTimes[1])
		print("Rate limit hit. Waiting for " .. waitTime .. " seconds...")
		wait(waitTime)
		requestTimes = {} 
	end

	table.insert(requestTimes, currentTime)
end

local function getAllFriends(userId)
	if friendCache[userId] then
		return friendCache[userId]
	end

	local FriendIDs = {}
	local success, fail = pcall(function()
		waitForRateLimit()
		local friendsList = PlayersService:GetFriendsAsync(userId)
		while true do
			for _, friend in pairs(friendsList:GetCurrentPage()) do
				table.insert(FriendIDs, friend.Id)
			end
			if not friendsList.IsFinished then
				waitForRateLimit()
				friendsList:AdvanceToNextPageAsync()
			else
				break
			end
		end
	end)

	if success then
		friendCache[userId] = FriendIDs
		return FriendIDs
	else
		warn("Failed to get friends for user " .. userId .. ": " .. tostring(fail))
		return {}
	end
end

local function findConnection(startId, targetId)
	local queueA = { startId }
	local queueB = { targetId }
	local visitedA = { [startId] = true }
	local visitedB = { [targetId] = true }
	local parentsA = { [startId] = nil }
	local parentsB = { [targetId] = nil }
	local backoffTime = 1

	while #queueA > 0 and #queueB > 0 do
		if #queueA > #queueB then
			queueA, queueB = queueB, queueA
			visitedA, visitedB = visitedB, visitedA
			parentsA, parentsB = parentsB, parentsA
		end

		local currentId = table.remove(queueA, 1)
		waitForRateLimit()
		local friends = getAllFriends(currentId)

		if #friends == 0 then
			print("No friends found or rate limit hit. Retrying in " .. backoffTime .. " seconds...")
			wait(backoffTime)
			backoffTime = math.min(backoffTime * 2, 60)
			table.insert(queueA, currentId) 
		else
			backoffTime = 1 
		end

		for _, friendId in ipairs(friends) do
			if not visitedA[friendId] then
				visitedA[friendId] = true
				parentsA[friendId] = currentId
				if visitedB[friendId] then
					local path = {}
					local node = friendId
					while node do
						table.insert(path, 1, node)
						node = parentsA[node]
					end
					node = parentsB[friendId]
					while node do
						table.insert(path, node)
						node = parentsB[node]
					end

					return path
				end

				table.insert(queueA, friendId)
			end
		end
	end

	return nil
end

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

