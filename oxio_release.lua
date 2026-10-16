local function geniter(f, s, c)
	if type(f) ~= "function" then
		local mt = getmetatable(f)

		if type(mt) == "table" and mt.__iter then
			f, s, c = mt.__iter(f)
		elseif type(f) == "table" then
			f, s, c = next, f, nil
		end
	end

	return function()
		local r = table.pack(f(s, c))

		if r[1] == nil then
			return false
		end

		c = r[1]

		return true, table.unpack(r, 1, r.n)
	end
end

local CFrame_ = CFrame
local cFrameNew = CFrame_ and CFrame_.new
local lookAt = CFrame_ and CFrame_.lookAt
local Angles = CFrame_ and CFrame_.Angles
local fromMatrix = CFrame_ and CFrame_.fromMatrix
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

game:GetService("TweenService")

local TeleportService = game:GetService("TeleportService")
local Nyx_getWorkspaceWorld, genv, Nyx_isCurrentSession, __NyxTweenRuntimeGeneration, Nyx_CONFIG, Nyx_getFps, Nyx_getTweenSpeed, Nyx_syncHoverPad, Nyx_ensureHoverPad, Nyx_destroyHoverPad
local Nyx_clearCharacterState, Nyx_setArrivalHold, Nyx_getEnv, Nyx_setTargetWalkSpeed, Nyx_applyWalkSpeedToState, Nyx_isOwnState, Nyx_isOwnStateChecked, Nyx_installIntegritySpoof, Nyx_updateIntegritySpoof, Nyx_startMovementLoop

do
	local Workspace = game:GetService("Workspace")

	Nyx_getWorkspaceWorld = function()
		return Workspace:FindFirstChild("World") or Workspace:FindFirstChild("__OBJECTS")
	end
	genv = getgenv and getgenv() or _G

	if type(genv.__NyxHubShutdown) == "function" then
		pcall(genv.__NyxHubShutdown)
	end

	local Nyx_sessionToken = {}

	genv.__NyxHubSession = Nyx_sessionToken
	Nyx_isCurrentSession = function()
		return genv.__NyxHubSession == Nyx_sessionToken
	end
	genv.__NyxIdentityGetter = genv.getthreadidentity or genv.get_thread_identity or genv.getidentity or genv.getthreadcontext or genv.get_thread_context
	genv.__NyxIdentitySetter = genv.setthreadidentity or genv.set_thread_identity or genv.setidentity or genv.setthreadcontext or genv.set_thread_context

	local __NyxIdentitySetter = genv.__NyxIdentitySetter

	if type(__NyxIdentitySetter) == "function" then
		pcall(__NyxIdentitySetter, 8)
		genv.__NyxUICapabilityIdentity = 8
	end

	if not (rawget(_G, "setfpscap") or rawget(_G, "set_fps_cap")) and type(setfpscap) == "function" then
	end

	genv.__NyxSetCapFps = function(fpsCapValue)
		local Nyx_cappedFps = math.clamp(math.floor(tonumber(fpsCapValue) or 240), 1, 999)
		local setfpscap_ = rawget(_G, "setfpscap") or rawget(_G, "set_fps_cap") or type(setfpscap) == "function" and setfpscap

		if type(setfpscap_) == "function" then
			return pcall(setfpscap_, Nyx_cappedFps)
		end

		return false
	end

	if type(genv.__NyxTweenRuntimeCleanup) == "function" then
		pcall(genv.__NyxTweenRuntimeCleanup)
	end

	if type(genv.__NyxEggRuntimeCleanup) == "function" then
		pcall(genv.__NyxEggRuntimeCleanup)
	end

	if type(genv.__NyxAntiGuardCleanup) == "function" then
		pcall(genv.__NyxAntiGuardCleanup)
	end

	genv.__NyxTweenRuntimeGeneration = (genv.__NyxTweenRuntimeGeneration or 0) + 1
	__NyxTweenRuntimeGeneration = genv.__NyxTweenRuntimeGeneration
	Nyx_CONFIG = {
		KEY = "__NyxStealAnEggMovementSpoof",
		VERSION = 436,
		INTEGRITY_KEY = "__NyxStealAnEggIntegritySpoof",
		SIGNAL = "ClientCharacter: GetDebugSnapshot",
		HEADROOM = 1.35,
		CLAMP = 0.15,
		PADDING = 24,
		MULTIPLIER = 10,
		MIN_INPUT = 20,
		MAX_INPUT = 100,
		DEF_INPUT = 60,
		MIN_SPEED = 200,
		MAX_SPEED = 1000,
		DEF_SPEED = 600,
		FIELDS = {
			"LastObservedSample",
			"LastSample",
			"LastGoodSample",
			"LastGameplayTrustedSample",
			"LastValidatedSample",
			"LastValidatedGroundedSample",
			"LastConfirmedGroundSample",
			"CandidateGroundedSample"
		}
	}

	local KEY = Nyx_CONFIG.KEY
	local VERSION = Nyx_CONFIG.VERSION
	local INTEGRITY_KEY = Nyx_CONFIG.INTEGRITY_KEY
	local SIGNAL = Nyx_CONFIG.SIGNAL
	local HEADROOM = Nyx_CONFIG.HEADROOM
	local CLAMP = Nyx_CONFIG.CLAMP
	local PADDING = Nyx_CONFIG.PADDING
	local MIN_SPEED = Nyx_CONFIG.MIN_SPEED
	local MAX_SPEED = Nyx_CONFIG.MAX_SPEED
	local DEF_SPEED = Nyx_CONFIG.DEF_SPEED
	local FIELDS = Nyx_CONFIG.FIELDS
	local Nyx_isCurrentSession_var1 = 60

	game:GetService("RunService").Heartbeat:Connect(function(dt)
		if dt and dt > 0 then
			Nyx_isCurrentSession_var1 = Nyx_isCurrentSession_var1 * 0.9 + 1 / dt * 0.1
		end
	end)
	Nyx_getFps = function()
		return Nyx_isCurrentSession_var1
	end

	local Nyx_hoverPadPart
	local Nyx_runtimeOwnerId = tostring(math.random(100000, 999999))
	local connection
	local connection2
	local Nyx_cancelledTweens = {}
	local Nyx_getFps_var1

	Nyx_getTweenSpeed = nil

	local function Nyx_purgeHoverPads()
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("BasePart") and child.Name == "__NyxHoverPad" and child ~= Nyx_hoverPadPart then
				pcall(child.Destroy, child)
			end
		end
	end

	Nyx_syncHoverPad = function(positionInput)
		if not Nyx_hoverPadPart or not Nyx_hoverPadPart.Parent then
			return false
		end

		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid then
			return false
		end

		local Nyx_resolvedTarget = typeof(positionInput) == "Vector3" and positionInput

		Nyx_resolvedTarget = Nyx_resolvedTarget or HumanoidRootPart.Position
		Nyx_hoverPadPart.CFrame = cFrameNew(Nyx_resolvedTarget.X, Nyx_resolvedTarget.Y - (Humanoid.RigType == Enum.HumanoidRigType.R15 and HumanoidRootPart.Size.Y * 0.5 + math.max(Humanoid.HipHeight, 0.5) or HumanoidRootPart.Size.Y * 0.5 + 2) - 0.5 - 0.05, Nyx_resolvedTarget.Z)

		return true
	end
	Nyx_ensureHoverPad = function()
		if not Nyx_hoverPadPart or not Nyx_hoverPadPart.Parent or Nyx_hoverPadPart:GetAttribute("NyxRuntimeOwner") ~= Nyx_runtimeOwnerId then
			Nyx_purgeHoverPads()

			if Nyx_hoverPadPart and Nyx_hoverPadPart.Parent then
				pcall(Nyx_hoverPadPart.Destroy, Nyx_hoverPadPart)
			end

			local Part = Instance.new("Part")

			Part.Name = "__NyxHoverPad"
			Part:SetAttribute("NyxRuntimeOwner", Nyx_runtimeOwnerId)
			Part.Anchored = true
			Part.CanCollide = true
			Part.CanQuery = true
			Part.CanTouch = false
			Part.CastShadow = false
			Part.Transparency = 1
			Part.Material = Enum.Material.SmoothPlastic
			Part.Size = Vector3.new(8, 1, 8)
			Nyx_hoverPadPart = Part
			Part.Parent = Workspace
		end

		Nyx_syncHoverPad()

		if not connection then
			local function Nyx_preSimHeartbeat()
				if not Nyx_syncHoverPad() then
					Nyx_ensureHoverPad()
				end
			end

			connection = RunService.PreSimulation:Connect(Nyx_preSimHeartbeat)
		end

		if not connection2 then
			connection2 = RunService.PostSimulation:Connect(function()
				Nyx_syncHoverPad()
			end)
		end
	end
	Nyx_destroyHoverPad = function()
		if connection then
			pcall(connection.Disconnect, connection)
			connection = nil
		end

		if connection2 then
			pcall(connection2.Disconnect, connection2)
			connection2 = nil
		end

		if Nyx_hoverPadPart then
			pcall(Nyx_hoverPadPart.Destroy, Nyx_hoverPadPart)
			Nyx_hoverPadPart = nil
		end

		Nyx_purgeHoverPads()
	end
	Nyx_destroyHoverPad()
	Nyx_clearCharacterState = function()
		Nyx_getFps_var1 = nil
	end
	Nyx_setArrivalHold = function(rootPart, targetCFrame)
		if rootPart and typeof(targetCFrame) == "CFrame" then
			Nyx_getFps_var1 = {
				Character = LocalPlayer.Character,
				RootPart = rootPart,
				CFrame = targetCFrame
			}
		end
	end

	local function Nyx_applyArrivalHold()
		local Nyx_pendingArrivalHold = Nyx_getFps_var1

		if type(Nyx_pendingArrivalHold) == "table" then
			if typeof(Nyx_pendingArrivalHold.CFrame) == "CFrame" then
				if LocalPlayer.Character == Nyx_pendingArrivalHold.Character then
					if Nyx_pendingArrivalHold.RootPart and Nyx_pendingArrivalHold.RootPart.Parent then
						Nyx_ensureHoverPad()
						Nyx_pendingArrivalHold.RootPart.AssemblyLinearVelocity = Vector3.zero
						Nyx_pendingArrivalHold.RootPart.AssemblyAngularVelocity = Vector3.zero
						Nyx_syncHoverPad(Nyx_pendingArrivalHold.CFrame.Position)
						Nyx_pendingArrivalHold.RootPart.CFrame = Nyx_pendingArrivalHold.CFrame
						Nyx_syncHoverPad(Nyx_pendingArrivalHold.CFrame.Position)

						return true
					end
				end

				Nyx_getFps_var1 = nil

				return false
			end
		end

		return false
	end
	local function Nyx_cleanupAllState()
		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character

		HumanoidRootPart = HumanoidRootPart and Character:FindFirstChild("HumanoidRootPart")

		for _, v in pairs(Nyx_cancelledTweens) do
			if type(v) == "table" then
				v.cancelled = true
			end
		end

		table.clear(Nyx_cancelledTweens)

		if HumanoidRootPart then
			HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
			HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
		end

		Nyx_clearCharacterState()
		Nyx_destroyHoverPad()
	end

	genv.__NyxTweenRuntimeCleanup = function()
		for _, v in pairs(Nyx_cancelledTweens) do
			if type(v) == "table" then
				v.cancelled = true
			end
		end

		table.clear(Nyx_cancelledTweens)
		Nyx_clearCharacterState()
		Nyx_destroyHoverPad()
	end
	Nyx_getEnv = function()
		return getgenv and getgenv() or _G
	end

	local function Nyx_getOrInitSpoof()
		local Nyx_envRef = Nyx_getEnv()
		local Nyx_stateConfig = Nyx_envRef[KEY]

		if type(Nyx_stateConfig) ~= "table" or Nyx_stateConfig.Version ~= VERSION then
			if type(Nyx_stateConfig) == "table" then
				Nyx_stateConfig.Enabled = false
			end

			Nyx_stateConfig = {
				Version = VERSION,
				Installed = false,
				Enabled = false,
				Mode = "StateBaseline",
				Humanoid = nil,
				RootPart = nil,
				WalkSpeed = DEF_SPEED
			}
			Nyx_envRef[KEY] = Nyx_stateConfig
		end

		return Nyx_stateConfig
	end

	Nyx_setTargetWalkSpeed = function(character, walkSpeedValue)
		local Nyx_stateConfigInst = Nyx_getOrInitSpoof()

		if not Nyx_stateConfigInst then
			return false
		end

		local Humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local HumanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		Nyx_stateConfigInst.Humanoid = Humanoid
		Nyx_stateConfigInst.RootPart = HumanoidRootPart
		Nyx_stateConfigInst.WalkSpeed = math.clamp(tonumber(walkSpeedValue) or DEF_SPEED, MIN_SPEED, MAX_SPEED * HEADROOM)
		Nyx_stateConfigInst.Enabled = false

		return Humanoid ~= nil and HumanoidRootPart ~= nil
	end

	local function Nyx_resetStateConfig()
		local Nyx_cleanupEnvState = Nyx_getEnv()[KEY]

		if type(Nyx_cleanupEnvState) == "table" then
			Nyx_cleanupEnvState.Enabled = false
			Nyx_cleanupEnvState.Humanoid = nil
			Nyx_cleanupEnvState.RootPart = nil
		end
	end
	local function Nyx_findStateByDeepSearch(player, humanoid, rootPart)
		local Nyx_findStateByDeepSearch_var1

		if type(getcallbackvalue) == "function" and type(debug) == "table" and type(debug.getupvalue) == "function" then
			local Signal = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Signal")

			if Signal then
				local ok, result = pcall(require, Signal)

				if ok and type(result) == "table" and type(result.Invoked) == "function" then
					local ok2, result2 = pcall(result.Invoked, SIGNAL)

					if ok2 and result2 then
						local ok3, result3 = pcall(getcallbackvalue, result2, "OnInvoke")

						if ok3 and type(result3) == "function" then
							local ok4, result4 = pcall(debug.getinfo, result3)

							if ok4 then
								local function Nyx_walkTableDeep(tableInput, depth, visited)
									if Nyx_findStateByDeepSearch_var1 or type(tableInput) ~= "table" or depth > 3 or visited[tableInput] then
										return
									end

									visited[tableInput] = true

									if rawget(tableInput, "Player") == player and rawget(tableInput, "Character") == player.Character then
										if rawget(tableInput, "Humanoid") == humanoid and rawget(tableInput, "RootPart") == rootPart and type(rawget(tableInput, "SampleHistory")) == "table" and type(rawget(tableInput, "Evidence")) == "table" then
											Nyx_findStateByDeepSearch_var1 = tableInput

											return
										end
									end

									local Nyx_walkTableDeep_var1 = 0

									for _, v in pairs(tableInput) do
										Nyx_walkTableDeep_var1 += 1

										if Nyx_walkTableDeep_var1 > 128 then
											break
										end

										if type(v) == "table" then
											Nyx_walkTableDeep(v, depth + 1, visited)
										end
									end
								end

								local Nyx_walkTableDeep_var2 = 1
								local nups = result4.nups or 0

								for i = Nyx_walkTableDeep_var2, nups do
									local ok5, result5 = pcall(debug.getupvalue, result3, i)

									if not ok5 or type(result5) ~= "table" then
										continue
									end

									Nyx_walkTableDeep(result5, 0, {})

									if Nyx_findStateByDeepSearch_var1 then
										break
									end
								end
							end
						end
					end
				end
			end
		end

		if not Nyx_findStateByDeepSearch_var1 and type(getgc) == "function" then
			local ok, result = pcall(getgc, true)

			if ok and type(result) == "table" then
				for _, v in ipairs(result) do
					if type(v) == "table" and rawget(v, "Player") == player and rawget(v, "Character") == player.Character and rawget(v, "Humanoid") == humanoid and rawget(v, "RootPart") == rootPart and type(rawget(v, "SampleHistory")) == "table" and type(rawget(v, "Evidence")) == "table" then
						Nyx_findStateByDeepSearch_var1 = v

						break
					end
				end
			end
		end

		return Nyx_findStateByDeepSearch_var1
	end

	local Nyx_stateFinder = {
		busy = false,
		nextAt = 0,
		misses = 0,
		found = nil
	}

	local function Nyx_findStateViaGc(player, humanoid, rootPart)
		local found = Nyx_stateFinder.found

		if type(found) == "table" and rawget(found, "Player") == player then
			if rawget(found, "Character") == player.Character and rawget(found, "Humanoid") == humanoid and rawget(found, "RootPart") == rootPart then
				return found
			end
		end

		if Nyx_stateFinder.busy or os.clock() < Nyx_stateFinder.nextAt then
			return nil
		end

		Nyx_stateFinder.busy = true
		task.spawn(function()
			task.wait()

			local ok, result = pcall(Nyx_findStateByDeepSearch, player, humanoid, rootPart)
			local Nyx_stateSearchResult = ok and result or nil

			Nyx_stateFinder.found = Nyx_stateSearchResult
			Nyx_stateFinder.misses = Nyx_stateSearchResult and 0 or Nyx_stateFinder.misses + 1
			Nyx_stateFinder.nextAt = os.clock() + (Nyx_stateSearchResult and 0.2 or Nyx_stateFinder.misses >= 5 and 10 or 1)
			Nyx_stateFinder.busy = false
		end)

		return nil
	end

	Nyx_applyWalkSpeedToState = function(stateTable, walkSpeed, velocity)
		if type(stateTable) ~= "table" then
			return false
		end

		local value = rawget(stateTable, "RootPart")
		local CFrame_2 = value and value.Parent and value.CFrame or nil
		local Position = CFrame_2 and CFrame_2.Position or nil
		local vector3 = typeof(velocity) == "Vector3" and velocity or Vector3.zero

		local function Nyx_applySpeedToSamples(sampleTable)
			if type(sampleTable) == "table" then
				rawset(sampleTable, "WalkSpeed", walkSpeed)

				if CFrame_2 then
					rawset(sampleTable, "CFrame", CFrame_2)
					rawset(sampleTable, "Position", Position)
					rawset(sampleTable, "LinearVelocity", vector3)
					rawset(sampleTable, "AngularVelocity", Vector3.zero)
				end
			end
		end

		for _, v in ipairs(FIELDS) do
			Nyx_applySpeedToSamples(rawget(stateTable, v))
		end

		local pairs_ = pairs
		local Nyx_sampleHistoryTable = rawget(stateTable, "SampleHistory") or {}

		for _, v in pairs_(Nyx_sampleHistoryTable) do
			Nyx_applySpeedToSamples(v)
		end

		local pairs_2 = pairs
		local Nyx_safeGroundCheckpoints = rawget(stateTable, "SafeGroundCheckpoints") or {}

		for _, v in pairs_2(Nyx_safeGroundCheckpoints) do
			Nyx_applySpeedToSamples(v)
		end

		local value2 = rawget(stateTable, "Evidence")

		if type(value2) == "table" then
			value2.Speed = 0
			value2.Teleport = 0
			value2.Flight = 0
		end

		local value3 = rawget(stateTable, "ImpulseContext")

		if type(value3) == "table" then
			local maxHorizontalSpeed = math.max(tonumber(value3.MaxHorizontalSpeed) or 0, walkSpeed)
			local Nyx_impulseDuration = math.max((tonumber(value3.ExpiresAt) or 0) - (tonumber(value3.StartedAt) or 0), CLAMP)

			value3.MaxHorizontalSpeed = maxHorizontalSpeed

			if Position then
				value3.OriginPosition = Position
			end

			value3.MaxHorizontalDistance = math.max(tonumber(value3.MaxHorizontalDistance) or 0, maxHorizontalSpeed * Nyx_impulseDuration + PADDING * 2)
			Nyx_applySpeedToSamples(value3.PreMovementSafeSample)
		end

		if rawget(stateTable, "CorrectionContext") == nil then
			rawset(stateTable, "FirstSuspiciousAt", nil)

			if rawget(stateTable, "ThreatLevel") == "Observing" then
				rawset(stateTable, "ThreatLevel", "Trusted")
			end
		end

		return true
	end

	local function Nyx_getIntegrityState()
		local Nyx_envRef2 = Nyx_getEnv()
		local Nyx_integritySpoofTable = Nyx_envRef2[INTEGRITY_KEY]

		if type(Nyx_integritySpoofTable) ~= "table" then
			Nyx_integritySpoofTable = {}
			Nyx_envRef2[INTEGRITY_KEY] = Nyx_integritySpoofTable
		end

		return Nyx_integritySpoofTable
	end

	Nyx_isOwnState = function(state, humanoid, rootPart)
		return type(state) == "table" and rawget(state, "Player") == LocalPlayer and rawget(state, "Character") == LocalPlayer.Character and rawget(state, "Humanoid") == humanoid and rawget(state, "RootPart") == rootPart
	end
	Nyx_isOwnStateChecked = function(state, humanoid, rootPart)
		return Nyx_isOwnState(state, humanoid, rootPart)
	end
	Nyx_installIntegritySpoof = function(state, humanoid, rootPart)
		local Nyx_integritySpoof = Nyx_getIntegrityState()
		local State = Nyx_integritySpoof.State

		if not Nyx_isOwnState(State, state, humanoid) then
			local now = os.clock()

			if now < (Nyx_integritySpoof.NextSearchAt or 0) then
				return false
			end

			Nyx_integritySpoof.NextSearchAt = now + 0.2
			State = Nyx_findStateViaGc(LocalPlayer, state, humanoid)
		end

		if not State then
			return false
		end

		if not Nyx_isOwnStateChecked(State, state, humanoid) then
			Nyx_integritySpoof.Enabled = false
			Nyx_integritySpoof.Humanoid = state
			Nyx_integritySpoof.RootPart = humanoid
			Nyx_integritySpoof.State = State

			return false
		end

		Nyx_integritySpoof.NextSearchAt = 0
		Nyx_integritySpoof.Enabled = true
		Nyx_integritySpoof.Humanoid = state
		Nyx_integritySpoof.RootPart = humanoid
		Nyx_integritySpoof.State = State
		Nyx_integritySpoof.WalkSpeed = math.clamp(rootPart * HEADROOM, MIN_SPEED, MAX_SPEED * HEADROOM)
		Nyx_integritySpoof.TravelVelocity = Vector3.zero
		Nyx_applyWalkSpeedToState(State, Nyx_integritySpoof.WalkSpeed, Nyx_integritySpoof.TravelVelocity)

		return true
	end
	Nyx_updateIntegritySpoof = function(humanoid, rootPart, walkSpeed, travelVelocity)
		local Nyx_integritySpoofCheck = Nyx_getEnv()[INTEGRITY_KEY]

		if type(Nyx_integritySpoofCheck) == "table" and Nyx_integritySpoofCheck.Enabled and Nyx_integritySpoofCheck.Humanoid == humanoid and Nyx_integritySpoofCheck.RootPart == rootPart then
			if Nyx_isOwnStateChecked(Nyx_integritySpoofCheck.State, humanoid, rootPart) then
				Nyx_integritySpoofCheck.WalkSpeed = math.clamp(walkSpeed * HEADROOM, MIN_SPEED, MAX_SPEED * HEADROOM)

				if typeof(travelVelocity) == "Vector3" then
					Nyx_integritySpoofCheck.TravelVelocity = travelVelocity
				elseif typeof(Nyx_integritySpoofCheck.TravelVelocity) ~= "Vector3" then
					Nyx_integritySpoofCheck.TravelVelocity = Vector3.zero
				end

				return Nyx_applyWalkSpeedToState(Nyx_integritySpoofCheck.State, Nyx_integritySpoofCheck.WalkSpeed, Nyx_integritySpoofCheck.TravelVelocity)
			end
		end

		return false
	end

	local function Nyx_clearIntegritySpoof(humanoid)
		local Nyx_integritySpoofActive = Nyx_getEnv()[INTEGRITY_KEY]

		if type(Nyx_integritySpoofActive) ~= "table" then
			return
		end

		if humanoid == nil or Nyx_integritySpoofActive.Humanoid == humanoid then
			Nyx_integritySpoofActive.Enabled = false
			Nyx_integritySpoofActive.Humanoid = nil
			Nyx_integritySpoofActive.RootPart = nil
			Nyx_integritySpoofActive.State = nil
			Nyx_integritySpoofActive.TravelVelocity = nil
			Nyx_integritySpoofActive.NextSearchAt = 0
		end
	end

	local connection3

	Nyx_startMovementLoop = function()
		if connection3 then
			return
		end

		connection3 = RunService.PreSimulation:Connect(function()
			if genv.__NyxTweenRuntimeGeneration ~= __NyxTweenRuntimeGeneration then
				local Nyx_preSimConnection = connection3

				connection3 = nil

				if Nyx_preSimConnection then
					pcall(Nyx_preSimConnection.Disconnect, Nyx_preSimConnection)
				end

				return
			end

			local Character = LocalPlayer.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not Character or not HumanoidRootPart or not Humanoid then
				return
			end

			local Nyx_tweenSpeedResolved = Nyx_getTweenSpeed()

			Nyx_setTargetWalkSpeed(Character, Nyx_tweenSpeedResolved * HEADROOM)

			if not Nyx_updateIntegritySpoof(Humanoid, HumanoidRootPart, Nyx_tweenSpeedResolved) then
				Nyx_installIntegritySpoof(Humanoid, HumanoidRootPart, Nyx_tweenSpeedResolved)
			end

			Nyx_applyArrivalHold()
		end)
	end

	local function Nyx_stopMovementLoop()
		if connection3 then
			pcall(connection3.Disconnect, connection3)
			connection3 = nil
		end

		Nyx_resetStateConfig()
		Nyx_clearIntegritySpoof()
	end

	genv.__NyxTweenRuntimeCleanup = function()
		Nyx_cleanupAllState()
		Nyx_stopMovementLoop()
	end
end

RunService.Heartbeat:Connect(function()
	local Character = LocalPlayer.Character
	local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return
	end

	local AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity

	if Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude > 400 or math.abs(AssemblyLinearVelocity.Y) > 400 then
		HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(math.clamp(AssemblyLinearVelocity.X, -100, 100), math.clamp(AssemblyLinearVelocity.Y, -100, 100), math.clamp(AssemblyLinearVelocity.Z, -100, 100))
	end
end)
pcall(function()
	local queue_on_teleport_ = queue_on_teleport or queueonteleport

	queue_on_teleport_ = queue_on_teleport_ or syn and syn.queue_on_teleport

	if queue_on_teleport_ then
		pcall(queue_on_teleport_, "")
	end
end)

do
	pcall(function()
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	end)
end

do
	local connection
	local connection2

	local function Nyx_healthPinSetup(character)
		if not character then
			return
		end

		local Humanoid = character:WaitForChild("Humanoid", 5) or character:FindFirstChildOfClass("Humanoid")

		if not character:WaitForChild("HumanoidRootPart", 5) then
			character:FindFirstChild("HumanoidRootPart")
		end

		if not Humanoid then
			return
		end

		local health = math.max(Humanoid.MaxHealth, 100)
		local Nyx_healthPinSetup_var2 = false
		local Nyx_healthPinSetup_var1 = 0

		local function Nyx_healthPinCallback()
			if Nyx_healthPinSetup_var2 or not Humanoid.Parent then
				return
			end

			local now = os.clock()

			if now - Nyx_healthPinSetup_var1 < 0.1 then
				if Humanoid.Health > 0 then
					if Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
						return
					end
				end
			end

			Nyx_healthPinSetup_var1 = now
			Nyx_healthPinSetup_var2 = true
			pcall(function()
				Humanoid.BreakJointsOnDeath = false
				Humanoid.RequiresNeck = false
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

				if Humanoid.Health <= 0 then
					Humanoid.Health = health
				end

				if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
					Humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end
			end)
			Nyx_healthPinSetup_var2 = false
		end

		Nyx_healthPinCallback()

		if connection then
			pcall(connection.Disconnect, connection)
		end

		if connection2 then
			pcall(connection2.Disconnect, connection2)
		end

		connection = Humanoid.HealthChanged:Connect(function(health2)
			if health2 <= 0 or health2 < health then
				Nyx_healthPinCallback()
			end
		end)
		connection2 = RunService.Heartbeat:Connect(Nyx_healthPinCallback)
	end

	task.spawn(function()
		Nyx_healthPinSetup(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
	end)
	LocalPlayer.CharacterAdded:Connect(function(character)
		Nyx_healthPinSetup(character)
	end)
end

local NyxConfig = {
	AutoSteal = false,
	HelpFriend = false,
	ScrambleTradeInTrade = false,
	ScrambleTradeInReroll = false,
	ScrambleTradeInBanners = {},
	ScrambleBossAuto = false,
	StealMode = "Fly",
	FlyAerial = false,
	StealHoldSeconds = 5,
	StealAreas = { "None" },
	StealRarities = { "None" },
	StealNamesFilter = { "None" },
	StealMinValue = 0,
	StealMutations = { "None" },
	StealMinWeight = 0,
	StealPriority = "Rarity",
	AutoFavorite = false,
	FavMode = "Rarity",
	FavRarities = { "None" },
	FavSpecies = { "None" },
	AutoEquipBest = false,
	AutoClaimOffline = false,
	AutoBaseUpgrade = false,
	AutoClaimAlmanac = false,
	AutoFusePets = false,
	ScrambleFarmDrones = false,
	ScrambleLostParts = false,
	ScrambleCollectSamples = false,
	ScrambleAutoVault = false,
	ScrambleAutoBuy = false,
	ScrambleAreas = {},
	ScrambleDroneTypes = {},
	ScrambleBuyList = {},
	ButterflyAutoNet = false,
	ButterflyAutoCatch = false,
	ButterflyEsp = false,
	ButterflyTiers = {},
	ButterflyAutoTrade = false,
	ButterflyTradeRecipe = "All",
	ButterflyCatchMode = "Tween",
	ButterflyAutoCraft = false,
	Noclip = false,
	BottingMode = false,
	AntiCutscene = false,
	FuseSelectedOnly = false,
	FuseRarities = { "None" },
	FuseSpecies = { "None" },
	EspDetails = {
		"Name",
		"Rarity",
		"Value"
	},
	BackpackRateEsp = false,
	AntiAFK = true,
	AutoReconnect = true,
	AutoExecute = false,
	AutoPlace = false,
	PlaceRarities = { "None" },
	AutoHatch = false,
	SellAll = false,
	AutoSell = false,
	SellNames = { "None" },
	SellRarities = { "None" },
	AutoSellEgg = false,
	SellEggRarities = { "None" },
	WebhookEnabled = false,
	WebhookURL = "",
	TweenSpeedMultiplier = 60,
	AutoTreadmillIdle = false,
	AutoTreadmillUpgrade = false,
	AntiTreadmill = false,
	HopNoMatch = false,
	PrivateServerMax = "2",
	PrivateServerAuto = false,
	HopCooldown = 5,
	AutoIndex = false,
	AntiHitGuard = false,
	FlyForCapture = false,
	AutoStealCapture = false,
	InstantGrab = false,
	InfiniteJump = false,
	WalkSpeedMultiplier = 1,
	AntiGuardKnockback = true,
	GodMode = true,
	EggPredictUI = false,
	EggESP = false,
	StealPlayers = false,
	StealPlayerRarities = { "None" },
	StealPlayerMinValue = 0,
	StealPlayerTarget = "Any Player",
	WebhookRarities = { "None" },
	WebhookMinValue = 0
}
local EggState = require(game:GetService("ReplicatedStorage").Client.EggState)

EggState.GetAreaEggSnapshot = EggState.ReadFieldEggs
EggState.GetAreaEggRecord = EggState.ReadFieldEgg
EggState.RequestAreaEggSnapshot = EggState.SyncFieldEggs
EggState.RequestCarryAreaEgg = EggState.CarryFieldEgg
EggState.RequestDropHeldAreaEgg = EggState.DropFieldEgg
EggState.AreaEggCarryStateChanged = EggState.CarryChanged
EggState.AreaEggClaimed = EggState.FieldClaimed
EggState.AreaEggUpdated = EggState.FieldShifted
EggState.AreaEggRemoved = EggState.FieldGone
EggState.GetOwnerRuntimeRecords = EggState.ReadOwnerEggs
EggState.RequestEquipTool = EggState.WearEggTool
EggState.RequestPlaceEgg = EggState.PlantEgg
EggState.RequestHatchEgg = EggState.BeginHatch
EggState.RequestCompleteHatchEgg = EggState.FinishHatch
EggState.RequestRuntimeSnapshot = EggState.SyncOwnedEggs
EggState.RuntimeOwnerUpdated = EggState.OwnerRefreshed
EggState.RuntimeOwnerCleared = EggState.OwnerCleared

local PlotState = require(game:GetService("ReplicatedStorage").Client.PlotState)

PlotState.GetMySlot = PlotState.ResolveLocalSlot
PlotState.GetPlotsFolder = PlotState.ResolveFolder
PlotState.IsWorldPositionWithinLocalPlotBounds = PlotState.ContainsLocalPoint
PlotState.GetPlotData = PlotState.ResolvePlot

local AreaEggResetWall = require(game:GetService("ReplicatedStorage").Client.AreaEggResetWall)

AreaEggResetWall.IsClosed = AreaEggResetWall.IsSealed
Nyx_getTweenSpeed = function()
	if genv.__NyxAdminBoost == true then
		return 4000
	end

	return math.clamp(math.floor((tonumber(NyxConfig.TweenSpeedMultiplier) or Nyx_CONFIG.DEF_INPUT) + 0.5), Nyx_CONFIG.MIN_INPUT, Nyx_CONFIG.MAX_INPUT) * Nyx_CONFIG.MULTIPLIER
end
NyxConfig.applyStealValueInput = function(cfgTable, inputValue)
	local lower = string.lower
	local tostring_ = tostring
	local Nyx_cleanedInputValue = lower(tostring_(inputValue or "")):gsub("[%s,]", "")

	if Nyx_cleanedInputValue == "" then
		cfgTable.StealMinValue = 0

		return true
	end

	local Nyx_parsedNumber, Nyx_parsedUnit = string.match(Nyx_cleanedInputValue, "^([%d]+%.?[%d]*)([kmb]?)$")
	local Nyx_parsedNumberValue = tonumber(Nyx_parsedNumber)

	if not Nyx_parsedNumberValue then
		return false
	end

	local Nyx_getTweenSpeed_var1 = 1

	if Nyx_parsedUnit == "k" then
		Nyx_getTweenSpeed_var1 = 1000
	elseif Nyx_parsedUnit == "m" then
		Nyx_getTweenSpeed_var1 = 1000000
	elseif Nyx_parsedUnit == "b" then
		Nyx_getTweenSpeed_var1 = 1e9
	end

	cfgTable.StealMinValue = Nyx_parsedNumberValue * Nyx_getTweenSpeed_var1

	return true
end
NyxConfig.getAreaEggValue = function(runtime, record)
	if not runtime._assetGenerationUtil then
		runtime._assetGenerationUtil = require(game:GetService("ReplicatedStorage").Shared.Util.AssetEarnings)
	end

	return runtime._assetGenerationUtil.MutationOnlyRatePerSecond({
		Category = record.AssetCategory,
		Scale = record.AssetScale or 1,
		Mutations = record.Mutations or {},
		BaseMutation = record.BaseMutation,
		EyeColor = record.AssetEyeColor,
		ColorSeed = record.AssetColorSeed,
		ColorIndex = record.AssetColorIndex,
		Gender = record.Gender,
		Personality = record.Personality or "Normal",
		HasBeenFirstPlaced = record.HasBeenFirstPlaced == true
	})
end

local function Nyx_setStealPriorityUntil(seconds)
	local max = math.max
	local StealPriorityUntil = NyxConfig.StealPriorityUntil or 0

	NyxConfig.StealPriorityUntil = max(StealPriorityUntil, os.clock() + (seconds or 5))
end

local AreaEggCycle
local AreaEggResetWall2

pcall(function()
	AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
	AreaEggResetWall2 = require(ReplicatedStorage.Client.AreaEggResetWall)
end)

local function Nyx_isNightPhase()
	if AreaEggCycle then
		if type(AreaEggCycle.IsNightPhase) == "function" then
			local ok, result = pcall(AreaEggCycle.IsNightPhase, workspace:GetServerTimeNow())

			if ok then
				if result == true then
					return true
				end
			end
		end
	end

	if AreaEggResetWall2 then
		if type(AreaEggResetWall2.IsSealed) == "function" then
			local ok, result = pcall(AreaEggResetWall2.IsSealed)

			if ok and result == true then
				return true
			end
		end

		if type(AreaEggResetWall2.IsClosed) == "function" then
			local ok, result = pcall(AreaEggResetWall2.IsClosed)

			if ok and result == true then
				return true
			end
		end
	end

	return false
end

do
	local Nyx_isNightPhase_var1 = 0
	local Nyx_isNightPhase_var2 = false

	local function Nyx_checkHighTierEggs()
		if Nyx_isNightPhase() then
			return false
		end

		local now = os.clock()

		if now - Nyx_isNightPhase_var1 < 0.35 then
			return Nyx_isNightPhase_var2
		end

		Nyx_isNightPhase_var1 = now

		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local Nyx_checkHighTierEggs_var1 = require(ReplicatedStorage2.Client.EggState).GetAreaEggSnapshot()
		local Directory = require(ReplicatedStorage2.Data.Assets).Directory
		local pairs_ = pairs
		local Records = Nyx_checkHighTierEggs_var1 and Nyx_checkHighTierEggs_var1.Records or {}

		for _, Record in pairs_(Records) do
			if Record.State ~= "Slot" and Record.State ~= "Dropped" or not Record.BottomCFrame then
				continue
			end

			local Nyx_assetDirectory = Directory[Record.AssetCategory]
			local Rarity = Nyx_assetDirectory and Nyx_assetDirectory.Rarity
			local DisplayName = Rarity and (Rarity.DisplayName or Rarity._id)

			if DisplayName ~= "Eternal" and DisplayName ~= "Divine" then
				continue
			end

			Nyx_isNightPhase_var2 = true

			return true
		end

		Nyx_isNightPhase_var2 = false

		return false
	end
end

local function Nyx_isSafeToSteal()
	if NyxConfig.IsStealing then
		return false
	end

	local __NyxDronesWantCharacter = genv.__NyxDronesWantCharacter

	if __NyxDronesWantCharacter and __NyxDronesWantCharacter() then
		return false
	end

	if NyxConfig.IsPlacing == true then
		return false
	end

	if NyxConfig.AutoSteal then
		return os.clock() >= (NyxConfig.StealPriorityUntil or 0)
	end

	return true
end

do
	local function Nyx_logDisconnect(logMessage)
		pcall(function()
			if typeof(writefile) ~= "function" then
				return
			end

			local Nyx_logDisconnect_var1 = ""

			if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile("Nyx_Disconnect_Log.txt") then
				Nyx_logDisconnect_var1 = readfile("Nyx_Disconnect_Log.txt") or ""
			end

			local Nyx_logBuffer = {}

			for match in Nyx_logDisconnect_var1:gmatch("[^\r\n]+") do
				table.insert(Nyx_logBuffer, match)
			end

			local Nyx_logDisconnect_var2 = "] " .. logMessage

			table.insert(Nyx_logBuffer, "[" .. os.date("%Y-%m-%d %H:%M:%S") .. Nyx_logDisconnect_var2)

			while #Nyx_logBuffer > 50 do
				table.remove(Nyx_logBuffer, 1)
			end

			writefile("Nyx_Disconnect_Log.txt", table.concat(Nyx_logBuffer, "\n"))
		end)
	end
end

local function Nyx_logDisconnect_var3(valueObject)
	if not valueObject or type(valueObject.GetValue) ~= "function" then
		return nil
	end

	local ok, result = pcall(function()
		return valueObject:GetValue()
	end)

	if not ok then
		return nil
	end

	if type(result) ~= "table" then
		if type(result) == "string" then
			return { result }
		end

		return nil
	end

	local Nyx_logLines = {}

	for k, v in pairs(result) do
		if type(k) == "number" then
			table.insert(Nyx_logLines, v)
		elseif type(k) == "string" and v == true then
			table.insert(Nyx_logLines, k)
		end
	end

	return Nyx_logLines
end
local function Nyx_isFilterMatch(eggName, eggRarity, nameList, rarityList)
	if NyxConfig.SellAll then
		return true
	end

	if type(nameList) ~= "table" or type(rarityList) ~= "table" then
		return false
	end

	local Nyx_isFilterMatch_var1 = false

	if not (#nameList == 0 or table.find(nameList, "None")) then
		if table.find(nameList, "All") then
			Nyx_isFilterMatch_var1 = true
		else
			Nyx_isFilterMatch_var1 = table.find(nameList, eggName) ~= nil
		end
	end

	local Nyx_isFilterMatch_var2 = false

	if #rarityList ~= 0 and not table.find(rarityList, "None") then
		if table.find(rarityList, "All") then
			Nyx_isFilterMatch_var2 = true
		else
			Nyx_isFilterMatch_var2 = table.find(rarityList, eggRarity) ~= nil
		end
	end

	return Nyx_isFilterMatch_var1 or Nyx_isFilterMatch_var2
end
local function Nyx_isRarityInList(nameInput, listInput)
	if type(listInput) ~= "table" then
		return false
	end

	if #listInput ~= 0 then
		if not table.find(listInput, "None") then
			if table.find(listInput, "All") then
				return true
			end

			return table.find(listInput, nameInput) ~= nil
		end
	end

	return false
end
local function Nyx_purgeTrapsOnCharacter(character)
	local HumanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if HumanoidRootPart then
		HumanoidRootPart:SetAttribute("KillPartIgnore", true)
	end
end

local vector3 = Vector3.new(544.76, 71.5, -416.48)
local Nyx_carryTimings = {
	CarryRetry = 0.25,
	CarryTimeout = 2,
	EarlyCarryDistance = 8,
	SafeStable = 0.35,
	ReturnValidation = 0.08,
	NextTarget = 0.05,
	SafeHandoff = 0.15
}
local Nyx_guardSpeeds = {
	GUARD_MARGIN = 1.25,
	GUARD_FALLBACK = 222,
	maxGuardWalkSpeed = nil,
	floorNotifiedFor = -1,
	capNotifiedFor = -1
}

local function Nyx_getGuardEscapeSpeed()
	if not Nyx_guardSpeeds.maxGuardWalkSpeed then
		local ok, result = pcall(function()
			return require(game:GetService("ReplicatedStorage").Data.Guards).GetHighestWalkSpeed()
		end)

		Nyx_guardSpeeds.maxGuardWalkSpeed = ok and type(result) == "number" and result > 0 and result or Nyx_guardSpeeds.GUARD_FALLBACK
		warn(string.format("[GuardEscape] Guard tercepat %d stud/detik -> lantai kabur %d stud/detik", Nyx_guardSpeeds.maxGuardWalkSpeed, Nyx_guardSpeeds.maxGuardWalkSpeed * Nyx_guardSpeeds.GUARD_MARGIN))
	end

	return Nyx_guardSpeeds.maxGuardWalkSpeed * Nyx_guardSpeeds.GUARD_MARGIN
end
local function Nyx_setTweenSpeedMultiplier(inputValue)
	local tweenSpeedMultiplier = math.clamp(math.floor((tonumber(inputValue) or Nyx_CONFIG.DEF_INPUT) + 0.5), Nyx_CONFIG.MIN_INPUT, Nyx_CONFIG.MAX_INPUT)

	if math.abs((NyxConfig.TweenSpeedMultiplier or 0) - tweenSpeedMultiplier) <= 0.001 then
		return
	end

	NyxConfig.TweenSpeedMultiplier = tweenSpeedMultiplier
end
local function Nyx_glideRootLegacy(rootPart, targetCFrame, timeout, cancelCheck)
	local Nyx_glideDeadline = os.clock() + timeout
	local now
	local Nyx_glideRootLegacy_var1 = 0
	local Nyx_glideRootLegacy_var2 = 0.1

	pcall(function()
		Nyx_glideRootLegacy_var2 = LocalPlayer:GetNetworkPing()
	end)

	local Nyx_settleThreshold = math.clamp(Nyx_glideRootLegacy_var2 * 2 + 0.2, 0.4, 1)

	while true do
		if not (os.clock() < Nyx_glideDeadline) then
			return false
		end

		if cancelCheck and cancelCheck() then
			break
		end

		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		RunService.Heartbeat:Wait()

		if not ((rootPart.Parent and (rootPart.Position - targetCFrame.Position).Magnitude or math.huge) <= 1.5) then
			now = nil
			Nyx_glideRootLegacy_var1 = 0

			continue
		end

		rootPart.CFrame = targetCFrame
		now = now or os.clock()
		Nyx_glideRootLegacy_var1 += 1

		if not (Nyx_glideRootLegacy_var1 >= 3) or not (Nyx_settleThreshold <= os.clock() - now) then
			continue
		end

		return true
	end

	return false
end

local Nyx_activeTweens = {}

local function Nyx_glideTo(rootPart, humanoid, targetCFrame, cancelCheck, onArrival, onEarlyCarry, allowAerial)
	if not rootPart or not humanoid or typeof(targetCFrame) ~= "CFrame" then
		return false
	end

	if cancelCheck and cancelCheck() then
		return false
	end

	local Nyx_previousTweenHandle = Nyx_activeTweens[rootPart]

	if Nyx_previousTweenHandle then
		Nyx_previousTweenHandle.cancelled = true
		Nyx_activeTweens[rootPart] = nil
	end

	local Parent = rootPart.Parent

	if not Parent then
		return false
	end

	Nyx_clearCharacterState()
	Nyx_purgeTrapsOnCharacter(Parent)
	Nyx_startMovementLoop()

	local CurrentCamera = workspace.CurrentCamera

	if CurrentCamera and CurrentCamera.CameraSubject ~= humanoid then
		pcall(function()
			CurrentCamera.CameraSubject = humanoid
		end)
	end

	local AutoRotate = humanoid.AutoRotate

	humanoid.AutoRotate = false

	local Nyx_forcedY = allowAerial and math.max(rootPart.Position.Y, targetCFrame.Position.Y + 5, vector3.Y + 5) or nil
	local Nyx_targetCF = Nyx_forcedY and cFrameNew(targetCFrame.Position.X, Nyx_forcedY, targetCFrame.Position.Z) * targetCFrame.Rotation or targetCFrame
	local Nyx_glideSpeed = math.clamp(Nyx_getTweenSpeed(), Nyx_CONFIG.MIN_SPEED, genv.__NyxAdminBoost == true and 3000 or Nyx_CONFIG.MAX_SPEED)

	Nyx_setTargetWalkSpeed(Parent, Nyx_glideSpeed * Nyx_CONFIG.HEADROOM)

	local Nyx_tweenState = {
		cancelled = false
	}

	Nyx_activeTweens[rootPart] = Nyx_tweenState
	Nyx_ensureHoverPad()

	local now
	local Nyx_previousDistance
	local Nyx_glideTo_var1 = 0
	local Nyx_flightPhase = Nyx_forcedY and (math.abs(rootPart.Position.Y - Nyx_forcedY) > 0.35 and "takeoff" or "cruise") or nil
	local Magnitude = (Nyx_targetCF.Position - rootPart.Position).Magnitude
	local Nyx_glideTimeout = os.clock() + math.max(Magnitude / Nyx_glideSpeed, 0.08) * 3 + 8
	local Nyx_arrivedSafely = false
	local Nyx_earlyCarryFired = false

	while not Nyx_tweenState.cancelled and (not cancelCheck or not cancelCheck()) and rootPart.Parent and not (Nyx_glideTimeout <= os.clock()) do
		local Nyx_frameDelta = math.max(math.min(RunService.Heartbeat:Wait(), 0.15), 0.0041666666666666666)
		local Nyx_currentSpeed = math.clamp(Nyx_getTweenSpeed(), Nyx_CONFIG.MIN_SPEED, genv.__NyxAdminBoost == true and 3000 or Nyx_CONFIG.MAX_SPEED)

		Nyx_setTargetWalkSpeed(Parent, Nyx_currentSpeed * Nyx_CONFIG.HEADROOM)

		local Nyx_stealIntegrityState = Nyx_getEnv()[Nyx_CONFIG.INTEGRITY_KEY]
		local State = type(Nyx_stealIntegrityState) == "table" and Nyx_stealIntegrityState.State or nil

		if Nyx_isOwnStateChecked(State, humanoid, rootPart) then
			local Position = rootPart.Position
			local Nyx_deltaVector = Nyx_targetCF.Position - Position
			local Magnitude2 = Nyx_deltaVector.Magnitude
			local vector32 = Vector3.new(Nyx_deltaVector.X, 0, Nyx_deltaVector.Z)

			if Nyx_forcedY and Nyx_flightPhase == "takeoff" and math.abs(Position.Y - Nyx_forcedY) <= 0.35 then
				Nyx_flightPhase = "cruise"
			end

			local Nyx_stepVector = (Nyx_forcedY and Nyx_flightPhase == "takeoff" and Vector3.new(Position.X, Nyx_forcedY, Position.Z) or Nyx_targetCF.Position) - Position
			local Magnitude3 = Nyx_stepVector.Magnitude
			local Magnitude4 = Nyx_forcedY and vector32.Magnitude or Magnitude2

			if Nyx_previousDistance and Nyx_previousDistance + 2 < Magnitude4 then
				Nyx_glideTo_var1 = os.clock() + 0.5
			end

			Nyx_previousDistance = Magnitude4

			local Nyx_stepDistance = (os.clock() < Nyx_glideTo_var1 and math.max(Nyx_CONFIG.MIN_SPEED, Nyx_currentSpeed * 0.45) or Nyx_currentSpeed) * Nyx_frameDelta

			if onEarlyCarry and not Nyx_earlyCarryFired and Magnitude2 <= Nyx_carryTimings.EarlyCarryDistance then
				Nyx_earlyCarryFired = true
				task.spawn(onEarlyCarry)
			end

			local vector33 = Vector3.new(rootPart.CFrame.LookVector.X, 0, rootPart.CFrame.LookVector.Z)
			local Unit = vector32.Magnitude > 0.001 and vector32.Unit or vector33.Magnitude > 0.001 and vector33.Unit or Vector3.new(0, 0, -1)

			if (not Nyx_forcedY or Nyx_flightPhase == "cruise") and Magnitude2 <= math.max(Nyx_stepDistance, 0.05) then
				if Magnitude2 > 0.5 then
					now = nil
				end

				Nyx_syncHoverPad(Nyx_targetCF.Position)
				rootPart.CFrame = lookAt(Nyx_targetCF.Position, Nyx_targetCF.Position + Unit)
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.AssemblyAngularVelocity = Vector3.zero
				Nyx_syncHoverPad(Nyx_targetCF.Position)
				Nyx_updateIntegritySpoof(humanoid, rootPart, Nyx_currentSpeed, Vector3.zero)
				now = now or os.clock()

				if os.clock() - now >= 0.4 then
					Nyx_arrivedSafely = true

					break
				end
			else
				now = nil

				if Magnitude3 <= 0.001 then
					rootPart.AssemblyLinearVelocity = Vector3.zero
					rootPart.AssemblyAngularVelocity = Vector3.zero
					Nyx_syncHoverPad(Position)
				else
					local Nyx_nextPosition = Position + Nyx_stepVector.Unit * math.min(Nyx_stepDistance, Magnitude3)
					local Nyx_velocity = (Nyx_nextPosition - Position) / Nyx_frameDelta

					Nyx_syncHoverPad(Nyx_nextPosition)
					rootPart.CFrame = lookAt(Nyx_nextPosition, Nyx_nextPosition + Unit)
					rootPart.AssemblyLinearVelocity = Vector3.zero
					Nyx_syncHoverPad(Nyx_nextPosition)

					if not Nyx_updateIntegritySpoof(humanoid, rootPart, Nyx_currentSpeed, Nyx_velocity) then
						Nyx_installIntegritySpoof(humanoid, rootPart, Nyx_currentSpeed)
						Nyx_updateIntegritySpoof(humanoid, rootPart, Nyx_currentSpeed, Nyx_velocity)
					end
				end
			end
		else
			Nyx_previousDistance = nil
			now = nil
			rootPart.AssemblyLinearVelocity = Vector3.zero
			rootPart.AssemblyAngularVelocity = Vector3.zero
			Nyx_syncHoverPad(rootPart.Position)

			if Nyx_isOwnState(State, humanoid, rootPart) then
				Nyx_applyWalkSpeedToState(State, Nyx_currentSpeed * Nyx_CONFIG.HEADROOM, Vector3.zero)
			else
				Nyx_installIntegritySpoof(humanoid, rootPart, Nyx_currentSpeed)
			end
		end
	end

	if humanoid.Parent and AutoRotate ~= nil then
		humanoid.AutoRotate = AutoRotate
	end

	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero

	if Nyx_arrivedSafely and onArrival then
		Nyx_setArrivalHold(rootPart, Nyx_targetCF)
	else
		Nyx_destroyHoverPad()
	end

	local Nyx_glideSuccess = Nyx_arrivedSafely and not Nyx_tweenState.cancelled

	return Nyx_glideSuccess
end
local function Nyx_glideToTarget(rootPart, humanoid, targetCFrame, cancelCheck)
	return Nyx_glideTo(rootPart, humanoid, targetCFrame, cancelCheck, false, nil, true)
end
local function Nyx_teleportCharacterRoot(rootPart, targetCFrame)
	if rootPart then
		if typeof(targetCFrame) == "CFrame" then
			if not pcall(function()
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.AssemblyAngularVelocity = Vector3.zero
				rootPart.CFrame = targetCFrame
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.AssemblyAngularVelocity = Vector3.zero
			end) then
				return false
			end

			Nyx_syncHoverPad(targetCFrame.Position)

			local Parent = rootPart.Parent
			local Humanoid = Parent and Parent:FindFirstChildOfClass("Humanoid")

			if Humanoid then
				local Nyx_targetSpeed = math.clamp(Nyx_getTweenSpeed(), Nyx_CONFIG.MIN_SPEED, genv.__NyxAdminBoost == true and 3000 or Nyx_CONFIG.MAX_SPEED)

				Nyx_setTargetWalkSpeed(Parent, Nyx_targetSpeed * Nyx_CONFIG.HEADROOM)

				if not Nyx_updateIntegritySpoof(Humanoid, rootPart, Nyx_targetSpeed, Vector3.zero) then
					Nyx_installIntegritySpoof(Humanoid, rootPart, Nyx_targetSpeed)
					Nyx_updateIntegritySpoof(Humanoid, rootPart, Nyx_targetSpeed, Vector3.zero)
				end
			end

			return true
		end
	end

	return false
end

getgenv().NyxConfig = NyxConfig

local function Nyx_destroyForeignTrap(trapInstance)
	if trapInstance and trapInstance.Name == "PlayerTrap" then
		pcall(function()
			trapInstance:Destroy()
		end)
	end
end

task.spawn(function()
	local function Nyx_watchTraps(folder)
		if not folder then
			return
		end

		local Nyx_transientChildren, Nyx_transientChildrenIter, Nyx_transientChildrenState = ipairs(folder:GetChildren())
		local Nyx_transientIterator = geniter(Nyx_transientChildren, Nyx_transientChildrenIter, Nyx_transientChildrenState)
		local Nyx_transientFirstPack = table.pack(Nyx_transientIterator())

		if Nyx_transientFirstPack[1] then
			local Nyx_transientChild = Nyx_transientFirstPack[3]

			while true do
				Nyx_destroyForeignTrap(Nyx_transientChild)

				local Nyx_transientNextPack = table.pack(Nyx_transientIterator())

				if Nyx_transientNextPack[1] then
					Nyx_transientChild = Nyx_transientNextPack[3]
				else
					break
				end
			end
		end

		folder.ChildAdded:Connect(function(child)
			Nyx_destroyForeignTrap(child)
		end)
	end

	local Transient = workspace:FindFirstChild("Transient")

	if Transient then
		Nyx_watchTraps(Transient)
	end

	local __DEBRIS = workspace:FindFirstChild("__DEBRIS")

	if __DEBRIS then
		Nyx_watchTraps(__DEBRIS)
	end

	workspace.ChildAdded:Connect(function(child)
		if child.Name == "Transient" or child.Name == "__DEBRIS" then
			Nyx_watchTraps(child)
		elseif child.Name == "PlayerTrap" then
			Nyx_destroyForeignTrap(child)

			return
		elseif child.Name:lower():find("trap") then
			Nyx_destroyForeignTrap(child)
		end
	end)
	task.spawn(function()
		while Nyx_isCurrentSession() do
			for _, v in ipairs({
				workspace:FindFirstChild("Transient"),
				workspace:FindFirstChild("__DEBRIS")
			}) do
				if v then
					for _, child in ipairs(v:GetChildren()) do
						Nyx_destroyForeignTrap(child)
					end
				end
			end

			task.wait(1.5)
		end
	end)
end)

local Nyx_watchTraps_var1

local function Nyx_checkTreadmillSnapshot()
	local ok, result = pcall(function()
		return require(game:GetService("ReplicatedStorage").Shared.Remotes).Treadmill.AskRenderSnapshot:InvokeServer()
	end)

	if ok then
		if type(result) == "table" then
			return table.find(result, LocalPlayer.UserId) ~= nil
		end
	end

	return nil
end
local function Nyx_unequipTreadmill()
	local ok, result, result2 = pcall(function()
		return require(game:GetService("ReplicatedStorage").Shared.Remotes).Treadmill.AskDoff:InvokeServer()
	end)

	if not ok then
		return false, tostring(result)
	end

	if result ~= true then
		return false, tostring(result2)
	end

	return true
end
local function Nyx_getTreadmillStandCF()
	local ok, result = pcall(function()
		local PlotState2 = require(ReplicatedStorage.Client.PlotState)
		local Nyx_localPlotSlot = type(PlotState2.ResolveLocalSlot) == "function" and PlotState2.ResolveLocalSlot() or PlotState2.GetMySlot()
		local Nyx_plotsFolder = type(PlotState2.ResolveFolder) == "function" and PlotState2.ResolveFolder() or PlotState2.GetPlotsFolder()
		local Nyx_localPlotFolder = Nyx_plotsFolder and Nyx_localPlotSlot

		Nyx_localPlotFolder = Nyx_localPlotFolder and Nyx_plotsFolder:FindFirstChild(tostring(Nyx_localPlotSlot))

		local TreadmillBottom = Nyx_localPlotFolder and Nyx_localPlotFolder:FindFirstChild("TreadmillBottom")

		if not TreadmillBottom or not TreadmillBottom:IsA("BasePart") then
			return nil
		end

		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if HumanoidRootPart and Humanoid then
			return TreadmillBottom.CFrame * cFrameNew(0, TreadmillBottom.Size.Y * 0.5 + (Humanoid.RigType == Enum.HumanoidRigType.R15 and HumanoidRootPart.Size.Y * 0.5 + math.max(Humanoid.HipHeight, 0.5) or HumanoidRootPart.Size.Y * 0.5 + 2) + 0.05, 0)
		end

		return nil
	end)
	local Nyx_treadmillPrepareResult = ok and result or nil

	return Nyx_treadmillPrepareResult
end

local Nyx_TreadmillHelpers = {
	HoldSeconds = 0.3,
	ConfirmStableSeconds = 0.3,
	ConfirmTimeout = 2.5,
	PollSeconds = 0.05,
	ArrivalSettle = 0.5,
	DecoyName = "__NyxTweenTreadmillDecoy",
	destroyTrail = function(trailInstance)
		if typeof(trailInstance) == "Instance" then
			if trailInstance:IsA("Trail") then
				pcall(trailInstance.Destroy, trailInstance)
			end
		end
	end,
	destroyStealPopup = function(popupInstance)
		if NyxConfig.IsStealing then
			if typeof(popupInstance) == "Instance" and (popupInstance.Name == "SpeedGainPopup" or popupInstance.Name == "PlusOne") then
				pcall(popupInstance.Destroy, popupInstance)
			end
		end
	end
}

Nyx_TreadmillHelpers.purgeStealPopups = function()
	local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not PlayerGui then
		return
	end

	for _, descendant in ipairs(PlayerGui:GetDescendants()) do
		Nyx_TreadmillHelpers.destroyStealPopup(descendant)
	end
end
Nyx_TreadmillHelpers.guiConnection = LocalPlayer:WaitForChild("PlayerGui").DescendantAdded:Connect(function(descendant)
	Nyx_TreadmillHelpers.destroyStealPopup(descendant)
end)
Nyx_TreadmillHelpers.removeDecoy = function()
	if Nyx_TreadmillHelpers.cameraConnection then
		pcall(Nyx_TreadmillHelpers.cameraConnection.Disconnect, Nyx_TreadmillHelpers.cameraConnection)
		Nyx_TreadmillHelpers.cameraConnection = nil
	end

	if Nyx_TreadmillHelpers.characterConnection then
		pcall(Nyx_TreadmillHelpers.characterConnection.Disconnect, Nyx_TreadmillHelpers.characterConnection)
		Nyx_TreadmillHelpers.characterConnection = nil
	end

	local pairs_ = pairs
	local transparency = Nyx_TreadmillHelpers.transparency or {}

	for k, v in pairs_(transparency) do
		if typeof(k) == "Instance" and k.Parent then
			pcall(function()
				k.LocalTransparencyModifier = v
			end)
		end
	end

	Nyx_TreadmillHelpers.transparency = nil

	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local CurrentCamera = workspace.CurrentCamera

	if CurrentCamera then
		pcall(function()
			CurrentCamera.CameraSubject = Humanoid or Nyx_TreadmillHelpers.cameraSubject
		end)
	end

	Nyx_TreadmillHelpers.cameraSubject = nil

	if Nyx_TreadmillHelpers.decoy then
		pcall(Nyx_TreadmillHelpers.decoy.Destroy, Nyx_TreadmillHelpers.decoy)
	end

	Nyx_TreadmillHelpers.decoy = nil
end
Nyx_TreadmillHelpers.spawnDecoy = function(targetCFrame)
	Nyx_TreadmillHelpers.removeDecoy()

	local Character = LocalPlayer.Character

	if not Character then
		return false
	end

	local Archivable = Character.Archivable

	Character.Archivable = true

	local ok, decoy = pcall(Character.Clone, Character)

	Character.Archivable = Archivable

	if not ok or not decoy or typeof(decoy) ~= "Instance" then
		return false
	end

	decoy.Name = Nyx_TreadmillHelpers.DecoyName

	for _, descendant in ipairs(decoy:GetDescendants()) do
		if not descendant:IsA("Script") then
			if not descendant:IsA("LocalScript") and not descendant:IsA("BillboardGui") and not descendant:IsA("Sound") and not descendant:IsA("Trail") then
				if not descendant:IsA("BasePart") then
					continue
				end

				descendant.LocalTransparencyModifier = 0
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false

				continue
			end
		end

		pcall(descendant.Destroy, descendant)
	end

	local Humanoid = decoy:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		decoy:Destroy()

		return false
	end

	pcall(function()
		Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	end)
	decoy.Parent = workspace
	decoy:PivotTo(targetCFrame)
	Nyx_TreadmillHelpers.decoy = decoy

	local transparency = setmetatable({}, {
		__mode = "k"
	})

	local function Nyx_hideLocalPart(part)
		if not part or not part:IsA("BasePart") or not part:IsDescendantOf(Character) then
			return
		end

		if transparency[part] == nil then
			transparency[part] = part.LocalTransparencyModifier
		end

		part.LocalTransparencyModifier = 1
	end

	for _, descendant in ipairs(Character:GetDescendants()) do
		Nyx_hideLocalPart(descendant)
		Nyx_TreadmillHelpers.destroyTrail(descendant)
	end

	Nyx_TreadmillHelpers.transparency = transparency
	Nyx_TreadmillHelpers.characterConnection = Character.DescendantAdded:Connect(function(descendant)
		if Nyx_TreadmillHelpers.decoy == decoy then
			pcall(Nyx_hideLocalPart, descendant)
			Nyx_TreadmillHelpers.destroyTrail(descendant)
		end
	end)

	local CurrentCamera = workspace.CurrentCamera

	if CurrentCamera then
		Nyx_TreadmillHelpers.cameraSubject = CurrentCamera.CameraSubject
		CurrentCamera.CameraSubject = Humanoid
	end

	Nyx_TreadmillHelpers.cameraConnection = RunService.RenderStepped:Connect(function()
		if Nyx_TreadmillHelpers.decoy == decoy then
			if decoy.Parent and Humanoid.Parent then
				for k in pairs(transparency) do
					if k.Parent and k.LocalTransparencyModifier ~= 1 then
						k.LocalTransparencyModifier = 1
					end
				end

				local CurrentCamera2 = workspace.CurrentCamera

				if CurrentCamera2 and CurrentCamera2.CameraSubject ~= Humanoid then
					CurrentCamera2.CameraSubject = Humanoid
				end

				return
			end
		end
	end)

	return true
end
Nyx_TreadmillHelpers.requestEquip = function()
	local ok, result, result2 = pcall(function()
		return require(ReplicatedStorage.Shared.Remotes).Treadmill.AskWearStill:InvokeServer()
	end)

	if ok then
		if result ~= false then
			return true
		end
	end

	local Nyx_treadmillUnequipFalse = false
	local tostring_ = tostring
	local Nyx_treadmillUnequipMsg = result2 or result

	return Nyx_treadmillUnequipFalse, tostring_(Nyx_treadmillUnequipMsg)
end
Nyx_TreadmillHelpers.prepare = function(targetCFrame, cancelCheck)
	local Character = LocalPlayer.Character
	local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if HumanoidRootPart then
		if Humanoid and typeof(targetCFrame) == "CFrame" then
			local function Nyx_cancelCheck()
				return cancelCheck ~= nil and cancelCheck()
			end
			local function Nyx_cleanupDecoy()
				local Character2 = LocalPlayer.Character
				local HumanoidRootPart2 = Character2 and Character2:FindFirstChild("HumanoidRootPart")

				if HumanoidRootPart2 then
					Nyx_teleportCharacterRoot(HumanoidRootPart2, targetCFrame)
					task.wait(0.1)
				end

				Nyx_TreadmillHelpers.removeDecoy()
			end

			Nyx_TreadmillHelpers.purgeStealPopups()
			Nyx_clearCharacterState()
			Nyx_destroyHoverPad()

			if not Nyx_TreadmillHelpers.spawnDecoy(targetCFrame) then
				return false
			end

			local Nyx_treadmillStandCF = Nyx_getTreadmillStandCF()

			if not Nyx_treadmillStandCF or Nyx_cancelCheck() or not Nyx_teleportCharacterRoot(HumanoidRootPart, Nyx_treadmillStandCF) then
				Nyx_unequipTreadmill()
				Nyx_cleanupDecoy()

				return false
			end

			task.wait(Nyx_TreadmillHelpers.ArrivalSettle)

			if Nyx_cancelCheck() then
				Nyx_unequipTreadmill()
				Nyx_cleanupDecoy()

				return false
			end

			if not Nyx_TreadmillHelpers.requestEquip() then
				Nyx_unequipTreadmill()
				Nyx_cleanupDecoy()

				return false
			end

			local Nyx_confirmDeadline = os.clock() + Nyx_TreadmillHelpers.ConfirmTimeout
			local Nyx_equipConfirmed = false
			local now

			while not Nyx_cancelCheck() do
				if not (os.clock() < Nyx_confirmDeadline) then
					break
				end

				if Nyx_checkTreadmillSnapshot() == true then
					now = now or os.clock()

					if not (Nyx_TreadmillHelpers.ConfirmStableSeconds <= os.clock() - now) then
						task.wait(Nyx_TreadmillHelpers.PollSeconds)

						continue
					end

					Nyx_equipConfirmed = true

					break
				end

				now = nil
				task.wait(Nyx_TreadmillHelpers.PollSeconds)
			end

			if not Nyx_equipConfirmed or Nyx_cancelCheck() then
				Nyx_unequipTreadmill()
				Nyx_cleanupDecoy()

				return false
			end

			local Nyx_holdDeadline = os.clock() + Nyx_TreadmillHelpers.HoldSeconds

			while not Nyx_cancelCheck() and os.clock() < Nyx_holdDeadline do
				task.wait(Nyx_TreadmillHelpers.PollSeconds)
			end

			local Nyx_doffDeadline = os.clock() + Nyx_TreadmillHelpers.ConfirmTimeout
			local Nyx_doffSucceeded = false

			while not Nyx_cancelCheck() and os.clock() < Nyx_doffDeadline do
				Nyx_unequipTreadmill()
				task.wait(Nyx_TreadmillHelpers.PollSeconds)

				if Nyx_checkTreadmillSnapshot() == false then
					Nyx_watchTraps_var1 = nil
					Nyx_doffSucceeded = true

					break
				end
			end

			Nyx_cleanupDecoy()

			local Nyx_treadmillPrepareDone = Nyx_doffSucceeded and not Nyx_cancelCheck()

			return Nyx_treadmillPrepareDone
		end
	end

	return false
end
Nyx_TreadmillHelpers.previousCleanup = genv.__NyxTweenRuntimeCleanup
genv.__NyxTweenRuntimeCleanup = function()
	Nyx_unequipTreadmill()
	Nyx_TreadmillHelpers.removeDecoy()

	if Nyx_TreadmillHelpers.guiConnection then
		pcall(Nyx_TreadmillHelpers.guiConnection.Disconnect, Nyx_TreadmillHelpers.guiConnection)
		Nyx_TreadmillHelpers.guiConnection = nil
	end

	if type(Nyx_TreadmillHelpers.previousCleanup) == "function" then
		Nyx_TreadmillHelpers.previousCleanup()
	end
end
LocalPlayer.CharacterRemoving:Connect(function()
	Nyx_TreadmillHelpers.removeDecoy()
end)

do
	if type(genv.__NyxCosmeticSuppressCleanup) == "function" then
		pcall(genv.__NyxCosmeticSuppressCleanup)
	end

	local Nyx_cosmeticConnections = {}

	local function Nyx_forceDisableDropHeldEgg(child)
		if child then
			if child.Name == "DropHeldEgg" then
				if not child:IsA("ScreenGui") then
					if not child:IsA("LayerCollector") then
						return
					end
				end

				pcall(function()
					child.Enabled = false
				end)
				table.insert(Nyx_cosmeticConnections, child:GetPropertyChangedSignal("Enabled"):Connect(function()
					if child.Enabled then
						pcall(function()
							child.Enabled = false
						end)
					end
				end))

				return
			end
		end
	end
	local function Nyx_watchPlayerGui()
		local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if PlayerGui then
			for _, child in ipairs(PlayerGui:GetChildren()) do
				Nyx_forceDisableDropHeldEgg(child)
			end

			table.insert(Nyx_cosmeticConnections, PlayerGui.ChildAdded:Connect(Nyx_forceDisableDropHeldEgg))

			return
		end
	end

	Nyx_watchPlayerGui()
	table.insert(Nyx_cosmeticConnections, LocalPlayer.CharacterAdded:Connect(function()
		task.defer(Nyx_watchPlayerGui)
	end))
	pcall(function()
		local GuardPresentationComponent = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardPresentationComponent)

		if type(GuardPresentationComponent) == "table" then
			genv.__NyxGuardPresentOrig = genv.__NyxGuardPresentOrig or {
				PlayWake = GuardPresentationComponent.PlayWake,
				PlayHit = GuardPresentationComponent.PlayHit,
				PlayAfterWake = GuardPresentationComponent.PlayAfterWake,
				ScheduleAfterWake = GuardPresentationComponent.ScheduleAfterWake
			}

			local function playWake()
			end

			GuardPresentationComponent.PlayWake = playWake
			GuardPresentationComponent.PlayHit = function()
				return 0
			end
			GuardPresentationComponent.PlayAfterWake = playWake
			GuardPresentationComponent.ScheduleAfterWake = playWake
		end
	end)
	genv.__NyxCosmeticSuppressCleanup = function()
		for _, v in ipairs(Nyx_cosmeticConnections) do
			pcall(function()
				v:Disconnect()
			end)
		end

		table.clear(Nyx_cosmeticConnections)

		local __NyxGuardPresentOrig = genv.__NyxGuardPresentOrig

		if type(__NyxGuardPresentOrig) == "table" then
			pcall(function()
				local GuardPresentationComponent = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardPresentationComponent)

				for k, v in pairs(__NyxGuardPresentOrig) do
					GuardPresentationComponent[k] = v
				end
			end)
		end
	end
end

do
	if type(genv.__NyxStealDeclutterCleanup) == "function" then
		pcall(genv.__NyxStealDeclutterCleanup)
	end

	local Nyx_declutterTargets = {
		{
			name = "ProximityPrompts",
			restore = true
		},
		{
			name = "AreaGui",
			restore = false
		}
	}
	local Nyx_playWake_var1 = false
	local Nyx_declutterConnections = {}

	local function Nyx_isLayerCollector(guiObject)
		return guiObject and (guiObject:IsA("ScreenGui") or guiObject:IsA("LayerCollector"))
	end
	local function Nyx_disableLayerCollector(guiObject)
		if not Nyx_isLayerCollector(guiObject) then
			return
		end

		pcall(function()
			guiObject.Enabled = false
		end)
		table.insert(Nyx_declutterConnections, guiObject:GetPropertyChangedSignal("Enabled"):Connect(function()
			if Nyx_playWake_var1 then
				if guiObject.Enabled then
					pcall(function()
						guiObject.Enabled = false
					end)
				end
			end
		end))
	end
	local function Nyx_findDeclutterTargets(callback)
		local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if not PlayerGui then
			return
		end

		for _, v in ipairs(Nyx_declutterTargets) do
			local VName = PlayerGui:FindFirstChild(v.name)

			if VName then
				callback(VName, v)
			end
		end
	end
	local function Nyx_watchDeclutter()
		local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if not PlayerGui then
			return
		end

		Nyx_findDeclutterTargets(function(guiObject)
			Nyx_disableLayerCollector(guiObject)
		end)
		table.insert(Nyx_declutterConnections, PlayerGui.ChildAdded:Connect(function(child)
			if not Nyx_playWake_var1 then
				return
			end

			for _, v in ipairs(Nyx_declutterTargets) do
				if child.Name == v.name then
					Nyx_disableLayerCollector(child)

					break
				end
			end
		end))
	end
	local function Nyx_restoreDeclutter()
		for _, v in ipairs(Nyx_declutterConnections) do
			pcall(function()
				v:Disconnect()
			end)
		end

		table.clear(Nyx_declutterConnections)
		Nyx_findDeclutterTargets(function(guiObject, entry)
			pcall(function()
				guiObject.Enabled = entry.restore
			end)
		end)
	end

	genv.__NyxSetStealDeclutter = function(enabled)
		local Nyx_declutterWanted = enabled == true

		if Nyx_declutterWanted == Nyx_playWake_var1 then
			return
		end

		Nyx_playWake_var1 = Nyx_declutterWanted

		if Nyx_declutterWanted then
			Nyx_watchDeclutter()
		else
			Nyx_restoreDeclutter()
		end
	end
	genv.__NyxStealDeclutterCleanup = function()
		Nyx_playWake_var1 = false
		Nyx_restoreDeclutter()
	end
end

do
	local function Nyx_leftTreadmillCheck()
		local Nyx_treadmillSnapshot = Nyx_checkTreadmillSnapshot()

		if Nyx_treadmillSnapshot == false then
			Nyx_watchTraps_var1 = nil

			return true
		end

		if Nyx_treadmillSnapshot == nil and Nyx_watchTraps_var1 == nil then
			return true
		end

		Nyx_watchTraps_var1 = Nyx_watchTraps_var1 or "server"

		local Nyx_doffOk, Nyx_doffError = Nyx_unequipTreadmill()

		if not Nyx_doffOk then
			warn("[Treadmill] Gagal minta lepas dari treadmill sebelum steal:", Nyx_doffError)

			return false
		end

		local Nyx_doffDeadline = os.clock() + 1.5

		while Nyx_watchTraps_var1 ~= nil and os.clock() < Nyx_doffDeadline do
			task.wait(0.05)

			if not NyxConfig.AutoSteal then
				return false
			end

			if Nyx_checkTreadmillSnapshot() == false then
				Nyx_watchTraps_var1 = nil

				break
			end
		end

		if Nyx_watchTraps_var1 ~= nil then
			warn("[Treadmill] Lepas treadmill gak kekonfirmasi dalam 1.5s, steal dilanjut apa adanya.")

			return false
		end

		task.wait(0.12)

		return true
	end
end

if type(genv.__NyxDecomBoostCleanup) == "function" then
	pcall(genv.__NyxDecomBoostCleanup)
end

local Nyx_FpsBoost, Nyx_leftTreadmillCheck_var2, Nyx_leftTreadmillCheck_var3

do
	local Nyx_fpsListeners = {}
	local Nyx_leftTreadmillCheck_var1 = false

	genv.__NyxDecomBoostCleanup = function()
		for _, v in ipairs(Nyx_fpsListeners) do
			pcall(function()
				v:Disconnect()
			end)
		end

		table.clear(Nyx_fpsListeners)
		Nyx_leftTreadmillCheck_var1 = false
	end

	local function Nyx_purgeClientRenderedAssets()
		local ClientRenderedAssets = workspace:FindFirstChild("ClientRenderedAssets")

		if not ClientRenderedAssets then
			return
		end

		for _, child in ipairs(ClientRenderedAssets:GetChildren()) do
			pcall(function()
				child.Parent = nil
			end)
		end
	end
	local function Nyx_isLocalPlotRender(childName)
		return string.sub(childName.Name, 1, #tostring(LocalPlayer.UserId) + 1) == tostring(LocalPlayer.UserId) .. "_"
	end
	local function Nyx_purgePlacedEggRenders()
		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name == "PlacedEggRenders" then
				for _, child2 in ipairs(child:GetChildren()) do
					pcall(function()
						if not child2:FindFirstChildOfClass("ProximityPrompt") then
							if not Nyx_isLocalPlotRender(child2) then
								child2.Parent = nil
							end
						end
					end)
				end
			end
		end
	end
	local function Nyx_purgeTrapDebris()
		for _, v in ipairs({
			"Transient",
			"__DEBRIS"
		}) do
			local Nyx_debrisFolder = workspace:FindFirstChild(v)

			if Nyx_debrisFolder then
				for _, child in ipairs(Nyx_debrisFolder:GetChildren()) do
					if child.Name ~= "PlayerTrap" then
						if not child.Name:lower():find("trap") then
							continue
						end
					end

					pcall(function()
						child:Destroy()
					end)
				end
			end
		end
	end
	local function Nyx_isVisualTool(descendant)
		if not descendant:FindFirstAncestor("NyxVisualBack") then
			if not descendant:FindFirstAncestor("NyxVisualRemote") then
				local Tool = descendant:FindFirstAncestorWhichIsA("Tool")

				return Tool ~= nil and Tool:GetAttribute("NyxVisual") ~= nil
			end
		end

		return true
	end

	Nyx_FpsBoost = {
		effects = {},
		parts = {},
		decals = {},
		snapshot = nil
	}

	local Nyx_fpsFilterNames = {
		PlusOne = true,
		SpeedGainPopup = true,
		SellPayout = true,
		SyncedIncomeCash = true
	}
	local Nyx_fpsBillboardWhitelist = {
		PlayerPlotSign = true,
		CanUpgrade = true,
		AlertGui = true,
		OfflineMoneyClaimBillboard = true
	}

	local function Nyx_applyFpsBoostFilter(descendant)
		pcall(function()
			if Nyx_isVisualTool(descendant) then
				return
			end

			if Nyx_fpsFilterNames[descendant.Name] then
				descendant:Destroy()

				return
			end

			if descendant:IsA("BillboardGui") and Nyx_fpsBillboardWhitelist[descendant.Name] then
				if descendant.Enabled then
					Nyx_FpsBoost.effects[descendant] = true
				end

				descendant.Enabled = false

				return
			end

			if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Sparkles") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("PostEffect") then
				if descendant.Enabled then
					Nyx_FpsBoost.effects[descendant] = true
				end

				descendant.Enabled = false
			end
		end)
	end
	local function Nyx_watchFpsBoost()
		if Nyx_leftTreadmillCheck_var1 then
			return
		end

		Nyx_leftTreadmillCheck_var1 = true
		table.insert(Nyx_fpsListeners, game.DescendantAdded:Connect(Nyx_applyFpsBoostFilter))
		table.insert(Nyx_fpsListeners, workspace.ChildAdded:Connect(function(child)
			if child.Name == "ClientRenderedAssets" then
				Nyx_purgeClientRenderedAssets()
				table.insert(Nyx_fpsListeners, child.ChildAdded:Connect(function(child2)
					pcall(function()
						child2.Parent = nil
					end)
				end))
			elseif child.Name == "PlacedEggRenders" then
				Nyx_purgePlacedEggRenders()
				table.insert(Nyx_fpsListeners, child.ChildAdded:Connect(function(child2)
					pcall(function()
						if not child2:FindFirstChildOfClass("ProximityPrompt") and not Nyx_isLocalPlotRender(child2) then
							child2.Parent = nil
						end
					end)
				end))
			elseif child.Name == "__DEBRIS" or child.Name == "Transient" then
				table.insert(Nyx_fpsListeners, child.ChildAdded:Connect(function(child2)
					if child2.Name == "PlayerTrap" then
						pcall(function()
							child2:Destroy()
						end)

						return
					elseif child2.Name:lower():find("trap") then
						pcall(function()
							child2:Destroy()
						end)
					end
				end))
			end
		end))

		local ClientRenderedAssets = workspace:FindFirstChild("ClientRenderedAssets")

		if ClientRenderedAssets then
			table.insert(Nyx_fpsListeners, ClientRenderedAssets.ChildAdded:Connect(function(child)
				pcall(function()
					child.Parent = nil
				end)
			end))
		end

		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name == "PlacedEggRenders" then
				table.insert(Nyx_fpsListeners, child.ChildAdded:Connect(function(child2)
					pcall(function()
						if not child2:FindFirstChildOfClass("ProximityPrompt") then
							if not Nyx_isLocalPlotRender(child2) then
								child2.Parent = nil
							end
						end
					end)
				end))
			end
		end
	end

	local Nyx_watchFpsBoost_var1 = false

	Nyx_leftTreadmillCheck_var2 = function()
		if Nyx_watchFpsBoost_var1 then
			return
		end

		Nyx_watchFpsBoost_var1 = true

		local Lighting = game:GetService("Lighting")

		if not Nyx_FpsBoost.snapshot then
			local Nyx_FpsSnapshot = {}

			pcall(function()
				Nyx_FpsSnapshot.quality = settings().Rendering.QualityLevel
				Nyx_FpsSnapshot.throttle = settings().Physics.PhysicsEnvironmentalThrottle
				Nyx_FpsSnapshot.technology = Lighting.Technology
				Nyx_FpsSnapshot.shadows = Lighting.GlobalShadows
				Nyx_FpsSnapshot.fogEnd = Lighting.FogEnd
				Nyx_FpsSnapshot.brightness = Lighting.Brightness
				Nyx_FpsSnapshot.ambient = Lighting.Ambient
				Nyx_FpsSnapshot.outdoorAmbient = Lighting.OutdoorAmbient
			end)

			local Terrain = workspace:FindFirstChildOfClass("Terrain")

			if Terrain then
				pcall(function()
					Nyx_FpsSnapshot.terrain = {
						WaterWaveSize = Terrain.WaterWaveSize,
						WaterWaveSpeed = Terrain.WaterWaveSpeed,
						WaterReflectance = Terrain.WaterReflectance,
						WaterTransparency = Terrain.WaterTransparency,
						Decoration = Terrain.Decoration
					}
				end)
				pcall(function()
					local Clouds = Terrain:FindFirstChildOfClass("Clouds")

					if Clouds then
						Nyx_FpsSnapshot.cloudNyxbled = Clouds.Enabled
					end
				end)
			end

			pcall(function()
				local Preferences = ReplicatedStorage.Shared:FindFirstChild("Preferences")

				if Preferences then
					local module = require(Preferences)

					Nyx_FpsSnapshot.prefs = {
						HideOtherPets = module.IsOn("HideOtherPets"),
						DisableVideos = module.IsOn("DisableVideos")
					}
				end
			end)

			if Nyx_FpsSnapshot.quality == Enum.QualityLevel.Level01 then
				Nyx_FpsSnapshot.quality = Enum.QualityLevel.Automatic
			end

			Nyx_FpsBoost.snapshot = genv.__NyxDecomSnapshot or Nyx_FpsSnapshot
			genv.__NyxDecomSnapshot = Nyx_FpsBoost.snapshot
		end

		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Always
			Lighting.Technology = Enum.Technology.Compatibility
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 9e9
			Lighting.Brightness = 2
			Lighting.Ambient = Color3.new(1, 1, 1)
			Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
		end)

		local now = os.clock()

		for _, v in ipairs({
			workspace,
			Lighting
		}) do
			for _, descendant in ipairs(v:GetDescendants()) do
				if not Nyx_isVisualTool(descendant) then
					if descendant:IsA("BasePart") then
						pcall(function()
							if not Nyx_FpsBoost.parts[descendant] then
								Nyx_FpsBoost.parts[descendant] = {
									descendant.Material,
									descendant.CastShadow,
									descendant:IsA("MeshPart") and descendant.RenderFidelity or nil
								}
							end

							descendant.Material = Enum.Material.SmoothPlastic
							descendant.CastShadow = false

							if descendant:IsA("MeshPart") then
								descendant.RenderFidelity = Enum.RenderFidelity.Performance
							end
						end)
					else
						if descendant:IsA("Decal") then
							pcall(function()
								if descendant.Texture ~= "" and not Nyx_FpsBoost.decals[descendant] then
									Nyx_FpsBoost.decals[descendant] = descendant.Texture
								end

								descendant.Texture = ""
							end)

							if os.clock() - now > 0.004 then
								task.wait()
								now = os.clock()
							end

							continue
						end

						if descendant:IsA("Texture") then
							pcall(function()
								if descendant.Texture ~= "" and not Nyx_FpsBoost.decals[descendant] then
									Nyx_FpsBoost.decals[descendant] = descendant.Texture
								end

								descendant.Texture = ""
							end)
						else
							Nyx_applyFpsBoostFilter(descendant)
						end
					end

					if os.clock() - now > 0.004 then
						task.wait()
						now = os.clock()
					end
				end
			end
		end

		local Terrain = workspace:FindFirstChildOfClass("Terrain")

		if Terrain then
			pcall(function()
				Terrain.WaterWaveSize = 0
				Terrain.WaterWaveSpeed = 0
				Terrain.WaterReflectance = 0
				Terrain.WaterTransparency = 1
				Terrain.Decoration = false

				local Clouds = Terrain:FindFirstChildOfClass("Clouds")

				if Clouds then
					Clouds.Enabled = false
				end
			end)
		end

		pcall(function()
			local Shared = ReplicatedStorage.Shared
			local Preferences = Shared:FindFirstChild("Preferences")

			if Preferences then
				local module = require(Preferences)

				module.Set("HideOtherPets", true)
				module.Set("DisableVideos", true)
			else
				local SettingsCmds = require(Shared.SettingsCmds)

				SettingsCmds.Write("HideOtherPets", true)
				SettingsCmds.Write("DisableVideos", true)
			end
		end)
		Nyx_purgeClientRenderedAssets()
		Nyx_purgePlacedEggRenders()
		Nyx_purgeTrapDebris()
		Nyx_watchFpsBoost()
		Nyx_watchFpsBoost_var1 = false
	end
	Nyx_FpsBoost.revert = function()
		for _, v in ipairs(Nyx_fpsListeners) do
			pcall(function()
				v:Disconnect()
			end)
		end

		table.clear(Nyx_fpsListeners)
		Nyx_leftTreadmillCheck_var1 = false

		local snapshot = Nyx_FpsBoost.snapshot
		local Lighting = game:GetService("Lighting")

		if snapshot then
			pcall(function()
				settings().Rendering.QualityLevel = snapshot.quality or Enum.QualityLevel.Automatic
			end)
			pcall(function()
				settings().Physics.PhysicsEnvironmentalThrottle = snapshot.throttle
			end)
			pcall(function()
				Lighting.Technology = snapshot.technology
				Lighting.GlobalShadows = snapshot.shadows
				Lighting.FogEnd = snapshot.fogEnd
				Lighting.Brightness = snapshot.brightness
				Lighting.Ambient = snapshot.ambient
				Lighting.OutdoorAmbient = snapshot.outdoorAmbient
			end)

			local Terrain = workspace:FindFirstChildOfClass("Terrain")

			if Terrain and snapshot.terrain then
				for k, v in pairs(snapshot.terrain) do
					pcall(function()
						Terrain[k] = v
					end)
				end

				if snapshot.cloudNyxbled ~= nil then
					pcall(function()
						local Clouds = Terrain:FindFirstChildOfClass("Clouds")

						if Clouds then
							Clouds.Enabled = snapshot.cloudNyxbled
						end
					end)
				end
			end

			if snapshot.prefs then
				pcall(function()
					local Preferences = require(ReplicatedStorage.Shared.Preferences)

					for k, pref in pairs(snapshot.prefs) do
						Preferences.Set(k, pref)
					end
				end)
			end
		end

		local Nyx_v390_var1 = 0

		for k, part in pairs(Nyx_FpsBoost.parts) do
			if k.Parent then
				pcall(function()
					k.Material = part[1]
					k.CastShadow = part[2]

					if part[3] ~= nil and k:IsA("MeshPart") then
						k.RenderFidelity = part[3]
					end
				end)
			end

			Nyx_v390_var1 += 1

			if Nyx_v390_var1 % 400 == 0 then
				task.wait()
			end
		end

		for k, decal in pairs(Nyx_FpsBoost.decals) do
			if k.Parent then
				pcall(function()
					k.Texture = decal
				end)
			end
		end

		for k in pairs(Nyx_FpsBoost.effects) do
			if k.Parent then
				pcall(function()
					k.Enabled = true
				end)
			end
		end

		Nyx_FpsBoost.parts = {}
		Nyx_FpsBoost.decals = {}
		Nyx_FpsBoost.effects = {}
		Nyx_FpsBoost.snapshot = nil
	end
	genv.__NyxDecomBoostUndo = Nyx_FpsBoost

	local Nyx_v390_var2 = false

	local function Nyx_hideOtherPlayerEggs(model)
		if not model or not model:IsA("Model") then
			return
		end

		local match = model.Name:match("^(%d+)_")
		local Nyx_otherPlayerId = match and tonumber(match)

		if not Nyx_otherPlayerId or Nyx_otherPlayerId == LocalPlayer.UserId then
			return
		end

		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
				descendant.CanCollide = false
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
				descendant.Enabled = false
			elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
				descendant.Enabled = false
			end
		end
	end
	local function Nyx_prepareFpsEggHiding()
		if NyxConfig._fpsEggsReady then
			return true
		end

		local Nyx_prepareFpsEggHiding_var1 = false
		local ok, result = pcall(function()
			local Nyx_placedEggRenderer = require(game:GetService("ReplicatedStorage").Shared.Eggs.PlacedEggRenderer).GetRenderFolder()

			if not Nyx_placedEggRenderer then
				return
			end

			local children = Nyx_placedEggRenderer:GetChildren()

			for _, child in ipairs(children) do
				Nyx_hideOtherPlayerEggs(child)
			end

			Nyx_placedEggRenderer.ChildAdded:Connect(function(child)
				task.defer(Nyx_hideOtherPlayerEggs, child)
			end)
			Nyx_prepareFpsEggHiding_var1 = true
		end)

		if not ok then
			warn("[FPSBoost] Gagal hide egg pemain lain:", result)

			return false
		end

		return Nyx_prepareFpsEggHiding_var1
	end
	local function Nyx_hideClientAsset(instance)
		if not instance then
			return
		end

		pcall(function()
			instance.Parent = nil
		end)
	end
	local function Nyx_prepareFpsPetHiding()
		if NyxConfig._fpsPetsReady then
			return true
		end

		local IsOn
		local ok, result = pcall(function()
			local Shared = game:GetService("ReplicatedStorage").Shared
			local Preferences = Shared:FindFirstChild("Preferences")

			if Preferences then
				local module = require(Preferences)

				module.Set("HideOtherPets", true)
				IsOn = module.IsOn
			else
				local SettingsCmds = require(Shared.SettingsCmds)

				SettingsCmds.Write("HideOtherPets", true)
				IsOn = SettingsCmds.Allows
			end
		end)
		local Nyx_hideOtherPetsOn = false

		if ok and IsOn then
			local ok2, result2 = pcall(IsOn, "HideOtherPets")

			Nyx_hideOtherPetsOn = ok2 and result2 == true
		end

		if ok then
			if Nyx_hideOtherPetsOn then
				local Nyx_prepareFpsPetHiding_var1 = false
				local ok2, result2 = pcall(function()
					local ClientRenderedAssets = workspace:FindFirstChild("ClientRenderedAssets") or workspace:WaitForChild("ClientRenderedAssets", 10)

					if not ClientRenderedAssets then
						return
					end

					local children = ClientRenderedAssets:GetChildren()

					for _, child in ipairs(children) do
						Nyx_hideClientAsset(child)
					end

					ClientRenderedAssets.ChildAdded:Connect(function(child)
						task.defer(Nyx_hideClientAsset, child)
					end)
					Nyx_prepareFpsPetHiding_var1 = true
				end)

				if not ok2 then
					warn("[FPSBoost] Gagal hide pet (manual):", result2)

					return false
				end

				return Nyx_prepareFpsPetHiding_var1
			end
		end

		warn("[FPSBoost] Gagal set HideOtherPets bawaan game:", result or "setting belum aktif")

		return false
	end
	local function Nyx_applyFpsBoostBase()
		if type(genv.__NyxSetCapFps) == "function" then
			pcall(genv.__NyxSetCapFps, 240)
		end

		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)

		local function Nyx_setQualityLevel1()
			UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
		end

		pcall(Nyx_setQualityLevel1)
		pcall(function()
			require(game:GetService("ReplicatedStorage").Client.LightingsController):SetModifier("FPSBoost", function(lightingTable)
				local Nyx_lightingOverride = table.clone(lightingTable)

				Nyx_lightingOverride.Bloom = nil
				Nyx_lightingOverride.ColorCorrection = nil
				Nyx_lightingOverride.SunRays = nil
				Nyx_lightingOverride.DepthOfField = nil
				Nyx_lightingOverride.Blur = nil
				Nyx_lightingOverride.Clouds = nil
				Nyx_lightingOverride.Atmosphere = nil
				Nyx_lightingOverride.ShadowSoftness = 1

				return Nyx_lightingOverride
			end, 100, 0)
		end)
		pcall(function()
			local Lighting = game:GetService("Lighting")

			Lighting.GlobalShadows = false
			Lighting.Technology = Enum.Technology.Compatibility
			Lighting.FogEnd = 9e9
			Lighting.Brightness = 2
		end)
		pcall(function()
			local Terrain = workspace:FindFirstChildOfClass("Terrain")

			if Terrain then
				Terrain.WaterWaveSize = 0
				Terrain.WaterWaveSpeed = 0
				Terrain.WaterReflectance = 0
				Terrain.WaterTransparency = 1
				Terrain.Decoration = false
			end
		end)
		pcall(function()
			local __DEBRIS = workspace:FindFirstChild("__DEBRIS")

			if __DEBRIS then
				for _, child in ipairs(__DEBRIS:GetChildren()) do
					if child.Name == "PlayerTrap" then
						pcall(function()
							child:Destroy()
						end)
					end
				end
			end
		end)
	end

	local color3 = Color3.fromRGB(120, 120, 120)

	local function Nyx_flattenPartMaterial(part)
		if not part or not part:IsA("BasePart") then
			return
		end

		part.Material = Enum.Material.SmoothPlastic
		part.Color = color3
		part.CastShadow = false
	end
	local function Nyx_disableVisualEffects(instance)
		if instance:IsA("ParticleEmitter") then
			instance.Enabled = false
			instance.Rate = 0
			pcall(function()
				instance:Clear()
			end)
		elseif instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles") or instance:IsA("PostEffect") or instance:IsA("Light") or instance:IsA("Highlight") or instance:IsA("Clouds") then
			instance.Enabled = false
		elseif instance:IsA("Atmosphere") then
			instance.Density = 0
			instance.Haze = 0
			instance.Glare = 0
		elseif instance:IsA("Explosion") then
			pcall(function()
				instance.Visible = false
			end)
		end
	end
	local function Nyx_prepareFpsWorld()
		if NyxConfig._fpsWorldReady then
			return true
		end

		local Nyx_prepareFpsWorld_var1 = false
		local Nyx_fpsListenersList = {}
		local ok, result = pcall(function()
			local function Nyx_applyFpsWorldToDescendant(descendant)
				if Nyx_isVisualTool(descendant) then
					return
				end

				Nyx_flattenPartMaterial(descendant)
				Nyx_disableVisualEffects(descendant)
			end

			local Nyx_fpsRoots = {
				workspace,
				game:GetService("Lighting")
			}

			for _, v in ipairs(Nyx_fpsRoots) do
				table.insert(Nyx_fpsListenersList, v.DescendantAdded:Connect(function(descendant)
					task.defer(Nyx_applyFpsWorldToDescendant, descendant)
				end))
			end

			local Nyx_fpsNodeList = {}

			for _, v in ipairs(Nyx_fpsRoots) do
				for _, child in ipairs(v:GetChildren()) do
					table.insert(Nyx_fpsNodeList, child)
				end
			end

			local Nyx_applyFpsWorldToDescendant_var1 = 0

			while #Nyx_fpsNodeList > 0 do
				local Nyx_fpsNode = table.remove(Nyx_fpsNodeList)

				Nyx_applyFpsWorldToDescendant(Nyx_fpsNode)

				for _, child in ipairs(Nyx_fpsNode:GetChildren()) do
					table.insert(Nyx_fpsNodeList, child)
				end

				Nyx_applyFpsWorldToDescendant_var1 += 1

				if Nyx_applyFpsWorldToDescendant_var1 >= 250 and #Nyx_fpsNodeList > 0 then
					Nyx_applyFpsWorldToDescendant_var1 = 0
					RunService.Heartbeat:Wait()
				end
			end

			Nyx_prepareFpsWorld_var1 = true
		end)

		if ok then
			return Nyx_prepareFpsWorld_var1
		end

		for _, v in ipairs(Nyx_fpsListenersList) do
			v:Disconnect()
		end

		warn("[FPSBoost] Gagal flatten material workspace:", result)

		return false
	end
	local function Nyx_prepareFpsAreas()
		if NyxConfig._fpsAreasReady then
			return true
		end

		local Nyx_worldRoot = Nyx_getWorkspaceWorld()
		local Areas = Nyx_worldRoot and Nyx_worldRoot:FindFirstChild("Areas")
		local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
		local Build = Nyx_worldRoot and Nyx_worldRoot:FindFirstChild("Build")

		if not GuardAreas or not Build then
			return false
		end

		for _, child in ipairs(GuardAreas:GetChildren()) do
			local RequiredSpeedSign = child:FindFirstChild("RequiredSpeedSign")

			if RequiredSpeedSign then
				pcall(function()
					RequiredSpeedSign:Destroy()
				end)
			end
		end

		local MainMap = Build:FindFirstChild("MainMap")
		local Bases = MainMap and MainMap:FindFirstChild("Bases")

		local function Nyx_isFpsKeepPart(part)
			if Bases and part:IsDescendantOf(Bases) then
				return part.Size.Y <= 5 and not string.find(string.upper(part.Name), "WALL", 1, true)
			end

			local Parent = part

			while true do
				if not Parent or Parent == Build then
					return false
				end

				if not string.find(string.upper(Parent.Name), "BOTTOM", 1, true) then
					Parent = Parent.Parent

					continue
				end

				break
			end

			return true
		end

		local Nyx_fpsAreaKeywords = {
			"ENCHANTED",
			"FUSEBIOME",
			"WISP",
			"BUTTERFLY",
			"MARKERS",
			"PORTAL",
			"TRIGGER"
		}

		local function Nyx_isFpsKeywordPart(part)
			if part:FindFirstChildOfClass("TouchTransmitter") or part:FindFirstChildWhichIsA("ProximityPrompt", true) then
				return true
			end

			local Parent = part

			while true do
				if not Parent then
					return false
				end

				if Parent == Build then
					return false
				end

				local Nyx_upperParentName = string.upper(Parent.Name)

				for _, v in ipairs(Nyx_fpsAreaKeywords) do
					if string.find(Nyx_upperParentName, v, 1, true) then
						return true
					end
				end

				Parent = Parent.Parent
			end
		end
		local function Nyx_applyFpsAreaFilter(part)
			if not part:IsA("BasePart") then
				return
			end

			if Nyx_isFpsKeywordPart(part) then
				return
			end

			if Nyx_isFpsKeepPart(part) then
				Nyx_flattenPartMaterial(part)
			else
				pcall(function()
					part:Destroy()
				end)
			end
		end

		local connection = Build.DescendantAdded:Connect(function(descendant)
			task.defer(Nyx_applyFpsAreaFilter, descendant)
		end)
		local Nyx_applyFpsAreaFilter_var1 = 0
		local fpsAreaDeleted = 0

		for _, descendant in ipairs(Build:GetDescendants()) do
			local Nyx_hadParentBeforeFilter = descendant.Parent ~= nil

			Nyx_applyFpsAreaFilter(descendant)

			if Nyx_hadParentBeforeFilter and descendant.Parent == nil then
				fpsAreaDeleted += 1
			end

			Nyx_applyFpsAreaFilter_var1 += 1

			if Nyx_applyFpsAreaFilter_var1 >= 250 then
				Nyx_applyFpsAreaFilter_var1 = 0
				RunService.Heartbeat:Wait()
			end
		end

		NyxConfig._fpsAreaListener = connection
		NyxConfig._fpsAreaDeleted = fpsAreaDeleted
		NyxConfig._fpsAreasReady = true

		return true
	end
	local function Nyx_prepareFpsPlots()
		if NyxConfig._fpsPlotsReady then
			return true
		end

		local Nyx_prepareFpsPlots_var1 = false
		local ok, result = pcall(function()
			local PlotState2 = require(game:GetService("ReplicatedStorage").Client.PlotState)

			if PlotState2.GetMySlot() == nil then
				warn("[FPSBoost] Slot plot kita belum ke-resolve, skip delete plot dulu (biar aman).")

				return
			end

			local function Nyx_isLocalPlot(plotChild)
				local Nyx_localPlotSlotId = PlotState2.GetMySlot()

				return Nyx_localPlotSlotId ~= nil and plotChild.Name == tostring(Nyx_localPlotSlotId)
			end

			local Plots = PlotState2.GetPlotsFolder() or workspace:WaitForChild("Plots", 10)

			if not Plots then
				warn("[FPSBoost] workspace.Plots gak ketemu sama sekali.")

				return
			end

			local children = Plots:GetChildren()
			local Nyx_isLocalPlot_var1 = 0

			for _, child in ipairs(children) do
				if not Nyx_isLocalPlot(child) and pcall(function()
					child:Destroy()
				end) then
					Nyx_isLocalPlot_var1 += 1
				end
			end

			Plots.ChildAdded:Connect(function(child)
				task.defer(function()
					if child.Parent then
						if not Nyx_isLocalPlot(child) then
							pcall(function()
								child:Destroy()
							end)
						end
					end
				end)
			end)
			Nyx_prepareFpsPlots_var1 = true
		end)

		if ok then
			return Nyx_prepareFpsPlots_var1
		end

		warn("[FPSBoost] Gagal delete plot pemain lain:", result)

		return false
	end
	local function Nyx_prepareFpsTreadmills()
		if NyxConfig._fpsTreadmillsReady then
			return true
		end

		local Nyx_prepareFpsTreadmills_var1 = false
		local ok, result = pcall(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local PlotState2 = require(ReplicatedStorage2.Client.PlotState)
			local Nyx_prepareFpsTreadmills_var2
			local Modules = ReplicatedStorage2.Client:FindFirstChild("Modules") or ReplicatedStorage2.Client:WaitForChild("Modules", 10)
			local RuntimeInstanceRegistry = Modules and (Modules:FindFirstChild("RuntimeInstanceRegistry") or Modules:WaitForChild("RuntimeInstanceRegistry", 10))

			if RuntimeInstanceRegistry then
				local ok, result = pcall(require, RuntimeInstanceRegistry)

				if ok then
					Nyx_prepareFpsTreadmills_var2 = result
				end
			end

			local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders") or workspace:WaitForChild("__ClientTreadmillRenders", 10)

			if not __ClientTreadmillRenders then
				return
			end

			local function Nyx_resolveTreadmillRender()
				local Nyx_localTreadmillSlot = PlotState2.GetMySlot()

				if Nyx_localTreadmillSlot == nil then
					return nil
				end

				local Nyx_localTreadmillRender = __ClientTreadmillRenders:FindFirstChild("TreadmillRender_" .. tostring(Nyx_localTreadmillSlot))

				if Nyx_localTreadmillRender then
					return Nyx_localTreadmillRender
				end

				local Peek = Nyx_prepareFpsTreadmills_var2 and (Nyx_prepareFpsTreadmills_var2.Peek or Nyx_prepareFpsTreadmills_var2.Get)

				if not Peek then
					return nil
				end

				local ok, result = pcall(Peek, "TreadmillPlotRender", tostring(Nyx_localTreadmillSlot))

				if ok then
					return result
				end

				return nil
			end
			local function Nyx_isLocalTreadmillRender(model)
				local Nyx_localTreadmillRender2 = Nyx_resolveTreadmillRender()

				if Nyx_localTreadmillRender2 and model == Nyx_localTreadmillRender2 then
					return true
				end

				local ok, result = pcall(function()
					return model:GetPivot().Position
				end)

				if not ok then
					return true
				end

				local ok2, result2 = pcall(PlotState2.IsWorldPositionWithinLocalPlotBounds, result)
				local Nyx_localPointInsidePlot = ok2 and result2

				return Nyx_localPointInsidePlot
			end

			local children = __ClientTreadmillRenders:GetChildren()
			local Nyx_isLocalTreadmillRender_var1 = 0

			for _, child in ipairs(children) do
				if child:IsA("Model") and not Nyx_isLocalTreadmillRender(child) and pcall(function()
					child:Destroy()
				end) then
					Nyx_isLocalTreadmillRender_var1 += 1
				end
			end

			__ClientTreadmillRenders.ChildAdded:Connect(function(child)
				task.defer(function()
					if child.Parent and child:IsA("Model") and not Nyx_isLocalTreadmillRender(child) then
						pcall(function()
							child:Destroy()
						end)
					end
				end)
			end)
			Nyx_prepareFpsTreadmills_var1 = true
		end)

		if ok then
			return Nyx_prepareFpsTreadmills_var1
		end

		warn("[FPSBoost] Gagal delete treadmill pemain lain:", result)

		return false
	end

	Nyx_leftTreadmillCheck_var3 = function()
		if Nyx_v390_var2 or NyxConfig._fpsBoostApplying then
			return
		end

		NyxConfig._fpsBoostApplying = true

		local ok, result = pcall(function()
			Nyx_applyFpsBoostBase()
			NyxConfig._fpsPlotsReady = Nyx_prepareFpsPlots() == true
			NyxConfig._fpsTreadmillsReady = Nyx_prepareFpsTreadmills() == true
			NyxConfig._fpsAreasReady = Nyx_prepareFpsAreas() == true
			NyxConfig._fpsWorldReady = Nyx_prepareFpsWorld() == true
			NyxConfig._fpsPetsReady = Nyx_prepareFpsPetHiding() == true
			NyxConfig._fpsEggsReady = Nyx_prepareFpsEggHiding() == true
			Nyx_v390_var2 = NyxConfig._fpsEggsReady and NyxConfig._fpsPetsReady and NyxConfig._fpsWorldReady and NyxConfig._fpsPlotsReady and NyxConfig._fpsTreadmillsReady and NyxConfig._fpsAreasReady
		end)

		NyxConfig._fpsBoostApplying = nil

		if not ok then
			warn("[FPSBoost] Gagal menerapkan FPS Boost:", result)
		end
	end
end

local function Nyx_hasLineOfSight(startPos, endPos, characterFilter)
	local Nyx_hasLineOfSight_var1 = true

	pcall(function()
		local filterDescendantsInstances = { characterFilter }
		local raycastParams = RaycastParams.new()

		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local Nyx_rayStartPos = startPos

		for i = 1, 8 do
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances

			local Nyx_rayDirection = endPos - Nyx_rayStartPos

			if Nyx_rayDirection.Magnitude < 1 then
				break
			end

			local hit = workspace:Raycast(Nyx_rayStartPos, Nyx_rayDirection, raycastParams)

			if not hit then
				break
			end

			if not hit.Instance.CanCollide then
				table.insert(filterDescendantsInstances, hit.Instance)
				Nyx_rayStartPos = hit.Position + Nyx_rayDirection.Unit * 0.1

				continue
			end

			Nyx_hasLineOfSight_var1 = false

			break
		end
	end)

	return Nyx_hasLineOfSight_var1
end

local Nyx_AutoLoops = {}
local ProximityPromptService = game:GetService("ProximityPromptService")
local Nyx_Blocker = {
	TITLES = {
		auto_steal = "Auto Steal",
		mech_boss = "Mech Boss",
		butterfly = "Butterfly Bloom",
		auto_place = "Auto Place",
		treadmill = "Treadmill"
	},
	ORDER = {
		"auto_steal",
		"mech_boss",
		"butterfly",
		"auto_place",
		"treadmill"
	}
}

do
	local function Nyx_isAutoStealBlocked(operation)
		if operation == "auto_steal" then
			local __NyxStealWantsCharacter = genv.__NyxStealWantsCharacter

			return __NyxStealWantsCharacter ~= nil and __NyxStealWantsCharacter() == true
		end

		if operation ~= "mech_boss" then
			if operation == "butterfly" then
				local __NyxButterflyRuntime = genv.__NyxButterflyRuntime

				return __NyxButterflyRuntime ~= nil and __NyxButterflyRuntime.wantsCharacter == true
			end

			if operation == "auto_place" then
				return NyxConfig.IsPlacing == true
			end

			return false
		end

		if LocalPlayer:GetAttribute("InScrambleArena") == true then
			return true
		end

		if NyxConfig.ScrambleBossAuto ~= true then
			return false
		end

		local ScrambleArena = workspace:FindFirstChild("ScrambleArena")
		local Nyx_scramblePortalPresent = workspace:FindFirstChild("ScrambleArenaPortal") ~= nil

		if not Nyx_scramblePortalPresent then
			Nyx_scramblePortalPresent = ScrambleArena ~= nil

			if Nyx_scramblePortalPresent then
				Nyx_scramblePortalPresent = tostring(ScrambleArena:GetAttribute("Phase") or "") ~= ""
			end

			Nyx_scramblePortalPresent = Nyx_scramblePortalPresent and ScrambleArena:GetAttribute("Phase") ~= "Defeated"
		end

		return Nyx_scramblePortalPresent
	end
	local function Nyx_isAutoStealRunning(operation)
		if operation == "auto_steal" then
			local __NyxEggRuntime = genv.__NyxEggRuntime

			return __NyxEggRuntime ~= nil and __NyxEggRuntime.enabled == true and (__NyxEggRuntime.running == true or __NyxEggRuntime.carry ~= nil and __NyxEggRuntime.carry.active == true)
		end

		if operation == "mech_boss" then
			return LocalPlayer:GetAttribute("InScrambleArena") == true
		end

		if operation ~= "butterfly" then
			if operation == "auto_place" then
				return NyxConfig.IsPlacing == true
			end

			return false
		end

		local __NyxButterflyRuntime = genv.__NyxButterflyRuntime

		return __NyxButterflyRuntime ~= nil and __NyxButterflyRuntime.active == true
	end

	Nyx_Blocker.blocker = function(operation)
		if operation ~= "mech_boss" and LocalPlayer:GetAttribute("InScrambleArena") == true then
			return "mech_boss"
		end

		for _, v in ipairs(Nyx_Blocker.ORDER) do
			if v == operation then
				return nil
			end

			if Nyx_isAutoStealBlocked(v) then
				return v
			end
		end

		return nil
	end
	Nyx_Blocker.holder = function(operation)
		for _, v in ipairs(Nyx_Blocker.ORDER) do
			if v ~= operation and v ~= "treadmill" then
				if Nyx_isAutoStealRunning(v) then
					return v
				end
			end
		end

		return nil
	end
end

local Nyx_catalog, Nyx_eggRuntime, Nyx_treadmillManager, Nyx_antiGuard, Nyx_godMode

do
	local function Nyx_CoordinatorFactory()
		local Nyx_Coordinator = {}

		Nyx_Coordinator.__index = Nyx_Coordinator

		local Nyx_foregroundOps = {
			auto_place = true,
			auto_fuse = true,
			equip_best = true
		}
		local Nyx_operationPriority = {
			auto_steal = 100,
			auto_hatch = 80,
			auto_place = 70,
			auto_fuse = 50,
			equip_best = 40,
			rewards = 20
		}

		local function Nyx_cloneTable(sourceTable)
			local Nyx_clonedTable = {}

			for k, v in pairs(sourceTable) do
				Nyx_clonedTable[k] = v
			end

			return Nyx_clonedTable
		end

		Nyx_Coordinator.new = function()
			local obj = setmetatable({}, Nyx_Coordinator)

			obj.destroyed = false
			obj.active = nil
			obj.background = nil
			obj.reservations = {}
			obj.listeners = {}
			obj.backgroundListeners = {}
			obj.serial = 0

			return obj
		end
		Nyx_Coordinator._snapshot = function(self)
			local active = self.active

			return {
				busy = active ~= nil,
				operation = active and active.owner or nil,
				priority = active and active.priority or 0,
				reservedCount = active and #active.uids or 0,
				reservations = Nyx_cloneTable(self.reservations)
			}
		end
		Nyx_Coordinator._emit = function(self)
			local Nyx_coordinatorSnapshot = self:_snapshot()

			for k in pairs(self.listeners) do
				local ok, result = pcall(k, Nyx_coordinatorSnapshot)

				if not ok then
					warn("[StealAnEgg] Coordinator listener failed:", result)
				end
			end
		end
		Nyx_Coordinator._emitBackground = function(self)
			local background = self.background
			local Nyx_bgState = {
				busy = background ~= nil
			}
			local owner = background and background.owner

			Nyx_bgState.operation = owner or nil

			for k in pairs(self.backgroundListeners) do
				local ok, result = pcall(k, Nyx_bgState)

				if not ok then
					warn("[StealAnEgg] Background coordinator listener failed:", result)
				end
			end
		end
		Nyx_Coordinator.subscribe = function(self, listener)
			self.listeners[listener] = true
			pcall(listener, self:_snapshot())

			local function Nyx_unsubscribe()
				self.listeners[listener] = nil
			end

			return Nyx_unsubscribe
		end
		Nyx_Coordinator.subscribeBackground = function(self, listener)
			self.backgroundListeners[listener] = true
			pcall(listener, {
				busy = self.background ~= nil,
				operation = self.background and self.background.owner or nil
			})

			local function Nyx_unsubscribeBackground()
				self.backgroundListeners[listener] = nil
			end

			return Nyx_unsubscribeBackground
		end
		Nyx_Coordinator.getSnapshot = function(self)
			return self:_snapshot()
		end
		Nyx_Coordinator.isBackgroundBusy = function(self)
			return self.background ~= nil
		end
		Nyx_Coordinator.isReserved = function(self, uid, owner)
			local Nyx_reservedBy = self.reservations[uid]

			return Nyx_reservedBy ~= nil and Nyx_reservedBy ~= owner
		end
		Nyx_Coordinator.tryAcquire = function(self, owner, uids, priority)
			if self.destroyed then
				return nil, "Coordinator destroyed"
			end

			if type(owner) ~= "string" or owner == "" then
				return nil, "Invalid operation owner"
			end

			if self.active then
				return nil, "Busy: " .. self.active.owner
			end

			if self.background and Nyx_foregroundOps[owner] then
				return nil, "Busy: background " .. self.background.owner
			end

			local Nyx_fgUids = {}
			local Nyx_fgUniqueUids = {}
			local ipairs_ = ipairs
			local Nyx_acquireUids = type(uids) == "table" and uids or {}

			for _, v in ipairs_(Nyx_acquireUids) do
				if type(v) == "string" and v ~= "" and not Nyx_fgUniqueUids[v] then
					if self:isReserved(v, owner) then
						return nil, "UID reserved by " .. tostring(self.reservations[v])
					end

					Nyx_fgUniqueUids[v] = true
					table.insert(Nyx_fgUids, v)
				end
			end

			self.serial += 1

			local active = {
				id = self.serial,
				lane = "foreground",
				owner = owner,
				priority = tonumber(priority) or Nyx_operationPriority[owner] or 0,
				uids = Nyx_fgUids,
				released = false
			}

			self.active = active

			for _, v in ipairs(Nyx_fgUids) do
				self.reservations[v] = owner
			end

			self:_emit()

			return active
		end
		Nyx_Coordinator.tryAcquireBackground = function(self, owner, uids)
			if self.destroyed then
				return nil, "Coordinator destroyed"
			end

			if type(owner) ~= "string" or owner == "" then
				return nil, "Invalid operation owner"
			end

			if self.background then
				return nil, "Background busy: " .. self.background.owner
			end

			if self.active and Nyx_foregroundOps[self.active.owner] then
				return nil, "Foreground tool busy: " .. self.active.owner
			end

			local Nyx_bgUids = {}
			local Nyx_bgUniqueUids = {}
			local ipairs_ = ipairs
			local Nyx_acquireBackgroundUids = type(uids) == "table" and uids or {}

			for _, v in ipairs_(Nyx_acquireBackgroundUids) do
				if type(v) == "string" and v ~= "" and not Nyx_bgUniqueUids[v] then
					if self:isReserved(v, owner) then
						return nil, "UID reserved by " .. tostring(self.reservations[v])
					end

					Nyx_bgUniqueUids[v] = true
					table.insert(Nyx_bgUids, v)
				end
			end

			self.serial += 1

			local background = {
				id = self.serial,
				lane = "background",
				owner = owner,
				priority = 0,
				uids = Nyx_bgUids,
				released = false
			}

			self.background = background

			for _, v in ipairs(Nyx_bgUids) do
				self.reservations[v] = owner
			end

			self:_emitBackground()

			return background
		end
		Nyx_Coordinator.release = function(self, token)
			if type(token) ~= "table" or token.released then
				return false
			end

			token.released = true

			local ipairs_ = ipairs
			local uids = token.uids or {}

			for _, uid in ipairs_(uids) do
				if self.reservations[uid] == token.owner then
					self.reservations[uid] = nil
				end
			end

			local Nyx_isForegroundActive = self.active == token

			if Nyx_isForegroundActive then
				self.active = nil
			elseif self.background == token then
				self.background = nil
				self:_emitBackground()
			end

			if Nyx_isForegroundActive then
				self:_emit()
			end

			return true
		end
		Nyx_Coordinator.destroy = function(self)
			if self.destroyed then
				return
			end

			self.destroyed = true

			if self.active then
				self:release(self.active)
			end

			if self.background then
				self:release(self.background)
			end

			table.clear(self.reservations)
			table.clear(self.listeners)
			table.clear(self.backgroundListeners)
		end

		return Nyx_Coordinator
	end

	local Nyx_coordinator = Nyx_CoordinatorFactory()

	local function Nyx_catalogFactory()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local Areas = require(ReplicatedStorage2.Data.Areas)
		local Assets = require(ReplicatedStorage2.Data.Assets)
		local Guards = require(ReplicatedStorage2.Data.Guards)
		local Mutations = require(ReplicatedStorage2.Shared.Modules.Mutations)
		local Nyx_rarityRank = {
			Common = 1,
			Uncommon = 2,
			Rare = 3,
			Epic = 4,
			Legendary = 5,
			Mythic = 6,
			Cosmic = 7,
			Secret = 8,
			Eternal = 9,
			Divine = 10
		}

		local function Nyx_dedupStringList(list)
			local Nyx_stringSet = {}
			local Nyx_nameDedup = {}

			for _, v in ipairs(list) do
				if type(v) == "string" and v ~= "" and not Nyx_stringSet[v] then
					Nyx_stringSet[v] = true
					table.insert(Nyx_nameDedup, v)
				end
			end

			table.sort(Nyx_nameDedup)

			return Nyx_nameDedup
		end

		return {
			rarityRank = function(rarity)
				return Nyx_rarityRank[rarity] or 0
			end,
			getRarities = function()
				local Nyx_rarityListSorted = {}

				for k in pairs(Assets.ByRarity) do
					table.insert(Nyx_rarityListSorted, k)
				end

				table.sort(Nyx_rarityListSorted, function(rarityA, rarityB)
					local Nyx_rankA = Nyx_rarityRank[rarityA] or 99
					local Nyx_rankB = Nyx_rarityRank[rarityB] or 99

					if Nyx_rankA == Nyx_rankB then
						return tostring(rarityA) < tostring(rarityB)
					end

					return Nyx_rankA < Nyx_rankB
				end)

				return Nyx_rarityListSorted
			end,
			getNames = function()
				local Nyx_assetNames = {}

				for _, v in pairs(Assets.Directory) do
					table.insert(Nyx_assetNames, v.DisplayName or v._id)
				end

				return Nyx_dedupStringList(Nyx_assetNames)
			end,
			getAreas = function()
				local Nyx_areaListSorted = {}

				for k, v in pairs(Areas.Directory) do
					if type(k) == "string" and type(v) == "table" and type(v.DropTable) == "table" then
						table.insert(Nyx_areaListSorted, k)
					end
				end

				table.sort(Nyx_areaListSorted, function(areaA, areaB)
					local Nyx_guardSpeedA = Guards.Directory[areaA]
					local Nyx_guardSpeedB = Guards.Directory[areaB]
					local WalkSpeed = Nyx_guardSpeedA and Nyx_guardSpeedA.WalkSpeed or math.huge
					local WalkSpeed2 = Nyx_guardSpeedB and Nyx_guardSpeedB.WalkSpeed

					WalkSpeed2 = WalkSpeed2 or math.huge

					if WalkSpeed == WalkSpeed2 then
						return areaA < areaB
					end

					return WalkSpeed < WalkSpeed2
				end)

				return Nyx_areaListSorted
			end,
			getMutations = function()
				local Nyx_mutationLabels = {}
				local Nyx_mutationIds = Mutations.Ids()
				local pairs_ = pairs
				local Nyx_mutationIdsSafe = type(Nyx_mutationIds) == "table" and Nyx_mutationIds or {}

				for k in pairs_(Nyx_mutationIdsSafe) do
					if type(k) == "string" and k ~= Mutations.NO_MUTATION then
						local ok, result = pcall(Mutations.LabelOf, k)

						table.insert(Nyx_mutationLabels, ok and type(result) == "string" and result ~= "" and result or k)
					end
				end

				return Nyx_dedupStringList(Nyx_mutationLabels)
			end,
			resolveMutationId = function(mutationId)
				if type(mutationId) ~= "string" then
					return nil
				end

				if Mutations.IdSet[mutationId] then
					return mutationId
				end

				for k in pairs(Mutations.Ids()) do
					if k ~= Mutations.NO_MUTATION and Mutations.LabelOf(k) == mutationId then
						return k
					end
				end

				return nil
			end,
			resolve = function(eggRecord)
				local Nyx_assetDef = eggRecord and Assets.Directory[eggRecord.AssetCategory]
				local Rarity = Nyx_assetDef and Nyx_assetDef.Rarity
				local DisplayName = Rarity and (Rarity.DisplayName or Rarity._id) or "Unknown"

				return {
					name = Nyx_assetDef and (Nyx_assetDef.DisplayName or Nyx_assetDef._id) or eggRecord and eggRecord.AssetCategory or "Unknown",
					category = eggRecord and eggRecord.AssetCategory or "Unknown",
					rarity = DisplayName,
					rarityRank = Nyx_rarityRank[DisplayName] or 0,
					rarityColor = Rarity and Rarity.Color or nil,
					icon = Nyx_assetDef and type(Nyx_assetDef.Icon) == "string" and Nyx_assetDef.Icon or nil
				}
			end
		}
	end

	Nyx_catalog = Nyx_catalogFactory()

	local function Nyx_findLimitsModule(scriptObject)
		if not scriptObject then
			return nil
		end

		for _, descendant in ipairs(scriptObject:GetDescendants()) do
			if not descendant:IsA("ModuleScript") or not (descendant.Name == "Limits" and descendant.Parent) then
				continue
			end

			if not descendant.Parent:FindFirstChild("Surface") then
				continue
			end

			if descendant.Parent:FindFirstChild("Runtime") then
				return descendant
			end
		end

		return nil
	end

	local Nyx_limitsModule = Nyx_findLimitsModule(LocalPlayer:FindFirstChildOfClass("PlayerScripts")) or Nyx_findLimitsModule(game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts"))

	local function Nyx_EggRuntimeFactory()
		local Players2 = game:GetService("Players")
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local RunService2 = game:GetService("RunService")
		local LocalPlayer2 = Players2.LocalPlayer
		local EggState2 = require(ReplicatedStorage2.Client.EggState)
		local Remotes = require(ReplicatedStorage2.Shared.Remotes)
		local EggWorld = Remotes.EggWorld
		local AreaEggs = require(ReplicatedStorage2.Shared.Types.AreaEggs)
		local AreaEggSlotIdentity = require(ReplicatedStorage2.Shared.Util.AreaEggSlotIdentity)
		local AreaEggResetWall3 = require(ReplicatedStorage2.Client.AreaEggResetWall)
		local SpeedPowerProjection = require(ReplicatedStorage2.Client.SpeedPowerProjection)
		local TreadmillUtil = require(ReplicatedStorage2.Shared.Util.TreadmillUtil)
		local EggRecords = require(ReplicatedStorage2.Shared.Util.EggRecords)
		local AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
		local Save = require(ReplicatedStorage2.Shared.Save)
		local PlotState2 = require(ReplicatedStorage2.Client.PlotState)

		local function Nyx_getMaxSpeedClamp()
			return genv.__NyxAdminBoost == true and 3000 or 1000
		end

		local Nyx_priorityRarities = {
			Divine = true,
			Eternal = true
		}
		local Nyx_integritySampleFields = {
			"LastObservedSample",
			"LastSample",
			"LastGoodSample",
			"LastGameplayTrustedSample",
			"LastValidatedSample",
			"LastValidatedGroundedSample",
			"LastConfirmedGroundSample",
			"CandidateGroundedSample"
		}
		local vector32 = Vector3.new(544.76, 71.5, -416.48)
		local Nyx_handoffLanes = {
			-364.3,
			-367.21,
			-371.12,
			-375.65
		}

		cFrameNew(599.8, 113.5, -325)
		Vector3.new(599.8, 70, -325)

		local cFrame = cFrameNew(616.749, 71.667, -395.585)
		local Nyx_decoyDestroyFilter = {
			Script = true,
			LocalScript = true,
			BillboardGui = true,
			Sound = true
		}
		local Nyx_EggRuntime = {}

		Nyx_EggRuntime.__index = Nyx_EggRuntime

		local Stats = game:GetService("Stats")

		local function Nyx_getMaxSpeedClamp_var1(uid, slotKey)
			local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

			if HumanoidRootPart then
				pcall(function()
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end)
			end

			local Nyx_v730_var1 = 0

			pcall(function()
				Nyx_v730_var1 = Stats.Network.ServerStats.Ping:GetValue()
			end)
			task.wait(math.max(0.3, Nyx_v730_var1 * 2.5 / 1000))

			local Nyx_carryRequest = {
				Uid = uid
			}

			if slotKey ~= nil then
				Nyx_carryRequest.FirstAreaSlotKey = slotKey
			end

			local response, Nyx_carryResponse = EggWorld.AskFieldEggCarry:InvokeServer(Nyx_carryRequest)
			local Nyx_carrySuccess = response == true
			local Nyx_carryError = typeof(Nyx_carryResponse) == "string" and Nyx_carryResponse or nil

			return Nyx_carrySuccess, Nyx_carryError
		end
		local function Nyx_connectSafe(signal, callback, connectionList)
			local connection = signal:Connect(callback)

			table.insert(connectionList, connection)

			return connection
		end
		local function Nyx_disconnectAll(connectionList)
			for _, v in ipairs(connectionList) do
				pcall(v.Disconnect, v)
			end

			table.clear(connectionList)
		end
		local function Nyx_disconnectAll_var1(list, value)
			local ipairs_ = ipairs
			local Nyx_listToIterate = list or {}

			for _, v in ipairs_(Nyx_listToIterate) do
				if v == value then
					return true
				end
			end

			return false
		end

		local Nyx_computeRatePerSec

		local function Nyx_v743_var1(func, constantsList)
			if type(func) ~= "function" or type(debug) ~= "table" or type(debug.getconstants) ~= "function" then
				return false
			end

			local ok, result = pcall(debug.getconstants, func)

			if not ok or type(result) ~= "table" then
				return false
			end

			local Nyx_debugConstMap = {}

			for _, v in ipairs(result) do
				if type(v) == "string" then
					Nyx_debugConstMap[v] = true
				end
			end

			for _, v in ipairs(constantsList) do
				if not Nyx_debugConstMap[v] then
					return false
				end
			end

			return true
		end
		local function Nyx_getDebugSource(func)
			if type(func) ~= "function" or type(debug) ~= "table" or type(debug.info) ~= "function" then
				return ""
			end

			local ok, result = pcall(debug.info, func, "s")

			return ok and tostring(result) or ""
		end
		local function Nyx_getDebugSource_var1(character)
			local HumanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if HumanoidRootPart then
				HumanoidRootPart:SetAttribute("KillPartIgnore", true)
			end
		end
		local function Nyx_rebuildHumanoid(model)
			local Humanoid = model and model:FindFirstChildOfClass("Humanoid")

			if not Humanoid or not Humanoid.Parent then
				return false
			end

			pcall(function()
				Humanoid.BreakJointsOnDeath = false
			end)

			local clone = Humanoid:Clone()

			Humanoid:Destroy()
			clone.Parent = model

			local CurrentCamera = workspace.CurrentCamera

			if CurrentCamera then
				CurrentCamera.CameraSubject = clone
			end

			local Animate = model:FindFirstChild("Animate")

			if Animate then
				local clone2 = Animate:Clone()

				Animate:Destroy()
				clone2.Parent = model
			end

			pcall(function()
				clone:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				clone:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				clone:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
				clone:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
				clone:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
				clone:ChangeState(Enum.HumanoidStateType.Running)
			end)

			return true
		end
		local function Nyx_clearHealthPin(model)
			if model._healthPinner then
				pcall(model._healthPinner.Disconnect, model._healthPinner)
				model._healthPinner = nil
			end

			if model._healthChangedConnection then
				pcall(model._healthChangedConnection.Disconnect, model._healthChangedConnection)
				model._healthChangedConnection = nil
			end
		end
		local function Nyx_installHealthPin(self, character)
			Nyx_clearHealthPin(self)

			local Humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local HumanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not Humanoid then
				return false
			end

			local health = math.max(Humanoid.MaxHealth, 100)
			local Nyx_installHealthPin_var2 = false
			local Nyx_installHealthPin_var1 = 0

			local function Nyx_healthPinCallback()
				if Nyx_installHealthPin_var2 or self.destroyed or LocalPlayer2.Character ~= character or not Humanoid.Parent then
					return
				end

				local now = os.clock()

				if now - Nyx_installHealthPin_var1 < 0.1 and Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					return
				end

				Nyx_installHealthPin_var1 = now
				Nyx_installHealthPin_var2 = true
				pcall(function()
					Humanoid.BreakJointsOnDeath = false
					Humanoid.RequiresNeck = false
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

					if Humanoid.Health <= 0 then
						Humanoid.Health = health
					end

					if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
						Humanoid:ChangeState(Enum.HumanoidStateType.Running)
					end

					if HumanoidRootPart and HumanoidRootPart.Parent == character and HumanoidRootPart.Anchored then
						HumanoidRootPart.Anchored = false
					end
				end)
				Nyx_installHealthPin_var2 = false
			end

			Nyx_healthPinCallback()
			self._healthChangedConnection = Humanoid.HealthChanged:Connect(function(health2)
				if health2 <= 0 or health2 < health then
					Nyx_healthPinCallback()
				end
			end)
			self._healthPinner = RunService2.Heartbeat:Connect(Nyx_healthPinCallback)

			return true
		end
		local function Nyx_disableDeathStates(model)
			local Humanoid = model and model:FindFirstChildOfClass("Humanoid")

			if not Humanoid then
				return
			end

			pcall(function()
				Humanoid.BreakJointsOnDeath = false
				Humanoid.RequiresNeck = false
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			end)
		end
		local function Nyx_restoreDeathStates(character)
			local Humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not Humanoid then
				return
			end

			pcall(function()
				if Humanoid.Health <= 0 then
					Humanoid.Health = math.max(Humanoid.MaxHealth, 1)
				end

				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
				Humanoid.BreakJointsOnDeath = true
				Humanoid.RequiresNeck = true
			end)
		end
		local function Nyx_getGenv()
			return getgenv and getgenv() or _G
		end
		local function Nyx_disableGameAntiAfk()
			if type(getconnections) ~= "function" or type(debug) ~= "table" or type(debug.info) ~= "function" or type(debug.getupvalue) ~= "function" then
				return false
			end

			local ok, result = pcall(getconnections, LocalPlayer2.Idled)

			if not (ok and type(result) == "table") then
				return false
			end

			for _, v in ipairs(result) do
				local Function = v.Function

				if type(Function) == "function" and type(v.Disable) == "function" then
					local ok2, result2 = pcall(debug.info, Function, "s")
					local ok3, result3 = pcall(debug.getupvalue, Function, 1)

					if not ok2 or not (type(result2) == "string" and result2:sub(-27) == ".PlayerScripts.Game.AntiAFK" and ok3) then
						continue
					end

					if type(result3) == "number" then
						return (pcall(v.Disable, v))
					end
				end
			end

			return false
		end
		local function Nyx_getOrInitSpoofState()
			local Nyx_genvTable = Nyx_getGenv()
			local __NyxStealAnEggMovementSpoof = Nyx_genvTable.__NyxStealAnEggMovementSpoof

			if type(__NyxStealAnEggMovementSpoof) ~= "table" or __NyxStealAnEggMovementSpoof.Version ~= 436 then
				if type(__NyxStealAnEggMovementSpoof) == "table" then
					__NyxStealAnEggMovementSpoof.Enabled = false
				end

				__NyxStealAnEggMovementSpoof = {
					Version = 436,
					Installed = false,
					Enabled = false,
					Mode = "StateBaseline",
					Humanoid = nil,
					RootPart = nil,
					WalkSpeed = 600
				}
				Nyx_genvTable.__NyxStealAnEggMovementSpoof = __NyxStealAnEggMovementSpoof
			end

			return __NyxStealAnEggMovementSpoof
		end
		local function Nyx_applySpoofWalkSpeed(character, speed)
			local Nyx_spoofState = Nyx_getOrInitSpoofState()

			if not Nyx_spoofState then
				return false
			end

			local Humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local HumanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			Nyx_spoofState.Humanoid = Humanoid
			Nyx_spoofState.RootPart = HumanoidRootPart
			Nyx_spoofState.WalkSpeed = math.clamp(tonumber(speed) or 600, 200, 1350)
			Nyx_spoofState.Enabled = false

			return Humanoid ~= nil and HumanoidRootPart ~= nil
		end
		local function Nyx_clearSpoofState()
			local __NyxStealAnEggMovementSpoof = Nyx_getGenv().__NyxStealAnEggMovementSpoof

			if type(__NyxStealAnEggMovementSpoof) == "table" then
				__NyxStealAnEggMovementSpoof.Enabled = false
				__NyxStealAnEggMovementSpoof.Humanoid = nil
				__NyxStealAnEggMovementSpoof.RootPart = nil
			end
		end
		local function Nyx_findStateViaCallback(rootPart, humanoid, rootPart)
			local Nyx_findStateViaCallback_var1

			if type(getcallbackvalue) == "function" then
				if type(debug) == "table" and type(debug.getupvalue) == "function" then
					local Signal = ReplicatedStorage2:FindFirstChild("Packages") and ReplicatedStorage2.Packages:FindFirstChild("Signal")

					if Signal then
						local ok, result = pcall(require, Signal)

						if ok and type(result) == "table" and type(result.Invoked) == "function" then
							local ok2, result2 = pcall(result.Invoked, "ClientCharacter: GetDebugSnapshot")

							if ok2 and result2 then
								local ok3, result3 = pcall(getcallbackvalue, result2, "OnInvoke")

								if ok3 and type(result3) == "function" then
									local ok4, result4 = pcall(debug.getinfo, result3)

									if ok4 then
										local function Nyx_walkStateDeep(tableInput, depth, visited)
											if Nyx_findStateViaCallback_var1 or type(tableInput) ~= "table" or depth > 3 or visited[tableInput] then
												return
											end

											visited[tableInput] = true

											if rawget(tableInput, "Player") == rootPart and rawget(tableInput, "Character") == rootPart.Character and rawget(tableInput, "Humanoid") == humanoid and rawget(tableInput, "RootPart") == rootPart and type(rawget(tableInput, "SampleHistory")) == "table" and type(rawget(tableInput, "Evidence")) == "table" then
												Nyx_findStateViaCallback_var1 = tableInput

												return
											end

											local Nyx_walkStateDeep_var1 = 0

											for _, v in pairs(tableInput) do
												Nyx_walkStateDeep_var1 += 1

												if Nyx_walkStateDeep_var1 > 128 then
													break
												end

												if type(v) == "table" then
													Nyx_walkStateDeep(v, depth + 1, visited)
												end
											end
										end

										local Nyx_walkStateDeep_var2 = 1
										local nups = result4.nups or 0

										for i = Nyx_walkStateDeep_var2, nups do
											local ok5, result5 = pcall(debug.getupvalue, result3, i)

											if not ok5 or type(result5) ~= "table" then
												continue
											end

											Nyx_walkStateDeep(result5, 0, {})

											if Nyx_findStateViaCallback_var1 then
												break
											end
										end
									end
								end
							end
						end
					end
				end
			end

			if not Nyx_findStateViaCallback_var1 and type(getgc) == "function" then
				local ok, result = pcall(getgc, true)

				if ok and type(result) == "table" then
					for _, v in ipairs(result) do
						if type(v) == "table" and rawget(v, "Player") == rootPart and rawget(v, "Character") == rootPart.Character and rawget(v, "Humanoid") == humanoid and rawget(v, "RootPart") == rootPart and type(rawget(v, "SampleHistory")) == "table" and type(rawget(v, "Evidence")) == "table" then
							Nyx_findStateViaCallback_var1 = v

							break
						end
					end
				end
			end

			return Nyx_findStateViaCallback_var1
		end

		local Nyx_recoveryCache = {
			busy = false,
			nextAt = 0,
			misses = 0,
			found = nil
		}

		local function Nyx_findStateViaGcSweep(player, humanoid, rootPart)
			local found = Nyx_recoveryCache.found

			if type(found) == "table" and rawget(found, "Player") == player and rawget(found, "Character") == player.Character and rawget(found, "Humanoid") == humanoid and rawget(found, "RootPart") == rootPart then
				return found
			end

			if Nyx_recoveryCache.busy or os.clock() < Nyx_recoveryCache.nextAt then
				return nil
			end

			Nyx_recoveryCache.busy = true
			task.spawn(function()
				task.wait()

				local ok, result = pcall(Nyx_findStateViaCallback, player, humanoid, rootPart)
				local Nyx_stateSearchResult = ok and result or nil

				Nyx_recoveryCache.found = Nyx_stateSearchResult
				Nyx_recoveryCache.misses = Nyx_stateSearchResult and 0 or Nyx_recoveryCache.misses + 1
				Nyx_recoveryCache.nextAt = os.clock() + (Nyx_stateSearchResult and 0.2 or Nyx_recoveryCache.misses >= 5 and 10 or 1)
				Nyx_recoveryCache.busy = false
			end)

			return nil
		end
		local function Nyx_applySpeedToState(state, walkSpeed, travelVelocity)
			if type(state) ~= "table" then
				return false
			end

			local value = rawget(state, "RootPart")
			local CFrame_2 = value and value.Parent and value.CFrame

			CFrame_2 = CFrame_2 or nil

			local Position = CFrame_2 and CFrame_2.Position or nil
			local vector33 = typeof(travelVelocity) == "Vector3" and travelVelocity or Vector3.zero

			local function Nyx_applyValuesToSamples(sample)
				if type(sample) == "table" then
					rawset(sample, "WalkSpeed", walkSpeed)

					if CFrame_2 then
						rawset(sample, "CFrame", CFrame_2)
						rawset(sample, "Position", Position)
						rawset(sample, "LinearVelocity", vector33)
						rawset(sample, "AngularVelocity", Vector3.zero)
					end
				end
			end

			for _, v in ipairs(Nyx_integritySampleFields) do
				Nyx_applyValuesToSamples(rawget(state, v))
			end

			local pairs_ = pairs
			local Nyx_sampleHistory = rawget(state, "SampleHistory") or {}

			for _, v in pairs_(Nyx_sampleHistory) do
				Nyx_applyValuesToSamples(v)
			end

			local pairs_2 = pairs
			local Nyx_safeGroundCheckpoints = rawget(state, "SafeGroundCheckpoints") or {}

			for _, v in pairs_2(Nyx_safeGroundCheckpoints) do
				Nyx_applyValuesToSamples(v)
			end

			local value2 = rawget(state, "Evidence")

			if type(value2) == "table" then
				value2.Speed = 0
				value2.Teleport = 0
				value2.Flight = 0
			end

			local value3 = rawget(state, "ImpulseContext")

			if type(value3) == "table" then
				local maxHorizontalSpeed = math.max(tonumber(value3.MaxHorizontalSpeed) or 0, walkSpeed)
				local Nyx_impulseDuration = math.max((tonumber(value3.ExpiresAt) or 0) - (tonumber(value3.StartedAt) or 0), 0.15)

				value3.MaxHorizontalSpeed = maxHorizontalSpeed

				if Position then
					value3.OriginPosition = Position
				end

				value3.MaxHorizontalDistance = math.max(tonumber(value3.MaxHorizontalDistance) or 0, maxHorizontalSpeed * Nyx_impulseDuration + 48)
				Nyx_applyValuesToSamples(value3.PreMovementSafeSample)
			end

			if rawget(state, "CorrectionContext") == nil then
				rawset(state, "FirstSuspiciousAt", nil)

				if rawget(state, "ThreatLevel") == "Observing" then
					rawset(state, "ThreatLevel", "Trusted")
				end
			end

			return true
		end
		local function Nyx_getIntegrityState2()
			local Nyx_genvTable2 = Nyx_getGenv()
			local __NyxStealAnEggIntegritySpoof = Nyx_genvTable2.__NyxStealAnEggIntegritySpoof

			if type(__NyxStealAnEggIntegritySpoof) ~= "table" then
				__NyxStealAnEggIntegritySpoof = {}
				Nyx_genvTable2.__NyxStealAnEggIntegritySpoof = __NyxStealAnEggIntegritySpoof
			end

			return __NyxStealAnEggIntegritySpoof
		end
		local function Nyx_isOwnStateA(player, humanoid, rootPart)
			return type(player) == "table" and rawget(player, "Player") == LocalPlayer2 and rawget(player, "Character") == LocalPlayer2.Character and rawget(player, "Humanoid") == humanoid and rawget(player, "RootPart") == rootPart
		end
		local function Nyx_isOwnStateB(player, humanoid, rootPart)
			return Nyx_isOwnStateA(player, humanoid, rootPart)
		end
		local function Nyx_installSpoofFromCharacter(humanoid, rootPart, walkSpeed)
			local Nyx_spoofState2 = Nyx_getIntegrityState2()
			local State = Nyx_spoofState2.State

			if not Nyx_isOwnStateA(State, humanoid, rootPart) then
				local now = os.clock()

				if now < (Nyx_spoofState2.NextSearchAt or 0) then
					return false
				end

				Nyx_spoofState2.NextSearchAt = now + 0.2
				State = Nyx_findStateViaGcSweep(LocalPlayer2, humanoid, rootPart)
			end

			if not State then
				return false
			end

			if not Nyx_isOwnStateB(State, humanoid, rootPart) then
				Nyx_spoofState2.Enabled = false
				Nyx_spoofState2.Humanoid = humanoid
				Nyx_spoofState2.RootPart = rootPart
				Nyx_spoofState2.State = State

				return false
			end

			Nyx_spoofState2.NextSearchAt = 0
			Nyx_spoofState2.Enabled = true
			Nyx_spoofState2.Humanoid = humanoid
			Nyx_spoofState2.RootPart = rootPart
			Nyx_spoofState2.State = State
			Nyx_spoofState2.WalkSpeed = math.clamp(walkSpeed * 1.35, 200, 1350)
			Nyx_spoofState2.TravelVelocity = Vector3.zero
			Nyx_applySpeedToState(State, Nyx_spoofState2.WalkSpeed, Nyx_spoofState2.TravelVelocity)

			return true
		end
		local function Nyx_updateSpoofSpeed(humanoid, rootPart, walkSpeed, travelVelocity)
			local __NyxStealAnEggIntegritySpoof = Nyx_getGenv().__NyxStealAnEggIntegritySpoof

			if type(__NyxStealAnEggIntegritySpoof) ~= "table" or not __NyxStealAnEggIntegritySpoof.Enabled or __NyxStealAnEggIntegritySpoof.Humanoid ~= humanoid or __NyxStealAnEggIntegritySpoof.RootPart ~= rootPart or not Nyx_isOwnStateB(__NyxStealAnEggIntegritySpoof.State, humanoid, rootPart) then
				return false
			end

			__NyxStealAnEggIntegritySpoof.WalkSpeed = math.clamp(walkSpeed * 1.35, 200, 1350)

			if typeof(travelVelocity) == "Vector3" then
				__NyxStealAnEggIntegritySpoof.TravelVelocity = travelVelocity
			elseif typeof(__NyxStealAnEggIntegritySpoof.TravelVelocity) ~= "Vector3" then
				__NyxStealAnEggIntegritySpoof.TravelVelocity = Vector3.zero
			end

			return Nyx_applySpeedToState(__NyxStealAnEggIntegritySpoof.State, __NyxStealAnEggIntegritySpoof.WalkSpeed, __NyxStealAnEggIntegritySpoof.TravelVelocity)
		end
		local function Nyx_clearSpoofHumanoid(humanoid)
			local __NyxStealAnEggIntegritySpoof = Nyx_getGenv().__NyxStealAnEggIntegritySpoof

			if type(__NyxStealAnEggIntegritySpoof) ~= "table" then
				return
			end

			if humanoid == nil or __NyxStealAnEggIntegritySpoof.Humanoid == humanoid then
				__NyxStealAnEggIntegritySpoof.Enabled = false
				__NyxStealAnEggIntegritySpoof.Humanoid = nil
				__NyxStealAnEggIntegritySpoof.RootPart = nil
				__NyxStealAnEggIntegritySpoof.State = nil
				__NyxStealAnEggIntegritySpoof.TravelVelocity = nil
				__NyxStealAnEggIntegritySpoof.NextSearchAt = 0
			end
		end
		local function Nyx_matchesMutation(record, mutationsList)
			if #mutationsList == 0 then
				return true
			end

			local ipairs_ = ipairs
			local Mutations = record.Mutations or {}

			for _, Mutation in ipairs_(Mutations) do
				if Nyx_disconnectAll_var1(mutationsList, Mutation) then
					return true
				end
			end

			return record.BaseMutation ~= nil and Nyx_disconnectAll_var1(mutationsList, record.BaseMutation)
		end
		local function Nyx_getLegitSpeedFromTreadmill()
			local Nyx_legitWalkSpeed = TreadmillUtil.SpeedPowerToWalkSpeed(SpeedPowerProjection.ReadProjected())
			local Character = LocalPlayer2.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			return math.clamp(math.min(Nyx_legitWalkSpeed, Humanoid and Humanoid.WalkSpeed or Nyx_legitWalkSpeed), 200, 1000)
		end

		Nyx_EggRuntime.new = function(catalog, limits, coordinator)
			local obj = setmetatable({}, Nyx_EggRuntime)

			obj.catalog = catalog
			obj.limitsModule = limits
			obj.coordinator = coordinator
			obj.operationToken = nil
			obj.connections = {}
			obj.listeners = {}
			obj.records = {}
			obj.enabled = false
			obj.userStealEnabled = false
			obj.skippedEggs = {}
			obj.riftWants = {}
			obj.riftOnly = false
			obj.indexObjectiveEnabled = false
			obj.wispObjective = nil
			obj.manualObjectiveEnabled = false
			obj.manualQueue = {}
			obj.manualOrder = {}
			obj.indexCache = {
				at = 0,
				set = {}
			}
			obj.running = false
			obj.safeStarting = false
			obj.movementRetryPending = false
			obj.destroyed = false
			obj.resetBlocked = AreaEggResetWall3.IsSealed()
			obj.gateOpenAt = obj.resetBlocked and math.huge or os.clock()
			obj.activeTween = nil
			obj.activeTarget = nil
			obj.claimPresentationNode = nil
			obj.claimPresentationOriginal = nil
			obj.claimPresentationSuppression = nil
			obj.carry = {
				active = false,
				uid = nil,
				generation = 0
			}
			obj.carryWorker = nil
			obj.tweenRecoveryUid = nil
			obj.planGeneration = 0
			obj.treadmillDecoy = nil
			obj.treadmillDecoyCamera = nil
			obj.treadmillDecoyCameraConnection = nil
			obj.treadmillDecoyCharacterConnection = nil
			obj.treadmillPopupConnection = nil
			obj.treadmillDecoyRealTransparency = nil
			obj.hoverPadOwnerId = string.format("%s:%0.6f", tostring(obj), os.clock())
			obj.instantPhase = nil
			obj.primerUid = nil
			obj.primerUids = {}
			obj.targetUid = nil
			obj.hitTimer = nil
			obj.guardHitBoostInstalled = false
			obj.stats = {
				status = obj.resetBlocked and "Reset wall closed" or "Ready",
				available = 0,
				matching = 0,
				lastTarget = "None",
				lastResult = "Idle"
			}
			obj.config = {
				stealMode = "Fly",
				flyAerial = false,
				flyZigzag = false,
				speed = 600,
				antiTrap = true,
				heaviestFirst = false,
				highestValueFirst = false,
				minWeightKg = 0,
				espEnabled = false,
				espRarity = true,
				espName = true,
				espKg = true,
				espMutation = true,
				espValue = true,
				espPlaced = false,
				espIcon = true,
				espMinRank = 0,
				espMinValue = 0,
				minValuePerSec = 0,
				rarityEnabled = false,
				rarities = {},
				nameEnabled = false,
				names = {},
				areaEnabled = false,
				areas = {},
				mutationEnabled = false,
				mutations = {}
			}
			obj.gameAntiAfkDisabled = Nyx_disableGameAntiAfk()

			if LocalPlayer2.Character then
				Nyx_getDebugSource_var1(LocalPlayer2.Character)

				local Humanoid = LocalPlayer2.Character:FindFirstChildOfClass("Humanoid")

				if Humanoid then
					pcall(function()
						Humanoid.BreakJointsOnDeath = false
						Humanoid.RequiresNeck = false
						Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
						Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
						Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					end)
				end

				Nyx_installHealthPin(obj, LocalPlayer2.Character)
			end

			local ok, result = pcall(function()
				return require(ReplicatedStorage2.Shared.Util.EggRecords)
			end)

			obj.weightUtil = ok and type(result.WeightKgForScale) == "function" and result or nil

			local function Nyx_watchTrapFolder(folder)
				if not folder then
					return
				end

				Nyx_connectSafe(folder.DescendantAdded, function(child)
					if obj.config.antiTrap then
						obj:_purgeTrap(child)
					end
				end, obj.connections)
			end

			Nyx_watchTrapFolder(workspace:FindFirstChild("Transient"))
			Nyx_watchTrapFolder(workspace:FindFirstChild("__DEBRIS"))

			if obj.config.antiTrap then
				obj:_purgeTraps()
			end

			Nyx_connectSafe(workspace.ChildAdded, function(child)
				if child.Name == "Transient" or child.Name == "__DEBRIS" then
					Nyx_watchTrapFolder(child)

					if obj.config.antiTrap then
						obj:_purgeTraps()
					end
				end
			end, obj.connections)
			obj:_replaceSnapshot(EggState2.ReadFieldEggs())
			Nyx_connectSafe(EggState2.FieldRefreshed, function(snapshot)
				obj:_replaceSnapshot(snapshot)
			end, obj.connections)
			Nyx_connectSafe(EggState2.FieldShifted, function(record)
				obj.records[record.Uid] = record
				obj:_refreshCounts()

				if obj.enabled and not obj.destroyed and not obj.running and not obj.carry.active and (record.State == AreaEggs.States.Slot or record.State == AreaEggs.States.Dropped) and not obj._shiftWakePending then
					obj._shiftWakePending = true
					task.delay(0.25, function()
						obj._shiftWakePending = nil

						if not obj.destroyed and obj.enabled then
							if not obj.running then
								obj:_schedule()
							end
						end
					end)
				end
			end, obj.connections)
			Nyx_connectSafe(EggState2.FieldGone, function(uid)
				obj.records[uid] = nil

				if obj.activeTarget and obj.activeTarget.Uid == uid then
					if obj.carry.active and obj.carry.uid == uid then
						obj:_refreshCounts()

						return
					end

					obj.carryAttemptToken = nil
					obj:_clearArrivalHold(uid)

					if obj.activeTween and obj.activeTween.Cancel then
						pcall(obj.activeTween.Cancel, obj.activeTween)
					end

					local activeTarget = obj.activeTarget

					task.delay(0.65, function()
						if obj.destroyed or not obj.enabled then
							return
						end

						if obj.carry.active and obj.carry.uid == uid then
							return
						end

						if obj.activeTarget == activeTarget and activeTarget.Uid == uid then
							obj:_finish("Target removed — continuing")
						end
					end)
				end

				obj:_refreshCounts()
			end, obj.connections)
			Nyx_connectSafe(EggState2.ResetCountdown, function()
				obj:_closeGate("Egg reset countdown")
			end, obj.connections)
			Nyx_connectSafe(EggState2.ResetFade, function()
				obj:_closeGate("Egg reset teleport")
			end, obj.connections)
			Nyx_connectSafe(AreaEggResetWall3.Changed, function(wallClosed)
				if wallClosed then
					obj:_closeGate("Reset wall closed")
				else
					obj.resetBlocked = false
					obj.gateOpenAt = os.clock()
					obj.safeStarting = false
					obj.running = false
					obj:_setStatus(obj.enabled and "Searching" or "Ready")
					obj:_schedule()
				end
			end, obj.connections)
			Nyx_connectSafe(LocalPlayer2.CharacterRemoving, function()
				obj._recalling = nil
				obj:_cleanupInstantSteal()
				obj:_hideTreadmillDecoy()
				obj._forestDropInProgress = nil
				obj._instantReturnToken = nil

				local carry = obj.carry

				carry.generation += 1
				obj:_invalidateCarryWorker()
				obj.carry.active = false
				obj.carry.uid = nil
				obj.safeStarting = false
				obj.planGeneration += 1
				obj:_cancelTween("Character resetting")
				obj:_stopMovementProtection()
			end, obj.connections)
			Nyx_connectSafe(RunService2.Heartbeat, function()
				if obj.destroyed then
					return
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

				if not HumanoidRootPart then
					return
				end

				local AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				local WalkSpeed = Humanoid and Humanoid.WalkSpeed or 0
				local vector33 = Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z)
				local Magnitude = vector33.Magnitude

				if math.max(400, WalkSpeed * 1.5) < Magnitude or math.abs(AssemblyLinearVelocity.Y) > 400 then
					local Nyx_clampedWalkSpeed = math.max(100, WalkSpeed)

					if Nyx_clampedWalkSpeed < vector33.Magnitude then
						vector33 = vector33.Unit * Nyx_clampedWalkSpeed
					end

					HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(vector33.X, math.clamp(AssemblyLinearVelocity.Y, -100, 100), vector33.Z)
				end
			end, obj.connections)
			Nyx_connectSafe(LocalPlayer2.CharacterAdded, function(character)
				obj:_hideTreadmillDecoy()
				Nyx_getDebugSource_var1(character)

				local Humanoid = character:FindFirstChildOfClass("Humanoid")

				if Humanoid then
					pcall(function()
						Humanoid.BreakJointsOnDeath = false
						Humanoid.RequiresNeck = false
						Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
						Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
						Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					end)
				end

				Nyx_installHealthPin(obj, character)
				task.delay(0.25, function()
					if not obj.destroyed and obj.enabled then
						obj:_startMovementProtection()
					end
				end)
				task.delay(1, function()
					if not obj.destroyed and obj.enabled and obj:_wallOpen() then
						obj:_schedule()
					end
				end)
			end, obj.connections)
			obj:_installClaimPresentationFilter()
			Nyx_connectSafe(EggState2.CarryChanged, function(carryData)
				if carryData.IsCarrying then
					if obj.running then
						if obj.activeTarget and carryData.Uid == obj.activeTarget.Uid then
							if obj.carry.active and obj.carry.uid == carryData.Uid then
								return
							end

							if obj.instantPhase == "priming" and carryData.Uid == obj.primerUid then
								obj.carry.active = true
								obj.carry.uid = carryData.Uid
								obj:_clearArrivalHold(carryData.Uid)
								obj:_enterBaitWait()

								return
							end

							local carry = obj.carry

							carry.generation += 1
							obj:_invalidateCarryWorker()
							obj:_clearArrivalHold(carryData.Uid)
							obj.claimPresentationSuppression = {
								assetCategory = obj.activeTarget.AssetCategory,
								expiresAt = os.clock() + 8
							}
							obj.carry.active = true
							obj.carry.uid = carryData.Uid
							obj.carryStartTime = os.clock()
							obj.carryStartPos = obj.activeTarget and obj.activeTarget.BottomCFrame and obj.activeTarget.BottomCFrame.Position or LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer2.Character.HumanoidRootPart.Position

							if obj.tweenRecoveryUid == carryData.Uid then
								obj.tweenRecoveryUid = nil
							end

							if obj.carryTimeouts then
								obj.carryTimeouts[carryData.Uid] = nil
							end

							obj.stats.lastResult = "Carry confirmed"
							obj:_notify()
							obj.carryAttemptToken = nil

							if obj.activeTween and obj.activeTween.Cancel then
								pcall(obj.activeTween.Cancel, obj.activeTween)
							end

							task.defer(function()
								if not obj.destroyed and obj.enabled and obj.carry.uid == carryData.Uid and obj:_hasConfirmedCarry(carryData.Uid) then
									if genv.__NyxGodMode then
										genv.__NyxGodMode:stopDefend()
									end

									obj:_returnToSafe()
								end
							end)
						end
					end

					return
				end

				if obj.carry.uid ~= nil and carryData.Uid ~= nil and carryData.Uid ~= obj.carry.uid then
					return
				end

				local Uid = carryData.Uid or obj.carry.uid

				Uid = Uid or obj.activeTarget and obj.activeTarget.Uid

				local active = obj.carry.active
				local carry = obj.carry

				carry.generation += 1

				local generation = obj.carry.generation

				obj:_invalidateCarryWorker()

				if obj.activeTween and obj.activeTween.Cancel then
					pcall(obj.activeTween.Cancel, obj.activeTween)
				end

				obj.carry.active = false
				obj.carry.uid = nil

				if genv.__NyxGodMode then
					genv.__NyxGodMode:startDefend(Uid)
				end

				if obj._captureHoldUid ~= nil and Uid == obj._captureHoldUid or obj._adminBusyUid ~= nil and Uid == obj._adminBusyUid then
					return
				end

				if obj.instantPhase == "priming" and (carryData.Uid == obj.primerUid or Uid == obj.primerUid) then
					obj:_startPrimerTargetHunt()

					return
				end

				if obj._forestDropInProgress ~= nil and Uid == obj._forestDropInProgress then
					return
				end

				if not active then
					return
				end

				if not obj.running or not obj.activeTarget then
					return
				end

				local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if not HumanoidRootPart or not obj:_isInSafeArea(HumanoidRootPart) then
					task.delay(0.03, function()
						if not obj.destroyed then
							if obj.enabled and not obj.carry.active and obj.carry.generation == generation then
								if LocalPlayer2.Character then
									local HumanoidRootPart2 = LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

									if HumanoidRootPart2 and obj:_isInSafeArea(HumanoidRootPart2) then
										obj:_reportStolen()
										obj:_finish("Safe return complete")

										return
									end
								end

								obj:_reStealDroppedEgg(Uid)

								return
							end
						end
					end)

					return
				end

				obj:_reportStolen()
				obj:_finish("Safe return complete")
			end, obj.connections)
			Nyx_connectSafe(LocalPlayer2:GetAttributeChangedSignal("RagdollEndTime"), function()
				local attribute = LocalPlayer2:GetAttribute("RagdollEndTime") or 0

				if obj.instantPhase == "priming" and workspace:GetServerTimeNow() < attribute then
					obj:_startPrimerTargetHunt()
				end
			end, obj.connections)
			Nyx_connectSafe(RunService2.Heartbeat, function()
				if obj.destroyed then
					return
				end

				local now = os.clock()

				if now - (obj._espLastTick or 0) < 0.4 then
					return
				end

				obj._espLastTick = now

				local ok2, result2 = pcall(function()
					obj:_updateEsp()
				end)

				if not ok2 then
					if now - (obj._espErrLast or 0) > 5 then
						obj._espErrLast = now
						warn("[SAE][esp] update error: " .. tostring(result2))
					end
				end
			end, obj.connections)
			obj.stats.status = obj.stats.status

			return obj
		end
		Nyx_EggRuntime._installClaimPresentationFilter = function()
			return false
		end
		Nyx_EggRuntime._restoreClaimPresentationFilter = function(self)
			local claimPresentationNode = self.claimPresentationNode
			local claimPresentationOriginal = self.claimPresentationOriginal

			if type(claimPresentationNode) == "table" and type(claimPresentationOriginal) == "function" and rawget(claimPresentationNode, "_fn") == self.claimPresentationWrapper then
				claimPresentationNode._fn = claimPresentationOriginal
			end

			self.claimPresentationNode = nil
			self.claimPresentationOriginal = nil
			self.claimPresentationWrapper = nil
			self.claimPresentationSuppression = nil
		end
		Nyx_EggRuntime._setStatus = function(self, newStatus)
			if self.stats.status == newStatus then
				return
			end

			if type(newStatus) == "string" and string.find(newStatus, "not currently trusted", 1, true) then
				self._untrustedSeen = true
			end

			self.stats.status = newStatus
			self:_notify()
		end
		Nyx_EggRuntime._notify = function(self)
			local Nyx_uiSnapshot = self:getSnapshot()

			for k in pairs(self.listeners) do
				local ok, result = pcall(k, Nyx_uiSnapshot)

				if not ok then
					warn("[StealAnEgg] UI listener failed:", result)
				end
			end
		end
		Nyx_EggRuntime.onChanged = function(self, listener)
			self.listeners[listener] = true

			local ok, result = pcall(listener, self:getSnapshot())

			if not ok then
				warn("[StealAnEgg] UI listener failed:", result)
			end

			local function Nyx_unsubscribeUI()
				self.listeners[listener] = nil
			end

			return Nyx_unsubscribeUI
		end
		Nyx_EggRuntime.getSnapshot = function(self)
			return {
				status = self.stats.status,
				available = self.stats.available,
				matching = self.stats.matching,
				lastTarget = self.stats.lastTarget,
				lastResult = self.stats.lastResult,
				wallClosed = self.resetBlocked or AreaEggResetWall3.IsSealed() or os.clock() < self.gateOpenAt,
				enabled = self.enabled,
				running = self.running
			}
		end
		Nyx_EggRuntime._replaceSnapshot = function(self, snapshot)
			table.clear(self.records)

			local Records = snapshot and (snapshot.Records or snapshot) or {}

			for k, Record in pairs(Records) do
				if type(Record) == "table" and type(Record.Uid) == "string" then
					self.records[Record.Uid] = Record
				elseif type(k) == "string" and type(Record) == "table" then
					self.records[k] = Record
				end
			end

			self:_refreshCounts()
			self:_schedule()
		end
		Nyx_EggRuntime._indexWants = function(self)
			local now = os.clock()
			local indexCache = self.indexCache

			if indexCache then
				if now - (indexCache.at or 0) < 2 then
					return indexCache.set
				end
			end

			local Nyx_indexWantSet = {}

			pcall(function()
				local areasDirectory = self.areasDirectory

				if not areasDirectory then
					areasDirectory = require(ReplicatedStorage2.Data.Areas).Directory
					self.areasDirectory = areasDirectory
				end

				local Nyx_saveData = (Save.Peek or Save.Get)()

				if not areasDirectory or not Nyx_saveData then
					return
				end

				local Index = Nyx_saveData.Index or {}
				local Nyx_ownedEggCategories = {}
				local pairs_ = pairs
				local EggInventory = Nyx_saveData.EggInventory or {}

				for _, v in pairs_(EggInventory) do
					local AssetCategory = type(v) == "table" and (v.AssetCategory or v.Category) or nil

					if AssetCategory then
						Nyx_ownedEggCategories[tostring(AssetCategory)] = true
					end
				end

				local uid = self.carry and self.carry.uid

				if uid then
					local Nyx_activeCarryRecord = self.records[uid]

					if Nyx_activeCarryRecord and Nyx_activeCarryRecord.AssetCategory then
						Nyx_ownedEggCategories[tostring(Nyx_activeCarryRecord.AssetCategory)] = true
					end
				end

				for _, v in pairs(areasDirectory) do
					if type(v) == "table" and type(v.DropTable) == "table" then
						for _, Nyx_item in ipairs(v.DropTable) do
							local Nyx_fieldEggTuple = Nyx_item[1]

							if Nyx_fieldEggTuple then
								local Nyx_fieldEggCategory = tostring(Nyx_fieldEggTuple)

								if not Index[Nyx_fieldEggCategory] and not Nyx_ownedEggCategories[Nyx_fieldEggCategory] then
									Nyx_indexWantSet[Nyx_fieldEggCategory] = true
								end
							end
						end
					end
				end
			end)
			self.indexCache = {
				at = now,
				set = Nyx_indexWantSet
			}

			return Nyx_indexWantSet
		end
		Nyx_EggRuntime._isIndexObjective = function(self, record)
			if not self.indexObjectiveEnabled then
				return false
			end

			if type(record) ~= "table" then
				return false
			end

			local AssetCategory = record.AssetCategory

			if not AssetCategory or AssetCategory == "" then
				return false
			end

			return self:_indexWants()[tostring(AssetCategory)] == true
		end
		Nyx_EggRuntime.setIndexObjective = function(self, enabled)
			local indexObjectiveEnabled = enabled == true

			if self.indexObjectiveEnabled == indexObjectiveEnabled then
				return
			end

			self.indexObjectiveEnabled = indexObjectiveEnabled
			self.indexCache = {
				at = 0,
				set = {}
			}
			self:_reconcileRunningState()
		end
		Nyx_EggRuntime._isWispObjective = function(self, record)
			local wispObjective = self.wispObjective

			if type(wispObjective) ~= "table" or type(record) ~= "table" then
				return false
			end

			if wispObjective.area and record.AreaId ~= wispObjective.area then
				return false
			end

			if wispObjective.rarity then
				local Nyx_wispMatch = self.catalog.resolve(record)

				if not Nyx_wispMatch or Nyx_wispMatch.rarity ~= wispObjective.rarity then
					return false
				end
			end

			return true
		end
		Nyx_EggRuntime.setWispObjective = function(self, objective)
			local wispObjectiveKey = type(objective) == "table"

			if wispObjectiveKey then
				wispObjectiveKey = (objective.area or "") .. "|" .. (objective.rarity or "")
			end

			wispObjectiveKey = wispObjectiveKey or nil

			if self.wispObjectiveKey == wispObjectiveKey then
				return
			end

			self.wispObjectiveKey = wispObjectiveKey
			self.wispObjective = wispObjectiveKey and objective or nil
			self:_reconcileRunningState()
		end
		Nyx_EggRuntime.indexMissingCount = function(self)
			local Nyx_unsubscribeUI_var1 = 0

			for _ in pairs(self:_indexWants()) do
				Nyx_unsubscribeUI_var1 += 1
			end

			return Nyx_unsubscribeUI_var1
		end
		Nyx_EggRuntime._matchesNormalFilter = function(self, record)
			local Nyx_resolvedEgg = self.catalog.resolve(record)
			local config = self.config
			local Nyx_unsubscribeUI_var2, Nyx_weightKg, minValuePerSec, minWeightKg

			if config.rarityEnabled then
				if not (#config.rarities ~= 0 and Nyx_disconnectAll_var1(config.rarities, Nyx_resolvedEgg.rarity)) then
					return false
				end

				if config.nameEnabled then
					if #config.names == 0 or not Nyx_disconnectAll_var1(config.names, Nyx_resolvedEgg.name) and not Nyx_disconnectAll_var1(config.names, Nyx_resolvedEgg.category) then
						return false
					end

					if config.areaEnabled then
						if not (#config.areas ~= 0 and Nyx_disconnectAll_var1(config.areas, record.AreaId)) then
							return false
						end

						if config.mutationEnabled then
							if not Nyx_matchesMutation(record, config.mutations) then
								return false
							end

							if (config.minWeightKg or 0) > 0 then
								Nyx_weightKg = self:_resolveWeightKg(record)

								if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
									return false
								end

								if (config.minValuePerSec or 0) > 0 then
									Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

									if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
										return false
									end
								end
							else
								minValuePerSec = config.minValuePerSec or 0

								if minValuePerSec > 0 then
									Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

									if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
										return false
									end
								end
							end
						else
							minWeightKg = config.minWeightKg or 0

							if minWeightKg > 0 then
								Nyx_weightKg = self:_resolveWeightKg(record)

								if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
									return false
								end

								minValuePerSec = config.minValuePerSec or 0

								if minValuePerSec > 0 then
									Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

									if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
										return false
									end
								end
							else
								minValuePerSec = config.minValuePerSec or 0

								if minValuePerSec > 0 then
									Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

									if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
										return false
									end
								end
							end
						end
					elseif config.mutationEnabled then
						if not Nyx_matchesMutation(record, config.mutations) then
							return false
						end

						minWeightKg = config.minWeightKg or 0

						if minWeightKg > 0 then
							Nyx_weightKg = self:_resolveWeightKg(record)

							if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
								return false
							end

							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						else
							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						end
					else
						minWeightKg = config.minWeightKg or 0

						if minWeightKg > 0 then
							Nyx_weightKg = self:_resolveWeightKg(record)

							if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
								return false
							end

							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						else
							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						end
					end
				elseif config.areaEnabled then
					if not (#config.areas ~= 0 and Nyx_disconnectAll_var1(config.areas, record.AreaId)) then
						return false
					end

					if config.mutationEnabled then
						if not Nyx_matchesMutation(record, config.mutations) then
							return false
						end

						minWeightKg = config.minWeightKg or 0

						if minWeightKg > 0 then
							Nyx_weightKg = self:_resolveWeightKg(record)

							if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
								return false
							end

							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						else
							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						end
					else
						minWeightKg = config.minWeightKg or 0

						if minWeightKg > 0 then
							Nyx_weightKg = self:_resolveWeightKg(record)

							if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
								return false
							end

							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						else
							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						end
					end
				elseif config.mutationEnabled then
					if not Nyx_matchesMutation(record, config.mutations) then
						return false
					end

					minWeightKg = config.minWeightKg or 0

					if minWeightKg > 0 then
						Nyx_weightKg = self:_resolveWeightKg(record)

						if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
							return false
						end

						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					else
						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					end
				else
					minWeightKg = config.minWeightKg or 0

					if minWeightKg > 0 then
						Nyx_weightKg = self:_resolveWeightKg(record)

						if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
							return false
						end

						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					else
						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					end
				end
			elseif config.nameEnabled then
				if #config.names == 0 or not Nyx_disconnectAll_var1(config.names, Nyx_resolvedEgg.name) and not Nyx_disconnectAll_var1(config.names, Nyx_resolvedEgg.category) then
					return false
				end

				if config.areaEnabled then
					if not (#config.areas ~= 0 and Nyx_disconnectAll_var1(config.areas, record.AreaId)) then
						return false
					end

					if config.mutationEnabled then
						if not Nyx_matchesMutation(record, config.mutations) then
							return false
						end

						minWeightKg = config.minWeightKg or 0

						if minWeightKg > 0 then
							Nyx_weightKg = self:_resolveWeightKg(record)

							if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
								return false
							end

							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						else
							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						end
					else
						minWeightKg = config.minWeightKg or 0

						if minWeightKg > 0 then
							Nyx_weightKg = self:_resolveWeightKg(record)

							if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
								return false
							end

							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						else
							minValuePerSec = config.minValuePerSec or 0

							if minValuePerSec > 0 then
								Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

								if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
									return false
								end
							end
						end
					end
				elseif config.mutationEnabled then
					if not Nyx_matchesMutation(record, config.mutations) then
						return false
					end

					minWeightKg = config.minWeightKg or 0

					if minWeightKg > 0 then
						Nyx_weightKg = self:_resolveWeightKg(record)

						if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
							return false
						end

						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					else
						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					end
				else
					minWeightKg = config.minWeightKg or 0

					if minWeightKg > 0 then
						Nyx_weightKg = self:_resolveWeightKg(record)

						if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
							return false
						end

						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					else
						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					end
				end
			elseif config.areaEnabled then
				if not (#config.areas ~= 0 and Nyx_disconnectAll_var1(config.areas, record.AreaId)) then
					return false
				end

				if config.mutationEnabled then
					if not Nyx_matchesMutation(record, config.mutations) then
						return false
					end

					minWeightKg = config.minWeightKg or 0

					if minWeightKg > 0 then
						Nyx_weightKg = self:_resolveWeightKg(record)

						if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
							return false
						end

						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					else
						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					end
				else
					minWeightKg = config.minWeightKg or 0

					if minWeightKg > 0 then
						Nyx_weightKg = self:_resolveWeightKg(record)

						if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
							return false
						end

						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					else
						minValuePerSec = config.minValuePerSec or 0

						if minValuePerSec > 0 then
							Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

							if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
								return false
							end
						end
					end
				end
			elseif config.mutationEnabled then
				if not Nyx_matchesMutation(record, config.mutations) then
					return false
				end

				minWeightKg = config.minWeightKg or 0

				if minWeightKg > 0 then
					Nyx_weightKg = self:_resolveWeightKg(record)

					if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
						return false
					end

					minValuePerSec = config.minValuePerSec or 0

					if minValuePerSec > 0 then
						Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

						if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
							return false
						end
					end
				else
					minValuePerSec = config.minValuePerSec or 0

					if minValuePerSec > 0 then
						Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

						if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
							return false
						end
					end
				end
			else
				if (config.minWeightKg or 0) > 0 then
					Nyx_weightKg = self:_resolveWeightKg(record)

					if not Nyx_weightKg or Nyx_weightKg < config.minWeightKg then
						return false
					end

					minValuePerSec = config.minValuePerSec or 0

					if minValuePerSec > 0 then
						Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

						if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
							return false
						end
					end
				else
					if (config.minValuePerSec or 0) > 0 then
						Nyx_unsubscribeUI_var2 = Nyx_computeRatePerSec(record)

						if not Nyx_unsubscribeUI_var2 or Nyx_unsubscribeUI_var2 < config.minValuePerSec then
							return false
						end
					end
				end
			end

			return true
		end
		Nyx_EggRuntime._matches = function(self, record)
			if record.State ~= AreaEggs.States.Slot and record.State ~= AreaEggs.States.Dropped then
				return false
			end

			if self.riftWants[record.AssetCategory] then
				return true
			end

			if self.indexObjectiveEnabled and self:_isIndexObjective(record) then
				return true
			end

			if self.wispObjective and self:_isWispObjective(record) then
				return true
			end

			if self.userStealEnabled and not self.riftOnly and self:_matchesNormalFilter(record) then
				return true
			end

			return false
		end
		Nyx_EggRuntime.setScrambleWants = function(self, uidList, riftOnly)
			local riftWants = {}
			local ipairs_ = ipairs
			local Nyx_riftUidList = type(uidList) == "table" and uidList or {}

			for _, v in ipairs_(Nyx_riftUidList) do
				if type(v) == "string" and v ~= "" then
					riftWants[v] = true
				end
			end

			local riftOnly = riftOnly == true
			local Nyx_riftChanged = riftOnly ~= self.riftOnly

			for k in pairs(riftWants) do
				if not self.riftWants[k] then
					Nyx_riftChanged = true
				end
			end

			for k in pairs(self.riftWants) do
				if not riftWants[k] then
					Nyx_riftChanged = true
				end
			end

			if not Nyx_riftChanged then
				return
			end

			self.riftWants = riftWants
			self.riftOnly = riftOnly
			self:_reconcileRunningState()
		end
		Nyx_EggRuntime._refreshCounts = function(self)
			local available = 0
			local matching = 0

			for _, record in pairs(self.records) do
				if record.State == AreaEggs.States.Slot then
					available += 1

					if self:_matches(record) then
						matching += 1
					end
				end
			end

			self.stats.available = available
			self.stats.matching = matching
			self:_notify()
		end
		Nyx_EggRuntime.hasPriorityRareEgg = function(self)
			local Character = LocalPlayer2.Character

			Character = Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

			local Nyx_bestPriorityRecord
			local Nyx_bestRank
			local Nyx_bestDistance
			local pairs_ = pairs
			local records = self.records or {}

			for _, record in pairs_(records) do
				if (record.State == AreaEggs.States.Slot or record.State == AreaEggs.States.Dropped) and record.BottomCFrame and not self:isSkippedEgg(record.Uid) and self:_matchesNormalFilter(record) then
					local Nyx_bestPriorityEgg = self.catalog.resolve(record)

					if Nyx_priorityRarities[Nyx_bestPriorityEgg.rarity] then
						local Magnitude = Character and (record.BottomCFrame.Position - Character.Position).Magnitude or 0
						local rarityRank = Nyx_bestPriorityEgg.rarityRank or 0

						if not Nyx_bestPriorityRecord or Nyx_bestRank < rarityRank or rarityRank == Nyx_bestRank and Magnitude < Nyx_bestDistance then
							Nyx_bestPriorityRecord = record
							Nyx_bestRank = rarityRank
							Nyx_bestDistance = Magnitude
						end
					end
				end
			end

			return Nyx_bestPriorityRecord ~= nil, Nyx_bestPriorityRecord
		end
		Nyx_EggRuntime.isSkippedEgg = function(self, uid)
			if uid ~= nil then
				if uid == workspace:GetAttribute("Event_CaptureTheEggUid") then
					if not self.captureObjectiveEnabled then
						return true
					end
				end
			end

			local Nyx_skipUntil = uid and self.skippedEggs[uid]

			if not Nyx_skipUntil then
				return false
			end

			if os.clock() < Nyx_skipUntil then
				return true
			end

			self.skippedEggs[uid] = nil

			return false
		end

		do
			Nyx_EggRuntime._isCaptureEgg = function(self, eggUid)
				return eggUid ~= nil and eggUid == workspace:GetAttribute("Event_CaptureTheEggUid")
			end
		end

		Nyx_EggRuntime.setCaptureObjective = function(self, enabled)
			local Nyx_captureObjectiveFlag = enabled == true

			if self.captureObjectiveEnabled == Nyx_captureObjectiveFlag then
				return
			end

			if Nyx_captureObjectiveFlag then
				self._modeBeforeCapture = {
					self.config.stealMode,
					self.config.flyAerial,
					self.config.flyZigzag
				}
				self:setStealMode("Instant", false, false)
				self.captureObjectiveEnabled = true
			else
				self.captureObjectiveEnabled = false

				local _modeBeforeCapture = self._modeBeforeCapture

				self._modeBeforeCapture = nil

				if _modeBeforeCapture then
					self:setStealMode(_modeBeforeCapture[1], _modeBeforeCapture[2], _modeBeforeCapture[3])
				end
			end

			self:_reconcileRunningState()
		end
		Nyx_EggRuntime._captureHold = function(self, uid)
			if self._captureHoldUid == uid then
				return
			end

			self._captureHoldUid = uid

			local function Nyx_stillCapturing()
				local Nyx_captureEggRecord = EggState2.ReadFieldEgg(uid)

				return Nyx_captureEggRecord ~= nil and Nyx_captureEggRecord.State == AreaEggs.States.Carried and Nyx_captureEggRecord.CarrierUserId == LocalPlayer2.UserId
			end
			local function Nyx_captureNotDone()
				return not self.destroyed and self.enabled and self.captureObjectiveEnabled and Nyx_stillCapturing()
			end

			task.spawn(function()
				self:_clearArrivalHold(uid)
				self:_hideTreadmillDecoy()
				pcall(function()
					self:_stopHoverPad()
				end)
				self.stats.lastResult = "Holding capture egg"
				self:_setStatus("Holding capture egg")

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local cFrame2 = HumanoidRootPart and cFrameNew(HumanoidRootPart.Position.X, 110, HumanoidRootPart.Position.Z) * HumanoidRootPart.CFrame.Rotation

				if cFrame2 then
					self:_glideRoot(cFrame2, function()
						return not Nyx_captureNotDone()
					end)
				end

				while Nyx_captureNotDone() do
					local Character2 = LocalPlayer2.Character
					local HumanoidRootPart2 = Character2 and Character2:FindFirstChild("HumanoidRootPart")
					local Humanoid = Character2 and Character2:FindFirstChildOfClass("Humanoid")

					if HumanoidRootPart2 and Humanoid and cFrame2 then
						pcall(function()
							HumanoidRootPart2.CFrame = cFrame2
							HumanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
							HumanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
						end)
						self:_syncHoverPad(cFrame2.Position)

						local Nyx_captureSpeed = math.clamp(self.config.speed or 600, 200, Nyx_getMaxSpeedClamp())

						pcall(function()
							Nyx_applySpoofWalkSpeed(Character2, Nyx_captureSpeed * 1.35)
							Nyx_updateSpoofSpeed(Humanoid, HumanoidRootPart2, Nyx_captureSpeed, Vector3.zero)
						end)
					end

					task.wait(0.1)
				end

				pcall(function()
					self:_stopHoverPad()
				end)

				if self._captureHoldUid == uid then
					self._captureHoldUid = nil
				end

				if self.destroyed or not self.enabled then
					return
				end

				self:_finish(self.captureObjectiveEnabled and "Capture egg lost — re-grabbing" or "Capture stopped")
			end)
		end
		Nyx_EggRuntime._chooseTarget = function(self)
			local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart then
				return nil
			end

			if self.captureObjectiveEnabled then
				local attribute = workspace:GetAttribute("Event_CaptureTheEggUid")
				local Nyx_captureRecordData = attribute and (EggState2.ReadFieldEgg(attribute) or self.records[attribute])

				if type(Nyx_captureRecordData) == "table" and Nyx_captureRecordData.BottomCFrame and (Nyx_captureRecordData.State == AreaEggs.States.Slot or Nyx_captureRecordData.State == AreaEggs.States.Dropped) then
					return Nyx_captureRecordData
				end
			end

			if self.manualObjectiveEnabled then
				local Nyx_manualTarget = self:_takeManualTarget()

				if Nyx_manualTarget then
					return Nyx_manualTarget
				end
			end

			if self.userStealEnabled and not self.riftOnly then
				local Nyx_hasPriority, Nyx_priorityEgg = self:hasPriorityRareEgg()

				if Nyx_hasPriority and Nyx_priorityEgg then
					return Nyx_priorityEgg
				end
			end

			local Nyx_riftRecord
			local Nyx_riftDistance
			local Nyx_indexRecord
			local Nyx_indexDistance
			local Nyx_wispRecord
			local Nyx_wispDistance

			for _, record in pairs(self.records) do
				if (record.State == AreaEggs.States.Slot or record.State == AreaEggs.States.Dropped) and record.BottomCFrame and not self:isSkippedEgg(record.Uid) then
					local Magnitude = (record.BottomCFrame.Position - HumanoidRootPart.Position).Magnitude

					if not self.riftWants[record.AssetCategory] then
						if not self.wispObjective or not self:_isWispObjective(record) then
							if self.indexObjectiveEnabled and self:_isIndexObjective(record) and (not Nyx_indexRecord or Magnitude < Nyx_indexDistance) then
								Nyx_indexRecord = record
								Nyx_indexDistance = Magnitude
							end
						elseif not Nyx_wispRecord or Magnitude < Nyx_wispDistance then
							Nyx_wispRecord = record
							Nyx_wispDistance = Magnitude
						end
					elseif not Nyx_riftRecord or Magnitude < Nyx_riftDistance then
						Nyx_riftRecord = record
						Nyx_riftDistance = Magnitude
					end
				end
			end

			if Nyx_riftRecord or Nyx_wispRecord or Nyx_indexRecord then
				return Nyx_riftRecord or Nyx_wispRecord or Nyx_indexRecord
			end

			if self.userStealEnabled and not self.riftOnly then
				local Nyx_filterMatchRecord
				local Nyx_filterMatchRank
				local Nyx_filterMatchDistance

				for _, record in pairs(self.records) do
					if record.State == AreaEggs.States.Slot or record.State == AreaEggs.States.Dropped then
						if not self:isSkippedEgg(record.Uid) and self:_matchesNormalFilter(record) then
							local Magnitude = (record.BottomCFrame.Position - HumanoidRootPart.Position).Magnitude
							local Nyx_eggResolved = self.catalog.resolve(record)
							local Nyx_eggPriorityScore

							if self.config.highestValueFirst then
								Nyx_eggPriorityScore = Nyx_computeRatePerSec(record) or -math.huge
							elseif self.config.heaviestFirst then
								Nyx_eggPriorityScore = self:_resolveWeightKg(record) or -math.huge
							else
								Nyx_eggPriorityScore = Nyx_eggResolved.rarityRank or 0
							end

							if not Nyx_filterMatchRecord or Nyx_filterMatchRank < Nyx_eggPriorityScore or Nyx_eggPriorityScore == Nyx_filterMatchRank and Magnitude < Nyx_filterMatchDistance then
								Nyx_filterMatchRecord = record
								Nyx_filterMatchRank = Nyx_eggPriorityScore
								Nyx_filterMatchDistance = Magnitude
							end
						end
					end
				end

				if Nyx_filterMatchRecord then
					return Nyx_filterMatchRecord
				end
			end

			return nil
		end
		Nyx_EggRuntime._takeManualTarget = function(self)
			local Nyx_manualRemaining = {}
			local manualOrder = {}

			for _, v in ipairs(self.manualOrder) do
				local Nyx_manualEggRecord = self.records[v]

				if Nyx_manualEggRecord and (Nyx_manualEggRecord.State == AreaEggs.States.Slot or Nyx_manualEggRecord.State == AreaEggs.States.Dropped) then
					manualOrder[#manualOrder + 1] = v
					Nyx_manualRemaining[v] = true
				end
			end

			self.manualOrder = manualOrder

			for k in pairs(self.manualQueue) do
				if not Nyx_manualRemaining[k] then
					self.manualQueue[k] = nil
				end
			end

			if #manualOrder ~= 0 then
				return self.records[manualOrder[1]]
			end

			if self.manualObjectiveEnabled then
				self.manualObjectiveEnabled = false
				task.defer(function()
					if not self.destroyed then
						self:_reconcileRunningState()
					end
				end)
			end

			return nil
		end
		Nyx_EggRuntime.queueManual = function(self, uidList)
			if type(uidList) ~= "table" then
				return 0
			end

			for _, v in ipairs(uidList) do
				local Nyx_manualQueueKey = v

				if Nyx_manualQueueKey ~= nil and not self.manualQueue[Nyx_manualQueueKey] then
					self.manualQueue[Nyx_manualQueueKey] = true
					self.manualOrder[#self.manualOrder + 1] = Nyx_manualQueueKey
				end
			end

			local Nyx_manualPendingCount = #self.manualOrder

			if Nyx_manualPendingCount > 0 then
				self.manualObjectiveEnabled = true
			end

			self:_reconcileRunningState()

			return Nyx_manualPendingCount
		end

		do
			Nyx_EggRuntime.clearManual = function(self)
				self.manualQueue = {}
				self.manualOrder = {}
				self.manualObjectiveEnabled = false
				self:_reconcileRunningState()
			end
		end

		Nyx_EggRuntime.manualPending = function(self)
			return #self.manualOrder
		end
		Nyx_EggRuntime.setTreadmillManager = function(self, treadmillManager)
			self.treadmillManager = treadmillManager
		end
		Nyx_EggRuntime.getStealMode = function(self)
			return self.config.stealMode == "Fly" and "Fly" or "Instant"
		end

		do
			Nyx_EggRuntime.setStealMode = function(self, mode, flyAerial, flyZigzag)
				local stealMode = mode == "Fly" and "Fly" or "Instant"
				local flyAerial = stealMode == "Fly" and flyAerial == true
				local flyZigzag = stealMode == "Fly" and flyZigzag == true and not flyAerial

				if self.config.stealMode ~= stealMode or self.config.flyAerial ~= flyAerial or self.config.flyZigzag ~= flyZigzag then
					self.config.stealMode = stealMode
					self.config.flyAerial = flyAerial
					self.config.flyZigzag = flyZigzag

					if self.enabled then
						self:_installGuardHitDistanceBoost()
						self:_finish("Mode changed")
					end
				end

				return stealMode
			end
		end

		do
			local ResolveHitDistance

			Nyx_EggRuntime._installGuardHitDistanceBoost = function(self)
				if not self.guardHitBoostInstalled then
					pcall(function()
						local GuardChasePolicy = require(ReplicatedStorage2.Shared.Modules.GuardAreas.GuardChasePolicy)

						if GuardChasePolicy and type(GuardChasePolicy.ResolveHitDistance) == "function" then
							ResolveHitDistance = ResolveHitDistance or GuardChasePolicy.ResolveHitDistance

							local Nyx_thisRuntime = self

							GuardChasePolicy.ResolveHitDistance = function(guardLevel)
								if Nyx_thisRuntime.enabled and Nyx_thisRuntime.instantPhase == "priming" then
									return 25
								end

								if Nyx_thisRuntime.enabled or Nyx_thisRuntime._recalling then
									return -math.huge
								end

								local ok = not ResolveHitDistance
								local Nyx_originalHitDistance

								if not ok then
									Nyx_originalHitDistance = ResolveHitDistance(guardLevel)
									ok = not Nyx_originalHitDistance
								end

								if ok then
									Nyx_originalHitDistance = guardLevel or 10
								end

								return Nyx_originalHitDistance
							end
							self.guardHitBoostInstalled = true
						end
					end)

					return
				end
			end
			Nyx_EggRuntime._removeGuardHitDistanceBoost = function(self)
				if not self.guardHitBoostInstalled then
					return
				end

				pcall(function()
					local GuardChasePolicy = require(ReplicatedStorage2.Shared.Modules.GuardAreas.GuardChasePolicy)

					if GuardChasePolicy and ResolveHitDistance then
						GuardChasePolicy.ResolveHitDistance = ResolveHitDistance
						self.guardHitBoostInstalled = false
					end
				end)
			end
		end

		Nyx_EggRuntime._setInstantAnchored = function(self, anchored)
			pcall(function()
				local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if HumanoidRootPart then
					if HumanoidRootPart.Anchored ~= anchored then
						HumanoidRootPart.Anchored = anchored
					end
				end
			end)
		end

		do
			Nyx_EggRuntime._kbCancelTimer = function(self)
				if self.hitTimer then
					pcall(task.cancel, self.hitTimer)
					self.hitTimer = nil
				end
			end
		end

		Nyx_EggRuntime._isPrimerEgg = function(self, uid)
			if uid == nil then
				return false
			end

			if uid == self.primerUid then
				return true
			end

			local primerUids = self.primerUids and self.primerUids[uid]

			if primerUids then
				if os.clock() < primerUids then
					return true
				end
			end

			if primerUids then
				self.primerUids[uid] = nil
			end

			return false
		end
		Nyx_EggRuntime._cleanupInstantSteal = function(self)
			self.instantPhase = nil
			self.primerUid = nil
			self.targetUid = nil
			self._flyDeparting = false
			self:_stopGuardStick()
			self:_kbCancelTimer()
			self:_setInstantAnchored(false)
			self:_hideTreadmillDecoy()
		end
		Nyx_EggRuntime._choosePrimerEgg = function(self, uid)
			local Nyx_guardHitDistance = Nyx_getWorkspaceWorld()
			local Areas = Nyx_guardHitDistance and Nyx_guardHitDistance:FindFirstChild("Areas")
			local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
			local Forest = GuardAreas and GuardAreas:FindFirstChild("Forest")
			local Guard = Forest and Forest:FindFirstChild("Guard")
			local HumanoidRootPart = Guard and Guard:FindFirstChild("HumanoidRootPart")
			local Position = HumanoidRootPart and HumanoidRootPart.Position
			local Nyx_primerEggCandidate
			local Nyx_primerEggScore

			for _, record in pairs(self.records) do
				if record.State == AreaEggs.States.Slot and record.AreaId == "Forest" and record.Uid ~= uid and not self:_isCaptureEgg(record.Uid) then
					local Nyx_primerEggPriority = -(Position and (record.BottomCFrame.Position - Position).Magnitude or LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart") and (record.BottomCFrame.Position - LocalPlayer2.Character.HumanoidRootPart.Position).Magnitude or math.huge) - (self.catalog.resolve(record).rarityRank or 0) * 100

					if not Nyx_primerEggCandidate or Nyx_primerEggScore < Nyx_primerEggPriority then
						Nyx_primerEggCandidate = record
						Nyx_primerEggScore = Nyx_primerEggPriority
					end
				end
			end

			return Nyx_primerEggCandidate
		end
		Nyx_EggRuntime._stopGuardStick = function(self)
			if self.guardStickConnection then
				pcall(self.guardStickConnection.Disconnect, self.guardStickConnection)
				self.guardStickConnection = nil
			end
		end
		Nyx_EggRuntime._startGuardStick = function(self)
			self:_stopGuardStick()

			local function Nyx_getForestGuard()
				local Nyx_worldRef = Nyx_getWorkspaceWorld()
				local Areas = Nyx_worldRef and Nyx_worldRef:FindFirstChild("Areas")
				local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
				local Forest = GuardAreas and GuardAreas:FindFirstChild("Forest")
				local Guard = Forest and Forest:FindFirstChild("Guard")

				return Guard and Guard:FindFirstChild("HumanoidRootPart")
			end

			self.guardStickConnection = RunService2.PreSimulation:Connect(function()
				if self.destroyed or not self.enabled or self.instantPhase ~= "priming" then
					self:_stopGuardStick()

					return
				end

				local Nyx_forestGuardRoot = Nyx_getForestGuard()
				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

				if not Nyx_forestGuardRoot or not HumanoidRootPart then
					return
				end

				local Position = Nyx_forestGuardRoot.Position
				local Nyx_guardForwardOffset = Nyx_forestGuardRoot.CFrame.LookVector * 2.5
				local Nyx_guardFrontPos = Vector3.new(Position.X + Nyx_guardForwardOffset.X, HumanoidRootPart.Position.Y, Position.Z + Nyx_guardForwardOffset.Z) - HumanoidRootPart.Position

				if Nyx_guardFrontPos.Magnitude > 40 then
					Nyx_guardFrontPos = Nyx_guardFrontPos.Unit * 40
				end

				local Nyx_guardStrikeAnchor = HumanoidRootPart.Position + Nyx_guardFrontPos

				HumanoidRootPart.CFrame = lookAt(Nyx_guardStrikeAnchor, Vector3.new(Position.X, Nyx_guardStrikeAnchor.Y, Position.Z))
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				self:_syncHoverPad(Nyx_guardStrikeAnchor)
			end)
		end
		Nyx_EggRuntime._forestGuardModel = function()
			local Nyx_worldRef2 = Nyx_getWorkspaceWorld()
			local Areas = Nyx_worldRef2 and Nyx_worldRef2:FindFirstChild("Areas")
			local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
			local Forest = GuardAreas and GuardAreas:FindFirstChild("Forest")

			return Forest and Forest:FindFirstChild("Guard")
		end
		Nyx_EggRuntime._triggerGuardHit = function(self)
			local Nyx_forestGuard = self:_forestGuardModel()
			local HumanoidRootPart = Nyx_forestGuard and Nyx_forestGuard:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart then
				return
			end

			local Character = LocalPlayer2.Character
			local HumanoidRootPart2 = Character and Character:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart2 then
				return
			end

			local Position = HumanoidRootPart.Position
			local Nyx_guardForward2 = HumanoidRootPart.CFrame.LookVector * 2.5
			local vector33 = Vector3.new(Position.X + Nyx_guardForward2.X, HumanoidRootPart2.Position.Y, Position.Z + Nyx_guardForward2.Z)

			self.guardStrikeAnchor = vector33
			HumanoidRootPart2.CFrame = lookAt(vector33, Vector3.new(Position.X, vector33.Y, Position.Z))
			HumanoidRootPart2.AssemblyLinearVelocity = Vector3.zero

			local Collider = Nyx_forestGuard:FindFirstChild("Collider") or HumanoidRootPart

			if firetouchinterest then
				pcall(function()
					firetouchinterest(HumanoidRootPart2, Collider, 0)
					firetouchinterest(HumanoidRootPart2, Collider, 1)
				end)
			end

			pcall(function()
				local ForestStrike = Remotes.GuardPatrol and Remotes.GuardPatrol.ForestStrike

				if ForestStrike then
					ForestStrike:FireServer({
						EggUid = self.primerUid,
						GuardCFrame = HumanoidRootPart.CFrame
					})
				end
			end)
		end
		Nyx_EggRuntime._stopGuardStrike = function(self)
			self.guardStrikeGeneration = (self.guardStrikeGeneration or 0) + 1
		end
		Nyx_EggRuntime._knockbackLanded = function()
			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not HumanoidRootPart or not Humanoid then
				return false
			end

			if Humanoid.PlatformStand or Humanoid.Sit then
				return true
			end

			local state = Humanoid:GetState()

			if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.PlatformStanding then
				return true
			end

			return HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 18
		end
		Nyx_EggRuntime._settleAfterKnockback = function(self)
			local guardStrikeAnchor = self.guardStrikeAnchor
			local Nyx_knockbackSettleDeadline = os.clock() + 0.35

			while true do
				if not (os.clock() < Nyx_knockbackSettleDeadline) or self.destroyed then
					return
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

				if not HumanoidRootPart then
					break
				end

				local Humanoid = Character:FindFirstChildOfClass("Humanoid")

				if Humanoid then
					pcall(function()
						Humanoid.PlatformStand = false
						Humanoid.Sit = false
						Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
					end)
				end

				if guardStrikeAnchor then
					HumanoidRootPart.CFrame = cFrameNew(guardStrikeAnchor)
				end

				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				self:_syncHoverPad(guardStrikeAnchor or HumanoidRootPart.Position)
				RunService2.Heartbeat:Wait()
			end
		end
		Nyx_EggRuntime._startGuardStrike = function(self)
			self:_stopGuardStrike()

			local guardStrikeGeneration = self.guardStrikeGeneration

			task.spawn(function()
				local Nyx_guardStrikeDeadline = os.clock() + 1.5

				while not self.destroyed and self.enabled and self.instantPhase == "priming" and self.guardStrikeGeneration == guardStrikeGeneration and os.clock() < Nyx_guardStrikeDeadline do
					self:_triggerGuardHit()

					local Nyx_knockbackCheckDeadline = os.clock() + 0.05
					local Nyx_knockbackLanded = false

					while os.clock() < Nyx_knockbackCheckDeadline do
						if self:_knockbackLanded() then
							Nyx_knockbackLanded = true

							break
						else
							RunService2.Heartbeat:Wait()
						end
					end

					if Nyx_knockbackLanded then
						break
					end
				end

				if self.guardStrikeGeneration == guardStrikeGeneration then
					self:_stopGuardStick()
					self:_settleAfterKnockback()
				end
			end)
		end
		Nyx_EggRuntime._enterBaitWait = function(self)
			self:_setInstantAnchored(false)
			self:_setStatus("Preparing steal")
			self:_startGuardStick()
			self:_startGuardStrike()

			if self.hitTimer then
				return
			end

			self.hitTimer = task.delay(1.8, function()
				self.hitTimer = nil

				if self.destroyed or not self.enabled then
					return
				end

				if self.instantPhase ~= "priming" then
					return
				end

				self:_stopGuardStick()
				self:_stopGuardStrike()

				if self.carry.active and self:_isPrimerEgg(self.carry.uid) then
					pcall(EggState2.DropFieldEgg, "PlayerRequest")
				end

				self:_finish("Steal timed out — retrying")
			end)
		end

		local function Nyx_computeSettleSeconds(areaName, holdLevel)
			local Nyx_areaName = tostring(areaName or ""):lower()
			local Nyx_computeSettleSeconds_var1 = 8
			local Nyx_computeSettleSeconds_var2 = 3.5

			if Nyx_areaName:find("enchanted") then
				Nyx_computeSettleSeconds_var1 = 18
				Nyx_computeSettleSeconds_var2 = 12
			elseif Nyx_areaName:find("light") or Nyx_areaName:find("dark") then
				Nyx_computeSettleSeconds_var1 = 16
				Nyx_computeSettleSeconds_var2 = 10
			elseif Nyx_areaName:find("titan") then
				Nyx_computeSettleSeconds_var1 = 10
				Nyx_computeSettleSeconds_var2 = 8
			end

			return math.max(Nyx_computeSettleSeconds_var2, Nyx_computeSettleSeconds_var1 * ((11 - math.clamp(holdLevel, 1, 10)) / 6))
		end

		do
			Nyx_EggRuntime._resolveSettleSeconds = function(self, record)
				local Nyx_stealHoldSeconds = math.clamp(tonumber(NyxConfig.StealHoldSeconds) or 5, 1, 10)
				local Nyx_settleBonusData = self.settleBonus and type(record) == "table" and self.settleBonus[record.Uid]
				local seconds = Nyx_settleBonusData and Nyx_settleBonusData.untilAt > os.clock() and Nyx_settleBonusData.seconds or 0

				return Nyx_computeSettleSeconds(type(record) == "table" and record.AreaId, Nyx_stealHoldSeconds) + seconds
			end
		end

		Nyx_EggRuntime._startPrimerTargetHunt = function(self)
			if self.instantPhase ~= "priming" then
				return
			end

			self:_stopGuardStick()
			self:_stopGuardStrike()
			pcall(function()
				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if Humanoid then
					Humanoid.PlatformStand = false
					Humanoid.Sit = false
				end

				if HumanoidRootPart then
					if self.guardStrikeAnchor then
						HumanoidRootPart.CFrame = cFrameNew(self.guardStrikeAnchor)
					end

					HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end
			end)
			self:_kbCancelTimer()
			self:_setInstantAnchored(false)
			self.instantPhase = "hunting"
			self:_clearArrivalHold()

			local carry = self.carry

			carry.generation += 1
			self:_invalidateCarryWorker()
			self.carry.active = false
			self.carry.uid = nil

			local targetUid = self.targetUid

			self.targetUid = nil

			if not targetUid then
				self:_finish("No target egg")

				return
			end

			local Nyx_targetRecordData = EggState2.ReadFieldEgg(targetUid) or self.records[targetUid]

			if not Nyx_targetRecordData or Nyx_targetRecordData.State ~= AreaEggs.States.Slot and Nyx_targetRecordData.State ~= AreaEggs.States.Dropped then
				self:_finish("Target egg no longer available")

				return
			end

			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not HumanoidRootPart or not Humanoid then
				self:_finish("Character unavailable")

				return
			end

			self.activeTarget = Nyx_targetRecordData

			local Nyx_eggDestinationCF = self:_resolveEggDestination(Nyx_targetRecordData, HumanoidRootPart, Humanoid)

			if not Nyx_eggDestinationCF then
				self:_finish("Target destination unavailable")

				return
			end

			if self.config.stealMode ~= "Fly" then
				if self.config.stealMode == "Instant" and not self.lowFpsPrime then
					local Uid = Nyx_targetRecordData.Uid

					local function Nyx_huntCancelled()
						return self.destroyed or not self.enabled or self.instantPhase ~= "hunting" or not self.activeTarget or self.activeTarget.Uid ~= Uid
					end

					local cFrame2 = Nyx_eggDestinationCF + Vector3.new(0, 14, 0)

					self:_setStatus("Heading to target egg")

					if not self:_glideRoot(cFrame2, Nyx_huntCancelled) then
						if not Nyx_huntCancelled() then
							self:_finish("Could not reach the egg — retrying")
						end

						return
					end

					task.spawn(function()
						local Nyx_settleSeconds = self:_resolveSettleSeconds(Nyx_targetRecordData)
						local Nyx_settleDeadline = os.clock() + Nyx_settleSeconds

						if os.clock() < Nyx_settleDeadline then
							local exitTo

							while not Nyx_huntCancelled() do
								self:_setStatus(string.format("Securing target egg (%.1fs)", math.max(0, Nyx_settleDeadline - os.clock())))

								local Character2 = LocalPlayer2.Character
								local HumanoidRootPart2 = Character2 and Character2:FindFirstChild("HumanoidRootPart")
								local Humanoid2 = Character2 and Character2:FindFirstChildOfClass("Humanoid")

								if HumanoidRootPart2 and Humanoid2 then
									pcall(function()
										HumanoidRootPart2.CFrame = cFrame2
										HumanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
										HumanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
									end)
									self:_syncHoverPad(cFrame2.Position)

									local Nyx_huntSpeed = math.clamp(self.config.speed or 600, 200, Nyx_getMaxSpeedClamp())

									pcall(function()
										Nyx_applySpoofWalkSpeed(Character2, Nyx_huntSpeed * 1.35)
										Nyx_updateSpoofSpeed(Humanoid2, HumanoidRootPart2, Nyx_huntSpeed, Vector3.zero)
									end)
								end

								task.wait(0.1)

								if not (os.clock() < Nyx_settleDeadline) then
									exitTo = 1

									break
								end
							end

							if exitTo ~= 1 then
								return
							end

							if not Nyx_huntCancelled() then
								self:_glideRoot(Nyx_eggDestinationCF, Nyx_huntCancelled)

								if Nyx_huntCancelled() then
									return
								end

								self:_setArrivalHold(Nyx_eggDestinationCF, Uid)
								self:_setStatus("Securing target egg")
								self:_requestCarry(Nyx_targetRecordData, true)

								return
							end
						elseif not Nyx_huntCancelled() then
							self:_glideRoot(Nyx_eggDestinationCF, Nyx_huntCancelled)

							if Nyx_huntCancelled() then
								return
							end

							self:_setArrivalHold(Nyx_eggDestinationCF, Uid)
							self:_setStatus("Securing target egg")
							self:_requestCarry(Nyx_targetRecordData, true)

							return
						end
					end)

					return
				end

				self:_setStatus("Heading to target egg")
				self:_tweenRoot(Nyx_eggDestinationCF, function()
					if self.instantPhase == "hunting" and self.activeTarget and self.activeTarget.Uid == Nyx_targetRecordData.Uid then
						self:_requestCarry(Nyx_targetRecordData, false)
					end
				end, nil, {
					holdAfterArrival = true,
					holdUid = Nyx_targetRecordData.Uid,
					flightProfile = true,
					carryTarget = Nyx_targetRecordData
				})

				return
			end

			local Uid = Nyx_targetRecordData.Uid

			local function Nyx_flyHuntCancelled()
				return self.destroyed or not self.enabled or self.instantPhase ~= "hunting" or not self.activeTarget or self.activeTarget.Uid ~= Uid
			end

			if self.config.flyAerial then
				self:_setStatus("Heading to target egg")
				self:_startFlyGrounding()

				local Nyx_flyHuntSuccess = self:_flyWalkTo(Nyx_eggDestinationCF, Nyx_flyHuntCancelled, 8, 110)

				self:_stopFlyGrounding()

				if not Nyx_flyHuntSuccess then
					if not Nyx_flyHuntCancelled() then
						self:_finish("Could not reach the egg — retrying")
					end

					return
				end
			elseif self.config.flyZigzag then
				self:_setStatus("Heading to target egg")

				if not self:_walkToZigzag(Nyx_eggDestinationCF, Nyx_flyHuntCancelled) then
					if not Nyx_flyHuntCancelled() then
						self:_finish("Zig-zag walk to target failed")
					end

					return
				end
			else
				self:_setStatus("Heading to target egg")

				if not self:_walkTo(Nyx_eggDestinationCF, Nyx_flyHuntCancelled) then
					if not Nyx_flyHuntCancelled() then
						self:_finish("Walk to target failed")
					end

					return
				end
			end

			if Nyx_flyHuntCancelled() then
				return
			end

			self:_glideRoot(Nyx_eggDestinationCF, Nyx_flyHuntCancelled, self:_legitWalkSpeed())

			if Nyx_flyHuntCancelled() then
				return
			end

			self:_setArrivalHold(Nyx_eggDestinationCF, Uid)
			self:_setStatus("Securing target egg")
			self:_requestCarry(Nyx_targetRecordData, true)
		end

		do
			Nyx_EggRuntime._wallOpen = function(self)
				if self.resetBlocked or AreaEggResetWall3.IsSealed() or os.clock() < self.gateOpenAt then
					return false
				end

				local Nyx_worldRef3 = Nyx_getWorkspaceWorld()
				local Areas = Nyx_worldRef3 and Nyx_worldRef3:FindFirstChild("Areas")
				local WallStartCollision = Areas and Areas:FindFirstChild("WallStartCollision")

				if WallStartCollision and WallStartCollision:IsA("BasePart") and WallStartCollision.CanCollide then
					return false
				end

				return true
			end
		end

		Nyx_EggRuntime._closeGate = function(self, reason)
			self.resetBlocked = true
			self.gateOpenAt = math.huge
			self.safeStarting = false

			if not self.activeTween then
				self:_cancelTween(reason)
			elseif not self.activeTween.sharedTravel then
				self:_cancelTween(reason)
				self:_setStatus(reason)

				return
			end

			self:_setStatus(reason)
		end
		Nyx_EggRuntime._releaseOperation = function(self)
			local operationToken = self.operationToken

			self.operationToken = nil

			if operationToken and self.coordinator then
				self.coordinator:release(operationToken)
			end
		end

		do
			Nyx_EggRuntime._acquireOperation = function(self)
				if self.operationToken or not self.coordinator then
					return true
				end

				local autoSteal, Nyx_acquireError = self.coordinator:tryAcquire("auto_steal", {})

				if not autoSteal then
					return false, Nyx_acquireError
				end

				self.operationToken = autoSteal

				return true
			end
		end

		Nyx_EggRuntime._cancelTween = function(self, reason, alreadyReleased)
			self:_cleanupInstantSteal()
			self.carryAttemptToken = nil
			self:_clearArrivalHold()
			self.safeStarting = false

			if self.activeTween then
				pcall(self.activeTween.Cancel, self.activeTween)
				self.activeTween = nil
			end

			if not self.activeTween and not self.arrivalHold then
				self:_stopHoverPad()
			end

			if self.running then
				self.running = false
				self.activeTarget = nil
				self.stats.lastResult = reason
				self:_notify()
			end

			if not alreadyReleased then
				self:_releaseOperation()
			end
		end
		Nyx_EggRuntime._groundYAt = function(self, x, z, character)
			local Character = character or LocalPlayer2.Character
			local vector33 = Vector3.new(x, (Character and Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart.Position.Y or vector32.Y) + 60, z)
			local filterDescendantsInstances = {}

			if Character then
				table.insert(filterDescendantsInstances, Character)
			end

			if self.hoverPad then
				table.insert(filterDescendantsInstances, self.hoverPad)
			end

			if self.treadmillDecoy then
				table.insert(filterDescendantsInstances, self.treadmillDecoy)
			end

			for _, child in ipairs(workspace:GetChildren()) do
				if child.Name == "__NyxHoverPad" or child.Name == "__NyxTreadmillDecoy" then
					table.insert(filterDescendantsInstances, child)
				end
			end

			for i = 1, 10 do
				local raycastParams = RaycastParams.new()

				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = filterDescendantsInstances
				raycastParams.IgnoreWater = true

				local hit = workspace:Raycast(vector33, Vector3.new(0, -300, 0), raycastParams)

				if not hit then
					return nil
				end

				if hit.Instance.CanCollide then
					return hit.Position.Y
				end

				table.insert(filterDescendantsInstances, hit.Instance)
			end

			return nil
		end

		do
			Nyx_EggRuntime._resolveSafeCFrame = function(self, rootPart)
				if not rootPart then
					return nil
				end

				local X = vector32.X
				local Z = vector32.Z
				local Y = vector32.Y
				local Nyx_groundYValue = self:_groundYAt(X, Z, rootPart.Parent)

				if Nyx_groundYValue then
					Y = Nyx_groundYValue + 3.2
				end

				return cFrameNew(X, Y, Z) * rootPart.CFrame.Rotation
			end
		end

		Nyx_EggRuntime._groundSnap = function(self)
			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not HumanoidRootPart or not Humanoid then
				return false
			end

			local Position = HumanoidRootPart.Position
			local Nyx_groundYSnap = self:_groundYAt(Position.X, Position.Z, Character)

			if not Nyx_groundYSnap then
				return false
			end

			local Nyx_groundYWithFeet = Nyx_groundYSnap + self:_feetOffset(HumanoidRootPart, Humanoid)

			if not (Position.Y < Nyx_groundYWithFeet - 0.25) and not (Nyx_groundYWithFeet + 8 < Position.Y) then
				return false
			end

			pcall(function()
				self:_syncHoverPad(Vector3.new(Position.X, Nyx_groundYWithFeet, Position.Z))
				HumanoidRootPart.CFrame = cFrameNew(Position.X, Nyx_groundYWithFeet, Position.Z) * HumanoidRootPart.CFrame.Rotation
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			end)

			return true
		end

		do
			local function Nyx_destroyTrails(instance)
				if typeof(instance) == "Instance" and instance:IsA("Trail") then
					pcall(instance.Destroy, instance)
				end
			end
			local function Nyx_destroyStealPopups(instance)
				if typeof(instance) == "Instance" then
					if instance.Name == "SpeedGainPopup" or instance.Name == "PlusOne" then
						pcall(instance.Destroy, instance)
					end
				end
			end

			Nyx_EggRuntime._showTreadmillDecoy = function(self)
				if self.treadmillDecoy and self.treadmillDecoy.Parent then
					return true
				end

				self:_hideTreadmillDecoy()

				local Character = LocalPlayer2.Character

				if not Character then
					return false
				end

				local Archivable = Character.Archivable

				Character.Archivable = true

				local ok, treadmillDecoy = pcall(Character.Clone, Character)

				Character.Archivable = Archivable

				if not ok or not treadmillDecoy or typeof(treadmillDecoy) ~= "Instance" then
					return false
				end

				treadmillDecoy.Name = "__NyxTreadmillDecoy"

				for _, descendant in ipairs(treadmillDecoy:GetDescendants()) do
					if Nyx_decoyDestroyFilter[descendant.ClassName] or descendant:IsA("Trail") then
						pcall(descendant.Destroy, descendant)
					elseif descendant:IsA("BasePart") then
						descendant.LocalTransparencyModifier = 0
						descendant.Anchored = true
						descendant.CanCollide = false
						descendant.CanQuery = false
						descendant.CanTouch = false
					end
				end

				local HumanoidRootPart = treadmillDecoy:FindFirstChild("HumanoidRootPart")
				local Humanoid = treadmillDecoy:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart or not Humanoid then
					treadmillDecoy:Destroy()

					return false
				end

				pcall(function()
					Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
				end)
				treadmillDecoy.Parent = workspace
				treadmillDecoy:PivotTo(cFrameNew(vector32))
				self.treadmillDecoy = treadmillDecoy

				local PlayerGui = LocalPlayer2:FindFirstChildOfClass("PlayerGui")

				if PlayerGui then
					for _, descendant in ipairs(PlayerGui:GetDescendants()) do
						if descendant.Name == "SpeedGainPopup" or descendant.Name == "PlusOne" then
							Nyx_destroyStealPopups(descendant)
						end
					end

					self.treadmillPopupConnection = PlayerGui.DescendantAdded:Connect(function(descendant)
						if self.treadmillDecoy == treadmillDecoy then
							Nyx_destroyStealPopups(descendant)
						end
					end)
				end

				local treadmillDecoyRealTransparency = setmetatable({}, {
					__mode = "k"
				})

				local function Nyx_hideCharacterPart(part)
					if not part or not part:IsA("BasePart") or not part:IsDescendantOf(Character) then
						return
					end

					if treadmillDecoyRealTransparency[part] == nil then
						treadmillDecoyRealTransparency[part] = part.LocalTransparencyModifier
					end

					part.LocalTransparencyModifier = 1
				end

				for _, descendant in ipairs(Character:GetDescendants()) do
					Nyx_hideCharacterPart(descendant)
					Nyx_destroyTrails(descendant)
				end

				self.treadmillDecoyRealTransparency = treadmillDecoyRealTransparency
				self.treadmillDecoyCharacterConnection = Character.DescendantAdded:Connect(function(descendant)
					if self.treadmillDecoy == treadmillDecoy then
						pcall(Nyx_hideCharacterPart, descendant)
						Nyx_destroyTrails(descendant)
					end
				end)

				local CurrentCamera = workspace.CurrentCamera

				if CurrentCamera then
					self.treadmillDecoyCamera = CurrentCamera.CameraSubject
					CurrentCamera.CameraSubject = Humanoid
				end

				self.treadmillDecoyCameraConnection = RunService2.RenderStepped:Connect(function()
					if self.treadmillDecoy ~= treadmillDecoy or not treadmillDecoy.Parent or not Humanoid.Parent then
						return
					end

					for k in pairs(treadmillDecoyRealTransparency) do
						if k.Parent and k.LocalTransparencyModifier ~= 1 then
							k.LocalTransparencyModifier = 1
						end
					end

					local CurrentCamera2 = workspace.CurrentCamera

					if CurrentCamera2 and CurrentCamera2.CameraSubject ~= Humanoid then
						CurrentCamera2.CameraSubject = Humanoid
					end
				end)

				return true
			end
		end

		Nyx_EggRuntime._hideTreadmillDecoy = function(self, forceRestore)
			if self._recalling and not forceRestore then
				return
			end

			if self.treadmillDecoyCameraConnection then
				pcall(self.treadmillDecoyCameraConnection.Disconnect, self.treadmillDecoyCameraConnection)
				self.treadmillDecoyCameraConnection = nil
			end

			if self.treadmillDecoyCharacterConnection then
				pcall(self.treadmillDecoyCharacterConnection.Disconnect, self.treadmillDecoyCharacterConnection)
				self.treadmillDecoyCharacterConnection = nil
			end

			if self.treadmillPopupConnection then
				pcall(self.treadmillPopupConnection.Disconnect, self.treadmillPopupConnection)
				self.treadmillPopupConnection = nil
			end

			local pairs_ = pairs
			local treadmillDecoyRealTransparency = self.treadmillDecoyRealTransparency or {}

			for k, v in pairs_(treadmillDecoyRealTransparency) do
				if typeof(k) == "Instance" and k.Parent then
					pcall(function()
						k.LocalTransparencyModifier = v
					end)
				end
			end

			self.treadmillDecoyRealTransparency = nil

			local Character = LocalPlayer2.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			local CurrentCamera = workspace.CurrentCamera

			if CurrentCamera then
				pcall(function()
					CurrentCamera.CameraSubject = Humanoid or self.treadmillDecoyCamera
				end)
			end

			self.treadmillDecoyCamera = nil

			if self.treadmillDecoy then
				pcall(self.treadmillDecoy.Destroy, self.treadmillDecoy)
			end

			self.treadmillDecoy = nil
		end

		do
			Nyx_EggRuntime._restoreTreadmillVisualAtSafe = function(self)
				if not self.treadmillDecoy then
					self:_hideTreadmillDecoy()

					return true
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				local Nyx_safeCFrame = self:_resolveSafeCFrame(HumanoidRootPart)

				if not HumanoidRootPart or not Humanoid or not Nyx_safeCFrame then
					self:_hideTreadmillDecoy()

					return false
				end

				local Nyx_restoreDeadline = os.clock() + 2
				local Nyx_inSafeZoneSince
				local Nyx_hideCharacterPart_var1 = 0

				while not self.destroyed and os.clock() < Nyx_restoreDeadline do
					local now = os.clock()

					if self:_isInSafeArea(HumanoidRootPart) then
						Nyx_inSafeZoneSince = Nyx_inSafeZoneSince or now

						if now - Nyx_inSafeZoneSince >= 0.35 then
							self:_hideTreadmillDecoy()

							return true
						end
					else
						Nyx_inSafeZoneSince = nil

						if Nyx_hideCharacterPart_var1 <= now then
							Nyx_hideCharacterPart_var1 = now + 0.1
							self:_teleportRoot(HumanoidRootPart, Humanoid, Nyx_safeCFrame)
						end
					end

					task.wait(0.03)
				end

				self:_hideTreadmillDecoy()

				return false
			end
		end

		Nyx_EggRuntime._prepareTreadmillLaunch = function(self, targetRecord, planGeneration)
			local treadmillManager = self.treadmillManager

			if not treadmillManager or type(treadmillManager.pulseForCarry) ~= "function" then
				return false, "Preparation unavailable"
			end

			local Uid = targetRecord and targetRecord.Uid

			local function Nyx_getEggFromUid()
				return Uid and (EggState2.ReadFieldEgg(Uid) or self.records[Uid]) or nil
			end
			local function Nyx_treadmillLaunchCancelled()
				local Nyx_treadmillLaunchStillValid = Nyx_getEggFromUid()

				return self.destroyed or not self.enabled or self.planGeneration ~= planGeneration or not self:_wallOpen() or type(Nyx_treadmillLaunchStillValid) ~= "table" or not self:_matches(Nyx_treadmillLaunchStillValid)
			end
			local function Nyx_treadmillTeleport(targetCFrame)
				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

				return self:_teleportRoot(HumanoidRootPart, Character and Character:FindFirstChildOfClass("Humanoid"), targetCFrame)
			end

			self:_setStatus("Preparing carry")

			if not self:_showTreadmillDecoy() then
				return false, "Safe-zone visual unavailable"
			end

			local Nyx_treadmillPrepareOk, Nyx_treadmillPrepareErr = treadmillManager:pulseForCarry(Nyx_treadmillTeleport, Nyx_treadmillLaunchCancelled)

			if not Nyx_treadmillPrepareOk then
				self:_restoreTreadmillVisualAtSafe()

				return false, Nyx_treadmillPrepareErr
			end

			self:_setStatus("Positioning at safe area")

			if not self:_restoreTreadmillVisualAtSafe() then
				return false, "Safe teleport failed"
			end

			if not Nyx_treadmillLaunchCancelled() then
				return true, Nyx_getEggFromUid()
			end

			return false, "Target changed before travel"
		end
		Nyx_EggRuntime._resolveEggDestination = function(self, record, rootPart, humanoid)
			if type(record) ~= "table" or typeof(record.BottomCFrame) ~= "CFrame" then
				return nil
			end

			local Character = LocalPlayer2.Character
			local HumanoidRootPart = rootPart or Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = humanoid or Character and Character:FindFirstChildOfClass("Humanoid")

			if HumanoidRootPart and Humanoid then
				return cFrameNew(record.BottomCFrame.Position + Vector3.new(0, self:_feetOffset(HumanoidRootPart, Humanoid) + 0.15, 0))
			end

			return nil
		end

		local function Nyx_getEggCarryBoundsZ()
			local ok, result = pcall(function()
				local Nyx_worldRef4 = Nyx_getWorkspaceWorld()

				return Nyx_worldRef4 and Nyx_worldRef4:FindFirstChild("Areas") and Nyx_worldRef4.Areas:FindFirstChild("EggCarryBounds")
			end)

			if ok and result then
				local Gameplay1 = result:FindFirstChild("Gameplay1")

				if Gameplay1 and Gameplay1:IsA("BasePart") then
					local Nyx_boundsHalfWidth = Gameplay1.Size.Z * 0.5 - 18

					if Nyx_boundsHalfWidth > 5 then
						return Gameplay1.Position.Z - Nyx_boundsHalfWidth, Gameplay1.Position.Z + Nyx_boundsHalfWidth
					end
				end
			end

			return -426, -308
		end

		Nyx_EggRuntime._resolveRouteCruiseY = function(self, rootPart, targetCFrame)
			if self.config.stealMode ~= "Fly" then
				return nil
			end

			if not rootPart or typeof(targetCFrame) ~= "CFrame" then
				return nil
			end

			if targetCFrame.Position.Y >= 104 then
				return nil
			end

			return 110
		end
		Nyx_EggRuntime._resolveElevatedDestination = function(self, rootPart, targetCFrame)
			if rootPart then
				if typeof(targetCFrame) == "CFrame" then
					return targetCFrame
				end
			end

			return nil
		end
		Nyx_EggRuntime._teleportRoot = function(self, rootPart, humanoid, targetCFrame)
			if not rootPart or not humanoid or typeof(targetCFrame) ~= "CFrame" then
				return false
			end

			if not pcall(function()
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.AssemblyAngularVelocity = Vector3.zero
				rootPart.CFrame = targetCFrame
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.AssemblyAngularVelocity = Vector3.zero
			end) then
				return false
			end

			local Nyx_teleportSpeed = math.clamp(self.config.speed or 600, 200, Nyx_getMaxSpeedClamp())

			Nyx_applySpoofWalkSpeed(LocalPlayer2.Character, Nyx_teleportSpeed * 1.35)

			if not Nyx_updateSpoofSpeed(humanoid, rootPart, Nyx_teleportSpeed, Vector3.zero) then
				Nyx_installSpoofFromCharacter(humanoid, rootPart, Nyx_teleportSpeed)
				Nyx_updateSpoofSpeed(humanoid, rootPart, Nyx_teleportSpeed, Vector3.zero)
			end

			return true
		end
		Nyx_EggRuntime._legitWalkSpeed = function(self)
			local Nyx_getEggCarryBoundsZ_var1

			pcall(function()
				local Character = LocalPlayer2.Character
				local WalkSpeed

				if Character then
					local Humanoid = LocalPlayer2.Character:FindFirstChildOfClass("Humanoid")

					WalkSpeed = Humanoid and Humanoid.WalkSpeed
				else
					WalkSpeed = Character
				end

				Nyx_getEggCarryBoundsZ_var1 = WalkSpeed
			end)

			if type(Nyx_getEggCarryBoundsZ_var1) == "number" and Nyx_getEggCarryBoundsZ_var1 >= 1 and Nyx_getEggCarryBoundsZ_var1 <= 400 then
				self._legitWsCache = Nyx_getEggCarryBoundsZ_var1
			end

			local _legitWsCache = self._legitWsCache or type(Nyx_getEggCarryBoundsZ_var1) == "number" and math.clamp(Nyx_getEggCarryBoundsZ_var1, 1, 400) or 16

			return _legitWsCache
		end

		do
			Nyx_EggRuntime._activeGlideSpeed = function(self)
				if self.config.stealMode == "Fly" and self._flyDeparting then
					return self:_legitWalkSpeed()
				end

				return 5000
			end
		end

		Nyx_EggRuntime._glideRoot = function(self, targetCFrame, cancelCheck, speedOverride)
			if typeof(targetCFrame) ~= "CFrame" then
				return false
			end

			local Nyx_glideSpeedLimit = speedOverride or self:_activeGlideSpeed()
			local Character = LocalPlayer2.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart or not Humanoid then
				return false
			end

			pcall(Nyx_getDebugSource_var1, Character)
			pcall(function()
				Humanoid.AutoRotate = false
			end)
			self:_startHoverPad()

			local Position = targetCFrame.Position

			local function Nyx_applyGlideSpeed(character, humanoid, rootPart)
				local Nyx_glideSpeedValue = math.clamp(self.config.speed or 600, 200, Nyx_getMaxSpeedClamp())

				pcall(function()
					Nyx_applySpoofWalkSpeed(character, Nyx_glideSpeedValue * 1.35)
					Nyx_updateSpoofSpeed(humanoid, rootPart, Nyx_glideSpeedValue, Vector3.zero)
				end)
			end

			local Nyx_glideDeadlineTime = os.clock() + math.clamp((Position - HumanoidRootPart.Position).Magnitude / math.max(Nyx_glideSpeedLimit, 1) * 1.6 + 6, 15, 120)

			while true do
				if not (os.clock() < Nyx_glideDeadlineTime) then
					return false
				end

				if cancelCheck and cancelCheck() then
					break
				end

				if self.destroyed or not self.enabled and not self._externalDeliver then
					return false
				end

				local Character2 = LocalPlayer2.Character
				local HumanoidRootPart2 = Character2 and Character2:FindFirstChild("HumanoidRootPart")

				Humanoid = Character2 and Character2:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart2 then
					return false
				end

				if not Humanoid then
					return false
				end

				local Position2 = HumanoidRootPart2.Position
				local Nyx_glideDelta = Position - Position2
				local Magnitude = Nyx_glideDelta.Magnitude

				if Magnitude <= 1 then
					pcall(function()
						HumanoidRootPart2.CFrame = targetCFrame
						HumanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
						HumanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
					end)
					self:_syncHoverPad(Position)
					Nyx_applyGlideSpeed(Character2, Humanoid, HumanoidRootPart2)

					return true
				end

				local Nyx_glideFrameDelta = math.max(math.min(RunService2.Heartbeat:Wait(), 0.15), 0.0041666666666666666)
				local Nyx_glideNextPos = Position2 + Nyx_glideDelta.Unit * math.min(Nyx_glideSpeedLimit * Nyx_glideFrameDelta, Magnitude)

				if Nyx_glideFrameDelta >= 0.033333333333333333 then
					local Nyx_glideGroundY = self:_groundYAt(Nyx_glideNextPos.X, Nyx_glideNextPos.Z, Character2)

					if Nyx_glideGroundY then
						local Nyx_glideGroundYFeet = Nyx_glideGroundY + self:_feetOffset(HumanoidRootPart2, Humanoid)

						if Nyx_glideNextPos.Y < Nyx_glideGroundYFeet then
							Nyx_glideNextPos = Vector3.new(Nyx_glideNextPos.X, Nyx_glideGroundYFeet, Nyx_glideNextPos.Z)
						end
					end
				end

				pcall(function()
					HumanoidRootPart2.CFrame = cFrameNew(Nyx_glideNextPos, Nyx_glideNextPos + Nyx_glideDelta.Unit)
					HumanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
					HumanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				end)
				self:_syncHoverPad(Nyx_glideNextPos)
				Nyx_applyGlideSpeed(Character2, Humanoid, HumanoidRootPart2)
			end

			return false
		end
		Nyx_EggRuntime._walkBrakeDecel = function(self)
			if self._brakeDecel then
				return self._brakeDecel
			end

			local __NyxBrakeDecel = genv.__NyxBrakeDecel

			if LocalPlayer2.Character then
				local Humanoid = LocalPlayer2.Character:FindFirstChildOfClass("Humanoid")

				if type(__NyxBrakeDecel) == "table" and Humanoid then
					if math.abs((__NyxBrakeDecel.ws or 0) - Humanoid.WalkSpeed) < 15 then
						self._brakeDecel = __NyxBrakeDecel.decel

						return __NyxBrakeDecel.decel
					end
				end
			else
				type(__NyxBrakeDecel)
			end

			return 420
		end

		do
			Nyx_EggRuntime._walkLeg = function(self, targetPos, cancelCheck, arriveDist, brakeOnArrive, deadline, onStep)
				local state = 1
				local Nyx_walkSelf, Nyx_walkTargetPos, Nyx_walkCancelCheck, Nyx_walkArriveDist, Nyx_walkBrakeOnArrive, Nyx_walkDeadline, Nyx_walkOnStep, Nyx_applyGlideSpeed_var1, Nyx_walkLastDir, Nyx_applyGlideSpeed_var2, Nyx_walkPrevSpeed, Nyx_walkPrevSpeedTime, Nyx_walkReleaseRoot, Nyx_applyGlideSpeed_var3, Nyx_applyGlideSpeed_var4, Nyx_applyGlideSpeed_var5, Nyx_applyGlideSpeed_var6, Character, HumanoidRootPart, Humanoid, Position, vector33, Magnitude, AssemblyLinearVelocity, Magnitude2, Nyx_walkCurrentDir, Nyx_walkHasVelocity, vector34, now, Nyx_walkBrakeDecel, Nyx_walkMinStepDist, Character2, Nyx_walkReleaseFn, Humanoid2, HumanoidRootPart2

				while true do
					if state == 1 then
						Nyx_walkSelf = self
						Nyx_walkTargetPos = targetPos
						Nyx_walkCancelCheck = cancelCheck
						Nyx_walkArriveDist = arriveDist
						Nyx_walkBrakeOnArrive = brakeOnArrive
						Nyx_walkDeadline = deadline
						Nyx_walkOnStep = onStep
						Nyx_applyGlideSpeed_var1 = 684529208
						Nyx_walkLastDir = nil
						Nyx_applyGlideSpeed_var2 = 602089359
						Nyx_walkPrevSpeed = nil
						Nyx_walkPrevSpeedTime = nil
						Nyx_walkReleaseRoot = function(humanoid, rootPart)
							if humanoid then
								if rootPart then
									pcall(function()
										humanoid:MoveTo(rootPart.Position)
									end)
								end
							end

							return false
						end
						Nyx_applyGlideSpeed_var3 = nil
						Nyx_applyGlideSpeed_var4 = nil
						Nyx_applyGlideSpeed_var5 = nil
						Nyx_applyGlideSpeed_var6 = nil

						if os.clock() < Nyx_walkDeadline then
							state = 2
						else
							state = 40
						end
					elseif state == 2 then
						Character = LocalPlayer2.Character
						HumanoidRootPart = Character

						if HumanoidRootPart then
							state = 35
						else
							state = 3
						end
					elseif state == 3 then
						if Character then
							state = 4
						else
							state = 39
						end
					elseif state == 4 then
						Humanoid = Character:FindFirstChildOfClass("Humanoid")
						state = 5
					elseif state == 5 then
						if HumanoidRootPart and Humanoid then
							state = 6
						else
							state = 38
						end
					elseif state == 6 then
						if Nyx_walkCancelCheck and Nyx_walkCancelCheck() then
							state = 7
						else
							state = 8
						end
					else
						if state == 7 then
							return Nyx_walkReleaseRoot(Humanoid, HumanoidRootPart)
						end

						if state == 8 then
							if not Nyx_walkSelf.destroyed and (Nyx_walkSelf.enabled or Nyx_walkSelf._externalDeliver) then
								state = 10
							else
								state = 9
							end
						else
							if state == 9 then
								return Nyx_walkReleaseRoot(Humanoid, HumanoidRootPart)
							end

							if state == 10 then
								Position = HumanoidRootPart.Position
								vector33 = Vector3.new(Nyx_walkTargetPos.X - Position.X, 0, Nyx_walkTargetPos.Z - Position.Z)
								Magnitude = vector33.Magnitude
								AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity
								Magnitude2 = Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude

								if Nyx_walkBrakeOnArrive then
									state = 11
								else
									state = 13
								end
							elseif state == 11 then
								if Magnitude <= Nyx_walkArriveDist and Magnitude2 <= 20 then
									state = 12
								else
									state = 19
								end
							else
								if state == 12 then
									pcall(function()
										Nyx_applyGlideSpeed_var3 = 26636988
										Nyx_applyGlideSpeed_var4 = 319405266
										Humanoid:MoveTo(Position)
									end)

									return true
								end

								if state == 13 then
									Nyx_walkCurrentDir = Nyx_walkLastDir

									if Nyx_walkCurrentDir then
										state = 18
									else
										state = 14
									end
								elseif state == 14 then
									Nyx_walkCurrentDir = Magnitude > 0.001

									if Nyx_walkCurrentDir then
										state = 15
									else
										state = 16
									end
								elseif state == 15 then
									Nyx_walkCurrentDir = vector33.Unit
									state = 16
								elseif state == 16 then
									if Nyx_walkCurrentDir then
										state = 18
									else
										state = 17
									end
								elseif state == 17 then
									Nyx_walkCurrentDir = Vector3.zero
									state = 18
								elseif state == 18 then
									Nyx_walkLastDir = Nyx_walkCurrentDir

									if Magnitude <= Nyx_walkArriveDist or vector33:Dot(Nyx_walkLastDir) <= 0 then
										state = 37
									else
										state = 19
									end
								elseif state == 19 then
									Nyx_walkHasVelocity = Magnitude > 0.001

									if Nyx_walkHasVelocity then
										state = 20
									else
										state = 21
									end
								elseif state == 20 then
									Nyx_walkHasVelocity = math.max(AssemblyLinearVelocity.X * vector33.X + AssemblyLinearVelocity.Z * vector33.Z, 0) / Magnitude
									state = 21
								elseif state == 21 then
									if Nyx_walkHasVelocity then
										state = 23
									else
										state = 22
									end
								elseif state == 22 then
									Nyx_walkHasVelocity = Magnitude2
									state = 23
								elseif state == 23 then
									if Nyx_walkBrakeOnArrive and Magnitude <= Nyx_walkHasVelocity * Nyx_walkHasVelocity / (2 * Nyx_walkSelf:_walkBrakeDecel()) + Nyx_walkHasVelocity * 0.06 then
										state = 24
									else
										state = 28
									end
								elseif state == 24 then
									vector34 = Position
									now = os.clock()

									if Nyx_walkPrevSpeed and Nyx_walkPrevSpeedTime < now and Magnitude2 > 20 then
										state = 25
									else
										state = 27
									end
								elseif state == 25 then
									Nyx_walkBrakeDecel = (Nyx_walkPrevSpeed - Magnitude2) / (now - Nyx_walkPrevSpeedTime)

									if Nyx_walkBrakeDecel > 20 and Nyx_walkBrakeDecel < 5000 then
										state = 26
									else
										state = 27
									end
								elseif state == 26 then
									Nyx_walkSelf._brakeDecel = Nyx_walkSelf:_walkBrakeDecel() * 0.8 + Nyx_walkBrakeDecel * 0.93 * 0.2
									genv.__NyxBrakeDecel = {
										ws = Humanoid.WalkSpeed,
										decel = Nyx_walkSelf._brakeDecel
									}
									state = 27
								elseif state == 27 then
									Nyx_walkPrevSpeed = Magnitude2
									Nyx_walkPrevSpeedTime = now
									state = 31
								elseif state == 28 then
									Nyx_walkPrevSpeed = nil
									Nyx_walkMinStepDist = math.max(Humanoid.WalkSpeed * 0.5, 12)

									if Nyx_walkBrakeOnArrive and Magnitude <= Nyx_walkMinStepDist then
										state = 29
									else
										state = 30
									end
								elseif state == 29 then
									vector34 = Vector3.new(Nyx_walkTargetPos.X, Position.Y, Nyx_walkTargetPos.Z)
									state = 31
								elseif state == 30 then
									vector34 = Position + vector33.Unit * Nyx_walkMinStepDist
									state = 31
								elseif state == 31 then
									pcall(function()
										Nyx_applyGlideSpeed_var5 = 843258489
										Nyx_applyGlideSpeed_var6 = 553919544
										Humanoid:MoveTo(vector34)
									end)

									if Nyx_walkOnStep then
										state = 32
									else
										state = 33
									end
								elseif state == 32 then
									Nyx_walkOnStep()
									state = 33
								elseif state == 33 then
									RunService2.Heartbeat:Wait()

									if os.clock() < Nyx_walkDeadline then
										state = 34
									else
										state = 40
									end
								elseif state == 34 then
									Character = LocalPlayer2.Character
									HumanoidRootPart = Character

									if HumanoidRootPart then
										state = 35
									else
										state = 36
									end
								elseif state == 35 then
									HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
									state = 36
								elseif state == 36 then
									Humanoid = Character

									if Humanoid then
										state = 4
									else
										state = 5
									end
								else
									if state == 37 then
										return true
									end

									if state == 38 then
										return false
									end

									if state == 39 then
										return false
									end

									if state == 40 then
										Character2 = LocalPlayer2.Character
										Nyx_walkReleaseFn = Nyx_walkReleaseRoot
										Humanoid2 = Character2

										if Humanoid2 then
											state = 41
										else
											state = 42
										end
									elseif state == 41 then
										Humanoid2 = Character2:FindFirstChildOfClass("Humanoid")
										state = 42
									elseif state == 42 then
										HumanoidRootPart2 = Character2

										if HumanoidRootPart2 then
											state = 43
										else
											state = 45
										end
									elseif state == 43 then
										HumanoidRootPart2 = Character2:FindFirstChild("HumanoidRootPart")
										state = 44
									elseif state == 44 then
										return Nyx_walkReleaseFn(Humanoid2, HumanoidRootPart2)
									elseif state == 45 then
										return Nyx_walkReleaseFn(Humanoid2, HumanoidRootPart2)
									end
								end
							end
						end
					end
				end
			end
		end

		do
			Nyx_EggRuntime._walkTo = function(self, targetCFrame, cancelCheck, arriveDist)
				if typeof(targetCFrame) ~= "CFrame" then
					return false
				end

				local Nyx_walkArriveDistParam = arriveDist or 8
				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart or not Humanoid then
					return false
				end

				pcall(function()
					Humanoid.AutoRotate = true
				end)

				local Position = targetCFrame.Position
				local WalkSpeed = Humanoid.WalkSpeed

				if not WalkSpeed or WalkSpeed < 1 then
					WalkSpeed = 16
				end

				local Magnitude = Vector3.new(Position.X - HumanoidRootPart.Position.X, 0, Position.Z - HumanoidRootPart.Position.Z).Magnitude

				return self:_walkLeg(Position, cancelCheck, Nyx_walkArriveDistParam, true, os.clock() + math.clamp(Magnitude / WalkSpeed * 2 + 8, 12, 90))
			end
		end

		Nyx_EggRuntime._walkToZigzag = function(self, targetCFrame, cancelCheck, arriveDist)
			if typeof(targetCFrame) ~= "CFrame" then
				return false
			end

			local Nyx_zigzagArriveDist = arriveDist or 8
			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not HumanoidRootPart or not Humanoid then
				return false
			end

			pcall(function()
				Humanoid.AutoRotate = true
			end)

			local Position = targetCFrame.Position
			local WalkSpeed = Humanoid.WalkSpeed

			if not WalkSpeed or WalkSpeed < 1 then
				WalkSpeed = 16
			end

			local Magnitude = Vector3.new(Position.X - HumanoidRootPart.Position.X, 0, Position.Z - HumanoidRootPart.Position.Z).Magnitude
			local Nyx_zigzagBrakeDist = math.max(45, WalkSpeed * WalkSpeed / (2 * self:_walkBrakeDecel()) * 2.5)
			local Nyx_zigzagDeadline = os.clock() + math.clamp(Magnitude / WalkSpeed * 3 + 10, 14, 120)
			local Nyx_zigzagLaneMin
			local Nyx_zigzagLaneMax
			local ok, result, result2 = pcall(function()
				return Nyx_getEggCarryBoundsZ()
			end)

			if ok and type(result) == "number" and type(result2) == "number" then
				Nyx_zigzagLaneMin = math.min(result, result2)
				Nyx_zigzagLaneMax = math.max(result, result2)
			end

			while true do
				if not (os.clock() < Nyx_zigzagDeadline) then
					return false
				end

				if cancelCheck and cancelCheck() then
					break
				end

				if self.destroyed or not self.enabled then
					return false
				end

				local Character2 = LocalPlayer2.Character
				local HumanoidRootPart2 = Character2 and Character2:FindFirstChild("HumanoidRootPart")

				Humanoid = Character2 and Character2:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart2 or not Humanoid then
					return false
				end

				local Position2 = HumanoidRootPart2.Position
				local vector33 = Vector3.new(Position.X - Position2.X, 0, Position.Z - Position2.Z)
				local Magnitude2 = vector33.Magnitude

				if Magnitude2 <= Nyx_zigzagBrakeDist then
					return self:_walkLeg(Position, cancelCheck, Nyx_zigzagArriveDist, true, Nyx_zigzagDeadline)
				end

				local Unit = vector33.Unit
				local vector34 = Vector3.new(-Unit.Z, 0, Unit.X)
				local Nyx_zigzagStepDist = math.max(Magnitude2 - Nyx_zigzagBrakeDist * 0.5, 4)
				local Nyx_zigzagForwardDist = math.min(60 + math.random() * 40, Nyx_zigzagStepDist)
				local Nyx_zigzagSideDist = math.min(38, Nyx_zigzagForwardDist * 0.4)
				local Nyx_zigzagTargetPos = Position2 + Unit * Nyx_zigzagForwardDist + vector34 * ((math.random() * 2 - 1) * Nyx_zigzagSideDist)
				local Z = Nyx_zigzagTargetPos.Z

				if Nyx_zigzagLaneMin and Nyx_zigzagLaneMax then
					Z = math.clamp(Z, Nyx_zigzagLaneMin + 2, Nyx_zigzagLaneMax - 2)
				end

				if self:_walkLeg(Vector3.new(Nyx_zigzagTargetPos.X, Position2.Y, Z), cancelCheck, 10, false, Nyx_zigzagDeadline) then
					continue
				end

				return false
			end

			return false
		end
		Nyx_EggRuntime._flyWalkTo = function(self, targetCFrame, cancelCheck, arriveDist, hoverHeight)
			if typeof(targetCFrame) ~= "CFrame" then
				return false
			end

			local Nyx_flyWalkArriveDist = arriveDist or 8
			local hoverPadHeightOverride = tonumber(hoverHeight) or 110
			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not HumanoidRootPart or not Humanoid then
				return false
			end

			pcall(function()
				Humanoid.AutoRotate = true
			end)

			local function Nyx_stopAnimations()
				pcall(function()
					local Humanoid2 = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChildOfClass("Humanoid")
					local Animator = Humanoid2 and Humanoid2:FindFirstChildWhichIsA("Animator")

					if Animator then
						for _, v in ipairs(Animator:GetPlayingAnimationTracks()) do
							v:Stop(0)
						end
					end
				end)
			end
			local function Nyx_toggleAnimate(disabled)
				local Character2 = LocalPlayer2.Character
				local Animate = Character2 and Character2:FindFirstChild("Animate")

				if Animate then
					pcall(function()
						Animate.Disabled = disabled
					end)
				end
			end

			Nyx_toggleAnimate(true)
			Nyx_stopAnimations()

			local Position = targetCFrame.Position

			self.hoverPadHeightOverride = hoverPadHeightOverride
			self:_startHoverPad()
			pcall(function()
				HumanoidRootPart.CFrame = cFrameNew(HumanoidRootPart.Position.X, hoverPadHeightOverride, HumanoidRootPart.Position.Z) * HumanoidRootPart.CFrame.Rotation
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			end)
			self:_syncHoverPad()

			local WalkSpeed = Humanoid.WalkSpeed

			if not WalkSpeed or WalkSpeed < 1 then
				WalkSpeed = 16
			end

			local Magnitude = Vector3.new(Position.X - HumanoidRootPart.Position.X, 0, Position.Z - HumanoidRootPart.Position.Z).Magnitude
			local Nyx_flyWalkSuccess = self:_walkLeg(Position, cancelCheck, Nyx_flyWalkArriveDist, true, os.clock() + math.clamp(Magnitude / WalkSpeed * 2 + 10, 12, 120), Nyx_stopAnimations)

			Nyx_toggleAnimate(false)
			self.hoverPadHeightOverride = nil

			if not Nyx_flyWalkSuccess then
				return false
			end

			if cancelCheck and cancelCheck() then
				return false
			end

			self:_glideRoot(targetCFrame, cancelCheck, self:_legitWalkSpeed())

			local Nyx_flyWalkCancelled = cancelCheck and cancelCheck()

			return not Nyx_flyWalkCancelled
		end
		Nyx_EggRuntime._isInSafeArea = function(self, rootPart)
			if not rootPart then
				return false
			end

			local Nyx_deltaFromSafe = rootPart.Position - vector32

			return Vector2.new(Nyx_deltaFromSafe.X, Nyx_deltaFromSafe.Z).Magnitude <= 30 and math.abs(Nyx_deltaFromSafe.Y) <= 18
		end
		Nyx_EggRuntime._isInField = function(self, rootPart)
			local Nyx_worldRef5 = Nyx_getWorkspaceWorld()
			local Areas = Nyx_worldRef5 and Nyx_worldRef5:FindFirstChild("Areas")
			local WallStartCollision = Areas and Areas:FindFirstChild("WallStartCollision")

			if WallStartCollision and WallStartCollision:IsA("BasePart") then
				return rootPart.Position.X >= WallStartCollision.Position.X + 3
			end

			return true
		end
		Nyx_EggRuntime._needsSafeZoneHop = function(self, rootPart)
			if self:_isInField(rootPart) or self:_isInSafeArea(rootPart) then
				return false, nil
			end

			return true, self:_resolveSafeCFrame(rootPart)
		end
		Nyx_EggRuntime._invalidateCarryWorker = function(self)
			self.carryWorker = nil
		end
		Nyx_EggRuntime._claimCarryWorker = function(self, kind, uid)
			local generation = self.carry.generation
			local carryWorker = self.carryWorker

			if carryWorker then
				if carryWorker.generation == generation then
					return nil
				end
			end

			local carryWorker2 = {
				kind = kind,
				uid = uid,
				generation = generation,
				token = {}
			}

			self.carryWorker = carryWorker2

			return carryWorker2
		end

		do
			Nyx_EggRuntime._isCarryWorkerCurrent = function(self, worker)
				return type(worker) == "table" and self.carryWorker == worker and self.carry.generation == worker.generation and not self.destroyed and (self.enabled or self._externalDeliver)
			end
		end

		Nyx_EggRuntime._releaseCarryWorker = function(self, worker)
			if self.carryWorker == worker then
				self.carryWorker = nil
			end
		end
		Nyx_EggRuntime.ownsCarryRecovery = function(self, uid)
			if self.destroyed or not self.enabled then
				return false
			end

			if self.carry.uid == uid then
				return true
			end

			return self.running and self.activeTarget ~= nil and (uid == nil or self.activeTarget.Uid == uid)
		end
		Nyx_EggRuntime.requestCarryRecovery = function(self, uid)
			if self.destroyed or not self.enabled or type(uid) ~= "string" or uid == "" then
				return false
			end

			if self:isSkippedEgg(uid) then
				return true
			end

			if self.tweenRecoveryUid == uid then
				self:_scheduleMovementRetry()

				return true
			end

			if self.carry.active and self.carry.uid == uid then
				return true
			end

			local Nyx_recoveryTargetRecord = EggState2.ReadFieldEgg(uid) or self.records[uid]

			if type(Nyx_recoveryTargetRecord) ~= "table" or Nyx_recoveryTargetRecord.State ~= AreaEggs.States.Dropped and Nyx_recoveryTargetRecord.State ~= AreaEggs.States.Slot then
				return false
			end

			local carryWorker = self.carryWorker

			if (not carryWorker or carryWorker.kind ~= "re-steal" or carryWorker.uid ~= uid) and (not self.activeTween or not self.activeTarget or self.activeTarget.Uid ~= uid) then
				if not self.carryAttemptToken or not self.activeTarget or self.activeTarget.Uid ~= uid then
					local carry = self.carry

					carry.generation += 1
					self:_invalidateCarryWorker()
					self.carryAttemptToken = nil
					self.running = true
					self.activeTarget = Nyx_recoveryTargetRecord
					task.defer(function()
						if not self.destroyed and self.enabled and not self.carry.active then
							self:_reStealDroppedEgg(uid)
						end
					end)

					return true
				end
			end

			return true
		end
		Nyx_EggRuntime._hasConfirmedCarry = function(self, uid)
			if not self.carry.active then
				return false
			end

			if uid == nil or self.carry.uid == nil then
				return true
			end

			return self.carry.uid == uid
		end
		Nyx_EggRuntime._adoptCarryFromRecord = function(self, uid)
			if self.carry.active and self.carry.uid == uid then
				return
			end

			if self.carryTimeouts then
				self.carryTimeouts[uid] = nil
			end

			if self.instantPhase == "priming" and uid == self.primerUid then
				self.carry.active = true
				self.carry.uid = uid

				return
			end

			local carry = self.carry

			carry.generation += 1
			self:_invalidateCarryWorker()
			self:_clearArrivalHold(uid)

			local activeTarget = self.activeTarget

			self.claimPresentationSuppression = {
				assetCategory = activeTarget and activeTarget.AssetCategory,
				expiresAt = os.clock() + 8
			}
			self.carry.active = true
			self.carry.uid = uid
			self.carryStartTime = os.clock()

			local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

			self.carryStartPos = activeTarget and activeTarget.BottomCFrame and activeTarget.BottomCFrame.Position or HumanoidRootPart and HumanoidRootPart.Position

			if self.tweenRecoveryUid == uid then
				self.tweenRecoveryUid = nil
			end

			self.stats.lastResult = "Carry confirmed"
			self:_notify()
		end
		Nyx_EggRuntime._recordShowsCarried = function(self, uid)
			if type(uid) ~= "string" or uid == "" then
				return false
			end

			local Nyx_recordShowsCarried = EggState2.ReadFieldEgg(uid) or self.records[uid]

			return type(Nyx_recordShowsCarried) == "table" and Nyx_recordShowsCarried.State == AreaEggs.States.Carried and Nyx_recordShowsCarried.CarrierUserId == LocalPlayer2.UserId
		end
		Nyx_EggRuntime._recordShowsForeignCarry = function(self, uid)
			if type(uid) ~= "string" or uid == "" then
				return false
			end

			local Nyx_recordShowsForeign = EggState2.ReadFieldEgg(uid) or self.records[uid]

			return type(Nyx_recordShowsForeign) == "table" and Nyx_recordShowsForeign.State == AreaEggs.States.Carried and Nyx_recordShowsForeign.CarrierUserId ~= nil and Nyx_recordShowsForeign.CarrierUserId ~= LocalPlayer2.UserId
		end
		Nyx_EggRuntime._resolveMovementSpeed = function(self, humanoid)
			if not humanoid.Parent or humanoid.Health <= 0 then
				return nil
			end

			return math.clamp(self.config.speed, 200, Nyx_getMaxSpeedClamp())
		end
		Nyx_EggRuntime._isAreaSafe = function()
			return true
		end
		Nyx_EggRuntime._feetOffset = function(self, rootPart, humanoid)
			if humanoid.RigType == Enum.HumanoidRigType.R15 then
				return rootPart.Size.Y * 0.5 + math.max(humanoid.HipHeight, 0.5)
			end

			return rootPart.Size.Y * 0.5 + 2
		end
		Nyx_EggRuntime.setAntiTrap = function(self, enabled)
			self.config.antiTrap = enabled == true

			if self.config.antiTrap then
				self:_purgeTraps()
			end
		end
		Nyx_EggRuntime._isForeignTrap = function(self, instance)
			if instance.Name == "PlayerTrap" and instance:IsA("BasePart") then
				local attribute = instance:GetAttribute("Owner")

				return type(attribute) ~= "string" or attribute ~= LocalPlayer2.Name
			end

			return instance:IsA("Model") and instance.Name == "Trap" and instance:FindFirstChild("Hitbox") ~= nil
		end
		Nyx_EggRuntime._purgeTrap = function(self, instance)
			if self.config.antiTrap and instance then
				if instance.Parent then
					if self:_isForeignTrap(instance) then
						pcall(instance.Destroy, instance)
					end

					return
				end
			end
		end
		Nyx_EggRuntime._purgeTraps = function(self)
			for _, v in ipairs({
				"Transient",
				"__DEBRIS"
			}) do
				local Nyx_trapFolder = workspace:FindFirstChild(v)

				if Nyx_trapFolder then
					for _, descendant in ipairs(Nyx_trapFolder:GetDescendants()) do
						self:_purgeTrap(descendant)
					end
				end
			end
		end

		do
			Nyx_EggRuntime._syncHoverPad = function(self, position)
				local hoverPad = self.hoverPad

				if not hoverPad or not hoverPad.Parent or hoverPad:GetAttribute("NyxRuntimeOwner") ~= self.hoverPadOwnerId then
					return false
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart or not Humanoid then
					return false
				end

				local Position = typeof(position) == "Vector3" and position or HumanoidRootPart.Position
				local Y = Position.Y

				if self.hoverPadHeightOverride ~= nil and typeof(position) ~= "Vector3" then
					Y = self.hoverPadHeightOverride
				end

				local Nyx_toggleAnimate_var1 = 8

				if self.hoverPadHeightOverride ~= nil then
					Nyx_toggleAnimate_var1 = math.max(8, Humanoid.WalkSpeed * 2 / 15)
				end

				if math.abs(hoverPad.Size.X - Nyx_toggleAnimate_var1) > 0.5 then
					hoverPad.Size = Vector3.new(Nyx_toggleAnimate_var1, 1, Nyx_toggleAnimate_var1)
				end

				hoverPad.CFrame = cFrameNew(Position.X, Y - self:_feetOffset(HumanoidRootPart, Humanoid) - 0.5 - 0.05, Position.Z)

				return true
			end
		end

		do
			Nyx_EggRuntime._setArrivalHold = function(self, targetCFrame, uid)
				if typeof(targetCFrame) ~= "CFrame" then
					return
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

				if not Character or not HumanoidRootPart then
					return
				end

				self.arrivalHold = {
					Character = Character,
					RootPart = HumanoidRootPart,
					CFrame = targetCFrame,
					Uid = uid
				}
			end
		end

		Nyx_EggRuntime._clearArrivalHold = function(self, uid)
			local arrivalHold = self.arrivalHold

			if not arrivalHold or uid == nil or arrivalHold.Uid == nil or arrivalHold.Uid == uid then
				self.arrivalHold = nil
			end
		end
		Nyx_EggRuntime._enforceArrivalHold = function(self)
			local arrivalHold = self.arrivalHold

			if type(arrivalHold) ~= "table" or typeof(arrivalHold.CFrame) ~= "CFrame" then
				return false
			end

			if LocalPlayer2.Character ~= arrivalHold.Character or not arrivalHold.RootPart or not arrivalHold.RootPart.Parent then
				self.arrivalHold = nil

				return false
			end

			self:_startHoverPad()
			pcall(function()
				arrivalHold.RootPart.AssemblyLinearVelocity = Vector3.zero
				arrivalHold.RootPart.AssemblyAngularVelocity = Vector3.zero
				self:_syncHoverPad(arrivalHold.CFrame.Position)
				arrivalHold.RootPart.CFrame = arrivalHold.CFrame
			end)
			self:_syncHoverPad(arrivalHold.CFrame.Position)

			return true
		end
		Nyx_EggRuntime._purgeOrphanHoverPads = function(self)
			for _, child in ipairs(workspace:GetChildren()) do
				if child.Name == "__NyxHoverPad" and child ~= self.hoverPad then
					pcall(child.Destroy, child)
				end
			end
		end
		Nyx_EggRuntime._startHoverPad = function(self)
			local hoverPad = self.hoverPad

			if not hoverPad or not hoverPad.Parent or hoverPad:GetAttribute("NyxRuntimeOwner") ~= self.hoverPadOwnerId then
				self:_purgeOrphanHoverPads()

				if hoverPad and hoverPad.Parent then
					pcall(hoverPad.Destroy, hoverPad)
				end

				local Part = Instance.new("Part")

				Part.Name = "__NyxHoverPad"
				Part:SetAttribute("NyxRuntimeOwner", self.hoverPadOwnerId)
				Part.Anchored = true
				Part.CanCollide = true
				Part.CanQuery = true
				Part.CanTouch = false
				Part.CastShadow = false
				Part.Transparency = 1
				Part.Material = Enum.Material.SmoothPlastic
				Part.Size = Vector3.new(8, 1, 8)
				self.hoverPad = Part
				Part.Parent = workspace
			end

			self:_syncHoverPad()

			if not self.hoverPadConnection then
				self.hoverPadConnection = RunService2.PreSimulation:Connect(function()
					if not self:_syncHoverPad() then
						self:_startHoverPad()
					end
				end)
			end

			if not self.hoverPadPostConnection then
				self.hoverPadPostConnection = RunService2.PostSimulation:Connect(function()
					if self.activeTween or self.arrivalHold then
						self:_syncHoverPad()
					end
				end)
			end
		end

		do
			Nyx_EggRuntime._stopHoverPad = function(self)
				self.hoverPadHeightOverride = nil

				if self.hoverPadConnection then
					pcall(self.hoverPadConnection.Disconnect, self.hoverPadConnection)
					self.hoverPadConnection = nil
				end

				if self.hoverPadPostConnection then
					pcall(self.hoverPadPostConnection.Disconnect, self.hoverPadPostConnection)
					self.hoverPadPostConnection = nil
				end

				if self.hoverPad then
					pcall(self.hoverPad.Destroy, self.hoverPad)
					self.hoverPad = nil
				end

				self:_purgeOrphanHoverPads()
			end
		end

		do
			Nyx_EggRuntime._startMovementProtection = function(self)
				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not Character or not HumanoidRootPart or not Humanoid then
					return false
				end

				local Nyx_protectionSpeed = math.clamp(self.config.speed or 600, 200, Nyx_getMaxSpeedClamp())

				self.protectionCharacter = Character
				self.protectionHumanoid = Humanoid
				self.protectionRoot = HumanoidRootPart
				Nyx_applySpoofWalkSpeed(Character, Nyx_protectionSpeed * 1.35)
				Nyx_installSpoofFromCharacter(Humanoid, HumanoidRootPart, Nyx_protectionSpeed)

				if not self.integritySpoofConnection then
					self.integritySpoofConnection = RunService2.PreSimulation:Connect(function()
						local Character2 = LocalPlayer2.Character
						local HumanoidRootPart2 = Character2 and Character2:FindFirstChild("HumanoidRootPart")
						local Humanoid2 = Character2 and Character2:FindFirstChildOfClass("Humanoid")

						if not Character2 or not HumanoidRootPart2 or not Humanoid2 then
							return
						end

						local Nyx_protectionSpeed2 = math.clamp(self.config.speed or 600, 200, Nyx_getMaxSpeedClamp())

						self.protectionCharacter = Character2
						self.protectionHumanoid = Humanoid2
						self.protectionRoot = HumanoidRootPart2
						Nyx_applySpoofWalkSpeed(Character2, Nyx_protectionSpeed2 * 1.35)

						if not Nyx_updateSpoofSpeed(Humanoid2, HumanoidRootPart2, Nyx_protectionSpeed2) then
							Nyx_installSpoofFromCharacter(Humanoid2, HumanoidRootPart2, Nyx_protectionSpeed2)
						end

						self:_enforceArrivalHold()
					end)
				end

				if not self.arrivalHoldConnection then
					self.arrivalHoldConnection = RunService2.Heartbeat:Connect(function()
						self:_enforceArrivalHold()
					end)
				end

				return true
			end
		end

		Nyx_EggRuntime._startFlyGrounding = function(self)
			self:_stopFlyGrounding()

			local Nyx_integrityState3 = Nyx_getIntegrityState2()

			self._flyGroundConn = RunService2.PreSimulation:Connect(function()
				if self.destroyed then
					return
				end

				local State = Nyx_integrityState3 and Nyx_integrityState3.State

				if type(State) ~= "table" or rawget(State, "CorrectionContext") ~= nil then
					return
				end

				rawset(State, "IsSupportedNow", true)
				rawset(State, "UnsupportedStartedAt", nil)

				if rawget(State, "MovementMode") ~= "Correcting" then
					rawset(State, "MovementMode", "Grounded")
				end

				local value = rawget(State, "Evidence")

				if type(value) == "table" then
					value.Flight = 0
					value.Teleport = 0
					value.Speed = 0
				end
			end)
		end
		Nyx_EggRuntime._stopFlyGrounding = function(self)
			if self._flyGroundConn then
				pcall(self._flyGroundConn.Disconnect, self._flyGroundConn)
				self._flyGroundConn = nil
			end
		end
		Nyx_EggRuntime._stopMovementProtection = function(self)
			self:_stopFlyGrounding()

			if self.integritySpoofConnection then
				pcall(self.integritySpoofConnection.Disconnect, self.integritySpoofConnection)
				self.integritySpoofConnection = nil
			end

			if self.arrivalHoldConnection then
				pcall(self.arrivalHoldConnection.Disconnect, self.arrivalHoldConnection)
				self.arrivalHoldConnection = nil
			end

			self:_clearArrivalHold()
			self:_stopHoverPad()
			Nyx_clearSpoofState()
			Nyx_clearSpoofHumanoid(self.protectionHumanoid)
			self.protectionCharacter = nil
			self.protectionHumanoid = nil
			self.protectionRoot = nil
		end
		Nyx_EggRuntime.travelAndWait = function(self, targetCFrame, options)
			local Nyx_travelOptions = options or {}

			if self.destroyed then
				return false
			end

			if self.travelBusy then
				if os.clock() < (self.travelBusyUntil or 0) then
					return false
				end
			end

			if self.activeTween and not self.running and (not self.activeTween.sharedTravel or Nyx_travelOptions.preempt == true) then
				pcall(self.activeTween.Cancel, self.activeTween)

				local Nyx_cancelWaitDeadline = os.clock() + 0.5

				while self.activeTween and os.clock() < Nyx_cancelWaitDeadline do
					task.wait(0.05)
				end
			end

			if self.activeTween then
				return false
			end

			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart then
				return false
			end

			self.travelBusy = true
			self.travelBusyUntil = os.clock() + 45

			local ok, result = pcall(function()
				local Nyx_toggleAnimate_var2
				local now = os.clock()
				local Nyx_lastProgressTime = now
				local Magnitude = (targetCFrame.Position - HumanoidRootPart.Position).Magnitude
				local Nyx_travelAbsoluteDeadline = now + Magnitude / math.max(tonumber(Nyx_travelOptions.speed) or self.config.speed or 600, 200) + 6

				self.travelBusyUntil = Nyx_travelAbsoluteDeadline + 2
				self:_tweenRoot(targetCFrame, nil, Nyx_travelOptions.speed, {
					silent = true,
					sharedTravel = true,
					abort = function()
						return self.destroyed or Nyx_travelOptions.abort ~= nil and Nyx_travelOptions.abort()
					end,
					onDone = function(success)
						Nyx_toggleAnimate_var2 = success == true
					end
				})

				while Nyx_toggleAnimate_var2 == nil do
					local now2 = os.clock()
					local HumanoidRootPart2 = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")
					local Magnitude2 = HumanoidRootPart2 and (targetCFrame.Position - HumanoidRootPart2.Position).Magnitude or math.huge

					if Magnitude2 < Magnitude - 0.5 then
						Magnitude = Magnitude2
						Nyx_lastProgressTime = now2
					end

					if self.destroyed or Nyx_travelOptions.abort ~= nil and Nyx_travelOptions.abort() or now2 - Nyx_lastProgressTime >= 1.5 or Nyx_travelAbsoluteDeadline <= now2 then
						if self.activeTween and self.activeTween.Cancel then
							pcall(self.activeTween.Cancel)
						end

						Nyx_toggleAnimate_var2 = false

						break
					else
						task.wait(0.05)
					end
				end

				return Nyx_toggleAnimate_var2
			end)

			self.travelBusy = false

			if ok then
				return result == true
			end

			if self.activeTween and self.activeTween.sharedTravel and self.activeTween.Cancel then
				pcall(self.activeTween.Cancel)
			end

			return false
		end

		do
			Nyx_EggRuntime._tweenRoot = function(self, targetCFrame, onSuccess, speedOverride, options)
				self:_clearArrivalHold()

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				local Nyx_tweenOptions = options or {}

				if not HumanoidRootPart or not Humanoid then
					self.safeStarting = false

					if not Nyx_tweenOptions.silent then
						self:_finish("Character unavailable")

						return
					end

					if Nyx_tweenOptions.onDone then
						pcall(Nyx_tweenOptions.onDone, false)
					end

					return
				end

				local Nyx_resolvedMoveSpeed = speedOverride or self:_resolveMovementSpeed(Humanoid)

				if not Nyx_resolvedMoveSpeed then
					self.safeStarting = false

					if not Nyx_tweenOptions.silent then
						self:_finish("Movement unavailable")

						return
					end

					if Nyx_tweenOptions.onDone then
						pcall(Nyx_tweenOptions.onDone, false)
					end

					return
				end

				local Nyx_clampedMoveSpeed = math.clamp(Nyx_resolvedMoveSpeed, 200, Nyx_getMaxSpeedClamp())

				self:_startMovementProtection()
				pcall(Nyx_getDebugSource_var1, Character)

				local CurrentCamera = workspace.CurrentCamera

				if CurrentCamera and CurrentCamera.CameraSubject ~= Humanoid then
					pcall(function()
						CurrentCamera.CameraSubject = Humanoid
					end)
				end

				local AutoRotate = Humanoid.AutoRotate

				Humanoid.AutoRotate = false

				local Nyx_routeCruiseY = Nyx_tweenOptions.flightProfile == true and self:_resolveRouteCruiseY(HumanoidRootPart, targetCFrame) or nil
				local activeTween = {
					sharedTravel = Nyx_tweenOptions.sharedTravel == true,
					routeCruiseY = Nyx_routeCruiseY,
					travelPhase = Nyx_routeCruiseY and "takeoff" or nil,
					zigzag = self.config.stealMode == "Zig-Zag",
					zigT = 0,
					zigLast = 0
				}

				self.activeTween = activeTween
				self:_startHoverPad()

				local Nyx_onDone_var2 = false
				local connection
				local now
				local Nyx_onDone_var3
				local Nyx_onDone_var1 = 0

				local function Nyx_finishTween(success)
					if Nyx_onDone_var2 then
						return
					end

					Nyx_onDone_var2 = true
					now = nil

					if Humanoid.Parent ~= nil then
						Humanoid.AutoRotate = AutoRotate
					end

					if success and Nyx_tweenOptions.holdAfterArrival then
						self:_setArrivalHold(targetCFrame, Nyx_tweenOptions.holdUid)
					end

					if Nyx_tweenOptions.onDone then
						pcall(Nyx_tweenOptions.onDone, success == true)
					end

					if connection then
						connection:Disconnect()
						connection = nil
					end

					if self.activeTween == activeTween then
						self.activeTween = nil
					end

					if not self.arrivalHold then
						self:_stopHoverPad()
					end

					if not self.enabled then
						self:_stopMovementProtection()
					end

					pcall(function()
						if LocalPlayer2.Character == Character and HumanoidRootPart.Parent then
							HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						end
					end)

					if success and LocalPlayer2.Character == Character and Humanoid.Parent ~= nil and onSuccess then
						onSuccess()
					end
				end

				activeTween.Cancel = function()
					Nyx_finishTween(false)
				end
				connection = RunService2.Heartbeat:Connect(function(dt)
					if Nyx_tweenOptions.abort and Nyx_tweenOptions.abort() then
						Nyx_finishTween(false)

						return
					end

					if self.destroyed or self.activeTween ~= activeTween then
						Nyx_finishTween(false)

						return
					end

					if Nyx_tweenOptions.carryTarget then
						if (activeTween.nextTargetCheck or 0) <= os.clock() then
							activeTween.nextTargetCheck = os.clock() + 0.1

							local Uid = Nyx_tweenOptions.carryTarget.Uid
							local Nyx_eggStateRecord = EggState2.ReadFieldEgg(Uid)
							local State = Nyx_eggStateRecord and Nyx_eggStateRecord.State

							if State ~= AreaEggs.States.Slot and State ~= AreaEggs.States.Dropped and State ~= "GuardCarried" and (not Nyx_eggStateRecord or Nyx_eggStateRecord.CarrierUserId ~= LocalPlayer2.UserId) and not self:_hasConfirmedCarry(Uid) then
								Nyx_finishTween(false)

								local __NyxPlayerSteal = genv.__NyxPlayerSteal

								self:_finish(State == "Carried" and __NyxPlayerSteal ~= nil and __NyxPlayerSteal:intercept(Uid) and "Target taken - chasing the carrier" or "Target taken by someone else")

								return
							end
						end
					end

					pcall(function()
						local Nyx_tweenSpeedValue = math.clamp(speedOverride or self.config.speed or Nyx_clampedMoveSpeed, 200, Nyx_getMaxSpeedClamp())

						Nyx_applySpoofWalkSpeed(Character, Nyx_tweenSpeedValue * 1.35)

						local __NyxStealAnEggIntegritySpoof = Nyx_getGenv().__NyxStealAnEggIntegritySpoof
						local State = type(__NyxStealAnEggIntegritySpoof) == "table" and __NyxStealAnEggIntegritySpoof.State or nil

						if not Nyx_isOwnStateB(State, Humanoid, HumanoidRootPart) then
							Nyx_onDone_var3 = nil
							now = nil
							HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
							HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
							self:_syncHoverPad(HumanoidRootPart.Position)

							if Nyx_isOwnStateA(State, Humanoid, HumanoidRootPart) then
								Nyx_applySpeedToState(State, Nyx_tweenSpeedValue * 1.35, Vector3.zero)
							else
								Nyx_installSpoofFromCharacter(Humanoid, HumanoidRootPart, Nyx_tweenSpeedValue)
							end

							return
						end

						local Position = HumanoidRootPart.Position
						local Nyx_tweenDelta = targetCFrame.Position - Position
						local Magnitude = Nyx_tweenDelta.Magnitude
						local vector33 = Vector3.new(Nyx_tweenDelta.X, 0, Nyx_tweenDelta.Z)
						local Magnitude2 = vector33.Magnitude
						local Position2 = targetCFrame.Position

						if activeTween.routeCruiseY then
							if activeTween.travelPhase == "takeoff" then
								if activeTween.routeCruiseY - 0.5 <= Position.Y then
									activeTween.travelPhase = "cruise"
								else
									Position2 = Vector3.new(Position.X, activeTween.routeCruiseY, Position.Z)
								end
							end

							if activeTween.travelPhase == "cruise" then
								if Magnitude2 <= 4 then
									activeTween.travelPhase = "descend"
								else
									Position2 = Vector3.new(targetCFrame.Position.X, activeTween.routeCruiseY, targetCFrame.Position.Z)
								end
							end

							if activeTween.travelPhase == "descend" then
								Position2 = targetCFrame.Position
							end
						end

						local Nyx_positionDelta = Position2 - Position
						local Magnitude3 = Nyx_positionDelta.Magnitude
						local routeCruiseY = activeTween.routeCruiseY and Magnitude2 or Magnitude

						if Nyx_onDone_var3 and Nyx_onDone_var3 + 2 < routeCruiseY then
							Nyx_onDone_var1 = os.clock() + 0.5
						end

						Nyx_onDone_var3 = routeCruiseY

						local Nyx_tweenFrameSpeed = os.clock() < Nyx_onDone_var1 and math.max(200, Nyx_tweenSpeedValue * 0.45) or Nyx_tweenSpeedValue

						if Nyx_tweenOptions.carryTarget and not activeTween.__earlyCarrySpam and Magnitude <= 30 then
							activeTween.__earlyCarrySpam = true

							local carryTarget = Nyx_tweenOptions.carryTarget
							local Uid = carryTarget.Uid
							local Nyx_slotKey = AreaEggSlotIdentity.LooksLikeFirstAreaUid(Uid) and AreaEggSlotIdentity.SlotKey(carryTarget.AreaId, carryTarget.NestId) or nil

							task.spawn(function()
								while not self.destroyed and self.enabled and self.activeTween == activeTween and not self:_hasConfirmedCarry(Uid) do
									pcall(Nyx_getMaxSpeedClamp_var1, Uid, Nyx_slotKey)
									task.wait(0.08)
								end
							end)
						end

						local Nyx_tweenFrameDelta = math.max(math.min(dt, 0.15), 0.0041666666666666666)
						local Nyx_tweenStepDist = Nyx_tweenFrameSpeed * Nyx_tweenFrameDelta
						local Nyx_tweenDirVector = vector33
						local vector34 = Vector3.new(HumanoidRootPart.CFrame.LookVector.X, 0, HumanoidRootPart.CFrame.LookVector.Z)
						local Unit = Nyx_tweenDirVector.Magnitude > 0.001 and Nyx_tweenDirVector.Unit or vector34.Magnitude > 0.001 and vector34.Unit or Vector3.new(0, 0, -1)

						if (not activeTween.routeCruiseY or activeTween.travelPhase == "descend") and Magnitude <= math.max(Nyx_tweenStepDist, 0.05) then
							if Magnitude > 0.5 then
								now = nil
							end

							self:_syncHoverPad(targetCFrame.Position)
							HumanoidRootPart.CFrame = lookAt(targetCFrame.Position, targetCFrame.Position + Unit)
							HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
							self:_syncHoverPad(targetCFrame.Position)
							Nyx_updateSpoofSpeed(Humanoid, HumanoidRootPart, Nyx_tweenSpeedValue, Vector3.zero)
							now = now or os.clock()

							if os.clock() - now >= 0.4 then
								Nyx_finishTween(true)
							end

							return
						end

						now = nil

						if Magnitude3 <= 0.001 then
							HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
							HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
							self:_syncHoverPad(Position)

							return
						end

						if not self.hoverPad or not self.hoverPad.Parent then
							self:_startHoverPad()
						end

						local Nyx_tweenClampedStep = math.min(Nyx_tweenStepDist, Magnitude3)
						local Nyx_tweenNextPos = Position + Nyx_positionDelta.Unit * Nyx_tweenClampedStep

						if Nyx_tweenFrameDelta >= 0.033333333333333333 and (not activeTween.routeCruiseY or activeTween.travelPhase ~= "cruise") then
							local Nyx_tweenGroundY = self:_groundYAt(Nyx_tweenNextPos.X, Nyx_tweenNextPos.Z, Character)

							if Nyx_tweenGroundY then
								local Nyx_tweenGroundYFeet = Nyx_tweenGroundY + self:_feetOffset(HumanoidRootPart, Humanoid)

								if Nyx_tweenNextPos.Y < Nyx_tweenGroundYFeet then
									Nyx_tweenNextPos = Vector3.new(Nyx_tweenNextPos.X, Nyx_tweenGroundYFeet, Nyx_tweenNextPos.Z)
								end
							end
						end

						if activeTween.zigzag and (not activeTween.routeCruiseY or activeTween.travelPhase == "cruise") then
							local vector35 = Vector3.new(Nyx_positionDelta.X, 0, Nyx_positionDelta.Z)

							if vector35.Magnitude > 1 and Magnitude2 > 12 then
								local Unit2 = vector35.Unit
								local vector36 = Vector3.new(-Unit2.Z, 0, Unit2.X)
								local Nyx_zigzagAmplitude = math.min(30, Magnitude2 * 0.3)

								if Magnitude2 < 120 then
									Nyx_zigzagAmplitude *= Magnitude2 / 120
								end

								activeTween.zigT = (activeTween.zigT or 0) + Nyx_tweenClampedStep

								local zigLast = Nyx_zigzagAmplitude * math.sin(activeTween.zigT / 900 * 3.1415926535897931 * 2)
								local zigLast2 = activeTween.zigLast or 0

								activeTween.zigLast = zigLast
								Nyx_tweenNextPos += vector36 * (zigLast - zigLast2)

								if not activeTween.zigLaneMin then
									local Nyx_zigzagBoundsMin, Nyx_zigzagBoundsMax = Nyx_getEggCarryBoundsZ()

									activeTween.zigLaneMin = Nyx_zigzagBoundsMin
									activeTween.zigLaneMax = Nyx_zigzagBoundsMax
								end

								local Nyx_zigzagClampedZ = math.clamp(Nyx_tweenNextPos.Z, activeTween.zigLaneMin, activeTween.zigLaneMax)

								if Nyx_zigzagClampedZ ~= Nyx_tweenNextPos.Z then
									Nyx_tweenNextPos = Vector3.new(Nyx_tweenNextPos.X, Nyx_tweenNextPos.Y, Nyx_zigzagClampedZ)
								end
							else
								activeTween.zigLast = 0
							end
						end

						local Nyx_tweenVelocity = (Nyx_tweenNextPos - Position) / Nyx_tweenFrameDelta

						self:_syncHoverPad(Nyx_tweenNextPos)
						HumanoidRootPart.CFrame = lookAt(Nyx_tweenNextPos, Nyx_tweenNextPos + Unit)
						HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						self:_syncHoverPad(Nyx_tweenNextPos)

						if not Nyx_updateSpoofSpeed(Humanoid, HumanoidRootPart, Nyx_tweenSpeedValue, Nyx_tweenVelocity) then
							Nyx_installSpoofFromCharacter(Humanoid, HumanoidRootPart, Nyx_tweenSpeedValue)
							Nyx_updateSpoofSpeed(Humanoid, HumanoidRootPart, Nyx_tweenSpeedValue, Nyx_tweenVelocity)
						end
					end)
				end)
			end
		end

		Nyx_EggRuntime._reStealDroppedEgg = function(self, uid)
			if type(uid) ~= "string" or uid == "" then
				self:_finish("Egg lost — retrying")

				return
			end

			if self:isSkippedEgg(uid) then
				return
			end

			if self.tweenRecoveryUid == uid then
				self.running = false
				self.activeTarget = nil
				self:_releaseOperation()
				self:_scheduleMovementRetry()

				return
			end

			local Nyx_reStealWorker = self:_claimCarryWorker("re-steal", uid)

			if not Nyx_reStealWorker then
				return
			end

			if genv.__NyxGodMode then
				genv.__NyxGodMode:startDefend(uid)
			end

			local Nyx_reStealRecord
			local Nyx_reStealDeadline = os.clock() + 5

			self:_setStatus("Re-stealing dropped egg")

			while self:_isCarryWorkerCurrent(Nyx_reStealWorker) and os.clock() < Nyx_reStealDeadline do
				local Nyx_reStealFieldEgg = EggState2.ReadFieldEgg(uid) or self.records[uid]

				if Nyx_reStealFieldEgg and (Nyx_reStealFieldEgg.State == AreaEggs.States.Dropped or Nyx_reStealFieldEgg.State == AreaEggs.States.Slot) then
					Nyx_reStealRecord = Nyx_reStealFieldEgg

					break
				else
					task.wait(0.03)
				end
			end

			if not self:_isCarryWorkerCurrent(Nyx_reStealWorker) then
				return
			end

			if not Nyx_reStealRecord or not self:_wallOpen() then
				self:_releaseCarryWorker(Nyx_reStealWorker)
				self:_finish("Egg lost — retrying")

				return
			end

			self:_cancelTween("Re-stealing dropped egg", true)

			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			local Nyx_reStealDestination = self:_resolveEggDestination(Nyx_reStealRecord, HumanoidRootPart, Humanoid)
			local Nyx_reStealElevatedDest = Nyx_reStealDestination and self:_resolveElevatedDestination(HumanoidRootPart, Nyx_reStealDestination) or nil

			if not Nyx_reStealElevatedDest then
				self:_releaseCarryWorker(Nyx_reStealWorker)
				self:_finish("Character unavailable")

				return
			end

			self.running = true
			self.activeTarget = Nyx_reStealRecord
			self:_setStatus("Bringing egg home")

			if self:_regrabBurst(Nyx_reStealWorker, Nyx_reStealRecord.Uid, 3.5) or not self:_isCarryWorkerCurrent(Nyx_reStealWorker) then
				return
			end

			self:_setStatus("Re-stealing egg")

			if not self:_teleportRoot(HumanoidRootPart, Humanoid, Nyx_reStealElevatedDest) then
				self:_releaseCarryWorker(Nyx_reStealWorker)
				self:_finish("Re-steal failed — retrying")

				return
			end

			self:_setArrivalHold(Nyx_reStealElevatedDest, Nyx_reStealRecord.Uid)
			self:_setStatus("Re-stealing egg")

			if self:_isCarryWorkerCurrent(Nyx_reStealWorker) then
				self:_requestCarry(Nyx_reStealRecord, true)
			end
		end

		do
			Nyx_EggRuntime._regrabBurst = function(self, worker, uid, duration)
				local function Nyx_isReStealDone()
					local Nyx_reStealEggCarried = EggState2.ReadFieldEgg(uid)

					return Nyx_reStealEggCarried ~= nil and Nyx_reStealEggCarried.State == AreaEggs.States.Carried and Nyx_reStealEggCarried.CarrierUserId == LocalPlayer2.UserId
				end

				local RagdollJoints

				pcall(function()
					RagdollJoints = require(ReplicatedStorage2.Shared.Modules.RagdollJoints)
				end)

				local Nyx_isReStealDone_var1 = false
				local Nyx_isReStealDone_var2 = false
				local Nyx_regrabDeadline = os.clock() + duration

				while true do
					if not (os.clock() < Nyx_regrabDeadline) or self.destroyed or not self.enabled and not self._externalDeliver then
						return Nyx_isReStealDone()
					end

					if Nyx_isReStealDone() then
						break
					end

					if not self:_isCarryWorkerCurrent(worker) then
						return Nyx_isReStealDone()
					end

					local Nyx_regrabRecord = EggState2.ReadFieldEgg(uid)

					if not Nyx_regrabRecord or Nyx_regrabRecord.State ~= AreaEggs.States.Dropped and Nyx_regrabRecord.State ~= AreaEggs.States.Slot then
						return false
					end

					local Character = LocalPlayer2.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

					if not HumanoidRootPart or not Humanoid then
						return false
					end

					pcall(function()
						if RagdollJoints and RagdollJoints.Release then
							RagdollJoints.Release(Character)
						end

						Humanoid.PlatformStand = false
						Humanoid.Sit = false

						if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
							Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
						end
					end)

					local Nyx_regrabDestination = self:_resolveEggDestination(Nyx_regrabRecord, HumanoidRootPart, Humanoid)

					if Nyx_regrabDestination then
						HumanoidRootPart.CFrame = Nyx_regrabDestination
						HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
						self:_syncHoverPad(Nyx_regrabDestination.Position)
					end

					if not Nyx_isReStealDone_var1 then
						Nyx_isReStealDone_var1 = true
						task.spawn(function()
							pcall(function()
								EggWorld.AskFieldEggCarry:InvokeServer({
									Uid = uid
								})
							end)
							Nyx_isReStealDone_var1 = false
						end)
					end

					if not Nyx_isReStealDone_var2 then
						Nyx_isReStealDone_var2 = true
						task.spawn(function()
							pcall(EggState2.CarryFieldEgg, uid)
							Nyx_isReStealDone_var2 = false
						end)
					end

					pcall(function()
						local AreaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
						local Nyx_areaEggSlotClient = AreaEggSlotsClient and AreaEggSlotsClient:FindFirstChild(tostring(uid))
						local CarryAreaEgg = Nyx_areaEggSlotClient and (Nyx_areaEggSlotClient:FindFirstChild("CarryAreaEgg", true) or Nyx_areaEggSlotClient:FindFirstChildWhichIsA("ProximityPrompt", true))

						if CarryAreaEgg and CarryAreaEgg.Enabled and type(fireproximityprompt) == "function" then
							CarryAreaEgg.HoldDuration = 0
							CarryAreaEgg.RequiresLineOfSight = false
							fireproximityprompt(CarryAreaEgg, 0)
						end
					end)
					task.wait(0.06)
				end

				return true
			end
		end

		Nyx_EggRuntime._recoverCarryConfirmationTimeout = function(self, expectedWorker, uid)
			if self.destroyed or not self.enabled or self.carryAttemptToken ~= expectedWorker or self:_hasConfirmedCarry(uid) then
				return false
			end

			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Nyx_carryTimeoutSafeCF = HumanoidRootPart and self:_resolveSafeCFrame(HumanoidRootPart)
			local Nyx_carryTimeoutElevatedCF = Nyx_carryTimeoutSafeCF and self:_resolveElevatedDestination(HumanoidRootPart, Nyx_carryTimeoutSafeCF) or nil

			self.carryTimeouts = self.carryTimeouts or {}

			local Nyx_carryTimeoutAttempts = (self.carryTimeouts[uid] or 0) + 1
			local Nyx_carryTimeoutSkip = Nyx_carryTimeoutAttempts >= 2

			if Nyx_carryTimeoutSkip then
				self.carryTimeouts[uid] = nil
				self.skippedEggs[uid] = os.clock() + 45
				self.tweenRecoveryUid = nil
			else
				self.carryTimeouts[uid] = Nyx_carryTimeoutAttempts
				self.tweenRecoveryUid = not self:_isPrimerEgg(uid) and uid or nil
			end

			local lastCarryReject = self.stats.lastCarryReject
			local Nyx_timeoutRecord = self.records[uid] or EggState2.ReadFieldEgg(uid)
			local Nyx_timeoutIsForest = self.config.stealMode == "Instant" and (uid == self.primerUid or type(Nyx_timeoutRecord) == "table" and Nyx_timeoutRecord.AreaId == "Forest")
			local carry = self.carry

			carry.generation += 1
			self:_invalidateCarryWorker()
			self.carryAttemptToken = nil
			self:_clearArrivalHold(uid)

			if self.activeTween and self.activeTween.Cancel then
				pcall(self.activeTween.Cancel, self.activeTween)
			end

			self.activeTween = nil
			self.running = true
			self.activeTarget = nil
			self.stats.lastResult = "Carry confirmation timeout"

			if HumanoidRootPart and Nyx_carryTimeoutElevatedCF then
				pcall(function()
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end)
				self:_setStatus("Carry timeout - returning to safe area")
				pcall(self._glideRoot, self, Nyx_carryTimeoutElevatedCF, function()
					return self.destroyed or not self.enabled
				end)

				if Nyx_carryTimeoutSkip then
					self:_setStatus(lastCarryReject and "Carry refused (" .. lastCarryReject .. ") — skipping egg" or "Carry timed out twice — skipping egg")
				else
					self:_setStatus("Carry timeout — retrying")
				end
			else
				self:_setStatus("Carry timeout — safe area unavailable")
			end

			self.running = false
			self:_releaseOperation()

			if Nyx_timeoutIsForest then
				self.running = true
			end

			task.delay(0.35, function()
				if Nyx_timeoutIsForest then
					if not self.destroyed and self.enabled then
						self:_setStatus("Retrying steal")
						pcall(self._treadmillReset, self, function()
							return self.destroyed or not self.enabled
						end)
					end

					self.running = false
				end

				if not self.destroyed and self.enabled and self.carryAttemptToken == nil then
					self:_schedule()
				end
			end)

			return true
		end
		Nyx_EggRuntime._requestCarry = function(self, record, skipReapproach)
			if not self:_wallOpen() then
				self:_finish("Wall closed before carry")

				return
			end

			local Uid = record.Uid
			local carryAttemptToken = {}
			local Nyx_isReStealDone_var3

			self.stats.lastCarryReject = nil

			local Nyx_carryConfirmWindow = self.instantPhase == "priming" and Uid == self.primerUid and 5 or math.max(5, self:_resolveSettleSeconds(record) + 3)

			self.carryAttemptToken = carryAttemptToken
			self.stats.lastResult = "Carry requested"
			self:_setStatus("Securing egg")

			local Character = LocalPlayer2.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if Humanoid then
				pcall(Humanoid.UnequipTools, Humanoid)
			end

			if self.coordinator then
				local Nyx_backgroundWaitDeadline = os.clock() + 0.35

				while self.coordinator:isBackgroundBusy() and not self.destroyed and self.enabled and self.carryAttemptToken == carryAttemptToken and os.clock() < Nyx_backgroundWaitDeadline do
					task.wait(0.02)
				end

				if Humanoid and Humanoid.Parent then
					pcall(Humanoid.UnequipTools, Humanoid)
				end
			end

			task.spawn(function()
				while not self.destroyed and self.enabled and self.running and self.carryAttemptToken == carryAttemptToken and self.activeTarget and self.activeTarget.Uid == Uid do
					if not self:_hasConfirmedCarry(Uid) and self:_recordShowsCarried(Uid) then
						self:_adoptCarryFromRecord(Uid)
					end

					if self:_hasConfirmedCarry(Uid) then
						if not self:_recordShowsCarried(Uid) then
							self:_setStatus("Confirming carry record")
							task.wait(0.25)

							continue
						end

						self:_clearArrivalHold(Uid)
						self.carryAttemptToken = nil

						if self.activeTween then
							pcall(self.activeTween.Cancel, self.activeTween)
							self.activeTween = nil
						end

						if self.instantPhase == "priming" and Uid == self.primerUid then
							self.carry.active = true
							self.carry.uid = Uid
							self.stats.lastResult = "Preparing steal"
							self:_enterBaitWait()

							return
						end

						self.carry.active = true
						self.carry.uid = Uid
						self.stats.lastResult = "Carry confirmed"
						self:_setStatus("Carry confirmed")
						task.defer(function()
							if not self.destroyed and self.enabled and self:_hasConfirmedCarry(Uid) then
								self:_returnToSafe()
							end
						end)

						return
					end

					if Nyx_isReStealDone_var3 and Nyx_isReStealDone_var3 <= os.clock() then
						self:_recoverCarryConfirmationTimeout(carryAttemptToken, Uid)

						return
					end

					if not self:_wallOpen() then
						self:_finish("Wall closed before carry")

						return
					end

					local Nyx_carryRequestRecord = EggState2.ReadFieldEgg(Uid) or self.records[Uid]

					if not Nyx_carryRequestRecord then
						self:_finish("Target unavailable")

						return
					end

					if Nyx_carryRequestRecord.State == AreaEggs.States.Carried then
						if Nyx_carryRequestRecord.CarrierUserId == LocalPlayer2.UserId then
							self:_setStatus("Confirming carry state")
							task.wait(0.25)

							continue
						end

						self:_finish("Egg carried by another player")

						return
					end

					if Nyx_carryRequestRecord.State ~= AreaEggs.States.Slot and Nyx_carryRequestRecord.State ~= AreaEggs.States.Dropped then
						self:_finish("Target changed")

						return
					end

					local Character2 = LocalPlayer2.Character
					local HumanoidRootPart = Character2 and Character2:FindFirstChild("HumanoidRootPart")

					if not HumanoidRootPart then
						self:_finish("Character unavailable")

						return
					end

					local Humanoid2 = Character2 and Character2:FindFirstChildOfClass("Humanoid")

					if not Humanoid2 then
						self:_finish("Character unavailable")

						return
					end

					local Nyx_carryRequestDest = self:_resolveEggDestination(Nyx_carryRequestRecord, HumanoidRootPart, Humanoid2)
					local Nyx_carryRequestElevatedDest = Nyx_carryRequestDest and self:_resolveElevatedDestination(HumanoidRootPart, Nyx_carryRequestDest) or nil

					if not Nyx_carryRequestElevatedDest then
						self:_finish("Character unavailable")

						return
					end

					if (HumanoidRootPart.Position - Nyx_carryRequestElevatedDest.Position).Magnitude > 10 then
						if not skipReapproach then
							self:_setStatus("Re-approaching egg")

							local Nyx_isReStealDone_var4 = false

							self:_tweenRoot(Nyx_carryRequestDest, function()
								Nyx_isReStealDone_var4 = true

								if self.carryAttemptToken == carryAttemptToken and not self:_hasConfirmedCarry(Uid) then
									self:_setStatus("Securing egg")
								end
							end, nil, {
								holdAfterArrival = true,
								holdUid = Uid,
								flightProfile = true
							})

							while not self.destroyed and self.enabled and self.carryAttemptToken == carryAttemptToken and not self:_hasConfirmedCarry(Uid) and not Nyx_isReStealDone_var4 do
								task.wait(0.25)
							end

							continue
						end

						self:_setStatus("Re-stealing egg")

						if not self:_teleportRoot(HumanoidRootPart, Humanoid2, Nyx_carryRequestElevatedDest) then
							self:_finish("Re-steal failed — retrying")

							return
						end

						self:_setArrivalHold(Nyx_carryRequestElevatedDest, Uid)
						self:_setStatus("Re-stealing egg")
					end

					local ok, result, lastCarryReject = pcall(Nyx_getMaxSpeedClamp_var1, Nyx_carryRequestRecord.Uid, AreaEggSlotIdentity.LooksLikeFirstAreaUid(Nyx_carryRequestRecord.Uid) and AreaEggSlotIdentity.SlotKey(Nyx_carryRequestRecord.AreaId, Nyx_carryRequestRecord.NestId) or nil)

					if not ok then
						lastCarryReject = tostring(result)
					elseif result == true then
						lastCarryReject = nil
					end

					if lastCarryReject then
						self.stats.lastCarryReject = lastCarryReject

						if lastCarryReject ~= self._lastCarryRejectLogged then
							self._lastCarryRejectLogged = lastCarryReject
							warn("[Nyx Steal] carry refused: " .. lastCarryReject)
						end
					end

					Nyx_isReStealDone_var3 = Nyx_isReStealDone_var3 or os.clock() + Nyx_carryConfirmWindow
					self.stats.lastResult = "Carry requested"
					self:_setStatus(lastCarryReject and "Waiting for carry · " .. lastCarryReject or "Waiting for carry confirmation")
					task.wait(0.25)
				end
			end)
		end
		Nyx_EggRuntime._burstHold = function(self, targetCFrame, cancelCheck)
			if typeof(targetCFrame) ~= "CFrame" then
				return false
			end

			local Position = targetCFrame.Position

			local function Nyx_getCarryRoot()
				local Character = LocalPlayer2.Character

				return Character and Character:FindFirstChild("HumanoidRootPart")
			end
			local function Nyx_holdRootCFrame(rootPart)
				rootPart.CFrame = targetCFrame
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.AssemblyAngularVelocity = Vector3.zero
			end

			local Nyx_burstHoldDeadline = os.clock() + 0.7

			while true do
				if os.clock() < Nyx_burstHoldDeadline then
					if cancelCheck and cancelCheck() then
						break
					end

					local Nyx_burstHoldRoot = Nyx_getCarryRoot()

					if not Nyx_burstHoldRoot or not Nyx_burstHoldRoot.Parent then
						return false
					end

					pcall(Nyx_holdRootCFrame, Nyx_burstHoldRoot)
					RunService2.Heartbeat:Wait()

					continue
				end

				local Nyx_burstHoldSettleDeadline = os.clock() + 3
				local now

				while true do
					if not (os.clock() < Nyx_burstHoldSettleDeadline) then
						local Nyx_burstHoldRoot2 = Nyx_getCarryRoot()
						local Nyx_burstHoldInRange = Nyx_burstHoldRoot2 ~= nil and (Nyx_burstHoldRoot2.Position - Position).Magnitude <= 6

						return Nyx_burstHoldInRange
					end

					if cancelCheck and cancelCheck() then
						break
					end

					local Nyx_burstHoldRoot3 = Nyx_getCarryRoot()

					if not Nyx_burstHoldRoot3 or not Nyx_burstHoldRoot3.Parent then
						return false
					end

					if (Nyx_burstHoldRoot3.Position - Position).Magnitude > 6 then
						now = nil
					elseif not now then
						now = os.clock()
					elseif os.clock() - now >= 0.45 then
						return true
					end

					pcall(Nyx_holdRootCFrame, Nyx_burstHoldRoot3)
					RunService2.Heartbeat:Wait()
				end

				return false
			end

			return false
		end
		Nyx_EggRuntime._isStealPrompt = function(self, prompt)
			if typeof(prompt) ~= "Instance" then
				return false
			end

			if prompt.Name == "EnchantedTreePrompt" then
				return true
			end

			local AreaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

			if AreaEggSlotsClient and prompt:IsDescendantOf(AreaEggSlotsClient) then
				return true
			end

			if prompt:FindFirstAncestor("FuseBiomeLanePortals") or prompt:FindFirstAncestor("FuseBiomeZone") then
				return true
			end

			return false
		end
		Nyx_EggRuntime._installPromptFilter = function(self)
			if self._promptFilter or type(getconnections) ~= "function" then
				return
			end

			local promptFilter = {
				muted = {},
				forwarders = {}
			}

			self._promptFilter = promptFilter

			local function Nyx_shouldMutePrompt()
				return not self.destroyed and (self.enabled or self._externalDeliver or self._recalling or self._treeFxMuted ~= nil)
			end

			for _, v in ipairs({
				ProximityPromptService.PromptShown,
				ProximityPromptService.PromptHidden
			}) do
				local ok, result = pcall(getconnections, v)
				local ipairs_ = ipairs
				local Nyx_promptConnections = ok and type(result) == "table" and result or {}

				for _, Nyx_item in ipairs_(Nyx_promptConnections) do
					local Function = Nyx_item.Function
					local Nyx_debugInfoOk = false
					local result2

					if type(Function) == "function" then
						Nyx_debugInfoOk, result2 = pcall(debug.info, Function, "s")
					end

					if Nyx_debugInfoOk then
						if tostring(result2):find("ProximityPromptScriptController", 1, true) and type(Nyx_item.Disable) == "function" and pcall(Nyx_item.Disable, Nyx_item) then
							table.insert(promptFilter.muted, Nyx_item)
							table.insert(promptFilter.forwarders, v:Connect(function(prompt, ...)
								if Nyx_shouldMutePrompt() then
									if self:_isStealPrompt(prompt) then
										return
									end
								end

								Function(prompt, ...)
							end))
						end
					end
				end
			end
		end
		Nyx_EggRuntime._removePromptFilter = function(self)
			local _promptFilter = self._promptFilter

			if not _promptFilter then
				return
			end

			self._promptFilter = nil

			for _, forwarder in ipairs(_promptFilter.forwarders) do
				pcall(forwarder.Disconnect, forwarder)
			end

			for _, v in ipairs(_promptFilter.muted) do
				pcall(v.Enable, v)
			end
		end
		Nyx_EggRuntime._treadmillReset = function(self, cancelCheck)
			self._treadmillResetting = true

			local ok, result = pcall(self._treadmillResetInner, self, cancelCheck)

			self._treadmillResetting = false

			return ok and result
		end
		Nyx_EggRuntime._treadmillResetInner = function(self, cancelCheck)
			local function Nyx_treadmillResetCancelled()
				return cancelCheck ~= nil and cancelCheck()
			end

			local Treadmill = Remotes and Remotes.Treadmill

			if not Treadmill or Nyx_treadmillResetCancelled() then
				return false
			end

			local function Nyx_treadmillRenderSnapshot()
				local ok, result = pcall(function()
					return Treadmill.AskRenderSnapshot:InvokeServer()
				end)

				if ok and type(result) == "table" then
					return table.find(result, LocalPlayer2.UserId) ~= nil
				end

				return nil
			end
			local function Nyx_getTreadmillStandCF2()
				local ok, result = pcall(function()
					local Nyx_localPlotSlot2 = type(PlotState2.ResolveLocalSlot) == "function" and PlotState2.ResolveLocalSlot() or PlotState2.GetMySlot()
					local Nyx_plotsFolder2 = type(PlotState2.ResolveFolder) == "function" and PlotState2.ResolveFolder() or PlotState2.GetPlotsFolder()
					local Nyx_localPlotFolder2 = Nyx_plotsFolder2 and Nyx_localPlotSlot2 and Nyx_plotsFolder2:FindFirstChild(tostring(Nyx_localPlotSlot2))
					local TreadmillBottom = Nyx_localPlotFolder2 and Nyx_localPlotFolder2:FindFirstChild("TreadmillBottom")

					if not TreadmillBottom or not TreadmillBottom:IsA("BasePart") then
						return nil
					end

					local Character = LocalPlayer2.Character
					local HumanoidRootPart = Character
					local Humanoid, Nyx_feetOffset

					if HumanoidRootPart then
						HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

						if Character then
							Humanoid = Character:FindFirstChildOfClass("Humanoid")

							if HumanoidRootPart and Humanoid then
								if Humanoid.RigType == Enum.HumanoidRigType.R15 then
									Nyx_feetOffset = HumanoidRootPart.Size.Y * 0.5 + math.max(Humanoid.HipHeight, 0.5)

									if not Nyx_feetOffset then
										Nyx_feetOffset = HumanoidRootPart.Size.Y * 0.5 + 2

										return TreadmillBottom.CFrame * cFrameNew(0, TreadmillBottom.Size.Y * 0.5 + Nyx_feetOffset + 0.05, 0)
									end
								else
									Nyx_feetOffset = HumanoidRootPart.Size.Y * 0.5 + 2
								end

								return TreadmillBottom.CFrame * cFrameNew(0, TreadmillBottom.Size.Y * 0.5 + Nyx_feetOffset + 0.05, 0)
							end
						end
					elseif Character then
						Humanoid = Character:FindFirstChildOfClass("Humanoid")

						if HumanoidRootPart and Humanoid then
							if Humanoid.RigType == Enum.HumanoidRigType.R15 then
								Nyx_feetOffset = HumanoidRootPart.Size.Y * 0.5 + math.max(Humanoid.HipHeight, 0.5)

								if not Nyx_feetOffset then
									Nyx_feetOffset = HumanoidRootPart.Size.Y * 0.5 + 2

									return TreadmillBottom.CFrame * cFrameNew(0, TreadmillBottom.Size.Y * 0.5 + Nyx_feetOffset + 0.05, 0)
								end
							else
								Nyx_feetOffset = HumanoidRootPart.Size.Y * 0.5 + 2
							end

							return TreadmillBottom.CFrame * cFrameNew(0, TreadmillBottom.Size.Y * 0.5 + Nyx_feetOffset + 0.05, 0)
						end
					end

					return nil
				end)
				local Nyx_treadmillStandCF3 = ok and result or nil

				return Nyx_treadmillStandCF3
			end

			local Nyx_treadmillStandCF4 = Nyx_getTreadmillStandCF2()

			if not Nyx_treadmillStandCF4 or Nyx_treadmillResetCancelled() then
				return false
			end

			self:_glideRoot(Nyx_treadmillStandCF4, function()
				return Nyx_treadmillResetCancelled()
			end)

			if Nyx_treadmillResetCancelled() then
				return false
			end

			local Nyx_treadmillWearOk = false
			local Nyx_treadmillWearDeadline = os.clock() + 0.7

			if not Nyx_treadmillResetCancelled() and os.clock() < Nyx_treadmillWearDeadline then
				while true do
					pcall(function()
						Treadmill.AskWearStill:InvokeServer()
					end)
					task.wait(0.08)

					if Nyx_treadmillRenderSnapshot() == true then
						Nyx_treadmillWearOk = true

						break
					elseif Nyx_treadmillResetCancelled() or not (os.clock() < Nyx_treadmillWearDeadline) then
						break
					end
				end

				if Nyx_treadmillWearOk then
					local Nyx_treadmillWearSettle = os.clock() + 0.25

					while not Nyx_treadmillResetCancelled() do
						if not (os.clock() < Nyx_treadmillWearSettle) then
							break
						end

						task.wait(0.05)
					end
				end
			end

			local Nyx_treadmillDoffOk = false
			local Nyx_treadmillDoffDeadline = os.clock() + 0.7

			while not Nyx_treadmillResetCancelled() and os.clock() < Nyx_treadmillDoffDeadline do
				pcall(function()
					Treadmill.AskDoff:InvokeServer()
				end)
				task.wait(0.08)

				if Nyx_treadmillRenderSnapshot() == false then
					Nyx_treadmillDoffOk = true

					break
				end
			end

			local Nyx_treadmillResetDone = Nyx_treadmillWearOk and Nyx_treadmillDoffOk

			return Nyx_treadmillResetDone
		end
		Nyx_EggRuntime._instantReturn = function(self, uid)
			if self._instantReturnToken ~= nil then
				return
			end

			local instantReturnToken = {}

			self._instantReturnToken = instantReturnToken
			self._flyDeparting = false

			if self.config.stealMode == "Fly" then
				self:_showTreadmillDecoy()
			end

			task.spawn(function()
				local function Nyx_isStillActive()
					return not self.destroyed and (self.enabled or self._externalDeliver) and self._instantReturnToken == instantReturnToken
				end
				local function Nyx_getCarryState()
					local Character = LocalPlayer2.Character

					return Character and Character:FindFirstChild("HumanoidRootPart"), Character and Character:FindFirstChildOfClass("Humanoid")
				end
				local function Nyx_getFieldEggState()
					return EggState2.ReadFieldEgg(uid)
				end
				local function Nyx_isFieldEggCarried()
					local Nyx_isFieldEggCarried2 = Nyx_getFieldEggState()

					return Nyx_isFieldEggCarried2 ~= nil and Nyx_isFieldEggCarried2.State == AreaEggs.States.Carried and Nyx_isFieldEggCarried2.CarrierUserId == LocalPlayer2.UserId
				end
				local function Nyx_isFieldEggClaimed()
					local Nyx_fieldEggState = Nyx_getFieldEggState()

					if Nyx_fieldEggState then
						return Nyx_fieldEggState.State == AreaEggs.States.Claimed
					end

					return true
				end
				local function Nyx_moveCarryToSafe(targetCFrame, statusText)
					local Nyx_carryRoot, Nyx_carryHumanoid = Nyx_getCarryState()

					if Nyx_carryRoot and Nyx_carryHumanoid and typeof(targetCFrame) == "CFrame" then
						if statusText then
							self:_setStatus(statusText)
						end

						self:_teleportRoot(Nyx_carryRoot, Nyx_carryHumanoid, targetCFrame)
					end
				end
				local function Nyx_getSafeCFrame()
					local Nyx_getSafeCFrame2 = Nyx_getCarryState()

					return Nyx_getSafeCFrame2 and self:_resolveSafeCFrame(Nyx_getSafeCFrame2) or nil
				end
				local function Nyx_setSettleBonus(isComplete)
					self.settleBonus = self.settleBonus or {}

					if isComplete then
						self.settleBonus[uid] = nil
					elseif self.config.stealMode == "Instant" and self.boostedUid ~= uid then
						self.settleBonus[uid] = {
							seconds = 2,
							untilAt = os.clock() + 300
						}
					end
				end
				local function Nyx_finishReturn(reason)
					if self._instantReturnToken ~= instantReturnToken then
						return
					end

					Nyx_setSettleBonus(reason == nil or reason == "Safe return complete")
					self._instantReturnToken = nil
					self._forestDropInProgress = nil

					local _externalDeliver = self._externalDeliver

					self._externalDeliver = nil

					if self.destroyed then
						return
					end

					if self.enabled then
						self:_reportStolen()
						self:_finish(reason or "Safe return complete")
					elseif _externalDeliver then
						self:_reportStolen()
						self.carry.active = false
						self.carry.uid = nil
						self.activeTarget = nil
						self:_hideTreadmillDecoy()
					end
				end

				self:_clearArrivalHold(uid)

				local treeRegrabMode = self.treeBoostedUid == uid and (self.treeRegrabMode or "walk") or "glide"

				local function Nyx_inSafeZone()
					local Nyx_inSafeZone2 = Nyx_getCarryState()

					return Nyx_inSafeZone2 ~= nil and self:_isInSafeArea(Nyx_inSafeZone2)
				end
				local function Nyx_walkToSafe(targetCFrame, cancelCheck, arriveDist)
					return self:_walkTo(targetCFrame, cancelCheck, arriveDist or 4)
				end
				local function Nyx_routeCarryStep(targetCFrame, cancelCheck, arriveDist, phase)
					local Nyx_treeRegrabMode = treeRegrabMode == "walk" or phase == "egg" and (treeRegrabMode == "glideSafe" or treeRegrabMode == "skipSafe") or phase == "safe" and treeRegrabMode == "glideEgg"

					if Nyx_treeRegrabMode and phase == "safe" then
						local Nyx_walkSelf2 = self
						local _walkTo = self._walkTo
						local Nyx_walkTargetPos2 = targetCFrame

						local function Nyx_walkCancelCheck2()
							return cancelCheck() or Nyx_inSafeZone()
						end

						local Nyx_walkArriveDist2 = arriveDist or 4

						return _walkTo(Nyx_walkSelf2, Nyx_walkTargetPos2, Nyx_walkCancelCheck2, Nyx_walkArriveDist2)
					end

					if not Nyx_treeRegrabMode then
						return self:_glideRoot(targetCFrame, cancelCheck)
					end

					local Nyx_walkSelf3 = self
					local _walkTo = self._walkTo
					local Nyx_walkTargetPos3 = targetCFrame
					local Nyx_walkCancelCheck3 = cancelCheck
					local Nyx_walkArriveDist3 = arriveDist or 4

					return _walkTo(Nyx_walkSelf3, Nyx_walkTargetPos3, Nyx_walkCancelCheck3, Nyx_walkArriveDist3)
				end

				local Nyx_isFlyMode = self.config.stealMode == "Fly" or self.boostedUid == uid and not NyxConfig.HelpFriend
				local Nyx_settleShort = Nyx_isFlyMode and 0.15 or 0.4
				local Nyx_settleLong = Nyx_isFlyMode and 0.45 or 0.85
				local Nyx_carryConfirmed = Nyx_isFieldEggCarried()

				if not Nyx_carryConfirmed then
					self:_setStatus("Confirming carry record")

					local Nyx_carryConfirmDeadline2 = os.clock() + 2.5

					while Nyx_isStillActive() and os.clock() < Nyx_carryConfirmDeadline2 do
						Nyx_carryConfirmed = Nyx_isFieldEggCarried()

						if not Nyx_carryConfirmed then
							local Nyx_carryClaimedState = Nyx_getFieldEggState()

							if not Nyx_carryClaimedState or Nyx_carryClaimedState.State ~= AreaEggs.States.Claimed then
								RunService2.Heartbeat:Wait()

								continue
							end
						end

						break
					end

					if not Nyx_isStillActive() then
						return
					end
				end

				if Nyx_carryConfirmed then
					self._forestDropInProgress = uid
					self:_setStatus("Bringing egg home")
					self:_glideRoot(cFrame, function()
						return not Nyx_isStillActive() or not Nyx_isFieldEggCarried()
					end)

					if not Nyx_isStillActive() then
						return
					end

					local Nyx_dropConfirmed = false

					for i = 1, 3 do
						if not Nyx_isStillActive() or not Nyx_isFieldEggCarried() then
							break
						end

						self:_setStatus("Bringing egg home")
						self:_glideRoot(cFrame, function()
							return not Nyx_isStillActive() or not Nyx_isFieldEggCarried()
						end)

						if not Nyx_isStillActive() then
							return
						end

						if Nyx_isFieldEggCarried() then
							task.wait(Nyx_settleShort)

							if not Nyx_isStillActive() then
								return
							end

							if Nyx_isFieldEggCarried() then
								pcall(EggState2.DropFieldEgg, "PlayerRequest")
							end

							local Nyx_dropConfirmDeadline = os.clock() + Nyx_settleLong

							while Nyx_isStillActive() and Nyx_isFieldEggCarried() and os.clock() < Nyx_dropConfirmDeadline do
								RunService2.Heartbeat:Wait()
							end
						end

						local Nyx_dropState = Nyx_getFieldEggState()

						if not Nyx_dropState or Nyx_dropState.State ~= AreaEggs.States.Dropped then
							if not Nyx_isFieldEggCarried() then
								break
							end

							continue
						end

						Nyx_dropConfirmed = true

						break
					end

					if not Nyx_isStillActive() then
						return
					end

					if not Nyx_dropConfirmed then
						if self._instantReturnToken == instantReturnToken then
							self._instantReturnToken = nil
						end

						self._forestDropInProgress = nil
						Nyx_setSettleBonus(false)
						self:_finish("Drop failed — retrying")

						return
					end

					if NyxConfig.HelpFriend then
						self.skippedEggs[uid] = os.clock() + 1800
						self._forestDropInProgress = nil
						self.carry.active = false
						self.carry.uid = nil
						self.stats.lastResult = "Dropped for a friend"
						self:_setStatus("Egg dropped for a friend, heading back")

						local Nyx_safeCFrameForFriend = Nyx_getSafeCFrame()

						if Nyx_safeCFrameForFriend then
							self:_glideRoot(Nyx_safeCFrameForFriend, function()
								return not Nyx_isStillActive()
							end)
						end

						if not Nyx_isStillActive() then
							return
						end

						local _externalDeliver = self._externalDeliver

						self._instantReturnToken = nil
						self._externalDeliver = nil

						if self.enabled then
							self:_finish("Dropped for a friend")
						elseif _externalDeliver then
							self.activeTarget = nil
							self:_hideTreadmillDecoy()
						end

						return
					end

					local Position
					local Nyx_dropStateDeadline = os.clock() + 3

					while Nyx_isStillActive() and os.clock() < Nyx_dropStateDeadline do
						local Nyx_fieldEggState2 = Nyx_getFieldEggState()

						if Nyx_fieldEggState2 and Nyx_fieldEggState2.State == AreaEggs.States.Dropped then
							local BottomCFrame = Nyx_fieldEggState2.BottomCFrame or Nyx_fieldEggState2.BoundsCFrame

							Position = BottomCFrame and BottomCFrame.Position

							if not Position then
								task.wait(0.1)

								continue
							end
						elseif not Nyx_fieldEggState2 or Nyx_fieldEggState2.State == AreaEggs.States.Carried then
							task.wait(0.1)

							continue
						end

						break
					end

					if not Nyx_isStillActive() then
						return
					end

					self._forestDropInProgress = nil
					self:_setStatus("Bringing egg home")

					local Nyx_safeCFrameForRegrab = treeRegrabMode ~= "skipSafe" and Nyx_getSafeCFrame() or nil

					if Nyx_safeCFrameForRegrab then
						Nyx_routeCarryStep(Nyx_safeCFrameForRegrab, function()
							return not Nyx_isStillActive()
						end, nil, "safe")
					end

					if not Nyx_isStillActive() then
						return
					end

					local Nyx_instantRegrabWorker = self:_claimCarryWorker("instant-regrab", uid)
					local cFrame2 = Position and cFrameNew(Position + Vector3.new(0, 3.2, 0)) or cFrame

					local function Nyx_instantRegrabStep()
						Nyx_routeCarryStep(cFrame2, function()
							return not Nyx_isStillActive() or Nyx_isFieldEggCarried()
						end, 3, "egg")
					end

					local Nyx_instantRegrabSuccess = false

					if Nyx_instantRegrabWorker then
						self:_setStatus("Bringing egg home")
						Nyx_instantRegrabStep()

						if not Nyx_isStillActive() then
							return
						end

						Nyx_instantRegrabSuccess = self:_regrabBurst(Nyx_instantRegrabWorker, uid, 0.5)

						if not Nyx_isStillActive() then
							return
						end

						if Nyx_isFieldEggCarried() then
							Nyx_instantRegrabSuccess = true
						end

						if not Nyx_instantRegrabSuccess and not Nyx_isFieldEggCarried() and self:_isCarryWorkerCurrent(Nyx_instantRegrabWorker) then
							self:_setStatus("Bringing egg home")

							local Nyx_safeCFrame3 = Nyx_getSafeCFrame()

							if Nyx_safeCFrame3 then
								self:_glideRoot(Nyx_safeCFrame3, function()
									return not Nyx_isStillActive()
								end)
							end

							if not Nyx_isStillActive() then
								return
							end

							self:_setStatus("Bringing egg home")
							self:_treadmillReset(function()
								return not Nyx_isStillActive()
							end)

							if not Nyx_isStillActive() then
								return
							end

							self:_setStatus("Bringing egg home")

							local Nyx_safeCFrame4 = Nyx_getSafeCFrame()

							if Nyx_safeCFrame4 then
								self:_glideRoot(Nyx_safeCFrame4, function()
									return not Nyx_isStillActive()
								end)
							end

							if not Nyx_isStillActive() then
								return
							end

							if self:_isCarryWorkerCurrent(Nyx_instantRegrabWorker) then
								self:_setStatus("Bringing egg home")
								Nyx_instantRegrabStep()

								if not Nyx_isStillActive() then
									return
								end

								Nyx_instantRegrabSuccess = self:_regrabBurst(Nyx_instantRegrabWorker, uid, 0.6)

								if not Nyx_isStillActive() then
									return
								end
							end
						end
					end

					if not Nyx_instantRegrabSuccess and not Nyx_isFieldEggCarried() then
						Nyx_finishReturn(Nyx_isFieldEggClaimed() and "Safe return complete" or "Re-grab failed — retrying")

						return
					end
				end

				if Nyx_isFieldEggCarried() then
					self:_setStatus("Bringing egg home")

					local Nyx_safeCFrame5 = Nyx_getSafeCFrame()

					if Nyx_safeCFrame5 then
						Nyx_walkToSafe(Nyx_safeCFrame5, function()
							return not Nyx_isStillActive() or not Nyx_isFieldEggCarried()
						end)
					end
				end

				self:_setStatus("Waiting for deposit")

				local Nyx_depositDeadline = os.clock() + 8

				while Nyx_isStillActive() and not Nyx_isFieldEggClaimed() and os.clock() < Nyx_depositDeadline do
					local Nyx_depositRoot, Nyx_depositHumanoid = Nyx_getCarryState()

					if Nyx_depositRoot and Nyx_depositHumanoid and not self:_isInSafeArea(Nyx_depositRoot) then
						local Nyx_depositSafeCF = self:_resolveSafeCFrame(Nyx_depositRoot)

						if Nyx_depositSafeCF then
							Nyx_walkToSafe(Nyx_depositSafeCF, function()
								return not Nyx_isStillActive() or Nyx_isFieldEggClaimed()
							end)
						end
					end

					task.wait(0.1)
				end

				Nyx_finishReturn(Nyx_isFieldEggClaimed() and "Safe return complete" or "Bank not confirmed — retrying")
			end)
		end
		Nyx_EggRuntime.deliverCarriedEgg = function(self, uid, targetRecord)
			if type(uid) ~= "string" or uid == "" or self.destroyed then
				return false
			end

			if self._instantReturnToken ~= nil then
				return false
			end

			self._externalDeliver = true

			if type(targetRecord) == "table" then
				self.activeTarget = targetRecord
			end

			self.carry.active = true
			self.carry.uid = uid
			self.reportedUid = nil
			self:_instantReturn(uid)

			if self._instantReturnToken ~= nil then
				task.spawn(function()
					local Nyx_instantReturnDeadline = os.clock() + 30

					while self._instantReturnToken ~= nil and os.clock() < Nyx_instantReturnDeadline do
						task.wait(0.25)
					end

					if self._externalDeliver then
						self._externalDeliver = nil
						self._instantReturnToken = nil
						self.carry.active = false
						self.carry.uid = nil
					end
				end)

				return true
			end

			self._externalDeliver = nil
			self.carry.active = false
			self.carry.uid = nil

			return false
		end
		Nyx_EggRuntime._adminSteal = function(self, record)
			local Uid = record.Uid

			self._adminBusyUid = Uid

			local function Nyx_isAdminDone()
				local Nyx_adminTargetCarried = EggState2.ReadFieldEgg(Uid)

				return Nyx_adminTargetCarried ~= nil and Nyx_adminTargetCarried.State == AreaEggs.States.Carried and Nyx_adminTargetCarried.CarrierUserId == LocalPlayer2.UserId
			end
			local function Nyx_adminStillValid()
				return not self.destroyed and self.enabled and genv.__NyxAdminBoost == true and self._adminBusyUid == Uid
			end

			local ok, result = pcall(function()
				self.instantPhase = nil
				self.primerUid = nil
				self.targetUid = nil
				self.activeTarget = record
				self.stats.lastResult = "Admin Abuse"
				self:_setStatus("Heading to target egg")

				local Nyx_adminDeadline = os.clock() + 3
				local Nyx_adminStillValid_var1 = 0

				while true do
					if not Nyx_adminStillValid() or Nyx_isAdminDone() then
						if not Nyx_adminStillValid() then
							return
						end

						self.carry.active = true
						self.carry.uid = Uid
						self:_adminDeliver(Uid)

						return
					end

					if Nyx_adminDeadline <= os.clock() then
						break
					end

					local Nyx_adminEggState = EggState2.ReadFieldEgg(Uid)

					if not Nyx_adminEggState or Nyx_adminEggState.State ~= AreaEggs.States.Slot and Nyx_adminEggState.State ~= AreaEggs.States.Dropped then
						return self:_finish("Target egg no longer available")
					end

					local Character = LocalPlayer2.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

					if not HumanoidRootPart or not Humanoid then
						return self:_finish("Character unavailable")
					end

					local Nyx_adminEggDest = self:_resolveEggDestination(Nyx_adminEggState, HumanoidRootPart, Humanoid)

					if Nyx_adminEggDest and (HumanoidRootPart.Position - Nyx_adminEggDest.Position).Magnitude > 4 then
						self:_teleportRoot(HumanoidRootPart, Humanoid, Nyx_adminEggDest)
					end

					if Nyx_adminStillValid_var1 <= os.clock() then
						Nyx_adminStillValid_var1 = os.clock() + 0.1
						self:_setStatus("Securing egg")
						task.spawn(function()
							pcall(function()
								EggWorld.AskFieldEggCarry:InvokeServer({
									Uid = Uid
								})
							end)
						end)
					end

					RunService2.Heartbeat:Wait()
				end

				self.skippedEggs[Uid] = os.clock() + 10

				return self:_finish("Carry refused — next egg")
			end)

			if self._adminBusyUid == Uid then
				self._adminBusyUid = nil
			end

			if not ok then
				warn("[Nyx Steal] admin steal error: " .. tostring(result))

				if not self.destroyed and self.enabled then
					self:_finish("Steal error — retrying")
				end
			end
		end

		do
			Nyx_EggRuntime._adminDeliver = function(self, uid)
				if self._adminDeliverUid == uid then
					return
				end

				self._adminDeliverUid = uid
				self._adminBusyUid = uid

				local function Nyx_getAdminEggState()
					return EggState2.ReadFieldEgg(uid)
				end
				local function Nyx_isAdminEggCarried()
					local Nyx_isAdminEggCarried2 = Nyx_getAdminEggState()

					return Nyx_isAdminEggCarried2 ~= nil and Nyx_isAdminEggCarried2.State == AreaEggs.States.Carried and Nyx_isAdminEggCarried2.CarrierUserId == LocalPlayer2.UserId
				end
				local function Nyx_isAdminEggClaimed()
					local Nyx_isAdminEggClaimed2 = Nyx_getAdminEggState()

					return Nyx_isAdminEggClaimed2 == nil or Nyx_isAdminEggClaimed2.State == AreaEggs.States.Claimed
				end

				self:_clearArrivalHold(uid)
				self:_setStatus("Bringing egg home")

				local Nyx_adminDeliverDeadline = os.clock() + 4

				while not self.destroyed and self.enabled and not Nyx_isAdminEggClaimed() and Nyx_isAdminEggCarried() and os.clock() < Nyx_adminDeliverDeadline do
					local Character = LocalPlayer2.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
					local Nyx_adminSafeCF = HumanoidRootPart and self:_resolveSafeCFrame(HumanoidRootPart)

					if Nyx_adminSafeCF and Humanoid and (HumanoidRootPart.Position - Nyx_adminSafeCF.Position).Magnitude > 4 then
						self:_teleportRoot(HumanoidRootPart, Humanoid, Nyx_adminSafeCF)
						self:_setStatus("Waiting for deposit")
					end

					RunService2.Heartbeat:Wait()
				end

				self._adminDeliverUid = nil

				if self._adminBusyUid == uid then
					self._adminBusyUid = nil
				end

				if self.destroyed or not self.enabled then
					return
				end

				if Nyx_isAdminEggClaimed() then
					self:_reportStolen()
					self:_finish("Safe return complete")
				else
					self:_finish(Nyx_isAdminEggCarried() and "Bank not confirmed — retrying" or "Egg lost — retrying")
				end
			end
		end

		do
			Nyx_EggRuntime._returnToSafe = function(self)
				if self:_isPrimerEgg(self.carry.uid) then
					local uid = self.carry.uid

					self.stats.lastResult = "Steal not banked — retrying"
					self.carry.active = false
					self.carry.uid = nil

					local carry = self.carry

					carry.generation += 1
					self:_invalidateCarryWorker()
					self.skippedEggs[uid] = os.clock() + 30
					pcall(EggState2.DropFieldEgg, "PlayerRequest")

					if self.instantPhase == "priming" then
						self:_startPrimerTargetHunt()
					else
						task.delay(0.5, function()
							if not self.destroyed and self.enabled and not self.running then
								self:_schedule()
							end
						end)
					end

					self:_notify()

					return
				end

				if self.captureObjectiveEnabled and self:_isCaptureEgg(self.carry.uid) then
					self:_captureHold(self.carry.uid)

					return
				end

				if genv.__NyxAdminBoost == true then
					local uid = self.carry.uid or self.activeTarget and self.activeTarget.Uid

					if uid and self._adminBusyUid ~= uid then
						task.spawn(self._adminDeliver, self, uid)
					end

					return
				end

				if self.config.stealMode == "Instant" or self.config.stealMode == "Fly" then
					local uid = self.carry.uid or self.activeTarget and self.activeTarget.Uid

					if not uid then
						self:_finish("Carry lost — retrying")

						return
					end

					self:_instantReturn(uid)

					return
				end

				local uid = self.carry.uid
				local Nyx_carryWorker = self:_claimCarryWorker("return", uid)

				if not Nyx_carryWorker then
					return
				end

				self:_clearArrivalHold(uid)

				if not self:_wallOpen() then
					self:_releaseCarryWorker(Nyx_carryWorker)
					self:_finish("Reset interrupted carry")

					return
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

				if not HumanoidRootPart then
					self:_releaseCarryWorker(Nyx_carryWorker)
					self:_finish("Character unavailable")

					return
				end

				if not self:_hasConfirmedCarry(uid) or self:_recordShowsForeignCarry(uid) then
					self:_releaseCarryWorker(Nyx_carryWorker)
					self:_finish("Carry not confirmed — retrying")

					return
				end

				if self:_isInSafeArea(HumanoidRootPart) then
					self:_finalizeReturn(Nyx_carryWorker)

					return
				end

				if not NyxConfig.HelpFriend then
					local Nyx_safeCFrame6 = self:_resolveSafeCFrame(HumanoidRootPart)

					if not Nyx_safeCFrame6 then
						self:_releaseCarryWorker(Nyx_carryWorker)
						self:_finish("Safe destination unavailable")

						return
					end

					self:_setStatus("Returning to safe area")
					self:_tweenRoot(Nyx_safeCFrame6, function()
						if self:_isCarryWorkerCurrent(Nyx_carryWorker) then
							self:_finalizeReturn(Nyx_carryWorker)
						end
					end, nil, {
						flightProfile = true
					})

					return
				end

				self.handoffLane = (self.handoffLane or 0) % #Nyx_handoffLanes + 1

				local Nyx_friendDropCF = cFrameNew(612, vector32.Y, Nyx_handoffLanes[self.handoffLane]) * HumanoidRootPart.CFrame.Rotation

				self:_setStatus("Taking the egg to the friend drop")
				self:_tweenRoot(Nyx_friendDropCF, function()
					if self:_isCarryWorkerCurrent(Nyx_carryWorker) then
						task.spawn(self._handOffEgg, self, Nyx_carryWorker, uid, Nyx_friendDropCF)
					end
				end, nil, {
					flightProfile = true
				})
			end
		end

		do
			Nyx_EggRuntime._handOffEgg = function(self, worker, uid, targetCFrame)
				local function Nyx_holdAtFriendDrop()
					local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

					if not HumanoidRootPart then
						return false
					end

					HumanoidRootPart.CFrame = targetCFrame
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

					return true
				end
				local function Nyx_isEggCarriedByMe()
					local Nyx_eggCarriedByMeState = EggState2.ReadFieldEgg(uid)

					return Nyx_eggCarriedByMeState ~= nil and Nyx_eggCarriedByMeState.State == AreaEggs.States.Carried and Nyx_eggCarriedByMeState.CarrierUserId == LocalPlayer2.UserId
				end

				self:_setStatus("Dropping the egg for a friend")

				local Nyx_isEggCarriedByMe_var1 = 0.1

				pcall(function()
					Nyx_isEggCarriedByMe_var1 = LocalPlayer2:GetNetworkPing() or 0.1
				end)

				local Nyx_friendDropWaitDeadline = os.clock() + math.max(0.3, 0.2 + 2 * Nyx_isEggCarriedByMe_var1)

				while os.clock() < Nyx_friendDropWaitDeadline and Nyx_holdAtFriendDrop() do
					RunService2.Heartbeat:Wait()
				end

				self.skippedEggs[uid] = os.clock() + 1800
				self:_reportStolen()

				local Nyx_friendDropConfirmed = false

				for i = 1, 4 do
					Nyx_holdAtFriendDrop()

					if not Nyx_isEggCarriedByMe() then
						Nyx_friendDropConfirmed = true

						break
					end

					pcall(EggState2.DropFieldEgg, "PlayerRequest")

					local Nyx_friendDropStepDeadline = os.clock() + 0.6

					while true do
						RunService2.Heartbeat:Wait()
						Nyx_friendDropConfirmed = not Nyx_isEggCarriedByMe()

						if Nyx_friendDropConfirmed then
							break
						elseif Nyx_friendDropStepDeadline <= os.clock() then
							break
						end
					end

					if Nyx_friendDropConfirmed then
						break
					end
				end

				if not Nyx_friendDropConfirmed then
					self.skippedEggs[uid] = nil

					if self:_isCarryWorkerCurrent(worker) then
						self:_releaseCarryWorker(worker)
						self:_finish("Friend drop failed — retrying")
					end

					return
				end

				local Nyx_friendDropEndDeadline = os.clock() + 1

				while self.carry.active and os.clock() < Nyx_friendDropEndDeadline do
					RunService2.Heartbeat:Wait()
				end

				self.carry.active = false
				self.carry.uid = nil
				self.stats.lastResult = "Dropped for a friend"

				local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")
				local Nyx_friendDropSafeCF = HumanoidRootPart and self:_resolveSafeCFrame(HumanoidRootPart)

				if not Nyx_friendDropSafeCF then
					self:_finish("Dropped for a friend")

					return
				end

				self:_setStatus("Egg dropped for a friend, heading back")
				self:_tweenRoot(Nyx_friendDropSafeCF, nil, nil, {
					flightProfile = true,
					onDone = function()
						self:_finish("Dropped for a friend")
					end
				})
			end
		end

		do
			Nyx_EggRuntime._reportStolen = function(self)
				local activeTarget = self.activeTarget

				if not (type(activeTarget) == "table" and activeTarget.Uid) then
					return
				end

				if self.reportedUid == activeTarget.Uid then
					return
				end

				self.reportedUid = activeTarget.Uid
				task.delay(1.5, function()
					if self.destroyed then
						return
					end

					local Nyx_onDone_var4

					pcall(function()
						Nyx_onDone_var4 = EggState2.ReadFieldEgg(activeTarget.Uid)
					end)

					if type(Nyx_onDone_var4) == "table" and (Nyx_onDone_var4.State == AreaEggs.States.Slot or Nyx_onDone_var4.State == AreaEggs.States.Dropped or Nyx_onDone_var4.State == AreaEggs.States.Carried and Nyx_onDone_var4.CarrierUserId ~= LocalPlayer2.UserId) then
						self.reportedUid = nil
						self.stats.deliveryFailed = (self.stats.deliveryFailed or 0) + 1
						self.stats.lastResult = "Delivery failed — retrying"
						self:_notify()

						if self.enabled and not self.running then
							self:_schedule()
						end

						return
					end

					self.stats.delivered = (self.stats.delivered or 0) + 1

					local __NyxWebhook = genv.__NyxWebhook

					if not __NyxWebhook then
						return
					end

					local ok, result = pcall(self.catalog.resolve, activeTarget)

					pcall(__NyxWebhook.stolen, activeTarget, ok and result or nil, nil)
				end)
			end
		end

		do
			Nyx_EggRuntime._startWatchdog = function(self)
				if self.watchdogRunning then
					return
				end

				self.watchdogRunning = true
				task.spawn(function()
					local Nyx_watchdogLastKey
					local now = os.clock()
					local now2
					local Nyx_watchdogLastStatus
					local Position
					local now3

					while Nyx_isCurrentSession() and not self.destroyed do
						if not self.userStealEnabled then
							break
						end

						task.wait(2)

						local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")
						local Nyx_watchdogStatus = tostring(self.stats.status)

						if not self.enabled or not self.running or self.carry.active or self.carryAttemptToken ~= nil or self._instantReturnToken ~= nil or self._captureHoldUid or not HumanoidRootPart or Nyx_watchdogStatus ~= Nyx_watchdogLastStatus or not Position or not ((HumanoidRootPart.Position - Position).Magnitude < 3) then
							Position = HumanoidRootPart and HumanoidRootPart.Position
							Nyx_watchdogLastStatus = Nyx_watchdogStatus
							now3 = os.clock()
						elseif os.clock() - now3 > 12 then
							Nyx_watchdogLastStatus = nil
							Position = nil
							now3 = nil
							Nyx_watchdogLastKey = nil
							self.stats.watchdogResets = (self.stats.watchdogResets or 0) + 1
							pcall(function()
								self:_invalidateCarryWorker()
							end)
							self:_finish("Stuck - retrying")
							self:_releaseOperation()
						end

						if not self.enabled or self._captureHoldUid then
							Nyx_watchdogLastKey = nil
							now2 = nil
						elseif self.running then
							now2 = nil

							local Nyx_watchdogTargetKey = tostring(self.activeTarget and self.activeTarget.Uid) .. "|" .. tostring(self.carry.active)

							if Nyx_watchdogTargetKey ~= Nyx_watchdogLastKey then
								Nyx_watchdogLastKey = Nyx_watchdogTargetKey
								now = os.clock()
							elseif os.clock() - now > 60 then
								Nyx_watchdogLastKey = nil
								self.stats.watchdogResets = (self.stats.watchdogResets or 0) + 1

								local Uid = self.activeTarget and self.activeTarget.Uid

								if Uid and not self.carry.active then
									self.skippedEggs[Uid] = os.clock() + 45

									if self.tweenRecoveryUid == Uid then
										self.tweenRecoveryUid = nil
									end
								end

								pcall(function()
									self:_invalidateCarryWorker()
								end)
								self:_finish("Stuck — retrying")
							end
						else
							Nyx_watchdogLastKey = nil

							local ok, result = pcall(self._chooseTarget, self)

							if self:_wallOpen() and ok and result ~= nil then
								now2 = now2 or os.clock()

								if os.clock() - now2 > 6 then
									now2 = nil
									self.stats.watchdogResets = (self.stats.watchdogResets or 0) + 1
									self:_releaseOperation()
									self:_schedule()
								end
							else
								now2 = nil
							end
						end
					end

					self.watchdogRunning = false
				end)
			end
		end

		Nyx_EggRuntime._finalizeReturn = function(self, worker)
			if not self:_isCarryWorkerCurrent(worker) then
				return
			end

			if not self.carry.active then
				self:_releaseCarryWorker(worker)
				self:_reportStolen()
				self:_finish("Safe return complete")

				return
			end

			self:_setStatus("Validating safe arrival")

			local now = os.clock()
			local Nyx_finalizeDeadline = os.clock() + 6

			while true do
				if not self:_isCarryWorkerCurrent(worker) or not self.carry.active or not (os.clock() < Nyx_finalizeDeadline) then
					if not self:_isCarryWorkerCurrent(worker) then
						return
					end

					if not self.carry.active then
						self:_releaseCarryWorker(worker)
						self:_reportStolen()
						self:_finish("Safe return complete")

						return
					end

					self:_setStatus("Deposit pending — validating again")
					task.defer(function()
						if self:_isCarryWorkerCurrent(worker) and self.carry.active then
							self:_finalizeReturn(worker)
						end
					end)

					return
				end

				local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if not HumanoidRootPart then
					self:_releaseCarryWorker(worker)
					self:_finish("Character unavailable")

					return
				end

				if not self:_isInSafeArea(HumanoidRootPart) then
					break
				end

				if os.clock() - now >= 0.35 then
					self:_setStatus("Waiting for deposit")
				end

				task.wait(0.08)
			end

			self:_setStatus("Rollback detected — returning again")
			self:_releaseCarryWorker(worker)
			task.defer(function()
				if not self.destroyed and self.enabled and self.carry.active then
					self:_returnToSafe()
				end
			end)
		end
		Nyx_EggRuntime._finish = function(self, reason)
			self:_noteLowSpeedOutcome(reason)
			self:_hideTreadmillDecoy()
			self._forestDropInProgress = nil
			self._instantReturnToken = nil
			self.boostedUid = nil
			self:_invalidateCarryWorker()
			self.planGeneration += 1
			self:_cancelTween(reason, self.enabled)
			self:_setStatus(self.enabled and "Searching" or "Idle")

			if self.enabled then
				task.delay(0.05, function()
					if self.destroyed or not self.enabled then
						self:_releaseOperation()

						return
					end

					self:_schedule()
				end)
			end
		end
		Nyx_EggRuntime._scheduleMovementRetry = function(self)
			if self.movementRetryPending or self.destroyed or not self.enabled then
				return
			end

			self.movementRetryPending = true
			task.delay(0.2, function()
				self.movementRetryPending = false

				if not self.destroyed and self.enabled then
					self:_schedule()
				end
			end)
		end
		Nyx_EggRuntime._schedule = function(self)
			if not self.running then
				self.safeStarting = false
			end

			if self.destroyed or not self.enabled or self.running then
				return
			end

			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not HumanoidRootPart or not Humanoid then
				self:_releaseOperation()
				self:_setStatus("Character unavailable")

				return
			end

			self:_startMovementProtection()

			if self.carry.active and self.carry.uid ~= nil then
				if self.instantPhase == "priming" and self.carry.uid == self.primerUid then
					return
				end

				if self:_isPrimerEgg(self.carry.uid) then
					self:_setStatus("Dropping primer egg")
					self.skippedEggs[self.carry.uid] = os.clock() + 30
					pcall(EggState2.DropFieldEgg, "PlayerRequest")
					task.delay(0.5, function()
						if not self.destroyed and self.enabled then
							self:_schedule()
						end
					end)

					return
				end

				local Nyx_reconcileTarget = self.records[self.carry.uid] or EggState2.ReadFieldEgg(self.carry.uid)
				local captureObjectiveEnabled = type(Nyx_reconcileTarget) == "table" and (self.riftWants[Nyx_reconcileTarget.AssetCategory] or self.captureObjectiveEnabled and self:_isCaptureEgg(Nyx_reconcileTarget.Uid) or self.indexObjectiveEnabled and self:_isIndexObjective(Nyx_reconcileTarget) or self.wispObjective and self:_isWispObjective(Nyx_reconcileTarget) or self.userStealEnabled and not self.riftOnly and self:_matchesNormalFilter(Nyx_reconcileTarget))

				if type(Nyx_reconcileTarget) ~= "table" or captureObjectiveEnabled then
					self:_returnToSafe()

					return
				end

				self:_setStatus("Dropping unwanted egg")
				self.skippedEggs[self.carry.uid] = os.clock() + 30
				pcall(EggState2.DropFieldEgg, "PlayerRequest")
				task.delay(0.5, function()
					if not self.destroyed and self.enabled then
						self:_schedule()
					end
				end)

				return
			end

			if not self:_wallOpen() then
				self:_releaseOperation()
				self:_setStatus("Waiting for reset wall")

				return
			end

			local __NyxPlayerSteal = genv.__NyxPlayerSteal
			local autoSteal = Nyx_Blocker.blocker("auto_steal")
			local autoSteal2 = not autoSteal and Nyx_Blocker.holder("auto_steal") or nil

			if autoSteal or autoSteal2 or __NyxPlayerSteal and __NyxPlayerSteal.running then
				self:_releaseOperation()
				self:_setStatus(autoSteal and "Yielding to " .. Nyx_Blocker.TITLES[autoSteal] or autoSteal2 and "Waiting for " .. Nyx_Blocker.TITLES[autoSteal2] .. " to hand over" or "Yielding to Steal Players")

				if self._yieldRetryPending then
					return
				end

				self._yieldRetryPending = true
				task.delay((autoSteal or autoSteal2) and 1 or 0.5, function()
					self._yieldRetryPending = nil

					if not self.destroyed and self.enabled then
						self:_schedule()
					end
				end)

				return
			end

			local tweenRecoveryUid = self.tweenRecoveryUid
			local Nyx_recoveryRecord = tweenRecoveryUid and (EggState2.ReadFieldEgg(tweenRecoveryUid) or self.records[tweenRecoveryUid]) or nil

			if tweenRecoveryUid then
				if type(Nyx_recoveryRecord) ~= "table" or Nyx_recoveryRecord.State ~= AreaEggs.States.Slot and Nyx_recoveryRecord.State ~= AreaEggs.States.Dropped then
					self.tweenRecoveryUid = nil
					tweenRecoveryUid = nil
					Nyx_recoveryRecord = nil
				end
			end

			Nyx_recoveryRecord = Nyx_recoveryRecord or self:_chooseTarget()

			if not Nyx_recoveryRecord then
				if self.stats.matching == 0 and self.stats.available > 0 then
					if (self.config.minWeightKg or 0) > 0 then
						self:_setStatus(string.format("No eggs ≥ %dKg", self.config.minWeightKg))
					else
						self:_setStatus("No matching eggs")
					end
				else
					self:_setStatus("No matching eggs")
				end

				self:_releaseOperation()

				if not self.activeTween and self:_isInField(HumanoidRootPart) and not self:_isInSafeArea(HumanoidRootPart) then
					local Nyx_reconcileSafeCF = self:_resolveSafeCFrame(HumanoidRootPart)

					if Nyx_reconcileSafeCF then
						self:_tweenRoot(Nyx_reconcileSafeCF, nil, nil, {
							silent = true,
							flightProfile = true,
							abort = function()
								return not self.enabled or self.running
							end
						})
					end
				end

				return
			end

			if self.treadmillManager then
				if self.treadmillManager:isEngaged() then
					self.treadmillManager:_cancelIdle(true)
				end
			end

			local planGeneration = self.planGeneration
			local Nyx_opAcquired, Nyx_opAcquireError = self:_acquireOperation()

			if not Nyx_opAcquired then
				self:_setStatus("Waiting · " .. tostring(Nyx_opAcquireError or "another operation"))
				task.delay(0.5, function()
					if not self.destroyed and self.enabled and self.planGeneration == planGeneration then
						self:_schedule()
					end
				end)

				return
			end

			self.safeStarting = true
			self.running = true
			self.activeTarget = Nyx_recoveryRecord

			local Nyx_resolvedTargetCatalog = self.catalog.resolve(Nyx_recoveryRecord)

			self.stats.lastTarget = string.format("%s · %s · %s", Nyx_resolvedTargetCatalog.rarity, Nyx_resolvedTargetCatalog.name, Nyx_recoveryRecord.AreaId)

			if tweenRecoveryUid then
				self.safeStarting = false
				self.stats.lastResult = "Recovering with tween"

				local Nyx_recoveryDest = self:_resolveEggDestination(Nyx_recoveryRecord, HumanoidRootPart, Humanoid)

				if not Nyx_recoveryDest then
					self.tweenRecoveryUid = nil
					self:_finish("Recovery destination unavailable")

					return
				end

				self:_setStatus("Returning to egg")
				self:_tweenRoot(Nyx_recoveryDest, function()
					if self.tweenRecoveryUid == Nyx_recoveryRecord.Uid then
						self:_requestCarry(Nyx_recoveryRecord, false)
					end
				end, nil, {
					holdAfterArrival = true,
					holdUid = Nyx_recoveryRecord.Uid,
					flightProfile = true,
					carryTarget = Nyx_recoveryRecord
				})

				return
			end

			if not self:_leftTreadmill(HumanoidRootPart) then
				self.running = false
				self.safeStarting = false
				self.activeTarget = nil
				self:_releaseOperation()
				self:_setStatus("Preparing steal")
				task.delay(0.3, function()
					if not self.destroyed and self.enabled and self.planGeneration == planGeneration then
						self:_schedule()
					end
				end)

				return
			end

			if genv.__NyxAdminBoost == true and (not self.captureObjectiveEnabled or not self:_isCaptureEgg(Nyx_recoveryRecord.Uid)) then
				self.safeStarting = false
				task.spawn(self._adminSteal, self, Nyx_recoveryRecord)

				return
			end

			local Nyx_deltaFromSafe2 = HumanoidRootPart.Position - vector32
			local Magnitude = Vector2.new(Nyx_deltaFromSafe2.X, Nyx_deltaFromSafe2.Z).Magnitude
			local Nyx_isNearEggFirst = false

			if self.config.stealMode == "Fly" then
				local BottomCFrame = Nyx_recoveryRecord.BottomCFrame or Nyx_recoveryRecord.BoundsCFrame

				if BottomCFrame then
					local Nyx_deltaToEgg = BottomCFrame.Position - HumanoidRootPart.Position

					if Vector2.new(Nyx_deltaToEgg.X, Nyx_deltaToEgg.Z).Magnitude < Magnitude then
						Nyx_isNearEggFirst = true
					end
				end
			end

			if not Nyx_isNearEggFirst and Magnitude > 3 then
				if os.clock() - (self.lastSafeRepositionAt or 0) > 5 then
					local Nyx_repositionSafeCF = self:_resolveSafeCFrame(HumanoidRootPart)

					if Nyx_repositionSafeCF then
						self.safeStarting = true
						self.running = true
						self.lastSafeRepositionAt = os.clock()
						self:_setStatus("Repositioning to safe area")
						self:_tweenRoot(Nyx_repositionSafeCF, function()
							self:_groundSnap()
							self.safeStarting = false
							self.running = false
							task.delay(0.15, function()
								if not self.destroyed and self.enabled and self.planGeneration == planGeneration then
									self:_schedule()
								end
							end)
						end, nil, {
							flightProfile = true
						})

						return
					end
				end
			end

			self.safeStarting = false

			if self.config.stealMode == "Fly" then
				self.instantPhase = "priming"
				self.primerUid = nil
				self.targetUid = Nyx_recoveryRecord.Uid
				self.activeTarget = Nyx_recoveryRecord
				self._flyDeparting = false
				self.lowFpsPrime = false
				self:_installGuardHitDistanceBoost()
				self:_startMovementProtection()
				self.stats.lastResult = "High Speed departing"
				self:_startPrimerTargetHunt()

				return
			end

			local Nyx_primerEggSelected = self:_choosePrimerEgg(Nyx_recoveryRecord.Uid)

			if not Nyx_primerEggSelected then
				self.running = false
				self.activeTarget = nil
				self:_releaseOperation()
				self:_setStatus("Preparing steal")
				task.delay(0.25, function()
					if not self.destroyed and self.enabled and self.planGeneration == planGeneration then
						self:_schedule()
					end
				end)

				return
			end

			self.instantPhase = "priming"
			self.primerUid = Nyx_primerEggSelected.Uid
			self.primerUids[Nyx_primerEggSelected.Uid] = os.clock() + 120
			self.skippedEggs[Nyx_primerEggSelected.Uid] = os.clock() + 30
			self.targetUid = Nyx_recoveryRecord.Uid
			self.activeTarget = Nyx_primerEggSelected
			self._flyDeparting = self.config.stealMode == "Fly"

			if self.config.stealMode == "Instant" then
				self:_showTreadmillDecoy()
			end

			self:_installGuardHitDistanceBoost()
			self.stats.lastResult = self.config.stealMode .. " priming"
			self.lowFpsPrime = Nyx_getFps() < 30

			local Nyx_primerEggDest = self:_resolveEggDestination(Nyx_primerEggSelected, HumanoidRootPart, Humanoid)

			if not Nyx_primerEggDest then
				self:_finish("Steal unavailable — retrying")

				return
			end

			if self.lowFpsPrime then
				self:_setStatus("Preparing steal")
				self:_tweenRoot(Nyx_primerEggDest, function()
					if self.instantPhase == "priming" and self.primerUid == Nyx_primerEggSelected.Uid then
						self:_requestCarry(Nyx_primerEggSelected, false)
					end
				end, nil, {
					holdAfterArrival = true,
					holdUid = Nyx_primerEggSelected.Uid,
					flightProfile = true,
					carryTarget = Nyx_primerEggSelected
				})

				return
			end

			if self.config.stealMode == "Fly" then
				self:_setStatus("Preparing steal")

				if not self:_glideRoot(Nyx_primerEggDest, function()
					return self.destroyed or not self.enabled or self.instantPhase ~= "priming" or self.primerUid ~= Nyx_primerEggSelected.Uid
				end) then
					if self.instantPhase == "priming" and self.primerUid == Nyx_primerEggSelected.Uid then
						self:_finish("Steal unavailable — retrying")
					end

					return
				end

				self:_setArrivalHold(Nyx_primerEggDest, Nyx_primerEggSelected.Uid)
				self:_requestCarry(Nyx_primerEggSelected, true)

				return
			end

			self:_setStatus("Preparing steal")

			if not self:_teleportRoot(HumanoidRootPart, Humanoid, Nyx_primerEggDest) then
				self:_finish("Steal unavailable — retrying")

				return
			end

			self:_setArrivalHold(Nyx_primerEggDest, Nyx_primerEggSelected.Uid)
			self:_requestCarry(Nyx_primerEggSelected, true)
		end
		Nyx_EggRuntime._leftTreadmill = function(self, rootPart)
			local treadmillManager = self.treadmillManager

			if not treadmillManager or treadmillManager.destroyed then
				return true
			end

			if not (treadmillManager.activeTreadmill ~= nil or treadmillManager.treadmillEquipPending == true or treadmillManager.travelingToTreadmill == true or rootPart ~= nil and rootPart.Anchored) then
				self.treadmillLeaveAt = nil

				return true
			end

			local now = os.clock()

			self.treadmillLeaveAt = self.treadmillLeaveAt or now
			treadmillManager.idleGeneration += 1

			if not self.treadmillDoffBusy then
				if now - (self.treadmillDoffAt or 0) > 0.6 then
					self.treadmillDoffBusy = true
					self.treadmillDoffAt = now
					task.spawn(function()
						pcall(treadmillManager._requestUnequip, treadmillManager)
						pcall(treadmillManager._syncActiveTreadmillSnapshot, treadmillManager)
						self.treadmillDoffBusy = false
					end)
				end
			end

			if rootPart and rootPart.Anchored and now - self.treadmillLeaveAt > 1 then
				pcall(function()
					rootPart.Anchored = false
				end)
			end

			if not (now - self.treadmillLeaveAt > 8) then
				return false
			end

			self.treadmillLeaveAt = nil

			return true
		end

		do
			Nyx_EggRuntime._reconcileRunningState = function(self)
				local enabled = self.userStealEnabled == true or next(self.riftWants) ~= nil or self.indexObjectiveEnabled == true or self.wispObjective ~= nil or self.manualObjectiveEnabled == true or self.captureObjectiveEnabled == true

				if self.enabled == enabled then
					if self.enabled then
						self:_refreshCounts()
						self:_schedule()
					end

					return
				end

				self.enabled = enabled

				if self.enabled then
					if LocalPlayer2.Character then
						Nyx_getDebugSource_var1(LocalPlayer2.Character)
						Nyx_installHealthPin(self, LocalPlayer2.Character)
					end

					self:_installGuardHitDistanceBoost()
					self:_startMovementProtection()
					pcall(self._installPromptFilter, self)
					self:_setStatus("Searching")
					self:_schedule()
				else
					if self._instantReturnToken ~= nil and self.carry.uid ~= nil and not self._externalDeliver then
						self._externalDeliver = true
						self.planGeneration += 1
						self.running = false
						self:_setStatus("Finishing target egg")
						task.spawn(function()
							local Nyx_instantFinishDeadline = os.clock() + 45

							while self._instantReturnToken ~= nil and os.clock() < Nyx_instantFinishDeadline and not self.destroyed do
								task.wait(0.2)
							end

							if self.destroyed or self.enabled then
								return
							end

							self._externalDeliver = nil
							self._instantReturnToken = nil
							self.carry.active = false
							self.carry.uid = nil
							self.activeTarget = nil
							self:_cleanupInstantSteal()
							self:_removeGuardHitDistanceBoost()
							self:_restoreTreadmillVisualAtSafe()
							self:_stopMovementProtection()
							Nyx_clearHealthPin(self)
							self:_setStatus("Idle")
						end)
						self:_refreshCounts()

						return
					end

					self.planGeneration += 1

					local carry = self.carry

					carry.generation += 1
					self:_cleanupInstantSteal()
					self:_removeGuardHitDistanceBoost()
					self:_invalidateCarryWorker()
					self._forestDropInProgress = nil
					self._instantReturnToken = nil
					self.carry.active = false
					self.carry.uid = nil
					self.tweenRecoveryUid = nil
					self.claimPresentationSuppression = nil
					self.safeStarting = false
					self.movementRetryPending = false
					self:_cancelTween("Disabled")
					self:_releaseOperation()
					self:_restoreTreadmillVisualAtSafe()
					self:_stopMovementProtection()
					Nyx_clearHealthPin(self)
					self.activeTarget = nil
					self.running = false
					self:_setStatus("Idle")
				end

				self:_refreshCounts()
			end
		end

		Nyx_EggRuntime.setEnabled = function(self, enabled)
			self.userStealEnabled = enabled == true
			self:_reconcileRunningState()

			if self.userStealEnabled then
				self:_startWatchdog()
			end

			self:_reconcileScramblePortal()
		end

		do
			Nyx_EggRuntime._neutralizeScramblePortal = function(self, portal)
				if typeof(portal) ~= "Instance" or portal.Name ~= "ScrambleArenaPortal" then
					return
				end

				self.scramblePortalOriginals = self.scramblePortalOriginals or {}

				for _, descendant in ipairs(portal:GetDescendants()) do
					if descendant:IsA("BasePart") then
						if self.scramblePortalOriginals[descendant] == nil then
							local attribute = descendant:GetAttribute("NyxPortalOrig")

							if type(attribute) == "string" then
								self.scramblePortalOriginals[descendant] = {
									CanCollide = attribute:sub(1, 1) == "1",
									CanTouch = attribute:sub(2, 2) == "1"
								}
							else
								self.scramblePortalOriginals[descendant] = {
									CanCollide = descendant.CanCollide,
									CanTouch = descendant.CanTouch
								}
								pcall(descendant.SetAttribute, descendant, "NyxPortalOrig", (descendant.CanCollide and "1" or "0") .. (descendant.CanTouch and "1" or "0"))
							end
						end

						pcall(function()
							descendant.CanCollide = false
							descendant.CanTouch = false
						end)
					end
				end
			end
		end

		Nyx_EggRuntime._startScramblePortalBypass = function(self)
			local ScrambleArenaPortal = workspace:FindFirstChild("ScrambleArenaPortal")

			if ScrambleArenaPortal then
				self:_neutralizeScramblePortal(ScrambleArenaPortal)
			end

			if not self.scramblePortalConn then
				self.scramblePortalConn = workspace.ChildAdded:Connect(function(child)
					if self.destroyed or not self.userStealEnabled or self._scramblePortalHold or NyxConfig.ScrambleBossAuto == true then
						return
					end

					if child.Name ~= "ScrambleArenaPortal" then
						return
					end

					for _, v in ipairs({
						0,
						0.15,
						0.4,
						0.8
					}) do
						task.delay(v, function()
							if not self.destroyed and self.userStealEnabled and not self._scramblePortalHold then
								if NyxConfig.ScrambleBossAuto ~= true and child.Parent then
									self:_neutralizeScramblePortal(child)
								end
							end
						end)
					end
				end)
			end
		end
		Nyx_EggRuntime._stopScramblePortalBypass = function(self)
			if self.scramblePortalConn then
				pcall(self.scramblePortalConn.Disconnect, self.scramblePortalConn)
				self.scramblePortalConn = nil
			end

			if self.scramblePortalOriginals then
				for k, scramblePortalOriginal in pairs(self.scramblePortalOriginals) do
					if typeof(k) == "Instance" and k.Parent then
						pcall(function()
							k.CanCollide = scramblePortalOriginal.CanCollide
							k.CanTouch = scramblePortalOriginal.CanTouch
							k:SetAttribute("NyxPortalOrig", nil)
						end)
					end
				end

				self.scramblePortalOriginals = nil
			end
		end

		do
			Nyx_EggRuntime._setScramblePortalHold = function(self, holdState)
				local scramblePortalHold = holdState == true

				if self._scramblePortalHold == scramblePortalHold then
					return
				end

				self._scramblePortalHold = scramblePortalHold
				self:_reconcileScramblePortal()
			end
		end

		Nyx_EggRuntime._reconcileScramblePortal = function(self)
			if not self.userStealEnabled or self._scramblePortalHold or NyxConfig.ScrambleBossAuto == true then
				self:_stopScramblePortalBypass()
			else
				self:_startScramblePortalBypass()
			end
		end
		Nyx_EggRuntime._resolveWeightKg = function(self, record)
			local weightUtil = self.weightUtil

			if not weightUtil or not record or not record.AssetScale or not record.AssetCategory then
				return nil
			end

			local ok, result = pcall(weightUtil.WeightKgForScale, record.AssetCategory, record.AssetScale)

			if ok and type(result) == "number" then
				return result
			end

			return nil
		end
		Nyx_EggRuntime.setHeaviestFirst = function(self, enabled)
			self.config.heaviestFirst = enabled == true

			if self.config.heaviestFirst then
				self.config.highestValueFirst = false
			end

			self:_schedule()
		end
		Nyx_EggRuntime.setHighestValueFirst = function(self, enabled)
			self.config.highestValueFirst = enabled == true

			if self.config.highestValueFirst then
				self.config.heaviestFirst = false
			end

			self:_schedule()
		end

		do
			local Nyx_espDetailFields = {
				rarity = true,
				name = true,
				kg = true,
				mutation = true,
				value = true,
				placed = true,
				icon = true
			}

			Nyx_computeRatePerSec = function(record)
				if type(record) ~= "table" then
					return nil
				end

				local Category = record.Category or record.AssetCategory
				local Nyx_computeRatePerSec_var2 = tonumber(record.Scale or record.AssetScale)

				if type(Category) ~= "string" or not Nyx_computeRatePerSec_var2 or Nyx_computeRatePerSec_var2 <= 0 then
					return nil
				end

				local ok, result = pcall(AssetEarnings.MutationOnlyRatePerSecond, {
					Category = Category,
					Scale = Nyx_computeRatePerSec_var2,
					Mutations = type(record.Mutations) == "table" and table.clone(record.Mutations) or {},
					BaseMutation = type(record.BaseMutation) == "string" and record.BaseMutation or nil
				})

				return ok and type(result) == "number" and result or nil
			end

			local Nyx_computeRatePerSec_var1

			local function Nyx_formatCompactNumber(value)
				if type(Nyx_computeRatePerSec_var1) ~= "table" then
					local ok, result = pcall(require, ReplicatedStorage2.Packages.FormatNumber.Simple)

					if ok and type(result.FormatCompact) == "function" then
						Nyx_computeRatePerSec_var1 = result
					end
				end

				if Nyx_computeRatePerSec_var1 then
					local ok, result = pcall(Nyx_computeRatePerSec_var1.FormatCompact, value, ".#")

					if ok and type(result) == "string" then
						return result
					end
				end

				local Nyx_absCompactValue = math.abs(value)

				if Nyx_absCompactValue >= 1e12 then
					return string.format("%.2fT", value / 1e12)
				end

				if Nyx_absCompactValue >= 1e9 then
					return string.format("%.2fB", value / 1e9)
				end

				if Nyx_absCompactValue >= 1000000 then
					return string.format("%.1fM", value / 1000000)
				end

				if Nyx_absCompactValue >= 1000 then
					return string.format("%.1fK", value / 1000)
				end

				return string.format("%d", math.floor(value + 0.5))
			end

			local Nyx_lowSpeedFailures = {
				["Carry not confirmed — retrying"] = true,
				["Carry refused — next egg"] = true,
				["Carry lost — retrying"] = true,
				["Drop failed — retrying"] = true,
				["Egg lost — retrying"] = true,
				["Re-steal failed — retrying"] = true,
				["Steal timed out — retrying"] = true
			}
			local Nyx_guardExitCache = {}

			local function Nyx_getGuardExitXMap()
				if next(Nyx_guardExitCache) then
					return Nyx_guardExitCache
				end

				local Nyx_worldRef6 = Nyx_getWorkspaceWorld()
				local Areas = Nyx_worldRef6 and Nyx_worldRef6:FindFirstChild("Areas")
				local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
				local ipairs_ = ipairs
				local children = GuardAreas and GuardAreas:GetChildren() or {}

				for _, child in ipairs_(children) do
					local ClosestExitPoint = child:FindFirstChild("ClosestExitPoint")

					if ClosestExitPoint and ClosestExitPoint:IsA("BasePart") then
						Nyx_guardExitCache[child.Name] = ClosestExitPoint.Position.X
					end
				end

				return Nyx_guardExitCache
			end

			Nyx_EggRuntime.settleNeed = function(self, areaId, walkSpeed)
				return 2 + math.max(0, (Nyx_getGuardExitXMap()[areaId] or 597) - 597) / (3.2 * math.max(walkSpeed, 16))
			end
			Nyx_EggRuntime.recommendLowSpeedLevel = function(self, projectedSpeed)
				local Nyx_currentProjectedSpeed = projectedSpeed or Nyx_getLegitSpeedFromTreadmill()
				local Nyx_settleAreas = {}

				if self.config.areaEnabled and #self.config.areas > 0 then
					Nyx_settleAreas = self.config.areas
				else
					for k in pairs(Nyx_getGuardExitXMap()) do
						Nyx_settleAreas[#Nyx_settleAreas + 1] = k
					end
				end

				local Nyx_getGuardExitXMap_var1 = 10
				local Nyx_getGuardExitXMap_var2 = 10
				local Nyx_settleWorstArea

				for _, v in ipairs(Nyx_settleAreas) do
					local Nyx_settleRequired = self:settleNeed(v, Nyx_currentProjectedSpeed)
					local Nyx_getGuardExitXMap_var3 = 1
					local Nyx_getGuardExitXMap_var4 = 1

					for i = 10, 1, -1 do
						if Nyx_settleRequired <= Nyx_computeSettleSeconds(v, i) then
							Nyx_getGuardExitXMap_var3 = i

							break
						end
					end

					for i = 10, 1, -1 do
						if Nyx_settleRequired * 1.25 <= Nyx_computeSettleSeconds(v, i) then
							Nyx_getGuardExitXMap_var4 = i

							break
						end
					end

					if Nyx_getGuardExitXMap_var3 < Nyx_getGuardExitXMap_var2 then
						Nyx_getGuardExitXMap_var2 = Nyx_getGuardExitXMap_var3
						Nyx_settleWorstArea = v
					end

					Nyx_getGuardExitXMap_var1 = math.min(Nyx_getGuardExitXMap_var1, Nyx_getGuardExitXMap_var4)
				end

				local lowSpeedFailCap = self.lowSpeedFailCap

				if lowSpeedFailCap then
					Nyx_getGuardExitXMap_var2 = math.min(Nyx_getGuardExitXMap_var2, lowSpeedFailCap)
					Nyx_getGuardExitXMap_var1 = math.min(Nyx_getGuardExitXMap_var1, lowSpeedFailCap)
				end

				return math.min(Nyx_getGuardExitXMap_var1, Nyx_getGuardExitXMap_var2), Nyx_getGuardExitXMap_var2, Nyx_currentProjectedSpeed, Nyx_settleWorstArea
			end
			Nyx_EggRuntime._noteLowSpeedOutcome = function(self, reason)
				local Nyx_untrustedSeen = self._untrustedSeen == true

				self._untrustedSeen = nil

				if self.config.stealMode ~= "Instant" then
					return
				end

				if self.boostedUid ~= nil or self._boostHopUid ~= nil then
					return
				end

				local Nyx_isFailureStatus = Nyx_lowSpeedFailures[tostring(reason)] == true or Nyx_untrustedSeen

				if not Nyx_isFailureStatus and reason ~= "Safe return complete" then
					return
				end

				local Nyx_currentHoldLevel = math.clamp(tonumber(NyxConfig.StealHoldSeconds) or 5, 1, 10)

				self.lowSpeedOutcomes = self.lowSpeedOutcomes or {}

				local Nyx_lowSpeedHistory = self.lowSpeedOutcomes[Nyx_currentHoldLevel] or {}

				self.lowSpeedOutcomes[Nyx_currentHoldLevel] = Nyx_lowSpeedHistory
				Nyx_lowSpeedHistory[#Nyx_lowSpeedHistory + 1] = {
					at = os.clock(),
					failed = Nyx_isFailureStatus
				}

				while #Nyx_lowSpeedHistory > 8 do
					table.remove(Nyx_lowSpeedHistory, 1)
				end

				local Nyx_getGuardExitXMap_var5 = 0
				local Nyx_getGuardExitXMap_var6 = 0

				for _, v in ipairs(Nyx_lowSpeedHistory) do
					if os.clock() - v.at <= 600 then
						Nyx_getGuardExitXMap_var6 += 1

						if v.failed then
							Nyx_getGuardExitXMap_var5 += 1
						end
					end
				end

				if Nyx_currentHoldLevel > 1 then
					if Nyx_getGuardExitXMap_var5 >= 3 and Nyx_getGuardExitXMap_var5 / Nyx_getGuardExitXMap_var6 >= 0.4 then
						local lowSpeedFailCap = Nyx_currentHoldLevel - 1

						if not self.lowSpeedFailCap or lowSpeedFailCap < self.lowSpeedFailCap then
							self.lowSpeedFailCap = lowSpeedFailCap
							self.lowSpeedAdvice = {
								from = Nyx_currentHoldLevel,
								to = lowSpeedFailCap,
								fails = Nyx_getGuardExitXMap_var5,
								total = Nyx_getGuardExitXMap_var6,
								fresh = true
							}
						end
					end
				end
			end
			Nyx_EggRuntime.lowSpeedStatus = function(self)
				local Nyx_getGuardExitXMap_var7

				pcall(function()
					Nyx_getGuardExitXMap_var7 = SpeedPowerProjection.ReadProjected()
				end)

				local Nyx_recommendedSafeLevel, Nyx_recommendedFastLevel, Nyx_currentWalkSpeed = self:recommendLowSpeedLevel()
				local Nyx_holdLevelForAdvice = math.clamp(tonumber(NyxConfig.StealHoldSeconds) or 5, 1, 10)
				local lowSpeedAdvice = self.lowSpeedAdvice

				if lowSpeedAdvice and Nyx_holdLevelForAdvice <= lowSpeedAdvice.to then
					lowSpeedAdvice = nil
				end

				local Nyx_lowSpeedStatus = {
					speedText = type(Nyx_getGuardExitXMap_var7) == "number" and Nyx_formatCompactNumber(Nyx_getGuardExitXMap_var7) or "?",
					walkSpeed = math.floor((Nyx_currentWalkSpeed or 0) + 0.5),
					safe = Nyx_recommendedSafeLevel,
					fast = Nyx_recommendedFastLevel,
					level = Nyx_holdLevelForAdvice,
					advice = lowSpeedAdvice
				}

				return Nyx_lowSpeedStatus
			end
			Nyx_EggRuntime.setEggEsp = function(self, enabled)
				self.config.espEnabled = enabled == true

				if not self.config.espEnabled then
					pcall(function()
						self:_clearEsp()
					end)
				end
			end
			Nyx_EggRuntime.setEspMinRank = function(self, rank)
				self.config.espMinRank = math.max(tonumber(rank) or 0, 0)
			end
			Nyx_EggRuntime.setEspMinValue = function(self, value)
				self.config.espMinValue = math.max(tonumber(value) or 0, 0)
			end
			Nyx_EggRuntime._espPasses = function(self, record, value)
				local config = self.config
				local espMinRank = config.espMinRank

				if (espMinRank or 0) > 0 then
					if (tonumber(record and record.rarityRank) or 0) < config.espMinRank then
						return false
					end
				end

				if (config.espMinValue or 0) > 0 then
					if (tonumber(value) or 0) < config.espMinValue then
						return false
					end
				end

				return true
			end
			Nyx_EggRuntime.setEspOption = function(self, option, enabled)
				if Nyx_espDetailFields[option] then
					self.config["esp" .. option:sub(1, 1):upper() .. option:sub(2)] = enabled == true
				end
			end
			Nyx_EggRuntime._clearEsp = function()
				local AreaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

				if not AreaEggSlotsClient then
					return
				end

				for _, child in ipairs(AreaEggSlotsClient:GetChildren()) do
					local __NyxEggEsp = child:FindFirstChild("__NyxEggEsp")

					if __NyxEggEsp then
						__NyxEggEsp:Destroy()
					end

					local __NyxEggHighlight = child:FindFirstChild("__NyxEggHighlight")

					if __NyxEggHighlight then
						__NyxEggHighlight:Destroy()
					end
				end
			end
			Nyx_EggRuntime._updateEsp = function(self)
				local AreaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

				if not AreaEggSlotsClient then
					return
				end

				local config = self.config

				for _, child in ipairs(AreaEggSlotsClient:GetChildren()) do
					local Nyx_areaEggRecord = self.records[child.Name]
					local Nyx_espRecordValid = config.espEnabled and Nyx_areaEggRecord ~= nil and (Nyx_areaEggRecord.State == AreaEggs.States.Slot or Nyx_areaEggRecord.State == AreaEggs.States.Dropped)

					if Nyx_espRecordValid and not self:_espPasses(self.catalog.resolve(Nyx_areaEggRecord), Nyx_computeRatePerSec(Nyx_areaEggRecord)) then
						Nyx_espRecordValid = false
					end

					local Hitbox = Nyx_espRecordValid and (child:FindFirstChild("Hitbox") or child:FindFirstChildWhichIsA("BasePart", true))
					local __NyxEggEsp = child:FindFirstChild("__NyxEggEsp")
					local __NyxEggHighlight = child:FindFirstChild("__NyxEggHighlight")

					if Nyx_espRecordValid and Hitbox then
						if __NyxEggEsp and not __NyxEggEsp:FindFirstChild("Icon") then
							__NyxEggEsp:Destroy()
							__NyxEggEsp = nil
						end

						if not __NyxEggEsp then
							__NyxEggEsp = Instance.new("BillboardGui")
							__NyxEggEsp.Name = "__NyxEggEsp"
							__NyxEggEsp.AlwaysOnTop = true
							__NyxEggEsp.Size = UDim2.fromOffset(220, 72)
							__NyxEggEsp.StudsOffset = Vector3.new(0, 4.4, 0)
							__NyxEggEsp.MaxDistance = 1000
							__NyxEggEsp.Adornee = Hitbox

							local ImageLabel = Instance.new("ImageLabel")

							ImageLabel.Name = "Icon"
							ImageLabel.AnchorPoint = Vector2.new(0.5, 1)
							ImageLabel.Position = UDim2.fromScale(0.5, 0.42)
							ImageLabel.Size = UDim2.fromOffset(30, 30)
							ImageLabel.BackgroundTransparency = 1
							ImageLabel.ScaleType = Enum.ScaleType.Fit
							ImageLabel.Visible = false
							ImageLabel.Parent = __NyxEggEsp

							local TextLabel = Instance.new("TextLabel")

							TextLabel.Name = "Text"
							TextLabel.AnchorPoint = Vector2.new(0.5, 0)
							TextLabel.Position = UDim2.fromScale(0.5, 0.45)
							TextLabel.Size = UDim2.new(1, 0, 0.55, 0)
							TextLabel.BackgroundTransparency = 1
							TextLabel.Font = Enum.Font.GothamBold
							TextLabel.TextSize = 13
							TextLabel.TextStrokeTransparency = 0.35
							TextLabel.TextXAlignment = Enum.TextXAlignment.Center
							TextLabel.TextYAlignment = Enum.TextYAlignment.Top
							TextLabel.Parent = __NyxEggEsp
							__NyxEggEsp.Parent = child
						end

						__NyxEggEsp.Adornee = Hitbox

						local Nyx_resolvedEggData = self.catalog.resolve(Nyx_areaEggRecord)
						local Icon = __NyxEggEsp:FindFirstChild("Icon")
						local icon = config.espIcon and type(Nyx_resolvedEggData.icon) == "string" and Nyx_resolvedEggData.icon ~= "" and Nyx_resolvedEggData.icon or nil

						Icon.Image = icon or ""
						Icon.Visible = icon ~= nil

						local rarityColor = typeof(Nyx_resolvedEggData.rarityColor) == "Color3" and Nyx_resolvedEggData.rarityColor or Color3.fromRGB(255, 255, 255)
						local Nyx_espParts = {}

						if config.espRarity then
							Nyx_espParts[#Nyx_espParts + 1] = string.upper(Nyx_resolvedEggData.rarity or "?")
						end

						if config.espName then
							Nyx_espParts[#Nyx_espParts + 1] = tostring(Nyx_resolvedEggData.name)
						end

						if config.espKg then
							local Nyx_resolvedWeightKg = self:_resolveWeightKg(Nyx_areaEggRecord)

							if Nyx_resolvedWeightKg then
								Nyx_espParts[#Nyx_espParts + 1] = string.format("%d Kg", math.floor(Nyx_resolvedWeightKg))
							end
						end

						if config.espMutation and type(Nyx_areaEggRecord.Mutations) == "table" and next(Nyx_areaEggRecord.Mutations) then
							local Nyx_espMutationList = {}

							for _, mutation in pairs(Nyx_areaEggRecord.Mutations) do
								Nyx_espMutationList[#Nyx_espMutationList + 1] = tostring(mutation)
							end

							if #Nyx_espMutationList > 0 then
								table.sort(Nyx_espMutationList)
								Nyx_espParts[#Nyx_espParts + 1] = table.concat(Nyx_espMutationList, ", ")
							end
						end

						if config.espValue then
							local Nyx_resolvedRatePerSec = Nyx_computeRatePerSec(Nyx_areaEggRecord)

							if Nyx_resolvedRatePerSec then
								Nyx_espParts[#Nyx_espParts + 1] = "$" .. Nyx_formatCompactNumber(Nyx_resolvedRatePerSec) .. "/s"
							end
						end

						local Text = __NyxEggEsp:FindFirstChild("Text")

						Text.Text = table.concat(Nyx_espParts, " | ")
						Text.TextColor3 = rarityColor

						if __NyxEggHighlight and not __NyxEggHighlight:IsA("Highlight") then
							__NyxEggHighlight:Destroy()
							__NyxEggHighlight = nil
						end

						if not __NyxEggHighlight then
							__NyxEggHighlight = Instance.new("Highlight")
							__NyxEggHighlight.Name = "__NyxEggHighlight"
							__NyxEggHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							__NyxEggHighlight.Parent = child
						end

						__NyxEggHighlight.Adornee = child
						__NyxEggHighlight.FillColor = rarityColor
						__NyxEggHighlight.FillTransparency = 0.72
						__NyxEggHighlight.OutlineColor = rarityColor
						__NyxEggHighlight.OutlineTransparency = 0
					else
						if __NyxEggEsp then
							__NyxEggEsp:Destroy()
						end

						if __NyxEggHighlight then
							__NyxEggHighlight:Destroy()
						end
					end
				end

				self._placedEspAnchors = self._placedEspAnchors or {}
				os.clock()

				if config.espPlaced then
					local Nyx_saveSnapshot = (Save.Peek or Save.Get)()
					local EggInventory = type(Nyx_saveSnapshot) == "table" and Nyx_saveSnapshot.EggInventory

					EggInventory = EggInventory or nil

					local Nyx_localSlot = PlotState2.ResolveLocalSlot()
					local Nyx_plotsFolder3 = PlotState2.ResolveFolder()
					local Nyx_localPlotFolder = Nyx_plotsFolder3 and Nyx_localSlot and Nyx_plotsFolder3:FindFirstChild(tostring(Nyx_localSlot))
					local CenterPoint = Nyx_localPlotFolder and Nyx_localPlotFolder:FindFirstChild("CenterPoint")

					if CenterPoint and not CenterPoint:IsA("BasePart") then
						CenterPoint = nil
					end

					local Nyx_placedEspKeys = {}

					if type(EggInventory) == "table" and CenterPoint then
						local NyxPlacedEggAnchors = workspace:FindFirstChild("NyxPlacedEggAnchors")

						if not NyxPlacedEggAnchors then
							NyxPlacedEggAnchors = Instance.new("Folder")
							NyxPlacedEggAnchors.Name = "NyxPlacedEggAnchors"
							NyxPlacedEggAnchors.Parent = workspace
						end

						for _, child in ipairs(NyxPlacedEggAnchors:GetChildren()) do
							if child:IsA("Highlight") or child:IsA("BillboardGui") then
								child:Destroy()
							end
						end

						for k, v in pairs(EggInventory) do
							if type(k) == "string" and type(v) == "table" and type(v.Placement) == "table" then
								Nyx_placedEspKeys[k] = true

								local LocalCFrame = v.Placement.LocalCFrame

								if typeof(LocalCFrame) ~= "CFrame" then
									local ok, result = pcall(EggRecords.Decode, v)
									local Placement = ok and type(result) == "table" and result.Placement or nil

									LocalCFrame = type(Placement) == "table" and Placement.LocalCFrame or nil
								end

								if typeof(LocalCFrame) == "CFrame" then
									local ok, result = pcall(EggRecords.Decode, v)
									local Nyx_decodedRecord = ok and type(result) == "table" and result or v
									local Nyx_decodedScale = tonumber(Nyx_decodedRecord.AssetScale) or 1
									local cFrame2 = CenterPoint.CFrame * LocalCFrame + Vector3.new(0, 3 + Nyx_decodedScale * 2, 0)

									self._placedEspAnchors[k] = self._placedEspAnchors[k] or {}

									local Nyx_placedAnchor = self._placedEspAnchors[k]

									if typeof(Nyx_placedAnchor.anchor) ~= "Instance" then
										local Part = Instance.new("Part")

										Part.Name = "NyxPE_" .. k
										Part.Size = Vector3.new(1.5, 1.5, 1.5)
										Part.Transparency = 1
										Part.Anchored = true
										Part.CanCollide = false
										Part.CanQuery = false
										Part.CanTouch = false
										Part.Parent = NyxPlacedEggAnchors
										Nyx_placedAnchor.anchor = Part
									end

									Nyx_placedAnchor.anchor.CFrame = cFrame2

									local Nyx_resolvedPlacedEgg = self.catalog.resolve({
										AssetCategory = Nyx_decodedRecord.AssetCategory
									})
									local rarityColor = typeof(Nyx_resolvedPlacedEgg.rarityColor) == "Color3" and Nyx_resolvedPlacedEgg.rarityColor or Color3.fromRGB(255, 255, 255)
									local Nyx_placedEggRate = Nyx_computeRatePerSec({
										Category = Nyx_decodedRecord.AssetCategory,
										Mutations = type(Nyx_decodedRecord.Mutations) == "table" and Nyx_decodedRecord.Mutations or {},
										Scale = Nyx_decodedScale,
										BaseMutation = type(Nyx_decodedRecord.BaseMutation) == "string" and Nyx_decodedRecord.BaseMutation or nil
									})

									if self:_espPasses(Nyx_resolvedPlacedEgg, Nyx_placedEggRate) then
										local Nyx_placedEspText = {}

										if config.espRarity then
											Nyx_placedEspText[#Nyx_placedEspText + 1] = string.upper(Nyx_resolvedPlacedEgg.rarity or "?")
										end

										if config.espName then
											Nyx_placedEspText[#Nyx_placedEspText + 1] = tostring(Nyx_resolvedPlacedEgg.name)
										end

										if config.espKg then
											local ok2, result2 = pcall(EggRecords.WeightKgForScale, Nyx_decodedRecord.AssetCategory, Nyx_decodedScale)

											if ok2 and type(result2) == "number" then
												Nyx_placedEspText[#Nyx_placedEspText + 1] = string.format("%d Kg", math.floor(result2))
											end
										end

										if config.espValue and Nyx_placedEggRate then
											Nyx_placedEspText[#Nyx_placedEspText + 1] = "$" .. Nyx_formatCompactNumber(Nyx_placedEggRate) .. "/s"
										end

										if type(v.Placement.ReadyAt) == "number" or type(Nyx_decodedRecord.Placement) == "table" and Nyx_decodedRecord.Placement.ReadyAt ~= nil then
											Nyx_placedEspText[#Nyx_placedEspText + 1] = "READY"
										end

										local __NyxEggEsp = Nyx_placedAnchor.anchor:FindFirstChild("__NyxEggEsp")

										if not __NyxEggEsp then
											__NyxEggEsp = Instance.new("BillboardGui")
											__NyxEggEsp.Name = "__NyxEggEsp"
											__NyxEggEsp.AlwaysOnTop = true
											__NyxEggEsp.Size = UDim2.fromOffset(220, 72)
											__NyxEggEsp.StudsOffset = Vector3.new(0, 1.4, 0)
											__NyxEggEsp.MaxDistance = 1000

											local ImageLabel = Instance.new("ImageLabel")

											ImageLabel.Name = "Icon"
											ImageLabel.AnchorPoint = Vector2.new(0.5, 1)
											ImageLabel.Position = UDim2.fromScale(0.5, 0.42)
											ImageLabel.Size = UDim2.fromOffset(34, 34)
											ImageLabel.BackgroundTransparency = 1
											ImageLabel.ScaleType = Enum.ScaleType.Fit
											ImageLabel.Visible = false
											ImageLabel.Parent = __NyxEggEsp

											local TextLabel = Instance.new("TextLabel")

											TextLabel.Name = "Text"
											TextLabel.AnchorPoint = Vector2.new(0.5, 0)
											TextLabel.Position = UDim2.fromScale(0.5, 0.45)
											TextLabel.Size = UDim2.new(1, 0, 0.55, 0)
											TextLabel.BackgroundTransparency = 1
											TextLabel.Font = Enum.Font.GothamBold
											TextLabel.TextSize = 13
											TextLabel.TextStrokeTransparency = 0.35
											TextLabel.TextXAlignment = Enum.TextXAlignment.Center
											TextLabel.TextYAlignment = Enum.TextYAlignment.Top
											TextLabel.Parent = __NyxEggEsp
											__NyxEggEsp.Parent = Nyx_placedAnchor.anchor
										end

										local Icon = __NyxEggEsp:FindFirstChild("Icon")

										if Icon then
											local icon = config.espIcon and type(Nyx_resolvedPlacedEgg.icon) == "string" and Nyx_resolvedPlacedEgg.icon ~= "" and Nyx_resolvedPlacedEgg.icon or nil

											Icon.Image = icon or ""
											Icon.Visible = icon ~= nil
										end

										local Text = __NyxEggEsp:FindFirstChild("Text")

										Text.Text = table.concat(Nyx_placedEspText, " | ")
										Text.TextColor3 = rarityColor

										local __NyxEggHighlight = Nyx_placedAnchor.anchor:FindFirstChild("__NyxEggHighlight")

										if __NyxEggHighlight then
											__NyxEggHighlight:Destroy()
										end
									else
										Nyx_placedEspKeys[k] = nil
									end
								end
							end
						end
					end

					for k, placedEspAnchor in pairs(self._placedEspAnchors) do
						if not Nyx_placedEspKeys[k] then
							if typeof(placedEspAnchor.anchor) == "Instance" then
								placedEspAnchor.anchor:Destroy()
							end

							if typeof(placedEspAnchor.highlight) == "Instance" then
								placedEspAnchor.highlight:Destroy()
							end

							self._placedEspAnchors[k] = nil
						end
					end
				else
					local pairs_ = pairs
					local _placedEspAnchors = self._placedEspAnchors or {}

					for k, _placedEspAnchor in pairs_(_placedEspAnchors) do
						if typeof(_placedEspAnchor.anchor) == "Instance" then
							_placedEspAnchor.anchor:Destroy()
						end

						if typeof(_placedEspAnchor.highlight) == "Instance" then
							_placedEspAnchor.highlight:Destroy()
						end

						self._placedEspAnchors[k] = nil
					end
				end
			end
		end

		Nyx_EggRuntime.setMinWeightKg = function(self, value)
			self.config.minWeightKg = math.max(tonumber(value) or 0, 0)
		end
		Nyx_EggRuntime.setMinValuePerSec = function(self, value)
			self.config.minValuePerSec = math.max(tonumber(value) or 0, 0)
			self:_refreshCounts()
			self:_schedule()
		end
		Nyx_EggRuntime.setSpeed = function(self, speed)
			local Nyx_clampedSpeedInput = math.clamp(math.floor((tonumber(speed) or 60) + 0.5), 20, 100)

			self.config.speed = Nyx_clampedSpeedInput * 10

			if genv.__NyxAdminBoost == true then
				self.config.speed = 3000
			end

			if self.enabled or self.activeTween then
				self:_startMovementProtection()
			end

			return Nyx_clampedSpeedInput
		end

		do
			Nyx_EggRuntime.getDefaultSpeed = function()
				return 60
			end
		end

		do
			Nyx_EggRuntime.setFilterEnabled = function(self, filterName, enabled)
				self.config[filterName .. "Enabled"] = enabled == true
				self:_refreshCounts()
				self:_schedule()
			end
		end

		Nyx_EggRuntime.setFilter = function(self, filterKey, valueList)
			local Nyx_copiedFilterList = type(valueList) == "table" and table.clone(valueList) or {}

			if filterKey == "mutations" and type(self.catalog.resolveMutationId) == "function" then
				local Nyx_mutationResolvedIds = {}

				for _, v in ipairs(Nyx_copiedFilterList) do
					local Nyx_resolvedMutationId = self.catalog.resolveMutationId(v)

					if Nyx_resolvedMutationId then
						table.insert(Nyx_mutationResolvedIds, Nyx_resolvedMutationId)
					end
				end

				Nyx_copiedFilterList = Nyx_mutationResolvedIds
			end

			self.config[filterKey] = Nyx_copiedFilterList
			self:_refreshCounts()
			self:_schedule()
		end
		Nyx_EggRuntime.destroy = function(self)
			if self.destroyed then
				return
			end

			self.destroyed = true
			self.enabled = false
			pcall(self._stopScramblePortalBypass, self)
			pcall(self._removePromptFilter, self)

			if self._relocateConn then
				pcall(self._relocateConn.Disconnect, self._relocateConn)
				self._relocateConn = nil
			end

			self._recalling = nil
			self:_hideTreadmillDecoy()
			self.planGeneration += 1

			local carry = self.carry

			carry.generation += 1
			self:_invalidateCarryWorker()
			self.carry.active = false
			self.carry.uid = nil
			self.tweenRecoveryUid = nil
			self.safeStarting = false
			self:_cancelTween("Destroyed")
			self:_cleanupInstantSteal()
			self:_removeGuardHitDistanceBoost()
			self:_releaseOperation()
			self:_stopMovementProtection()

			if self._healthPinner then
				pcall(self._healthPinner.Disconnect, self._healthPinner)
				self._healthPinner = nil
			end

			if self._healthChangedConnection then
				pcall(self._healthChangedConnection.Disconnect, self._healthChangedConnection)
				self._healthChangedConnection = nil
			end

			self:_restoreClaimPresentationFilter()
			Nyx_restoreDeathStates(LocalPlayer2.Character)
			pcall(function()
				self:_clearEsp()
			end)
			pcall(function()
				local pairs_ = pairs
				local _placedEspAnchors = self._placedEspAnchors or {}

				for _, _placedEspAnchor in pairs_(_placedEspAnchors) do
					if typeof(_placedEspAnchor.anchor) == "Instance" then
						_placedEspAnchor.anchor:Destroy()
					end
				end

				local NyxPlacedEggAnchors = workspace:FindFirstChild("NyxPlacedEggAnchors")

				if NyxPlacedEggAnchors then
					NyxPlacedEggAnchors:Destroy()
				end
			end)
			Nyx_disconnectAll(self.connections)
			table.clear(self.listeners)
			table.clear(self.records)
		end

		return Nyx_EggRuntime
	end

	local Nyx_EggRuntimeClass = Nyx_EggRuntimeFactory()
	local Nyx_rateUnitMult = {
		k = 1000,
		m = 1000000,
		b = 1e9,
		t = 1e12,
		q = 1e15
	}

	local function Nyx_parseCompactNumber(valueInput)
		local match, Nyx_parsedNumberUnit = tostring(valueInput or ""):lower():gsub("%s+", ""):gsub("%$", ""):gsub("/s$", ""):match("^([%d%.]+)([kmbtq]?)$")
		local Nyx_parsedNumberValue = tonumber(match)

		if Nyx_parsedNumberValue then
			return math.max(0, math.floor(Nyx_parsedNumberValue * (Nyx_rateUnitMult[Nyx_parsedNumberUnit] or 1) + 0.5))
		end

		return nil
	end
	local function Nyx_AntiGuardFactory()
		local Players2 = game:GetService("Players")
		local RunService2 = game:GetService("RunService")
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local LocalPlayer2 = Players2.LocalPlayer
		local Remotes = require(ReplicatedStorage2.Shared.Remotes)
		local EggState2 = require(ReplicatedStorage2.Client.EggState)
		local Ragdoll = require(ReplicatedStorage2.Shared.Modules.Ragdoll)
		local RagdollJoints = require(ReplicatedStorage2.Shared.Modules.RagdollJoints)
		local EggWorld = Remotes.EggWorld
		local Nyx_AntiGuardBody = {}

		Nyx_AntiGuardBody.__index = Nyx_AntiGuardBody

		local function Nyx_disconnectConnection(self)
			if self then
				pcall(self.Disconnect, self)
			end
		end

		Nyx_AntiGuardBody.new = function(eggRuntime)
			local obj = setmetatable({}, Nyx_AntiGuardBody)

			obj.eggRuntime = eggRuntime
			obj.enabled = true
			obj.destroyed = false
			obj.connections = {}
			obj.originalRagdoll = {}
			obj.originalHumanoidStates = setmetatable({}, {
				__mode = "k"
			})
			obj.stats = {
				blockedHits = 0,
				blockedDrops = 0,
				recarriedEggs = 0
			}
			obj.lastHeldEggUid = nil
			obj.lastHeldSlotKey = nil
			obj._installed = false
			obj._stickyToken = 0
			obj._nextBodyRecoveryAt = 0
			obj._nextJointSweepAt = 0
			obj._forestStrikeOldFire = nil

			return obj
		end
		Nyx_AntiGuardBody._liveBody = function()
			local Character = LocalPlayer2.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			return Character, Humanoid, Character and Character:FindFirstChild("HumanoidRootPart")
		end
		Nyx_AntiGuardBody._recoverBody = function(self, force)
			if not self.enabled or self.destroyed then
				return
			end

			local Nyx_antiGuardChar, Nyx_antiGuardHumanoid, Nyx_antiGuardRoot = self:_liveBody()

			if not Nyx_antiGuardChar or not Nyx_antiGuardHumanoid or not Nyx_antiGuardRoot then
				return
			end

			local now = os.clock()

			if not force and now < self._nextBodyRecoveryAt then
				return
			end

			self._nextBodyRecoveryAt = now + 0.03

			if not self.originalHumanoidStates[Nyx_antiGuardHumanoid] then
				self.originalHumanoidStates[Nyx_antiGuardHumanoid] = {
					Physics = Nyx_antiGuardHumanoid:GetStateEnabled(Enum.HumanoidStateType.Physics),
					FallingDown = Nyx_antiGuardHumanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown),
					Ragdoll = Nyx_antiGuardHumanoid:GetStateEnabled(Enum.HumanoidStateType.Ragdoll)
				}
			end

			local state = Nyx_antiGuardHumanoid:GetState()
			local Nyx_wasInRagdollState = state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown

			Nyx_wasInRagdollState = Nyx_wasInRagdollState or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.PlatformStanding or state == Enum.HumanoidStateType.Seated
			pcall(function()
				Nyx_antiGuardHumanoid.BreakJointsOnDeath = false
				Nyx_antiGuardHumanoid.RequiresNeck = false
				Nyx_antiGuardHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				Nyx_antiGuardHumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
				Nyx_antiGuardHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				Nyx_antiGuardHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
				Nyx_antiGuardHumanoid.PlatformStand = false
				Nyx_antiGuardHumanoid.Sit = false

				local state2 = Nyx_antiGuardHumanoid:GetState()

				if state2 == Enum.HumanoidStateType.Physics or state2 == Enum.HumanoidStateType.FallingDown or state2 == Enum.HumanoidStateType.Ragdoll or state2 == Enum.HumanoidStateType.PlatformStanding or state2 == Enum.HumanoidStateType.Seated then
					Nyx_antiGuardHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
					Nyx_antiGuardHumanoid:ChangeState(Enum.HumanoidStateType.Running)
				end
			end)

			for _, descendant in ipairs(Nyx_antiGuardChar:GetDescendants()) do
				if not descendant:IsA("Motor6D") then
					if descendant:IsA("BallSocketConstraint") or descendant:IsA("HingeConstraint") then
						if descendant.Name:find("Ragdoll", 1, true) or descendant:GetAttribute("RagdollConstraint") then
							pcall(descendant.Destroy, descendant)
						end
					end
				elseif not descendant.Enabled then
					descendant.Enabled = true
				end
			end

			local AssemblyLinearVelocity = Nyx_antiGuardRoot.AssemblyLinearVelocity
			local Magnitude = Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude
			local Nyx_maxAllowedVelocity = math.max(340, (tonumber(Nyx_antiGuardHumanoid.WalkSpeed) or 0) * 1.5)

			if Nyx_wasInRagdollState or Nyx_maxAllowedVelocity < Magnitude or math.abs(AssemblyLinearVelocity.Y) > 240 then
				Nyx_antiGuardRoot.AssemblyLinearVelocity = Vector3.zero
				Nyx_antiGuardRoot.AssemblyAngularVelocity = Vector3.zero
				self.stats.blockedHits += 1
			end
		end
		Nyx_AntiGuardBody._watchCharacter = function(self, character)
			if not character then
				return
			end

			local connection = character.DescendantAdded:Connect(function(descendant)
				if not self.enabled or self.destroyed then
					return
				end

				if not descendant:IsA("BallSocketConstraint") and not descendant:IsA("HingeConstraint") then
					if descendant:IsA("Motor6D") and not descendant.Enabled then
						descendant.Enabled = true
					end
				elseif descendant.Name:find("Ragdoll", 1, true) or descendant:GetAttribute("RagdollConstraint") then
					pcall(descendant.Destroy, descendant)
					self:_recoverBody(true)
				end
			end)

			table.insert(self.connections, connection)
		end
		Nyx_AntiGuardBody._installRagdollHooks = function(self)
			if self._installed then
				return
			end

			self._installed = true
			task.spawn(function()
				task.wait()

				local __NyxForestGate = genv.__NyxForestGate

				if type(__NyxForestGate) == "table" and __NyxForestGate.comp and __NyxForestGate.orig then
					pcall(rawset, __NyxForestGate.comp, "_attackHandler", __NyxForestGate.orig)
					genv.__NyxForestGate = nil
				end

				if type(getgc) ~= "function" then
					return
				end

				local ok, result = pcall(getgc, true)

				if not ok or type(result) ~= "table" then
					return
				end

				for i, v in ipairs(result) do
					if i % 20000 == 0 then
						RunService2.Heartbeat:Wait()
					end

					if self.destroyed then
						return
					end

					if type(v) ~= "table" or rawget(v, "_areaId") ~= "Forest" or type(rawget(v, "_attackHandler")) ~= "function" then
						continue
					end

					local value = rawget(v, "_attackHandler")

					self._forestGate = {
						comp = v,
						orig = value
					}
					genv.__NyxForestGate = self._forestGate
					rawset(v, "_attackHandler", function(...)
						if not self.enabled or self.destroyed or self.eggRuntime and self.eggRuntime.instantPhase == "priming" or genv.__NyxPlayerSteal and genv.__NyxPlayerSteal.running then
							return value(...)
						end

						self.stats.blockedHits += 1
						self:_recoverBody(true)

						if genv.__NyxGodMode then
							genv.__NyxGodMode:startDefend()
						end
					end)

					break
				end
			end)

			for _, v in ipairs({
				"ApplyClientRagdoll",
				"Ragdoll",
				"TimedRagdoll",
				"TimedRagdollAsync"
			}) do
				if type(Ragdoll[v]) == "function" then
					self.originalRagdoll[v] = Ragdoll[v]
					Ragdoll[v] = function(...)
						if self.enabled then
							if not self.destroyed then
								self.stats.blockedHits += 1
								self:_recoverBody(true)

								return
							end
						end

						return self.originalRagdoll[v](...)
					end
				end
			end

			if type(Ragdoll.IsRagdolled) == "function" then
				self.originalRagdoll.IsRagdolled = Ragdoll.IsRagdolled
				Ragdoll.IsRagdolled = function(character)
					if self.enabled then
						if character == LocalPlayer2.Character then
							return false
						end
					end

					return self.originalRagdoll.IsRagdolled(character)
				end
			end
		end
		Nyx_AntiGuardBody._restoreLocalState = function(self)
			for k, originalHumanoidState in pairs(self.originalHumanoidStates) do
				if k.Parent then
					pcall(function()
						k:SetStateEnabled(Enum.HumanoidStateType.Physics, originalHumanoidState.Physics)
						k:SetStateEnabled(Enum.HumanoidStateType.FallingDown, originalHumanoidState.FallingDown)
						k:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, originalHumanoidState.Ragdoll)
					end)
				end
			end

			self.originalHumanoidStates = setmetatable({}, {
				__mode = "k"
			})
			pcall(RagdollJoints.Release, LocalPlayer2.Character)
		end
		Nyx_AntiGuardBody._slotKey = function(self, record)
			if type(record) == "table" and type(record.AreaId) == "string" and type(record.NestId) == "string" then
				return string.format("%s:%s", record.AreaId, record.NestId)
			end

			return nil
		end
		Nyx_AntiGuardBody._requestCarry = function(self, uid, slotKey)
			local Nyx_batCarryRequest = {
				Uid = uid
			}

			if slotKey ~= nil then
				Nyx_batCarryRequest.FirstAreaSlotKey = slotKey
			end

			return EggWorld.AskFieldEggCarry:InvokeServer(Nyx_batCarryRequest)
		end
		Nyx_AntiGuardBody._startSticky = function(self, uid, slotKey)
			if type(uid) ~= "string" or uid == "" then
				return
			end

			self._stickyToken += 1

			local _stickyToken = self._stickyToken

			self.stats.recarriedEggs += 1
			task.spawn(function()
				local Nyx_stickyDeadline = os.clock() + 5

				while not self.destroyed and self.enabled and _stickyToken == self._stickyToken and os.clock() < Nyx_stickyDeadline do
					local Nyx_stickyEggRecord = EggState2.ReadFieldEgg(uid)

					if Nyx_stickyEggRecord and Nyx_stickyEggRecord.State == "Carried" and Nyx_stickyEggRecord.CarrierUserId == LocalPlayer2.UserId then
						self.lastHeldEggUid = uid
						self.lastHeldSlotKey = slotKey or self:_slotKey(Nyx_stickyEggRecord)

						return
					end

					if Nyx_stickyEggRecord and (Nyx_stickyEggRecord.State == "Dropped" or Nyx_stickyEggRecord.State == "Slot") then
						if self.eggRuntime then
							if self.eggRuntime:requestCarryRecovery(uid) then
								return
							end
						end

						local _, _, Nyx_stickyRoot = self:_liveBody()

						if Nyx_stickyRoot and Nyx_stickyEggRecord.BottomCFrame and (Nyx_stickyRoot.Position - Nyx_stickyEggRecord.BottomCFrame.Position).Magnitude <= 10 then
							pcall(self._requestCarry, self, uid, slotKey or self:_slotKey(Nyx_stickyEggRecord))
						end
					end

					task.wait(0.05)
				end
			end)
		end
		Nyx_AntiGuardBody._bindSignals = function(self)
			table.insert(self.connections, EggState2.CarryChanged:Connect(function(carryEvent)
				if not self.enabled then
					return
				end

				if carryEvent.IsCarrying and type(carryEvent.Uid) == "string" then
					self._stickyToken += 1
					self.lastHeldEggUid = carryEvent.Uid

					local Nyx_stickySlotKeySource = EggState2.ReadFieldEgg(carryEvent.Uid)

					self.lastHeldSlotKey = self:_slotKey(Nyx_stickySlotKeySource)

					return
				end

				local __NyxPlayerSteal = genv.__NyxPlayerSteal

				if __NyxPlayerSteal and __NyxPlayerSteal.running then
					return
				end

				local Uid = carryEvent.Uid or self.lastHeldEggUid
				local lastHeldSlotKey = self.lastHeldSlotKey

				if self.eggRuntime then
					if self.eggRuntime:isSkippedEgg(Uid) then
						return
					end
				end

				if Uid then
					self.stats.blockedDrops += 1
					self:_startSticky(Uid, lastHeldSlotKey)

					if genv.__NyxGodMode then
						genv.__NyxGodMode:startDefend(Uid)
					end
				end
			end))
			table.insert(self.connections, LocalPlayer2.CharacterAdded:Connect(function(character)
				self:_watchCharacter(character)
				task.defer(function()
					self:_recoverBody(true)
				end)
			end))

			if LocalPlayer2.Character then
				self:_watchCharacter(LocalPlayer2.Character)
			end

			table.insert(self.connections, RunService2.Stepped:Connect(function()
				self:_recoverBody()
			end))
		end
		Nyx_AntiGuardBody.setEnabled = function(self, enabled)
			local enabled = enabled == true

			if self.enabled == enabled then
				return
			end

			self.enabled = enabled

			if self.enabled then
				self:_recoverBody()
			else
				self._stickyToken += 1
				self:_restoreLocalState()
			end
		end
		Nyx_AntiGuardBody.install = function(self)
			if self.destroyed then
				return false
			end

			getgenv().__NyxAntiGuard = self
			self:_installRagdollHooks()
			self:_bindSignals()
			self:_recoverBody()

			return true
		end

		local Nyx_disconnectConnection_var1 = "destroy"

		local function Nyx_destroyAntiGuardBody(self)
			if self.destroyed then
				return
			end

			self.enabled = false
			self:_restoreLocalState()
			self.destroyed = true
			self._stickyToken += 1

			for _, connection in ipairs(self.connections) do
				Nyx_disconnectConnection(connection)
			end

			table.clear(self.connections)

			for k, v in pairs(self.originalRagdoll) do
				if type(v) == "function" then
					Ragdoll[k] = v
				end
			end

			if self._forestGate then
				pcall(rawset, self._forestGate.comp, "_attackHandler", self._forestGate.orig)

				if genv.__NyxForestGate == self._forestGate then
					genv.__NyxForestGate = nil
				end

				self._forestGate = nil
			end

			self.eggRuntime = nil

			if getgenv().__NyxAntiGuard == self then
				getgenv().__NyxAntiGuard = nil
			end
		end

		Nyx_AntiGuardBody[Nyx_disconnectConnection_var1] = Nyx_destroyAntiGuardBody
		Nyx_AntiGuardBody.getStats = function(self)
			return self.stats
		end

		return Nyx_AntiGuardBody
	end

	local Nyx_AntiGuardClass = Nyx_AntiGuardFactory()

	local function Nyx_GodModeClass()
		local Players2 = game:GetService("Players")

		game:GetService("RunService")

		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local LocalPlayer2 = Players2.LocalPlayer
		local Nyx_AuraBat = {}

		Nyx_AuraBat.__index = Nyx_AuraBat
		Nyx_AuraBat.new = function(eggRuntime)
			local obj = setmetatable({}, Nyx_AuraBat)

			obj.eggRuntime = eggRuntime
			obj.enabled = NyxConfig.GodMode == nil and true or NyxConfig.GodMode == true
			obj.active = false
			obj.activeDroppedUid = nil
			obj.swingSequence = 0
			obj.lastSwingAt = 0
			obj.defendThread = nil
			obj.connections = {}
			obj.targetRange = 35
			obj:_bindSignals()

			return obj
		end
		Nyx_AuraBat._isBat = function(self, tool)
			if not tool or not tool:IsA("Tool") then
				return false
			end

			local __NyxIsBatTool = genv.__NyxIsBatTool

			if __NyxIsBatTool and __NyxIsBatTool(tool) then
				return true
			end

			if not __NyxIsBatTool and (tool:GetAttribute("IsBat") == true or tool:GetAttribute("GearName") == "Bat") then
				return true
			end

			local attribute = tool:GetAttribute("ItemType")

			if attribute == nil or attribute == "Gear" then
				return string.find(string.lower(tool.Name), "slap", 1, true) ~= nil
			end

			return false
		end
		Nyx_AuraBat._findBat = function(self)
			local Character = LocalPlayer2.Character
			local Backpack = LocalPlayer2:FindFirstChildOfClass("Backpack")

			if Character then
				for _, child in ipairs(Character:GetChildren()) do
					if not self:_isBat(child) then
						continue
					end

					return child, true
				end
			end

			if Backpack then
				for _, child in ipairs(Backpack:GetChildren()) do
					if not self:_isBat(child) then
						continue
					end

					return child, false
				end
			end

			pcall(function()
				local Networking = ReplicatedStorage2:FindFirstChild("Packages") and ReplicatedStorage2.Packages:FindFirstChild("Networking")
				local RFCodexAskWearFieldBat = Networking and Networking:FindFirstChild("RF/Codex/AskWearFieldBat")

				if RFCodexAskWearFieldBat then
					RFCodexAskWearFieldBat:InvokeServer()
				end
			end)

			return nil, false
		end
		Nyx_AuraBat._equipBat = function(self)
			local Character = LocalPlayer2.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not Humanoid or Humanoid.Health <= 0 then
				return nil
			end

			local Nyx_batTool, Nyx_batEquipped = self:_findBat()

			if not Nyx_batTool then
				return nil
			end

			if Nyx_batEquipped and Nyx_batTool.Parent == Character then
				return Nyx_batTool
			end

			pcall(Humanoid.EquipTool, Humanoid, Nyx_batTool)

			local Nyx_batEquipDeadline = os.clock() + 0.35

			while true do
				if not (os.clock() < Nyx_batEquipDeadline) then
					return Nyx_batTool.Parent == Character and Nyx_batTool or nil
				end

				if Nyx_batTool.Parent == Character then
					break
				end

				task.wait(0.05)
			end

			return Nyx_batTool
		end
		Nyx_AuraBat._getNearbyEnemies = function(self)
			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart then
				return {}
			end

			local Nyx_nearbyEnemies = {}

			for _, player in ipairs(Players2:GetPlayers()) do
				if player ~= LocalPlayer2 and player.Character then
					local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
					local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")

					if HumanoidRootPart2 and Humanoid and Humanoid.Health > 0 then
						local Magnitude = (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude

						if Magnitude <= self.targetRange then
							table.insert(Nyx_nearbyEnemies, {
								player = player,
								root = HumanoidRootPart2,
								humanoid = Humanoid,
								distance = Magnitude
							})
						end
					end
				end
			end

			table.sort(Nyx_nearbyEnemies, function(enemyA, enemyB)
				return enemyA.distance < enemyB.distance
			end)

			return Nyx_nearbyEnemies
		end
		Nyx_AuraBat._swing = function(self, batTool, targetPart)
			if not batTool or batTool.Parent ~= LocalPlayer2.Character then
				return false
			end

			local serverTimeNow = workspace:GetServerTimeNow()

			if serverTimeNow - self.lastSwingAt < 0.22 then
				return false
			end

			self.lastSwingAt = serverTimeNow
			pcall(batTool.Activate, batTool)

			local Handle = batTool:FindFirstChild("Handle") or batTool:FindFirstChildWhichIsA("BasePart", true)

			if Handle and targetPart and type(firetouchinterest) == "function" then
				pcall(function()
					firetouchinterest(Handle, targetPart, 0)
					task.wait(0.01)
					firetouchinterest(Handle, targetPart, 1)
				end)
			end

			pcall(function()
				local BatSwing = require(ReplicatedStorage2.Shared.Remotes).BatSwing

				if BatSwing and BatSwing.Trigger then
					self.swingSequence += 1

					local Nyx_swingSignature = string.format("%d:%d:%d", LocalPlayer2.UserId, self.swingSequence, math.floor(serverTimeNow * 1000))

					BatSwing.Trigger:FireServer(nil, Nyx_swingSignature)
				end
			end)

			return true
		end
		Nyx_AuraBat.startDefend = function(self, uid)
			if not self.enabled then
				return
			end

			if self.eggRuntime and self.eggRuntime.instantPhase == "priming" then
				return
			end

			if uid and self.eggRuntime then
				if self.eggRuntime:isSkippedEgg(uid) then
					return
				end
			end

			local __NyxPlayerSteal = genv.__NyxPlayerSteal

			if __NyxPlayerSteal and __NyxPlayerSteal.running then
				return
			end

			self.active = true
			self.activeDroppedUid = uid or self.activeDroppedUid

			if not self.defendThread then
				self.defendThread = task.spawn(function()
					local Nyx_defendYielded = false

					while self.active and self.enabled and (not self.eggRuntime or not self.eggRuntime.carry or not self.eggRuntime.carry.active) do
						local __NyxPlayerSteal2 = genv.__NyxPlayerSteal

						if __NyxPlayerSteal2 and __NyxPlayerSteal2.running then
							Nyx_defendYielded = true

							break
						end

						local Nyx_nearbyEnemies = self:_getNearbyEnemies()

						if #Nyx_nearbyEnemies > 0 then
							local Nyx_equippedBat = self:_equipBat()

							if Nyx_equippedBat then
								for _, v in ipairs(Nyx_nearbyEnemies) do
									if v.root and v.root.Parent then
										self:_swing(Nyx_equippedBat, v.root)
									end
								end
							end
						end

						task.wait(0.1)
					end

					self.active = false
					self.defendThread = nil

					if Nyx_defendYielded then
						return
					end

					pcall(function()
						local Character = LocalPlayer2.Character
						local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

						if Humanoid then
							Humanoid:UnequipTools()
						end
					end)
				end)

				return
			end
		end
		Nyx_AuraBat.stopDefend = function(self)
			self.active = false
			self.activeDroppedUid = nil
		end
		Nyx_AuraBat.setEnabled = function(self, enabled)
			self.enabled = enabled == true

			if not self.enabled then
				self:stopDefend()
			end
		end
		Nyx_AuraBat._bindSignals = function(self)
			pcall(function()
				table.insert(self.connections, require(ReplicatedStorage2.Client.EggState).CarryChanged:Connect(function(carryEvent)
					if carryEvent.IsCarrying then
						self:stopDefend()
					elseif self.enabled then
						self:startDefend(carryEvent.Uid)
					end
				end))
			end)
			pcall(function()
				local Remotes = require(ReplicatedStorage2.Shared.Remotes)
				local ForestStrike = Remotes.GuardPatrol and Remotes.GuardPatrol.ForestStrike

				if ForestStrike then
					table.insert(self.connections, ForestStrike.OnClientEvent:Connect(function()
						if self.enabled then
							self:startDefend()
						end
					end))
				end
			end)
		end
		Nyx_AuraBat.destroy = function(self)
			self:stopDefend()

			for _, connection in ipairs(self.connections) do
				pcall(connection.Disconnect, connection)
			end

			table.clear(self.connections)
		end

		return Nyx_AuraBat
	end

	local Nyx_GodModeClass_var1 = Nyx_GodModeClass()

	local function Nyx_GodModeClass_var2()
		local Players2 = game:GetService("Players")
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local LocalPlayer2 = Players2.LocalPlayer
		local Remotes = require(ReplicatedStorage2.Shared.Remotes)
		local PlotState2 = require(ReplicatedStorage2.Client.PlotState)
		local Hud = require(ReplicatedStorage2.Client.Hud)
		local Save = require(ReplicatedStorage2.Shared.Save)
		local Treadmills = require(ReplicatedStorage2.Data.Treadmills)

		local function Nyx_getTreadmillYieldReason()
			local treadmill = Nyx_Blocker.blocker("treadmill")

			if treadmill then
				return "Yielding to " .. Nyx_Blocker.TITLES[treadmill]
			end

			local treadmill2 = Nyx_Blocker.holder("treadmill")

			if treadmill2 then
				return "Waiting for " .. Nyx_Blocker.TITLES[treadmill2]
			end

			return nil
		end
		local function Nyx_hasAnyTreadmillBlocker()
			return Nyx_getTreadmillYieldReason() ~= nil
		end
		local function Nyx_isAutoStealBlocking()
			return Nyx_Blocker.blocker("treadmill") == "auto_steal"
		end
		local function Nyx_getTreadmillYieldText()
			return Nyx_getTreadmillYieldReason() or "Yielding"
		end

		local Nyx_TreadmillManager = {}

		Nyx_TreadmillManager.__index = Nyx_TreadmillManager
		Nyx_TreadmillManager.new = function(coordinator, travelHandler)
			local obj = setmetatable({}, Nyx_TreadmillManager)

			obj.coordinator = coordinator
			obj.travel = travelHandler
			obj.destroyed = false
			obj.listeners = {}
			obj.resources = {}
			obj.config = {
				disableDuringAutomation = true,
				idleFarm = false,
				autoUpgrade = false
			}
			obj.stats = {
				mode = "Idle",
				boost = "Waiting"
			}
			obj.busy = coordinator and coordinator:getSnapshot().busy == true or false
			obj.idleGeneration = 0
			obj.lastEquipAt = 0
			obj.activeTreadmill = nil
			obj.travelingToTreadmill = false
			obj.treadmillEquipPending = false
			obj.unequipGuardRunning = false
			obj.backgroundYieldRunning = false
			obj.lastBackgroundYieldAt = 0
			obj.carryPulseRunning = false
			obj.treadmillStateRevision = 0
			obj:_listenActiveTreadmill()
			task.spawn(function()
				pcall(function()
					obj:_syncActiveTreadmillSnapshot()
				end)
			end)
			obj:_listenCoordinator()
			obj:_listenSpeedGain()

			return obj
		end
		Nyx_TreadmillManager._snapshot = function(self)
			return {
				mode = self.stats.mode,
				boost = self.stats.boost,
				disableDuringAutomation = self.config.disableDuringAutomation,
				idleFarm = self.config.idleFarm
			}
		end
		Nyx_TreadmillManager._emit = function(self)
			local Nyx_treadmillSnapshotData = self:_snapshot()

			for _, listener in ipairs(self.listeners) do
				pcall(listener, Nyx_treadmillSnapshotData)
			end
		end
		Nyx_TreadmillManager._setStatus = function(self, mode, boostStatus)
			if mode ~= nil then
				self.stats.mode = mode
			end

			if boostStatus ~= nil then
				self.stats.boost = boostStatus
			end

			self:_emit()
		end
		Nyx_TreadmillManager.subscribe = function(self, listener)
			table.insert(self.listeners, listener)
			pcall(listener, self:_snapshot())

			local function Nyx_treadmillUnsub()
				local Nyx_listenerIndex = table.find(self.listeners, listener)

				if Nyx_listenerIndex then
					table.remove(self.listeners, Nyx_listenerIndex)
				end
			end

			return Nyx_treadmillUnsub
		end
		Nyx_TreadmillManager._requestUnequip = function()
			local ok, result, result2 = pcall(function()
				return Remotes.Treadmill.AskDoff:InvokeServer()
			end)

			if not ok then
				return false, tostring(result)
			end

			if result ~= false then
				return true
			end

			local Nyx_unequipFalse = false
			local tostring_ = tostring
			local Nyx_unequipError = result2 or "Server rejected"

			return Nyx_unequipFalse, tostring_(Nyx_unequipError)
		end
		Nyx_TreadmillManager._shouldBlockTreadmill = function(self)
			if self.destroyed or self.carryPulseRunning then
				return false
			end

			if self.busy and self.config.disableDuringAutomation then
				return true
			end

			local __NyxEggRuntime = genv.__NyxEggRuntime

			if __NyxEggRuntime and __NyxEggRuntime._treadmillResetting then
				return false
			end

			local ok, result = pcall(Nyx_Blocker.holder, "treadmill")

			return ok and result ~= nil
		end
		Nyx_TreadmillManager._startUnequipGuard = function(self)
			if self.unequipGuardRunning or not self:_shouldBlockTreadmill() or self.activeTreadmill == nil then
				return
			end

			self.unequipGuardRunning = true
			task.spawn(function()
				local Nyx_treadmillUnsub_var1 = 0.15

				while self:_shouldBlockTreadmill() and self.activeTreadmill ~= nil do
					local Nyx_unequipOk, Nyx_unequipMsg = self:_requestUnequip()

					self:_setStatus("Automation active", Nyx_unequipOk and "Blocked" or "Release retry: " .. tostring(Nyx_unequipMsg))
					task.wait(Nyx_treadmillUnsub_var1)
					Nyx_treadmillUnsub_var1 = math.min(Nyx_treadmillUnsub_var1 * 2, 0.75)
				end

				self.unequipGuardRunning = false

				if self:_shouldBlockTreadmill() and self.activeTreadmill ~= nil then
					self:_startUnequipGuard()
				end
			end)
		end
		Nyx_TreadmillManager._cancelIdle = function(self, unequip)
			self.idleGeneration += 1

			if unequip then
				self:_requestUnequip()
			end
		end
		Nyx_TreadmillManager.setDisableDuringAutomation = function(self)
			self.config.disableDuringAutomation = true

			if self.busy and self.config.disableDuringAutomation then
				self:_cancelIdle(true)
				self:_startUnequipGuard()
				self:_setStatus("Automation active", "Blocked")
			elseif not self.busy and self.config.idleFarm then
				self:_startIdle()
			end
		end
		Nyx_TreadmillManager.setIdleFarm = function(self, enabled)
			self.config.idleFarm = enabled == true

			if not self.config.idleFarm then
				self:_cancelIdle(true)
				self:_setStatus(self.busy and "Automation active" or "Idle", "Disabled")

				return
			end

			if not self.busy then
				self:_startIdle()
			end

			if self.idleWatchdog then
				return
			end

			self.idleWatchdog = task.spawn(function()
				while not self.destroyed and self.config.idleFarm do
					task.wait(2)

					if self.idleRunning == nil and not self.busy and self.config.idleFarm and not self.destroyed then
						self:_startIdle()
					end
				end

				self.idleWatchdog = nil
			end)
		end
		Nyx_TreadmillManager._readUpgradeState = function()
			local ok, result, result2, result3 = pcall(function()
				local Nyx_treadmillSaveData = (Save.Peek or Save.Get)()

				if not Nyx_treadmillSaveData then
					return nil
				end

				local Nyx_treadmillUpgradeLevel = tonumber(Nyx_treadmillSaveData.TreadmillUpgradeLevel) or 0

				return Nyx_treadmillUpgradeLevel, Nyx_treadmillSaveData.Money, Treadmills.GetByUpgradeLevel(Nyx_treadmillUpgradeLevel + 1)
			end)

			if not ok or result == nil then
				return nil
			end

			return result, result2, result3
		end
		Nyx_TreadmillManager._raiseTier = function(self)
			local _, Nyx_treadmillMoney, Nyx_treadmillNextTier = self:_readUpgradeState()

			if not Nyx_treadmillNextTier then
				return false, "Max tier"
			end

			if (tonumber(Nyx_treadmillMoney) or 0) < (tonumber(Nyx_treadmillNextTier.Price) or 0) then
				return false, "Not enough money"
			end

			local ok, result, result2 = pcall(function()
				return Remotes.Treadmill.AskTierRaise:InvokeServer(Nyx_treadmillNextTier._id)
			end)

			if not ok then
				return false, tostring(result)
			end

			if result ~= true then
				local Nyx_raiseTierFalse = false
				local tostring_ = tostring
				local Nyx_raiseTierError = result2 or "Server rejected"

				return Nyx_raiseTierFalse, tostring_(Nyx_raiseTierError)
			end

			local Nyx_raiseTierTrue = true
			local DisplayName = Nyx_treadmillNextTier.DisplayName or Nyx_treadmillNextTier._id

			return Nyx_raiseTierTrue, DisplayName
		end
		Nyx_TreadmillManager.setAutoUpgrade = function(self, enabled)
			self.config.autoUpgrade = enabled == true

			if not self.config.autoUpgrade or self.autoUpgradeRunning then
				return
			end

			self.autoUpgradeRunning = true
			task.spawn(function()
				while not self.destroyed and self.config.autoUpgrade do
					while true do
						local Nyx_raiseTierOk, Nyx_raiseTierResult = self:_raiseTier()

						if Nyx_raiseTierOk then
							self:_setStatus(self.busy and "Automation active" or "Idle", "Upgraded to " .. tostring(Nyx_raiseTierResult))
							task.wait(1)
						else
							if Nyx_raiseTierResult ~= "Max tier" then
								break
							end

							self:_setStatus(self.busy and "Automation active" or "Idle", "Treadmill maxed")
							task.wait(30)
						end

						if not self.destroyed and self.config.autoUpgrade then
							continue
						end

						self.autoUpgradeRunning = false

						return
					end

					task.wait(5)
				end

				self.autoUpgradeRunning = false
			end)
		end
		Nyx_TreadmillManager._resolveStandCFrame = function()
			local Nyx_localSlotForStand = PlotState2.ResolveLocalSlot()
			local Nyx_plotsFolderForStand = PlotState2.ResolveFolder()
			local Nyx_localPlotFolderStand = Nyx_plotsFolderForStand and Nyx_localSlotForStand and Nyx_plotsFolderForStand:FindFirstChild(tostring(Nyx_localSlotForStand))
			local TreadmillBottom = Nyx_localPlotFolderStand and Nyx_localPlotFolderStand:FindFirstChild("TreadmillBottom")

			if not TreadmillBottom or not TreadmillBottom:IsA("BasePart") then
				return nil
			end

			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not HumanoidRootPart or not Humanoid then
				return nil
			end

			local Nyx_standFeetOffset

			if Humanoid.RigType == Enum.HumanoidRigType.R15 then
				Nyx_standFeetOffset = HumanoidRootPart.Size.Y * 0.5 + math.max(Humanoid.HipHeight, 0.5)
			else
				Nyx_standFeetOffset = HumanoidRootPart.Size.Y * 0.5 + 2
			end

			return TreadmillBottom.CFrame * cFrameNew(0, TreadmillBottom.Size.Y * 0.5 + Nyx_standFeetOffset + 0.05, 0)
		end
		Nyx_TreadmillManager.isEngaged = function(self)
			return self.activeTreadmill ~= nil or self.travelingToTreadmill or self.treadmillEquipPending or self.carryPulseRunning
		end
		Nyx_TreadmillManager._isTreadmillHudActive = function()
			local ok, result = pcall(function()
				local Game = Hud.Frame("Game")
				local Treadmill = Hud.Frame("Treadmill")

				return Game.Visible == false and Treadmill.Visible == true
			end)
			local Nyx_isTreadmillHudActive = ok and result == true

			return Nyx_isTreadmillHudActive
		end
		Nyx_TreadmillManager._isGameHudRestored = function()
			local ok, result = pcall(function()
				local Game = Hud.Frame("Game")
				local Treadmill = Hud.Frame("Treadmill")

				return Game.Visible == true and Treadmill.Visible == false
			end)
			local Nyx_isGameHudRestored = ok and result == true

			return Nyx_isGameHudRestored
		end
		Nyx_TreadmillManager.pulseForCarry = function(self, positionFn, cancelCheck)
			if self.destroyed or self.carryPulseRunning or type(positionFn) ~= "function" then
				return false, "Preparation unavailable"
			end

			self:_cancelIdle(false)
			self.carryPulseRunning = true

			local function Nyx_isPulseCancelled()
				return self.destroyed or cancelCheck ~= nil and cancelCheck()
			end
			local function Nyx_awaitTreadmillRelease(seconds)
				local Nyx_awaitReleaseDeadline = os.clock() + seconds
				local Nyx_awaitTreadmillRelease_var1 = 0
				local Nyx_stableGameHudSince
				local treadmillStateRevision = self.treadmillStateRevision

				while not self.destroyed and os.clock() < Nyx_awaitReleaseDeadline do
					local now = os.clock()

					if Nyx_awaitTreadmillRelease_var1 <= now then
						self:_requestUnequip()
						Nyx_awaitTreadmillRelease_var1 = now + 0.15
					end

					local Nyx_treadmillSnapshotOk = self:_syncActiveTreadmillSnapshot()
					local Nyx_gameHudRestored = self:_isGameHudRestored()

					if self.treadmillStateRevision ~= treadmillStateRevision then
						treadmillStateRevision = self.treadmillStateRevision
						Nyx_stableGameHudSince = nil
					end

					if not Nyx_treadmillSnapshotOk and self.activeTreadmill == nil and Nyx_gameHudRestored then
						Nyx_stableGameHudSince = Nyx_stableGameHudSince or now

						if now - Nyx_stableGameHudSince >= 0.35 then
							return true
						end
					else
						Nyx_stableGameHudSince = nil
					end

					task.wait(0.03)
				end

				return false
			end
			local function Nyx_finishTreadmillPulse(success, errorText)
				if not success then
					Nyx_awaitTreadmillRelease(1.85)
				end

				self.treadmillEquipPending = false
				self.carryPulseRunning = false

				if success then
					self:_setStatus("Automation active", "Preparation complete")
				elseif not self.destroyed then
					self:_setStatus("Automation active", tostring(errorText or "Preparation failed"))
				end

				if self:_shouldBlockTreadmill() and self.activeTreadmill ~= nil then
					self:_startUnequipGuard()
				end

				return success, errorText
			end

			self:_syncActiveTreadmillSnapshot()

			local Nyx_treadmillActivated = false
			local Nyx_activationError

			for i = 1, 3 do
				if Nyx_isPulseCancelled() then
					return Nyx_finishTreadmillPulse(false, "Cancelled")
				end

				local Nyx_treadmillStandCF = self:_resolveStandCFrame()

				if Nyx_treadmillStandCF then
					self:_setStatus("Preparing carry", i == 1 and "Positioning" or "Repositioning")

					local ok, result = pcall(positionFn, Nyx_treadmillStandCF)

					if ok and result == true then
						task.wait(0.35)
						self.treadmillEquipPending = true
						self:_setStatus("Preparing carry", "Activating")

						local Nyx_activationDeadline = os.clock() + 2.5
						local Nyx_finishTreadmillPulse_var1 = 0
						local Nyx_finishTreadmillPulse_var2 = 0

						while not Nyx_isPulseCancelled() and os.clock() < Nyx_activationDeadline do
							local now = os.clock()

							if Nyx_finishTreadmillPulse_var2 <= now then
								Nyx_finishTreadmillPulse_var2 = now + 0.25
								self:_syncActiveTreadmillSnapshot()
							end

							if self.activeTreadmill ~= nil and self:_isTreadmillHudActive() then
								Nyx_treadmillActivated = true

								break
							end

							if self.activeTreadmill == nil and Nyx_finishTreadmillPulse_var1 <= now then
								Nyx_finishTreadmillPulse_var1 = now + 0.2

								local ok2, result2, result3 = pcall(function()
									return Remotes.Treadmill.AskWearStill:InvokeServer()
								end)

								if not ok2 or result2 == false then
									Nyx_activationError = tostring(result3 or result2)
									self:_setStatus("Preparing carry", "Activation retry")
								end
							end

							task.wait(0.03)
						end
					else
						Nyx_activationError = "Positioning failed"
					end
				else
					Nyx_activationError = "Position unavailable"
				end

				if Nyx_treadmillActivated then
					break
				end

				if not Nyx_isPulseCancelled() then
					self:_setStatus("Preparing carry", "Resetting position")
					Nyx_awaitTreadmillRelease(1.85)

					continue
				end

				return Nyx_finishTreadmillPulse(false, "Cancelled")
			end

			if not Nyx_treadmillActivated then
				local Nyx_activationNotConfirmed = Nyx_finishTreadmillPulse
				local Nyx_activationFalse = false
				local tostring_ = tostring
				local Nyx_activationErrText = Nyx_activationError or "Unknown"

				return Nyx_activationNotConfirmed(Nyx_activationFalse, "Activation not confirmed: " .. tostring_(Nyx_activationErrText))
			end

			self.treadmillEquipPending = false
			self:_setStatus("Preparing carry", "Active")

			local Nyx_releaseCheckDeadline = os.clock() + 0.1

			while not Nyx_isPulseCancelled() and os.clock() < Nyx_releaseCheckDeadline do
				task.wait(0.03)
			end

			if Nyx_isPulseCancelled() then
				return Nyx_finishTreadmillPulse(false, "Cancelled")
			end

			self:_setStatus("Preparing carry", "Releasing")

			if Nyx_awaitTreadmillRelease(1.85) then
				return Nyx_finishTreadmillPulse(true)
			end

			local Nyx_releaseNotConfirmed = Nyx_finishTreadmillPulse
			local Nyx_releaseFalse = false
			local Nyx_releaseErrText = Nyx_isPulseCancelled() and "Cancelled" or "Release not confirmed"

			return Nyx_releaseNotConfirmed(Nyx_releaseFalse, Nyx_releaseErrText)
		end
		Nyx_TreadmillManager.yieldForBackground = function(self)
			if self.destroyed then
				return
			end

			self:_cancelIdle(false)

			if self.backgroundYieldRunning then
				return
			end

			self.backgroundYieldRunning = true
			task.spawn(function()
				local Nyx_finishTreadmillPulse_var3 = 0.15

				while not self.destroyed do
					if self.coordinator and self.coordinator:isBackgroundBusy() then
						self.lastBackgroundYieldAt = os.clock()
						self:_setStatus("Idle", "Yielding to background inventory")
						self:_requestUnequip()
						task.wait(Nyx_finishTreadmillPulse_var3)

						if self:_syncActiveTreadmillSnapshot() then
							Nyx_finishTreadmillPulse_var3 = math.min(Nyx_finishTreadmillPulse_var3 * 2, 0.75)

							continue
						end
					end

					break
				end

				self.backgroundYieldRunning = false

				if not self.destroyed and not self:isEngaged() then
					self:_setStatus("Idle", "Background inventory ready")
				end
			end)
		end
		Nyx_TreadmillManager._startIdle = function(self)
			if self.destroyed or self.busy or not self.config.idleFarm then
				return
			end

			self:_cancelIdle(false)

			local idleGeneration = self.idleGeneration
			local now = os.clock()

			self.idleRunning = idleGeneration
			task.spawn(function()
				local ok, result = xpcall(function()
					while not self.destroyed and not self.busy and self.config.idleFarm and idleGeneration == self.idleGeneration do
						if self.coordinator then
							if self.coordinator:isBackgroundBusy() then
								now = os.clock()
								self:_setStatus("Idle", "Waiting for background inventory")
								task.wait(0.25)

								continue
							end
						end

						if Nyx_isAutoStealBlocking() then
							now = os.clock()
							self:_setStatus("Idle", "Yielding to Auto Steal")
							task.wait(0.25)
						elseif genv.__NyxIsAutoSellEggBusy and genv.__NyxIsAutoSellEggBusy() then
							now = os.clock()
							self:_setStatus("Idle", "Waiting for Auto Sell Egg")
							task.wait(0.25)
						elseif Nyx_hasAnyTreadmillBlocker() then
							now = os.clock()
							self:_setStatus("Idle", Nyx_getTreadmillYieldText())
							task.wait(0.25)
						else
							local Nyx_startDelayRemaining = 1 - (os.clock() - now)

							if Nyx_startDelayRemaining > 0 then
								self:_setStatus("Idle", string.format("Starting in %.0fs", math.ceil(Nyx_startDelayRemaining)))
								task.wait(math.min(Nyx_startDelayRemaining, 0.25))
							else
								local Nyx_treadmillStandCF2 = self:_resolveStandCFrame()

								if Nyx_treadmillStandCF2 then
									self.travelingToTreadmill = true
									self:_setStatus("Moving", "Waiting")

									local travel = self.travel and self.travel:travelAndWait(Nyx_treadmillStandCF2, {
										abort = function()
											return self.destroyed or self.busy or not self.config.idleFarm or idleGeneration ~= self.idleGeneration or self.coordinator and self.coordinator:isBackgroundBusy() or genv.__NyxIsAutoSellEggBusy and genv.__NyxIsAutoSellEggBusy() or Nyx_hasAnyTreadmillBlocker()
										end
									})

									self.travelingToTreadmill = false

									if not travel then
										if not self.busy and self.config.idleFarm then
											self:_setStatus("Idle", "Travel failed")
											task.wait(1)
										end
									elseif not self.busy and self.config.idleFarm and idleGeneration == self.idleGeneration then
										if self.coordinator then
											if self.coordinator:isBackgroundBusy() then
												continue
											end
										end

										if (not genv.__NyxIsAutoSellEggBusy or not genv.__NyxIsAutoSellEggBusy()) and not Nyx_hasAnyTreadmillBlocker() then
											task.wait(0.35)

											if not self.busy and self.config.idleFarm and idleGeneration == self.idleGeneration then
												if self.coordinator then
													if self.coordinator:isBackgroundBusy() then
														continue
													end
												end

												if (not genv.__NyxIsAutoSellEggBusy or not genv.__NyxIsAutoSellEggBusy()) and not Nyx_hasAnyTreadmillBlocker() then
													self.treadmillEquipPending = true

													local ok, result, result2 = pcall(function()
														return Remotes.Treadmill.AskWearStill:InvokeServer()
													end)

													if ok and result ~= false then
														self.lastEquipAt = os.clock()
														self:_setStatus("Active", "Waiting for gain")
														task.delay(2, function()
															if not self.destroyed and self.activeTreadmill == nil then
																self.treadmillEquipPending = false
															end
														end)

														local Nyx_treadmillActiveDeadline = os.clock() + 8

														while (self.activeTreadmill ~= nil or os.clock() < Nyx_treadmillActiveDeadline) and not self.destroyed and not self.busy and self.config.idleFarm and idleGeneration == self.idleGeneration do
															local ok33 = not self.coordinator

															if not ok33 then
																ok33 = not self.coordinator:isBackgroundBusy()
															end

															if not ok33 then
																break
															end

															if Nyx_isAutoStealBlocking() then
																self:_cancelIdle(true)
																self:_setStatus("Idle", "Yielding to Auto Steal")

																break
															end

															if not genv.__NyxIsAutoSellEggBusy or not genv.__NyxIsAutoSellEggBusy() then
																if not Nyx_hasAnyTreadmillBlocker() then
																	task.wait(0.25)

																	continue
																end

																self:_requestUnequip()
																self:_setStatus("Idle", Nyx_getTreadmillYieldText())

																break
															end

															self:_cancelIdle(true)
															self:_setStatus("Idle", "Yielding to Auto Sell Egg")

															break
														end

														continue
													end

													self.treadmillEquipPending = false
													self:_setStatus("Preparing carry", "Activation failed: " .. tostring(result2 or result))

													local Nyx_treadmillActivationDeadline = os.clock() + 8

													while true do
														local coordinator

														if self.activeTreadmill == nil then
															if os.clock() < Nyx_treadmillActivationDeadline and not self.destroyed and not self.busy and self.config.idleFarm and idleGeneration == self.idleGeneration then
																if not self.coordinator then
																	if Nyx_isAutoStealBlocking() then
																		self:_cancelIdle(true)
																		self:_setStatus("Idle", "Yielding to Auto Steal")

																		break
																	end

																	if not genv.__NyxIsAutoSellEggBusy or not genv.__NyxIsAutoSellEggBusy() then
																		if not Nyx_hasAnyTreadmillBlocker() then
																			task.wait(0.25)

																			continue
																		end

																		self:_requestUnequip()
																		self:_setStatus("Idle", Nyx_getTreadmillYieldText())

																		break
																	end

																	self:_cancelIdle(true)
																	self:_setStatus("Idle", "Yielding to Auto Sell Egg")

																	break
																end

																coordinator = self.coordinator

																if not coordinator:isBackgroundBusy() then
																	if Nyx_isAutoStealBlocking() then
																		self:_cancelIdle(true)
																		self:_setStatus("Idle", "Yielding to Auto Steal")

																		break
																	end

																	if not genv.__NyxIsAutoSellEggBusy or not genv.__NyxIsAutoSellEggBusy() then
																		if not Nyx_hasAnyTreadmillBlocker() then
																			task.wait(0.25)

																			continue
																		end

																		self:_requestUnequip()
																		self:_setStatus("Idle", Nyx_getTreadmillYieldText())

																		break
																	end

																	self:_cancelIdle(true)
																	self:_setStatus("Idle", "Yielding to Auto Sell Egg")

																	break
																end
															end

															break
														end

														if not self.destroyed and not self.busy and self.config.idleFarm and idleGeneration == self.idleGeneration then
															if not self.coordinator then
																if Nyx_isAutoStealBlocking() then
																	self:_cancelIdle(true)
																	self:_setStatus("Idle", "Yielding to Auto Steal")

																	break
																end

																if not genv.__NyxIsAutoSellEggBusy or not genv.__NyxIsAutoSellEggBusy() then
																	if not Nyx_hasAnyTreadmillBlocker() then
																		task.wait(0.25)

																		continue
																	end

																	self:_requestUnequip()
																	self:_setStatus("Idle", Nyx_getTreadmillYieldText())

																	break
																end

																self:_cancelIdle(true)
																self:_setStatus("Idle", "Yielding to Auto Sell Egg")

																break
															end

															coordinator = self.coordinator

															if not coordinator:isBackgroundBusy() then
																if Nyx_isAutoStealBlocking() then
																	self:_cancelIdle(true)
																	self:_setStatus("Idle", "Yielding to Auto Steal")

																	break
																end

																if not genv.__NyxIsAutoSellEggBusy or not genv.__NyxIsAutoSellEggBusy() then
																	if not Nyx_hasAnyTreadmillBlocker() then
																		task.wait(0.25)

																		continue
																	end

																	self:_requestUnequip()
																	self:_setStatus("Idle", Nyx_getTreadmillYieldText())

																	break
																end

																self:_cancelIdle(true)
																self:_setStatus("Idle", "Yielding to Auto Sell Egg")

																break
															end
														end

														break
													end
												end
											end
										end
									end
								else
									self:_setStatus("Idle", "Position unavailable")
									task.wait(2)
								end
							end
						end
					end
				end, debug.traceback)

				if not ok then
					warn("[SAE][treadmill] idle error:\n" .. tostring(result))
				end

				if self.idleRunning == idleGeneration then
					self.idleRunning = nil
				end
			end)
		end
		Nyx_TreadmillManager._onCoordinator = function(self, state)
			local busy = self.busy

			self.busy = state.busy == true

			if self.busy then
				self:_cancelIdle(self.config.disableDuringAutomation)
				self:_startUnequipGuard()
				self:_setStatus("Automation active", self.config.disableDuringAutomation and "Blocked" or "Unchanged")
			elseif busy or self.config.idleFarm then
				if self.config.idleFarm then
					self:_startIdle()
				else
					self:_setStatus("Idle", "Disabled")
				end
			end
		end
		Nyx_TreadmillManager._listenCoordinator = function(self)
			if not self.coordinator then
				return
			end

			table.insert(self.resources, self.coordinator:subscribe(function(state)
				self:_onCoordinator(state)
			end))
			table.insert(self.resources, self.coordinator:subscribeBackground(function(state)
				if state.busy then
					self:_cancelIdle(false)
					self:_setStatus("Idle", "Waiting for background inventory")
				elseif not self.destroyed and not self.busy and self.config.idleFarm then
					self:_startIdle()
				end
			end))
		end
		Nyx_TreadmillManager._syncActiveTreadmillSnapshot = function(self)
			local ok, result = pcall(function()
				return Remotes.Treadmill.AskRenderSnapshot:InvokeServer()
			end)

			if not ok or type(result) ~= "table" then
				return self.activeTreadmill ~= nil
			end

			local Nyx_activeTreadmillFlag = table.find(result, LocalPlayer2.UserId) ~= nil

			self.activeTreadmill = Nyx_activeTreadmillFlag and "snapshot" or nil

			if not Nyx_activeTreadmillFlag then
				self.treadmillEquipPending = false
			end

			return Nyx_activeTreadmillFlag
		end
		Nyx_TreadmillManager._listenActiveTreadmill = function(self)
			local function Nyx_applyActiveTreadmill(treadmillState)
				self.treadmillStateRevision += 1
				self.activeTreadmill = treadmillState
				self.treadmillEquipPending = false

				if treadmillState ~= nil and self:_shouldBlockTreadmill() then
					self:_startUnequipGuard()
				elseif treadmillState == nil and self:_shouldBlockTreadmill() then
					self:_setStatus("Automation active", "Blocked")
				elseif treadmillState == nil then
					self:_setStatus("Idle", self.config.idleFarm and "Released" or "Disabled")
				elseif not self.busy then
					self:_setStatus("Active", "Waiting for gain")
				end
			end

			local AssignedBeltShifted
			local RenderStateShifted

			pcall(function()
				AssignedBeltShifted = Remotes.Treadmill.AssignedBeltShifted
			end)
			pcall(function()
				RenderStateShifted = Remotes.Treadmill.RenderStateShifted
			end)

			if AssignedBeltShifted then
				table.insert(self.resources, AssignedBeltShifted.OnClientEvent:Connect(function(treadmillState)
					Nyx_applyActiveTreadmill(treadmillState)
				end))

				return
			end

			if RenderStateShifted then
				table.insert(self.resources, RenderStateShifted.OnClientEvent:Connect(function(playerName, activeName)
					if playerName ~= LocalPlayer2.Name then
						return
					end

					local Nyx_applyActiveTreadmillRef = Nyx_applyActiveTreadmill
					local Nyx_activeTreadmillName = activeName and playerName

					Nyx_applyActiveTreadmillRef(Nyx_activeTreadmillName or nil)
				end))
			end
		end
		Nyx_TreadmillManager._listenSpeedGain = function(self)
			local SpeedGained = Remotes.Treadmill.SpeedGained

			if SpeedGained then
				table.insert(self.resources, SpeedGained.OnClientEvent:Connect(function()
					self.activeTreadmill = self.activeTreadmill or true
					self.treadmillEquipPending = false

					if not self:_shouldBlockTreadmill() then
						self:_setStatus("Active", "Gain ticking")

						return
					end

					self:_startUnequipGuard()
				end))
			end
		end
		Nyx_TreadmillManager.destroy = function(self)
			if self.destroyed then
				return
			end

			self.destroyed = true
			self:_cancelIdle(true)

			for _, resource in ipairs(self.resources) do
				pcall(function()
					if typeof(resource) == "RBXScriptConnection" then
						resource:Disconnect()
					elseif type(resource) == "function" then
						resource()
					elseif type(resource) == "table" and type(resource.Disconnect) == "function" then
						resource:Disconnect()
					end
				end)
			end

			table.clear(self.resources)
			table.clear(self.listeners)
		end
		Nyx_TreadmillManager.Destroy = Nyx_TreadmillManager.destroy

		return Nyx_TreadmillManager
	end

	local Nyx_treadmillManagerClass = Nyx_GodModeClass_var2()
	local Nyx_coordinatorInst = Nyx_coordinator.new()

	Nyx_eggRuntime = Nyx_EggRuntimeClass.new(Nyx_catalog, Nyx_limitsModule, Nyx_coordinatorInst)
	genv.__NyxEggRuntime = Nyx_eggRuntime
	Nyx_treadmillManager = Nyx_treadmillManagerClass.new(Nyx_coordinatorInst, Nyx_eggRuntime)
	genv.__NyxTreadmillManager = Nyx_treadmillManager
	Nyx_eggRuntime:setTreadmillManager(Nyx_treadmillManager)
	Nyx_treadmillManager:setDisableDuringAutomation(true)

	if NyxConfig.AutoTreadmillIdle then
		Nyx_treadmillManager:setIdleFarm(true)
	end

	if NyxConfig.AutoIndex then
		Nyx_eggRuntime:setIndexObjective(true)
	end

	if NyxConfig.AutoTreadmillUpgrade then
		Nyx_treadmillManager:setAutoUpgrade(true)
	end

	local function Nyx_webhookFactory()
		local HttpService = game:GetService("HttpService")
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local LocalPlayer2 = game:GetService("Players").LocalPlayer
		local http_request_ = http_request or request or http and http.request or syn and syn.request or fluxus and fluxus.request
		local Nyx_webhookQueue = {}
		local Nyx_webhookFactory_var1 = false
		local Nyx_assetIconCache = {}
		local Nyx_webhookFactory_var2
		local AssetEarnings
		local EggRecords

		pcall(function()
			AssetEarnings = require(ReplicatedStorage2.Shared.Util.AssetEarnings)
		end)
		pcall(function()
			EggRecords = require(ReplicatedStorage2.Shared.Util.EggRecords)
		end)

		local function Nyx_resolveThumbnail(assetIdInput)
			local match = tostring(assetIdInput or ""):match("%d+")

			if not match then
				return nil
			end

			local Nyx_cachedThumbnail = Nyx_assetIconCache[match]

			if Nyx_cachedThumbnail ~= nil then
				if Nyx_cachedThumbnail == "" then
					return nil
				end

				return Nyx_cachedThumbnail
			end

			local Nyx_preferredThumbnail

			for _, v in ipairs({
				"512x512",
				"150x150"
			}) do
				local imageUrl

				pcall(function()
					local Nyx_thumbnailUrl = "https://thumbnails.roblox.com/Nyx_resolveThumbnail_var1/assets?assetIds=" .. match .. "&size=" .. v .. "&format=Png&isCircular=false"
					local Body

					if http_request_ then
						local Nyx_thumbnailResponse = http_request_({
							Url = Nyx_thumbnailUrl,
							Method = "GET"
						})

						Body = type(Nyx_thumbnailResponse) == "table" and (Nyx_thumbnailResponse.Body or Nyx_thumbnailResponse.body) or nil
					else
						Body = HttpService:GetAsync(Nyx_thumbnailUrl)
					end

					if type(Body) == "string" and Body ~= "" then
						local data = HttpService:JSONDecode(Body)
						local data2 = data and data.data and data.data[1]

						if data2 and data2.state == "Completed" and type(data2.imageUrl) == "string" and data2.imageUrl ~= "" then
							imageUrl = data2.imageUrl
						end
					end
				end)

				if imageUrl then
					Nyx_preferredThumbnail = Nyx_preferredThumbnail or imageUrl

					if imageUrl:find("/Png/", 1, true) then
						Nyx_preferredThumbnail = imageUrl

						break
					else
					end
				else
				end
			end

			Nyx_assetIconCache[match] = Nyx_preferredThumbnail or ""

			return Nyx_preferredThumbnail
		end
		local function Nyx_getWebhookIcon()
			if Nyx_webhookFactory_var2 == nil then
				Nyx_webhookFactory_var2 = Nyx_resolveThumbnail("96240498384290") or false
			end

			return Nyx_webhookFactory_var2 or nil
		end
		local function Nyx_flushWebhookQueue()
			if Nyx_webhookFactory_var1 then
				return
			end

			Nyx_webhookFactory_var1 = true
			task.spawn(function()
				while #Nyx_webhookQueue > 0 do
					local Nyx_webhookQueueItem = table.remove(Nyx_webhookQueue, 1)

					pcall(function()
						if Nyx_webhookQueueItem.thumbAsset then
							local Nyx_webhookEmbed = Nyx_webhookQueueItem.payload.embeds[1]
							local Nyx_resolvedThumbnail = Nyx_resolveThumbnail(Nyx_webhookQueueItem.thumbAsset)

							if Nyx_resolvedThumbnail then
								Nyx_webhookEmbed.thumbnail = {
									url = Nyx_resolvedThumbnail
								}
							end
						end

						local json = HttpService:JSONEncode(Nyx_webhookQueueItem.payload)

						if http_request_ then
							http_request_({
								Url = Nyx_webhookQueueItem.url,
								Method = "POST",
								Headers = {
									["Content-Type"] = "application/json"
								},
								Body = json
							})
						else
							HttpService:PostAsync(Nyx_webhookQueueItem.url, json, Enum.HttpContentType.ApplicationJson)
						end
					end)
					task.wait(0.6)
				end

				Nyx_webhookFactory_var1 = false
			end)
		end
		local function Nyx_colorToDecimal(color)
			if typeof(color) == "Color3" then
				return math.floor(color.R * 255 + 0.5) * 65536 + math.floor(color.G * 255 + 0.5) * 256 + math.floor(color.B * 255 + 0.5)
			end

			return 5814783
		end
		local function compact(value)
			local Simple

			pcall(function()
				Simple = require(ReplicatedStorage2.Packages.FormatNumber.Simple)
			end)

			if Simple and Simple.FormatCompact then
				local ok, result = pcall(Simple.FormatCompact, value, ".#")

				if ok and result then
					return tostring(result)
				end
			end

			local format = string.format
			local Nyx_compact_var1 = "%.1f"
			local Nyx_compactNumberInput = value or 0

			return format(Nyx_compact_var1, Nyx_compactNumberInput)
		end

		local Nyx_webhookHelpers = {
			compact = compact,
			rateOf = function(record)
				if not AssetEarnings or type(record) ~= "table" then
					return 0
				end

				local Nyx_resolvedAssetScale = tonumber(record.AssetScale) or 1
				local Nyx_rateContext = {
					Category = record.AssetCategory,
					Scale = Nyx_resolvedAssetScale,
					AssetScale = Nyx_resolvedAssetScale,
					BaseMutation = record.BaseMutation,
					Mutations = record.Mutations or {}
				}

				for _, v in ipairs({
					"LiveRatePerSecond",
					"RatePerSecond",
					"CatalogRatePerSecond"
				}) do
					if type(AssetEarnings[v]) == "function" then
						local ok, result = pcall(AssetEarnings[v], Nyx_rateContext)

						if ok and type(result) == "number" and result > 0 then
							return result
						end
					end
				end

				return 0
			end,
			weightOf = function(record)
				if not EggRecords or type(record) ~= "table" then
					return 0
				end

				local ok, result = pcall(EggRecords.WeightKgForScale, record.AssetCategory, tonumber(record.AssetScale) or 1)

				if ok and type(result) == "number" then
					return result
				end

				return 0
			end,
			sizeText = function(record)
				local Nyx_sizeTextValue = tonumber(record and (record.AssetScale or record.Scale)) or 1

				if Nyx_sizeTextValue >= 100 then
					return string.format("%.0fx", Nyx_sizeTextValue)
				end

				return string.format("%.2fx", Nyx_sizeTextValue)
			end,
			weightText = function(weightKg)
				local Nyx_weightTextValue = tonumber(weightKg) or 0

				if Nyx_weightTextValue >= 1000 then
					return compact(Nyx_weightTextValue) .. " kg"
				end

				return string.format("%.1fkg", Nyx_weightTextValue)
			end,
			rateText = function(rate)
				local Nyx_rateTextValue = tonumber(rate) or 0

				if Nyx_rateTextValue >= 1000 then
					return "$" .. compact(Nyx_rateTextValue) .. "/s"
				end

				return string.format("$%d/s", math.floor(Nyx_rateTextValue))
			end,
			passes = function(record, resolvedEgg, eggRate)
				local Nyx_webhookRaritySet = {}
				local Nyx_hasRarityFilter = false
				local ipairs_ = ipairs
				local WebhookRarities = NyxConfig.WebhookRarities or {}

				for _, WebhookRarity in ipairs_(WebhookRarities) do
					if WebhookRarity ~= "None" and WebhookRarity ~= "" then
						Nyx_webhookRaritySet[WebhookRarity] = true
						Nyx_hasRarityFilter = true
					end
				end

				if Nyx_hasRarityFilter and not Nyx_webhookRaritySet[resolvedEgg.rarity] then
					return false
				end

				local Nyx_webhookMinValue = tonumber(NyxConfig.WebhookMinValue) or 0

				if Nyx_webhookMinValue > 0 and eggRate < Nyx_webhookMinValue then
					return false
				end

				return true
			end
		}
		local Nyx_imageFieldNames = {
			"Image",
			"Icon",
			"Thumbnail",
			"ImageId",
			"IconId",
			"Texture",
			"Asset",
			"DisplayImage"
		}

		Nyx_webhookHelpers.eggAsset = function(assetCategory)
			local Directory

			pcall(function()
				Directory = require(ReplicatedStorage2.Data.Assets).Directory
			end)

			local Nyx_assetDefFound = Directory and Directory[assetCategory]

			if type(Nyx_assetDefFound) ~= "table" then
				return nil
			end

			for _, v in ipairs({
				Nyx_assetDefFound,
				Nyx_assetDefFound.Egg,
				Nyx_assetDefFound.Pet
			}) do
				if type(v) == "table" then
					for _, Nyx_item in ipairs(Nyx_imageFieldNames) do
						local Nyx_assetIconRaw = v[Nyx_item]
						local match = (type(Nyx_assetIconRaw) == "string" or type(Nyx_assetIconRaw) == "number") and tostring(Nyx_assetIconRaw):match("%d+")

						if not match or not (tonumber(match) > 0) then
							continue
						end

						return match
					end
				end
			end

			return nil
		end
		Nyx_webhookHelpers.stolen = function(record, resolvedEgg, source)
			if NyxConfig.WebhookEnabled ~= true then
				return
			end

			local WebhookURL = NyxConfig.WebhookURL

			if type(WebhookURL) ~= "string" or WebhookURL == "" then
				return
			end

			if not (type(record) == "table" and record.AssetCategory) then
				return
			end

			local Nyx_webhookResolvedEgg = resolvedEgg or {
				name = record.AssetCategory,
				rarity = "Unknown",
				rarityColor = nil
			}
			local Nyx_webhookEggRate = Nyx_webhookHelpers.rateOf(record)

			if not Nyx_webhookHelpers.passes(record, Nyx_webhookResolvedEgg, Nyx_webhookEggRate) then
				return
			end

			local Nyx_webhookFields = {
				{
					name = "User",
					value = LocalPlayer2.Name,
					inline = true
				},
				{
					name = "Rarity",
					value = tostring(Nyx_webhookResolvedEgg.rarity),
					inline = true
				},
				{
					name = "Size",
					value = Nyx_webhookHelpers.sizeText(record),
					inline = true
				},
				{
					name = "Weight",
					value = Nyx_webhookHelpers.weightText(Nyx_webhookHelpers.weightOf(record)),
					inline = true
				},
				{
					name = "Cash/s",
					value = Nyx_webhookHelpers.rateText(Nyx_webhookEggRate),
					inline = true
				},
				{
					name = "Area",
					value = tostring(record.AreaId or "?"),
					inline = true
				}
			}
			local Mutations = record.Mutations or {}

			if #Mutations > 0 then
				local Nyx_mutationStrings = {}

				for _, Mutation in ipairs(Mutations) do
					Nyx_mutationStrings[#Nyx_mutationStrings + 1] = tostring(Mutation)
				end

				Nyx_webhookFields[#Nyx_webhookFields + 1] = {
					name = "Mutations",
					value = table.concat(Nyx_mutationStrings, ", "),
					inline = false
				}
			end

			if source and source ~= "" then
				Nyx_webhookFields[#Nyx_webhookFields + 1] = {
					name = "Taken From",
					value = tostring(source),
					inline = false
				}
			end

			local Nyx_webhookAuthorIcon = Nyx_getWebhookIcon()
			local Nyx_webhookPayload = {
				title = "Egg Stolen",
				description = string.format("You've stolen a **%s** %s", tostring(Nyx_webhookResolvedEgg.rarity), tostring(Nyx_webhookResolvedEgg.name)),
				color = Nyx_colorToDecimal(Nyx_webhookResolvedEgg.rarityColor),
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				author = {
					name = "Nyx Hub",
					icon_url = Nyx_webhookAuthorIcon
				},
				footer = {
					text = "discord.gg/Nyxhub",
					icon_url = Nyx_webhookAuthorIcon
				},
				fields = Nyx_webhookFields
			}

			if #Nyx_webhookQueue > 40 then
				table.remove(Nyx_webhookQueue, 1)
			end

			table.insert(Nyx_webhookQueue, {
				url = WebhookURL,
				payload = {
					embeds = { Nyx_webhookPayload }
				}
			})
			Nyx_flushWebhookQueue()
		end
		Nyx_webhookHelpers.test = function()
			local WebhookURL = NyxConfig.WebhookURL

			if type(WebhookURL) ~= "string" or WebhookURL == "" then
				return false
			end

			local Nyx_webhookTestIcon = Nyx_getWebhookIcon()
			local Nyx_webhookTestPayload = {
				title = "Webhook Test",
				description = string.format("Connection test for **%s**", LocalPlayer2.Name),
				color = 5814783,
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				author = {
					name = "Nyx Hub",
					icon_url = Nyx_webhookTestIcon
				},
				footer = {
					text = "discord.gg/Nyxhub",
					icon_url = Nyx_webhookTestIcon
				},
				fields = {
					{
						name = "User",
						value = LocalPlayer2.Name,
						inline = true
					},
					{
						name = "User ID",
						value = tostring(LocalPlayer2.UserId),
						inline = true
					},
					{
						name = "Place ID",
						value = tostring(game.PlaceId),
						inline = true
					},
					{
						name = "Status",
						value = "Connected",
						inline = true
					}
				}
			}
			local Nyx_webhookTestThumbnail = Nyx_resolveThumbnail("96240498384290")

			if Nyx_webhookTestThumbnail then
				Nyx_webhookTestPayload.thumbnail = {
					url = Nyx_webhookTestThumbnail
				}
			end

			table.insert(Nyx_webhookQueue, {
				url = WebhookURL,
				payload = {
					embeds = { Nyx_webhookTestPayload }
				}
			})
			Nyx_flushWebhookQueue()

			return true
		end

		return Nyx_webhookHelpers
	end

	genv.__NyxWebhook = Nyx_webhookFactory()

	local function Nyx_passes_var1()
		local Players2 = game:GetService("Players")
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local LocalPlayer2 = Players2.LocalPlayer
		local EggState2 = require(ReplicatedStorage2.Client.EggState)
		local AreaEggs = require(ReplicatedStorage2.Shared.Types.AreaEggs)
		local Nyx_PlayerSteal = {}

		Nyx_PlayerSteal.__index = Nyx_PlayerSteal

		local Nyx_chaseLeads = {
			1.1,
			0.2,
			0.7,
			1.4,
			0.45
		}

		Nyx_PlayerSteal.new = function(eggRuntime, godMode, catalog)
			local obj = setmetatable({}, Nyx_PlayerSteal)

			obj.eggRuntime = eggRuntime
			obj.godMode = godMode
			obj.catalog = catalog
			obj.enabled = false
			obj.running = false
			obj.status = "idle"
			obj.taken = 0
			obj.attempts = 0
			obj.history = {}
			obj.blacklist = {}
			obj.forced = false
			obj.listeners = {}
			obj.swingSeq = 0
			obj.leadIdx = 1
			obj.hitIdx = nil
			obj.missStreak = 0

			return obj
		end
		Nyx_PlayerSteal.onChanged = function(self, listener)
			table.insert(self.listeners, listener)
		end
		Nyx_PlayerSteal._notify = function(self)
			for _, listener in ipairs(self.listeners) do
				pcall(listener, self)
			end
		end
		Nyx_PlayerSteal._setStatus = function(self, newStatus)
			if self.status == newStatus then
				return
			end

			self.status = newStatus
			self:_notify()
		end
		Nyx_PlayerSteal._log = function(self, playerName, eggName, outcome)
			table.insert(self.history, 1, {
				at = os.time(),
				player = playerName or "?",
				egg = eggName or "?",
				outcome = outcome or "?"
			})

			while #self.history > 20 do
				table.remove(self.history)
			end

			self:_notify()
		end
		Nyx_PlayerSteal.setEnabled = function(self, enabled)
			self.enabled = enabled == true

			if self.enabled then
				self:_setStatus("looking for a carrier")
				self:_start()
			else
				self:_setStatus("idle")
			end
		end
		Nyx_PlayerSteal._passes = function(self, record)
			if not (type(record) == "table" and record.AssetCategory) then
				return false
			end

			local Nyx_resolvedStealEgg = self.catalog.resolve(record)
			local Nyx_playerRaritySet = {}
			local Nyx_hasRarityFilter2 = false
			local ipairs_ = ipairs
			local StealPlayerRarities = NyxConfig.StealPlayerRarities or {}

			for _, StealPlayerRarity in ipairs_(StealPlayerRarities) do
				if StealPlayerRarity ~= "None" and StealPlayerRarity ~= "" then
					Nyx_playerRaritySet[StealPlayerRarity] = true
					Nyx_hasRarityFilter2 = true
				end
			end

			if not Nyx_hasRarityFilter2 then
				local ipairs_2 = ipairs
				local StealRarities = NyxConfig.StealRarities or {}

				for _, StealRarity in ipairs_2(StealRarities) do
					if StealRarity ~= "None" and StealRarity ~= "" then
						Nyx_playerRaritySet[StealRarity] = true
						Nyx_hasRarityFilter2 = true
					end
				end
			end

			if Nyx_hasRarityFilter2 and not Nyx_playerRaritySet[Nyx_resolvedStealEgg.rarity] then
				return false
			end

			local Nyx_playerMinValue = tonumber(NyxConfig.StealPlayerMinValue) or 0

			if Nyx_playerMinValue > 0 then
				if (genv.__NyxWebhook and genv.__NyxWebhook.rateOf(record) or 0) < Nyx_playerMinValue then
					return false
				end
			end

			return true
		end
		Nyx_PlayerSteal.carriers = function(self)
			local Nyx_carriersMap = {}
			local ok, result = pcall(function()
				return EggState2.ReadFieldEggs()
			end)

			if not ok or not result then
				return Nyx_carriersMap
			end

			local ipairs_ = ipairs
			local Records = result.Records or {}

			for _, Record in ipairs_(Records) do
				if (Record.State == "Carried" or AreaEggs and AreaEggs.States and Record.State == AreaEggs.States.Carried) and not self.blacklist[Record.Uid] then
					local Nyx_v2149_var1

					pcall(function()
						Nyx_v2149_var1 = EggState2.ReadFieldEgg(Record.Uid)
					end)
					Nyx_v2149_var1 = Nyx_v2149_var1 or Record

					local CarrierUserId = Nyx_v2149_var1.CarrierUserId

					if CarrierUserId and CarrierUserId ~= LocalPlayer2.UserId then
						local playerByUserId = Players2:GetPlayerByUserId(CarrierUserId)
						local HumanoidRootPart = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChild("HumanoidRootPart")

						if playerByUserId and HumanoidRootPart then
							table.insert(Nyx_carriersMap, {
								record = Nyx_v2149_var1,
								player = playerByUserId,
								root = HumanoidRootPart
							})
						end
					end
				end
			end

			return Nyx_carriersMap
		end
		Nyx_PlayerSteal.clearHistory = function(self)
			table.clear(self.history)
			self:_notify()
		end

		local function Nyx_v2149_var2(color)
			if typeof(color) == "Color3" then
				return string.format("%02x%02x%02x", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
			end

			return "ffffff"
		end

		Nyx_PlayerSteal.listEntries = function(self)
			local Nyx_playerEntriesMap = {}

			for _, v in ipairs(self:carriers()) do
				Nyx_playerEntriesMap[v.player] = v.record
			end

			local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")
			local Nyx_playerListEntries = {}
			local Nyx_playerDistance

			for _, player in ipairs(Players2:GetPlayers()) do
				if player ~= LocalPlayer2 then
					local Nyx_playerCarriedRecord, Nyx_v2183_var1

					if player.Character then
						local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

						Nyx_playerCarriedRecord = Nyx_playerEntriesMap[player]

						local ok = not (HumanoidRootPart2 and HumanoidRootPart)

						if not ok then
							Nyx_playerDistance = math.floor((HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude + 0.5)
							ok = not Nyx_playerDistance
						end

						if ok then
							Nyx_playerDistance = nil
						end

						Nyx_v2183_var1 = "Offline"

						if Nyx_playerCarriedRecord and Nyx_playerCarriedRecord.AreaId then
							Nyx_v2183_var1 = tostring(Nyx_playerCarriedRecord.AreaId)
						elseif HumanoidRootPart2 then
							Nyx_v2183_var1 = HumanoidRootPart2.Position.X <= 552.2 and "Safe Zone" or "Field"
						end
					else
						Nyx_playerCarriedRecord = Nyx_playerEntriesMap[player]
						Nyx_playerDistance = nil
						Nyx_v2183_var1 = "Offline"

						if Nyx_playerCarriedRecord and Nyx_playerCarriedRecord.AreaId then
							Nyx_v2183_var1 = tostring(Nyx_playerCarriedRecord.AreaId)
						end
					end

					local rarityRank
					local Nyx_playerStatusMain, Nyx_playerStatusSub

					if Nyx_playerCarriedRecord then
						local ok, result = pcall(function()
							return self.catalog.resolve(Nyx_playerCarriedRecord)
						end)
						local Nyx_playerResolvedEgg = ok and result

						if not Nyx_playerResolvedEgg then
							Nyx_playerResolvedEgg = {
								rarityRank = 0,
								name = tostring(Nyx_playerCarriedRecord.AssetCategory or "Egg"),
								rarity = "Unknown",
								rarityColor = Color3.fromRGB(245, 196, 81)
							}
						end

						local Nyx_playerResolvedRef = Nyx_playerResolvedEgg

						rarityRank = Nyx_playerResolvedRef.rarityRank or 0
						Nyx_playerStatusMain = string.format("<font color=\"#%s\">%s</font>  <font color=\"#A2A2AE\">[%s]</font>", Nyx_v2149_var2(Nyx_playerResolvedRef.rarityColor), tostring(Nyx_playerResolvedRef.name or "Egg"), tostring(Nyx_playerResolvedRef.rarity or "Common"))
						Nyx_playerStatusSub = string.format("Running in %s%s", Nyx_v2183_var1, Nyx_playerDistance and "  -  " .. Nyx_playerDistance .. " studs" or "")
					else
						Nyx_playerStatusMain = "No Egg Carried"
						Nyx_playerStatusSub = string.format("Idle in %s%s", Nyx_v2183_var1, Nyx_playerDistance and "  -  " .. Nyx_playerDistance .. " studs" or "")
					end

					Nyx_playerListEntries[#Nyx_playerListEntries + 1] = {
						id = tostring(player.UserId),
						name = tostring(player.DisplayName or player.Name),
						sub = string.format("<font color=\"#4ADE80\">@%s</font>  <font color=\"#A2A2AE\">[%s]</font>", tostring(player.Name), Nyx_v2183_var1),
						status = Nyx_playerStatusMain,
						statusSub = Nyx_playerStatusSub,
						button = "Steal",
						buttonColor = Nyx_playerCarriedRecord and "accent" or "dim",
						player = player,
						carrying = Nyx_playerCarriedRecord ~= nil,
						rank = rarityRank or -1,
						distance = Nyx_playerDistance or 1e9,
						onClick = function(entry, buttonStateFn)
							local Nyx_strikeResult = self:strike(entry.player)

							buttonStateFn(Nyx_strikeResult and "Chasing" or "No Egg", Nyx_strikeResult and "green" or "red")
							task.delay(1.6, function()
								pcall(buttonStateFn, "Steal", entry.carrying and "accent" or "dim")
							end)
						end
					}
				end
			end

			table.sort(Nyx_playerListEntries, function(entryA, entryB)
				if entryA.carrying ~= entryB.carrying then
					return entryA.carrying
				end

				if not entryA.carrying or entryA.rank == entryB.rank then
					return entryA.distance < entryB.distance
				end

				return entryA.rank > entryB.rank
			end)

			return Nyx_playerListEntries
		end
		Nyx_PlayerSteal._pick = function(self)
			local StealPlayerTarget = NyxConfig.StealPlayerTarget
			local Nyx_bestPlayerTarget
			local Nyx_bestPlayerRank
			local Nyx_carriersIter, Nyx_carriersIterState, Nyx_carriersIterControl = ipairs(self:carriers())
			local Nyx_carriersIterator = geniter(Nyx_carriersIter, Nyx_carriersIterState, Nyx_carriersIterControl)

			while true do
				local Nyx_carriersFirstPack = table.pack(Nyx_carriersIterator())

				if not Nyx_carriersFirstPack[1] then
					break
				end

				local Nyx_playerCarrier = Nyx_carriersFirstPack[3]
				local Nyx_playerMatchesTarget = StealPlayerTarget == nil or StealPlayerTarget == "" or StealPlayerTarget == "Any Player" or Nyx_playerCarrier.player.Name == StealPlayerTarget

				if not (Nyx_playerCarrier.root.Position.X > 672.2) then
					continue
				end

				local exitTo2

				while true do
					local Nyx_playerNotInBoss = Nyx_playerCarrier.player:GetAttribute("InBossArena") ~= true
					local exitTo

					while true do
						if not Nyx_playerMatchesTarget or not Nyx_playerNotInBoss then
							local Nyx_carriersNextPack = table.pack(Nyx_carriersIterator())

							if not Nyx_carriersNextPack[1] then
								break
							end

							Nyx_playerCarrier = Nyx_carriersNextPack[3]
							Nyx_playerMatchesTarget = StealPlayerTarget == nil or StealPlayerTarget == "" or StealPlayerTarget == "Any Player" or Nyx_playerCarrier.player.Name == StealPlayerTarget
							Nyx_playerNotInBoss = Nyx_playerCarrier.root.Position.X > 672.2

							if not Nyx_playerNotInBoss then
								continue
							end

							exitTo = 2

							break
						end

						exitTo = 1

						break
					end

					if exitTo == 1 then
						exitTo2 = 1

						break
					elseif exitTo == 2 then
						continue
					end

					break
				end

				if exitTo2 == 1 then
					if self:_passes(Nyx_playerCarrier.record) then
						local rarityRank = self.catalog.resolve(Nyx_playerCarrier.record).rarityRank or 0

						if not Nyx_bestPlayerRank or Nyx_bestPlayerRank < rarityRank then
							Nyx_bestPlayerTarget = Nyx_playerCarrier
							Nyx_bestPlayerRank = rarityRank
						end
					end

					continue
				end

				break
			end

			return Nyx_bestPlayerTarget
		end
		Nyx_PlayerSteal.strike = function(self, targetPlayer)
			if not targetPlayer or targetPlayer == LocalPlayer2 then
				return false
			end

			for _, v in ipairs(self:carriers()) do
				if v.player == targetPlayer then
					self.forced = true
					task.spawn(function()
						self:_chase(v)
					end)

					return true
				end
			end

			self:_setStatus(targetPlayer.Name .. " is not carrying an egg")

			return false
		end

		local function Nyx_resetRagdollState()
			local Character = LocalPlayer2.Character

			if not Character then
				return
			end

			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

			for _, descendant in ipairs(Character:GetDescendants()) do
				if not descendant:IsA("Motor6D") then
					if not descendant:IsA("BallSocketConstraint") then
						if not descendant:IsA("HingeConstraint") then
							if not descendant:IsA("Attachment") then
								continue
							end

							if not descendant.Name:find("Ragdoll") and not descendant:GetAttribute("RagdollAttachment") then
								continue
							end

							pcall(function()
								descendant:Destroy()
							end)

							continue
						end
					end

					if descendant.Name:find("Ragdoll") or descendant:GetAttribute("RagdollConstraint") then
						pcall(function()
							descendant:Destroy()
						end)
					end
				elseif not descendant.Enabled then
					descendant.Enabled = true
				end
			end

			if Humanoid then
				Humanoid.PlatformStand = false
				Humanoid.Sit = false
				pcall(function()
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
					Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
					task.wait(0.02)
					Humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end)
			end

			if HumanoidRootPart then
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			end
		end
		local function Nyx_findForestGuard()
			local Nyx_worldRef7 = Nyx_getWorkspaceWorld()
			local Areas = Nyx_worldRef7 and Nyx_worldRef7:FindFirstChild("Areas")
			local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
			local Forest = GuardAreas and GuardAreas:FindFirstChild("Forest")

			if Forest then
				local Guard = Forest:FindFirstChild("Guard")
				local HumanoidRootPart = Guard and (Guard:FindFirstChild("HumanoidRootPart") or Guard:FindFirstChild("Collider") or Guard:IsA("Model") and Guard.PrimaryPart)

				if Guard and HumanoidRootPart then
					return Guard, HumanoidRootPart
				end

				local ForestGuardAuthored = Forest:FindFirstChild("ForestGuardAuthored")
				local HumanoidRootPart2 = ForestGuardAuthored and (ForestGuardAuthored:FindFirstChild("HumanoidRootPart") or ForestGuardAuthored:IsA("Model") and ForestGuardAuthored.PrimaryPart)

				if ForestGuardAuthored and HumanoidRootPart2 then
					return ForestGuardAuthored, HumanoidRootPart2
				end
			end

			local AreaGuards = workspace:FindFirstChild("AreaGuards")

			if AreaGuards then
				for _, child in ipairs(AreaGuards:GetChildren()) do
					local HumanoidRootPart = child:FindFirstChild("HumanoidRootPart")

					if HumanoidRootPart and HumanoidRootPart.Position.X < 850 then
						return child, HumanoidRootPart
					end
				end
			end

			return nil, nil
		end
		local function Nyx_findForestBaitEgg(skipUid)
			local Nyx_findForestBaitEgg_var2

			pcall(function()
				Nyx_findForestBaitEgg_var2 = EggState2.ReadFieldEggs()
			end)

			local Records = Nyx_findForestBaitEgg_var2 and Nyx_findForestBaitEgg_var2.Records or {}
			local Nyx_forestBaitFound

			for _, Record in ipairs(Records) do
				if (Record.State == "Slot" or Record.State == "Dropped") and Record.Uid ~= skipUid and (not Record.CarrierUserId or Record.CarrierUserId == LocalPlayer2.UserId) then
					local Position = Record.BottomCFrame and Record.BottomCFrame.Position or Record.BoundsCFrame and Record.BoundsCFrame.Position

					if Record.AreaId == "Forest" or tostring(Record.Uid):find("Forest", 1, true) or tostring(Record.Uid):find("^FirstArea") or Position and Position.X < 680 then
						if Record.State == "Slot" then
							Nyx_forestBaitFound = Record

							break
						end

						Nyx_forestBaitFound = Nyx_forestBaitFound or Record
					end
				end
			end

			return Nyx_forestBaitFound
		end

		Nyx_PlayerSteal._primeForest = function(self, targetUid)
			local eggRuntime = self.eggRuntime
			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not HumanoidRootPart or not Humanoid or not (Humanoid.Health > 0) then
				return false
			end

			if eggRuntime and eggRuntime.carry and eggRuntime.carry.active and eggRuntime.carry.uid then
				pcall(function()
					eggRuntime:_returnToSafe()
				end)
				task.wait(0.08)
			end

			self:_setStatus("Finding Forest bait egg")

			local Nyx_forestBaitEggRecord = Nyx_findForestBaitEgg(targetUid)

			if not Nyx_forestBaitEggRecord then
				self:_setStatus("No Forest bait egg available")

				return false
			end

			local Position = Nyx_forestBaitEggRecord.BottomCFrame and Nyx_forestBaitEggRecord.BottomCFrame.Position or Nyx_forestBaitEggRecord.BoundsCFrame and Nyx_forestBaitEggRecord.BoundsCFrame.Position or Vector3.new(596.6, 67.7, -325)
			local vector32 = Vector3.new(Position.X, Position.Y + 2.5, Position.Z)
			local Nyx_findForestBaitEgg_var3 = "Forest:" .. tostring(Nyx_forestBaitEggRecord.NestId or "Slot_001")

			pcall(function()
				local AreaEggSlotIdentity = require(ReplicatedStorage2.Shared.Util.AreaEggSlotIdentity)

				if AreaEggSlotIdentity and Nyx_forestBaitEggRecord.AreaId and Nyx_forestBaitEggRecord.NestId then
					Nyx_findForestBaitEgg_var3 = AreaEggSlotIdentity.SlotKey(Nyx_forestBaitEggRecord.AreaId, Nyx_forestBaitEggRecord.NestId)
				end
			end)
			self:_setStatus("Grabbing Forest bait egg")
			HumanoidRootPart.CFrame = cFrameNew(vector32)
			HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
			HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			RunService.Heartbeat:Wait()

			local Nyx_forestBaitCarried = false
			local now = os.clock()
			local Nyx_findForestBaitEgg_var1 = 0

			while os.clock() - now < 0.8 do
				HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or HumanoidRootPart

				if HumanoidRootPart.Position.Y < 65 then
					HumanoidRootPart.CFrame = cFrameNew(vector32)
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				end

				if Nyx_findForestBaitEgg_var1 <= os.clock() then
					Nyx_findForestBaitEgg_var1 = os.clock() + 0.1
					task.spawn(function()
						pcall(function()
							EggState2.CarryFieldEgg(Nyx_forestBaitEggRecord.Uid, Nyx_findForestBaitEgg_var3)
						end)
					end)
					task.spawn(function()
						pcall(function()
							local Remotes = require(ReplicatedStorage2.Shared.Remotes)

							if Remotes and Remotes.EggWorld and Remotes.EggWorld.AskFieldEggCarry then
								Remotes.EggWorld.AskFieldEggCarry:InvokeServer({
									Uid = Nyx_forestBaitEggRecord.Uid,
									FirstAreaSlotKey = Nyx_findForestBaitEgg_var3
								})
							end
						end)
					end)
				end

				local Nyx_findForestBaitEgg_var4

				pcall(function()
					Nyx_findForestBaitEgg_var4 = EggState2.ReadFieldEgg(Nyx_forestBaitEggRecord.Uid)
				end)

				if Nyx_findForestBaitEgg_var4 and Nyx_findForestBaitEgg_var4.State == "Carried" and Nyx_findForestBaitEgg_var4.CarrierUserId == LocalPlayer2.UserId then
					Nyx_forestBaitCarried = true

					break
				else
					RunService.Heartbeat:Wait()
				end
			end

			if not Nyx_forestBaitCarried then
				self:_setStatus("Failed to carry Forest bait egg")
				Nyx_resetRagdollState()

				return false
			end

			self:_setStatus("Moving to Forest Guard")

			local Nyx_findForestBaitEgg_var5, Nyx_findForestBaitEgg_var6 = Nyx_findForestGuard()
			local Position2, Nyx_forestHitConfirmed, Nyx_forestGuardConnections

			if Nyx_findForestBaitEgg_var5 then
				if not Nyx_findForestBaitEgg_var5:FindFirstChild("Collider") then
				end

				Position2 = Nyx_findForestBaitEgg_var6 and Nyx_findForestBaitEgg_var6.Position or Vector3.new(596.6, 69.4, -317.1)
				HumanoidRootPart.CFrame = cFrameNew(Position2.X, Position2.Y + 0.8, Position2.Z)
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				Nyx_forestHitConfirmed = false
				Nyx_forestGuardConnections = {}
			else
				Position2 = Nyx_findForestBaitEgg_var6 and Nyx_findForestBaitEgg_var6.Position or Vector3.new(596.6, 69.4, -317.1)
				HumanoidRootPart.CFrame = cFrameNew(Position2.X, Position2.Y + 0.8, Position2.Z)
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				Nyx_forestHitConfirmed = false
				Nyx_forestGuardConnections = {}
			end

			pcall(function()
				local RERigSyncRefresh = ReplicatedStorage2:FindFirstChild("Packages") and ReplicatedStorage2.Packages:FindFirstChild("Networking") and ReplicatedStorage2.Packages.Networking:FindFirstChild("RE/RigSync/Refresh")

				if RERigSyncRefresh then
					table.insert(Nyx_forestGuardConnections, RERigSyncRefresh.OnClientEvent:Connect(function()
						Nyx_forestHitConfirmed = true
					end))
				end
			end)
			pcall(function()
				local Remotes = require(ReplicatedStorage2.Shared.Remotes)

				if Remotes and Remotes.EggWorld and Remotes.EggWorld.OwnerDropped then
					table.insert(Nyx_forestGuardConnections, Remotes.EggWorld.OwnerDropped.OnClientEvent:Connect(function()
						Nyx_forestHitConfirmed = true
					end))
				end
			end)
			table.insert(Nyx_forestGuardConnections, Humanoid.StateChanged:Connect(function(old, new)
				if new == Enum.HumanoidStateType.Ragdoll or new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.PlatformStanding then
					Nyx_forestHitConfirmed = true
				end
			end))
			table.insert(Nyx_forestGuardConnections, Humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
				if Humanoid.PlatformStand then
					Nyx_forestHitConfirmed = true
				end
			end))

			local function Nyx_triggerForestHit()
				local Nyx_forestGuardModelNow, Nyx_forestGuardRootNow = Nyx_findForestGuard()

				Nyx_findForestBaitEgg_var5 = Nyx_forestGuardModelNow
				Nyx_findForestBaitEgg_var6 = Nyx_forestGuardRootNow

				local Position3 = Nyx_findForestBaitEgg_var6 and Nyx_findForestBaitEgg_var6.Position or Position2
				local HumanoidRootPart2 = Character:FindFirstChild("HumanoidRootPart")

				if HumanoidRootPart2 then
					HumanoidRootPart2.CFrame = cFrameNew(Position3.X, Position3.Y + 0.8, Position3.Z)
					HumanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				end

				local Collider = Nyx_findForestBaitEgg_var5 and Nyx_findForestBaitEgg_var5:FindFirstChild("Collider") or Nyx_findForestBaitEgg_var6

				if Collider and type(firetouchinterest) == "function" and HumanoidRootPart2 then
					pcall(function()
						firetouchinterest(HumanoidRootPart2, Collider, 0)
						firetouchinterest(HumanoidRootPart2, Collider, 1)
					end)
				end

				pcall(function()
					local Remotes = require(ReplicatedStorage2.Shared.Remotes)

					if Remotes then
						if Remotes.GuardPatrol and Remotes.GuardPatrol.ForestStrike then
							Remotes.GuardPatrol.ForestStrike:FireServer({
								EggUid = Nyx_forestBaitEggRecord.Uid,
								GuardCFrame = Nyx_findForestBaitEgg_var6 and Nyx_findForestBaitEgg_var6.CFrame or cFrameNew(Position3)
							})
						end
					end
				end)
			end

			self:_setStatus("Triggering Forest Guard hit")
			Nyx_triggerForestHit()

			local Nyx_forestHitDeadline = os.clock() + 0.75
			local Nyx_forestRetryCheck = os.clock() + 0.05

			while os.clock() < Nyx_forestHitDeadline and not Nyx_forestHitConfirmed do
				local Humanoid2 = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChildOfClass("Humanoid")

				if Humanoid2 and (Humanoid2.PlatformStand or Humanoid2.Sit) then
					Nyx_forestHitConfirmed = true

					break
				end

				local HumanoidRootPart2 = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if HumanoidRootPart2 and HumanoidRootPart2.AssemblyLinearVelocity.Magnitude > 18 then
					Nyx_forestHitConfirmed = true

					break
				else
					if HumanoidRootPart2 and HumanoidRootPart2.Position.Y < 65 then
						HumanoidRootPart2.CFrame = cFrameNew(Position2.X, 70, Position2.Z)
						HumanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
					end

					if Nyx_forestRetryCheck <= os.clock() then
						Nyx_forestRetryCheck = os.clock() + 0.05
						Nyx_triggerForestHit()
					end

					RunService.Heartbeat:Wait()
				end
			end

			for _, v in ipairs(Nyx_forestGuardConnections) do
				pcall(v.Disconnect, v)
			end

			if not Nyx_forestHitConfirmed then
				self:_setStatus("Forest Guard hit timed out")
				Nyx_resetRagdollState()

				return false, Nyx_forestBaitEggRecord.Uid
			end

			self:_setStatus("Recovering posture")
			Nyx_resetRagdollState()

			local Nyx_forestRecoverDeadline = os.clock() + 0.35

			while os.clock() < Nyx_forestRecoverDeadline do
				local Humanoid2 = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChildOfClass("Humanoid")
				local HumanoidRootPart2 = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if not Humanoid2 or not HumanoidRootPart2 or Humanoid2.PlatformStand or Humanoid2.Sit then
					Nyx_resetRagdollState()
					RunService.Heartbeat:Wait()
				else
					local state = Humanoid2:GetState()

					if state ~= Enum.HumanoidStateType.Ragdoll and state ~= Enum.HumanoidStateType.FallingDown and state ~= Enum.HumanoidStateType.PlatformStanding then
						HumanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
						HumanoidRootPart2.AssemblyAngularVelocity = Vector3.zero

						break
					end

					Nyx_resetRagdollState()
					RunService.Heartbeat:Wait()
				end
			end

			return true, Nyx_forestBaitEggRecord.Uid
		end
		Nyx_PlayerSteal._swingBatAt = function(self, targetPlayer, batTool)
			if not batTool or batTool.Parent ~= LocalPlayer2.Character then
				return false
			end

			self.swingSeq += 1

			local Nyx_batSwingSignature = string.format("%d:%d:%d", LocalPlayer2.UserId, self.swingSeq, math.floor(workspace:GetServerTimeNow() * 1000))

			local function Nyx_fireBatSwing()
				require(ReplicatedStorage2.Shared.Remotes).BatSwing.Trigger:FireServer(targetPlayer, Nyx_batSwingSignature)
			end

			return pcall(Nyx_fireBatSwing)
		end
		Nyx_PlayerSteal._returnSafe = function(self)
			local eggRuntime = self.eggRuntime
			local Character = LocalPlayer2.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			if not eggRuntime or not HumanoidRootPart or not Humanoid or eggRuntime:_isInSafeArea(HumanoidRootPart) then
				return
			end

			local Nyx_strikeReturnCF = eggRuntime:_resolveSafeCFrame(HumanoidRootPart)

			if not Nyx_strikeReturnCF then
				return
			end

			self:_setStatus("Returning to safe zone")
			Nyx_glideTo(HumanoidRootPart, Humanoid, Nyx_strikeReturnCF, function()
				return Humanoid.Health <= 0 or not HumanoidRootPart.Parent
			end, false, nil, true)
		end
		Nyx_PlayerSteal.intercept = function(self, targetUid)
			if self.running then
				return false
			end

			local HumanoidRootPart = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart then
				return false
			end

			for _, v in ipairs(self:carriers()) do
				if v.record.Uid == targetUid then
					if v.root.Position.X <= 552.2 or (v.root.Position - HumanoidRootPart.Position).Magnitude > 80 then
						return false
					end

					self.forced = true
					task.spawn(self._chase, self, v, true)

					return self.running
				end
			end

			return false
		end

		local Nyx_fireBatSwing_var1 = "_chase"

		local function Nyx_chasePlayer(self, carrier, instant)
			if self.running then
				return
			end

			self.running = true
			self.attempts += 1

			local record = carrier.record
			local Uid = record.Uid
			local Nyx_chaseResolvedEgg = self.catalog.resolve(record)
			local player = carrier.player
			local DisplayName = player.DisplayName or player.Name

			if self.godMode then
				self.godMode:stopDefend()
			end

			if not instant then
				self:_returnSafe()
				self:_setStatus(string.format("Priming at Forest Guard for %s", DisplayName))

				local ok, result, result2 = pcall(self._primeForest, self, Uid)
				local Nyx_chasePlayer_var5

				if ok and not result and result2 then
					pcall(function()
						Nyx_chasePlayer_var5 = EggState2.ReadFieldEgg(result2)
					end)
				end

				if Nyx_chasePlayer_var5 and Nyx_chasePlayer_var5.State == "Carried" and Nyx_chasePlayer_var5.CarrierUserId == LocalPlayer2.UserId then
					self:_returnSafe()
					self:_log(DisplayName, Nyx_chaseResolvedEgg.name, "Forest priming failed")
					self:_setStatus(self.enabled and "looking for a carrier" or "idle")
					self.running = false
					self.forced = false

					return
				end
			end

			local godMode = self.godMode and self.godMode:_equipBat()
			local Nyx_chaseDeadline = os.clock() + (instant and 8 or 16)
			local Nyx_outcome = "could not catch them"
			local Nyx_chasePlayer_var1 = 0
			local Nyx_chasePlayer_var2 = 0
			local now
			local Nyx_chasePrevCooldown
			local now2
			local Nyx_positionHistory = {}
			local vector32 = Vector3.zero
			local attribute = player:GetAttribute("RagdollEndTime") or false
			local Nyx_chasePlayer_var3 = 0.1

			pcall(function()
				Nyx_chasePlayer_var3 = math.clamp(LocalPlayer2:GetNetworkPing() or 0.1, 0.03, 0.6)
			end)

			local Nyx_chaseLeadTime = math.clamp(0.14 + Nyx_chasePlayer_var3, 0.14, 0.35)
			local hitIdx = self.hitIdx or self.leadIdx

			self.leadIdx = hitIdx or 1
			self.missStreak = 0

			local connection

			pcall(function()
				connection = RunService.Stepped:Connect(function()
					local Character = LocalPlayer2.Character

					if Character then
						for _, descendant in ipairs(Character:GetDescendants()) do
							if descendant:IsA("BasePart") then
								descendant.CanCollide = false
							end
						end
					end
				end)
			end)
			self:_setStatus(string.format("Chasing %s", DisplayName))

			while os.clock() < Nyx_chaseDeadline do
				local result = RunService.PreSimulation:Wait()

				if not self.enabled and not self.forced then
					Nyx_outcome = "stopped"

					break
				end

				local Nyx_chasePlayer_var6

				pcall(function()
					Nyx_chasePlayer_var6 = EggState2.ReadFieldEgg(Uid)
				end)

				local State = Nyx_chasePlayer_var6 and Nyx_chasePlayer_var6.State

				if not Nyx_chasePlayer_var6 or State == "Slot" or State == "GuardCarried" then
					Nyx_outcome = "egg reset"

					break
				end

				if State == "Claimed" then
					Nyx_outcome = "they banked it"

					break
				end

				if State == "Carried" and Nyx_chasePlayer_var6.CarrierUserId == LocalPlayer2.UserId then
					Nyx_outcome = "taken"

					break
				end

				if State == "Dropped" then
					if now and os.clock() - now <= 1 then
						self.hitIdx = self.leadIdx
					end

					self:_setStatus(string.format("Grabbing dropped egg from %s", DisplayName))
					Nyx_outcome = self:_grab(Nyx_chasePlayer_var6) and "taken" or "someone else grabbed it"

					break
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then
					Nyx_outcome = "character died"

					break
				end

				local HumanoidRootPart2, now3, Nyx_chaseTrackIndex, AssemblyLinearVelocity, vector33, Magnitude, LookVector, vector34, Unit, Unit2, clamp, Nyx_chaseLeadMultiplier, Nyx_chaseTargetPos, vector35, cFrame, Nyx_chaseDelta, Magnitude2, Nyx_chaseSpeed, Nyx_chaseStepDist, Nyx_chaseVelocity, Nyx_chaseNearThreshold, attribute2, Nyx_chaseCooldownEnd

				if Nyx_chasePlayer_var6.CarrierUserId == player.UserId then
					HumanoidRootPart2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

					if not HumanoidRootPart2 then
						Nyx_outcome = "lost sight of them"

						break
					end

					if HumanoidRootPart2.Position.X <= 552.2 then
						Nyx_outcome = "banked"

						break
					end

					now3 = os.clock()
					Nyx_chaseTrackIndex = #Nyx_positionHistory + 1
					Nyx_positionHistory[Nyx_chaseTrackIndex] = {
						t = now3,
						p = HumanoidRootPart2.Position
					}

					while #Nyx_positionHistory > 2 and now3 - Nyx_positionHistory[1].t > 0.4 do
						table.remove(Nyx_positionHistory, 1)
					end

					AssemblyLinearVelocity = HumanoidRootPart2.AssemblyLinearVelocity

					if Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude > 8 then
						vector32 = AssemblyLinearVelocity
					elseif #Nyx_positionHistory >= 2 and now3 - Nyx_positionHistory[1].t > 0.15 then
						vector32 = (HumanoidRootPart2.Position - Nyx_positionHistory[1].p) / (now3 - Nyx_positionHistory[1].t)
					end

					vector33 = Vector3.new(vector32.X, 0, vector32.Z)
					Magnitude = vector33.Magnitude

					if Magnitude > 6 then
						Unit2 = vector33.Unit
					else
						LookVector = HumanoidRootPart2.CFrame.LookVector
						vector34 = Vector3.new(LookVector.X, 0, LookVector.Z)
						Unit = vector34.Magnitude > 0.05 and vector34.Unit or Vector3.new(-1, 0, 0)
						Unit2 = Unit
					end

					clamp = math.clamp
					Nyx_chaseLeadMultiplier = Nyx_chaseLeads[self.leadIdx] or 1
					Nyx_chaseTargetPos = HumanoidRootPart2.Position + Unit2 * clamp(Nyx_chaseLeadMultiplier * Magnitude * Nyx_chaseLeadTime, 3, 110)

					if Nyx_chaseTargetPos.X < 557.2 then
						Nyx_chaseTargetPos = Vector3.new(557.2, Nyx_chaseTargetPos.Y, Nyx_chaseTargetPos.Z)
					end

					vector35 = Vector3.new(HumanoidRootPart2.Position.X, Nyx_chaseTargetPos.Y, HumanoidRootPart2.Position.Z)

					if (vector35 - Nyx_chaseTargetPos).Magnitude < 0.5 then
						vector35 = Nyx_chaseTargetPos - Unit2
					end

					cFrame = lookAt(Nyx_chaseTargetPos, vector35)
					Nyx_chaseDelta = Nyx_chaseTargetPos - HumanoidRootPart.Position
					Magnitude2 = Nyx_chaseDelta.Magnitude
					Nyx_chaseSpeed = Nyx_getTweenSpeed()
					Nyx_chaseStepDist = Nyx_chaseSpeed * math.min(result, 0.05)
					Nyx_setTargetWalkSpeed(Character, Nyx_chaseSpeed * Nyx_CONFIG.HEADROOM)

					if Nyx_chaseStepDist < Magnitude2 then
						HumanoidRootPart.CFrame = cFrameNew(HumanoidRootPart.Position + Nyx_chaseDelta.Unit * Nyx_chaseStepDist) * cFrame.Rotation
						HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						Nyx_chaseVelocity = Nyx_chaseDelta.Unit * Nyx_chaseSpeed
					else
						HumanoidRootPart.CFrame = cFrame
						HumanoidRootPart.AssemblyLinearVelocity = HumanoidRootPart2.AssemblyLinearVelocity
						Nyx_chaseVelocity = HumanoidRootPart2.AssemblyLinearVelocity
					end

					HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

					if not Nyx_updateIntegritySpoof(Humanoid, HumanoidRootPart, Nyx_chaseSpeed, Nyx_chaseVelocity) then
						Nyx_installIntegritySpoof(Humanoid, HumanoidRootPart, Nyx_chaseSpeed)
						Nyx_updateIntegritySpoof(Humanoid, HumanoidRootPart, Nyx_chaseSpeed, Nyx_chaseVelocity)
					end

					Nyx_chaseNearThreshold = Magnitude * result * 1.5

					if not (Magnitude2 <= 5 + Nyx_chaseNearThreshold) then
						if 12 + Nyx_chaseNearThreshold < Magnitude2 and now2 then
							now2 = nil
							self:_setStatus(string.format("Chasing %s", DisplayName))
						end
					elseif not now2 then
						now2 = os.clock()
						self:_setStatus(string.format("Attacking %s", DisplayName))
					end

					attribute2 = player:GetAttribute("RagdollEndTime") or false

					if attribute2 ~= attribute then
						attribute = attribute2
						self.hitIdx = self.leadIdx
						self.missStreak = 0
						now = nil
					end

					if (not godMode or godMode.Parent ~= Character) and Nyx_chasePlayer_var2 <= os.clock() then
						Nyx_chasePlayer_var2 = os.clock() + 0.5
						task.spawn(function()
							godMode = self.godMode and self.godMode:_equipBat() or godMode
						end)
					end

					Nyx_chaseCooldownEnd = godMode and tonumber(godMode:GetAttribute("CooldownEndTime")) or 0

					if now and os.clock() - now > 0.9 then
						if Nyx_chaseCooldownEnd ~= Nyx_chasePrevCooldown then
							self.missStreak += 1

							if self.missStreak >= 2 then
								self.missStreak = 0
								self.leadIdx = self.leadIdx % #Nyx_chaseLeads + 1
								now2 = nil
							end
						end

						now = nil
					end

					if godMode and godMode.Parent == Character and now2 and Nyx_chaseLeadTime + 0.05 <= os.clock() - now2 and godMode:GetAttribute("CooldownActive") ~= true and Nyx_chaseCooldownEnd <= workspace:GetServerTimeNow() and os.clock() - Nyx_chasePlayer_var1 >= 0.35 then
						Nyx_chasePlayer_var1 = os.clock()

						if not now then
							now = os.clock()
							Nyx_chasePrevCooldown = Nyx_chaseCooldownEnd
						end

						task.spawn(self._swingBatAt, self, player, godMode)
					end
				else
					local playerByUserId = Players2:GetPlayerByUserId(Nyx_chasePlayer_var6.CarrierUserId or 0)

					if not playerByUserId then
						Nyx_outcome = "taken by another player"

						break
					end

					player = playerByUserId
					DisplayName = player.DisplayName or player.Name
					attribute = player:GetAttribute("RagdollEndTime") or false
					now2 = nil
					now = nil
					table.clear(Nyx_positionHistory)
					self:_setStatus(string.format("Chasing %s", DisplayName))
					HumanoidRootPart2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

					if not HumanoidRootPart2 then
						Nyx_outcome = "lost sight of them"

						break
					end

					if HumanoidRootPart2.Position.X <= 552.2 then
						Nyx_outcome = "banked"

						break
					end

					now3 = os.clock()
					Nyx_chaseTrackIndex = #Nyx_positionHistory + 1
					Nyx_positionHistory[Nyx_chaseTrackIndex] = {
						t = now3,
						p = HumanoidRootPart2.Position
					}

					while #Nyx_positionHistory > 2 and now3 - Nyx_positionHistory[1].t > 0.4 do
						table.remove(Nyx_positionHistory, 1)
					end

					AssemblyLinearVelocity = HumanoidRootPart2.AssemblyLinearVelocity

					if Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude > 8 then
						vector32 = AssemblyLinearVelocity
					elseif #Nyx_positionHistory >= 2 and now3 - Nyx_positionHistory[1].t > 0.15 then
						vector32 = (HumanoidRootPart2.Position - Nyx_positionHistory[1].p) / (now3 - Nyx_positionHistory[1].t)
					end

					vector33 = Vector3.new(vector32.X, 0, vector32.Z)
					Magnitude = vector33.Magnitude

					if Magnitude > 6 then
						Unit2 = vector33.Unit
					else
						LookVector = HumanoidRootPart2.CFrame.LookVector
						vector34 = Vector3.new(LookVector.X, 0, LookVector.Z)
						Unit = vector34.Magnitude > 0.05 and vector34.Unit or Vector3.new(-1, 0, 0)
						Unit2 = Unit
					end

					clamp = math.clamp
					Nyx_chaseLeadMultiplier = Nyx_chaseLeads[self.leadIdx] or 1
					Nyx_chaseTargetPos = HumanoidRootPart2.Position + Unit2 * clamp(Nyx_chaseLeadMultiplier * Magnitude * Nyx_chaseLeadTime, 3, 110)

					if Nyx_chaseTargetPos.X < 557.2 then
						Nyx_chaseTargetPos = Vector3.new(557.2, Nyx_chaseTargetPos.Y, Nyx_chaseTargetPos.Z)
					end

					vector35 = Vector3.new(HumanoidRootPart2.Position.X, Nyx_chaseTargetPos.Y, HumanoidRootPart2.Position.Z)

					if (vector35 - Nyx_chaseTargetPos).Magnitude < 0.5 then
						vector35 = Nyx_chaseTargetPos - Unit2
					end

					cFrame = lookAt(Nyx_chaseTargetPos, vector35)
					Nyx_chaseDelta = Nyx_chaseTargetPos - HumanoidRootPart.Position
					Magnitude2 = Nyx_chaseDelta.Magnitude
					Nyx_chaseSpeed = Nyx_getTweenSpeed()
					Nyx_chaseStepDist = Nyx_chaseSpeed * math.min(result, 0.05)
					Nyx_setTargetWalkSpeed(Character, Nyx_chaseSpeed * Nyx_CONFIG.HEADROOM)

					if Nyx_chaseStepDist < Magnitude2 then
						HumanoidRootPart.CFrame = cFrameNew(HumanoidRootPart.Position + Nyx_chaseDelta.Unit * Nyx_chaseStepDist) * cFrame.Rotation
						HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						Nyx_chaseVelocity = Nyx_chaseDelta.Unit * Nyx_chaseSpeed
					else
						HumanoidRootPart.CFrame = cFrame
						HumanoidRootPart.AssemblyLinearVelocity = HumanoidRootPart2.AssemblyLinearVelocity
						Nyx_chaseVelocity = HumanoidRootPart2.AssemblyLinearVelocity
					end

					HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

					if not Nyx_updateIntegritySpoof(Humanoid, HumanoidRootPart, Nyx_chaseSpeed, Nyx_chaseVelocity) then
						Nyx_installIntegritySpoof(Humanoid, HumanoidRootPart, Nyx_chaseSpeed)
						Nyx_updateIntegritySpoof(Humanoid, HumanoidRootPart, Nyx_chaseSpeed, Nyx_chaseVelocity)
					end

					Nyx_chaseNearThreshold = Magnitude * result * 1.5

					if not (Magnitude2 <= 5 + Nyx_chaseNearThreshold) then
						if 12 + Nyx_chaseNearThreshold < Magnitude2 and now2 then
							now2 = nil
							self:_setStatus(string.format("Chasing %s", DisplayName))
						end
					elseif not now2 then
						now2 = os.clock()
						self:_setStatus(string.format("Attacking %s", DisplayName))
					end

					attribute2 = player:GetAttribute("RagdollEndTime") or false

					if attribute2 ~= attribute then
						attribute = attribute2
						self.hitIdx = self.leadIdx
						self.missStreak = 0
						now = nil
					end

					if (not godMode or godMode.Parent ~= Character) and Nyx_chasePlayer_var2 <= os.clock() then
						Nyx_chasePlayer_var2 = os.clock() + 0.5
						task.spawn(function()
							godMode = self.godMode and self.godMode:_equipBat() or godMode
						end)
					end

					Nyx_chaseCooldownEnd = godMode and tonumber(godMode:GetAttribute("CooldownEndTime")) or 0

					if now and os.clock() - now > 0.9 then
						if Nyx_chaseCooldownEnd ~= Nyx_chasePrevCooldown then
							self.missStreak += 1

							if self.missStreak >= 2 then
								self.missStreak = 0
								self.leadIdx = self.leadIdx % #Nyx_chaseLeads + 1
								now2 = nil
							end
						end

						now = nil
					end

					if godMode and godMode.Parent == Character and now2 and Nyx_chaseLeadTime + 0.05 <= os.clock() - now2 and godMode:GetAttribute("CooldownActive") ~= true and Nyx_chaseCooldownEnd <= workspace:GetServerTimeNow() and os.clock() - Nyx_chasePlayer_var1 >= 0.35 then
						Nyx_chasePlayer_var1 = os.clock()

						if not now then
							now = os.clock()
							Nyx_chasePrevCooldown = Nyx_chaseCooldownEnd
						end

						task.spawn(self._swingBatAt, self, player, godMode)
					end
				end
			end

			if connection then
				pcall(function()
					connection:Disconnect()
				end)
			end

			if Nyx_outcome == "taken" then
				self.taken += 1
				pcall(function()
					local Humanoid = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChildOfClass("Humanoid")

					if Humanoid then
						Humanoid:UnequipTools()
					end
				end)
			else
				self.blacklist[Uid] = os.clock() + 20
			end

			self:_returnSafe()
			self:_log(DisplayName, Nyx_chaseResolvedEgg.name, Nyx_outcome)
			self:_setStatus(self.enabled and "looking for a carrier" or "idle")
			self.running = false
			self.forced = false
		end

		Nyx_PlayerSteal[Nyx_fireBatSwing_var1] = Nyx_chasePlayer
		Nyx_PlayerSteal._grab = function(self, record)
			local eggRuntime = self.eggRuntime
			local Uid = record.Uid
			local Nyx_grabDeadline = os.clock() + 3
			local Nyx_chasePlayer_var4 = 0

			while true do
				if not (os.clock() < Nyx_grabDeadline) then
					return false
				end

				local Nyx_chasePlayer_var7

				pcall(function()
					Nyx_chasePlayer_var7 = EggState2.ReadFieldEgg(Uid)
				end)

				local State = Nyx_chasePlayer_var7 and Nyx_chasePlayer_var7.State

				if State == "Carried" then
					if Nyx_chasePlayer_var7.CarrierUserId ~= LocalPlayer2.UserId then
						return false
					end

					if genv.__NyxWebhook then
						local ok, result = pcall(self.catalog.resolve, Nyx_chasePlayer_var7)

						pcall(genv.__NyxWebhook.stolen, Nyx_chasePlayer_var7, ok and result or nil, "player carry")
					end

					return true
				end

				if State ~= "Dropped" then
					return false
				end

				local Character = LocalPlayer2.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then
					break
				end

				local cFrame = eggRuntime and eggRuntime:_resolveEggDestination(Nyx_chasePlayer_var7, HumanoidRootPart, Humanoid)

				if not cFrame then
					local Position = Nyx_chasePlayer_var7.BottomCFrame and Nyx_chasePlayer_var7.BottomCFrame.Position or Nyx_chasePlayer_var7.BoundsCFrame and Nyx_chasePlayer_var7.BoundsCFrame.Position

					cFrame = Position and cFrameNew(Position.X, Position.Y + 2.5, Position.Z)
				end

				if cFrame then
					HumanoidRootPart.CFrame = cFrame
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end

				if Nyx_chasePlayer_var4 <= os.clock() then
					Nyx_chasePlayer_var4 = os.clock() + 0.1
					task.spawn(function()
						pcall(function()
							EggState2.CarryFieldEgg(Uid)
						end)
					end)
					task.spawn(function()
						pcall(function()
							require(ReplicatedStorage2.Shared.Remotes).EggWorld.AskFieldEggCarry:InvokeServer({
								Uid = Uid
							})
						end)
					end)
				end

				RunService.Heartbeat:Wait()
			end

			return false
		end
		Nyx_PlayerSteal._start = function(self)
			if self.loop then
				return
			end

			self.loop = task.spawn(function()
				while true do
					task.wait(0.4)

					if genv.ChloeX_Running == nil and genv.__NyxPlayerSteal ~= self then
						break
					end

					for k, v in pairs(self.blacklist) do
						if v < os.clock() then
							self.blacklist[k] = nil
						end
					end

					local eggRuntime = self.eggRuntime
					local __NyxScrambleRuntime = genv.__NyxScrambleRuntime

					if self.enabled and not self.running and (not eggRuntime or not eggRuntime.running and (not eggRuntime.carry or not eggRuntime.carry.active)) and (__NyxScrambleRuntime == nil or __NyxScrambleRuntime.active ~= true) then
						local Nyx_loopTargetPlayer = self:_pick()

						if Nyx_loopTargetPlayer then
							self:_chase(Nyx_loopTargetPlayer)
						end
					end
				end

				self.loop = nil
			end)
		end

		return Nyx_PlayerSteal
	end

	local Nyx_playerStealClassDef = Nyx_passes_var1()

	Nyx_antiGuard = Nyx_AntiGuardClass.new(Nyx_eggRuntime)
	Nyx_antiGuard:install()
	Nyx_antiGuard:setEnabled(NyxConfig.AntiGuardKnockback == true)
	genv.__NyxAntiGuard = Nyx_antiGuard
	Nyx_godMode = Nyx_GodModeClass_var1.new(Nyx_eggRuntime)
	Nyx_godMode:setEnabled(NyxConfig.GodMode == nil and true or NyxConfig.GodMode == true)
	genv.__NyxGodMode = Nyx_godMode

	local Nyx_playerStealInstance = Nyx_playerStealClassDef.new(Nyx_eggRuntime, Nyx_godMode, Nyx_catalog)

	local function Nyx_movementExtrasFactory()
		local Players2 = game:GetService("Players")
		local RunService2 = game:GetService("RunService")
		local UserInputService = game:GetService("UserInputService")
		local LocalPlayer2 = Players2.LocalPlayer
		local Nyx_MovementExtras = {}

		Nyx_MovementExtras.__index = Nyx_MovementExtras
		Nyx_MovementExtras.new = function()
			local obj = setmetatable({}, Nyx_MovementExtras)

			obj.flyEnabled = false
			obj.flyConnection = nil
			obj.flyMover = nil
			obj.grabEnabled = false
			obj.grabConnection = nil
			obj.grabOriginals = setmetatable({}, {
				__mode = "k"
			})
			obj.jumpEnabled = false
			obj.jumpConnections = {}
			obj.lastJumpAt = 0
			obj.speedMultiplier = 1
			obj.speedModules = nil
			obj.speedConnection = nil

			return obj
		end
		Nyx_MovementExtras._root = function()
			local Character = LocalPlayer2.Character

			return Character and Character:FindFirstChild("HumanoidRootPart")
		end
		Nyx_MovementExtras._humanoid = function()
			local Character = LocalPlayer2.Character

			return Character and Character:FindFirstChildOfClass("Humanoid")
		end
		Nyx_MovementExtras._ensureMover = function(self, rootPart)
			if self.flyMover and self.flyMover.Parent == rootPart then
				return
			end

			if self.flyMover then
				pcall(function()
					self.flyMover:Destroy()
				end)
			end

			local BodyVelocity = Instance.new("BodyVelocity")

			BodyVelocity.Name = "NyxFlyCaptureHover"
			BodyVelocity.MaxForce = Vector3.new(0, 9e9, 0)
			BodyVelocity.Velocity = Vector3.zero
			BodyVelocity.Parent = rootPart
			self.flyMover = BodyVelocity
		end

		local function Nyx_isTreadmillIdleFarm()
			local __NyxTreadmillManager = genv.__NyxTreadmillManager

			return __NyxTreadmillManager ~= nil and not __NyxTreadmillManager.destroyed and __NyxTreadmillManager.config ~= nil and __NyxTreadmillManager.config.idleFarm == true
		end

		local Nyx_flyCaptureCache = {
			at = 0,
			value = false
		}

		local function Nyx_isHoldingCaptureEgg()
			local now = os.clock()

			if now - Nyx_flyCaptureCache.at < 0.25 then
				return Nyx_flyCaptureCache.value
			end

			Nyx_flyCaptureCache.at = now

			local value = false

			pcall(function()
				local EggState2 = require(game:GetService("ReplicatedStorage").Client.EggState)
				local GetAreaEggSnapshot = EggState2.GetAreaEggSnapshot and EggState2.GetAreaEggSnapshot()

				if (not GetAreaEggSnapshot or not GetAreaEggSnapshot.Records) and EggState2.ReadFieldEggs then
					GetAreaEggSnapshot = EggState2.ReadFieldEggs()
				end

				local ipairs_ = ipairs
				local Records = GetAreaEggSnapshot and GetAreaEggSnapshot.Records or {}

				for _, Record in ipairs_(Records) do
					if Record.State == "Carried" and Record.CarrierUserId == LocalPlayer2.UserId then
						value = true

						break
					end
				end
			end)
			Nyx_flyCaptureCache.value = value

			return value
		end

		Nyx_MovementExtras._dropMover = function(self, rootPart)
			if self.flyMover then
				pcall(function()
					self.flyMover:Destroy()
				end)
				self.flyMover = nil
			end

			local NyxFlyCaptureHover = rootPart and rootPart:FindFirstChild("NyxFlyCaptureHover")

			if NyxFlyCaptureHover then
				pcall(function()
					NyxFlyCaptureHover:Destroy()
				end)
			end
		end
		Nyx_MovementExtras.setFlyForCapture = function(self, enabled)
			self.flyEnabled = enabled == true

			if self.flyEnabled then
				if not self.flyConnection then
					self.flyAnchored = false
					self.flyConnection = RunService2.PreSimulation:Connect(function()
						if not self.flyEnabled then
							return
						end

						local Nyx_flyCaptureRoot = self:_root()

						if not Nyx_flyCaptureRoot then
							return
						end

						local running = not Nyx_isHoldingCaptureEgg() or Nyx_isTreadmillIdleFarm() or next(Nyx_activeTweens) ~= nil or Nyx_eggRuntime and (Nyx_eggRuntime.running or Nyx_eggRuntime.activeTween)

						if not running then
							local __NyxPlayerSteal = genv.__NyxPlayerSteal

							if __NyxPlayerSteal and __NyxPlayerSteal.running then
								running = true
							end
						end

						if running then
							if self.flyAnchored then
								pcall(function()
									Nyx_flyCaptureRoot.Anchored = false
								end)
								self.flyAnchored = false
							end

							return
						end

						if Nyx_flyCaptureRoot.Position.Y < 109 then
							if self.flyAnchored then
								pcall(function()
									Nyx_flyCaptureRoot.Anchored = false
								end)
								self.flyAnchored = false
							end

							Nyx_flyCaptureRoot.CFrame = cFrameNew(Nyx_flyCaptureRoot.Position.X, Nyx_flyCaptureRoot.Position.Y + math.min(110 - Nyx_flyCaptureRoot.Position.Y, 4), Nyx_flyCaptureRoot.Position.Z) * Nyx_flyCaptureRoot.CFrame.Rotation
							Nyx_flyCaptureRoot.AssemblyLinearVelocity = Vector3.zero
							Nyx_flyCaptureRoot.AssemblyAngularVelocity = Vector3.zero
						elseif Nyx_flyCaptureRoot.Anchored then
							self.flyAnchored = true
						else
							pcall(function()
								Nyx_flyCaptureRoot.Anchored = true
							end)
							self.flyAnchored = true
						end
					end)

					return
				end

				return
			end

			if self.flyConnection then
				pcall(function()
					self.flyConnection:Disconnect()
				end)
				self.flyConnection = nil
			end

			if self.flyMover then
				pcall(function()
					self.flyMover:Destroy()
				end)
				self.flyMover = nil
			end

			local Nyx_flyCaptureRoot2 = self:_root()

			if Nyx_flyCaptureRoot2 then
				local NyxFlyCaptureHover = Nyx_flyCaptureRoot2:FindFirstChild("NyxFlyCaptureHover")

				if NyxFlyCaptureHover then
					pcall(function()
						NyxFlyCaptureHover:Destroy()
					end)
				end

				if self.flyAnchored then
					pcall(function()
						Nyx_flyCaptureRoot2.Anchored = false
					end)
				end
			end

			self.flyAnchored = false
		end
		Nyx_MovementExtras._isGrabPrompt = function(self, prompt)
			return prompt:IsA("ProximityPrompt") and prompt.Name == "CarryAreaEgg"
		end
		Nyx_MovementExtras._applyGrab = function(self, prompt)
			if not self:_isGrabPrompt(prompt) then
				return
			end

			if self.grabOriginals[prompt] == nil then
				self.grabOriginals[prompt] = prompt.HoldDuration
			end

			if prompt.HoldDuration > 0.1 then
				prompt.HoldDuration = 0.1
			end
		end
		Nyx_MovementExtras._restoreGrab = function(self)
			local Nyx_grabHoldDuration = workspace:GetAttribute("FastEggPickupTime") and 0.25 or 1.2

			for k, grabOriginal in pairs(self.grabOriginals) do
				pcall(function()
					if k.Parent then
						k.HoldDuration = tonumber(grabOriginal) and grabOriginal > 0.1 and grabOriginal or Nyx_grabHoldDuration
					end
				end)
			end

			self.grabOriginals = setmetatable({}, {
				__mode = "k"
			})
		end
		Nyx_MovementExtras._fireGrab = function(self, prompt)
			if not self:_isGrabPrompt(prompt) or not prompt.Enabled then
				return
			end

			self.grabFiring = self.grabFiring or setmetatable({}, {
				__mode = "k"
			})

			if self.grabFiring[prompt] then
				return
			end

			local Parent = prompt.Parent
			local Nyx_grabRootPart = self:_root()

			if not Nyx_grabRootPart or not Parent or not Parent:IsA("BasePart") then
				return
			end

			if (tonumber(prompt.MaxActivationDistance) or 10) + 1 < (Parent.Position - Nyx_grabRootPart.Position).Magnitude then
				return
			end

			self.grabFiring[prompt] = true
			task.spawn(function()
				pcall(function()
					local Nyx_grabHoldTime = math.max(0.1, tonumber(prompt.HoldDuration) or 0.1)

					prompt:InputHoldBegin()
					task.wait(Nyx_grabHoldTime + 0.05)
					prompt:InputHoldEnd()
				end)
				task.wait(0.4)

				if self.grabFiring then
					self.grabFiring[prompt] = nil
				end
			end)
		end
		Nyx_MovementExtras.setInstantGrab = function(self, enabled)
			self.grabEnabled = enabled == true

			if self.grabEnabled then
				for _, descendant in ipairs(workspace:GetDescendants()) do
					self:_applyGrab(descendant)
				end

				if not self.grabConnection then
					self.grabConnection = workspace.DescendantAdded:Connect(function(descendant)
						if self.grabEnabled then
							if self:_isGrabPrompt(descendant) then
								task.defer(function()
									self:_applyGrab(descendant)
								end)
							end
						end
					end)
				end
			else
				if self.grabConnection then
					pcall(function()
						self.grabConnection:Disconnect()
					end)
					self.grabConnection = nil
				end

				self.grabFireLoop = nil
				self:_restoreGrab()
			end
		end
		Nyx_MovementExtras.triggerJump = function(self)
			if not self.jumpEnabled then
				return
			end

			local now = os.clock()

			if now - self.lastJumpAt < 0.08 then
				return
			end

			local Nyx_jumpHumanoid = self:_humanoid()
			local Nyx_jumpRoot = self:_root()

			if not Nyx_jumpHumanoid or not Nyx_jumpRoot or Nyx_jumpHumanoid.Health <= 0 then
				return
			end

			self.lastJumpAt = now
			pcall(function()
				Nyx_jumpHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				Nyx_jumpHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				Nyx_jumpHumanoid.Jump = true
			end)

			local Nyx_isHoldingCaptureEgg_var1 = 55

			if Nyx_jumpHumanoid.UseJumpPower and Nyx_jumpHumanoid.JumpPower > 0 then
				Nyx_isHoldingCaptureEgg_var1 = Nyx_jumpHumanoid.JumpPower
			elseif Nyx_jumpHumanoid.JumpHeight and Nyx_jumpHumanoid.JumpHeight > 0 then
				Nyx_isHoldingCaptureEgg_var1 = math.sqrt(2 * workspace.Gravity * Nyx_jumpHumanoid.JumpHeight)
			end

			if Nyx_isHoldingCaptureEgg_var1 < 55 then
				Nyx_isHoldingCaptureEgg_var1 = 55
			end

			pcall(function()
				local AssemblyLinearVelocity = Nyx_jumpRoot.AssemblyLinearVelocity

				Nyx_jumpRoot.AssemblyLinearVelocity = Vector3.new(AssemblyLinearVelocity.X, Nyx_isHoldingCaptureEgg_var1, AssemblyLinearVelocity.Z)
			end)
		end
		Nyx_MovementExtras.setInfiniteJump = function(self, enabled)
			self.jumpEnabled = enabled == true

			if #self.jumpConnections > 0 then
				return
			end

			pcall(function()
				table.insert(self.jumpConnections, UserInputService.InputBegan:Connect(function(input)
					if not self.jumpEnabled then
						return
					end

					if UserInputService:GetFocusedTextBox() then
						return
					end

					if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
						self:triggerJump()
					end
				end))
				table.insert(self.jumpConnections, UserInputService.JumpRequest:Connect(function()
					if not self.jumpEnabled then
						return
					end

					if UserInputService:GetFocusedTextBox() then
						return
					end

					self:triggerJump()
				end))
			end)
			task.spawn(function()
				while true do
					RunService2.Heartbeat:Wait()

					if self.jumpEnabled and not UserInputService:GetFocusedTextBox() then
						local Nyx_isHoldingCaptureEgg_var2 = false

						pcall(function()
							if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonA) then
								Nyx_isHoldingCaptureEgg_var2 = true
							end
						end)

						if Nyx_isHoldingCaptureEgg_var2 and os.clock() - self.lastJumpAt >= 0.28 then
							self:triggerJump()
						end
					end
				end
			end)
		end
		Nyx_MovementExtras._gameWalkSpeed = function(self)
			local speedModules = self.speedModules

			if not speedModules then
				speedModules = {}
				pcall(function()
					speedModules.TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
				end)
				pcall(function()
					speedModules.Projection = require(ReplicatedStorage.Client.SpeedPowerProjection)
				end)
				pcall(function()
					speedModules.Save = require(ReplicatedStorage.Shared.Save)
				end)
				self.speedModules = speedModules
			end

			if not speedModules.TreadmillUtil or not speedModules.TreadmillUtil.SpeedPowerToWalkSpeed then
				return nil
			end

			local SpeedPower

			if speedModules.Projection then
				pcall(function()
					SpeedPower = speedModules.Projection.ReadProjected()
				end)
			end

			if type(SpeedPower) ~= "number" and speedModules.Save then
				pcall(function()
					SpeedPower = (speedModules.Save.Peek or speedModules.Save.Get)().SpeedPower
				end)
			end

			if type(SpeedPower) ~= "number" then
				return nil
			end

			local ok, result = pcall(speedModules.TreadmillUtil.SpeedPowerToWalkSpeed, SpeedPower)
			local Nyx_resolvedWalkSpeed = ok and tonumber(result) or nil

			return Nyx_resolvedWalkSpeed
		end
		Nyx_MovementExtras.setSpeedMultiplier = function(self, multiplier)
			self.speedMultiplier = math.clamp(tonumber(multiplier) or 1, 1, 2.1)
			self:_applySpeedMultiplier()

			if not self.speedConnection then
				self.speedConnection = RunService2.Heartbeat:Connect(function()
					if self.speedMultiplier <= 1.001 then
						return
					end

					self:_applySpeedMultiplier()
				end)

				return
			end
		end
		Nyx_MovementExtras._applySpeedMultiplier = function(self)
			local __NyxTreadmillManager = genv.__NyxTreadmillManager

			if __NyxTreadmillManager and __NyxTreadmillManager.activeTreadmill ~= nil then
				return
			end

			local Nyx_speedMultiplierHumanoid = self:_humanoid()

			if not Nyx_speedMultiplierHumanoid then
				return
			end

			local Nyx_gameWalkSpeed = self:_gameWalkSpeed()

			if not Nyx_gameWalkSpeed or Nyx_gameWalkSpeed <= 0 then
				return
			end

			local walkSpeed = Nyx_gameWalkSpeed * self.speedMultiplier

			if math.abs(Nyx_speedMultiplierHumanoid.WalkSpeed - walkSpeed) > 0.05 then
				pcall(function()
					Nyx_speedMultiplierHumanoid.WalkSpeed = walkSpeed
				end)
			end
		end
		Nyx_MovementExtras.destroy = function(self)
			self:setFlyForCapture(false)
			self:setInstantGrab(false)
			self.jumpEnabled = false

			for _, jumpConnection in ipairs(self.jumpConnections) do
				pcall(function()
					jumpConnection:Disconnect()
				end)
			end

			self.jumpConnections = {}

			if self.speedConnection then
				pcall(function()
					self.speedConnection:Disconnect()
				end)
				self.speedConnection = nil
			end
		end

		return Nyx_MovementExtras
	end

	local Nyx_movementExtras = Nyx_movementExtrasFactory().new()

	genv.__NyxMovementExtras = Nyx_movementExtras

	if NyxConfig.FlyForCapture then
		Nyx_movementExtras:setFlyForCapture(true)
	end

	if NyxConfig.InstantGrab then
		Nyx_movementExtras:setInstantGrab(true)
	end

	if NyxConfig.InfiniteJump then
		Nyx_movementExtras:setInfiniteJump(true)
	end

	if (NyxConfig.WalkSpeedMultiplier or 1) > 1 then
		Nyx_movementExtras:setSpeedMultiplier(NyxConfig.WalkSpeedMultiplier)
	end

	local function Nyx_isHoldingCaptureEgg_var3()
		local Players2 = game:GetService("Players")
		local RunService2 = game:GetService("RunService")
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local LocalPlayer2 = Players2.LocalPlayer
		local cFrame = cFrameNew(544.76, 71.5, -416.48)
		local Nyx_v2429_var1 = {}

		Nyx_v2429_var1.__index = Nyx_v2429_var1
		Nyx_v2429_var1.new = function()
			local obj = setmetatable({}, Nyx_v2429_var1)

			obj.enabled = false
			obj.running = false
			obj.destroyed = false
			obj.connection = nil
			obj.wasHolding = false
			obj.lastResult = "Idle"

			return obj
		end
		Nyx_v2429_var1._character = function()
			return LocalPlayer2.Character
		end
		Nyx_v2429_var1._root = function(self)
			local Nyx_v2429_var2 = self:_character()

			return Nyx_v2429_var2 and Nyx_v2429_var2:FindFirstChild("HumanoidRootPart")
		end
		Nyx_v2429_var1._carriedUid = function()
			local Uid

			pcall(function()
				local EggState2 = require(ReplicatedStorage2.Client.EggState)
				local Nyx_areaEggSnapshot

				if EggState2.GetAreaEggSnapshot then
					Nyx_areaEggSnapshot = EggState2.GetAreaEggSnapshot()
				end

				if (not Nyx_areaEggSnapshot or not Nyx_areaEggSnapshot.Records) and EggState2.ReadFieldEggs then
					Nyx_areaEggSnapshot = EggState2.ReadFieldEggs()
				end

				if not Nyx_areaEggSnapshot or not Nyx_areaEggSnapshot.Records then
					return
				end

				local UserId = LocalPlayer2.UserId

				for _, record in ipairs(Nyx_areaEggSnapshot.Records) do
					if record.State == "Carried" and record.CarrierUserId == UserId then
						Uid = record.Uid

						return
					end
				end
			end)

			return Uid
		end
		Nyx_v2429_var1._record = function(self, uid)
			local ReadFieldEgg

			pcall(function()
				local EggState2 = require(ReplicatedStorage2.Client.EggState)

				ReadFieldEgg = EggState2.ReadFieldEgg and EggState2.ReadFieldEgg(uid)
			end)

			return ReadFieldEgg
		end
		Nyx_v2429_var1._guardFor = function(self, uid)
			local Guard

			pcall(function()
				local Nyx_guardAreaRecord = self:_record(uid)
				local Nyx_worldRef8 = Nyx_getWorkspaceWorld()
				local Areas = Nyx_worldRef8 and Nyx_worldRef8:FindFirstChild("Areas")
				local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
				local AreaId = GuardAreas and Nyx_guardAreaRecord and Nyx_guardAreaRecord.AreaId and GuardAreas:FindFirstChild(Nyx_guardAreaRecord.AreaId)

				Guard = AreaId and AreaId:FindFirstChild("Guard")
			end)

			return Guard
		end
		Nyx_v2429_var1._skips = function(self, uid)
			local __NyxEggRuntime = genv.__NyxEggRuntime

			if __NyxEggRuntime then
				if __NyxEggRuntime.instantPhase == "priming" then
					return true
				end

				if __NyxEggRuntime.enabled or __NyxEggRuntime.running then
					return true
				end
			end

			local __NyxPlayerSteal = genv.__NyxPlayerSteal

			if __NyxPlayerSteal and __NyxPlayerSteal.running then
				return true
			end

			if not uid then
				return false
			end

			local Nyx_guardAreaId = self:_record(uid)

			return Nyx_guardAreaId ~= nil and tostring(Nyx_guardAreaId.AreaId) == "Forest"
		end
		Nyx_v2429_var1._freeze = function(self, targetCFrame)
			local Nyx_ghostCharacter = self:_character()
			local Humanoid = Nyx_ghostCharacter and Nyx_ghostCharacter:FindFirstChildOfClass("Humanoid")
			local CurrentCamera = workspace.CurrentCamera
			local CFrame_2 = CurrentCamera and CurrentCamera.CFrame
			local CameraType = CurrentCamera and CurrentCamera.CameraType
			local clone

			pcall(function()
				Nyx_ghostCharacter.Archivable = true
				clone = Nyx_ghostCharacter:Clone()

				if targetCFrame then
					pcall(function()
						clone:PivotTo(targetCFrame)
					end)
				end

				clone.Name = "NyxAntiHitGhost"

				for _, descendant in ipairs(clone:GetDescendants()) do
					if descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") then
						descendant:Destroy()
					elseif descendant:IsA("BasePart") then
						descendant.CanCollide = false
						descendant.Anchored = true
					end
				end

				clone.Parent = workspace

				for _, descendant in ipairs(Nyx_ghostCharacter:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
						descendant.LocalTransparencyModifier = 1
					end

					if descendant:IsA("Trail") then
						descendant.Enabled = false
					end
				end

				if CurrentCamera then
					CurrentCamera.CameraType = Enum.CameraType.Scriptable
					CurrentCamera.CFrame = CFrame_2
				end
			end)

			local Nyx_ghostParts = {}

			pcall(function()
				for _, descendant in ipairs(Nyx_ghostCharacter:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
						Nyx_ghostParts[#Nyx_ghostParts + 1] = descendant
					end
				end
			end)

			local function Nyx_lockCamera()
				if CurrentCamera then
					CurrentCamera.CameraType = Enum.CameraType.Scriptable
					CurrentCamera.CFrame = CFrame_2
				end

				for _, v in ipairs(Nyx_ghostParts) do
					if v.Parent then
						v.LocalTransparencyModifier = 1
					end
				end
			end
			local function Nyx_releaseFreeze(restoreCamera)
				pcall(function()
					if clone then
						clone:Destroy()
					end

					for _, descendant in ipairs(Nyx_ghostCharacter:GetDescendants()) do
						if descendant:IsA("BasePart") then
							descendant.LocalTransparencyModifier = 0
						end

						if descendant:IsA("Trail") then
							descendant.Enabled = true
						end
					end

					if CurrentCamera then
						CurrentCamera.CameraType = CameraType ~= Enum.CameraType.Scriptable and CameraType or Enum.CameraType.Custom

						if Humanoid then
							CurrentCamera.CameraSubject = Humanoid
						end

						if restoreCamera then
							CurrentCamera.CFrame = CFrame_2
						end
					end
				end)
			end

			return Nyx_releaseFreeze, Nyx_lockCamera
		end
		Nyx_v2429_var1.shield = function(self, uid)
			if not self.enabled or self.running then
				return false
			end

			if self:_skips(uid) then
				return false
			end

			local Nyx_shieldRoot = self:_root()

			if not Nyx_shieldRoot then
				return false
			end

			self.running = true

			local CFrame_2 = Nyx_shieldRoot.CFrame
			local Nyx_shieldGuard = self:_guardFor(uid)

			local function Nyx_shieldReposition()
				local Nyx_shieldRoot2 = self:_root()

				if not Nyx_shieldRoot2 then
					return false
				end

				Nyx_shieldRoot2.CFrame = cFrame
				Nyx_shieldRoot2.AssemblyLinearVelocity = Vector3.zero
				Nyx_shieldRoot2.AssemblyAngularVelocity = Vector3.zero

				return true
			end

			Nyx_shieldReposition()

			local Nyx_shieldReleaseFn, Nyx_shieldUpdateFn = self:_freeze(CFrame_2)
			local Nyx_shieldReposition_var1 = 1
			local Nyx_shieldReposition_var2 = false

			pcall(function()
				local now = os.clock()
				local Nyx_guardWasChasing = false

				while (os.clock() - now < 0.9 or Nyx_guardWasChasing and os.clock() - now < 1.6 and Nyx_shieldGuard and (Nyx_shieldGuard:GetAttribute("GuardState") == "Waking" or Nyx_shieldGuard:GetAttribute("GuardState") == "Chasing")) and Nyx_shieldReposition() do
					Nyx_shieldUpdateFn()
					Nyx_shieldReposition_var1 += 1

					local attribute = Nyx_shieldGuard and Nyx_shieldGuard:GetAttribute("GuardState")

					if attribute == "Waking" or attribute == "Chasing" then
						Nyx_guardWasChasing = true
						RunService2.Heartbeat:Wait()
					elseif Nyx_guardWasChasing and attribute == "Sleeping" and os.clock() - now > 0.2 then
						Nyx_shieldReposition_var2 = true

						break
					else
						RunService2.Heartbeat:Wait()
					end
				end
			end)
			Nyx_shieldReleaseFn(true)
			self.lastResult = (Nyx_shieldReposition_var2 and "Guard slept" or "Held") .. " (" .. Nyx_shieldReposition_var1 .. " writes)"
			self.running = false

			return true
		end
		Nyx_v2429_var1._check = function(self, carryEvent)
			if not self.enabled then
				self.wasHolding = false

				return
			end

			local Uid

			if type(carryEvent) == "table" and carryEvent.IsCarrying and carryEvent.Uid then
				Uid = carryEvent.Uid
			else
				Uid = self:_carriedUid()
			end

			local wasHolding = Uid ~= nil

			if wasHolding and not self.wasHolding and not self.running and not self:_skips(Uid) then
				task.spawn(function()
					pcall(function()
						self:shield(Uid)
					end)
				end)
			end

			self.wasHolding = wasHolding
		end
		Nyx_v2429_var1.setEnabled = function(self, enabled)
			self.enabled = enabled == true

			if self.enabled then
				self.wasHolding = self:_carriedUid() ~= nil
			end

			if not self.watcher then
				self.watcher = true
				task.spawn(function()
					while not self.destroyed do
						if not self.enabled or self.running then
							task.wait(0.5)
						else
							pcall(function()
								self:_check()
							end)
							task.wait(0.15)
						end
					end
				end)
			end

			if self.connection then
				return
			end

			pcall(function()
				local EggState2 = require(ReplicatedStorage2.Client.EggState)

				if EggState2 and EggState2.CarryChanged then
					self.connection = EggState2.CarryChanged:Connect(function(carryEvent)
						task.defer(function()
							self:_check(carryEvent)
						end)
					end)
				end
			end)
		end
		Nyx_v2429_var1.destroy = function(self)
			self.destroyed = true
			self.enabled = false

			if self.connection then
				pcall(function()
					self.connection:Disconnect()
				end)
				self.connection = nil
			end
		end

		return Nyx_v2429_var1
	end

	local Nyx_antiHitGuard = Nyx_isHoldingCaptureEgg_var3().new()

	genv.__NyxAntiHitGuard = Nyx_antiHitGuard

	if NyxConfig.AntiHitGuard then
		Nyx_antiHitGuard:setEnabled(true)
	end

	genv.__NyxPlayerSteal = Nyx_playerStealInstance
end

do
	local Nyx_guiConnections = {
		at = 0,
		value = false
	}

	genv.__NyxStealWantsCharacter = function()
		local __NyxPlayerSteal = genv.__NyxPlayerSteal

		if __NyxPlayerSteal and __NyxPlayerSteal.running then
			return true
		end

		local __NyxEggRuntime = genv.__NyxEggRuntime

		if not __NyxEggRuntime or not __NyxEggRuntime.enabled or __NyxEggRuntime.destroyed then
			return false
		end

		if __NyxEggRuntime.running or __NyxEggRuntime.activeTween and not __NyxEggRuntime.activeTween.sharedTravel or __NyxEggRuntime.carry and __NyxEggRuntime.carry.active then
			return true
		end

		local now = os.clock()

		if now - Nyx_guiConnections.at < 0.5 then
			return Nyx_guiConnections.value
		end

		Nyx_guiConnections.at = now

		local ok, result = pcall(function()
			return __NyxEggRuntime:_wallOpen() and __NyxEggRuntime:_chooseTarget() or nil
		end)

		Nyx_guiConnections.value = ok and result ~= nil

		return Nyx_guiConnections.value
	end
	genv.__NyxDronesWantCharacter = function()
		local __NyxButterflyRuntime = genv.__NyxButterflyRuntime

		return __NyxButterflyRuntime ~= nil and (__NyxButterflyRuntime.active == true or __NyxButterflyRuntime.wantsCharacter == true)
	end
end

Nyx_eggRuntime:setStealMode(NyxConfig.StealMode == "Semi Teleport" and "Instant" or NyxConfig.StealMode)
Nyx_eggRuntime:setSpeed(NyxConfig.TweenSpeedMultiplier or 60)

if NyxConfig.StealMinValue and NyxConfig.StealMinValue > 0 then
	Nyx_eggRuntime:setMinValuePerSec(NyxConfig.StealMinValue)
end

if NyxConfig.StealAreas and not table.find(NyxConfig.StealAreas, "None") and #NyxConfig.StealAreas > 0 then
	local Nyx_areaList = {}

	for _, stealArea in ipairs(NyxConfig.StealAreas) do
		if stealArea ~= "None" then
			table.insert(Nyx_areaList, stealArea)
		end
	end

	Nyx_eggRuntime:setFilter("areas", Nyx_areaList)
	Nyx_eggRuntime:setFilterEnabled("area", #Nyx_areaList > 0)
end

if NyxConfig.StealRarities and not table.find(NyxConfig.StealRarities, "None") and #NyxConfig.StealRarities > 0 then
	local Nyx_rarityListB = {}

	for _, stealRarity in ipairs(NyxConfig.StealRarities) do
		if stealRarity ~= "None" then
			table.insert(Nyx_rarityListB, stealRarity)
		end
	end

	Nyx_eggRuntime:setFilter("rarities", Nyx_rarityListB)
	Nyx_eggRuntime:setFilterEnabled("rarity", #Nyx_rarityListB > 0)
end

if NyxConfig.StealNamesFilter and not table.find(NyxConfig.StealNamesFilter, "None") and #NyxConfig.StealNamesFilter > 0 then
	local Nyx_nameList = {}

	for _, v in ipairs(NyxConfig.StealNamesFilter) do
		if v ~= "None" then
			table.insert(Nyx_nameList, v)
		end
	end

	Nyx_eggRuntime:setFilter("names", Nyx_nameList)
	Nyx_eggRuntime:setFilterEnabled("name", #Nyx_nameList > 0)
end

do
	genv.__NyxEggRuntimeCleanup = function()
		if Nyx_eggRuntime then
			pcall(Nyx_eggRuntime.destroy, Nyx_eggRuntime)
		end

		if Nyx_treadmillManager then
			pcall(Nyx_treadmillManager.destroy, Nyx_treadmillManager)
		end

		if genv.__NyxEggRuntime == Nyx_eggRuntime then
			genv.__NyxEggRuntime = nil
		end

		if genv.__NyxTreadmillManager == Nyx_treadmillManager then
			genv.__NyxTreadmillManager = nil
		end
	end
	genv.__NyxAntiGuardCleanup = function()
		if Nyx_antiGuard then
			pcall(Nyx_antiGuard.destroy, Nyx_antiGuard)
		end

		if Nyx_godMode then
			pcall(Nyx_godMode.destroy, Nyx_godMode)
		end

		if genv.__NyxAntiGuard == Nyx_antiGuard then
			genv.__NyxAntiGuard = nil
		end

		if genv.__NyxGodMode == Nyx_godMode then
			genv.__NyxGodMode = nil
		end
	end
end

do
	local function Nyx_getGenv2()
		return getgenv and getgenv() or _G
	end
	local function Nyx_getConnectionAPI()
		if type(getconnections) == "function" then
			return getconnections
		end

		if type(get_signal_cons) == "function" then
			return get_signal_cons
		end

		return nil
	end
	local function Nyx_disableIdleConnections(state)
		local LocalPlayer2 = Players.LocalPlayer

		if not LocalPlayer2 then
			state.antiAfkStatus = "LocalPlayer unavailable"

			return false
		end

		local Nyx_connectionAPIName = Nyx_getConnectionAPI()

		if not Nyx_connectionAPIName then
			state.antiAfkStatus = "Native Idled connection API unavailable"

			return false
		end

		local ok, result = pcall(Nyx_connectionAPIName, LocalPlayer2.Idled)

		if not ok or type(result) ~= "table" then
			state.antiAfkStatus = "Idled scan unavailable"

			return false
		end

		local lastDisabledIdleConnections = 0

		for _, v in ipairs(result) do
			local Nyx_connectionDisabled = false

			if type(v) == "table" or type(v) == "userdata" then
				if type(v.Disable) == "function" then
					Nyx_connectionDisabled = pcall(v.Disable, v)
				elseif type(v.Disconnect) == "function" then
					Nyx_connectionDisabled = pcall(v.Disconnect, v)
				end
			end

			if Nyx_connectionDisabled then
				lastDisabledIdleConnections += 1
			end
		end

		state.scanRuns += 1
		state.lastScanAt = os.clock()
		state.lastDisabledIdleConnections = lastDisabledIdleConnections
		state.disabledIdleConnections += lastDisabledIdleConnections
		state.antiAfkStatus = lastDisabledIdleConnections > 0 and "Anti-AFK disabled " .. tostring(lastDisabledIdleConnections) .. " Idled connection(s)" or "Anti-AFK active; Idled connections clear"

		return true
	end

	local Nyx_startupProtection = {
		install = function()
			local Nyx_genvTable3 = Nyx_getGenv2()
			local value = rawget(Nyx_genvTable3, "__FyyStealAnEggStartupProtectionLiteV2")

			if type(value) == "table" and value.installed then
				value.installRuns += 1
				Nyx_disableIdleConnections(value)
				value.status = value.antiAfkStatus

				return value
			end

			local Nyx_startupProtectionLite = {
				installRuns = 1,
				scanRuns = 0,
				disabledIdleConnections = 0,
				lastDisabledIdleConnections = 0,
				lastScanAt = 0,
				installed = false,
				mode = "native-idled-disabler",
				integrityPatcherInstalled = false,
				networkFilterInstalled = false,
				namecallHookInstalled = false
			}

			Nyx_genvTable3.__FyyStealAnEggStartupProtectionLiteV2 = Nyx_startupProtectionLite

			local LocalPlayer2 = Players.LocalPlayer

			if not LocalPlayer2 then
				Nyx_startupProtectionLite.antiAfkInstalled = false
				Nyx_startupProtectionLite.antiAfkStatus = "LocalPlayer unavailable"
				Nyx_startupProtectionLite.status = Nyx_startupProtectionLite.antiAfkStatus
				Nyx_startupProtectionLite.installed = true

				return Nyx_startupProtectionLite
			end

			Nyx_startupProtectionLite.antiAfkInstalled = Nyx_disableIdleConnections(Nyx_startupProtectionLite)
			Nyx_startupProtectionLite.idledConnection = LocalPlayer2.Idled:Connect(function()
				Nyx_disableIdleConnections(Nyx_startupProtectionLite)
			end)
			Nyx_startupProtectionLite.characterConnection = LocalPlayer2.CharacterAdded:Connect(function()
				task.delay(1, function()
					if Nyx_startupProtectionLite.installed then
						Nyx_disableIdleConnections(Nyx_startupProtectionLite)
					end
				end)
			end)
			Nyx_startupProtectionLite.installed = true
			Nyx_startupProtectionLite.status = Nyx_startupProtectionLite.antiAfkStatus

			local function Nyx_antiAfkWatchLoop()
				while Nyx_startupProtectionLite.installed and Nyx_genvTable3.__FyyStealAnEggStartupProtectionLiteV2 == Nyx_startupProtectionLite do
					task.wait(60)

					if Nyx_startupProtectionLite.installed and Nyx_genvTable3.__FyyStealAnEggStartupProtectionLiteV2 == Nyx_startupProtectionLite then
						Nyx_disableIdleConnections(Nyx_startupProtectionLite)
						Nyx_startupProtectionLite.status = Nyx_startupProtectionLite.antiAfkStatus
					end
				end
			end

			task.spawn(Nyx_antiAfkWatchLoop)

			return Nyx_startupProtectionLite
		end,
		uninstall = function()
			local value = rawget(Nyx_getGenv2(), "__FyyStealAnEggStartupProtectionLiteV2")

			if type(value) == "table" then
				value.installed = false

				if value.idledConnection and typeof(value.idledConnection.Disconnect) == "function" then
					pcall(value.idledConnection.Disconnect, value.idledConnection)
					value.idledConnection = nil
				end

				if value.characterConnection and typeof(value.characterConnection.Disconnect) == "function" then
					pcall(value.characterConnection.Disconnect, value.characterConnection)
					value.characterConnection = nil
				end
			end
		end
	}

	local function Nyx_initAntiAfk()
		local genv2 = getgenv and getgenv() or _G

		genv2.__NyxAntiAfkGeneration = (genv2.__NyxAntiAfkGeneration or 0) + 1
		genv2.__NyxAntiAfkEnabled = NyxConfig.AntiAFK
		genv2.__NyxStartupProtection = Nyx_startupProtection
		genv2.__NyxSetAntiAfkEnabled = function(enabled)
			genv2.__NyxAntiAfkEnabled = enabled == true

			if enabled then
				Nyx_startupProtection.install()
			else
				Nyx_startupProtection.uninstall()
			end
		end

		if NyxConfig.AntiAFK then
			genv2.__NyxSetAntiAfkEnabled(true)
		end
	end

	Nyx_initAntiAfk()
end

local Nyx_configRef = NyxConfig
local Nyx_teleportRefs = {
	TeleportService = TeleportService or game:GetService("TeleportService"),
	LP = LocalPlayer or Players.LocalPlayer,
	Players = Players
}

local function Nyx_writeAutoexecFile()
	pcall(function()
		if writefile then
			pcall(function()
				writefile("autoexec/Nyx_StealAnEgg.lua", [[repeat task.wait(0.5) until game:IsLoaded()
task.wait(1.5)
if getgenv then getgenv().SNE_AutoExecute = true end
loadstring(game:HttpGet("https://Nyxhub.xyz/raw/saev2"))()
]])
			end)
			pcall(function()
				writefile("autoexecute/Nyx_StealAnEgg.lua", [[repeat task.wait(0.5) until game:IsLoaded()
task.wait(1.5)
if getgenv then getgenv().SNE_AutoExecute = true end
loadstring(game:HttpGet("https://Nyxhub.xyz/raw/saev2"))()
]])
			end)
		end
	end)

	local queue_on_teleport_ = queue_on_teleport or syn and syn.queue_on_teleport or fluxus and fluxus.queue_on_teleport

	if queue_on_teleport_ then
		pcall(function()
			queue_on_teleport_([[repeat task.wait(0.5) until game:IsLoaded()
task.wait(1.5)
if getgenv then getgenv().SNE_AutoExecute = true end
loadstring(game:HttpGet("https://Nyxhub.xyz/raw/saev2"))()
]])
		end)
	end
end
local function Nyx_clearAutoexecFile()
	pcall(function()
		if delfile then
			pcall(function()
				delfile("autoexec/Nyx_StealAnEgg.lua")
			end)
			pcall(function()
				delfile("autoexecute/Nyx_StealAnEgg.lua")
			end)
		elseif writefile then
			pcall(function()
				writefile("autoexec/Nyx_StealAnEgg.lua", "")
			end)
			pcall(function()
				writefile("autoexecute/Nyx_StealAnEgg.lua", "")
			end)
		end
	end)
end

local Nyx_clearAutoexecFile_var1 = false

local function Nyx_autoReconnectLoop()
	if Nyx_clearAutoexecFile_var1 then
		return
	end

	Nyx_clearAutoexecFile_var1 = true

	if Nyx_configRef.autoExecute or getgenv and getgenv().SNE_AutoExecute then
		pcall(Nyx_writeAutoexecFile)
	end

	task.wait(3)

	local TeleportService2 = Nyx_teleportRefs.TeleportService or game:GetService("TeleportService")
	local PlaceId = game.PlaceId
	local JobId = game.JobId

	while true do
		pcall(function()
			if JobId then
				if not (#JobId > 0) then
					TeleportService2:Teleport(PlaceId, Nyx_teleportRefs.LP)

					return
				end

				TeleportService2:TeleportToPlaceInstance(PlaceId, JobId, Nyx_teleportRefs.LP)
			else
				TeleportService2:Teleport(PlaceId, Nyx_teleportRefs.LP)
			end
		end)
		task.wait(6)
	end
end

pcall(function()
	game:GetService("GuiService").ErrorMessageChanged:Connect(function(errorMessage)
		if Nyx_configRef.autoReconnect and errorMessage and #errorMessage > 0 then
			Nyx_autoReconnectLoop()
		end
	end)
end)
pcall(function()
	local LP = Nyx_teleportRefs.LP or LocalPlayer

	LP = LP or Players.LocalPlayer

	if LP and LP.OnTeleport then
		LP.OnTeleport:Connect(function()
			if Nyx_configRef.autoExecute or getgenv and getgenv().SNE_AutoExecute then
				pcall(Nyx_writeAutoexecFile)
			end
		end)
	end
end)
task.spawn(function()
	while true do
		task.wait(2)

		if Nyx_configRef.autoReconnect then
			pcall(function()
				local RobloxPromptGui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
				local promptOverlay = RobloxPromptGui and RobloxPromptGui:FindFirstChild("promptOverlay")
				local ErrorPrompt = promptOverlay and promptOverlay:FindFirstChild("ErrorPrompt")

				if ErrorPrompt and ErrorPrompt.Visible then
					Nyx_autoReconnectLoop()
				end
			end)
		end
	end
end)

local function Nyx_petBarnFactory()
	local Remotes = require(ReplicatedStorage.Shared.Remotes)

	local function Nyx_findFusablePair(speciesFilter, nameFilter, rarityFilter)
		local Nyx_saveDataSnapshot = (require(ReplicatedStorage.Shared.Save).Peek or require(ReplicatedStorage.Shared.Save).Get)()

		if not Nyx_saveDataSnapshot or type(Nyx_saveDataSnapshot.Inventory) ~= "table" then
			return nil
		end

		local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
		local Directory = require(ReplicatedStorage.Data.Assets).Directory
		local Nyx_equippedSet = {}
		local ipairs_ = ipairs
		local EquippedAssets = Nyx_saveDataSnapshot.EquippedAssets or {}

		for _, EquippedAsset in ipairs_(EquippedAssets) do
			Nyx_equippedSet[EquippedAsset] = true
		end

		local Nyx_groupedPets = {}

		for k, v in pairs(Nyx_saveDataSnapshot.Inventory) do
			if not Nyx_equippedSet[k] then
				local Nyx_findFusablePair_var1

				if AssetItems and type(AssetItems.Decode) == "function" then
					pcall(function()
						Nyx_findFusablePair_var1 = AssetItems.Decode(v)
					end)
				end

				Nyx_findFusablePair_var1 = Nyx_findFusablePair_var1 or v

				if type(Nyx_findFusablePair_var1) == "table" and not Nyx_findFusablePair_var1.InFuse and not Nyx_findFusablePair_var1.IsFavorite and Nyx_findFusablePair_var1.Category then
					local Nyx_petAssetDef = Directory[Nyx_findFusablePair_var1.Category]
					local DisplayName = Nyx_petAssetDef and Nyx_petAssetDef.Rarity and (Nyx_petAssetDef.Rarity.DisplayName or Nyx_petAssetDef.Rarity._id)
					local Nyx_rarityMatch = true

					if rarityFilter and #rarityFilter > 0 and not table.find(rarityFilter, "All") then
						Nyx_rarityMatch = DisplayName and table.find(rarityFilter, DisplayName) ~= nil
					end

					local Nyx_speciesMatch = true

					if speciesFilter and nameFilter and #nameFilter > 0 and not table.find(nameFilter, "All") then
						Nyx_speciesMatch = table.find(nameFilter, Nyx_findFusablePair_var1.Category) ~= nil or Nyx_petAssetDef and table.find(nameFilter, Nyx_petAssetDef.DisplayName) ~= nil
					end

					if Nyx_rarityMatch and Nyx_speciesMatch then
						Nyx_groupedPets[Nyx_findFusablePair_var1.Category] = Nyx_groupedPets[Nyx_findFusablePair_var1.Category] or {}
						table.insert(Nyx_groupedPets[Nyx_findFusablePair_var1.Category], {
							uid = k,
							d = Nyx_findFusablePair_var1
						})
					end
				end
			end
		end

		for _, v in pairs(Nyx_groupedPets) do
			if not (#v >= 3) then
				continue
			end

			return {
				v[1].uid,
				v[2].uid,
				v[3].uid
			}
		end

		return nil
	end

	local Nyx_petBarnActions = {
		equipBest = function()
			pcall(function()
				Remotes.Haul.WearBest:InvokeServer()
			end)
		end,
		claimOffline = function()
			local ok, result = pcall(function()
				return Remotes.AwayEarnings.FetchSummary:InvokeServer()
			end)

			if ok and type(result) == "table" then
				if (result.ClaimableAmount or 0) > 0 then
					pcall(function()
						Remotes.AwayEarnings.AskCollect:InvokeServer({
							Kind = "Claim"
						})
					end)
				end
			end
		end,
		favoriteSelected = function()
			local Nyx_saveForFavorite = (require(ReplicatedStorage.Shared.Save).Peek or require(ReplicatedStorage.Shared.Save).Get)()

			if not Nyx_saveForFavorite or type(Nyx_saveForFavorite.Inventory) ~= "table" then
				return 0
			end

			local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
			local Directory = require(ReplicatedStorage.Data.Assets).Directory
			local Nyx_favoriteSelected_var1 = 0

			for k, v in pairs(Nyx_saveForFavorite.Inventory) do
				local Nyx_favoriteSelected_var2

				if AssetItems and type(AssetItems.Decode) == "function" then
					pcall(function()
						Nyx_favoriteSelected_var2 = AssetItems.Decode(v)
					end)
				end

				Nyx_favoriteSelected_var2 = Nyx_favoriteSelected_var2 or v

				if type(Nyx_favoriteSelected_var2) == "table" then
					if not Nyx_favoriteSelected_var2.IsFavorite and Nyx_favoriteSelected_var2.Category then
						local Nyx_petAssetDefFav = Directory[Nyx_favoriteSelected_var2.Category]
						local DisplayName = Nyx_petAssetDefFav and Nyx_petAssetDefFav.Rarity and (Nyx_petAssetDefFav.Rarity.DisplayName or Nyx_petAssetDefFav.Rarity._id)
						local Nyx_favoriteMatch = false

						if NyxConfig.FavMode == "Species" then
							local FavSpecies = NyxConfig.FavSpecies or {}

							if table.find(FavSpecies, "All") or table.find(FavSpecies, Nyx_favoriteSelected_var2.Category) or Nyx_petAssetDefFav and table.find(FavSpecies, Nyx_petAssetDefFav.DisplayName) then
								Nyx_favoriteMatch = true
							end
						else
							local FavRarities = NyxConfig.FavRarities or {}

							if table.find(FavRarities, "All") or DisplayName and table.find(FavRarities, DisplayName) then
								Nyx_favoriteMatch = true
							end
						end

						if Nyx_favoriteMatch then
							pcall(function()
								Remotes.PetSatchel.WriteFavourite:FireServer(k, true)
							end)
							Nyx_favoriteSelected_var1 += 1

							if Nyx_favoriteSelected_var1 % 10 == 0 then
								task.wait(0.05)
							end
						end
					end
				end
			end

			return Nyx_favoriteSelected_var1
		end,
		unfavoriteAll = function()
			local Nyx_saveForUnfavorite = (require(ReplicatedStorage.Shared.Save).Peek or require(ReplicatedStorage.Shared.Save).Get)()

			if not Nyx_saveForUnfavorite or type(Nyx_saveForUnfavorite.Inventory) ~= "table" then
				return 0
			end

			local Nyx_unfavoriteAll_var1 = 0

			for k, v in pairs(Nyx_saveForUnfavorite.Inventory) do
				local Nyx_inventoryPet = v

				if type(Nyx_inventoryPet) == "table" and Nyx_inventoryPet.IsFavorite then
					pcall(function()
						Remotes.PetSatchel.WriteFavourite:FireServer(k, false)
					end)
					Nyx_unfavoriteAll_var1 += 1

					if Nyx_unfavoriteAll_var1 % 10 == 0 then
						task.wait(0.05)
					end
				end
			end

			return Nyx_unfavoriteAll_var1
		end,
		fuseOnePair = function()
			local Nyx_saveForFuse = (require(ReplicatedStorage.Shared.Save).Peek or require(ReplicatedStorage.Shared.Save).Get)()

			if not Nyx_saveForFuse then
				return false
			end

			if Nyx_saveForFuse.FusionLocked then
				return false, "Fusion locked"
			end

			local Nyx_fusablePair = Nyx_findFusablePair(NyxConfig.FuseSelectedOnly, NyxConfig.FuseSpecies, NyxConfig.FuseRarities)

			if not Nyx_fusablePair then
				return false, "No eligible group of 3"
			end

			pcall(function()
				Remotes.Fusery.ConfirmBriefing:InvokeServer()
			end)

			for _, v in ipairs(Nyx_fusablePair) do
				local ok, result = pcall(function()
					return Remotes.Fusery.LoadPet:InvokeServer(v)
				end)

				if ok and result then
					task.wait(0.02)

					continue
				end

				return false, "Failed to load pet"
			end

			local ok, result = pcall(function()
				return Remotes.Fusery.BeginFuse:InvokeServer()
			end)

			if not ok or not result then
				return false, "Failed to begin fuse"
			end

			task.wait(0.06)
			pcall(function()
				Remotes.Fusery.FinishReveal:InvokeServer()
			end)

			return true
		end
	}

	task.spawn(function()
		local Nyx_fuseOnePair_var1 = 0

		while Nyx_isCurrentSession() do
			local now = os.clock()

			if NyxConfig.AutoEquipBest and now - Nyx_fuseOnePair_var1 > 6 then
				Nyx_fuseOnePair_var1 = now
				pcall(Nyx_petBarnActions.equipBest)
			end

			if NyxConfig.AutoClaimOffline then
				pcall(Nyx_petBarnActions.claimOffline)
			end

			if NyxConfig.AutoFavorite then
				pcall(Nyx_petBarnActions.favoriteSelected)
			end

			if NyxConfig.AutoFusePets then
				pcall(Nyx_petBarnActions.fuseOnePair)
			end

			task.wait(2.5)
		end
	end)

	return Nyx_petBarnActions
end

genv.__NyxPetBarn = Nyx_petBarnFactory()

do
	local function Nyx_upgradesFactory()
		local Remotes = require(ReplicatedStorage.Shared.Remotes)
		local Nyx_baseUpgradeActions = {
			upgradeBase = function()
				local Nyx_saveForBase = (require(ReplicatedStorage.Shared.Save).Peek or require(ReplicatedStorage.Shared.Save).Get)()

				if not Nyx_saveForBase then
					return false
				end

				local Nyx_baseUpgradeLevel = tonumber(Nyx_saveForBase.BaseUpgradeLevel or 0) or 0
				local Bases = require(ReplicatedStorage.Data.Bases)
				local BASES = Bases and Bases.BASES and Bases.BASES[Nyx_baseUpgradeLevel + 1]

				if not BASES then
					return false, "Max level"
				end

				local Nyx_baseMoney = tonumber(Nyx_saveForBase.Money or 0) or 0

				if Nyx_baseMoney < (BASES.Cost or 0) then
					return false, "Not enough money"
				end

				local ok, result = pcall(function()
					return Remotes.Homestead.AskBaseTierRaise:InvokeServer()
				end)
				local Nyx_baseUpgradeOk = ok and result == true

				return Nyx_baseUpgradeOk, result
			end,
			claimAlmanac = function()
				local ok, result = pcall(function()
					return Remotes.Codex.AskRedeemAll:InvokeServer()
				end)

				return ok, result
			end
		}

		task.spawn(function()
			while Nyx_isCurrentSession() do
				if NyxConfig.AutoBaseUpgrade then
					pcall(Nyx_baseUpgradeActions.upgradeBase)
				end

				if NyxConfig.AutoClaimAlmanac then
					pcall(Nyx_baseUpgradeActions.claimAlmanac)
				end

				task.wait(3)
			end
		end)

		return Nyx_baseUpgradeActions
	end

	genv.__NyxUpgrades = Nyx_upgradesFactory()
end

local function Nyx_roamingFactory()
	local Nyx_roamingActions = {
		noclipConn = nil
	}

	Nyx_roamingActions.setNoclip = function(enabled)
		NyxConfig.Noclip = enabled == true

		if Nyx_roamingActions.noclipConn then
			pcall(function()
				Nyx_roamingActions.noclipConn:Disconnect()
			end)
			Nyx_roamingActions.noclipConn = nil
		end

		if NyxConfig.Noclip then
			Nyx_roamingActions.noclipConn = RunService.Stepped:Connect(function()
				if not NyxConfig.Noclip then
					return
				end

				local Character = LocalPlayer.Character

				if not Character then
					return
				end

				for _, descendant in ipairs(Character:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant.CanCollide then
						descendant:SetAttribute("NyxNoclip", true)
						descendant.CanCollide = false
					end
				end
			end)

			return
		end

		local Character = LocalPlayer.Character

		if Character then
			for _, descendant in ipairs(Character:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant:GetAttribute("NyxNoclip") then
					descendant.CanCollide = true
					descendant:SetAttribute("NyxNoclip", nil)
				end
			end
		end
	end
	Nyx_roamingActions.waypointList = function()
		local Nyx_waypointsList = { "Respawn Point" }
		local Nyx_worldRef9 = Nyx_getWorkspaceWorld()
		local Machines = Nyx_worldRef9 and Nyx_worldRef9:FindFirstChild("Machines")

		if Machines and Machines:FindFirstChild("FuseMachine") then
			table.insert(Nyx_waypointsList, "Fuse Machine")
		end

		local Areas = Nyx_worldRef9 and Nyx_worldRef9:FindFirstChild("Areas")
		local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")

		if GuardAreas then
			for _, child in ipairs(GuardAreas:GetChildren()) do
				table.insert(Nyx_waypointsList, child.Name)
			end
		end

		return Nyx_waypointsList
	end
	Nyx_roamingActions.teleportWaypoint = function(waypointName)
		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			return false
		end

		local Position
		local Nyx_worldRef10 = Nyx_getWorkspaceWorld()

		if waypointName == "Respawn Point" then
			pcall(function()
				local PlotState2 = require(ReplicatedStorage.Client.PlotState)
				local ResolvePlot = PlotState2.ResolvePlot and PlotState2.ResolvePlot()

				if ResolvePlot and ResolvePlot.RespawnPointCFrame then
					Position = ResolvePlot.RespawnPointCFrame.Position
				elseif ResolvePlot and ResolvePlot.Model then
					if ResolvePlot.Model:FindFirstChild("Spawn") then
						Position = ResolvePlot.Model.Spawn.Position
					end
				end
			end)
		elseif waypointName == "Fuse Machine" then
			local Machines = Nyx_worldRef10 and Nyx_worldRef10:FindFirstChild("Machines")
			local FuseMachine = Machines and Machines:FindFirstChild("FuseMachine")
			local Machine = FuseMachine and (FuseMachine:FindFirstChild("Machine") or FuseMachine.PrimaryPart)

			if Machine then
				Position = Machine.Position
			end
		else
			local Areas = Nyx_worldRef10 and Nyx_worldRef10:FindFirstChild("Areas")
			local GuardAreas = Areas and Areas:FindFirstChild("GuardAreas")
			local Nyx_guardArea = GuardAreas and GuardAreas:FindFirstChild(waypointName)
			local Guard = Nyx_guardArea and Nyx_guardArea:FindFirstChild("Guard")

			if Guard and Guard:IsA("BasePart") then
				Position = Guard.Position
			end
		end

		if not Position then
			return false
		end

		HumanoidRootPart.CFrame = cFrameNew(Position + Vector3.new(0, 4, 0))
		HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero

		return true
	end
	Nyx_roamingActions.setBottingMode = function(enabled)
		NyxConfig.BottingMode = enabled == true

		local __NyxBottingOverlay = genv.__NyxBottingOverlay

		if __NyxBottingOverlay and __NyxBottingOverlay.Parent then
			pcall(function()
				__NyxBottingOverlay:Destroy()
			end)
		end

		genv.__NyxBottingOverlay = nil

		if not NyxConfig.BottingMode then
			pcall(function()
				RunService:Set3dRenderingEnabled(true)
			end)

			return
		end

		pcall(function()
			RunService:Set3dRenderingEnabled(false)
		end)

		local CoreGui

		pcall(function()
			CoreGui = game:GetService("CoreGui")
		end)
		CoreGui = CoreGui or LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if not CoreGui then
			return
		end

		local ScreenGui = Instance.new("ScreenGui")

		ScreenGui.Name = "NyxBottingOverlay"
		ScreenGui.ResetOnSpawn = false
		ScreenGui.IgnoreGuiInset = true
		ScreenGui.DisplayOrder = -1
		ScreenGui.Parent = CoreGui

		local Frame = Instance.new("Frame")

		Frame.Name = "Blackscreen"
		Frame.Size = UDim2.new(1, 0, 1, 0)
		Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Active = false
		Frame.Parent = ScreenGui
		genv.__NyxBottingOverlay = ScreenGui
	end
	task.spawn(function()
		while Nyx_isCurrentSession() do
			if NyxConfig.AntiCutscene then
				pcall(function()
					local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

					if PlayerGui then
						for _, child in ipairs(PlayerGui:GetChildren()) do
							if child:IsA("ScreenGui") and (string.find(string.lower(child.Name), "cutscene") or child.Name == "Intro") and child.Enabled then
								child.Enabled = false
							end
						end
					end
				end)
			end

			task.wait(0.2)
		end
	end)

	return Nyx_roamingActions
end

genv.__NyxRoaming = Nyx_roamingFactory()

do
	local function Nyx_scrambleFactory()
		local Nyx_ScrambleRuntime = {
			snapAt = 0,
			snap = nil,
			status = "Idle",
			lastBuy = 0,
			doneLost = {},
			active = false,
			token = 0
		}

		local function Nyx_getScrambleRemotes()
			return require(ReplicatedStorage.Shared.Remotes).Scramble
		end

		Nyx_ScrambleRuntime.snapshot = function(forceRefresh)
			local now = os.clock()

			if not forceRefresh and Nyx_ScrambleRuntime.snap and now - Nyx_ScrambleRuntime.snapAt < 1.5 then
				return Nyx_ScrambleRuntime.snap
			end

			local ok, snap = pcall(function()
				return Nyx_getScrambleRemotes().Request:InvokeServer("Snapshot")
			end)

			if ok and type(snap) == "table" and snap.State then
				Nyx_ScrambleRuntime.snap = snap
				Nyx_ScrambleRuntime.snapAt = now
			end

			return Nyx_ScrambleRuntime.snap
		end
		Nyx_ScrambleRuntime.live = function()
			local Nyx_scrambleSnapshot = Nyx_ScrambleRuntime.snapshot()

			if not Nyx_scrambleSnapshot then
				return false
			end

			local Nyx_scrambleIsLive = Nyx_scrambleSnapshot.Ready == true and Nyx_scrambleSnapshot.Enabled == true and Nyx_scrambleSnapshot.WorldReady == true

			if Nyx_scrambleIsLive then
				Nyx_scrambleIsLive = workspace:GetServerTimeNow() < (Nyx_scrambleSnapshot.EventEndsAt or 0)
			end

			return Nyx_scrambleIsLive
		end
		Nyx_ScrambleRuntime.windowActive = function()
			local Nyx_scrambleWindowActive = Nyx_ScrambleRuntime.snapshot()

			return Nyx_scrambleWindowActive and Nyx_scrambleWindowActive.Window and Nyx_scrambleWindowActive.Window.Active == true or false
		end
		Nyx_ScrambleRuntime.progress = function()
			local Nyx_scrambleState = Nyx_ScrambleRuntime.snapshot()
			local State = Nyx_scrambleState and Nyx_scrambleState.State

			if State then
				return State.Samples or 0, State.TotalParts or 0, State.DroneParts or 0
			end

			return 0, 0, 0
		end
		Nyx_ScrambleRuntime.buyTick = function()
			local ScrambleBuyList = NyxConfig.ScrambleBuyList

			if not ScrambleBuyList or #ScrambleBuyList == 0 then
				return
			end

			if os.clock() - Nyx_ScrambleRuntime.lastBuy < 2 then
				return
			end

			local Nyx_scrambleShopSnapshot = Nyx_ScrambleRuntime.snapshot(true)

			if not Nyx_scrambleShopSnapshot or not Nyx_scrambleShopSnapshot.State or not Nyx_scrambleShopSnapshot.Shop then
				return
			end

			local Samples = Nyx_scrambleShopSnapshot.State.Samples or 0

			for _, v in pairs(Nyx_scrambleShopSnapshot.Shop) do
				if not NyxConfig.ScrambleAutoBuy then
					return
				end

				local Nyx_scrambleShopLabel = tostring(v.Label)
				local Nyx_scrambleShopMatched = false
				local Nyx_scrambleBuyIter, Nyx_scrambleBuyIterState, Nyx_scrambleBuyIterControl = ipairs(ScrambleBuyList)
				local Nyx_scrambleBuyIterator = geniter(Nyx_scrambleBuyIter, Nyx_scrambleBuyIterState, Nyx_scrambleBuyIterControl)
				local Nyx_scrambleBuyPack = table.pack(Nyx_scrambleBuyIterator())

				if Nyx_scrambleBuyPack[1] then
					local Nyx_scrambleBuyEntry = Nyx_scrambleBuyPack[3]

					while true do
						if tostring(Nyx_scrambleBuyEntry) == Nyx_scrambleShopLabel then
							Nyx_scrambleShopMatched = true

							break
						end

						local Nyx_scrambleBuyNextPack = table.pack(Nyx_scrambleBuyIterator())

						if not Nyx_scrambleBuyNextPack[1] then
							break
						end

						Nyx_scrambleBuyEntry = Nyx_scrambleBuyNextPack[3]
					end

					if not Nyx_scrambleShopMatched then
						continue
					end

					if not ((v.Price or 0) <= Samples) then
						continue
					end

					local Nyx_scrambleBuyPurchase = (Nyx_scrambleShopSnapshot.State.ShopPurchases or {})[v.Id]
					local Count = Nyx_scrambleBuyPurchase and Nyx_scrambleBuyPurchase.Period == Nyx_scrambleShopSnapshot.ShopPeriod and (Nyx_scrambleBuyPurchase.Count or 0) or 0

					if not v.PurchaseLimit then
						Nyx_ScrambleRuntime.lastBuy = os.clock()
						pcall(function()
							Nyx_getScrambleRemotes().Request:InvokeServer("Shop", v.Id, {
								Quote = v.Quote,
								Sequence = Nyx_scrambleShopSnapshot.State.ShopSequence
							})
						end)
						Nyx_ScrambleRuntime.status = "Bought " .. Nyx_scrambleShopLabel
						Nyx_ScrambleRuntime.snapshot(true)

						return
					end

					if not (Count + (v.Quantity or 1) <= v.PurchaseLimit) then
						continue
					end

					Nyx_ScrambleRuntime.lastBuy = os.clock()
					pcall(function()
						Nyx_getScrambleRemotes().Request:InvokeServer("Shop", v.Id, {
							Quote = v.Quote,
							Sequence = Nyx_scrambleShopSnapshot.State.ShopSequence
						})
					end)
					Nyx_ScrambleRuntime.status = "Bought " .. Nyx_scrambleShopLabel
					Nyx_ScrambleRuntime.snapshot(true)

					return
				end
			end
		end
		task.spawn(function()
			while Nyx_isCurrentSession() do
				Nyx_ScrambleRuntime.wantsCharacter = false
				Nyx_ScrambleRuntime.active = false

				if NyxConfig.ScrambleAutoBuy then
					pcall(function()
						if Nyx_ScrambleRuntime.live() then
							Nyx_ScrambleRuntime.buyTick()
						else
							Nyx_ScrambleRuntime.status = "Event not active"
						end
					end)
				end

				task.wait(NyxConfig.ScrambleAutoBuy and 0.5 or 1)
			end
		end)

		return Nyx_ScrambleRuntime
	end

	genv.__NyxScrambleRuntime = Nyx_scrambleFactory()
end

local function Nyx_butterflyFactory()
	local Nyx_BloomRuntime = {
		status = "Idle",
		active = false,
		wantsCharacter = false,
		lastSwing = 0,
		retryAt = {},
		cards = {},
		snap = {}
	}
	local Nyx_BLOOM_TIERS = {
		"Green",
		"Blue",
		"Purple",
		"Golden"
	}
	local Nyx_butterflyTierOrder = {
		Green = 1,
		Blue = 2,
		Purple = 3,
		Golden = 4
	}
	local Nyx_butterflyBlockers = {
		TITLES = {
			auto_steal = "Auto Steal",
			mech_boss = "Mech Boss",
			auto_place = "Auto Place"
		},
		blocker = function()
			if LocalPlayer:GetAttribute("InScrambleArena") == true then
				return "mech_boss"
			end

			if NyxConfig.ScrambleBossAuto == true then
				local ScrambleArena = workspace:FindFirstChild("ScrambleArena")

				if workspace:FindFirstChild("ScrambleArenaPortal") or ScrambleArena and ScrambleArena:GetAttribute("Phase") ~= "Defeated" then
					return "mech_boss"
				end
			end

			local __NyxStealWantsCharacter = genv.__NyxStealWantsCharacter

			if __NyxStealWantsCharacter and __NyxStealWantsCharacter() then
				return "auto_steal"
			end

			return nil
		end,
		holder = function()
			if NyxConfig.IsPlacing == true then
				return "auto_place"
			end

			return nil
		end
	}

	local function Nyx_requirePath(root, ...)
		for _, v in ipairs({ ... }) do
			if not root then
				return nil
			end

			root = root:FindFirstChild(v)
		end

		return root
	end

	local Nyx_requirePath_var1

	local function Nyx_getButterflyModules()
		if Nyx_requirePath_var1 then
			return Nyx_requirePath_var1
		end

		local function Nyx_safeRequire(moduleScript)
			if not moduleScript then
				return nil
			end

			local ok, result = pcall(require, moduleScript)

			return ok and result or nil
		end

		local Nyx_butterflyModules = {
			Remotes = Nyx_safeRequire(Nyx_requirePath(ReplicatedStorage, "Shared", "Remotes")),
			Save = Nyx_safeRequire(Nyx_requirePath(ReplicatedStorage, "Shared", "Save")),
			Catalog = Nyx_safeRequire(Nyx_requirePath(ReplicatedStorage, "Shared", "Modules", "ButterflyCatalog")),
			Flags = Nyx_safeRequire(Nyx_requirePath(ReplicatedStorage, "Shared", "Flags", "ButterflyFlags")),
			Swarm = Nyx_safeRequire(Nyx_requirePath(ReplicatedStorage, "Controllers", "Game", "AdminAbuseClientController", "Events", "ButterflyBloom", "Swarm"))
		}

		if not Nyx_butterflyModules.Remotes or not Nyx_butterflyModules.Save or not Nyx_butterflyModules.Catalog then
			return nil
		end

		Nyx_requirePath_var1 = Nyx_butterflyModules

		return Nyx_butterflyModules
	end
	local function Nyx_readButterflyFlag(flagKey, defaultValue)
		local Nyx_butterflyFlags = Nyx_getButterflyModules()
		local Flags = Nyx_butterflyFlags and Nyx_butterflyFlags.Flags and Nyx_butterflyFlags.Flags[flagKey]

		if not Flags then
			return defaultValue
		end

		local ok, result = pcall(function()
			return Flags:Get()
		end)

		if not ok or result == nil then
			return defaultValue
		end

		return result
	end
	local function Nyx_callButterflyRemote(remoteCategory, remoteName, ...)
		local Nyx_butterflyModulesRef = Nyx_getButterflyModules()
		local Nyx_butterflyRemote = Nyx_butterflyModulesRef and Nyx_butterflyModulesRef.Remotes[remoteCategory] and Nyx_butterflyModulesRef.Remotes[remoteCategory][remoteName]

		if not Nyx_butterflyRemote then
			return false, remoteCategory .. "." .. remoteName .. " missing"
		end

		local Nyx_remoteCallResult = table.pack(pcall(Nyx_butterflyRemote.InvokeServer, Nyx_butterflyRemote, ...))

		if Nyx_remoteCallResult[1] then
			return Nyx_remoteCallResult[2] == true, type(Nyx_remoteCallResult[3]) == "string" and Nyx_remoteCallResult[3] or nil, Nyx_remoteCallResult[2]
		end

		return false, tostring(Nyx_remoteCallResult[2])
	end
	local function Nyx_canRetry(cooldownKey)
		return (Nyx_BloomRuntime.retryAt[cooldownKey] or 0) <= os.clock()
	end
	local function Nyx_markRetryAt(cooldownKey)
		Nyx_BloomRuntime.retryAt[cooldownKey] = os.clock() + 5
	end
	local function Nyx_getLocalRoot()
		local Character = LocalPlayer.Character

		return Character and Character:FindFirstChild("HumanoidRootPart") or nil
	end

	Nyx_BloomRuntime.bloomLeft = function()
		local Nyx_butterflyCatalog = Nyx_getButterflyModules()
		local attribute = workspace:GetAttribute(Nyx_butterflyCatalog and Nyx_butterflyCatalog.Catalog.EndsAtAttribute or "ButterflyBloomEndsAt")

		if typeof(attribute) == "number" then
			return math.max(0, attribute - workspace:GetServerTimeNow())
		end

		return 0
	end
	Nyx_BloomRuntime.nextBloom = function()
		local Nyx_bloomIntervalSeconds = tonumber(Nyx_readButterflyFlag("IntervalSeconds", 1800)) or 1800
		local Nyx_bloomOffsetSeconds = tonumber(Nyx_readButterflyFlag("OffsetSeconds", 900)) or 900
		local Nyx_bloomDurationSeconds = tonumber(Nyx_readButterflyFlag("DurationSeconds", 300)) or 300

		if Nyx_bloomIntervalSeconds <= 0 then
			return nil
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local Nyx_butterflyCatalog2 = Nyx_getButterflyModules()
		local attribute = workspace:GetAttribute(Nyx_butterflyCatalog2 and Nyx_butterflyCatalog2.Catalog.EndsAtAttribute or "ButterflyBloomEndsAt")
		local Nyx_nextBloomTime = typeof(attribute) == "number" and attribute - Nyx_bloomDurationSeconds or math.floor((serverTimeNow - Nyx_bloomOffsetSeconds) / Nyx_bloomIntervalSeconds) * Nyx_bloomIntervalSeconds + Nyx_bloomOffsetSeconds
		local Nyx_getLocalRoot_var1 = 0

		while Nyx_nextBloomTime <= serverTimeNow and Nyx_getLocalRoot_var1 < 64 do
			Nyx_nextBloomTime += Nyx_bloomIntervalSeconds
			Nyx_getLocalRoot_var1 += 1
		end

		return Nyx_nextBloomTime > serverTimeNow and Nyx_nextBloomTime - serverTimeNow or nil
	end

	local function Nyx_findButterflyNet(character)
		if not character then
			return nil
		end

		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("ButterflyNet") == true then
				return child
			end
		end

		return nil
	end

	local Nyx_findButterflyNet_var1

	Nyx_BloomRuntime.tiers = function()
		if Nyx_findButterflyNet_var1 then
			return Nyx_findButterflyNet_var1
		end

		local Nyx_butterflyModules3 = Nyx_getButterflyModules()

		if not Nyx_butterflyModules3 then
			return nil
		end

		local Nyx_butterflyTiers = {}

		for i, v in ipairs(Nyx_BLOOM_TIERS) do
			local Tiers = Nyx_butterflyModules3.Catalog.Tiers and Nyx_butterflyModules3.Catalog.Tiers[v]

			Nyx_butterflyTiers[v] = {
				name = (Tiers and tostring(Tiers.DisplayName) or v):gsub("%s*Butterfly$", ""),
				color = Tiers and typeof(Tiers.Color) == "Color3" and Tiers.Color or Color3.new(1, 1, 1),
				trade = i < 4 and (tonumber(Nyx_readButterflyFlag(("%sTo%sCost"):format(v, Nyx_BLOOM_TIERS[i + 1]), 0)) or 0) or 0,
				essence = tonumber(Nyx_readButterflyFlag("Essence" .. v, 0)) or 0
			}
		end

		Nyx_findButterflyNet_var1 = Nyx_butterflyTiers

		return Nyx_butterflyTiers
	end
	Nyx_BloomRuntime.snapshot = function()
		local Nyx_butterflyModules4 = Nyx_getButterflyModules()
		local snap = Nyx_BloomRuntime.snap

		if not Nyx_butterflyModules4 then
			return snap
		end

		snap.left = Nyx_BloomRuntime.bloomLeft()
		snap.active = snap.left > 0
		snap.enabled = Nyx_readButterflyFlag("Enabled", true) ~= false
		snap.nextIn = not snap.active and Nyx_BloomRuntime.nextBloom() or nil

		local ok, result = pcall(Nyx_butterflyModules4.Save.Peek)
		local Nyx_saveSnapshot2 = ok and result or nil
		local Butterflies = Nyx_saveSnapshot2 and Nyx_saveSnapshot2.Butterflies

		snap.net = type(Butterflies) == "table" and Butterflies.NetClaimed == true
		snap.holding = Nyx_findButterflyNet(LocalPlayer.Character) ~= nil
		snap.inBag = Nyx_findButterflyNet(LocalPlayer:FindFirstChildOfClass("Backpack")) ~= nil
		snap.counts = snap.counts or {}

		for _, v in ipairs(Nyx_BLOOM_TIERS) do
			snap.counts[v] = type(Butterflies) == "table" and Butterflies.Counts and tonumber(Butterflies.Counts[v]) or 0
		end

		snap.essence = type(Butterflies) == "table" and tonumber(Butterflies.Essence) or 0
		snap.caught = type(Butterflies) == "table" and tonumber(Butterflies.TotalCaught) or 0
		snap.treeUnlocked = LocalPlayer:GetAttribute("EnchantedTreeUnlocked") == true

		return snap
	end
	Nyx_BloomRuntime.smartNext = function(tierCounts)
		local Nyx_butterflyTiers = Nyx_BloomRuntime.tiers()

		if not Nyx_butterflyTiers or not tierCounts then
			return nil
		end

		for i = 3, 1, -1 do
			local Nyx_butterflySourceTier = Nyx_BLOOM_TIERS[i]
			local Nyx_butterflyDestTier = Nyx_BLOOM_TIERS[i + 1]
			local trade = Nyx_butterflyTiers[Nyx_butterflySourceTier].trade

			if not (trade > 0) then
				continue
			end

			if not ((tierCounts[Nyx_butterflyDestTier] or 0) < Nyx_butterflyTiers[Nyx_butterflyDestTier].essence) then
				continue
			end

			if trade <= (tierCounts[Nyx_butterflySourceTier] or 0) - Nyx_butterflyTiers[Nyx_butterflySourceTier].essence then
				return Nyx_butterflySourceTier
			end
		end

		return nil
	end
	Nyx_BloomRuntime.canTrade = function()
		local snap = Nyx_BloomRuntime.snap
		local Nyx_butterflyTiers2 = Nyx_BloomRuntime.tiers()

		if not Nyx_butterflyTiers2 or not snap.counts then
			return false
		end

		local ButterflyTradeRecipe = NyxConfig.ButterflyTradeRecipe

		if ButterflyTradeRecipe == "Smart" then
			return Nyx_BloomRuntime.smartNext(snap.counts) ~= nil
		end

		for i = 1, 3 do
			local Nyx_butterflyTierEntry = Nyx_BLOOM_TIERS[i]

			if ButterflyTradeRecipe ~= nil and ButterflyTradeRecipe ~= "All" and ButterflyTradeRecipe ~= Nyx_butterflyTierEntry or not (Nyx_butterflyTiers2[Nyx_butterflyTierEntry].trade > 0) then
				continue
			end

			if Nyx_butterflyTiers2[Nyx_butterflyTierEntry].trade <= (snap.counts[Nyx_butterflyTierEntry] or 0) then
				return true
			end
		end

		return false
	end
	Nyx_BloomRuntime.canCraft = function()
		local snap = Nyx_BloomRuntime.snap
		local Nyx_butterflyTiers3 = Nyx_BloomRuntime.tiers()

		if not Nyx_butterflyTiers3 or not snap.counts then
			return false
		end

		for _, v in ipairs(Nyx_BLOOM_TIERS) do
			if not (Nyx_butterflyTiers3[v].essence > 0) then
				continue
			end

			if (snap.counts[v] or 0) < Nyx_butterflyTiers3[v].essence then
				return false, v
			end
		end

		return true
	end

	local function Nyx_getTierFilterSet()
		local ButterflyTiers = NyxConfig.ButterflyTiers

		if type(ButterflyTiers) ~= "table" or #ButterflyTiers == 0 then
			return nil
		end

		local Nyx_tierFilterSet = {}

		for _, ButterflyTier in ipairs(ButterflyTiers) do
			Nyx_tierFilterSet[tostring(ButterflyTier)] = true
		end

		return Nyx_tierFilterSet
	end
	local function Nyx_getSwarmButterflies()
		local ButterflyBloomSwarm = workspace:FindFirstChild("ButterflyBloomSwarm")

		if not ButterflyBloomSwarm then
			return {}
		end

		local Nyx_butterflyList = {}

		for _, child in ipairs(ButterflyBloomSwarm:GetChildren()) do
			if Nyx_butterflyTierOrder[child.Name] and child:IsA("Model") then
				Nyx_butterflyList[#Nyx_butterflyList + 1] = {
					pos = child.PrimaryPart and child.PrimaryPart.Position or child:GetPivot().Position,
					tier = child.Name
				}
			end
		end

		return Nyx_butterflyList
	end
	local function Nyx_equipNetTool()
		local Character = LocalPlayer.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local Nyx_backpackNet = Nyx_findButterflyNet(LocalPlayer:FindFirstChildOfClass("Backpack"))

		if not Humanoid or not Nyx_backpackNet then
			return false
		end

		pcall(function()
			Humanoid:EquipTool(Nyx_backpackNet)
		end)

		return Nyx_findButterflyNet(Character) ~= nil
	end

	local Nyx_bloomPad = {
		part = nil,
		y = 0
	}

	local function Nyx_cleanupBloomPad()
		if Nyx_bloomPad.part then
			pcall(function()
				Nyx_bloomPad.part:Destroy()
			end)
		end

		Nyx_bloomPad.part = nil
	end
	local function Nyx_updateBloomPad()
		local Nyx_localRoot = Nyx_getLocalRoot()

		if not Nyx_localRoot then
			return
		end

		if not Nyx_bloomPad.part or not Nyx_bloomPad.part.Parent then
			local Part = Instance.new("Part")

			Part.Name = "NyxBloomPad"
			Part.Anchored = true
			Part.CanCollide = true
			Part.CanTouch = false
			Part.CastShadow = false
			Part.Transparency = 1
			Part.Size = Vector3.new(24, 1, 24)
			Nyx_bloomPad.y = Nyx_localRoot.Position.Y - 3.5
			Part.CFrame = cFrameNew(Nyx_localRoot.Position.X, Nyx_bloomPad.y, Nyx_localRoot.Position.Z)
			Part.Parent = workspace
			Nyx_bloomPad.part = Part
		end

		local raycastParams = RaycastParams.new()

		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {
			LocalPlayer.Character,
			Nyx_bloomPad.part
		}

		local hit = workspace:Raycast(Nyx_localRoot.Position + Vector3.new(0, 4, 0), Vector3.new(0, -80, 0), raycastParams)

		if not hit then
			return
		end

		Nyx_bloomPad.y += math.clamp(hit.Position.Y - 0.5 + 6 - Nyx_bloomPad.y, -2, 2)
		Nyx_bloomPad.part.CFrame = cFrameNew(Nyx_localRoot.Position.X, Nyx_bloomPad.y, Nyx_localRoot.Position.Z)
	end
	local function Nyx_travelToBloomZone(targetPos, timeoutSeconds)
		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid then
			return false
		end

		Nyx_cleanupBloomPad()

		local Nyx_travelTimeout = os.clock() + (timeoutSeconds or 30)

		local function Nyx_isTravelCancelled()
			if not Nyx_isCurrentSession() or Nyx_travelTimeout < os.clock() then
				return true
			end

			return Nyx_butterflyBlockers.blocker("butterfly") ~= nil
		end

		if Nyx_eggRuntime and HumanoidRootPart.Position.Y < 16000 and targetPos.Y < 16000 and (HumanoidRootPart.Position - targetPos).Magnitude > 600 and not Nyx_eggRuntime:_isInSafeArea(HumanoidRootPart) then
			local Nyx_safeCFrameToZone = Nyx_eggRuntime:_resolveSafeCFrame(HumanoidRootPart)

			if Nyx_safeCFrameToZone and (Nyx_safeCFrameToZone.Position - targetPos).Magnitude > 40 then
				local status = Nyx_BloomRuntime.status

				Nyx_BloomRuntime.status = "Heading to the safe zone first"
				pcall(Nyx_glideTo, HumanoidRootPart, Humanoid, Nyx_safeCFrameToZone, Nyx_isTravelCancelled)
				Nyx_BloomRuntime.status = status
				HumanoidRootPart = Nyx_getLocalRoot()

				if not HumanoidRootPart or Nyx_isTravelCancelled() or not Nyx_eggRuntime:_isInSafeArea(HumanoidRootPart) then
					return false
				end
			end
		end

		pcall(Nyx_glideTo, HumanoidRootPart, Humanoid, cFrameNew(targetPos) * HumanoidRootPart.CFrame.Rotation, Nyx_isTravelCancelled)

		local Nyx_localRootAfterTravel = Nyx_getLocalRoot()
		local Nyx_arrivedAtZone = Nyx_localRootAfterTravel ~= nil and (Nyx_localRootAfterTravel.Position - targetPos).Magnitude <= 12

		return Nyx_arrivedAtZone
	end
	local function Nyx_isInEnchantedTree()
		if LocalPlayer:GetAttribute("InEnchantedTree") == true then
			return true
		end

		local Nyx_localRootPos = Nyx_getLocalRoot()

		return Nyx_localRootPos ~= nil and Nyx_localRootPos.Position.Y > 16000
	end
	local function Nyx_firePrompt(prompt)
		if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then
			return false
		end

		local Nyx_promptHoldDuration = tonumber(prompt.HoldDuration) or 0

		pcall(function()
			prompt:InputHoldBegin()
			task.wait(Nyx_promptHoldDuration > 0 and Nyx_promptHoldDuration + 0.15 or 0.05)
			prompt:InputHoldEnd()
		end)

		if typeof(fireproximityprompt) == "function" then
			pcall(fireproximityprompt, prompt, Nyx_promptHoldDuration > 0 and Nyx_promptHoldDuration + 0.15 or 0)
		end

		return true
	end

	local EnchantedTreePrompt

	local function Nyx_enterEnchantedTree()
		if Nyx_isInEnchantedTree() then
			return nil
		end

		if LocalPlayer:GetAttribute("EnchantedTreeUnlocked") ~= true then
			return "Enchanted Tree is locked (finish the Wisp Event)"
		end

		if not EnchantedTreePrompt or not EnchantedTreePrompt.Parent then
			local world = Nyx_requirePath(workspace, "World", "Build", "EnchantedTreeInterior", "Markers", "EnterTrigger")

			EnchantedTreePrompt = world and world:FindFirstChild("EnchantedTreePrompt", true) or nil
		end

		local Parent = EnchantedTreePrompt and EnchantedTreePrompt.Parent
		local WorldPosition = Parent and (Parent:IsA("Attachment") and Parent.WorldPosition or Parent:IsA("BasePart") and Parent.Position)

		if not WorldPosition then
			return "tree entrance not found"
		end

		if Nyx_isNightPhase() then
			return "night - the forest is sealed"
		end

		Nyx_BloomRuntime.status = "Flying to the Enchanted Tree"

		if not Nyx_travelToBloomZone(WorldPosition + Vector3.new(0, 3, 0), 60) then
			return "could not reach the tree entrance"
		end

		Nyx_BloomRuntime.status = "Entering the tree"
		Nyx_firePrompt(EnchantedTreePrompt)

		local Nyx_enterTreeDeadline = os.clock() + 8

		while os.clock() < Nyx_enterTreeDeadline and not Nyx_isInEnchantedTree() do
			task.wait(0.05)
		end

		if Nyx_isInEnchantedTree() then
			return nil
		end

		return "entering the tree failed"
	end
	local function Nyx_exitEnchantedTree()
		if not Nyx_isInEnchantedTree() then
			return true
		end

		local world = Nyx_requirePath(workspace, "World", "Build", "EnchantedTreeInterior", "Markers", "ExitTrigger")

		if not world or typeof(firetouchinterest) ~= "function" then
			return false
		end

		Nyx_BloomRuntime.status = "Leaving the tree"

		local Nyx_exitTreeDeadline = os.clock() + 6

		while os.clock() < Nyx_exitTreeDeadline and Nyx_isInEnchantedTree() do
			local Nyx_localRootForExit = Nyx_getLocalRoot()

			if Nyx_localRootForExit then
				pcall(firetouchinterest, Nyx_localRootForExit, world, 0)
				pcall(firetouchinterest, Nyx_localRootForExit, world, 1)
			end

			task.wait(0.3)
		end

		return not Nyx_isInEnchantedTree()
	end
	local function Nyx_findButterflyStation(stationName)
		local world = Nyx_requirePath(workspace, "World", "Machines", "ButterflyStation", stationName, "Anchor")

		return world and world:IsA("BasePart") and world.Position or nil, world
	end
	local function Nyx_visitButterflyStation(stationName)
		local Nyx_stationAnchor = Nyx_findButterflyStation(stationName)

		if not Nyx_stationAnchor then
			return false, stationName .. " not found"
		end

		local Nyx_localRootForStation = Nyx_getLocalRoot()

		if Nyx_localRootForStation and (Nyx_localRootForStation.Position - Nyx_stationAnchor).Magnitude <= 10 then
			return true
		end

		local Nyx_stationEnterError = Nyx_enterEnchantedTree()

		if Nyx_stationEnterError then
			return false, Nyx_stationEnterError
		end

		Nyx_BloomRuntime.status = "Walking to the " .. stationName

		if Nyx_travelToBloomZone(Nyx_stationAnchor + Vector3.new(0, 3, 0), 15) then
			return true
		end

		return false, "could not reach the " .. stationName
	end
	local function Nyx_getBloomBounds()
		local world = Nyx_requirePath(workspace, "World", "Areas", "ButterflyBloom", "Bounds")

		return world and world:IsA("BasePart") and world or nil
	end
	local function Nyx_isInBloomZone()
		local Nyx_bloomBoundsPart = Nyx_getBloomBounds()
		local Nyx_localRootForBounds = Nyx_getLocalRoot()

		if not Nyx_bloomBoundsPart or not Nyx_localRootForBounds or Nyx_isInEnchantedTree() then
			return false
		end

		local Nyx_localPosInBounds = Nyx_bloomBoundsPart.CFrame:PointToObjectSpace(Nyx_localRootForBounds.Position)

		return math.abs(Nyx_localPosInBounds.X) <= Nyx_bloomBoundsPart.Size.X / 2 + 20 and math.abs(Nyx_localPosInBounds.Z) <= Nyx_bloomBoundsPart.Size.Z / 2 + 20
	end
	local function Nyx_getBloomZoneCenter()
		local Nyx_bloomBoundsPart2 = Nyx_getBloomBounds()

		return Nyx_bloomBoundsPart2 and Nyx_bloomBoundsPart2.Position + Vector3.new(0, 4, 0) or nil
	end
	local function Nyx_leaveTreadmill()
		local __NyxTreadmillManager = genv.__NyxTreadmillManager

		if not __NyxTreadmillManager or __NyxTreadmillManager.activeTreadmill == nil then
			return
		end

		Nyx_BloomRuntime.status = "Leaving the treadmill"

		local Nyx_leaveTreadmillDeadline = os.clock() + 5

		while __NyxTreadmillManager.activeTreadmill ~= nil and os.clock() < Nyx_leaveTreadmillDeadline do
			__NyxTreadmillManager:_requestUnequip()
			task.wait(0.3)
		end

		local Nyx_localRootForLeave = Nyx_getLocalRoot()

		if Nyx_localRootForLeave and Nyx_localRootForLeave.Anchored then
			pcall(function()
				Nyx_localRootForLeave.Anchored = false
			end)
		end
	end
	local function Nyx_resumeTreadmillIdle()
		local __NyxTreadmillManager = genv.__NyxTreadmillManager

		if not __NyxTreadmillManager or __NyxTreadmillManager.destroyed or not __NyxTreadmillManager.config.idleFarm then
			return false
		end

		if not __NyxTreadmillManager.busy and not __NyxTreadmillManager.idleRunning then
			task.defer(function()
				__NyxTreadmillManager:_startIdle()
			end)
		end

		return true
	end
	local function Nyx_returnToSafeArea()
		Nyx_cleanupBloomPad()

		if Nyx_isInEnchantedTree() then
			Nyx_exitEnchantedTree()
		end

		if Nyx_resumeTreadmillIdle() then
			return
		end

		local Nyx_localRootForReturn = Nyx_getLocalRoot()

		if not Nyx_localRootForReturn or not Nyx_eggRuntime or Nyx_eggRuntime:_isInSafeArea(Nyx_localRootForReturn) then
			return
		end

		local Nyx_safeCFrameForReturn = Nyx_eggRuntime:_resolveSafeCFrame(Nyx_localRootForReturn)

		if Nyx_safeCFrameForReturn then
			Nyx_BloomRuntime.status = "Back to the safe zone"
			Nyx_travelToBloomZone(Nyx_safeCFrameForReturn.Position, 60)
		end
	end

	Nyx_BloomRuntime.claimNet = function()
		local NetStand, Nyx_netClaimError = Nyx_visitButterflyStation("NetStand")

		if not NetStand then
			return false, Nyx_netClaimError
		end

		Nyx_BloomRuntime.status = "Claiming the net"

		local _, Nyx_netStandPart = Nyx_findButterflyStation("NetStand")
		local Butterflies, Nyx_netClaimErrorText

		if Nyx_netStandPart then
			local ProximityPrompt = Nyx_netStandPart:FindFirstChildWhichIsA("ProximityPrompt", true)

			if ProximityPrompt and ProximityPrompt.Enabled then
				Nyx_firePrompt(ProximityPrompt)

				local Nyx_netClaimDeadline = os.clock() + 2

				while true do
					if not (os.clock() < Nyx_netClaimDeadline) then
						Butterflies, Nyx_netClaimErrorText = Nyx_callButterflyRemote("Butterflies", "AskClaimNet")

						return Butterflies, Nyx_netClaimErrorText
					end

					if not Nyx_BloomRuntime.snapshot().net then
						task.wait(0.1)

						continue
					end

					break
				end

				return true
			end
		end

		Butterflies, Nyx_netClaimErrorText = Nyx_callButterflyRemote("Butterflies", "AskClaimNet")

		return Butterflies, Nyx_netClaimErrorText
	end
	Nyx_BloomRuntime.tradeUp = function()
		Nyx_BloomRuntime.snapshot()

		if not Nyx_BloomRuntime.canTrade() then
			return false, "nothing to trade up"
		end

		local ButterflyMachine, Nyx_butterflyMachineError = Nyx_visitButterflyStation("ButterflyMachine")

		if not ButterflyMachine then
			return false, Nyx_butterflyMachineError
		end

		local Nyx_butterflyTiersForTrade = Nyx_BloomRuntime.tiers()
		local ButterflyTradeRecipe = NyxConfig.ButterflyTradeRecipe
		local Nyx_returnToSafeArea_var1 = 0

		if ButterflyTradeRecipe == "Smart" then
			local Nyx_simulatedTierCounts = table.clone(Nyx_BloomRuntime.snap.counts)
			local Nyx_tradeUpError

			while true do
				if Nyx_returnToSafeArea_var1 < 50 then
					local Nyx_nextTradeTier = Nyx_BloomRuntime.smartNext(Nyx_simulatedTierCounts)

					if not Nyx_nextTradeTier then
						return true, Nyx_returnToSafeArea_var1
					end

					Nyx_BloomRuntime.status = "Trading up " .. Nyx_butterflyTiersForTrade[Nyx_nextTradeTier].name .. " for the essence"

					local Butterflies

					Butterflies, Nyx_tradeUpError = Nyx_callButterflyRemote("Butterflies", "AskTradeUp", Nyx_nextTradeTier)

					if not Butterflies then
						break
					end

					Nyx_returnToSafeArea_var1 += 1
					Nyx_simulatedTierCounts[Nyx_nextTradeTier] = (Nyx_simulatedTierCounts[Nyx_nextTradeTier] or 0) - Nyx_butterflyTiersForTrade[Nyx_nextTradeTier].trade

					local Nyx_nextTierAfterTrade = Nyx_BLOOM_TIERS[Nyx_butterflyTierOrder[Nyx_nextTradeTier] + 1]

					Nyx_simulatedTierCounts[Nyx_nextTierAfterTrade] = (Nyx_simulatedTierCounts[Nyx_nextTierAfterTrade] or 0) + 1
					task.wait(0.12)
				else
					return true, Nyx_returnToSafeArea_var1
				end
			end

			if Nyx_returnToSafeArea_var1 == 0 then
				return false, Nyx_tradeUpError or "the machine refused"
			end

			return true, Nyx_returnToSafeArea_var1
		end

		local Nyx_tradeRecipeError

		for i = 3, 1, -1 do
			local Nyx_butterflyTierForTrade = Nyx_BLOOM_TIERS[i]

			if ButterflyTradeRecipe ~= nil and ButterflyTradeRecipe ~= "All" and ButterflyTradeRecipe ~= Nyx_butterflyTierForTrade then
				continue
			end

			local Nyx_currentTierCount = Nyx_BloomRuntime.snap.counts[Nyx_butterflyTierForTrade] or 0
			local trade = Nyx_butterflyTiersForTrade[Nyx_butterflyTierForTrade].trade
			local exitTo

			while trade > 0 and trade <= Nyx_currentTierCount do
				Nyx_BloomRuntime.status = "Trading up " .. Nyx_butterflyTiersForTrade[Nyx_butterflyTierForTrade].name

				local Butterflies

				Butterflies, Nyx_tradeRecipeError = Nyx_callButterflyRemote("Butterflies", "AskTradeUp", Nyx_butterflyTierForTrade)

				if not Butterflies then
					exitTo = 1

					break
				end

				Nyx_returnToSafeArea_var1 += 1
				Nyx_currentTierCount -= trade
				task.wait(0.12)
			end

			if exitTo == 1 then
				if Nyx_returnToSafeArea_var1 == 0 then
					return false, Nyx_tradeRecipeError or "the machine refused"
				end
			end
		end

		return true, Nyx_returnToSafeArea_var1
	end
	Nyx_BloomRuntime.craft = function()
		Nyx_BloomRuntime.snapshot()

		local Nyx_canCraftResult, Nyx_craftMissingTier = Nyx_BloomRuntime.canCraft()

		if not Nyx_canCraftResult then
			local Nyx_butterflyTiersForCraft = Nyx_BloomRuntime.tiers()

			return false, "need more " .. tostring(Nyx_butterflyTiersForCraft and Nyx_butterflyTiersForCraft[Nyx_craftMissingTier] and Nyx_butterflyTiersForCraft[Nyx_craftMissingTier].name or Nyx_craftMissingTier)
		end

		local MutationShrine, Nyx_mutationShrineError = Nyx_visitButterflyStation("MutationShrine")

		if not MutationShrine then
			return false, Nyx_mutationShrineError
		end

		local Nyx_returnToSafeArea_var2 = 0
		local Nyx_craftErrorText

		while true do
			if Nyx_returnToSafeArea_var2 < 10 and Nyx_BloomRuntime.canCraft() then
				Nyx_BloomRuntime.status = "Crafting Enchanted Essence"

				local Butterflies

				Butterflies, Nyx_craftErrorText = Nyx_callButterflyRemote("Butterflies", "AskCraftEssence")

				if not Butterflies then
					break
				end

				Nyx_returnToSafeArea_var2 += 1
				task.wait(0.2)
				Nyx_BloomRuntime.snapshot()
			else
				return true, Nyx_returnToSafeArea_var2
			end
		end

		if Nyx_returnToSafeArea_var2 == 0 then
			return false, Nyx_craftErrorText or "the shrine refused"
		end

		return true, Nyx_returnToSafeArea_var2
	end
	Nyx_BloomRuntime.tierOptions = function()
		local Nyx_butterflyTiersForLabels = Nyx_BloomRuntime.tiers()
		local Nyx_bloomTierLabels = {}

		for i = #Nyx_BLOOM_TIERS, 1, -1 do
			local Nyx_tierForLabels = Nyx_BLOOM_TIERS[i]

			Nyx_bloomTierLabels[#Nyx_bloomTierLabels + 1] = Nyx_butterflyTiersForLabels and Nyx_butterflyTiersForLabels[Nyx_tierForLabels].name or Nyx_tierForLabels
		end

		return Nyx_bloomTierLabels
	end
	Nyx_BloomRuntime.tierFromLabel = function(tierLabel)
		local Nyx_butterflyTiersForLookup = Nyx_BloomRuntime.tiers()

		for _, v in ipairs(Nyx_BLOOM_TIERS) do
			if tierLabel == v or Nyx_butterflyTiersForLookup and Nyx_butterflyTiersForLookup[v].name == tierLabel then
				return v
			end
		end

		return nil
	end
	Nyx_BloomRuntime.setTiers = function(tierList)
		local butterflyTiers = {}
		local ipairs_ = ipairs
		local Nyx_tierLabelsToSet = type(tierList) == "table" and tierList or {}

		for _, v in ipairs_(Nyx_tierLabelsToSet) do
			local Nyx_resolvedTierKey = Nyx_BloomRuntime.tierFromLabel(tostring(v))

			if Nyx_resolvedTierKey then
				butterflyTiers[#butterflyTiers + 1] = Nyx_resolvedTierKey
			end
		end

		NyxConfig.ButterflyTiers = butterflyTiers
	end

	local Nyx_bloomRecipes = {
		"All Recipes",
		"For Essence (shortfall only)",
		"Emerald to Sapphire",
		"Sapphire to Amethyst",
		"Amethyst to Radiant"
	}
	local Nyx_bloomRecipeMap = {
		["For Essence (shortfall only)"] = "Smart",
		["Emerald to Sapphire"] = "Green",
		["Sapphire to Amethyst"] = "Blue",
		["Amethyst to Radiant"] = "Purple"
	}

	Nyx_BloomRuntime.recipeOptions = function()
		return Nyx_bloomRecipes
	end
	Nyx_BloomRuntime.setRecipe = function(recipeLabel)
		NyxConfig.ButterflyTradeRecipe = Nyx_bloomRecipeMap[tostring(recipeLabel)] or "All"
	end

	local Nyx_bloomModes = {
		"Tween to Butterfly",
		"Stand",
		"Zigzag",
		"Circle"
	}
	local Nyx_bloomModeMap = {
		["Tween to Butterfly"] = "Tween",
		Stand = "Stand",
		Zigzag = "Zigzag",
		Circle = "Circle"
	}

	Nyx_BloomRuntime.modeOptions = function()
		return Nyx_bloomModes
	end
	Nyx_BloomRuntime.setMode = function(modeLabel)
		NyxConfig.ButterflyCatchMode = Nyx_bloomModeMap[tostring(modeLabel)] or "Tween"
	end

	local Folder

	local function Nyx_clearBloomEsp()
		for k, card in pairs(Nyx_BloomRuntime.cards) do
			pcall(function()
				card.part:Destroy()
			end)
			Nyx_BloomRuntime.cards[k] = nil
		end

		if Folder then
			pcall(function()
				Folder:Destroy()
			end)
			Folder = nil
		end
	end
	local function Nyx_updateBloomEsp()
		local CurrentCamera = workspace.CurrentCamera

		if not CurrentCamera then
			return
		end

		if not Folder or not Folder.Parent then
			Folder = Instance.new("Folder")
			Folder.Name = "NyxBloomEsp"
			Folder.Parent = CurrentCamera
		end

		local Nyx_butterflyTiersForEsp = Nyx_BloomRuntime.tiers() or {}
		local Nyx_localRootForEsp = Nyx_getLocalRoot()
		local Nyx_activeCards = {}

		for _, v in ipairs(Nyx_getSwarmButterflies()) do
			local Nyx_bloomEspKey = ("%d_%d_%d"):format(v.pos.X, v.pos.Y, v.pos.Z)

			Nyx_activeCards[Nyx_bloomEspKey] = true

			local Nyx_bloomEspCard = Nyx_BloomRuntime.cards[Nyx_bloomEspKey]

			if not Nyx_bloomEspCard or not Nyx_bloomEspCard.part.Parent then
				local Part = Instance.new("Part")

				Part.Size = Vector3.new(0.2, 0.2, 0.2)
				Part.Anchored = true
				Part.CanCollide = false
				Part.CanQuery = false
				Part.CanTouch = false
				Part.Transparency = 1
				Part.Parent = Folder

				local BillboardGui = Instance.new("BillboardGui")

				BillboardGui.Adornee = Part
				BillboardGui.Size = UDim2.fromOffset(120, 20)
				BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 1.6, 0)
				BillboardGui.AlwaysOnTop = true
				BillboardGui.MaxDistance = 260
				BillboardGui.Parent = Part

				local TextLabel = Instance.new("TextLabel")

				TextLabel.Size = UDim2.fromScale(1, 1)
				TextLabel.BackgroundTransparency = 1
				TextLabel.Font = Enum.Font.GothamBold
				TextLabel.TextSize = 13
				TextLabel.TextStrokeTransparency = 0.35
				TextLabel.Parent = BillboardGui
				Nyx_bloomEspCard = {
					part = Part,
					label = TextLabel
				}
				Nyx_BloomRuntime.cards[Nyx_bloomEspKey] = Nyx_bloomEspCard
			end

			Nyx_bloomEspCard.part.CFrame = cFrameNew(v.pos)

			local Nyx_bloomTierData = Nyx_butterflyTiersForEsp[v.tier]

			Nyx_bloomEspCard.label.TextColor3 = Nyx_bloomTierData and Nyx_bloomTierData.color or Color3.new(1, 1, 1)

			local label = Nyx_bloomEspCard.label
			local Nyx_bloomEspLabel = Nyx_localRootForEsp

			if Nyx_bloomEspLabel then
				Nyx_bloomEspLabel = ("%s  %dm"):format(Nyx_bloomTierData and Nyx_bloomTierData.name or v.tier, math.floor((v.pos - Nyx_localRootForEsp.Position).Magnitude))
			end

			label.Text = Nyx_bloomEspLabel or Nyx_bloomTierData and Nyx_bloomTierData.name or v.tier
		end

		for k, card in pairs(Nyx_BloomRuntime.cards) do
			if not Nyx_activeCards[k] then
				pcall(function()
					card.part:Destroy()
				end)
				Nyx_BloomRuntime.cards[k] = nil
			end
		end
	end

	local Nyx_BloomCatcher

	Nyx_BloomCatcher = {
		target = nil,
		since = 0,
		swinging = false,
		skip = setmetatable({}, {
			__mode = "k"
		}),
		pos = function(model)
			if not model or not model.Parent then
				return nil
			end

			local ok, result = pcall(function()
				return model.PrimaryPart and model.PrimaryPart.Position or model:GetPivot().Position
			end)
			local Nyx_resolvedPos = ok and result or nil

			return Nyx_resolvedPos
		end,
		pick = function(originPos)
			local ButterflyBloomSwarm = workspace:FindFirstChild("ButterflyBloomSwarm")

			if not ButterflyBloomSwarm then
				return nil
			end

			local Nyx_activeTierFilter = Nyx_getTierFilterSet()
			local now = os.clock()
			local Nyx_bestButterfly
			local Nyx_bestButterflyScore

			for _, child in ipairs(ButterflyBloomSwarm:GetChildren()) do
				if child:IsA("Model") and Nyx_butterflyTierOrder[child.Name] and (not Nyx_activeTierFilter or Nyx_activeTierFilter[child.Name]) then
					if (Nyx_BloomCatcher.skip[child] or 0) <= now then
						local Nyx_butterflyPos = Nyx_BloomCatcher.pos(child)

						if Nyx_butterflyPos then
							local Nyx_butterflyScore = (Nyx_butterflyTierOrder[child.Name] == 4 and 1000000 or 0) - (Nyx_butterflyPos - originPos).Magnitude

							if not Nyx_bestButterflyScore or Nyx_bestButterflyScore < Nyx_butterflyScore then
								Nyx_bestButterfly = child
								Nyx_bestButterflyScore = Nyx_butterflyScore
							end
						end
					end
				end
			end

			return Nyx_bestButterfly
		end,
		gain = function()
			local ok, result = pcall(Nyx_getButterflyModules().Save.Peek)
			local Nyx_caughtDelta = ok and result and result.Butterflies and tonumber(result.Butterflies.TotalCaught)

			return Nyx_caughtDelta and Nyx_BloomRuntime.bloomBase and math.max(0, Nyx_caughtDelta - Nyx_BloomRuntime.bloomBase) or 0
		end
	}
	Nyx_BloomCatcher.swing = function(butterflyModel, originPos)
		if Nyx_BloomCatcher.swinging then
			return
		end

		local Nyx_swingCooldown = tonumber(Nyx_readButterflyFlag("SwingCooldownSeconds", 0.45)) or 0.45

		if os.clock() - Nyx_BloomRuntime.lastSwing < Nyx_swingCooldown then
			return
		end

		local Nyx_butterflySwarm = Nyx_getButterflyModules()

		if not Nyx_butterflySwarm or not Nyx_butterflySwarm.Swarm or not Nyx_butterflySwarm.Swarm.Nearest then
			return
		end

		local ok, result = pcall(Nyx_butterflySwarm.Swarm.Nearest, originPos, Vector3.new(0, 0, -1), 4)
		local Flight = ok and result and result.Flight

		if not Flight or not Flight.Id then
			return
		end

		if Flight.Tier ~= nil and tostring(Flight.Tier) ~= butterflyModel.Name then
			return
		end

		Nyx_BloomRuntime.lastSwing = os.clock()
		Nyx_BloomCatcher.swinging = true
		task.spawn(function()
			local _, _, Nyx_swingResult = Nyx_callButterflyRemote("Butterflies", "AskSwing", Flight.Id)

			Nyx_BloomCatcher.swinging = false

			if Nyx_swingResult ~= "Caught" and Nyx_swingResult ~= "Gone" then
				Nyx_BloomCatcher.skip[butterflyModel] = os.clock() + 1.5
			end

			if Nyx_BloomCatcher.target == butterflyModel then
				Nyx_BloomCatcher.target = nil
			end

			local Nyx_butterflyTiersForStatus = Nyx_BloomRuntime.tiers()

			Nyx_BloomRuntime.status = ("%s %s  ·  +%d this Bloom"):format(Nyx_swingResult == "Caught" and "Caught" or "Chasing", Nyx_butterflyTiersForStatus and Nyx_butterflyTiersForStatus[butterflyModel.Name] and Nyx_butterflyTiersForStatus[butterflyModel.Name].name or butterflyModel.Name, Nyx_BloomCatcher.gain())
		end)
	end
	Nyx_BloomCatcher.prepare = function()
		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if not HumanoidRootPart or not Humanoid then
			return nil
		end

		Nyx_cleanupBloomPad()
		Nyx_purgeTrapsOnCharacter(Character)
		Nyx_startMovementLoop()
		Nyx_ensureHoverPad()

		local AutoRotate = Humanoid.AutoRotate

		Humanoid.AutoRotate = false

		return Character, HumanoidRootPart, Humanoid, AutoRotate
	end
	Nyx_BloomCatcher.release = function(rootPart, character, savedAutoRotate)
		Nyx_BloomCatcher.target = nil

		if character.Parent and savedAutoRotate ~= nil then
			character.AutoRotate = savedAutoRotate
		end

		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		Nyx_destroyHoverPad()
	end
	Nyx_BloomCatcher.keepGoing = function(rootPart, humanoid, mode)
		if not Nyx_isCurrentSession() or not NyxConfig.ButterflyAutoCatch or not (Nyx_BloomRuntime.bloomLeft() > 0) or not rootPart.Parent or not (humanoid.Health > 0) then
			return false
		end

		if (NyxConfig.ButterflyCatchMode or "Tween") == mode then
			return not (Nyx_BloomRuntime.manual or Nyx_isInEnchantedTree() or Nyx_isNightPhase() or Nyx_butterflyBlockers.blocker("butterfly") ~= nil)
		end

		return false
	end
	Nyx_BloomCatcher.moveStep = function(self, humanoid, rootPart, targetPos, lookAtPos, speed, dt)
		Nyx_setTargetWalkSpeed(self, speed * Nyx_CONFIG.HEADROOM)

		local Nyx_stealIntegrityState2 = Nyx_getEnv()[Nyx_CONFIG.INTEGRITY_KEY]
		local State = type(Nyx_stealIntegrityState2) == "table" and Nyx_stealIntegrityState2.State or nil

		if not Nyx_isOwnStateChecked(State, humanoid, rootPart) then
			rootPart.AssemblyLinearVelocity = Vector3.zero
			rootPart.AssemblyAngularVelocity = Vector3.zero
			Nyx_syncHoverPad(rootPart.Position)

			if Nyx_isOwnState(State, humanoid, rootPart) then
				Nyx_applyWalkSpeedToState(State, speed * Nyx_CONFIG.HEADROOM, Vector3.zero)
			else
				Nyx_installIntegritySpoof(humanoid, rootPart, speed)
			end

			return nil
		end

		local Position = rootPart.Position
		local Nyx_moveStepDelta = targetPos - Position
		local Nyx_moveStepDist = speed * dt
		local Nyx_moveStepNextPos = Nyx_moveStepDelta.Magnitude <= Nyx_moveStepDist and targetPos or Position + Nyx_moveStepDelta.Unit * Nyx_moveStepDist
		local Nyx_moveStepLookAt = (lookAtPos or targetPos) - Nyx_moveStepNextPos
		local vector32 = Vector3.new(Nyx_moveStepLookAt.X, 0, Nyx_moveStepLookAt.Z)

		if vector32.Magnitude <= 0.001 then
			vector32 = Vector3.new(Nyx_moveStepDelta.X, 0, Nyx_moveStepDelta.Z)
		end

		local Unit = vector32.Magnitude > 0.001 and vector32.Unit or rootPart.CFrame.LookVector
		local Nyx_moveStepVelocity = (Nyx_moveStepNextPos - Position) / dt

		Nyx_syncHoverPad(Nyx_moveStepNextPos)
		rootPart.CFrame = lookAt(Nyx_moveStepNextPos, Nyx_moveStepNextPos + Unit)
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero

		if not Nyx_updateIntegritySpoof(humanoid, rootPart, speed, Nyx_moveStepVelocity) then
			Nyx_installIntegritySpoof(humanoid, rootPart, speed)
			Nyx_updateIntegritySpoof(humanoid, rootPart, speed, Nyx_moveStepVelocity)
		end

		return Nyx_moveStepNextPos
	end
	Nyx_BloomCatcher.nearest = function(originPos, maxDist)
		local ButterflyBloomSwarm = workspace:FindFirstChild("ButterflyBloomSwarm")

		if not ButterflyBloomSwarm then
			return nil
		end

		local Nyx_activeTierFilter2 = Nyx_getTierFilterSet()
		local now = os.clock()
		local Nyx_nearestButterfly
		local Nyx_nearestButterflyPos
		local Nyx_nearestSearchRadius = maxDist

		for _, child in ipairs(ButterflyBloomSwarm:GetChildren()) do
			if child:IsA("Model") and Nyx_butterflyTierOrder[child.Name] and (not Nyx_activeTierFilter2 or Nyx_activeTierFilter2[child.Name]) then
				if (Nyx_BloomCatcher.skip[child] or 0) <= now then
					local Nyx_butterflyPos2 = Nyx_BloomCatcher.pos(child)
					local Magnitude = Nyx_butterflyPos2 and (Nyx_butterflyPos2 - originPos).Magnitude

					if Magnitude and Magnitude <= Nyx_nearestSearchRadius then
						Nyx_nearestButterfly = child
						Nyx_nearestButterflyPos = Nyx_butterflyPos2
						Nyx_nearestSearchRadius = Magnitude
					end
				end
			end
		end

		return Nyx_nearestButterfly, Nyx_nearestButterflyPos
	end
	Nyx_BloomCatcher.cluster = function(originPos)
		local ButterflyBloomSwarm = workspace:FindFirstChild("ButterflyBloomSwarm")
		local Nyx_clusterPositions = {}
		local ipairs_ = ipairs
		local children = ButterflyBloomSwarm and ButterflyBloomSwarm:GetChildren() or {}

		for _, child in ipairs_(children) do
			if child:IsA("Model") and Nyx_butterflyTierOrder[child.Name] then
				local Nyx_clusterButterflyPos = Nyx_BloomCatcher.pos(child)

				if Nyx_clusterButterflyPos then
					Nyx_clusterPositions[#Nyx_clusterPositions + 1] = Nyx_clusterButterflyPos
				end
			end
		end

		if #Nyx_clusterPositions == 0 then
			return nil, 0, 0
		end

		local Nyx_gain_var1 = 0

		for _, v in ipairs(Nyx_clusterPositions) do
			if originPos and (v - originPos).Magnitude <= 24 then
				Nyx_gain_var1 += 1
			end
		end

		local Nyx_clusterBestCenter
		local Nyx_clusterBestScore

		for _, v in ipairs(Nyx_clusterPositions) do
			local vector32 = Vector3.zero
			local Nyx_gain_var2 = 0

			for _, Nyx_item in ipairs(Nyx_clusterPositions) do
				if (v - Nyx_item).Magnitude <= 24 then
					vector32 += Nyx_item
					Nyx_gain_var2 += 1
				end
			end

			local Nyx_clusterAvgPos = vector32 / Nyx_gain_var2
			local Nyx_clusterScore = Nyx_gain_var2 * 100 - (originPos and (Nyx_clusterAvgPos - originPos).Magnitude or 0)

			if not Nyx_clusterBestScore or Nyx_clusterBestScore < Nyx_clusterScore then
				Nyx_clusterBestCenter = Nyx_clusterAvgPos
				Nyx_clusterBestScore = Nyx_clusterScore
			end
		end

		return Nyx_clusterBestCenter, #Nyx_clusterPositions, Nyx_gain_var1
	end
	Nyx_BloomCatcher.route = function(mode, centerPos, elapsedTime)
		if mode == "Circle" then
			local Nyx_routeAngle = elapsedTime * 2.0833333333333335

			return centerPos + Vector3.new(math.cos(Nyx_routeAngle) * 24, 0, math.sin(Nyx_routeAngle) * 24)
		end

		local Nyx_routeBounds = Nyx_getBloomBounds()

		if not (mode == "Zigzag" and Nyx_routeBounds) then
			return centerPos
		end

		local Nyx_routeHalfWidth = math.max(Nyx_routeBounds.Size.X / 2 - 12, 20)
		local Nyx_routeHalfDepth = math.clamp(Nyx_routeBounds.Size.Z / 2 - 12, 8, 30)
		local Nyx_routePhase = elapsedTime * 80 / math.sqrt((2 * Nyx_routeHalfWidth / 8) ^ 2 + (2 * Nyx_routeHalfDepth) ^ 2) % 16
		local Nyx_routeSector = math.floor(Nyx_routePhase)
		local Nyx_routeSectorFrac = Nyx_routePhase - Nyx_routeSector
		local Nyx_routeSideA = Nyx_routeSector <= 8 and Nyx_routeSector or 16 - Nyx_routeSector
		local Nyx_routeSideB = Nyx_routeSector + 1 <= 8 and Nyx_routeSector + 1 or 16 - (Nyx_routeSector + 1)
		local Nyx_routeX = -Nyx_routeHalfWidth + Nyx_routeSideA * (2 * Nyx_routeHalfWidth / 8)
		local Nyx_routeZ = Nyx_routeSector % 2 == 0 and -Nyx_routeHalfDepth or Nyx_routeHalfDepth
		local Nyx_routeWorldOffset = Nyx_routeBounds.CFrame:VectorToWorldSpace(Vector3.new(Nyx_routeX + (-Nyx_routeHalfWidth + Nyx_routeSideB * (2 * Nyx_routeHalfWidth / 8) - Nyx_routeX) * Nyx_routeSectorFrac, 0, Nyx_routeZ + (((Nyx_routeSector + 1) % 2 == 0 and -Nyx_routeHalfDepth or Nyx_routeHalfDepth) - Nyx_routeZ) * Nyx_routeSectorFrac))

		return Vector3.new(Nyx_routeBounds.Position.X + Nyx_routeWorldOffset.X, centerPos.Y, Nyx_routeBounds.Position.Z + Nyx_routeWorldOffset.Z)
	end
	Nyx_BloomCatcher.patrol = function(mode)
		local Nyx_patrolSelf, Nyx_patrolRoot, Nyx_patrolHumanoid, Nyx_patrolAutoRotate = Nyx_BloomCatcher.prepare()

		if not Nyx_patrolSelf then
			return false
		end

		local Nyx_patrolNetReach = tonumber(Nyx_readButterflyFlag("NetReach", 14)) or 14
		local Nyx_patrolLabel = ({
			Stand = "Standing in the swarm",
			Zigzag = "Zigzag patrol",
			Circle = "Circling the swarm"
		})[mode] or mode
		local Nyx_patrolClusterCenter
		local Nyx_gain_var3 = 0
		local now = os.clock()
		local Nyx_patrolEmptySince
		local Nyx_patrolMoved = false
		local Nyx_gain_var4 = 0

		while Nyx_BloomCatcher.keepGoing(Nyx_patrolRoot, Nyx_patrolHumanoid, mode) do
			local Nyx_patrolFrameDelta = math.max(math.min(RunService.Heartbeat:Wait(), 0.15), 0.0041666666666666666)
			local now2 = os.clock()

			if Nyx_gain_var3 <= now2 then
				local Nyx_patrolClusterPos, Nyx_patrolClusterCount, Nyx_patrolClusterNearby = Nyx_BloomCatcher.cluster(Nyx_patrolClusterCenter)

				Nyx_gain_var3 = now2 + 1.5

				if Nyx_patrolClusterCount == 0 then
					Nyx_patrolEmptySince = Nyx_patrolEmptySince or now2
				else
					Nyx_patrolEmptySince = nil

					if mode == "Stand" then
						if not Nyx_patrolClusterCenter or Nyx_patrolClusterNearby < 3 then
							Nyx_patrolClusterCenter = Nyx_patrolClusterPos
						end
					else
						Nyx_patrolClusterCenter = Nyx_patrolClusterCenter and Nyx_patrolClusterCenter:Lerp(Nyx_patrolClusterPos, 0.5) or Nyx_patrolClusterPos
					end
				end
			end

			if Nyx_patrolEmptySince and now2 - Nyx_patrolEmptySince > 2 then
				break
			end

			if Nyx_patrolClusterCenter then
				Nyx_patrolMoved = true

				local Nyx_patrolRouteTarget = Nyx_BloomCatcher.route(mode, Nyx_patrolClusterCenter, now2 - now)
				local huge = (Nyx_patrolRouteTarget - Nyx_patrolRoot.Position).Magnitude > 40 and math.huge or mode == "Stand" and 60 or mode == "Circle" and 70 or 110
				local Nyx_patrolSpeed = math.clamp(math.min(Nyx_getTweenSpeed(), huge), Nyx_CONFIG.MIN_SPEED, Nyx_CONFIG.MAX_SPEED)
				local Nyx_patrolNearestButterfly, Nyx_patrolNearestPos = Nyx_BloomCatcher.nearest(Nyx_patrolRoot.Position, Nyx_patrolNetReach + 6)
				local Nyx_patrolMovedPos = Nyx_BloomCatcher.moveStep(Nyx_patrolSelf, Nyx_patrolHumanoid, Nyx_patrolRoot, Nyx_patrolRouteTarget, Nyx_patrolNearestPos, Nyx_patrolSpeed, Nyx_patrolFrameDelta)

				if Nyx_patrolMovedPos and Nyx_patrolNearestButterfly and (Nyx_patrolNearestPos - Nyx_patrolMovedPos).Magnitude <= Nyx_patrolNetReach - 1.5 then
					Nyx_BloomCatcher.swing(Nyx_patrolNearestButterfly, Nyx_patrolNearestPos)
				end

				if Nyx_gain_var4 <= now2 and not Nyx_BloomCatcher.swinging then
					Nyx_gain_var4 = now2 + 1
					Nyx_BloomRuntime.status = ("%s  ·  +%d this Bloom"):format(Nyx_patrolLabel, Nyx_BloomCatcher.gain())
				end
			else
				Nyx_patrolRoot.AssemblyLinearVelocity = Vector3.zero
				Nyx_patrolRoot.AssemblyAngularVelocity = Vector3.zero
				Nyx_syncHoverPad(Nyx_patrolRoot.Position)
			end
		end

		Nyx_BloomCatcher.release(Nyx_patrolRoot, Nyx_patrolHumanoid, Nyx_patrolAutoRotate)

		return Nyx_patrolMoved
	end
	Nyx_BloomCatcher.run = function()
		local Nyx_huntSelf, Nyx_huntRoot, Nyx_huntHumanoid, Nyx_huntAutoRotate = Nyx_BloomCatcher.prepare()

		if not Nyx_huntSelf then
			return false
		end

		local Nyx_huntNetReach = tonumber(Nyx_readButterflyFlag("NetReach", 14)) or 14
		local Nyx_huntDodgeRadius = math.min(Nyx_huntNetReach - 3, (tonumber(Nyx_readButterflyFlag("DodgeRadius", 9)) or 9) + 1)
		local now
		local Nyx_huntMoved = false

		while Nyx_BloomCatcher.keepGoing(Nyx_huntRoot, Nyx_huntHumanoid, "Tween") do
			local Nyx_huntFrameDelta = math.max(math.min(RunService.Heartbeat:Wait(), 0.15), 0.0041666666666666666)
			local target = Nyx_BloomCatcher.target
			local Nyx_huntTargetPos = Nyx_BloomCatcher.pos(target)

			if not Nyx_huntTargetPos or os.clock() - Nyx_BloomCatcher.since > 3 then
				if Nyx_huntTargetPos then
					Nyx_BloomCatcher.skip[target] = os.clock() + 2
				end

				target = Nyx_BloomCatcher.pick(Nyx_huntRoot.Position)

				local now2 = os.clock()

				Nyx_BloomCatcher.target = target
				Nyx_BloomCatcher.since = now2
				Nyx_huntTargetPos = Nyx_BloomCatcher.pos(target)

				if target then
					local Nyx_huntTiersForStatus = Nyx_BloomRuntime.tiers()

					Nyx_BloomRuntime.status = ("Chasing %s  ·  +%d this Bloom"):format(Nyx_huntTiersForStatus and Nyx_huntTiersForStatus[target.Name] and Nyx_huntTiersForStatus[target.Name].name or target.Name, Nyx_BloomCatcher.gain())
				end
			end

			if Nyx_huntTargetPos then
				now = nil
				Nyx_huntMoved = true

				local Nyx_huntSpeed = math.clamp(Nyx_getTweenSpeed(), Nyx_CONFIG.MIN_SPEED, Nyx_CONFIG.MAX_SPEED)
				local Nyx_huntDelta = Nyx_huntRoot.Position - Nyx_huntTargetPos
				local Nyx_huntMovedPos = Nyx_BloomCatcher.moveStep(Nyx_huntSelf, Nyx_huntHumanoid, Nyx_huntRoot, Nyx_huntDelta.Magnitude > 0.001 and Nyx_huntTargetPos + Nyx_huntDelta.Unit * Nyx_huntDodgeRadius or Nyx_huntTargetPos + Vector3.new(Nyx_huntDodgeRadius, 0, 0), Nyx_huntTargetPos, Nyx_huntSpeed, Nyx_huntFrameDelta)

				if Nyx_huntMovedPos and (Nyx_huntTargetPos - Nyx_huntMovedPos).Magnitude <= Nyx_huntNetReach - 1.5 then
					Nyx_BloomCatcher.swing(target, Nyx_huntTargetPos)
				end

				continue
			else
				now = now or os.clock()

				if not (os.clock() - now > 2) then
					Nyx_huntRoot.AssemblyLinearVelocity = Vector3.zero
					Nyx_huntRoot.AssemblyAngularVelocity = Vector3.zero
					Nyx_syncHoverPad(Nyx_huntRoot.Position)

					continue
				end
			end

			break
		end

		Nyx_BloomCatcher.release(Nyx_huntRoot, Nyx_huntHumanoid, Nyx_huntAutoRotate)

		return Nyx_huntMoved
	end

	local function Nyx_processBloomTick(snapshot)
		if Nyx_isInEnchantedTree() then
			Nyx_exitEnchantedTree()

			return
		end

		if not Nyx_isInBloomZone() then
			Nyx_cleanupBloomPad()

			if Nyx_isNightPhase() then
				Nyx_BloomRuntime.status = "Night - waiting to fly to the forest"

				return
			end

			if not Nyx_canRetry("area") then
				return
			end

			local Nyx_bloomZoneCenter = Nyx_getBloomZoneCenter()

			if not Nyx_bloomZoneCenter then
				Nyx_BloomRuntime.status = "Butterfly Bloom zone not found"
				Nyx_markRetryAt("area")

				return
			end

			Nyx_BloomRuntime.status = "Flying to the Butterfly Bloom"

			if not Nyx_travelToBloomZone(Nyx_bloomZoneCenter, 60) then
				Nyx_markRetryAt("area")
				Nyx_BloomRuntime.status = "Could not reach the Enchanted Forest"
			end

			return
		end

		local __NyxTreadmillManager = genv.__NyxTreadmillManager

		if __NyxTreadmillManager and __NyxTreadmillManager.activeTreadmill ~= nil then
			Nyx_leaveTreadmill()
		end

		if not snapshot.holding and not Nyx_equipNetTool() then
			Nyx_BloomRuntime.status = "Butterfly Net is not in your backpack"

			return
		end

		local ButterflyCatchMode = NyxConfig.ButterflyCatchMode or "Tween"
		local Nyx_huntResult

		if ButterflyCatchMode == "Tween" then
			Nyx_huntResult = Nyx_BloomCatcher.run()
		else
			Nyx_huntResult = Nyx_BloomCatcher.patrol(ButterflyCatchMode)
		end

		if not Nyx_huntResult then
			Nyx_updateBloomPad()
			Nyx_BloomRuntime.status = ("Waiting for butterflies  ·  +%d this Bloom"):format(Nyx_BloomCatcher.gain())
		end
	end
	local function Nyx_bloomStatusText(snapshot)
		if not snapshot.net then
			return snapshot.treeUnlocked and "No Butterfly Net yet" or "Enchanted Tree locked - finish the Wisp Event"
		end

		if snapshot.active then
			return "Bloom is live"
		end

		if snapshot.nextIn then
			return ("Next Bloom in %dm %02ds"):format(math.floor(snapshot.nextIn / 60), math.floor(snapshot.nextIn % 60))
		end

		return "Idle"
	end
	local function Nyx_processBloomState()
		if Nyx_BloomRuntime.manual then
			return
		end

		local Nyx_bloomSnapshot = Nyx_BloomRuntime.snapshot()

		if Nyx_bloomSnapshot.active then
			Nyx_BloomRuntime.bloomBase = Nyx_BloomRuntime.bloomBase or Nyx_bloomSnapshot.caught
		else
			Nyx_BloomRuntime.bloomBase = nil
		end

		if NyxConfig.ButterflyEsp and Nyx_bloomSnapshot.active then
			Nyx_updateBloomEsp()
		elseif next(Nyx_BloomRuntime.cards) or Folder then
			Nyx_clearBloomEsp()
		end

		local Nyx_task

		if NyxConfig.ButterflyAutoNet and not Nyx_bloomSnapshot.net and Nyx_bloomSnapshot.treeUnlocked and Nyx_canRetry("net") then
			Nyx_task = "net"
		elseif NyxConfig.ButterflyAutoCatch and Nyx_bloomSnapshot.active and Nyx_bloomSnapshot.net then
			Nyx_task = "catch"
		elseif not Nyx_bloomSnapshot.active and NyxConfig.ButterflyAutoTrade and Nyx_bloomSnapshot.net and Nyx_BloomRuntime.canTrade() and Nyx_canRetry("trade") then
			Nyx_task = "trade"
		elseif not Nyx_bloomSnapshot.active and NyxConfig.ButterflyAutoCraft and Nyx_bloomSnapshot.net and Nyx_BloomRuntime.canCraft() and Nyx_canRetry("craft") then
			Nyx_task = "craft"
		end

		Nyx_BloomRuntime.wantsCharacter = Nyx_task ~= nil

		local butterfly = Nyx_task and Nyx_butterflyBlockers.blocker("butterfly") or nil
		local butterfly2 = Nyx_task and not butterfly and Nyx_butterflyBlockers.holder("butterfly") or nil
		local active = Nyx_BloomRuntime.active

		Nyx_BloomRuntime.active = Nyx_task ~= nil and butterfly == nil and butterfly2 == nil

		if Nyx_task and not Nyx_BloomRuntime.active then
			Nyx_cleanupBloomPad()

			if butterfly and Nyx_isInEnchantedTree() then
				Nyx_BloomRuntime.status = "Leaving the tree for " .. Nyx_butterflyBlockers.TITLES[butterfly]
				Nyx_exitEnchantedTree()
			end

			Nyx_BloomRuntime.status = butterfly and "Yielding to " .. Nyx_butterflyBlockers.TITLES[butterfly] or "Waiting for " .. Nyx_butterflyBlockers.TITLES[butterfly2] .. " to hand over"

			return
		end

		if not Nyx_task then
			if active then
				Nyx_returnToSafeArea()
			end

			Nyx_cleanupBloomPad()
			Nyx_BloomRuntime.status = Nyx_bloomStatusText(Nyx_bloomSnapshot)

			return
		end

		if not active then
			Nyx_leaveTreadmill()
		end

		if Nyx_task == "net" then
			local Nyx_netClaimOk, Nyx_netClaimErr = Nyx_BloomRuntime.claimNet()
			local status = Nyx_netClaimOk and "Butterfly Net claimed"

			if not status then
				status = "Net: " .. tostring(Nyx_netClaimErr or "refused")
			end

			Nyx_BloomRuntime.status = status

			if not Nyx_netClaimOk then
				Nyx_markRetryAt("net")
			end
		elseif Nyx_task == "catch" then
			Nyx_processBloomTick(Nyx_bloomSnapshot)
		elseif Nyx_task == "trade" then
			local status, Nyx_tradeCount = Nyx_BloomRuntime.tradeUp()

			if status then
				status = ("Traded up %d time(s)"):format(tonumber(Nyx_tradeCount) or 0)
			end

			Nyx_BloomRuntime.status = status or "Trade: " .. tostring(Nyx_tradeCount)
			Nyx_markRetryAt("trade")
		elseif Nyx_task == "craft" then
			local status, Nyx_craftCount = Nyx_BloomRuntime.craft()

			if status then
				status = ("Crafted %d Enchanted Essence"):format(tonumber(Nyx_craftCount) or 0)
			end

			Nyx_BloomRuntime.status = status or "Craft: " .. tostring(Nyx_craftCount)
			Nyx_markRetryAt("craft")
		end
	end

	task.spawn(function()
		while Nyx_isCurrentSession() do
			local ok, result = pcall(Nyx_processBloomState)

			if not ok then
				Nyx_BloomRuntime.active = false
				Nyx_BloomRuntime.wantsCharacter = false
				Nyx_cleanupBloomPad()
				Nyx_BloomRuntime.status = "Error: " .. tostring(result)
				task.wait(1)
			end

			task.wait(0.2)
		end

		Nyx_cleanupBloomPad()
		Nyx_clearBloomEsp()
	end)
	genv.__NyxButterflyRuntime = Nyx_BloomRuntime
end

Nyx_butterflyFactory()

local function Nyx_getIsBatKeywords()
	local Nyx_getIsBatKeywords_var1

	local function Nyx_getBatKeywordSet()
		if Nyx_getIsBatKeywords_var1 then
			return Nyx_getIsBatKeywords_var1
		end

		local Nyx_batKeywords = {}

		pcall(function()
			for _, child in ipairs(ReplicatedStorage.Data.Gears.Configs:GetChildren()) do
				local ok, result = pcall(require, child)

				if ok and type(result) == "table" and type(result.BatControllerData) == "table" then
					for _, v in ipairs({
						child.Name,
						result._id,
						result.DisplayName,
						result.ToolModel
					}) do
						if type(v) == "string" then
							Nyx_batKeywords[v:lower()] = true
						end
					end
				end
			end
		end)

		if next(Nyx_batKeywords) then
			Nyx_getIsBatKeywords_var1 = Nyx_batKeywords
		end

		return Nyx_batKeywords
	end
	local function Nyx_isBatToolCheck(tool)
		if not tool or not tool:IsA("Tool") then
			return false
		end

		if tool:GetAttribute("IsBat") == true then
			return true
		end

		local attribute = tool:GetAttribute("ItemType")

		if attribute ~= nil and attribute ~= "Gear" then
			return false
		end

		local Nyx_batKeywordSet = Nyx_getBatKeywordSet()
		local Nyx_toolGearName = tostring(tool:GetAttribute("GearName") or ""):lower()
		local Nyx_toolCleanName = tostring(tool.Name or ""):gsub("%s*%[.-%]%s*$", ""):lower()

		if Nyx_batKeywordSet[Nyx_toolGearName] or Nyx_batKeywordSet[Nyx_toolCleanName] then
			return true
		end

		return attribute == "Gear" and (Nyx_toolGearName:find("bat", 1, true) ~= nil or Nyx_toolCleanName:find("bat", 1, true) ~= nil)
	end

	return Nyx_isBatToolCheck
end

genv.__NyxIsBatTool = Nyx_getIsBatKeywords()

do
	local Players2 = game:GetService("Players")
	local RunService2 = game:GetService("RunService")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local LocalPlayer2 = Players2.LocalPlayer
	local Nyx_AutoCapture = {
		pinConn = nil,
		holding = false,
		status = "Idle"
	}

	local function Nyx_getEggStateModule()
		local ok, result = pcall(require, ReplicatedStorage2.Client.EggState)

		return ok and result or nil
	end
	local function Nyx_getRemotesModule()
		local ok, result = pcall(require, ReplicatedStorage2.Shared.Remotes)

		return ok and result or nil
	end
	local function Nyx_getAreaEggStates()
		local ok, result = pcall(require, ReplicatedStorage2.Shared.Types.AreaEggs)

		return ok and result and result.States or nil
	end
	local function Nyx_getCaptureRoot()
		local Character = LocalPlayer2.Character

		return Character and Character:FindFirstChild("HumanoidRootPart")
	end
	local function Nyx_getCaptureHumanoid()
		local Character = LocalPlayer2.Character

		return Character and Character:FindFirstChildOfClass("Humanoid")
	end
	local function Nyx_getCaptureEggUid()
		return workspace:GetAttribute("Event_CaptureTheEggUid")
	end
	local function Nyx_getCaptureRecord(uid)
		if not uid then
			return nil
		end

		local Nyx_eggStateModule = Nyx_getEggStateModule()

		if not Nyx_eggStateModule then
			return nil
		end

		local ok, result = pcall(Nyx_eggStateModule.ReadFieldEgg, uid)

		return ok and result or nil
	end
	local function Nyx_isEggCarriedByMe(uid, record)
		local Nyx_captureEggState = record or Nyx_getCaptureRecord(uid)
		local Nyx_captureEggStates = Nyx_getAreaEggStates()

		if Nyx_captureEggState and Nyx_captureEggStates then
			return Nyx_captureEggState.State == Nyx_captureEggStates.Carried and Nyx_captureEggState.CarrierUserId == LocalPlayer2.UserId
		end

		return false
	end
	local function Nyx_isEggSlotOrDropped(record)
		local Nyx_captureEggStates2 = Nyx_getAreaEggStates()

		if record and Nyx_captureEggStates2 then
			return record.State == Nyx_captureEggStates2.Slot or record.State == Nyx_captureEggStates2.Dropped
		end

		return false
	end
	local function Nyx_destroyCapturePlatform()
		local NyxCapturePlatform = workspace:FindFirstChild("NyxCapturePlatform")

		if NyxCapturePlatform then
			pcall(function()
				NyxCapturePlatform:Destroy()
			end)
		end
	end
	local function Nyx_updateCapturePlatform(rootPart)
		local Nyx_captureRootPos = rootPart or Nyx_getCaptureRoot()

		if not Nyx_captureRootPos then
			return
		end

		local NyxCapturePlatform = workspace:FindFirstChild("NyxCapturePlatform")

		if not NyxCapturePlatform then
			NyxCapturePlatform = Instance.new("Part")
			NyxCapturePlatform.Name = "NyxCapturePlatform"
			NyxCapturePlatform.Anchored = true
			NyxCapturePlatform.CanCollide = true
			NyxCapturePlatform.Size = Vector3.new(30, 1, 30)
			NyxCapturePlatform.Transparency = 0.5
			NyxCapturePlatform.Material = Enum.Material.Neon
			NyxCapturePlatform.Color = Color3.fromRGB(130, 90, 255)
			NyxCapturePlatform.TopSurface = Enum.SurfaceType.Smooth
			NyxCapturePlatform.BottomSurface = Enum.SurfaceType.Smooth
			NyxCapturePlatform.Parent = workspace
		end

		NyxCapturePlatform.CFrame = cFrameNew(Nyx_captureRootPos.Position.X, Nyx_captureRootPos.Position.Y - 3.4, Nyx_captureRootPos.Position.Z)
	end
	local function Nyx_startCapturePinLoop()
		if Nyx_AutoCapture.pinConn then
			return
		end

		Nyx_AutoCapture.pinConn = RunService2.PreSimulation:Connect(function()
			if not NyxConfig.AutoStealCapture then
				return
			end

			local Nyx_captureRootRef = Nyx_getCaptureRoot()

			if not Nyx_captureRootRef then
				return
			end

			if Nyx_captureRootRef.Position.Y < 89 then
				Nyx_captureRootRef.CFrame = cFrameNew(Nyx_captureRootRef.Position.X, 90, Nyx_captureRootRef.Position.Z) * Nyx_captureRootRef.CFrame.Rotation
			end

			Nyx_captureRootRef.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			Nyx_captureRootRef.AssemblyAngularVelocity = Vector3.zero
			Nyx_updateCapturePlatform(Nyx_captureRootRef)
		end)
	end
	local function Nyx_stopCapturePin()
		if Nyx_AutoCapture.pinConn then
			pcall(function()
				Nyx_AutoCapture.pinConn:Disconnect()
			end)
			Nyx_AutoCapture.pinConn = nil
		end

		Nyx_destroyCapturePlatform()
	end
	local function Nyx_flyToCaptureEgg(uid, record)
		local Nyx_captureRoot = Nyx_getCaptureRoot()
		local Nyx_captureHumanoid = Nyx_getCaptureHumanoid()

		if not Nyx_captureRoot or not Nyx_captureHumanoid or not record or not record.BottomCFrame then
			return false
		end

		Nyx_stopCapturePin()

		local Nyx_captureEggPos = record.BottomCFrame.Position + Vector3.new(0, 3, 0)

		Nyx_AutoCapture.status = "Flying to capture egg"
		pcall(Nyx_glideTo, Nyx_captureRoot, Nyx_captureHumanoid, cFrameNew(Nyx_captureEggPos) * Nyx_captureRoot.CFrame.Rotation, function()
			return not NyxConfig.AutoStealCapture or Nyx_getCaptureEggUid() ~= uid or Nyx_isEggCarriedByMe(uid)
		end)

		local Nyx_captureRootAfterFly = Nyx_getCaptureRoot()

		if not Nyx_captureRootAfterFly then
			return false
		end

		pcall(function()
			Nyx_captureRootAfterFly.AssemblyLinearVelocity = Vector3.zero
			Nyx_captureRootAfterFly.AssemblyAngularVelocity = Vector3.zero
		end)

		local Nyx_captureRemotes = Nyx_getRemotesModule()

		if not Nyx_captureRemotes or not Nyx_captureRemotes.EggWorld or not Nyx_captureRemotes.EggWorld.AskFieldEggCarry then
			return false
		end

		Nyx_AutoCapture.status = "Grabbing capture egg"

		local ok, result = pcall(function()
			return Nyx_captureRemotes.EggWorld.AskFieldEggCarry:InvokeServer({
				Uid = uid
			})
		end)
		local Nyx_captureOk = ok and result == true

		return Nyx_captureOk
	end

	task.spawn(function()
		while Nyx_isCurrentSession() do
			if NyxConfig.AutoStealCapture then
				if not pcall(function()
					local Nyx_captureEggUid = Nyx_getCaptureEggUid()
					local Nyx_captureEggRecord = Nyx_getCaptureRecord(Nyx_captureEggUid)

					if Nyx_captureEggUid and Nyx_isEggCarriedByMe(Nyx_captureEggUid, Nyx_captureEggRecord) then
						Nyx_AutoCapture.holding = true
						Nyx_AutoCapture.status = "Holding capture egg"
						Nyx_startCapturePinLoop()
					elseif Nyx_captureEggUid and Nyx_isEggSlotOrDropped(Nyx_captureEggRecord) then
						Nyx_AutoCapture.holding = false
						Nyx_flyToCaptureEgg(Nyx_captureEggUid, Nyx_captureEggRecord)
					elseif not Nyx_captureEggUid then
						Nyx_AutoCapture.holding = false

						if Nyx_AutoCapture.pinConn or workspace:FindFirstChild("NyxCapturePlatform") then
							Nyx_stopCapturePin()
						end

						Nyx_AutoCapture.status = "No capture event"
					elseif Nyx_AutoCapture.holding then
						Nyx_startCapturePinLoop()
						Nyx_AutoCapture.status = "Egg taken - holding position"
					else
						if Nyx_AutoCapture.pinConn or workspace:FindFirstChild("NyxCapturePlatform") then
							Nyx_stopCapturePin()
						end

						Nyx_AutoCapture.status = "Waiting for capture egg"
					end
				end) then
					Nyx_stopCapturePin()
				end

				task.wait(0.3)
			else
				if Nyx_AutoCapture.pinConn or workspace:FindFirstChild("NyxCapturePlatform") then
					Nyx_stopCapturePin()
				end

				Nyx_AutoCapture.holding = false
				Nyx_AutoCapture.status = "Idle"
				task.wait(0.5)
			end
		end
	end)
	genv.__NyxAutoCapture = Nyx_AutoCapture
end

do
	local Players2 = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local LocalPlayer2 = Players2.LocalPlayer

	local function Nyx_getSaveModule()
		local ok, result = pcall(require, ReplicatedStorage2.Shared.Save)

		return ok and result or nil
	end
	local function Nyx_getAssetsDirectory()
		local ok, result = pcall(require, ReplicatedStorage2.Data.Assets)

		if ok then
			return result.Directory or result
		end

		return nil
	end
	local function Nyx_genVisualId(kind)
		return "NyxVIS_" .. kind .. "_" .. tostring(math.floor(os.clock() * 1000)) .. "_" .. tostring(math.random(1, 1000000))
	end

	local Nyx_VisualSAE = {
		held = {},
		categories = function(category)
			local Nyx_assetsDirectory = Nyx_getAssetsDirectory()
			local Nyx_categories_var1 = {}

			if not Nyx_assetsDirectory then
				return Nyx_categories_var1
			end

			for k, v in pairs(Nyx_assetsDirectory) do
				if type(k) == "string" and type(v) == "table" and (category == "Pet" or v.Egg ~= nil) then
					Nyx_categories_var1[#Nyx_categories_var1 + 1] = k
				end
			end

			table.sort(Nyx_categories_var1)

			return Nyx_categories_var1
		end,
		spawnEgg = function(eggCategory, size)
			local Nyx_saveModule = Nyx_getSaveModule()
			local Nyx_assetsDirectory2 = Nyx_getAssetsDirectory()

			if not Nyx_saveModule or not Nyx_assetsDirectory2 or not Nyx_assetsDirectory2[eggCategory] then
				return nil
			end

			local Nyx_visualEggId = Nyx_genVisualId("E")

			pcall(function()
				Nyx_saveModule.Amend("EggInventory", function(eggInventory)
					eggInventory[Nyx_visualEggId] = {
						AssetCategory = eggCategory,
						AssetScale = tonumber(size) or 50,
						AssetColorIndex = 1,
						AssetColorSeed = math.random(1, 2e9),
						AssetEyeColor = "ffffff",
						HasParasite = false,
						Mutations = {}
					}
				end)
			end)

			return Nyx_visualEggId
		end,
		spawnPet = function(petCategory, petSize)
			local Nyx_saveModuleForPet = Nyx_getSaveModule()
			local Nyx_assetsDirectoryForPet = Nyx_getAssetsDirectory()

			if not Nyx_saveModuleForPet or not Nyx_assetsDirectoryForPet or not Nyx_assetsDirectoryForPet[petCategory] then
				return nil
			end

			local Nyx_visualPetId = Nyx_genVisualId("P")

			pcall(function()
				Nyx_saveModuleForPet.Amend("Inventory", function(petInventory)
					petInventory[Nyx_visualPetId] = {
						Category = petCategory,
						Scale = tonumber(petSize) or 50,
						ColorIndex = 1,
						ColorSeed = math.random(1, 2e9),
						EyeColor = "ffffff",
						Gender = "Male",
						Personality = "Normal",
						InFuse = false,
						HasBeenFirstPlaced = false,
						Mutations = {}
					}
				end)
			end)

			return Nyx_visualPetId
		end
	}

	local function Nyx_findEggModel(eggCategory)
		local Assets = ReplicatedStorage2:FindFirstChild("Assets")
		local Models = Assets and Assets:FindFirstChild("Models")
		local Eggs = Models and Models:FindFirstChild("Eggs")

		return Eggs and Eggs:FindFirstChild(eggCategory)
	end
	local function Nyx_findAssetModel(assetCategory)
		local AssetModels = ReplicatedStorage2:FindFirstChild("AssetModels")

		return AssetModels and AssetModels:FindFirstChild(assetCategory)
	end
	local function Nyx_clearHeldVisuals()
		for _, v in ipairs(Nyx_VisualSAE.held) do
			pcall(function()
				v:Destroy()
			end)
		end

		Nyx_VisualSAE.held = {}

		for _, v in ipairs({
			LocalPlayer2.Character,
			LocalPlayer2:FindFirstChild("Backpack")
		}) do
			if v then
				for _, child in ipairs(v:GetChildren()) do
					if child:IsA("Tool") then
						if child.Name:sub(1, 8) == "NyxVIS_" then
							pcall(function()
								child:Destroy()
							end)
						end
					end
				end
			end
		end
	end

	Nyx_VisualSAE.hold = function(category, isEgg, visualSize)
		local Character = LocalPlayer2.Character

		if not Character then
			return false
		end

		local Nyx_visualModelTemplate = isEgg and Nyx_findEggModel(category) or Nyx_findAssetModel(category)

		if not Nyx_visualModelTemplate then
			return false
		end

		local ok, result = pcall(function()
			return Nyx_visualModelTemplate:Clone()
		end)

		if not ok or not result or not result:IsA("Model") then
			return false
		end

		local PrimaryPart = result.PrimaryPart or result:FindFirstChildWhichIsA("BasePart")

		if not PrimaryPart then
			pcall(function()
				result:Destroy()
			end)

			return false
		end

		pcall(function()
			if not result.PrimaryPart then
				result.PrimaryPart = PrimaryPart
			end
		end)

		local Nyx_visualScale = math.clamp(1 + (tonumber(visualSize) or 50) / 70, 1, 2.4) * (0.85 + math.random() * 0.4)

		pcall(function()
			if result.ScaleTo then
				result:ScaleTo(Nyx_visualScale)
			end
		end)

		local vector32 = Vector3.new(3, 3, 3)

		pcall(function()
			vector32 = result:GetExtentsSize()
		end)

		local Tool = Instance.new("Tool")

		Tool.Name = "NyxVIS_" .. category
		Tool.RequiresHandle = true
		Tool.CanBeDropped = false

		local Nyx_assetsDirectoryForHold = Nyx_getAssetsDirectory()
		local Nyx_assetDefForHold = Nyx_assetsDirectoryForHold and Nyx_assetsDirectoryForHold[category]
		local Icon = Nyx_assetDefForHold and (isEgg and Nyx_assetDefForHold.Egg and Nyx_assetDefForHold.Egg.Icon or Nyx_assetDefForHold.Icon)

		if type(Icon) == "string" then
			pcall(function()
				Tool.TextureId = Icon
			end)
		end

		PrimaryPart.Name = "Handle"

		for _, descendant in ipairs(result:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Massless = true
				descendant.CanCollide = false
				descendant.Anchored = false

				if descendant ~= PrimaryPart then
					local WeldConstraint = Instance.new("WeldConstraint")

					WeldConstraint.Part0 = PrimaryPart
					WeldConstraint.Part1 = descendant
					WeldConstraint.Parent = PrimaryPart
				end
			end
		end

		for _, child in ipairs(result:GetChildren()) do
			child.Parent = Tool
		end

		PrimaryPart.Parent = Tool
		pcall(function()
			result:Destroy()
		end)
		pcall(function()
			Tool.Grip = cFrameNew(0, -(vector32.Y * 0.55), math.max(vector32.X, vector32.Z) * 0.5 + 0.5)
		end)
		Tool.Parent = LocalPlayer2:FindFirstChild("Backpack") or Character

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")

		if Humanoid then
			pcall(function()
				Humanoid:EquipTool(Tool)
			end)
		end

		Nyx_VisualSAE.held[#Nyx_VisualSAE.held + 1] = Tool

		return true
	end
	Nyx_VisualSAE.spawn = function(kind, category, spawnSize, holdInHand)
		if not category or category == "None" then
			return
		end

		local Nyx_visualSizeParam = tonumber(spawnSize) or 50

		if holdInHand then
			pcall(Nyx_VisualSAE.hold, category, kind ~= "Pet", Nyx_visualSizeParam)
		elseif kind == "Pet" then
			Nyx_VisualSAE.spawnPet(category, math.clamp(1 + Nyx_visualSizeParam / 25, 1.2, 5) * (0.85 + math.random() * 0.4))
		else
			Nyx_VisualSAE.spawnEgg(category, Nyx_visualSizeParam * (0.85 + math.random() * 0.5))
		end
	end
	Nyx_VisualSAE.clear = function()
		local Nyx_saveForVisualClear = Nyx_getSaveModule()

		if Nyx_saveForVisualClear then
			pcall(function()
				Nyx_saveForVisualClear.Amend("EggInventory", function(eggInventoryTable)
					for k in pairs(eggInventoryTable) do
						if type(k) == "string" and k:sub(1, 8) == "NyxVIS_" then
							eggInventoryTable[k] = nil
						end
					end
				end)
			end)
			pcall(function()
				Nyx_saveForVisualClear.Amend("Inventory", function(inventoryTable)
					for k in pairs(inventoryTable) do
						if type(k) == "string" and k:sub(1, 8) == "NyxVIS_" then
							inventoryTable[k] = nil
						end
					end
				end)
			end)
			pcall(function()
				Nyx_saveForVisualClear.Amend("EquippedAssets", function(equippedAssets)
					for i = #equippedAssets, 1, -1 do
						local Nyx_equippedVisualId = equippedAssets[i]

						if type(Nyx_equippedVisualId) == "string" and Nyx_equippedVisualId:sub(1, 8) == "NyxVIS_" then
							table.remove(equippedAssets, i)
						end
					end
				end)
			end)
		end

		for _, v in ipairs(Nyx_VisualSAE.held) do
			pcall(function()
				v:Destroy()
			end)
		end

		Nyx_VisualSAE.held = {}

		for _, v in ipairs({
			LocalPlayer2.Character,
			LocalPlayer2:FindFirstChild("Backpack")
		}) do
			if v then
				for _, child in ipairs(v:GetChildren()) do
					if child:IsA("Tool") then
						if child.Name:sub(1, 8) == "NyxVIS_" then
							pcall(function()
								child:Destroy()
							end)
						end
					end
				end
			end
		end
	end
	genv.__NyxVisualSAE = Nyx_VisualSAE
end

do
	local cameraMaxZoomDistance = (tonumber(game:GetService("StarterPlayer").CameraMaxZoomDistance) or 128) * 1.95

	local function Nyx_extendCameraZoom()
		if LocalPlayer.CameraMaxZoomDistance < cameraMaxZoomDistance then
			LocalPlayer.CameraMaxZoomDistance = cameraMaxZoomDistance
		end
	end

	pcall(Nyx_extendCameraZoom)
	LocalPlayer:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
		if Nyx_isCurrentSession() then
			pcall(Nyx_extendCameraZoom)
		end
	end)
end

do
	local function Nyx_visualRuntimeFactory()
		local HttpService = game:GetService("HttpService")
		local Nyx_VisualRuntime = {
			base = "http://56.10.112.179:8080/visual/",
			manifest = nil,
			status = "Idle",
			spawned = {},
			backs = {},
			backRod = nil,
			remote = {}
		}
		local Unit = Vector3.new(0.3, 0.75, 0.6).Unit
		local Nyx_visualPose = {
			RightShoulder = Angles(0.69813170079773179, 0, 0.17453292519943295),
			RightElbow = Angles(1.7453292519943295, 0, 0),
			RightWrist = cFrameNew(),
			LeftShoulder = cFrameNew(),
			LeftElbow = cFrameNew(),
			LeftWrist = cFrameNew()
		}
		local Nyx_visualBackWeldCF = cFrameNew(0.5, 1.3, 1, -0.7071, -0.7071, 0, -0.7071, 0.7071, 0, 0, 0, -1):Inverse()

		local function Nyx_ensureFolderRecursive(folderPath)
			local Nyx_ensureFolderRecursive_var1 = ""

			for match in string.gmatch(folderPath, "[^/]+") do
				Nyx_ensureFolderRecursive_var1 = Nyx_ensureFolderRecursive_var1 == "" and match or Nyx_ensureFolderRecursive_var1 .. "/" .. match

				if not isfolder(Nyx_ensureFolderRecursive_var1) then
					makefolder(Nyx_ensureFolderRecursive_var1)
				end
			end
		end
		local function Nyx_httpGet(httpUrl)
			local ok, result = pcall(function()
				return game:HttpGet(httpUrl, true)
			end)

			if not ok or type(result) ~= "string" or result == "" then
				return nil
			end

			return result
		end

		Nyx_VisualRuntime.loadManifest = function()
			if Nyx_VisualRuntime.manifest then
				return Nyx_VisualRuntime.manifest
			end

			Nyx_ensureFolderRecursive("NyxVisual/cache")

			local json = Nyx_httpGet(Nyx_VisualRuntime.base .. "manifest.json")

			if json then
				pcall(writefile, "NyxVisual/cache/manifest.json", json)
			elseif isfile("NyxVisual/cache/manifest.json") then
				json = readfile("NyxVisual/cache/manifest.json")
			end

			local ok, manifest = pcall(function()
				return HttpService:JSONDecode(json)
			end)

			if ok and type(manifest) == "table" then
				Nyx_VisualRuntime.manifest = manifest
			end

			return Nyx_VisualRuntime.manifest
		end
		Nyx_VisualRuntime.names = function(visualKind)
			local Nyx_httpGet_var1 = {}
			local Nyx_visualManifest = Nyx_VisualRuntime.loadManifest()
			local ipairs_ = ipairs
			local Nyx_visualNames = Nyx_visualManifest and Nyx_visualManifest[visualKind] or {}

			for _, v in ipairs_(Nyx_visualNames) do
				local name = v.name

				if v.tier then
					name = v.name .. " [" .. v.tier .. "]"
				end

				table.insert(Nyx_httpGet_var1, name)
			end

			return Nyx_httpGet_var1
		end

		local function Nyx_findVisualEntry(visualKind, visualName)
			local Nyx_visualManifest2 = Nyx_VisualRuntime.loadManifest()
			local ipairs_ = ipairs
			local Nyx_visualEntries = Nyx_visualManifest2 and Nyx_visualManifest2[visualKind] or {}

			for _, v in ipairs_(Nyx_visualEntries) do
				if v.name == visualName or v.name .. " [" .. tostring(v.tier) .. "]" == visualName then
					return v
				end
			end

			return nil
		end
		local function Nyx_loadVisualModel(visualKind, visualEntry)
			local Nyx_visualCachePath = "NyxVisual/cache" .. "/" .. visualKind

			Nyx_ensureFolderRecursive(Nyx_visualCachePath)

			local Nyx_visualModelFile = Nyx_visualCachePath .. "/" .. visualEntry.file

			if not isfile(Nyx_visualModelFile) then
				Nyx_VisualRuntime.status = "Downloading " .. visualEntry.name .. "..."

				local Nyx_visualModelData = Nyx_httpGet(Nyx_VisualRuntime.base .. visualKind .. "/" .. visualEntry.file)

				if not Nyx_visualModelData then
					return nil, "Download failed"
				end

				writefile(Nyx_visualModelFile, Nyx_visualModelData)
			end

			local ok, result = pcall(function()
				return game:GetObjects(getcustomasset(Nyx_visualModelFile))
			end)

			if not ok or not (type(result) == "table" and result[1]) then
				pcall(delfile, Nyx_visualModelFile)

				return nil, "Could not load model"
			end

			return result[1]
		end

		Nyx_VisualRuntime.rodScale = 1
		Nyx_VisualRuntime.fishWeight = 0

		local function Nyx_setupVisualModel(visualModel, baseScale, scaleFactor)
			local Nyx_visualParts = {}

			for _, descendant in ipairs(visualModel:GetDescendants()) do
				if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
					descendant:Destroy()
				elseif descendant:IsA("BasePart") then
					table.insert(Nyx_visualParts, descendant)
				elseif descendant:IsA("Script") or descendant:IsA("LocalScript") then
					descendant:Destroy()
				end
			end

			if #Nyx_visualParts == 0 then
				return nil
			end

			local Handle = visualModel:FindFirstChild("Handle", true)

			if not Handle or not Handle:IsA("BasePart") then
				Handle = Nyx_visualParts[1]
			end

			if baseScale or scaleFactor and scaleFactor ~= 1 then
				local boundingBox, Nyx_visualBoundingSize = visualModel:GetBoundingBox()
				local Nyx_visualScaleFactor = scaleFactor or baseScale / math.max(Nyx_visualBoundingSize.X, Nyx_visualBoundingSize.Y, Nyx_visualBoundingSize.Z, 0.01)

				if not baseScale then
					boundingBox = Handle.CFrame
				end

				for _, v in ipairs(Nyx_visualParts) do
					local Nyx_visualPartLocalCF = boundingBox:ToObjectSpace(v.CFrame)

					v.Size *= Nyx_visualScaleFactor
					v.CFrame = boundingBox * (cFrameNew(Nyx_visualPartLocalCF.Position * Nyx_visualScaleFactor) * Nyx_visualPartLocalCF.Rotation)
				end

				for _, descendant in ipairs(visualModel:GetDescendants()) do
					if descendant:IsA("Attachment") then
						if not descendant.Parent:IsA("Bone") then
							descendant.Position *= Nyx_visualScaleFactor
						end
					end
				end
			end

			for _, v in ipairs(Nyx_visualParts) do
				v.Anchored = false
				v.CanCollide = false
				v.CanQuery = false
				v.CanTouch = false
				v.Massless = true

				if v ~= Handle then
					local Weld = Instance.new("Weld")

					Weld.Part0 = Handle
					Weld.Part1 = v
					Weld.C0 = Handle.CFrame:ToObjectSpace(v.CFrame)
					Weld.Parent = Handle
				end
			end

			Handle.Name = "Handle"

			return Handle, Nyx_visualParts
		end
		local function Nyx_computeRodAxis(visualHandle, visualParts)
			local vector32 = Vector3.zero
			local vector33 = Vector3.zero

			for _, v in ipairs(visualParts) do
				if v ~= visualHandle and v.Transparency < 0.95 then
					local Nyx_visualPartHalfSize = v.Size / 2

					for _, Nyx_item in ipairs({
						-1,
						1
					}) do
						for _, Nyx_computeRodAxis_var1 in ipairs({
							-1,
							1
						}) do
							for _, Nyx_computeRodAxis_var2 in ipairs({
								-1,
								1
							}) do
								local Nyx_visualCornerLocal = visualHandle.CFrame:PointToObjectSpace(v.CFrame:PointToWorldSpace(Vector3.new(Nyx_visualPartHalfSize.X * Nyx_item, Nyx_visualPartHalfSize.Y * Nyx_computeRodAxis_var1, Nyx_visualPartHalfSize.Z * Nyx_computeRodAxis_var2)))

								vector32 = vector32:Min(Nyx_visualCornerLocal)
								vector33 = vector33:Max(Nyx_visualCornerLocal)
							end
						end
					end
				end
			end

			local Nyx_visualBoundsDelta = vector33 - vector32
			local vector34

			if Nyx_visualBoundsDelta.Y <= Nyx_visualBoundsDelta.X and Nyx_visualBoundsDelta.Z <= Nyx_visualBoundsDelta.X then
				vector34 = Vector3.new(vector33.X >= -vector32.X and 1 or -1, 0, 0)
			elseif Nyx_visualBoundsDelta.Z <= Nyx_visualBoundsDelta.Y then
				vector34 = Vector3.new(0, vector33.Y >= -vector32.Y and 1 or -1, 0)
			else
				vector34 = Vector3.new(0, 0, vector33.Z >= -vector32.Z and 1 or -1)
			end

			local vector35 = Vector3.xAxis

			if math.abs(vector34.X) > 0.5 then
				vector35 = Nyx_visualBoundsDelta.Z >= Nyx_visualBoundsDelta.Y and Vector3.zAxis or Vector3.yAxis
			elseif math.abs(vector34.Z) > 0.5 then
				vector35 = Nyx_visualBoundsDelta.X >= Nyx_visualBoundsDelta.Y and Vector3.xAxis or Vector3.yAxis
			end

			local Nyx_visualGripShift = -math.min(vector32:Dot(vector34), vector33:Dot(vector34))

			return fromMatrix(Vector3.zero, vector35, vector34), math.max(0, Nyx_visualGripShift - 0.6)
		end

		Nyx_VisualRuntime.updateBack = function()
			local Backpack = LocalPlayer:FindFirstChild("Backpack")

			for k, back in pairs(Nyx_VisualRuntime.backs) do
				back(k == Nyx_VisualRuntime.backRod and Backpack ~= nil and k.Parent == Backpack)
			end

			task.defer(Nyx_VisualRuntime.refreshQuality)
		end
		Nyx_VisualRuntime.refreshQuality = function()
			local Nyx_isAnyVisualActive = false
			local Character = LocalPlayer.Character

			if Character then
				for _, child in ipairs(Character:GetChildren()) do
					if child:IsA("Tool") and child:GetAttribute("NyxVisual") or child.Name == "NyxVisualBack" then
						Nyx_isAnyVisualActive = true

						break
					end
				end
			end

			if next(Nyx_VisualRuntime.remote) ~= nil then
				Nyx_isAnyVisualActive = true
			end

			pcall(function()
				if Nyx_isAnyVisualActive then
					settings().Rendering.QualityLevel = Enum.QualityLevel.Level10
				elseif NyxConfig.StartupBoost then
					settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
				end
			end)
		end

		local function Nyx_computeFishOverhead(fishModel, fishHandle, fishParts)
			local Nyx_boundsMinInit = Vector3.one * 1e9
			local Nyx_boundsMaxInit = -Vector3.one * 1e9
			local Nyx_fishPartsIter, Nyx_fishPartsIterState, Nyx_fishPartsIterControl = ipairs(fishParts)

			for _, v in Nyx_fishPartsIter, Nyx_fishPartsIterState, Nyx_fishPartsIterControl do
				local Nyx_fishPartHalfSize = v.Size / 2

				for _, Nyx_item in ipairs({
					-1,
					1
				}) do
					for _, Nyx_computeRodAxis_var1 in ipairs({
						-1,
						1
					}) do
						for _, Nyx_computeRodAxis_var2 in ipairs({
							-1,
							1
						}) do
							local Nyx_fishPartCorner = v.CFrame:PointToWorldSpace(Vector3.new(Nyx_fishPartHalfSize.X * Nyx_item, Nyx_fishPartHalfSize.Y * Nyx_computeRodAxis_var1, Nyx_fishPartHalfSize.Z * Nyx_computeRodAxis_var2))

							Nyx_boundsMinInit = Nyx_boundsMinInit:Min(Nyx_fishPartCorner)
							Nyx_boundsMaxInit = Nyx_boundsMaxInit:Max(Nyx_fishPartCorner)
						end
					end
				end
			end

			local Nyx_fishBoundsDelta = Nyx_boundsMaxInit - Nyx_boundsMinInit
			local Nyx_meshCorners = {}
			local Nyx_computeFishOverhead_var1 = 0
			local vector32 = Vector3.zero
			local Nyx_fishPartsIter2, Nyx_fishPartsIterState2, Nyx_fishPartsIterControl2 = ipairs(fishParts)

			for _, v in Nyx_fishPartsIter2, Nyx_fishPartsIterState2, Nyx_fishPartsIterControl2 do
				if v.Transparency < 0.95 then
					local Nyx_fishPartVolume = math.max(v.Size.X * v.Size.Y * v.Size.Z, 0.0001)
					local Nyx_fishPartHalfSize2 = v.Size / 2
					local huge = math.huge

					for _, Nyx_item in ipairs({
						-1,
						1
					}) do
						for _, Nyx_computeRodAxis_var1 in ipairs({
							-1,
							1
						}) do
							for _, Nyx_computeRodAxis_var2 in ipairs({
								-1,
								1
							}) do
								huge = math.min(huge, v.CFrame:PointToWorldSpace(Vector3.new(Nyx_fishPartHalfSize2.X * Nyx_item, Nyx_fishPartHalfSize2.Y * Nyx_computeRodAxis_var1, Nyx_fishPartHalfSize2.Z * Nyx_computeRodAxis_var2)).Y)
							end
						end
					end

					table.insert(Nyx_meshCorners, {
						y = huge,
						vol = Nyx_fishPartVolume
					})
					Nyx_computeFishOverhead_var1 += Nyx_fishPartVolume
					vector32 += v.Position * Nyx_fishPartVolume
				end
			end

			local Nyx_fishOverheadCenter = (Nyx_boundsMinInit + Nyx_boundsMaxInit) / 2 - Vector3.new(0, Nyx_fishBoundsDelta.Y / 2, 0)

			if Nyx_computeFishOverhead_var1 > 0 then
				table.sort(Nyx_meshCorners, function(entryA, entryB)
					return entryA.y < entryB.y
				end)

				local Nyx_computeFishOverhead_var2 = 0
				local y = Nyx_meshCorners[1].y
				local Nyx_fishVolumeIter, Nyx_fishVolumeIterState, Nyx_fishVolumeIterControl = ipairs(Nyx_meshCorners)
				local Nyx_fishVolumeIterator = geniter(Nyx_fishVolumeIter, Nyx_fishVolumeIterState, Nyx_fishVolumeIterControl)

				while true do
					local Nyx_fishVolumePack = table.pack(Nyx_fishVolumeIterator())

					if Nyx_fishVolumePack[1] then
						local Nyx_fishVolumeEntry = Nyx_fishVolumePack[3]

						Nyx_computeFishOverhead_var2 += Nyx_fishVolumeEntry.vol
						y = Nyx_fishVolumeEntry.y

						if Nyx_computeFishOverhead_var1 * 0.1 <= Nyx_computeFishOverhead_var2 then
							break
						end
					else
						break
					end
				end

				local Nyx_fishWeightedCenter = vector32 / Nyx_computeFishOverhead_var1

				Nyx_fishOverheadCenter = Vector3.new(Nyx_fishWeightedCenter.X, y, Nyx_fishWeightedCenter.Z)
			end

			local function Nyx_isInsideFish(point)
				for _, v in ipairs(fishParts) do
					if v.Transparency < 0.95 then
						local Nyx_fishLocalPoint = v.CFrame:PointToObjectSpace(point)
						local Nyx_fishHitboxSize = v.Size / 2 + Vector3.new(0.6, 0.6, 0.6)

						if math.abs(Nyx_fishLocalPoint.X) <= Nyx_fishHitboxSize.X and math.abs(Nyx_fishLocalPoint.Y) <= Nyx_fishHitboxSize.Y and math.abs(Nyx_fishLocalPoint.Z) <= Nyx_fishHitboxSize.Z then
							return true
						end
					end
				end

				return false
			end

			local Nyx_isInsideFish_var1 = 0

			while true do
				if Nyx_isInsideFish_var1 < 150 then
					local Nyx_fishOverheadProbe = Nyx_fishOverheadCenter - Vector3.new(0, 1.6 + Nyx_isInsideFish_var1, 0)

					if Nyx_isInsideFish(Nyx_fishOverheadProbe) or Nyx_isInsideFish(Nyx_fishOverheadProbe - Vector3.new(0, 1.8, 0)) then
						Nyx_isInsideFish_var1 += 1

						continue
					end

					break
				end

				break
			end

			local function Nyx_normalizeLookVec(directionVec)
				local vector33 = Vector3.new(directionVec.X, 0, directionVec.Z)

				return vector33.Magnitude > 0.05 and vector33.Unit or nil
			end

			local Nyx_fishLookVec
			local Nyx_fishPartsIter3, Nyx_fishPartsIterState3, Nyx_fishPartsIterControl3 = ipairs(fishParts)
			local Nyx_fishPartsIterator = geniter(Nyx_fishPartsIter3, Nyx_fishPartsIterState3, Nyx_fishPartsIterControl3)

			while true do
				local Nyx_fishPartsPack = table.pack(Nyx_fishPartsIterator())

				if Nyx_fishPartsPack[1] then
					local Nyx_fishPartEntry = Nyx_fishPartsPack[3]

					if string.find(string.lower(Nyx_fishPartEntry.Name), "eye", 1, true) then
						Nyx_fishLookVec = Nyx_normalizeLookVec(Nyx_fishPartEntry.Position - Nyx_fishOverheadCenter)

						break
					end
				else
					break
				end
			end

			if not Nyx_fishLookVec then
				local Nyx_fishDescendantsIter, Nyx_fishDescendantsIterState, Nyx_fishDescendantsIterControl = ipairs(fishModel:GetDescendants())

				for _, v in Nyx_fishDescendantsIter, Nyx_fishDescendantsIterState, Nyx_fishDescendantsIterControl do
					local Nyx_fishAttachmentName = string.lower(v.Name)

					if not v:IsA("Attachment") or not Nyx_fishAttachmentName:find("head") and not Nyx_fishAttachmentName:find("eye") and not Nyx_fishAttachmentName:find("jaw") and not Nyx_fishAttachmentName:find("mouth") then
						continue
					end

					Nyx_fishLookVec = Nyx_normalizeLookVec(v.WorldPosition - Nyx_fishOverheadCenter)

					if Nyx_fishLookVec then
						break
					end
				end
			end

			local vector33 = Nyx_fishLookVec or Nyx_normalizeLookVec(fishHandle.CFrame.LookVector) or Vector3.zAxis
			local Nyx_visualTransform = {
				lift = Nyx_isInsideFish_var1,
				rootRel = cFrameNew(Nyx_fishOverheadCenter):ToObjectSpace(fishHandle.CFrame),
				turn = lookAt(Vector3.zero, vector33):Inverse()
			}

			return Nyx_visualTransform
		end
		local function Nyx_buildVisualInstance(visualKind, visualEntry, weightPercent, scaleOverride)
			local Nyx_visualInstance, Nyx_visualInstanceError = Nyx_loadVisualModel(visualKind, visualEntry)

			if not Nyx_visualInstance then
				return nil, Nyx_visualInstanceError
			end

			local Nyx_visualHandle, Nyx_visualPartsList

			if visualKind == "fish" then
				local Nyx_fishMinKg = tonumber(visualEntry.minKg)
				local Nyx_fishMaxKg = tonumber(visualEntry.bigMaxKg) or tonumber(visualEntry.maxKg)
				local Nyx_buildVisualInstance_var1 = 1

				if Nyx_fishMinKg and Nyx_fishMinKg > 0 and Nyx_fishMaxKg then
					Nyx_buildVisualInstance_var1 = math.max(1, (Nyx_fishMinKg + (Nyx_fishMaxKg - Nyx_fishMinKg) * (weightPercent or 0)) / Nyx_fishMinKg)
				end

				if (tonumber(visualEntry.nativeLen) or 0) > 50 then
					Nyx_buildVisualInstance_var1 *= 0.8
				end

				Nyx_visualHandle, Nyx_visualPartsList = Nyx_setupVisualModel(Nyx_visualInstance, nil, Nyx_buildVisualInstance_var1)
			else
				Nyx_visualHandle, Nyx_visualPartsList = Nyx_setupVisualModel(Nyx_visualInstance, nil, scaleOverride or 1)
			end

			if not Nyx_visualHandle then
				Nyx_visualInstance:Destroy()

				return nil, "Empty model"
			end

			Nyx_visualHandle.Parent = Nyx_visualInstance

			local Nyx_visualModel = {
				model = Nyx_visualInstance,
				handle = Nyx_visualHandle,
				kind = visualKind
			}

			if visualKind == "fish" then
				Nyx_visualModel.overhead = Nyx_computeFishOverhead(Nyx_visualInstance, Nyx_visualHandle, Nyx_visualPartsList)
				Nyx_visualHandle.Name = "FishRoot"
			else
				local Nyx_rodAxis, Nyx_rodGripShift = Nyx_computeRodAxis(Nyx_visualHandle, Nyx_visualPartsList)

				Nyx_visualModel.rodAxis = Nyx_rodAxis
				Nyx_visualModel.gripShift = Nyx_rodGripShift
				Nyx_visualHandle.Name = "RodRoot"
			end

			return Nyx_visualModel
		end
		local function Nyx_scaleVisualBack(visualData)
			local clone = visualData.model:Clone()

			clone.Name = "NyxVisualBack"

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Size *= 0.8
				elseif descendant:IsA("Weld") then
					descendant.C0 = cFrameNew(descendant.C0.Position * 0.8) * descendant.C0.Rotation
				elseif descendant:IsA("Attachment") then
					if not descendant.Parent:IsA("Bone") then
						descendant.Position *= 0.8
					end
				end
			end

			return clone, clone:FindFirstChild("RodRoot", true)
		end
		local function createWeld(character, visualPart, visualHandle, visualData)
			local UpperTorso = character and (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"))

			if not UpperTorso or not visualHandle then
				return nil
			end

			visualPart.Parent = character

			local Weld = Instance.new("Weld")

			Weld.Part0 = UpperTorso
			Weld.Part1 = visualHandle
			Weld.C0 = Nyx_visualBackWeldCF * cFrameNew(0, visualData.gripShift * 0.8, 0) * visualData.rodAxis:Inverse()
			Weld.Parent = visualHandle

			return Weld
		end
		local function Nyx_attachRodToHand(character, visualHandle, visualData)
			local RightHand = character and character:FindFirstChild("RightHand")
			local UpperTorso = character and character:FindFirstChild("UpperTorso")

			if not RightHand or not UpperTorso then
				local function Nyx_noopHand()
				end

				return Nyx_noopHand
			end

			local Nyx_noopHand_var1 = {}

			for k, v in pairs(Nyx_visualPose) do
				local Nyx_motorChild = character:FindFirstChild(k, true)

				if Nyx_motorChild and Nyx_motorChild:IsA("Motor6D") then
					Nyx_noopHand_var1[Nyx_motorChild] = v
				end
			end

			local Nyx_noopHand_var2 = true
			local Weld
			local connection = RunService.PreSimulation:Connect(function()
				for k, v in pairs(Nyx_noopHand_var1) do
					k.Transform = v
				end
			end)

			task.spawn(function()
				RunService.PostSimulation:Wait()
				RunService.PostSimulation:Wait()

				if not Nyx_noopHand_var2 or not visualHandle.Parent then
					return
				end

				local Nyx_handLocalOffset = UpperTorso.CFrame:PointToObjectSpace(RightHand.Position) + Vector3.new(0, 0, -0.1)
				local Unit2 = (Vector3.xAxis - Unit * Vector3.xAxis:Dot(Unit)).Unit

				Weld = Instance.new("Weld")
				Weld.Part0 = UpperTorso
				Weld.Part1 = visualHandle
				Weld.C0 = fromMatrix(Nyx_handLocalOffset, Unit2, Unit) * cFrameNew(0, visualData.gripShift, 0) * visualData.rodAxis:Inverse()
				Weld.Parent = visualHandle
			end)

			local function Nyx_noopHand2()
				Nyx_noopHand_var2 = false
				connection:Disconnect()

				if Weld then
					Weld:Destroy()
				end
			end

			return Nyx_noopHand2
		end
		local function Nyx_attachFishToHead(character, visualHandle, visualData)
			local Head = character and character:FindFirstChild("Head")

			if not Head then
				local function Nyx_noopHead()
				end

				return Nyx_noopHead
			end

			local overhead = visualData.overhead
			local Weld = Instance.new("Weld")

			Weld.Part0 = Head
			Weld.Part1 = visualHandle
			Weld.C0 = cFrameNew(0, Head.Size.Y / 2 + 1 + overhead.lift, 0) * overhead.turn * overhead.rootRel
			Weld.Parent = visualHandle

			local cFrame = Angles(3.1415926535897931, 0, 0)
			local RightShoulder = character:FindFirstChild("RightShoulder", true)
			local LeftShoulder = character:FindFirstChild("LeftShoulder", true)
			local RightElbow = character:FindFirstChild("RightElbow", true)
			local LeftElbow = character:FindFirstChild("LeftElbow", true)
			local connection = RunService.PreSimulation:Connect(function()
				if RightShoulder then
					RightShoulder.Transform = cFrame * Angles(0, 0, -0.20943951023931956)
				end

				if LeftShoulder then
					LeftShoulder.Transform = cFrame * Angles(0, 0, 0.20943951023931956)
				end

				if RightElbow then
					RightElbow.Transform = cFrameNew()
				end

				if LeftElbow then
					LeftElbow.Transform = cFrameNew()
				end
			end)

			local function Nyx_noopHead2()
				connection:Disconnect()
				Weld:Destroy()
			end

			return Nyx_noopHead2
		end
		local function createTool(visualKind, visualEntry)
			local Nyx_builtVisual, Nyx_buildVisualError = Nyx_buildVisualInstance(visualKind, visualEntry, Nyx_VisualRuntime.fishWeight, Nyx_VisualRuntime.rodScale)

			if not Nyx_builtVisual then
				return nil, Nyx_buildVisualError
			end

			local model = Nyx_builtVisual.model
			local handle = Nyx_builtVisual.handle
			local Tool = Instance.new("Tool")

			Tool.Name = visualEntry.name
			Tool.CanBeDropped = false
			Tool.RequiresHandle = false
			Tool:SetAttribute("NyxVisual", visualKind)

			if visualKind == "fish" then
				Tool:SetAttribute("ItemType", "Phone")
				Tool.ToolTip = tostring(visualEntry.tier or "Fish")
			else
				Tool.ToolTip = "Rod"
			end

			if visualEntry.icon then
				Tool.TextureId = visualEntry.icon
			end

			local Nyx_rodBackModel
			local Nyx_rodBackHandle

			if visualKind == "rods" then
				Nyx_rodBackModel, Nyx_rodBackHandle = Nyx_scaleVisualBack(Nyx_builtVisual)
			end

			for _, child in ipairs(model:GetChildren()) do
				child.Parent = Tool
			end

			model:Destroy()
			Tool.Equipped:Connect(function()
				task.defer(Nyx_VisualRuntime.refreshQuality)
			end)
			Tool.Unequipped:Connect(function()
				task.defer(Nyx_VisualRuntime.refreshQuality)
			end)

			local Nyx_activeUnequip

			if visualKind == "rods" then
				local Nyx_createTool_var3

				Nyx_VisualRuntime.backs[Tool] = function(enabled)
					local Character = LocalPlayer.Character

					if not enabled or not Character then
						Nyx_rodBackModel.Parent = nil
					elseif Nyx_rodBackModel.Parent ~= Character then
						if Nyx_createTool_var3 then
							Nyx_createTool_var3:Destroy()
						end

						Nyx_createTool_var3 = createWeld(Character, Nyx_rodBackModel, Nyx_rodBackHandle, Nyx_builtVisual)
					end
				end
				Tool.Destroying:Connect(function()
					Nyx_VisualRuntime.backs[Tool] = nil
					Nyx_rodBackModel:Destroy()
				end)
				Tool.Equipped:Connect(function()
					Nyx_VisualRuntime.backRod = Tool
					Nyx_VisualRuntime.updateBack()

					if Nyx_activeUnequip then
						Nyx_activeUnequip()
					end

					Nyx_activeUnequip = Nyx_attachRodToHand(Tool.Parent, handle, Nyx_builtVisual)
				end)
				Tool.Unequipped:Connect(function()
					if Nyx_activeUnequip then
						Nyx_activeUnequip()
						Nyx_activeUnequip = nil
					end

					Nyx_VisualRuntime.backRod = Tool
					task.defer(Nyx_VisualRuntime.updateBack)
				end)
			else
				Tool.Equipped:Connect(function()
					if Nyx_activeUnequip then
						Nyx_activeUnequip()
					end

					Nyx_activeUnequip = Nyx_attachFishToHead(Tool.Parent, handle, Nyx_builtVisual)
				end)
				Tool.Unequipped:Connect(function()
					if Nyx_activeUnequip then
						Nyx_activeUnequip()
						Nyx_activeUnequip = nil
					end
				end)
			end

			return Tool
		end

		Nyx_VisualRuntime.spawn = function(visualKind, visualName)
			local Nyx_visualEntry = Nyx_findVisualEntry(visualKind, visualName)

			if not Nyx_visualEntry then
				Nyx_VisualRuntime.status = "Pick an item first"

				return false
			end

			local Backpack = LocalPlayer:FindFirstChild("Backpack")

			if not Backpack then
				Nyx_VisualRuntime.status = "Backpack not ready"

				return false
			end

			local Nyx_existingVisualTool = Backpack:FindFirstChild(Nyx_visualEntry.name)

			if Nyx_existingVisualTool and Nyx_existingVisualTool:GetAttribute("NyxVisual") then
				Nyx_VisualRuntime.status = Nyx_visualEntry.name .. " is already in your backpack"

				return true
			end

			Nyx_VisualRuntime.status = "Loading " .. Nyx_visualEntry.name .. "..."

			local Nyx_createdTool, Nyx_createToolError = createTool(visualKind, Nyx_visualEntry)

			if not Nyx_createdTool then
				Nyx_VisualRuntime.status = Nyx_visualEntry.name .. ": " .. tostring(Nyx_createToolError)

				return false
			end

			Nyx_createdTool.Parent = Backpack

			if visualKind == "rods" then
				Nyx_VisualRuntime.backRod = Nyx_createdTool
				Nyx_VisualRuntime.updateBack()
			end

			Nyx_VisualRuntime.spawned[visualKind .. "|" .. Nyx_visualEntry.name] = {
				kind = visualKind,
				label = Nyx_visualEntry.name
			}
			Nyx_VisualRuntime.status = Nyx_visualEntry.name .. " added to your backpack"

			return true
		end
		Nyx_VisualRuntime.respawn = function(visualKind)
			local Nyx_spawnKindFilter = {}

			for k, v in pairs(Nyx_VisualRuntime.spawned) do
				if v.kind == visualKind then
					Nyx_spawnKindFilter[k] = v
				end
			end

			for _, v in pairs(Nyx_spawnKindFilter) do
				local ipairs_ = ipairs
				local Nyx_createTool_var1 = {
					LocalPlayer:FindFirstChild("Backpack"),
					LocalPlayer.Character
				}

				for _, Nyx_item in ipairs_(Nyx_createTool_var1) do
					local VLabel = Nyx_item and Nyx_item:FindFirstChild(v.label)

					if VLabel and VLabel:IsA("Tool") and VLabel:GetAttribute("NyxVisual") then
						VLabel:Destroy()
					end
				end

				Nyx_VisualRuntime.spawn(v.kind, v.label)
			end
		end
		Nyx_VisualRuntime.clear = function()
			Nyx_VisualRuntime.spawned = {}

			local ipairs_ = ipairs
			local Nyx_createTool_var2 = {
				LocalPlayer:FindFirstChild("Backpack"),
				LocalPlayer.Character
			}

			for _, v in ipairs_(Nyx_createTool_var2) do
				if v then
					for _, child in ipairs(v:GetChildren()) do
						if child:IsA("Tool") and child:GetAttribute("NyxVisual") then
							child:Destroy()
						end
					end
				end
			end

			Nyx_VisualRuntime.status = "Removed all visual items"
			task.defer(Nyx_VisualRuntime.refreshQuality)
		end

		local function Nyx_clearRemoteVisual(playerId)
			local Nyx_remoteVisualState = Nyx_VisualRuntime.remote[playerId]

			if not Nyx_remoteVisualState then
				return
			end

			Nyx_VisualRuntime.remote[playerId] = nil

			for _, v in ipairs(Nyx_remoteVisualState.cleanup) do
				pcall(v)
			end
		end
		local function Nyx_parseVisualKey(visualKey)
			local Nyx_visualKind, Nyx_visualName, Nyx_visualSize = string.match(visualKey or "", "^(%a+)|([^|]+)|?(.*)$")

			return Nyx_visualKind, Nyx_visualName, tonumber(Nyx_visualSize)
		end
		local function Nyx_applyRemoteVisual(playerId, heldKey, backKey)
			local playerByUserId = Players:GetPlayerByUserId(tonumber(playerId) or 0)
			local Character = playerByUserId and playerByUserId.Character

			if not Character then
				Nyx_clearRemoteVisual(playerId)

				return
			end

			local Nyx_visualKeyString = heldKey .. "#" .. backKey
			local Nyx_existingRemoteVisual = Nyx_VisualRuntime.remote[playerId]

			if Nyx_existingRemoteVisual and Nyx_existingRemoteVisual.key == Nyx_visualKeyString and Nyx_existingRemoteVisual.char == Character then
				return
			end

			Nyx_clearRemoteVisual(playerId)

			local Nyx_remoteVisual = {
				key = Nyx_visualKeyString,
				char = Character,
				cleanup = {}
			}

			Nyx_VisualRuntime.remote[playerId] = Nyx_remoteVisual

			local Nyx_heldKind, Nyx_heldName, Nyx_heldSize = Nyx_parseVisualKey(heldKey)
			local Nyx_heldVisualEntry = (Nyx_heldKind == "rods" or Nyx_heldKind == "fish") and Nyx_findVisualEntry(Nyx_heldKind, Nyx_heldName) or nil

			if Nyx_heldVisualEntry then
				local Nyx_builtHeldVisual = Nyx_buildVisualInstance(Nyx_heldKind, Nyx_heldVisualEntry, Nyx_heldKind == "fish" and (Nyx_heldSize or 0) or 0, Nyx_heldKind == "rods" and (Nyx_heldSize or 1) or 1)

				if Nyx_builtHeldVisual and Nyx_VisualRuntime.remote[playerId] == Nyx_remoteVisual and Character.Parent then
					Nyx_builtHeldVisual.model.Name = "NyxVisualRemote"
					Nyx_builtHeldVisual.model.Parent = Character
					table.insert(Nyx_remoteVisual.cleanup, (Nyx_heldKind == "rods" and Nyx_attachRodToHand or Nyx_attachFishToHead)(Character, Nyx_builtHeldVisual.handle, Nyx_builtHeldVisual))
					table.insert(Nyx_remoteVisual.cleanup, function()
						Nyx_builtHeldVisual.model:Destroy()
					end)
				elseif Nyx_builtHeldVisual then
					Nyx_builtHeldVisual.model:Destroy()
				end
			end

			local Nyx_backKind, Nyx_backName = Nyx_parseVisualKey(backKey)
			local Nyx_backVisualEntry = Nyx_backKind == "rods" and Nyx_findVisualEntry("rods", Nyx_backName) or nil

			if Nyx_backVisualEntry and Nyx_VisualRuntime.remote[playerId] == Nyx_remoteVisual then
				local Nyx_builtBackVisual = Nyx_buildVisualInstance("rods", Nyx_backVisualEntry, 0, 1)

				if Nyx_builtBackVisual and Nyx_VisualRuntime.remote[playerId] == Nyx_remoteVisual and Character.Parent then
					local Nyx_backRodModel, Nyx_backRodHandle = Nyx_scaleVisualBack(Nyx_builtBackVisual)

					Nyx_builtBackVisual.model:Destroy()
					createWeld(Character, Nyx_backRodModel, Nyx_backRodHandle, Nyx_builtBackVisual)
					table.insert(Nyx_remoteVisual.cleanup, function()
						Nyx_backRodModel:Destroy()
					end)
				elseif Nyx_builtBackVisual then
					Nyx_builtBackVisual.model:Destroy()
				end
			end

			task.defer(Nyx_VisualRuntime.refreshQuality)
		end

		task.spawn(function()
			while Nyx_isCurrentSession() do
				local Nyx_applyRemoteVisual_var1 = 6

				pcall(function()
					if #Players:GetPlayers() <= 1 then
						for k in pairs(Nyx_VisualRuntime.remote) do
							Nyx_clearRemoteVisual(k)
						end

						return
					end

					local NyxBackend = genv.NyxBackend or {}
					local Api = NyxBackend.Api or "http://56.10.112.179:8080"
					local Nyx_applyRemoteVisual_var2 = ""
					local Nyx_applyRemoteVisual_var3 = ""
					local Character = LocalPlayer.Character

					if Character then
						for _, child in ipairs(Character:GetChildren()) do
							local attribute = child:IsA("Tool") and child:GetAttribute("NyxVisual")

							if attribute then
								Nyx_applyRemoteVisual_var2 = attribute .. "|" .. child.Name .. "|" .. tostring(attribute == "fish" and Nyx_VisualRuntime.fishWeight or Nyx_VisualRuntime.rodScale)

								break
							end
						end

						if Character:FindFirstChild("NyxVisualBack") and Nyx_VisualRuntime.backRod then
							Nyx_applyRemoteVisual_var3 = "rods|" .. Nyx_VisualRuntime.backRod.Name
						end
					end

					local data = HttpService:JSONDecode(game:HttpGet(string.format("%s/vstate?key=%s&job=%s&uid=%d&held=%s&back=%s", Api, HttpService:UrlEncode(NyxBackend.Key or "sena_20VvixjHsd1OPPwgHYJAstpM"), HttpService:UrlEncode(game.JobId), LocalPlayer.UserId, HttpService:UrlEncode(Nyx_applyRemoteVisual_var2), HttpService:UrlEncode(Nyx_applyRemoteVisual_var3)), true))

					if type(data) ~= "table" or data.ok ~= true then
						return
					end

					Nyx_applyRemoteVisual_var1 = tonumber(data.poll) or 4

					local Nyx_applyRemoteVisual_var5 = {}
					local pairs_ = pairs
					local players = data.players or {}

					for k, player in pairs_(players) do
						local Nyx_playerIdString = tostring(k)

						Nyx_applyRemoteVisual_var5[Nyx_playerIdString] = true
						Nyx_applyRemoteVisual(Nyx_playerIdString, tostring(player.held or ""), tostring(player.back or ""))
					end

					for k in pairs(Nyx_VisualRuntime.remote) do
						if not Nyx_applyRemoteVisual_var5[k] then
							Nyx_clearRemoteVisual(k)
						end
					end
				end)
				task.wait(Nyx_applyRemoteVisual_var1)
			end

			for k in pairs(Nyx_VisualRuntime.remote) do
				Nyx_clearRemoteVisual(k)
			end
		end)
		LocalPlayer.CharacterAdded:Connect(function()
			if not Nyx_isCurrentSession() then
				return
			end

			task.wait(1.5)

			for _, v in pairs(Nyx_VisualRuntime.spawned) do
				pcall(Nyx_VisualRuntime.spawn, v.kind, v.label)
			end
		end)

		return Nyx_VisualRuntime
	end

	genv.__NyxVisual = Nyx_visualRuntimeFactory()
end

do
	local HttpService = game:GetService("HttpService")
	local Nyx_ServerHop = {
		hopFailed = false,
		lastHopAt = 0
	}

	pcall(function()
		TeleportService.TeleportInitFailed:Connect(function(errorMessage)
			if errorMessage == LocalPlayer then
				Nyx_ServerHop.hopFailed = true
			end
		end)
	end)
	Nyx_ServerHop.collectServers = function(maxPlayersFilter)
		local Nyx_serverList = {}
		local Nyx_applyRemoteVisual_var4 = ""

		for i = 1, 3 do
			local ok, result = pcall(function()
				local Nyx_serverListUrl = ("https://games.roblox.com/Nyx_resolveThumbnail_var1/games/%d/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"):format(game.PlaceId)

				if Nyx_applyRemoteVisual_var4 ~= "" then
					Nyx_serverListUrl ..= "&cursor=" .. Nyx_applyRemoteVisual_var4
				end

				return HttpService:JSONDecode(game:HttpGet(Nyx_serverListUrl))
			end)

			if ok and type(result) == "table" then
				local ipairs_ = ipairs
				local data = result.data or {}

				for _, v in ipairs_(data) do
					if tostring(v.id) ~= game.JobId and v.playing and v.maxPlayers and v.playing < v.maxPlayers and (not maxPlayersFilter or v.playing <= maxPlayersFilter) then
						Nyx_serverList[#Nyx_serverList + 1] = {
							id = tostring(v.id),
							playing = v.playing
						}
					end
				end

				Nyx_applyRemoteVisual_var4 = result.nextPageCursor or ""

				if Nyx_applyRemoteVisual_var4 ~= "" then
					continue
				end
			end

			break
		end

		table.sort(Nyx_serverList, function(serverA, serverB)
			return serverA.playing < serverB.playing
		end)

		return Nyx_serverList
	end
	Nyx_ServerHop.hopToList = function(serverList)
		if type(serverList) ~= "table" or #serverList == 0 then
			return false
		end

		for _, v in ipairs(serverList) do
			Nyx_ServerHop.hopFailed = false

			if pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
			end) then
				local now = os.clock()

				while not Nyx_ServerHop.hopFailed and os.clock() - now < 6 do
					task.wait(0.25)
				end

				if not Nyx_ServerHop.hopFailed then
					return true
				end
			end

			task.wait(0.3)
		end

		return false
	end
	Nyx_ServerHop.hopEmptiest = function()
		return Nyx_ServerHop.hopToList(Nyx_ServerHop.collectServers(nil))
	end
	Nyx_ServerHop.privateStatus = "Pick a max player count, then Hop Server Now."
	Nyx_ServerHop.privateMax = function()
		return math.max(1, math.floor(tonumber(tostring(NyxConfig.PrivateServerMax or "2"):match("%d+")) or 2))
	end
	Nyx_ServerHop.findPrivateTargets = function()
		local Nyx_privateMaxPlayers = Nyx_ServerHop.privateMax()
		local Nyx_publicServerList = Nyx_ServerHop.collectServers(nil)

		if #Nyx_publicServerList == 0 then
			return nil
		end

		local Nyx_privateTargets = {}

		for _, v in ipairs(Nyx_publicServerList) do
			if v.playing + 1 <= Nyx_privateMaxPlayers then
				Nyx_privateTargets[#Nyx_privateTargets + 1] = v
			end
		end

		local Nyx_targetServers = Nyx_privateTargets

		if #Nyx_targetServers == 0 then
			local playing = Nyx_publicServerList[1].playing

			for _, v in ipairs(Nyx_publicServerList) do
				if v.playing == playing then
					Nyx_targetServers[#Nyx_targetServers + 1] = v
				end
			end
		end

		local Nyx_applyRemoteVisual_var6 = {}

		while #Nyx_targetServers > 0 and #Nyx_applyRemoteVisual_var6 < 5 do
			Nyx_applyRemoteVisual_var6[#Nyx_applyRemoteVisual_var6 + 1] = table.remove(Nyx_targetServers, math.random(1, #Nyx_targetServers))
		end

		return Nyx_applyRemoteVisual_var6
	end
	Nyx_ServerHop.hopPrivateOnce = function()
		local Nyx_privateMaxCheck = Nyx_ServerHop.privateMax()
		local Nyx_currentPlayerCount = #Players:GetPlayers()

		if Nyx_currentPlayerCount <= Nyx_privateMaxCheck then
			Nyx_ServerHop.privateStatus = "This server is good (" .. Nyx_currentPlayerCount .. " player(s), max " .. Nyx_privateMaxCheck .. ")."

			return false
		end

		if Nyx_ServerHop.hubBusy() then
			Nyx_ServerHop.privateStatus = "Waiting until you finish stealing..."

			return false
		end

		Nyx_ServerHop.privateStatus = "Searching for a quieter server..."

		local Nyx_privateTargetServers = Nyx_ServerHop.findPrivateTargets()

		if not Nyx_privateTargetServers or #Nyx_privateTargetServers == 0 then
			Nyx_ServerHop.privateStatus = "Could not load the server list. Try again."

			return false
		end

		Nyx_ServerHop.privateStatus = "Teleporting..."
		Nyx_ServerHop.lastHopAt = os.clock()

		if Nyx_ServerHop.hopToList(Nyx_privateTargetServers) then
			return true
		end

		Nyx_ServerHop.privateStatus = "Teleport failed. Trying again soon."

		return false
	end
	Nyx_ServerHop.startPrivateAutoHop = function()
		if Nyx_ServerHop.privateAutoRunning then
			return
		end

		Nyx_ServerHop.privateAutoRunning = true
		task.spawn(function()
			while Nyx_isCurrentSession() and NyxConfig.PrivateServerAuto do
				local Nyx_privateMaxCheck2 = Nyx_ServerHop.privateMax()

				if Nyx_privateMaxCheck2 >= #Players:GetPlayers() then
					Nyx_ServerHop.privateStatus = "Good server found. Waiting..."
					task.wait(3)
				else
					Nyx_ServerHop.hopPrivateOnce()
					task.wait(5)
				end
			end

			Nyx_ServerHop.privateAutoRunning = false

			if not NyxConfig.PrivateServerAuto then
				Nyx_ServerHop.privateStatus = "Auto hop stopped."
			end
		end)
	end

	local function hubBusy()
		if NyxConfig.IsStealing or NyxConfig.IsPlacing then
			return true
		end

		local __NyxEggRuntime = genv.__NyxEggRuntime

		if __NyxEggRuntime and (__NyxEggRuntime.running or __NyxEggRuntime.travelBusy or __NyxEggRuntime.carry and __NyxEggRuntime.carry.active) then
			return true
		end

		local __NyxPlayerSteal = genv.__NyxPlayerSteal

		if __NyxPlayerSteal and __NyxPlayerSteal.running then
			return true
		end

		return false
	end

	Nyx_ServerHop.hubBusy = hubBusy
	Nyx_ServerHop.startHopLoop = function()
		if Nyx_ServerHop.hopLoopRunning then
			return
		end

		Nyx_ServerHop.hopLoopRunning = true
		task.spawn(function()
			while Nyx_isCurrentSession() do
				task.wait(2)

				if NyxConfig.HopNoMatch and not Nyx_ServerHop.hubBusy() then
					if (tonumber(NyxConfig.HopCooldown) or 5) < os.clock() - Nyx_ServerHop.lastHopAt then
						local __NyxEggRuntime = genv.__NyxEggRuntime

						if NyxConfig.AutoSteal and (__NyxEggRuntime and __NyxEggRuntime.stats and __NyxEggRuntime.stats.matching or 0) <= 0 and not Nyx_isNightPhase() then
							Nyx_ServerHop.lastHopAt = os.clock()
							Nyx_ServerHop.hopEmptiest()
						end
					end
				end
			end

			Nyx_ServerHop.hopLoopRunning = false
		end)
	end
	Nyx_ServerHop.startAntiTreadmillLoop = function()
		if Nyx_ServerHop.antiTreadmillRunning then
			return
		end

		Nyx_ServerHop.antiTreadmillRunning = true
		task.spawn(function()
			while Nyx_isCurrentSession() do
				if NyxConfig.AntiTreadmill then
					local __NyxTreadmillManager = genv.__NyxTreadmillManager

					pcall(function()
						if __NyxTreadmillManager and __NyxTreadmillManager.activeTreadmill ~= nil then
							__NyxTreadmillManager:_cancelIdle(true)
							__NyxTreadmillManager:_requestUnequip()
						end
					end)

					local Character = LocalPlayer.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

					if HumanoidRootPart and HumanoidRootPart.Anchored then
						pcall(function()
							HumanoidRootPart.Anchored = false
						end)
					end
				end

				task.wait(0.3)
			end

			Nyx_ServerHop.antiTreadmillRunning = false
		end)
	end
	Nyx_ServerHop.setBackpackRates = function(enabled)
		NyxConfig.BackpackRateEsp = enabled == true

		if not Nyx_ServerHop.backpackRatesRunning then
			Nyx_ServerHop.backpackRatesRunning = true
			task.spawn(function()
				local EggRecords
				local Save

				pcall(function()
					EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
					Save = require(ReplicatedStorage.Shared.Save)
				end)

				while Nyx_isCurrentSession() do
					local ScrollingFrame

					pcall(function()
						ScrollingFrame = LocalPlayer.PlayerGui.BackpackGui.Backpack.Main.Inventory.ScrollingFrame
					end)

					local __NyxWebhook = genv.__NyxWebhook
					local NyxDiscord = ScrollingFrame and ScrollingFrame.Parent:FindFirstChild("NyxDiscord")

					if ScrollingFrame and NyxConfig.BackpackRateEsp and not NyxDiscord then
						local TextLabel = Instance.new("TextLabel")

						TextLabel.Name = "NyxDiscord"
						TextLabel.BackgroundTransparency = 1
						TextLabel.Position = UDim2.new(0.34, 0, 0.017, 0)
						TextLabel.Size = UDim2.new(0.3, 0, 0.09, 0)
						TextLabel.Font = Enum.Font.GothamBlack
						TextLabel.Text = "discord.gg/Nyxhub"
						TextLabel.TextScaled = true
						TextLabel.TextXAlignment = Enum.TextXAlignment.Left
						TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
						TextLabel.TextStrokeTransparency = 0
						TextLabel.ZIndex = 40
						TextLabel.Parent = ScrollingFrame.Parent
					elseif NyxDiscord and not NyxConfig.BackpackRateEsp then
						NyxDiscord:Destroy()
					end

					if ScrollingFrame then
						local Nyx_backpackRateGroups = {}

						if NyxConfig.BackpackRateEsp and EggRecords and Save and __NyxWebhook then
							local Nyx_saveDataForBackpack = (Save.Peek or Save.Get)()
							local pairs_ = pairs
							local EggInventory = Nyx_saveDataForBackpack and Nyx_saveDataForBackpack.EggInventory or {}

							for _, v in pairs_(EggInventory) do
								local ok, result = pcall(EggRecords.DisplayNameWithWeight, v)

								if ok and type(result) == "string" then
									Nyx_backpackRateGroups[result] = Nyx_backpackRateGroups[result] or {}
									table.insert(Nyx_backpackRateGroups[result], v)
								end
							end
						end

						local Nyx_backpackRateCounts = {}

						for _, child in ipairs(ScrollingFrame:GetChildren()) do
							local ToolName = child:IsA("GuiButton") and child:FindFirstChild("ToolName")

							if ToolName then
								local Text = ToolName.Text
								local Nyx_backpackRowIndex = (Nyx_backpackRateCounts[Text] or 0) + 1
								local Nyx_backpackEggRecord = Nyx_backpackRateGroups[Text] and Nyx_backpackRateGroups[Text][Nyx_backpackRowIndex]
								local NyxRate = child:FindFirstChild("NyxRate")

								if Nyx_backpackEggRecord then
									Nyx_backpackRateCounts[Text] = Nyx_backpackRowIndex

									if not NyxRate then
										NyxRate = Instance.new("TextLabel")
										NyxRate.Name = "NyxRate"
										NyxRate.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
										NyxRate.BackgroundTransparency = 0.35
										NyxRate.BorderSizePixel = 0
										NyxRate.Position = UDim2.new(0.04, 0, 0, 3)
										NyxRate.Size = UDim2.new(0.92, 0, 0.24, 0)
										NyxRate.Font = Enum.Font.GothamBlack
										NyxRate.TextScaled = true
										NyxRate.TextColor3 = Color3.fromRGB(73, 211, 31)
										NyxRate.TextStrokeTransparency = 0
										NyxRate.ZIndex = 40

										local UICorner = Instance.new("UICorner")

										UICorner.CornerRadius = UDim.new(0, 6)
										UICorner.Parent = NyxRate

										local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

										UITextSizeConstraint.MaxTextSize = 20
										UITextSizeConstraint.Parent = NyxRate
										NyxRate.Parent = child
									end

									NyxRate.Text = __NyxWebhook.compact(__NyxWebhook.rateOf(Nyx_backpackEggRecord)) .. "/s"
								elseif NyxRate then
									NyxRate:Destroy()
								end
							end
						end
					end

					if not NyxConfig.BackpackRateEsp then
						break
					end

					task.wait(1)
				end

				Nyx_ServerHop.backpackRatesRunning = false
			end)

			return
		end
	end

	local function Nyx_scrambleTradeInFactory()
		local Nyx_ScrambleTradeIn = {
			status = "Disabled",
			banner = "Unknown",
			rotation = 0,
			pity = 0,
			pityMax = 100,
			free = 0,
			trades = 0,
			demands = "-",
			stock = "-",
			ready = 0,
			total = 3,
			missing = "None",
			cache = nil,
			cacheAt = 0,
			lastReroll = 0
		}
		local Directory
		local AssetItems
		local AssetEarnings
		local Save

		pcall(function()
			Directory = require(ReplicatedStorage.Data.Assets).Directory
		end)
		pcall(function()
			AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
		end)
		pcall(function()
			AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
		end)
		pcall(function()
			Save = require(ReplicatedStorage.Shared.Save)
		end)

		local function Nyx_getTradeInRemotes()
			local ok, result = pcall(function()
				return require(ReplicatedStorage.Shared.Remotes).ScrambleTradeIn
			end)
			local Nyx_tradeInRemotes = ok and result or nil

			return Nyx_tradeInRemotes
		end
		local function Nyx_isTradeInActive()
			return NyxConfig.ScrambleTradeInTrade or NyxConfig.ScrambleTradeInReroll
		end
		local function Nyx_normalizeTradeName(nameInput)
			return ((tostring(nameInput or ""):lower():match("^%s*(.-)%s*$") or ""):gsub("%s*egg$", ""))
		end
		local function matches(nameA, nameB)
			local Nyx_normalizedA = Nyx_normalizeTradeName(nameA)
			local Nyx_normalizedB = Nyx_normalizeTradeName(nameB)

			if Nyx_normalizedA == "" or Nyx_normalizedB == "" then
				return false
			end

			if Nyx_normalizedA == Nyx_normalizedB then
				return true
			end

			if not Directory or Directory[nameA] then
				return false
			end

			local Nyx_tradeAssetDef = Directory[nameB]

			return type(Nyx_tradeAssetDef) == "table" and type(Nyx_tradeAssetDef.DisplayName) == "string" and Nyx_normalizeTradeName(Nyx_tradeAssetDef.DisplayName) == Nyx_normalizedA
		end

		Nyx_ScrambleTradeIn.matches = matches

		local function Nyx_getTradeDisplayName(nameInput)
			local Nyx_tradeAssetDefB = Directory and Directory[nameInput]
			local DisplayName = type(Nyx_tradeAssetDefB) == "table" and Nyx_tradeAssetDefB.DisplayName

			return type(DisplayName) == "string" and DisplayName ~= "" and DisplayName or tostring(nameInput)
		end
		local function Nyx_joinTradeNames(namesList, separator)
			local Nyx_petNameList = {}

			for i, v in ipairs(namesList) do
				Nyx_petNameList[i] = Nyx_getTradeDisplayName(v)
			end

			return table.concat(Nyx_petNameList, separator)
		end

		Nyx_ScrambleTradeIn.state = function(forceRefresh)
			local now = os.clock()

			if not forceRefresh and Nyx_ScrambleTradeIn.cache and now - Nyx_ScrambleTradeIn.cacheAt < 2.5 then
				return Nyx_ScrambleTradeIn.cache
			end

			local Nyx_tradeInRemotesRef = Nyx_getTradeInRemotes()

			if not Nyx_tradeInRemotesRef or not Nyx_tradeInRemotesRef.AskState then
				return Nyx_ScrambleTradeIn.cache
			end

			local ok, cache = pcall(function()
				return Nyx_tradeInRemotesRef.AskState:InvokeServer()
			end)

			if ok and type(cache) == "table" then
				Nyx_ScrambleTradeIn.cache = cache
				Nyx_ScrambleTradeIn.cacheAt = now
			end

			return Nyx_ScrambleTradeIn.cache
		end

		local function Nyx_isBannerMatched(record)
			local ScrambleTradeInBanners = NyxConfig.ScrambleTradeInBanners

			if type(ScrambleTradeInBanners) ~= "table" or #ScrambleTradeInBanners == 0 then
				return true
			end

			if not record or not record.BannerId then
				return true
			end

			local Nyx_bannerIdNormalized = Nyx_normalizeTradeName(record.BannerId)
			local Nyx_bannerNameNormalized = Nyx_normalizeTradeName(record.BannerDisplayName)

			for _, ScrambleTradeInBanner in ipairs(ScrambleTradeInBanners) do
				local Nyx_bannerEntryNormalized = Nyx_normalizeTradeName(ScrambleTradeInBanner)

				if Nyx_bannerEntryNormalized == Nyx_bannerIdNormalized or Nyx_bannerNameNormalized ~= "" and Nyx_bannerEntryNormalized == Nyx_bannerNameNormalized then
					return true
				end
			end

			return false
		end
		local function Nyx_getTradeRequirements(record)
			return record and type(record.Requirements) == "table" and record.Requirements or {}
		end
		local function Nyx_getTradeSaveData()
			local Nyx_getTradeSaveData_var1

			if Save then
				pcall(function()
					Nyx_getTradeSaveData_var1 = (Save.Peek or Save.Get)()
				end)
			end

			return Nyx_getTradeSaveData_var1
		end
		local function Nyx_listSellablePets(saveData)
			local Nyx_listSellablePets_var1 = {}

			if not saveData or not AssetItems then
				return Nyx_listSellablePets_var1
			end

			local Nyx_listSellablePets_var2 = {}
			local ipairs_ = ipairs
			local EquippedAssets = saveData.EquippedAssets or {}

			for _, EquippedAsset in ipairs_(EquippedAssets) do
				Nyx_listSellablePets_var2[EquippedAsset] = true
			end

			local Nyx_listSellablePets_var3 = {}

			pcall(function()
				for k in pairs(require(ReplicatedStorage.Client.AssetRoster).ReadOwnerPen(LocalPlayer.UserId)) do
					Nyx_listSellablePets_var3[k] = true
				end
			end)

			local pairs_ = pairs
			local Inventory = saveData.Inventory or {}

			for k, v in pairs_(Inventory) do
				local ok, result = pcall(AssetItems.Decode, v)

				if ok and type(result) == "table" and result.Category and not result.IsFavorite and not result.InFuse and not Nyx_listSellablePets_var2[k] and not Nyx_listSellablePets_var3[k] then
					local huge = math.huge

					if AssetEarnings then
						local ok2, result2 = pcall(AssetEarnings.LiveRatePerSecond, {
							Category = result.Category,
							Scale = math.max(tonumber(result.Scale) or 1, 0.01),
							Mutations = type(result.Mutations) == "table" and result.Mutations or {}
						}, saveData.Gamepasses, saveData.Products)

						if ok2 and type(result2) == "number" then
							huge = result2
						end
					end

					Nyx_listSellablePets_var1[#Nyx_listSellablePets_var1 + 1] = {
						uid = k,
						category = result.Category,
						rate = huge
					}
				end
			end

			table.sort(Nyx_listSellablePets_var1, function(entryA, entryB)
				if entryA.rate == entryB.rate then
					return tostring(entryA.uid) < tostring(entryB.uid)
				end

				return entryA.rate < entryB.rate
			end)

			return Nyx_listSellablePets_var1
		end
		local function selectPets(requirementsList, saveData)
			local Nyx_sellablePets = Nyx_listSellablePets(saveData)
			local Nyx_petUsed = {}
			local Nyx_petSlots = {}
			local Nyx_selectPets_var1 = {}

			for i, v in ipairs(requirementsList) do
				local Nyx_selectedPet

				for _, Nyx_item in ipairs(Nyx_sellablePets) do
					if not Nyx_petUsed[Nyx_item.uid] and matches(Nyx_item.category, v) then
						Nyx_selectedPet = Nyx_item

						break
					end
				end

				if Nyx_selectedPet then
					Nyx_petUsed[Nyx_selectedPet.uid] = true
					Nyx_petSlots[i] = Nyx_selectedPet
				else
					Nyx_selectPets_var1[#Nyx_selectPets_var1 + 1] = v
				end
			end

			return Nyx_petSlots, Nyx_selectPets_var1, Nyx_sellablePets
		end

		Nyx_ScrambleTradeIn.selectPets = selectPets

		local function Nyx_formatStockText(requirementsList, saveData, allPetsList)
			local Nyx_stockCounts = {}
			local Nyx_stockUnique = {}

			for _, v in ipairs(requirementsList) do
				if not Nyx_stockCounts[v] then
					Nyx_stockUnique[#Nyx_stockUnique + 1] = v
				end

				Nyx_stockCounts[v] = (Nyx_stockCounts[v] or 0) + 1
			end

			local Nyx_stockStrs = {}

			for _, v in ipairs(Nyx_stockUnique) do
				local Nyx_formatStockText_var1 = 0

				for _, Nyx_item in ipairs(allPetsList) do
					if matches(Nyx_item.category, v) then
						Nyx_formatStockText_var1 += 1
					end
				end

				local pairs_ = pairs
				local EggInventory = saveData and saveData.EggInventory or {}

				for _, Nyx_item in pairs_(EggInventory) do
					if type(Nyx_item) == "table" and matches(Nyx_item.AssetCategory, v) then
						Nyx_formatStockText_var1 += 1
					end
				end

				Nyx_stockStrs[#Nyx_stockStrs + 1] = string.format("%s %d/%d", Nyx_getTradeDisplayName(v), math.min(Nyx_formatStockText_var1, Nyx_stockCounts[v]), Nyx_stockCounts[v])
			end

			return table.concat(Nyx_stockStrs, "  ")
		end
		local function teleport()
			local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

			if not HumanoidRootPart then
				return false
			end

			local Nyx_worldRefForTrade = Nyx_getWorkspaceWorld()
			local Machines = Nyx_worldRefForTrade and Nyx_worldRefForTrade:FindFirstChild("Machines")
			local RiftMachine = Machines and Machines:FindFirstChild("RiftMachine")
			local Machine = RiftMachine and RiftMachine:FindFirstChild("Machine")

			HumanoidRootPart.CFrame = Machine and Machine:IsA("BasePart") and Machine.CFrame * cFrameNew(0, Machine.Size.Y * 0.5 + 3, 4) or cFrameNew(533.4, 72, -330)
			HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero

			return true
		end

		Nyx_ScrambleTradeIn.teleport = teleport
		Nyx_ScrambleTradeIn.openUI = function()
			return (pcall(function()
				require(ReplicatedStorage.Client.Tabs).Activate("DrScrambleTradeIn")
			end))
		end

		local function Nyx_submitTradeIn(requirementsList, selectedPets)
			local Nyx_tradeInRemotes2 = Nyx_getTradeInRemotes()

			if not Nyx_tradeInRemotes2 or not Nyx_tradeInRemotes2.AskTradeIn then
				return false, "Trade remote unavailable"
			end

			local Nyx_submitTradeIn_var1 = {}

			for i = 1, #requirementsList do
				local Nyx_petSlotEntry = selectedPets[i]

				if Nyx_petSlotEntry then
					Nyx_submitTradeIn_var1[#Nyx_submitTradeIn_var1 + 1] = Nyx_petSlotEntry.uid

					continue
				end

				return false, "Requirements incomplete"
			end

			Nyx_ScrambleTradeIn.status = "Trading pets into Dr Scramble"

			local ok, result = pcall(function()
				return Nyx_tradeInRemotes2.AskTradeIn:InvokeServer(Nyx_submitTradeIn_var1)
			end)

			if (not ok or result == false) and teleport() then
				task.wait(0.3)
				ok, result = pcall(function()
					return Nyx_tradeInRemotes2.AskTradeIn:InvokeServer(Nyx_submitTradeIn_var1)
				end)
			end

			if not ok or result == false then
				local Nyx_tradeFailed = false
				local tostring_ = tostring
				local Nyx_tradeErrorMessage = result or "Trade rejected"

				return Nyx_tradeFailed, tostring_(Nyx_tradeErrorMessage)
			end

			pcall(function()
				if Nyx_tradeInRemotes2.AskFinishReveal then
					Nyx_tradeInRemotes2.AskFinishReveal:InvokeServer()
				end
			end)
			Nyx_ScrambleTradeIn.trades += 1
			Nyx_ScrambleTradeIn.state(true)

			return true
		end

		Nyx_ScrambleTradeIn.tradeOnce = function()
			local Nyx_tradeRequirements = Nyx_getTradeRequirements(Nyx_ScrambleTradeIn.state(true))

			if #Nyx_tradeRequirements < 3 then
				return false, "Cannot read the recipe"
			end

			local Nyx_selectedPets, Nyx_missingRequirements = selectPets(Nyx_tradeRequirements, Nyx_getTradeSaveData())

			if #Nyx_missingRequirements > 0 then
				return false, "Missing: " .. Nyx_joinTradeNames(Nyx_missingRequirements, ", ")
			end

			return Nyx_submitTradeIn(Nyx_tradeRequirements, Nyx_selectedPets)
		end
		Nyx_ScrambleTradeIn.reroll = function()
			local Nyx_tradeInState = Nyx_ScrambleTradeIn.state(false)

			if (tonumber(Nyx_tradeInState and Nyx_tradeInState.FreeRefreshesRemaining) or 0) <= 0 then
				return false, "No free rerolls left"
			end

			local Nyx_tradeInRemotes3 = Nyx_getTradeInRemotes()

			if not Nyx_tradeInRemotes3 or not Nyx_tradeInRemotes3.AskRefresh then
				return false, "Refresh remote unavailable"
			end

			if not pcall(function()
				return Nyx_tradeInRemotes3.AskRefresh:InvokeServer()
			end) then
				return false, "Reroll failed"
			end

			Nyx_ScrambleTradeIn.state(true)

			return true
		end
		Nyx_ScrambleTradeIn.tick = function()
			local Nyx_tradeInSnapshot = Nyx_ScrambleTradeIn.state(false)

			if not Nyx_tradeInSnapshot then
				Nyx_ScrambleTradeIn.status = "Trade-In state unavailable"

				return
			end

			if Nyx_tradeInSnapshot.Unlocked == false then
				Nyx_ScrambleTradeIn.status = "Dr Scramble Trade-In is locked"

				return
			end

			Nyx_ScrambleTradeIn.banner = tostring(Nyx_tradeInSnapshot.BannerDisplayName or Nyx_tradeInSnapshot.BannerId or "Unknown")
			Nyx_ScrambleTradeIn.rotation = math.max(0, math.floor(tonumber(Nyx_tradeInSnapshot.SecondsUntilRotation) or 0))
			Nyx_ScrambleTradeIn.pity = tonumber(Nyx_tradeInSnapshot.PityCount) or 0
			Nyx_ScrambleTradeIn.pityMax = tonumber(Nyx_tradeInSnapshot.PityThreshold) or 100
			Nyx_ScrambleTradeIn.free = tonumber(Nyx_tradeInSnapshot.FreeRefreshesRemaining) or 0

			if Nyx_tradeInSnapshot.PendingReward then
				Nyx_ScrambleTradeIn.status = "Finishing reward"

				local Nyx_tradeInRemotes4 = Nyx_getTradeInRemotes()

				pcall(function()
					if Nyx_tradeInRemotes4 and Nyx_tradeInRemotes4.AskFinishReveal then
						Nyx_tradeInRemotes4.AskFinishReveal:InvokeServer()
					end
				end)
				Nyx_ScrambleTradeIn.cache = nil

				return
			end

			if not Nyx_isBannerMatched(Nyx_tradeInSnapshot) then
				Nyx_ScrambleTradeIn.status = "Waiting for banner (now: " .. Nyx_ScrambleTradeIn.banner .. ")"
				Nyx_ScrambleTradeIn.demands = "-"
				Nyx_ScrambleTradeIn.stock = "-"
				Nyx_ScrambleTradeIn.ready = 0
				Nyx_ScrambleTradeIn.missing = "None"

				return
			end

			local Nyx_tradeRequirementsList = Nyx_getTradeRequirements(Nyx_tradeInSnapshot)

			Nyx_ScrambleTradeIn.total = #Nyx_tradeRequirementsList
			Nyx_ScrambleTradeIn.demands = #Nyx_tradeRequirementsList > 0 and Nyx_joinTradeNames(Nyx_tradeRequirementsList, " / ") or "-"

			if #Nyx_tradeRequirementsList < 3 then
				Nyx_ScrambleTradeIn.status = "Waiting for requirements"

				return
			end

			local Nyx_tradeSaveData = Nyx_getTradeSaveData()
			local Nyx_selectedPets2, Nyx_missingPets2, Nyx_allPets2 = selectPets(Nyx_tradeRequirementsList, Nyx_tradeSaveData)

			Nyx_ScrambleTradeIn.stock = Nyx_formatStockText(Nyx_tradeRequirementsList, Nyx_tradeSaveData, Nyx_allPets2)
			Nyx_ScrambleTradeIn.ready = #Nyx_tradeRequirementsList - #Nyx_missingPets2
			Nyx_ScrambleTradeIn.missing = #Nyx_missingPets2 > 0 and Nyx_joinTradeNames(Nyx_missingPets2, ", ") or "None"

			if #Nyx_missingPets2 == 0 then
				if NyxConfig.ScrambleTradeInTrade then
					Nyx_ScrambleTradeIn.status = "Requirements complete, submitting"

					local Nyx_tradeOk, Nyx_tradeErr = Nyx_submitTradeIn(Nyx_tradeRequirementsList, Nyx_selectedPets2)

					Nyx_ScrambleTradeIn.status = Nyx_tradeOk and "Trade complete" or "Trade: " .. tostring(Nyx_tradeErr)
				else
					Nyx_ScrambleTradeIn.status = "Ready to trade (Auto Trade-In is off)"
				end

				return
			end

			if NyxConfig.ScrambleTradeInReroll and Nyx_ScrambleTradeIn.free > 0 and os.clock() - Nyx_ScrambleTradeIn.lastReroll > 3 then
				Nyx_ScrambleTradeIn.lastReroll = os.clock()
				Nyx_ScrambleTradeIn.status = "Rerolling the recipe"
				Nyx_ScrambleTradeIn.reroll()

				return
			end

			Nyx_ScrambleTradeIn.status = #Nyx_missingPets2 > 0 and "Waiting for " .. Nyx_ScrambleTradeIn.missing or Nyx_ScrambleTradeIn.status
		end
		task.spawn(function()
			while Nyx_isCurrentSession() do
				if Nyx_isTradeInActive() then
					local ok, result = pcall(Nyx_ScrambleTradeIn.tick)

					if not ok then
						Nyx_ScrambleTradeIn.status = "Trade-In error: " .. tostring(result)
					end
				elseif Nyx_ScrambleTradeIn.status ~= "Disabled" then
					Nyx_ScrambleTradeIn.status = "Disabled"
				end

				task.wait(1)
			end
		end)
		genv.__NyxScrambleTradeIn = Nyx_ScrambleTradeIn
	end

	Nyx_scrambleTradeInFactory()

	local function Nyx_scrambleBossFactory()
		local LocalPlayer2 = game:GetService("Players").LocalPlayer
		local Nyx_scrambleBossFactory_var1 = {
			status = "Disabled",
			inArena = false,
			joins = 0,
			hits = 0,
			dodges = 0
		}
		local ScrambleBossHazards

		pcall(function()
			ScrambleBossHazards = require(ReplicatedStorage.Shared.Util.ScrambleBossHazards)
		end)

		local function Nyx_getScrambleBossRemotes()
			local ok, result = pcall(function()
				return require(ReplicatedStorage.Shared.Remotes)
			end)
			local Nyx_scrambleBossRemotes = ok and result or nil

			return Nyx_scrambleBossRemotes
		end
		local function Nyx_getScrambleArena()
			return workspace:FindFirstChild("ScrambleArena")
		end
		local function Nyx_getScramblePortal()
			return workspace:FindFirstChild("ScrambleArenaPortal")
		end
		local function Nyx_getScramblePlayerParts()
			local Character = LocalPlayer2.Character

			if Character then
				return Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChildOfClass("Humanoid"), Character
			end

			return nil
		end
		local function amInArena()
			local Nyx_scrambleArena = Nyx_getScrambleArena()

			if not Nyx_scrambleArena then
				return false
			end

			local Nyx_scramblePlayerRoot = Nyx_getScramblePlayerParts()

			if not Nyx_scramblePlayerRoot then
				return false
			end

			local attribute = Nyx_scrambleArena:GetAttribute("Center")

			if typeof(attribute) == "Vector3" then
				return (Nyx_scramblePlayerRoot.Position - attribute).Magnitude < (tonumber(Nyx_scrambleArena:GetAttribute("Radius")) or 500) + 80
			end

			return false
		end

		Nyx_scrambleBossFactory_var1.amInArena = amInArena

		local function Nyx_isAutoStealActive()
			local __NyxStealWantsCharacter = genv.__NyxStealWantsCharacter

			return NyxConfig.AutoSteal == true and __NyxStealWantsCharacter ~= nil and __NyxStealWantsCharacter() == true
		end

		local Nyx_isAutoStealActive_var1 = {}

		pcall(function()
			local Nyx_scrambleBossRemotes2 = Nyx_getScrambleBossRemotes()

			if Nyx_scrambleBossRemotes2 and Nyx_scrambleBossRemotes2.ScrambleBoss and Nyx_scrambleBossRemotes2.ScrambleBoss.Hazard then
				Nyx_scrambleBossRemotes2.ScrambleBoss.Hazard.OnClientEvent:Connect(function(hazardData)
					if type(hazardData) == "table" and hazardData.Id then
						Nyx_isAutoStealActive_var1[hazardData.Id] = hazardData
						task.delay((hazardData.Warn or 0) + (ScrambleBossHazards and ScrambleBossHazards.ActiveSeconds(hazardData) or 0.25) + 1.5, function()
							if Nyx_isAutoStealActive_var1[hazardData.Id] == hazardData then
								Nyx_isAutoStealActive_var1[hazardData.Id] = nil
							end
						end)
					end
				end)
			end
		end)

		local function Nyx_isHazardActive(hazardData, position, now)
			if not ScrambleBossHazards then
				return false
			end

			local Nyx_hazardElapsed = now - (hazardData.At or now)
			local Nyx_hazardDuration = ScrambleBossHazards.ActiveSeconds(hazardData)

			if not (Nyx_hazardElapsed >= 0) or not (Nyx_hazardElapsed <= Nyx_hazardDuration) then
				if Nyx_hazardElapsed < 0 and Nyx_hazardElapsed > -2.2 then
					for i = 0, 5 do
						if ScrambleBossHazards.Contains(hazardData, i / 5 * Nyx_hazardDuration, position, false, 3.5) then
							return true
						end
					end
				end
			elseif ScrambleBossHazards.Contains(hazardData, Nyx_hazardElapsed, position, false, 3.5) then
				return true
			end

			return false
		end
		local function Nyx_isPositionSafe(position, now)
			for _, v in pairs(Nyx_isAutoStealActive_var1) do
				if Nyx_isHazardActive(v, position, now) then
					return false
				end
			end

			return true
		end
		local function Nyx_isPositionUnsafe(now)
			local Nyx_scramblePlayerRoot2 = Nyx_getScramblePlayerParts()

			if Nyx_scramblePlayerRoot2 then
				return not Nyx_isPositionSafe(Nyx_scramblePlayerRoot2.Position, now)
			end

			return false
		end
		local function Nyx_findDodgeTarget(now)
			local Nyx_scramblePlayerParts = Nyx_getScramblePlayerParts()
			local Nyx_scrambleArena2 = Nyx_getScrambleArena()

			if not Nyx_scramblePlayerParts or not Nyx_scrambleArena2 then
				return nil
			end

			local attribute = Nyx_scrambleArena2:GetAttribute("Center")
			local Nyx_scrambleHubRadius = tonumber(Nyx_scrambleArena2:GetAttribute("HubRadius")) or 88
			local Y = tonumber(Nyx_scrambleArena2:GetAttribute("FloorY")) or Nyx_scramblePlayerParts.Position.Y
			local Position = Nyx_scramblePlayerParts.Position

			for _, v in ipairs({
				9,
				15,
				23,
				33,
				45
			}) do
				local Nyx_bestDodgePos
				local Nyx_bestDodgeDist

				for i = 0, 11 do
					local Nyx_dodgeAngle = i / 12 * 3.1415926535897931 * 2
					local vector32 = Vector3.new(Position.X + math.cos(Nyx_dodgeAngle) * v, Y + 3, Position.Z + math.sin(Nyx_dodgeAngle) * v)

					if (typeof(attribute) ~= "Vector3" or Vector3.new(vector32.X - attribute.X, 0, vector32.Z - attribute.Z).Magnitude <= Nyx_scrambleHubRadius + 8) and Nyx_isPositionSafe(vector32, now) then
						local Magnitude = (vector32 - Position).Magnitude

						if not Nyx_bestDodgeDist or Magnitude < Nyx_bestDodgeDist then
							Nyx_bestDodgePos = vector32
							Nyx_bestDodgeDist = Magnitude
						end
					end
				end

				if Nyx_bestDodgePos then
					return Nyx_bestDodgePos
				end
			end

			return nil
		end
		local function Nyx_tryDodgeHazard(now)
			if not Nyx_isPositionUnsafe(now) then
				return false
			end

			local Nyx_dodgeTarget = Nyx_findDodgeTarget(now)

			if not Nyx_dodgeTarget then
				return false
			end

			local Nyx_scramblePlayerRoot3 = Nyx_getScramblePlayerParts()

			if Nyx_scramblePlayerRoot3 then
				Nyx_scramblePlayerRoot3.CFrame = cFrameNew(Nyx_dodgeTarget)
				Nyx_scramblePlayerRoot3.AssemblyLinearVelocity = Vector3.zero
				Nyx_scrambleBossFactory_var1.dodges += 1
			end

			return true
		end

		local Nyx_tryDodgeHazard_var1 = 0

		local function Nyx_getOrEquipBat()
			local _, Nyx_scrambleBackpack, Nyx_scrambleCharacter = Nyx_getScramblePlayerParts()

			if not Nyx_scrambleCharacter then
				return nil
			end

			local __NyxIsBatTool = genv.__NyxIsBatTool or function(batTool)
				return batTool:IsA("Tool") and batTool:GetAttribute("IsBat") == true
			end

			for _, child in ipairs(Nyx_scrambleCharacter:GetChildren()) do
				if not __NyxIsBatTool(child) then
					continue
				end

				return child
			end

			local Backpack = LocalPlayer2:FindFirstChild("Backpack")

			if Backpack and Nyx_scrambleBackpack then
				for _, child in ipairs(Backpack:GetChildren()) do
					if not __NyxIsBatTool(child) then
						continue
					end

					pcall(function()
						Nyx_scrambleBackpack:EquipTool(child)
					end)

					return child
				end
			end

			return nil
		end
		local function Nyx_swingBatAt(targetPart)
			local Nyx_batToolRef = Nyx_getOrEquipBat()

			if not Nyx_batToolRef then
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()

			if serverTimeNow - Nyx_tryDodgeHazard_var1 < 0.22 then
				return
			end

			Nyx_tryDodgeHazard_var1 = serverTimeNow
			pcall(function()
				Nyx_batToolRef:Activate()
			end)

			local Handle = Nyx_batToolRef:FindFirstChild("Handle") or Nyx_batToolRef:FindFirstChildWhichIsA("BasePart", true)

			if Handle and targetPart and type(firetouchinterest) == "function" then
				pcall(function()
					firetouchinterest(Handle, targetPart, 0)
					task.wait(0.02)
					firetouchinterest(Handle, targetPart, 1)
				end)
			end

			Nyx_scrambleBossFactory_var1.hits += 1
			pcall(function()
				local Nyx_scrambleBossRemotes3 = Nyx_getScrambleBossRemotes()

				if Nyx_scrambleBossRemotes3 and Nyx_scrambleBossRemotes3.BatSwing then
					Nyx_scrambleBossRemotes3.BatSwing.Trigger:FireServer(nil, string.format("%d:%d:%d", LocalPlayer2.UserId, Nyx_scrambleBossFactory_var1.hits, math.floor(serverTimeNow * 1000)))
				end
			end)
		end

		local Nyx_swingBatAt_var1 = {
			Floor = true,
			Structure = true,
			Collision = true,
			Windows = true,
			BackgroundCrates = true,
			Crates = true,
			Cranes = true,
			VFX = true,
			Coils = true,
			Center = true,
			BossSpawn = true,
			PlayerSpawn = true,
			LeaveTeleport = true,
			HubBlocker = true,
			FloorSlime = true,
			Drones = true,
			ScrambleHazards = true
		}

		local function Nyx_resolveBossHitbox(part)
			if part:IsA("BasePart") then
				return part
			end

			return part.PrimaryPart or part:FindFirstChild("Core") or part:FindFirstChild("Hitbox") or part:FindFirstChild("HumanoidRootPart") or part:FindFirstChildWhichIsA("BasePart", true)
		end
		local function Nyx_findBossTarget(arena)
			local Nyx_scramblePlayerRoot4 = Nyx_getScramblePlayerParts()

			if not Nyx_scramblePlayerRoot4 then
				return nil
			end

			local Nyx_findBossTarget_var1
			local Nyx_findBossTarget_var2
			local Nyx_findBossTarget_var3

			local function Nyx_considerBossTarget(targetPart, priority)
				local Nyx_bossHitbox = Nyx_resolveBossHitbox(targetPart)

				if not Nyx_bossHitbox then
					return
				end

				local Magnitude = (Nyx_bossHitbox.Position - Nyx_scramblePlayerRoot4.Position).Magnitude

				if not Nyx_findBossTarget_var2 or priority < Nyx_findBossTarget_var2 or priority == Nyx_findBossTarget_var2 and Magnitude < Nyx_findBossTarget_var3 then
					Nyx_findBossTarget_var1 = Nyx_bossHitbox
					Nyx_findBossTarget_var2 = priority
					Nyx_findBossTarget_var3 = Magnitude
				end
			end

			for _, v in ipairs({
				"Mech",
				"Ball",
				"Croc",
				"Human",
				"DrScramble",
				"Pilot"
			}) do
				local Nyx_bossChild = arena:FindFirstChild(v)

				if Nyx_bossChild then
					Nyx_considerBossTarget(Nyx_bossChild, 1)
				end
			end

			for _, child in ipairs(arena:GetChildren()) do
				if not Nyx_swingBatAt_var1[child.Name] and child:IsA("Model") and child.Name ~= "Mech" and child:FindFirstChildOfClass("Humanoid") then
					Nyx_considerBossTarget(child, 1)
				end
			end

			local Drones = arena:FindFirstChild("Drones")

			if Drones then
				for _, child in ipairs(Drones:GetChildren()) do
					if child:IsA("Model") then
						local Hitbox = child:FindFirstChild("Hitbox") or child.PrimaryPart

						if Hitbox then
							Nyx_considerBossTarget(Hitbox, 2)
						end
					end
				end
			end

			return Nyx_findBossTarget_var1
		end
		local function Nyx_tryBreakFree()
			if LocalPlayer2:GetAttribute("ScrambleGrabbed") == true then
				pcall(function()
					local Nyx_scrambleBossRemotes4 = Nyx_getScrambleBossRemotes()

					if Nyx_scrambleBossRemotes4 and Nyx_scrambleBossRemotes4.ScrambleBoss then
						Nyx_scrambleBossRemotes4.ScrambleBoss.HazardHit:FireServer(-2)
					end
				end)

				return true
			end

			return false
		end
		local function Nyx_moveRootTowards(targetPos, maxDist)
			local Nyx_scramblePlayerRoot5 = Nyx_getScramblePlayerParts()

			if not Nyx_scramblePlayerRoot5 then
				return
			end

			local Nyx_moveDelta = targetPos - Nyx_scramblePlayerRoot5.Position
			local Magnitude = Nyx_moveDelta.Magnitude

			if Magnitude < 0.5 then
				return
			end

			Nyx_scramblePlayerRoot5.CFrame = cFrameNew(Nyx_scramblePlayerRoot5.Position + Nyx_moveDelta.Unit * math.min(Magnitude, maxDist or 40))
			Nyx_scramblePlayerRoot5.AssemblyLinearVelocity = Vector3.zero
		end
		local function Nyx_stepTowardsPos(targetPos)
			local Nyx_scramblePlayerRoot6 = Nyx_getScramblePlayerParts()

			if not Nyx_scramblePlayerRoot6 then
				return
			end

			local Position = Nyx_scramblePlayerRoot6.Position
			local Nyx_stepCount = math.max(1, math.ceil((targetPos - Position).Magnitude / 140))

			for i = 1, Nyx_stepCount do
				local Nyx_scramblePlayerRoot7 = Nyx_getScramblePlayerParts()

				if not Nyx_scramblePlayerRoot7 then
					return
				end

				Nyx_scramblePlayerRoot7.CFrame = cFrameNew(Position:Lerp(targetPos, i / Nyx_stepCount))
				Nyx_scramblePlayerRoot7.AssemblyLinearVelocity = Vector3.zero
				task.wait(0.08)
			end
		end
		local function leaveArena()
			local Nyx_scrambleArena3 = Nyx_getScrambleArena()

			if not Nyx_scrambleArena3 then
				return false
			end

			local Nyx_scramblePlayerRoot8 = Nyx_getScramblePlayerParts()

			if not Nyx_scramblePlayerRoot8 then
				return false
			end

			local LeaveTeleport = Nyx_scrambleArena3:FindFirstChild("LeaveTeleport")
			local isBasePart = LeaveTeleport and (LeaveTeleport:IsA("BasePart") and LeaveTeleport or LeaveTeleport:FindFirstChildWhichIsA("BasePart", true))

			if not isBasePart then
				return false
			end

			Nyx_scramblePlayerRoot8.CFrame = cFrameNew(isBasePart.Position + Vector3.new(0, 3, 0))
			Nyx_scramblePlayerRoot8.AssemblyLinearVelocity = Vector3.zero

			return true
		end

		Nyx_scrambleBossFactory_var1.leaveArena = leaveArena

		local Nyx_leaveArena_var1 = 0

		task.spawn(function()
			while Nyx_isCurrentSession() do
				if not NyxConfig.ScrambleBossAuto or Nyx_isAutoStealActive() then
					if NyxConfig.ScrambleBossAuto and Nyx_isAutoStealActive() then
						Nyx_scrambleBossFactory_var1.status = "Yielding to Auto Steal"

						if amInArena() and os.clock() - Nyx_leaveArena_var1 > 3 then
							Nyx_leaveArena_var1 = os.clock()
							leaveArena()
						end
					elseif Nyx_scrambleBossFactory_var1.status ~= "Disabled" then
						Nyx_scrambleBossFactory_var1.status = "Disabled"
					end

					task.wait(0.3)
				else
					local Nyx_scrambleArena4 = Nyx_getScrambleArena()

					if amInArena() then
						Nyx_scrambleBossFactory_var1.inArena = true

						local serverTimeNow = workspace:GetServerTimeNow()

						if Nyx_tryDodgeHazard(serverTimeNow) then
							Nyx_scrambleBossFactory_var1.status = "Dodging"
						elseif Nyx_tryBreakFree() then
							Nyx_scrambleBossFactory_var1.status = "Breaking free"
						else
							Nyx_getOrEquipBat()

							local Nyx_bossTarget = Nyx_findBossTarget(Nyx_scrambleArena4)

							if Nyx_bossTarget then
								local Nyx_scramblePlayerRoot9 = Nyx_getScramblePlayerParts()

								if Nyx_scramblePlayerRoot9 and (Nyx_scramblePlayerRoot9.Position - Nyx_bossTarget.Position).Magnitude > 12 then
									Nyx_moveRootTowards(Nyx_bossTarget.Position + Vector3.new(0, 2, 0), 42)
								end

								Nyx_swingBatAt(Nyx_bossTarget)
								Nyx_scrambleBossFactory_var1.status = "Fighting (" .. tostring(Nyx_scrambleArena4:GetAttribute("Phase")) .. ")"
							else
								Nyx_scrambleBossFactory_var1.status = "In arena (" .. tostring(Nyx_scrambleArena4:GetAttribute("Phase")) .. ")"
							end
						end

						task.wait(0.06)
					elseif Nyx_getScramblePortal() then
						Nyx_scrambleBossFactory_var1.status = "Boss up - joining"

						local Nyx_scramblePortalPart = Nyx_getScramblePortal()
						local Position = Nyx_scramblePortalPart and (Nyx_scramblePortalPart:IsA("Model") and select(1, Nyx_scramblePortalPart:GetPivot()).Position or Nyx_scramblePortalPart.Position)

						if Position then
							local Nyx_scramblePlayerRoot10 = Nyx_getScramblePlayerParts()

							if Nyx_scramblePlayerRoot10 and Nyx_eggRuntime and (Nyx_scramblePlayerRoot10.Position - Position).Magnitude > 600 and not Nyx_eggRuntime:_isInSafeArea(Nyx_scramblePlayerRoot10) then
								local Nyx_safeCFForArena = Nyx_eggRuntime:_resolveSafeCFrame(Nyx_scramblePlayerRoot10)

								if Nyx_safeCFForArena then
									Nyx_scrambleBossFactory_var1.status = "Heading to the safe zone first"
									Nyx_stepTowardsPos(Nyx_safeCFForArena.Position)
								end
							end

							Nyx_stepTowardsPos(Position + Vector3.new(0, 3, 0))
							Nyx_scrambleBossFactory_var1.joins += 1
						end

						task.wait(1.2)
					else
						Nyx_scrambleBossFactory_var1.inArena = false
						Nyx_scrambleBossFactory_var1.status = "Waiting for boss"
						task.wait(0.4)
					end
				end
			end
		end)
		task.spawn(function()
			while Nyx_isCurrentSession() do
				if NyxConfig.AutoSteal and not NyxConfig.ScrambleBossAuto and amInArena() then
					leaveArena()
					task.wait(0.5)
				end

				task.wait(0.25)
			end
		end)
		genv.__NyxScrambleBoss = Nyx_scrambleBossFactory_var1
	end

	Nyx_scrambleBossFactory()

	local NyxPanels = {}

	local function Nyx_buildAllUI()
		game:GetService("UserInputService")

		local Assets = require(ReplicatedStorage.Data.Assets)
		local EggState2 = require(ReplicatedStorage.Client.EggState)
		local Save = require(ReplicatedStorage.Shared.Save)
		local Nyx_buildAllUI_var1 = {
			strokeCol = Color3.fromRGB(36, 36, 42),
			accent = Color3.fromRGB(26, 147, 250),
			accentA = Color3.fromRGB(19, 96, 250),
			accentB = Color3.fromRGB(33, 198, 250),
			surface = Color3.fromRGB(22, 22, 27),
			surfaceHi = Color3.fromRGB(28, 28, 34),
			text = Color3.fromRGB(235, 236, 245),
			btnText = Color3.fromRGB(186, 184, 198),
			muted = Color3.fromRGB(156, 154, 170),
			shadow = Color3.fromRGB(4, 4, 8),
			obsTop = Color3.fromRGB(18, 18, 24),
			obsMid = Color3.fromRGB(12, 12, 16),
			obsLow = Color3.fromRGB(10, 14, 26),
			btnBg = Color3.fromRGB(30, 30, 36),
			btnHover = Color3.fromRGB(44, 44, 52),
			inputBg = Color3.fromRGB(14, 14, 18),
			switchOff = Color3.fromRGB(42, 42, 48),
			good = Color3.fromRGB(163, 230, 53)
		}
		local Nyx_uiTheme = Nyx_buildAllUI_var1

		local function Nyx_applyElevatedIdentity()
			pcall(function()
				if type(setthreadidentity) == "function" then
					setthreadidentity(8)
				elseif genv and type(genv.__NyxIdentitySetter) == "function" then
					genv.__NyxIdentitySetter(8)
				end
			end)
		end
		local function Nyx_getUiHost()
			local PlayerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")

			if PlayerGui then
				return PlayerGui
			end

			local ok, result = pcall(function()
				return game:GetService("CoreGui")
			end)

			if not ok or not result then
				return game:GetService("CoreGui")
			end

			return result
		end
		local function Nyx_formatCompactShort(value)
			local Nyx_compactAbsValue = tonumber(value) or 0

			if Nyx_compactAbsValue >= 1e12 then
				return string.format("%.2fT", Nyx_compactAbsValue / 1e12)
			end

			if Nyx_compactAbsValue >= 1e9 then
				return string.format("%.2fB", Nyx_compactAbsValue / 1e9)
			end

			if Nyx_compactAbsValue >= 1000000 then
				return string.format("%.2fM", Nyx_compactAbsValue / 1000000)
			end

			if Nyx_compactAbsValue >= 1000 then
				return string.format("%.2fK", Nyx_compactAbsValue / 1000)
			end

			return string.format("%d", Nyx_compactAbsValue)
		end
		local function Nyx_formatCompactShort2(value)
			return Nyx_formatCompactShort(value)
		end
		local function Nyx_color3ToHex(color)
			if typeof(color) == "Color3" then
				return string.format("#%02x%02x%02x", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
			end

			return "#ffffff"
		end
		local function Nyx_resolveRarityInfo(category)
			local Directory = Assets.Directory and Assets.Directory[category]

			if not Directory or not Directory.Rarity then
				return 0, "?", nil
			end

			local DisplayName = Directory.Rarity.DisplayName or Directory.Rarity._id or "?"

			return Nyx_catalog.rarityRank(DisplayName), DisplayName, Directory.Rarity.Color
		end
		local function Nyx_findIconUrl(category)
			local Directory = Assets.Directory and Assets.Directory[category]

			if type(Directory) ~= "table" then
				return nil
			end

			local function Nyx_normalizeIconUrl(value)
				if type(value) == "string" and value ~= "" then
					if value:find("rbxassetid") or value:find("rbxthumb") then
						return value
					end

					if value:match("^%d+$") then
						return "rbxassetid://" .. value
					end
				elseif type(value) == "number" and value > 0 then
					return "rbxassetid://" .. tostring(value)
				end

				return nil
			end

			local Nyx_imageFields = {
				"Image",
				"Icon",
				"Thumbnail",
				"ImageId",
				"IconId",
				"Texture",
				"Asset",
				"DisplayImage"
			}

			for _, v in ipairs(Nyx_imageFields) do
				local Nyx_iconUrl = Nyx_normalizeIconUrl(Directory[v])

				if not Nyx_iconUrl then
					continue
				end

				return Nyx_iconUrl
			end

			if type(Directory.Egg) == "table" then
				for _, v in ipairs(Nyx_imageFields) do
					local Nyx_iconUrlEgg = Nyx_normalizeIconUrl(Directory.Egg[v])

					if not Nyx_iconUrlEgg then
						continue
					end

					return Nyx_iconUrlEgg
				end
			end

			return nil
		end

		local Nyx_rarityListAll = {}
		local Nyx_rarityRankMap = {}
		local pairs_ = pairs
		local Directory = Assets.Directory or {}

		for k, v in pairs_(Directory) do
			if type(v) == "table" and v.Rarity then
				local DisplayName = v.Rarity.DisplayName or v.Rarity._id or "?"
				local Nyx_rarityRankValue = Nyx_catalog.rarityRank(DisplayName)

				Nyx_rarityRankMap[DisplayName] = Nyx_rarityRankValue
				table.insert(Nyx_rarityListAll, {
					cat = k,
					rnum = Nyx_rarityRankValue,
					rname = DisplayName
				})
			end
		end

		table.sort(Nyx_rarityListAll, function(entryA, entryB)
			if entryA.rnum == entryB.rnum then
				return entryA.cat < entryB.cat
			end

			return entryA.rnum > entryB.rnum
		end)

		local function Nyx_getRarityOptions()
			local Nyx_raritySeen = {}
			local Nyx_rarityUnique = {}

			for _, v in ipairs(Nyx_rarityListAll) do
				if not Nyx_raritySeen[v.rname] then
					Nyx_raritySeen[v.rname] = true
					table.insert(Nyx_rarityUnique, {
						v.rname,
						v.rnum
					})
				end
			end

			table.sort(Nyx_rarityUnique, function(entryA, entryB)
				return entryA[2] > entryB[2]
			end)

			local Nyx_rarityOrder = { "Any" }

			for _, v in ipairs(Nyx_rarityUnique) do
				table.insert(Nyx_rarityOrder, v[1])
			end

			return Nyx_rarityOrder
		end
		local function Nyx_getRarityOptionsNoAny()
			local Nyx_rarityList = {}

			for _, v in ipairs(Nyx_getRarityOptions()) do
				if v ~= "Any" then
					table.insert(Nyx_rarityList, v)
				end
			end

			return Nyx_rarityList
		end
		local function Nyx_computeAreaEggValue(record)
			local Nyx_computeAreaEggValue_var1 = 0

			pcall(function()
				Nyx_computeAreaEggValue_var1 = NyxConfig:getAreaEggValue(record) or 0
			end)

			if Nyx_computeAreaEggValue_var1 > 0 then
				return Nyx_computeAreaEggValue_var1
			end

			pcall(function()
				local AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)

				if AssetEarnings and type(AssetEarnings.LiveRatePerSecond) == "function" then
					Nyx_computeAreaEggValue_var1 = AssetEarnings.LiveRatePerSecond(record) or 0
				end
			end)

			local Nyx_areaEggValue = Nyx_computeAreaEggValue_var1 or 0

			return Nyx_areaEggValue
		end
		local function Nyx_computeEggWeight(record)
			local Nyx_computeEggWeight_var1 = 0

			pcall(function()
				local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
				local AssetCategory = record.AssetCategory or record.Category

				Nyx_computeEggWeight_var1 = EggRecords.WeightKgForScale(AssetCategory, record.AssetScale or record.Scale or 1)
			end)

			local Nyx_eggWeightValue = Nyx_computeEggWeight_var1 or 0

			return Nyx_eggWeightValue
		end
		local function Nyx_countPlacedEggs()
			local Nyx_countPlacedEggs_var1 = 0
			local Nyx_countPlacedEggs_var2 = 0

			pcall(function()
				local pairs_2 = pairs
				local Nyx_ownedEggs = EggState2.ReadOwnerEggs(LocalPlayer.UserId) or {}

				for _, v in pairs_2(Nyx_ownedEggs) do
					if v.Placement == nil then
						Nyx_countPlacedEggs_var2 += 1
					else
						Nyx_countPlacedEggs_var1 += 1
					end
				end
			end)

			return Nyx_countPlacedEggs_var1, math.max(0, 50 - Nyx_countPlacedEggs_var1), Nyx_countPlacedEggs_var2
		end

		local Nyx_eggLogCounts = {}

		local function Nyx_incrementEggLog(record)
			local AssetCategory = record and (record.AssetCategory or record.Category)

			if not AssetCategory then
				return
			end

			local Nyx_eggLogEntry = Nyx_eggLogCounts[AssetCategory]

			if not Nyx_eggLogEntry then
				local Nyx_eggLogRank, Nyx_eggLogRarity, Nyx_eggLogColor = Nyx_resolveRarityInfo(AssetCategory)

				Nyx_eggLogEntry = {
					name = AssetCategory,
					rarity = Nyx_eggLogRarity,
					rnum = Nyx_eggLogRank,
					color = Nyx_eggLogColor,
					count = 0,
					last = 0,
					image = Nyx_findIconUrl(AssetCategory)
				}
				Nyx_eggLogCounts[AssetCategory] = Nyx_eggLogEntry
			end

			Nyx_eggLogEntry.count += 1
			Nyx_eggLogEntry.last = os.clock()
		end

		local windows = {}

		local function Nyx_isWindowOpen(panelKey)
			local Nyx_windowState = windows[panelKey]

			return Nyx_windowState ~= nil and Nyx_windowState.gui ~= nil and Nyx_windowState.gui.Parent ~= nil and Nyx_windowState.gui.Enabled or false
		end

		local Nyx_refreshEggLogs
		local Nyx_refreshEggBoard
		local Nyx_refreshInventory
		local Nyx_EggCheckerUI = {
			list = nil,
			headLbl = nil,
			countLbl = nil,
			statusBtn = nil,
			sel = nil,
			rows = {},
			picked = {},
			chips = {},
			sortBtns = {},
			modeBtns = {}
		}
		local Nyx_EggDataUI = {
			history = {},
			reportedUids = {},
			knownFieldUids = {},
			lastAlert = nil,
			lastReportTime = 0,
			lastSync = 0,
			onlineCount = 1,
			category = "targets",
			filter = "All"
		}

		local function Nyx_refreshPanelByKey(panelKey)
			Nyx_applyElevatedIdentity()

			if panelKey == "logs" then
				if Nyx_refreshEggLogs then
					Nyx_refreshEggLogs()
				end
			elseif panelKey == "eggs" then
				if Nyx_refreshEggBoard then
					Nyx_refreshEggBoard()
				end
			elseif panelKey == "inventory" then
				if Nyx_refreshInventory then
					Nyx_refreshInventory()
				end
			elseif panelKey == "checker" then
				if Nyx_EggCheckerUI and Nyx_EggCheckerUI.refresh then
					Nyx_EggCheckerUI.refresh()
				end
			elseif panelKey == "eggdata" and Nyx_EggDataUI and Nyx_EggDataUI.refresh then
				Nyx_EggDataUI.refresh()
			end
		end

		local Nyx_refreshPanelByKey_var3
		local TextLabel
		local Nyx_refreshPanelByKey_var1 = "rarity"
		local Nyx_refreshPanelByKey_var2 = {}

		local function Nyx_refreshLogsSortUI()
			Nyx_applyElevatedIdentity()

			for k, v in pairs(Nyx_refreshPanelByKey_var2) do
				local Nyx_isSortActive = k == Nyx_refreshPanelByKey_var1

				v.BackgroundColor3 = Nyx_isSortActive and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
				v.BackgroundTransparency = Nyx_isSortActive and 0.15 or 0.88
				v.TextColor3 = Nyx_isSortActive and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText

				local UIStroke = v:FindFirstChildOfClass("UIStroke")

				if UIStroke then
					UIStroke.Transparency = Nyx_isSortActive and 0 or 1
				end
			end
		end

		Nyx_refreshEggLogs = function()
			Nyx_applyElevatedIdentity()

			if not Nyx_refreshPanelByKey_var3 then
				return
			end

			for _, child in ipairs(Nyx_refreshPanelByKey_var3:GetChildren()) do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end

			local Nyx_logsRows = {}
			local Nyx_refreshEggLogs_var1 = 0

			for _, v in pairs(Nyx_eggLogCounts) do
				table.insert(Nyx_logsRows, v)
				Nyx_refreshEggLogs_var1 += v.count
			end

			if Nyx_refreshPanelByKey_var1 == "count" then
				table.sort(Nyx_logsRows, function(entryA, entryB)
					if entryA.count == entryB.count then
						return (entryA.rnum or 0) > (entryB.rnum or 0)
					end

					return entryA.count > entryB.count
				end)
			elseif Nyx_refreshPanelByKey_var1 == "name" then
				table.sort(Nyx_logsRows, function(entryA, entryB)
					return tostring(entryA.name) < tostring(entryB.name)
				end)
			else
				table.sort(Nyx_logsRows, function(entryA, entryB)
					if entryA.rnum == entryB.rnum then
						return entryA.count > entryB.count
					end

					return (entryA.rnum or 0) > (entryB.rnum or 0)
				end)
			end

			for i, v in ipairs(Nyx_logsRows) do
				local Frame = Instance.new("Frame")

				Frame.Size = UDim2.new(1, -6, 0, 34)
				Frame.BackgroundColor3 = Nyx_uiTheme.surface
				Frame.BackgroundTransparency = 0.12
				Frame.BorderSizePixel = 0
				Frame.LayoutOrder = i
				Frame.Parent = Nyx_refreshPanelByKey_var3
				Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

				local UIStroke = Instance.new("UIStroke", Frame)

				UIStroke.Color = Nyx_uiTheme.strokeCol
				UIStroke.Thickness = 1
				UIStroke.Transparency = 0.72

				local Frame2 = Instance.new("Frame")

				Frame2.Size = UDim2.new(0, 3, 1, -10)
				Frame2.Position = UDim2.fromOffset(0, 5)
				Frame2.BorderSizePixel = 0
				Frame2.BackgroundColor3 = v.color or Nyx_uiTheme.accent
				Frame2.Parent = Frame
				Instance.new("UICorner", Frame2).CornerRadius = UDim.new(1, 0)

				local ImageLabel = Instance.new("ImageLabel")

				ImageLabel.Position = UDim2.fromOffset(10, 5)
				ImageLabel.Size = UDim2.fromOffset(24, 24)
				ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageLabel.BackgroundTransparency = v.image and 0.9 or 0.94
				ImageLabel.BorderSizePixel = 0
				ImageLabel.ScaleType = Enum.ScaleType.Fit
				ImageLabel.Image = v.image or ""
				ImageLabel.Parent = Frame
				Instance.new("UICorner", ImageLabel).CornerRadius = UDim.new(0, 4)

				if not v.image then
					local Frame3 = Instance.new("Frame")

					Frame3.AnchorPoint = Vector2.new(0.5, 0.5)
					Frame3.Position = UDim2.fromScale(0.5, 0.5)
					Frame3.Size = UDim2.fromOffset(9, 9)
					Frame3.BackgroundColor3 = v.color or Nyx_uiTheme.accent
					Frame3.BorderSizePixel = 0
					Frame3.Parent = ImageLabel
					Instance.new("UICorner", Frame3).CornerRadius = UDim.new(1, 0)
				end

				local TextLabel2 = Instance.new("TextLabel")

				TextLabel2.BackgroundTransparency = 1
				TextLabel2.Position = UDim2.fromOffset(42, 0)
				TextLabel2.Size = UDim2.new(0.5, -42, 1, 0)
				TextLabel2.Font = Enum.Font.GothamBold
				TextLabel2.TextSize = 13
				TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel2.TextTruncate = Enum.TextTruncate.AtEnd
				TextLabel2.TextColor3 = Nyx_uiTheme.text
				TextLabel2.Text = tostring(v.name)
				TextLabel2.Parent = Frame

				local TextLabel3 = Instance.new("TextLabel")

				TextLabel3.BackgroundTransparency = 1
				TextLabel3.Position = UDim2.new(0.5, 0, 0, 0)
				TextLabel3.Size = UDim2.new(0.3, 0, 1, 0)
				TextLabel3.Font = Enum.Font.GothamBold
				TextLabel3.TextSize = 12
				TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel3.TextColor3 = v.color or Nyx_uiTheme.muted
				TextLabel3.Text = tostring(v.rarity)
				TextLabel3.Parent = Frame

				local TextLabel4 = Instance.new("TextLabel")

				TextLabel4.BackgroundTransparency = 1
				TextLabel4.Position = UDim2.new(0.8, 0, 0, 0)
				TextLabel4.Size = UDim2.new(0.2, -12, 1, 0)
				TextLabel4.Font = Enum.Font.GothamBold
				TextLabel4.TextSize = 13
				TextLabel4.TextXAlignment = Enum.TextXAlignment.Right
				TextLabel4.TextColor3 = Nyx_uiTheme.accent
				TextLabel4.Text = "x" .. tostring(v.count)
				TextLabel4.Parent = Frame
			end

			Nyx_refreshPanelByKey_var3.CanvasSize = UDim2.new(0, 0, 0, #Nyx_logsRows * 38 + 6)

			if TextLabel then
				TextLabel.Text = "Total: " .. tostring(Nyx_refreshEggLogs_var1)
			end
		end

		local function Nyx_buildEggLogsPanel(parentFrame)
			TextLabel = Instance.new("TextLabel")
			TextLabel.BackgroundTransparency = 1
			TextLabel.Position = UDim2.new(1, -150, 0, 4)
			TextLabel.Size = UDim2.fromOffset(110, 22)
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.TextSize = 12
			TextLabel.TextXAlignment = Enum.TextXAlignment.Right
			TextLabel.TextColor3 = Nyx_uiTheme.muted
			TextLabel.Text = "Total: 0"
			TextLabel.Parent = parentFrame

			local Frame = Instance.new("Frame")

			Frame.Position = UDim2.fromOffset(14, 4)
			Frame.Size = UDim2.new(1, -28, 0, 28)
			Frame.BackgroundTransparency = 1
			Frame.Parent = parentFrame

			local UIListLayout = Instance.new("UIListLayout", Frame)

			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout.Padding = UDim.new(0, 6)
			UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local function Nyx_createLogSortButton(label, sortKey, width)
				local TextButton = Instance.new("TextButton")

				TextButton.Size = UDim2.fromOffset(width, 26)
				TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.BackgroundTransparency = 0.88
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.GothamBold
				TextButton.TextSize = 12
				TextButton.TextColor3 = Nyx_uiTheme.btnText
				TextButton.Text = label
				TextButton.Parent = Frame
				Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)

				local UIStroke = Instance.new("UIStroke", TextButton)

				UIStroke.Color = Nyx_uiTheme.accent
				UIStroke.Thickness = 1
				UIStroke.Transparency = 1
				TextButton.MouseButton1Click:Connect(function()
					Nyx_refreshPanelByKey_var1 = sortKey
					Nyx_refreshLogsSortUI()
					Nyx_refreshEggLogs()
				end)
				Nyx_refreshPanelByKey_var2[sortKey] = TextButton
			end

			Nyx_createLogSortButton("Rarity", "rarity", 66)
			Nyx_createLogSortButton("Amount", "count", 66)
			Nyx_createLogSortButton("Name", "name", 58)

			local TextButton = Instance.new("TextButton")

			TextButton.Size = UDim2.fromOffset(54, 26)
			TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextButton.BackgroundTransparency = 0.88
			TextButton.AutoButtonColor = false
			TextButton.Font = Enum.Font.GothamBold
			TextButton.TextSize = 12
			TextButton.TextColor3 = Nyx_uiTheme.btnText
			TextButton.Text = "Clear"
			TextButton.Parent = Frame
			Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)

			local UIStroke = Instance.new("UIStroke", TextButton)

			UIStroke.Color = Nyx_uiTheme.accent
			UIStroke.Thickness = 1
			UIStroke.Transparency = 1
			TextButton.MouseButton1Click:Connect(function()
				Nyx_eggLogCounts = {}
				Nyx_refreshEggLogs()
			end)

			local Frame2 = Instance.new("Frame")

			Frame2.Position = UDim2.fromOffset(16, 38)
			Frame2.Size = UDim2.new(1, -32, 0, 18)
			Frame2.BackgroundTransparency = 1
			Frame2.Parent = parentFrame

			local function Nyx_createLogHeaderLabel(label, position, size, alignment)
				local TextLabel2 = Instance.new("TextLabel")

				TextLabel2.BackgroundTransparency = 1
				TextLabel2.Position = position
				TextLabel2.Size = size
				TextLabel2.Font = Enum.Font.GothamBold
				TextLabel2.TextSize = 11
				TextLabel2.TextColor3 = Nyx_uiTheme.muted
				TextLabel2.TextXAlignment = alignment
				TextLabel2.Text = label
				TextLabel2.Parent = Frame2
			end

			Nyx_createLogHeaderLabel("EGG", UDim2.fromOffset(26, 0), UDim2.new(0.5, -26, 1, 0), Enum.TextXAlignment.Left)
			Nyx_createLogHeaderLabel("RARITY", UDim2.new(0.5, 0, 0, 0), UDim2.new(0.3, 0, 1, 0), Enum.TextXAlignment.Left)
			Nyx_createLogHeaderLabel("AMOUNT", UDim2.new(0.8, 0, 0, 0), UDim2.new(0.2, -12, 1, 0), Enum.TextXAlignment.Right)

			local ScrollingFrame = Instance.new("ScrollingFrame")

			ScrollingFrame.Position = UDim2.fromOffset(14, 60)
			ScrollingFrame.Size = UDim2.new(1, -28, 1, -68)
			ScrollingFrame.BackgroundTransparency = 1
			ScrollingFrame.BorderSizePixel = 0
			ScrollingFrame.ScrollBarThickness = 3
			ScrollingFrame.ScrollBarImageColor3 = Nyx_uiTheme.accent
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame.Parent = parentFrame

			local UIListLayout2 = Instance.new("UIListLayout", ScrollingFrame)

			UIListLayout2.Padding = UDim.new(0, 4)
			UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
			Nyx_refreshPanelByKey_var3 = ScrollingFrame
			Nyx_refreshLogsSortUI()
			Nyx_refreshEggLogs()
		end

		local Nyx_createLogHeaderLabel_var4
		local TextLabel2
		local startPlacing
		local TextLabel3
		local Nyx_createLogHeaderLabel_var1 = "All"
		local Nyx_createLogHeaderLabel_var2 = {}
		local Nyx_createLogHeaderLabel_var3 = {}

		local function Nyx_refreshBoardRarityChips()
			Nyx_applyElevatedIdentity()

			for k, v in pairs(Nyx_createLogHeaderLabel_var2) do
				local Nyx_isBoardChipActive = k == Nyx_createLogHeaderLabel_var1

				v.BackgroundColor3 = Nyx_isBoardChipActive and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
				v.BackgroundTransparency = Nyx_isBoardChipActive and 0.15 or 0.88
				v.TextColor3 = Nyx_isBoardChipActive and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText

				local UIStroke = v:FindFirstChildOfClass("UIStroke")

				if UIStroke then
					UIStroke.Transparency = Nyx_isBoardChipActive and 0 or 1
				end
			end
		end

		Nyx_refreshEggBoard = function()
			Nyx_applyElevatedIdentity()

			if not Nyx_createLogHeaderLabel_var4 then
				return
			end

			for _, child in ipairs(Nyx_createLogHeaderLabel_var4:GetChildren()) do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end

			local ok, result = pcall(function()
				return EggState2.ReadOwnerEggs(LocalPlayer.UserId)
			end)

			if not ok or type(result) ~= "table" then
				if TextLabel3 then
					TextLabel3.Text = "Total: 0  ON: 0"
				end

				return
			end

			local Nyx_boardRows = {}
			local Nyx_refreshEggBoard_var1 = 0

			for k, v in pairs(result) do
				if v.Placement == nil then
					local Nyx_boardEggRank, Nyx_boardEggRarity, Nyx_boardEggColor = Nyx_resolveRarityInfo(v.AssetCategory)

					if Nyx_createLogHeaderLabel_var1 == "All" or Nyx_boardEggRarity == Nyx_createLogHeaderLabel_var1 then
						local Nyx_boardEggEnabled = Nyx_createLogHeaderLabel_var3[k] ~= false

						if Nyx_boardEggEnabled then
							Nyx_refreshEggBoard_var1 += 1
						end

						local Directory2 = Assets.Directory and Assets.Directory[v.AssetCategory]

						table.insert(Nyx_boardRows, {
							uid = k,
							name = Directory2 and Directory2.DisplayName or v.AssetCategory or tostring(k):sub(1, 8),
							rarity = Nyx_boardEggRarity,
							rnum = Nyx_boardEggRank,
							color = Nyx_boardEggColor,
							image = Nyx_findIconUrl(v.AssetCategory),
							enabled = Nyx_boardEggEnabled
						})
					end
				end
			end

			table.sort(Nyx_boardRows, function(entryA, entryB)
				if entryA.rnum == entryB.rnum then
					return entryA.name < entryB.name
				end

				return (entryA.rnum or 0) > (entryB.rnum or 0)
			end)

			for i, v in ipairs(Nyx_boardRows) do
				local Frame = Instance.new("Frame")

				Frame.Size = UDim2.new(1, -6, 0, 34)
				Frame.BackgroundColor3 = Nyx_uiTheme.surface
				Frame.BackgroundTransparency = 0.12
				Frame.BorderSizePixel = 0
				Frame.LayoutOrder = i
				Frame.Parent = Nyx_createLogHeaderLabel_var4
				Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

				local UIStroke = Instance.new("UIStroke", Frame)

				UIStroke.Color = Nyx_uiTheme.strokeCol
				UIStroke.Thickness = 1
				UIStroke.Transparency = 0.72

				local Frame2 = Instance.new("Frame")

				Frame2.Size = UDim2.new(0, 3, 1, -10)
				Frame2.Position = UDim2.fromOffset(0, 5)
				Frame2.BorderSizePixel = 0
				Frame2.BackgroundColor3 = v.color or Nyx_uiTheme.accent
				Frame2.Parent = Frame
				Instance.new("UICorner", Frame2).CornerRadius = UDim.new(1, 0)

				local ImageLabel = Instance.new("ImageLabel")

				ImageLabel.Position = UDim2.fromOffset(10, 5)
				ImageLabel.Size = UDim2.fromOffset(24, 24)
				ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageLabel.BackgroundTransparency = 1
				ImageLabel.BorderSizePixel = 0
				ImageLabel.ScaleType = Enum.ScaleType.Fit
				ImageLabel.Image = v.image or ""
				ImageLabel.Parent = Frame
				Instance.new("UICorner", ImageLabel).CornerRadius = UDim.new(0, 4)

				if not v.image then
					local Frame3 = Instance.new("Frame")

					Frame3.AnchorPoint = Vector2.new(0.5, 0.5)
					Frame3.Position = UDim2.fromScale(0.5, 0.5)
					Frame3.Size = UDim2.fromOffset(9, 9)
					Frame3.BackgroundColor3 = v.color or Nyx_uiTheme.accent
					Frame3.BorderSizePixel = 0
					Frame3.Parent = ImageLabel
					Instance.new("UICorner", Frame3).CornerRadius = UDim.new(1, 0)
				end

				local TextLabel4 = Instance.new("TextLabel")

				TextLabel4.BackgroundTransparency = 1
				TextLabel4.Position = UDim2.fromOffset(42, 0)
				TextLabel4.Size = UDim2.new(0.55, -42, 1, 0)
				TextLabel4.Font = Enum.Font.GothamBold
				TextLabel4.TextSize = 12
				TextLabel4.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel4.TextTruncate = Enum.TextTruncate.AtEnd
				TextLabel4.TextColor3 = Nyx_uiTheme.text
				TextLabel4.Text = tostring(v.name)
				TextLabel4.Parent = Frame

				local TextLabel5 = Instance.new("TextLabel")

				TextLabel5.BackgroundTransparency = 1
				TextLabel5.Position = UDim2.new(0.55, 0, 0, 0)
				TextLabel5.Size = UDim2.new(0.23, 0, 1, 0)
				TextLabel5.Font = Enum.Font.GothamBold
				TextLabel5.TextSize = 11
				TextLabel5.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel5.TextColor3 = v.color or Nyx_uiTheme.muted
				TextLabel5.Text = tostring(v.rarity)
				TextLabel5.Parent = Frame

				local TextButton = Instance.new("TextButton")

				TextButton.Position = UDim2.new(1, -62, 0, 5)
				TextButton.Size = UDim2.fromOffset(56, 24)
				TextButton.BackgroundColor3 = v.enabled and Nyx_uiTheme.accent or Color3.fromRGB(78, 78, 96)
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.GothamBold
				TextButton.TextSize = 11
				TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.Text = v.enabled and "ON" or "OFF"
				TextButton.Parent = Frame
				Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 5)

				local UIStroke2 = Instance.new("UIStroke", TextButton)

				UIStroke2.Color = Nyx_uiTheme.strokeCol
				UIStroke2.Thickness = 1
				UIStroke2.Transparency = 0.6
				TextButton.MouseButton1Click:Connect(function()
					if Nyx_createLogHeaderLabel_var3[v.uid] == false then
						Nyx_createLogHeaderLabel_var3[v.uid] = nil
					else
						Nyx_createLogHeaderLabel_var3[v.uid] = false
					end

					Nyx_refreshEggBoard()
				end)
			end

			Nyx_createLogHeaderLabel_var4.CanvasSize = UDim2.new(0, 0, 0, #Nyx_boardRows * 38 + 6)

			if TextLabel3 then
				TextLabel3.Text = string.format("Total: %d  ON: %d", #Nyx_boardRows, Nyx_refreshEggBoard_var1)
			end

			if TextLabel2 then
				local Nyx_placedCount, Nyx_roomCount, Nyx_waitingCount = Nyx_countPlacedEggs()

				if Nyx_roomCount <= 0 then
					TextLabel2.Text = string.format("Plot FULL - %d/50 placed, %d waiting", Nyx_placedCount, Nyx_waitingCount)
				else
					TextLabel2.Text = string.format("Plot %d/50 - room for %d more, %d waiting", Nyx_placedCount, Nyx_roomCount, Nyx_waitingCount)
				end
			end
		end

		local function Nyx_buildEggBoardPanel(parentFrame)
			local Frame = Instance.new("Frame")

			Frame.Size = UDim2.fromScale(1, 1)
			Frame.BackgroundTransparency = 1
			Frame.BorderSizePixel = 0
			Frame.Parent = parentFrame
			TextLabel3 = Instance.new("TextLabel")
			TextLabel3.BackgroundTransparency = 1
			TextLabel3.Position = UDim2.new(0, 236, 1, -60)
			TextLabel3.Size = UDim2.new(1, -250, 0, 26)
			TextLabel3.Font = Enum.Font.GothamBold
			TextLabel3.TextSize = 12
			TextLabel3.TextXAlignment = Enum.TextXAlignment.Right
			TextLabel3.TextColor3 = Nyx_uiTheme.muted
			TextLabel3.Text = "Total: 0  ON: 0"
			TextLabel3.Parent = Frame

			local ScrollingFrame = Instance.new("ScrollingFrame")

			ScrollingFrame.Position = UDim2.fromOffset(14, 4)
			ScrollingFrame.Size = UDim2.new(1, -28, 0, 28)
			ScrollingFrame.BackgroundTransparency = 1
			ScrollingFrame.BorderSizePixel = 0
			ScrollingFrame.ScrollBarThickness = 3
			ScrollingFrame.ScrollBarImageColor3 = Nyx_uiTheme.accent
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame.Parent = Frame

			local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)

			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout.Padding = UDim.new(0, 6)
			UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			Nyx_createLogHeaderLabel_var2 = {}

			local Nyx_buildEggBoardPanel_var1 = 0

			local function Nyx_createBoardChip(label)
				local TextButton = Instance.new("TextButton")
				local Nyx_chipWidth = math.max(42, #label * 6 + 12)

				TextButton.Size = UDim2.fromOffset(Nyx_chipWidth, 24)
				TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.BackgroundTransparency = 0.88
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.GothamBold
				TextButton.TextSize = 12
				TextButton.TextColor3 = Nyx_uiTheme.btnText
				TextButton.Text = label
				TextButton.Parent = ScrollingFrame
				Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)

				local UIStroke = Instance.new("UIStroke", TextButton)

				UIStroke.Color = Nyx_uiTheme.accent
				UIStroke.Thickness = 1
				UIStroke.Transparency = 1
				TextButton.MouseButton1Click:Connect(function()
					Nyx_createLogHeaderLabel_var1 = label
					Nyx_refreshBoardRarityChips()
					Nyx_refreshEggBoard()
				end)
				Nyx_createLogHeaderLabel_var2[label] = TextButton
				Nyx_buildEggBoardPanel_var1 = Nyx_buildEggBoardPanel_var1 + Nyx_chipWidth + 6
			end

			Nyx_createBoardChip("All")

			for _, v in ipairs(Nyx_getRarityOptionsNoAny()) do
				Nyx_createBoardChip(v)
			end

			ScrollingFrame.CanvasSize = UDim2.new(0, Nyx_buildEggBoardPanel_var1 + 4, 0, 0)
			Nyx_refreshBoardRarityChips()

			local Frame2 = Instance.new("Frame")

			Frame2.Position = UDim2.fromOffset(16, 38)
			Frame2.Size = UDim2.new(1, -32, 0, 18)
			Frame2.BackgroundTransparency = 1
			Frame2.Parent = Frame

			local function Nyx_createBoardHeaderLabel(label, position, size, alignment)
				local TextLabel4 = Instance.new("TextLabel")

				TextLabel4.BackgroundTransparency = 1
				TextLabel4.Position = position
				TextLabel4.Size = size
				TextLabel4.Font = Enum.Font.GothamBold
				TextLabel4.TextSize = 11
				TextLabel4.TextColor3 = Nyx_uiTheme.muted
				TextLabel4.TextXAlignment = alignment
				TextLabel4.Text = label
				TextLabel4.Parent = Frame2
			end

			Nyx_createBoardHeaderLabel("EGG", UDim2.fromOffset(26, 0), UDim2.new(0.55, -26, 1, 0), Enum.TextXAlignment.Left)
			Nyx_createBoardHeaderLabel("RARITY", UDim2.new(0.55, 0, 0, 0), UDim2.new(0.23, 0, 1, 0), Enum.TextXAlignment.Left)
			Nyx_createBoardHeaderLabel("PLACE", UDim2.new(1, -62, 0, 0), UDim2.fromOffset(56, 18), Enum.TextXAlignment.Center)

			local ScrollingFrame2 = Instance.new("ScrollingFrame")

			ScrollingFrame2.Position = UDim2.fromOffset(14, 60)
			ScrollingFrame2.Size = UDim2.new(1, -28, 1, -126)
			ScrollingFrame2.BackgroundTransparency = 1
			ScrollingFrame2.BorderSizePixel = 0
			ScrollingFrame2.ScrollBarThickness = 3
			ScrollingFrame2.ScrollBarImageColor3 = Nyx_uiTheme.accent
			ScrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame2.Parent = Frame

			local UIListLayout2 = Instance.new("UIListLayout", ScrollingFrame2)

			UIListLayout2.Padding = UDim.new(0, 4)
			UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
			Nyx_createLogHeaderLabel_var4 = ScrollingFrame2

			local function createTextButton(label, width, color, order)
				local TextButton = Instance.new("TextButton")

				TextButton.Size = UDim2.fromOffset(width, 28)
				TextButton.BackgroundColor3 = color or Nyx_uiTheme.accent
				TextButton.BackgroundTransparency = 0.15
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.GothamBold
				TextButton.TextSize = 12
				TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.Text = label
				TextButton.LayoutOrder = order or 1
				Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)

				local UIStroke = Instance.new("UIStroke", TextButton)

				UIStroke.Color = Nyx_uiTheme.strokeCol
				UIStroke.Thickness = 1
				UIStroke.Transparency = 0.6

				return TextButton
			end

			local Frame3 = Instance.new("Frame")

			Frame3.Position = UDim2.new(0, 14, 1, -60)
			Frame3.Size = UDim2.new(0, 220, 0, 28)
			Frame3.BackgroundTransparency = 1
			Frame3.Parent = Frame

			local UIListLayout3 = Instance.new("UIListLayout", Frame3)

			UIListLayout3.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout3.Padding = UDim.new(0, 6)
			UIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center

			local toggleAll = createTextButton("Toggle All", 80, Color3.fromRGB(60, 70, 95), 1)

			toggleAll.Parent = Frame3
			toggleAll.MouseButton1Click:Connect(function()
				local ok, result = pcall(function()
					return EggState2.ReadOwnerEggs(LocalPlayer.UserId)
				end)

				if not ok or type(result) ~= "table" then
					return
				end

				local Nyx_allEggNyxbled = false
				local Nyx_pairsIter, Nyx_pairsIterState, Nyx_pairsIterControl = pairs(result)
				local Nyx_pairsIterator = geniter(Nyx_pairsIter, Nyx_pairsIterState, Nyx_pairsIterControl)

				while true do
					local Nyx_pairsPack = table.pack(Nyx_pairsIterator())

					if Nyx_pairsPack[1] then
						if (Nyx_pairsPack[3]).Placement == nil and Nyx_createLogHeaderLabel_var3[Nyx_pairsPack[2]] == false then
							Nyx_allEggNyxbled = true

							break
						end
					else
						break
					end
				end

				local Nyx_pairsIter2, Nyx_pairsIterState2, Nyx_pairsIterControl2 = pairs(result)

				for k, v in Nyx_pairsIter2, Nyx_pairsIterState2, Nyx_pairsIterControl2 do
					if v.Placement == nil then
						if Nyx_allEggNyxbled then
							Nyx_createLogHeaderLabel_var3[k] = nil
						else
							Nyx_createLogHeaderLabel_var3[k] = false
						end
					end
				end

				Nyx_refreshEggBoard()
			end)
			startPlacing = createTextButton("Start Placing", 120, Nyx_uiTheme.accent, 2)
			startPlacing.Parent = Frame3
			startPlacing.MouseButton1Click:Connect(function()
				pcall(function()
					if type(applyAutoPlace) == "function" then
						applyAutoPlace(true)
					elseif type(Nyx_AutoLoops) == "table" and type(Nyx_AutoLoops.AutoPlaceLoop) == "function" then
						NyxConfig.AutoPlace = true
						task.spawn(Nyx_AutoLoops.AutoPlaceLoop)
					end
				end)
			end)
			TextLabel2 = Instance.new("TextLabel")
			TextLabel2.BackgroundTransparency = 1
			TextLabel2.Position = UDim2.new(0, 16, 1, -26)
			TextLabel2.Size = UDim2.new(1, -32, 0, 18)
			TextLabel2.Font = Enum.Font.GothamMedium
			TextLabel2.TextSize = 11
			TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel2.TextColor3 = Nyx_uiTheme.muted
			TextLabel2.Text = ""
			TextLabel2.Parent = Frame
			Nyx_refreshEggBoard()
		end

		local Nyx_createTextButton_var5
		local TextLabel4
		local Nyx_createTextButton_var1 = "backpack"
		local Nyx_createTextButton_var2 = "moneys"
		local Nyx_createTextButton_var6 = false
		local Nyx_createTextButton_var3 = {}
		local Nyx_createTextButton_var4 = {}

		local function Nyx_refreshInvTabUI()
			Nyx_applyElevatedIdentity()

			for k, v in pairs(Nyx_createTextButton_var4) do
				local Nyx_isInvBackpackTab = k == Nyx_createTextButton_var1

				v.BackgroundColor3 = Nyx_isInvBackpackTab and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
				v.BackgroundTransparency = Nyx_isInvBackpackTab and 0.15 or 0.88
				v.TextColor3 = Nyx_isInvBackpackTab and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText

				local UIStroke = v:FindFirstChildOfClass("UIStroke")

				if UIStroke then
					UIStroke.Transparency = Nyx_isInvBackpackTab and 0 or 1
				end
			end
		end
		local function Nyx_refreshInvSortUI()
			Nyx_applyElevatedIdentity()

			for k, v in pairs(Nyx_createTextButton_var3) do
				local Nyx_isInvMoneySort = k == Nyx_createTextButton_var2

				v.BackgroundColor3 = Nyx_isInvMoneySort and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
				v.BackgroundTransparency = Nyx_isInvMoneySort and 0.15 or 0.88
				v.TextColor3 = Nyx_isInvMoneySort and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText

				local UIStroke = v:FindFirstChildOfClass("UIStroke")

				if UIStroke then
					UIStroke.Transparency = Nyx_isInvMoneySort and 0 or 1
				end
			end
		end

		Nyx_refreshInventory = function()
			Nyx_applyElevatedIdentity()

			if not Nyx_createTextButton_var5 then
				return
			end

			for _, child in ipairs(Nyx_createTextButton_var5:GetChildren()) do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end

			local Nyx_saveDataForInv = (Save.Peek or Save.Get)() or {}
			local Nyx_inventoryRows = {}
			local Nyx_refreshInventory_var1 = 0

			local function Nyx_addInvRow(record)
				local AssetCategory = record.AssetCategory or record.Category
				local Directory2 = Assets.Directory and Assets.Directory[AssetCategory]
				local Nyx_invEggRank, Nyx_invEggRarity, Nyx_invEggColor = Nyx_resolveRarityInfo(AssetCategory)
				local Nyx_invEggRate = Nyx_computeAreaEggValue({
					AssetCategory = AssetCategory,
					AssetScale = record.Scale or record.AssetScale or 1,
					Mutations = record.Mutations or {}
				})
				local Nyx_invEggWeight = Nyx_computeEggWeight(record)

				Nyx_refreshInventory_var1 += Nyx_invEggRate
				table.insert(Nyx_inventoryRows, {
					name = Directory2 and Directory2.DisplayName or tostring(AssetCategory),
					icon = Nyx_findIconUrl(AssetCategory),
					kg = Nyx_invEggWeight,
					kgS = string.format("%.1fKg", Nyx_invEggWeight),
					moneys = Nyx_invEggRate,
					rnum = Nyx_invEggRank,
					rarity = Nyx_invEggRarity,
					color = Nyx_invEggColor
				})
			end

			if Nyx_createTextButton_var1 == "inplot" then
				local ipairs_ = ipairs
				local EquippedAssets = Nyx_saveDataForInv.EquippedAssets or {}

				for _, EquippedAsset in ipairs_(EquippedAssets) do
					local Inventory = Nyx_saveDataForInv.Inventory and Nyx_saveDataForInv.Inventory[EquippedAsset]

					if Inventory then
						Nyx_addInvRow(Inventory)
					end
				end
			else
				local pairs_2 = pairs
				local Inventory = Nyx_saveDataForInv.Inventory or {}

				for _, v in pairs_2(Inventory) do
					if type(v) == "table" and (v.AssetCategory or v.Category) then
						Nyx_addInvRow(v)
					end
				end
			end

			local Nyx_invSortKey = Nyx_createTextButton_var2 == "rarity" and "rnum" or Nyx_createTextButton_var2

			table.sort(Nyx_inventoryRows, function(entryA, entryB)
				if entryA[Nyx_invSortKey] == entryB[Nyx_invSortKey] then
					return entryA.name < entryB.name
				end

				if Nyx_createTextButton_var6 then
					return (entryA[Nyx_invSortKey] or 0) < (entryB[Nyx_invSortKey] or 0)
				end

				return (entryA[Nyx_invSortKey] or 0) > (entryB[Nyx_invSortKey] or 0)
			end)

			for i, v in ipairs(Nyx_inventoryRows) do
				local Frame = Instance.new("Frame")

				Frame.Size = UDim2.new(1, -6, 0, 34)
				Frame.BackgroundColor3 = Nyx_uiTheme.surface
				Frame.BackgroundTransparency = 0.12
				Frame.BorderSizePixel = 0
				Frame.LayoutOrder = i
				Frame.Parent = Nyx_createTextButton_var5
				Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

				local UIStroke = Instance.new("UIStroke", Frame)

				UIStroke.Color = Nyx_uiTheme.strokeCol
				UIStroke.Thickness = 1
				UIStroke.Transparency = 0.72

				local Frame2 = Instance.new("Frame")

				Frame2.Size = UDim2.new(0, 3, 1, -10)
				Frame2.Position = UDim2.fromOffset(0, 5)
				Frame2.BorderSizePixel = 0
				Frame2.BackgroundColor3 = v.color or Nyx_uiTheme.accent
				Frame2.Parent = Frame
				Instance.new("UICorner", Frame2).CornerRadius = UDim.new(1, 0)

				local ImageLabel = Instance.new("ImageLabel")

				ImageLabel.Position = UDim2.fromOffset(10, 5)
				ImageLabel.Size = UDim2.fromOffset(24, 24)
				ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageLabel.BackgroundTransparency = 1
				ImageLabel.BorderSizePixel = 0
				ImageLabel.ScaleType = Enum.ScaleType.Fit
				ImageLabel.Image = v.icon or ""
				ImageLabel.Parent = Frame
				Instance.new("UICorner", ImageLabel).CornerRadius = UDim.new(0, 4)

				if not v.icon then
					local Frame3 = Instance.new("Frame")

					Frame3.AnchorPoint = Vector2.new(0.5, 0.5)
					Frame3.Position = UDim2.fromScale(0.5, 0.5)
					Frame3.Size = UDim2.fromOffset(9, 9)
					Frame3.BackgroundColor3 = v.color or Nyx_uiTheme.accent
					Frame3.BorderSizePixel = 0
					Frame3.Parent = ImageLabel
					Instance.new("UICorner", Frame3).CornerRadius = UDim.new(1, 0)
				end

				local TextLabel5 = Instance.new("TextLabel")

				TextLabel5.BackgroundTransparency = 1
				TextLabel5.Position = UDim2.fromOffset(42, 0)
				TextLabel5.Size = UDim2.new(0.42, -42, 1, 0)
				TextLabel5.Font = Enum.Font.GothamBold
				TextLabel5.TextSize = 12
				TextLabel5.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel5.TextTruncate = Enum.TextTruncate.AtEnd
				TextLabel5.TextColor3 = Nyx_uiTheme.text
				TextLabel5.Text = tostring(v.name)
				TextLabel5.Parent = Frame

				local TextLabel6 = Instance.new("TextLabel")

				TextLabel6.BackgroundTransparency = 1
				TextLabel6.Position = UDim2.new(0.42, 0, 0, 0)
				TextLabel6.Size = UDim2.new(0.18, 0, 1, 0)
				TextLabel6.Font = Enum.Font.GothamBold
				TextLabel6.TextSize = 11
				TextLabel6.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel6.TextColor3 = v.color or Nyx_uiTheme.muted
				TextLabel6.Text = tostring(v.rarity)
				TextLabel6.Parent = Frame

				local TextLabel7 = Instance.new("TextLabel")

				TextLabel7.BackgroundTransparency = 1
				TextLabel7.Position = UDim2.new(0.6, 0, 0, 0)
				TextLabel7.Size = UDim2.new(0.18, 0, 1, 0)
				TextLabel7.Font = Enum.Font.GothamBold
				TextLabel7.TextSize = 11
				TextLabel7.TextXAlignment = Enum.TextXAlignment.Right
				TextLabel7.TextColor3 = Nyx_uiTheme.btnText
				TextLabel7.Text = tostring(v.kgS)
				TextLabel7.Parent = Frame

				local TextLabel8 = Instance.new("TextLabel")

				TextLabel8.BackgroundTransparency = 1
				TextLabel8.Position = UDim2.new(0.78, 0, 0, 0)
				TextLabel8.Size = UDim2.new(0.22, -12, 1, 0)
				TextLabel8.Font = Enum.Font.GothamBold
				TextLabel8.TextSize = 11
				TextLabel8.TextXAlignment = Enum.TextXAlignment.Right
				TextLabel8.TextColor3 = v.moneys > 0 and Nyx_uiTheme.text or Nyx_uiTheme.muted
				TextLabel8.Text = Nyx_formatCompactShort2(v.moneys) .. "/s"
				TextLabel8.Parent = Frame
			end

			Nyx_createTextButton_var5.CanvasSize = UDim2.new(0, 0, 0, #Nyx_inventoryRows * 38 + 6)

			if TextLabel4 then
				if Nyx_createTextButton_var1 == "inplot" then
					TextLabel4.Text = string.format("%d equipped | %s/s", #Nyx_inventoryRows, Nyx_formatCompactShort2(Nyx_refreshInventory_var1))
				else
					TextLabel4.Text = string.format("%d pets", #Nyx_inventoryRows)
				end
			end
		end

		local function Nyx_buildInventoryPanel(parentFrame)
			TextLabel4 = Instance.new("TextLabel")
			TextLabel4.BackgroundTransparency = 1
			TextLabel4.Position = UDim2.new(1, -190, 0, 4)
			TextLabel4.Size = UDim2.fromOffset(180, 22)
			TextLabel4.Font = Enum.Font.GothamBold
			TextLabel4.TextSize = 12
			TextLabel4.TextXAlignment = Enum.TextXAlignment.Right
			TextLabel4.TextColor3 = Nyx_uiTheme.muted
			TextLabel4.Text = "0 pets"
			TextLabel4.Parent = parentFrame

			local Frame = Instance.new("Frame")

			Frame.Position = UDim2.fromOffset(14, 4)
			Frame.Size = UDim2.new(0, 180, 0, 28)
			Frame.BackgroundTransparency = 1
			Frame.Parent = parentFrame

			local UIListLayout = Instance.new("UIListLayout", Frame)

			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout.Padding = UDim.new(0, 6)
			UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			Nyx_createTextButton_var4 = {}

			local function Nyx_createInvTabButton(label, tabKey, width)
				local TextButton = Instance.new("TextButton")

				TextButton.Size = UDim2.fromOffset(width, 26)
				TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.BackgroundTransparency = 0.88
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.GothamBold
				TextButton.TextSize = 12
				TextButton.TextColor3 = Nyx_uiTheme.btnText
				TextButton.Text = label
				TextButton.Parent = Frame
				Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)

				local UIStroke = Instance.new("UIStroke", TextButton)

				UIStroke.Color = Nyx_uiTheme.accent
				UIStroke.Thickness = 1
				UIStroke.Transparency = 1
				TextButton.MouseButton1Click:Connect(function()
					Nyx_createTextButton_var1 = tabKey
					Nyx_refreshInvTabUI()
					Nyx_refreshInventory()
				end)
				Nyx_createTextButton_var4[tabKey] = TextButton
			end

			Nyx_createInvTabButton("Backpack", "backpack", 78)
			Nyx_createInvTabButton("Base", "inplot", 54)

			local Frame2 = Instance.new("Frame")

			Frame2.Position = UDim2.fromOffset(14, 36)
			Frame2.Size = UDim2.new(1, -28, 0, 28)
			Frame2.BackgroundTransparency = 1
			Frame2.Parent = parentFrame

			local UIListLayout2 = Instance.new("UIListLayout", Frame2)

			UIListLayout2.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout2.Padding = UDim.new(0, 6)
			UIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
			Nyx_createTextButton_var3 = {}

			local function Nyx_createInvSortButton(label, sortKey, width)
				local TextButton = Instance.new("TextButton")

				TextButton.Size = UDim2.fromOffset(width, 26)
				TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.BackgroundTransparency = 0.88
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.GothamBold
				TextButton.TextSize = 12
				TextButton.TextColor3 = Nyx_uiTheme.btnText
				TextButton.Text = label
				TextButton.Parent = Frame2
				Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)

				local UIStroke = Instance.new("UIStroke", TextButton)

				UIStroke.Color = Nyx_uiTheme.accent
				UIStroke.Thickness = 1
				UIStroke.Transparency = 1
				TextButton.MouseButton1Click:Connect(function()
					if Nyx_createTextButton_var2 == sortKey then
						Nyx_createTextButton_var6 = not Nyx_createTextButton_var6
					else
						Nyx_createTextButton_var2 = sortKey
						Nyx_createTextButton_var6 = false
					end

					Nyx_refreshInvSortUI()
					Nyx_refreshInventory()
				end)
				Nyx_createTextButton_var3[sortKey] = TextButton
			end

			Nyx_createInvSortButton("Money/s", "moneys", 86)
			Nyx_createInvSortButton("Kg", "kg", 56)
			Nyx_createInvSortButton("Rarity", "rarity", 76)
			Nyx_createInvSortButton("Name", "name", 66)

			local Frame3 = Instance.new("Frame")

			Frame3.Position = UDim2.fromOffset(16, 66)
			Frame3.Size = UDim2.new(1, -32, 0, 18)
			Frame3.BackgroundTransparency = 1
			Frame3.Parent = parentFrame

			local function Nyx_createInvHeaderLabel(label, position, size, alignment)
				local TextLabel5 = Instance.new("TextLabel")

				TextLabel5.BackgroundTransparency = 1
				TextLabel5.Position = position
				TextLabel5.Size = size
				TextLabel5.Font = Enum.Font.GothamBold
				TextLabel5.TextSize = 11
				TextLabel5.TextColor3 = Nyx_uiTheme.muted
				TextLabel5.TextXAlignment = alignment
				TextLabel5.Text = label
				TextLabel5.Parent = Frame3
			end

			Nyx_createInvHeaderLabel("PET", UDim2.fromOffset(26, 0), UDim2.new(0.42, -26, 1, 0), Enum.TextXAlignment.Left)
			Nyx_createInvHeaderLabel("RARITY", UDim2.new(0.42, 0, 0, 0), UDim2.new(0.18, 0, 1, 0), Enum.TextXAlignment.Left)
			Nyx_createInvHeaderLabel("KG", UDim2.new(0.6, 0, 0, 0), UDim2.new(0.18, 0, 1, 0), Enum.TextXAlignment.Right)
			Nyx_createInvHeaderLabel("MONEY/S", UDim2.new(0.78, 0, 0, 0), UDim2.new(0.22, -12, 1, 0), Enum.TextXAlignment.Right)

			local ScrollingFrame = Instance.new("ScrollingFrame")

			ScrollingFrame.Position = UDim2.fromOffset(14, 88)
			ScrollingFrame.Size = UDim2.new(1, -28, 1, -96)
			ScrollingFrame.BackgroundTransparency = 1
			ScrollingFrame.BorderSizePixel = 0
			ScrollingFrame.ScrollBarThickness = 3
			ScrollingFrame.ScrollBarImageColor3 = Nyx_uiTheme.accent
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame.Parent = parentFrame

			local UIListLayout3 = Instance.new("UIListLayout", ScrollingFrame)

			UIListLayout3.Padding = UDim.new(0, 4)
			UIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
			Nyx_createTextButton_var5 = ScrollingFrame
			Nyx_refreshInvTabUI()
			Nyx_refreshInvSortUI()
			Nyx_refreshInventory()
		end

		Nyx_EggCheckerUI.sort = "value"
		Nyx_EggCheckerUI.rarity = "All"
		Nyx_EggCheckerUI.picked = {}
		Nyx_EggCheckerUI.chips = {}
		Nyx_EggCheckerUI.sortBtns = {}
		Nyx_EggCheckerUI.modeBtns = {}
		Nyx_EggCheckerUI.rows = {}
		Nyx_EggCheckerUI.scan = function()
			local Nyx_createInvHeaderLabel_var5

			pcall(function()
				Nyx_createInvHeaderLabel_var5 = EggState2.ReadFieldEggs()
			end)

			local Nyx_checkerRows = {}
			local ipairs_ = ipairs
			local Records = Nyx_createInvHeaderLabel_var5 and Nyx_createInvHeaderLabel_var5.Records or {}

			for _, Record in ipairs_(Records) do
				if Record.State ~= "Claimed" and Record.State ~= "Carried" and not Record.CarrierUserId and Record.BottomCFrame then
					if not tostring(Record.Uid):find("FirstAreaEgg") then
						local AssetCategory = Record.AssetCategory
						local Directory2 = AssetCategory and Assets.Directory and Assets.Directory[AssetCategory]
						local Nyx_checkerEggRank, Nyx_checkerEggRarity, Nyx_checkerEggColor = Nyx_resolveRarityInfo(AssetCategory)
						local Nyx_checkerEggRate = Nyx_computeAreaEggValue({
							AssetCategory = AssetCategory,
							Category = AssetCategory,
							AssetScale = Record.AssetScale or Record.Scale or 1,
							Scale = Record.AssetScale or Record.Scale or 1,
							Mutations = Record.Mutations or {}
						})
						local Nyx_checkerEggWeight = Nyx_computeEggWeight(Record)
						local Nyx_checkerRowIndex = #Nyx_checkerRows + 1
						local Nyx_checkerRow = {
							rec = Record,
							uid = Record.Uid
						}
						local DisplayName = Directory2 and Directory2.DisplayName

						if not DisplayName then
							DisplayName = tostring(AssetCategory or "Egg")
						end

						Nyx_checkerRow.name = DisplayName
						Nyx_checkerRow.rarity = Nyx_checkerEggRarity
						Nyx_checkerRow.rnum = Nyx_checkerEggRank
						Nyx_checkerRow.color = Nyx_checkerEggColor
						Nyx_checkerRow.area = tostring(Record.AreaId or "?")
						Nyx_checkerRow.rate = Nyx_checkerEggRate
						Nyx_checkerRow.kg = Nyx_checkerEggWeight
						Nyx_checkerRow.icon = Nyx_findIconUrl(AssetCategory)
						Nyx_checkerRows[Nyx_checkerRowIndex] = Nyx_checkerRow
					end
				end
			end

			if Nyx_EggCheckerUI.rarity ~= "All" then
				local Nyx_createInvHeaderLabel_var3 = {}

				for _, v in ipairs(Nyx_checkerRows) do
					if v.rarity == Nyx_EggCheckerUI.rarity then
						Nyx_createInvHeaderLabel_var3[#Nyx_createInvHeaderLabel_var3 + 1] = v
					end
				end

				Nyx_checkerRows = Nyx_createInvHeaderLabel_var3
			end

			table.sort(Nyx_checkerRows, function(entryA, entryB)
				if Nyx_EggCheckerUI.sort == "rarity" then
					if entryA.rnum == entryB.rnum then
						return (entryA.rate or 0) > (entryB.rate or 0)
					end

					return (entryA.rnum or 0) > (entryB.rnum or 0)
				end

				if entryA.rate == entryB.rate then
					return (entryA.rnum or 0) > (entryB.rnum or 0)
				end

				return (entryA.rate or 0) > (entryB.rate or 0)
			end)

			return Nyx_checkerRows
		end
		Nyx_EggCheckerUI.paintChips = function()
			for k, chip in pairs(Nyx_EggCheckerUI.chips) do
				local Nyx_isRarityChipActive = k == Nyx_EggCheckerUI.rarity

				chip.BackgroundTransparency = Nyx_isRarityChipActive and 0.1 or 0.9
				chip.TextColor3 = Nyx_isRarityChipActive and Color3.fromRGB(255, 255, 255) or chip:GetAttribute("chipColor") and Color3.fromHex(chip:GetAttribute("chipColor")) or Nyx_uiTheme.btnText

				local UIStroke = chip:FindFirstChildOfClass("UIStroke")

				if UIStroke then
					UIStroke.Transparency = Nyx_isRarityChipActive and 0 or 0.65
				end
			end

			for k, sortBtn in pairs(Nyx_EggCheckerUI.sortBtns) do
				local Nyx_isSortChipActive = k == Nyx_EggCheckerUI.sort

				sortBtn.BackgroundColor3 = Nyx_isSortChipActive and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
				sortBtn.BackgroundTransparency = Nyx_isSortChipActive and 0.12 or 0.9
				sortBtn.TextColor3 = Nyx_isSortChipActive and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText
			end

			local __NyxStealMode = genv.__NyxStealMode or "Fly"
			local pairs_2 = pairs
			local modeBtns = Nyx_EggCheckerUI.modeBtns or {}

			for k, modeBtn in pairs_2(modeBtns) do
				local Nyx_isModeChipActive = __NyxStealMode == k

				modeBtn.BackgroundColor3 = Nyx_isModeChipActive and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
				modeBtn.BackgroundTransparency = Nyx_isModeChipActive and 0.12 or 0.9
				modeBtn.TextColor3 = Nyx_isModeChipActive and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText

				local UIStroke = modeBtn:FindFirstChildOfClass("UIStroke")

				if UIStroke then
					UIStroke.Transparency = Nyx_isModeChipActive and 0 or 0.7
				end
			end
		end
		Nyx_EggCheckerUI.paintRows = function()
			local Nyx_createInvHeaderLabel_var1 = 0

			for _, row in ipairs(Nyx_EggCheckerUI.rows) do
				local Nyx_isRowPicked = Nyx_EggCheckerUI.picked[tostring(row.uid)] == true

				if Nyx_isRowPicked then
					Nyx_createInvHeaderLabel_var1 += 1
				end

				row.frame.BackgroundTransparency = Nyx_isRowPicked and 0.02 or 0.14

				local UIStroke = row.frame:FindFirstChildOfClass("UIStroke")

				if UIStroke then
					UIStroke.Transparency = Nyx_isRowPicked and 0 or 0.78
				end

				if row.tick then
					row.tick.BackgroundTransparency = Nyx_isRowPicked and 0.05 or 0.86
					row.tick.Text = Nyx_isRowPicked and "OK" or ""
				end
			end

			if Nyx_EggCheckerUI.statusBtn and not Nyx_EggCheckerUI.running then
				Nyx_EggCheckerUI.statusBtn.Text = Nyx_createInvHeaderLabel_var1 > 0 and "Steal Selected (" .. Nyx_createInvHeaderLabel_var1 .. ")" or "Steal Selected"
			end

			if Nyx_EggCheckerUI.headLbl then
				Nyx_EggCheckerUI.headLbl.Text = Nyx_createInvHeaderLabel_var1 > 0 and Nyx_createInvHeaderLabel_var1 .. " picked" or "Tap eggs to pick them"
			end
		end
		Nyx_EggCheckerUI.refresh = function()
			Nyx_applyElevatedIdentity()

			if not Nyx_EggCheckerUI.list then
				return
			end

			for _, child in ipairs(Nyx_EggCheckerUI.list:GetChildren()) do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end

			Nyx_EggCheckerUI.rows = {}

			local Nyx_checkerEggList = Nyx_EggCheckerUI.scan()
			local Nyx_createInvHeaderLabel_var4 = {}

			for _, v in ipairs(Nyx_checkerEggList) do
				Nyx_createInvHeaderLabel_var4[tostring(v.uid)] = true
			end

			for k in pairs(Nyx_EggCheckerUI.picked) do
				if not Nyx_createInvHeaderLabel_var4[k] then
					Nyx_EggCheckerUI.picked[k] = nil
				end
			end

			for i, v in ipairs(Nyx_checkerEggList) do
				local Frame = Instance.new("Frame")

				Frame.Size = UDim2.new(1, -6, 0, 46)
				Frame.BackgroundColor3 = Nyx_uiTheme.surface
				Frame.BackgroundTransparency = 0.14
				Frame.BorderSizePixel = 0
				Frame.LayoutOrder = i
				Frame.Parent = Nyx_EggCheckerUI.list
				Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)

				local UIStroke = Instance.new("UIStroke", Frame)

				UIStroke.Color = v.color or Nyx_uiTheme.accent
				UIStroke.Thickness = 1
				UIStroke.Transparency = 0.78

				local Frame2 = Instance.new("Frame")

				Frame2.Size = UDim2.new(0, 3, 1, -12)
				Frame2.Position = UDim2.fromOffset(0, 6)
				Frame2.BorderSizePixel = 0
				Frame2.BackgroundColor3 = v.color or Nyx_uiTheme.accent
				Frame2.Parent = Frame
				Instance.new("UICorner", Frame2).CornerRadius = UDim.new(1, 0)

				local TextLabel5 = Instance.new("TextLabel")

				TextLabel5.Position = UDim2.fromOffset(10, 11)
				TextLabel5.Size = UDim2.fromOffset(24, 24)
				TextLabel5.BackgroundColor3 = Nyx_uiTheme.accent
				TextLabel5.BackgroundTransparency = 0.86
				TextLabel5.Font = Enum.Font.GothamBold
				TextLabel5.TextSize = 11
				TextLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextLabel5.Text = ""
				TextLabel5.Parent = Frame
				Instance.new("UICorner", TextLabel5).CornerRadius = UDim.new(0, 5)

				local UIStroke2 = Instance.new("UIStroke", TextLabel5)

				UIStroke2.Color = Nyx_uiTheme.accent
				UIStroke2.Thickness = 1
				UIStroke2.Transparency = 0.6

				local ImageLabel = Instance.new("ImageLabel")

				ImageLabel.Position = UDim2.fromOffset(42, 7)
				ImageLabel.Size = UDim2.fromOffset(30, 30)
				ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageLabel.BackgroundTransparency = 1
				ImageLabel.BorderSizePixel = 0
				ImageLabel.ScaleType = Enum.ScaleType.Fit
				ImageLabel.Image = v.icon or ""
				ImageLabel.Parent = Frame
				Instance.new("UICorner", ImageLabel).CornerRadius = UDim.new(0, 4)

				if not v.icon then
					local Frame3 = Instance.new("Frame")

					Frame3.AnchorPoint = Vector2.new(0.5, 0.5)
					Frame3.Position = UDim2.fromScale(0.5, 0.5)
					Frame3.Size = UDim2.fromOffset(10, 10)
					Frame3.BackgroundColor3 = v.color or Nyx_uiTheme.accent
					Frame3.BorderSizePixel = 0
					Frame3.Parent = ImageLabel
					Instance.new("UICorner", Frame3).CornerRadius = UDim.new(1, 0)
				end

				local TextLabel6 = Instance.new("TextLabel")

				TextLabel6.BackgroundTransparency = 1
				TextLabel6.Position = UDim2.fromOffset(78, 6)
				TextLabel6.Size = UDim2.new(1, -184, 0, 17)
				TextLabel6.Font = Enum.Font.GothamBold
				TextLabel6.TextSize = 13
				TextLabel6.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel6.TextTruncate = Enum.TextTruncate.AtEnd
				TextLabel6.TextColor3 = Nyx_uiTheme.text
				TextLabel6.Text = tostring(v.name)
				TextLabel6.Parent = Frame

				local TextLabel7 = Instance.new("TextLabel")

				TextLabel7.BackgroundTransparency = 1
				TextLabel7.Position = UDim2.fromOffset(78, 24)
				TextLabel7.Size = UDim2.new(1, -184, 0, 17)
				TextLabel7.Font = Enum.Font.GothamBold
				TextLabel7.TextSize = 11
				TextLabel7.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel7.TextTruncate = Enum.TextTruncate.AtEnd
				TextLabel7.TextColor3 = v.color or Nyx_uiTheme.muted
				TextLabel7.Text = string.format("%s  -  %s%s", tostring(v.rarity or "?"), tostring(v.area), v.kg and string.format("  -  %.1fkg", v.kg) or "")
				TextLabel7.Parent = Frame

				local TextLabel8 = Instance.new("TextLabel")

				TextLabel8.BackgroundTransparency = 1
				TextLabel8.AnchorPoint = Vector2.new(1, 0.5)
				TextLabel8.Position = UDim2.new(1, -12, 0.5, 0)
				TextLabel8.Size = UDim2.fromOffset(96, 20)
				TextLabel8.Font = Enum.Font.GothamBold
				TextLabel8.TextSize = 13
				TextLabel8.TextXAlignment = Enum.TextXAlignment.Right
				TextLabel8.TextColor3 = Color3.fromRGB(126, 224, 151)
				TextLabel8.Text = Nyx_formatCompactShort(v.rate) .. "/s"
				TextLabel8.Parent = Frame

				local TextButton = Instance.new("TextButton")

				TextButton.Size = UDim2.fromScale(1, 1)
				TextButton.BackgroundTransparency = 1
				TextButton.Text = ""
				TextButton.AutoButtonColor = false
				TextButton.Parent = Frame

				local Nyx_pickedEggUid = tostring(v.uid)

				TextButton.MouseButton1Click:Connect(function()
					Nyx_EggCheckerUI.picked[Nyx_pickedEggUid] = not Nyx_EggCheckerUI.picked[Nyx_pickedEggUid] or nil
					Nyx_EggCheckerUI.paintRows()
				end)
				Nyx_EggCheckerUI.rows[#Nyx_EggCheckerUI.rows + 1] = {
					uid = v.uid,
					frame = Frame,
					tick = TextLabel5
				}
			end

			if Nyx_EggCheckerUI.countLbl then
				pcall(function()
					Nyx_EggCheckerUI.countLbl.Text = #Nyx_checkerEggList .. " eggs"
				end)
			end

			pcall(function()
				Nyx_EggCheckerUI.list.CanvasSize = UDim2.new(0, 0, 0, #Nyx_checkerEggList * 50 + 8)
			end)
			pcall(Nyx_EggCheckerUI.paintChips)
			pcall(Nyx_EggCheckerUI.paintRows)
		end
		Nyx_EggCheckerUI.build = function(parentFrame)
			local Frame = Instance.new("Frame")

			Frame.Size = UDim2.fromScale(1, 1)
			Frame.BackgroundTransparency = 1
			Frame.BorderSizePixel = 0
			Frame.Parent = parentFrame
			Nyx_EggCheckerUI.countLbl = Instance.new("TextLabel")
			Nyx_EggCheckerUI.countLbl.BackgroundTransparency = 1
			Nyx_EggCheckerUI.countLbl.AnchorPoint = Vector2.new(1, 0)
			Nyx_EggCheckerUI.countLbl.Position = UDim2.new(1, -16, 0, 2)
			Nyx_EggCheckerUI.countLbl.Size = UDim2.fromOffset(110, 18)
			Nyx_EggCheckerUI.countLbl.Font = Enum.Font.GothamBold
			Nyx_EggCheckerUI.countLbl.TextSize = 12
			Nyx_EggCheckerUI.countLbl.TextXAlignment = Enum.TextXAlignment.Right
			Nyx_EggCheckerUI.countLbl.TextColor3 = Nyx_uiTheme.muted
			Nyx_EggCheckerUI.countLbl.Text = "0 eggs"
			Nyx_EggCheckerUI.countLbl.Parent = Frame
			Nyx_EggCheckerUI.headLbl = Instance.new("TextLabel")
			Nyx_EggCheckerUI.headLbl.BackgroundTransparency = 1
			Nyx_EggCheckerUI.headLbl.Position = UDim2.fromOffset(14, 2)
			Nyx_EggCheckerUI.headLbl.Size = UDim2.new(1, -135, 0, 18)
			Nyx_EggCheckerUI.headLbl.Font = Enum.Font.GothamBold
			Nyx_EggCheckerUI.headLbl.TextSize = 12
			Nyx_EggCheckerUI.headLbl.TextXAlignment = Enum.TextXAlignment.Left
			Nyx_EggCheckerUI.headLbl.TextTruncate = Enum.TextTruncate.AtEnd
			Nyx_EggCheckerUI.headLbl.TextColor3 = Nyx_uiTheme.muted
			Nyx_EggCheckerUI.headLbl.Text = "Tap eggs to pick them"
			Nyx_EggCheckerUI.headLbl.Parent = Frame

			local ScrollingFrame = Instance.new("ScrollingFrame")

			ScrollingFrame.Position = UDim2.fromOffset(14, 24)
			ScrollingFrame.Size = UDim2.new(1, -28, 0, 36)
			ScrollingFrame.BackgroundTransparency = 1
			ScrollingFrame.BorderSizePixel = 0
			ScrollingFrame.ScrollBarThickness = 3
			ScrollingFrame.ScrollBarImageColor3 = Nyx_uiTheme.accent
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame.Parent = Frame

			local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)

			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout.Padding = UDim.new(0, 6)
			UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local Nyx_createInvHeaderLabel_var2 = 0

			Nyx_EggCheckerUI.chips = {}

			local function Nyx_createRarityChip(label, color)
				local TextButton = Instance.new("TextButton")
				local Nyx_rarityChipWidth = math.max(48, #label * 7 + 16)

				TextButton.Size = UDim2.fromOffset(Nyx_rarityChipWidth, 24)
				TextButton.BackgroundColor3 = color or Nyx_uiTheme.accent
				TextButton.BackgroundTransparency = 0.9
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.GothamBold
				TextButton.TextSize = 12
				TextButton.TextColor3 = color or Nyx_uiTheme.btnText
				TextButton.Text = label

				if color then
					TextButton:SetAttribute("chipColor", color:ToHex())
				end

				local UIStroke = Instance.new("UIStroke", TextButton)

				UIStroke.Color = color or Nyx_uiTheme.accent
				UIStroke.Thickness = 1
				UIStroke.Transparency = 0.65
				TextButton.Parent = ScrollingFrame
				Instance.new("UICorner", TextButton).CornerRadius = UDim.new(1, 0)
				TextButton.MouseButton1Click:Connect(function()
					Nyx_EggCheckerUI.rarity = label
					Nyx_EggCheckerUI.paintChips()
					Nyx_EggCheckerUI.refresh()
				end)
				Nyx_EggCheckerUI.chips[label] = TextButton
				Nyx_createInvHeaderLabel_var2 = Nyx_createInvHeaderLabel_var2 + Nyx_rarityChipWidth + 6
			end

			Nyx_createRarityChip("All", nil)

			for _, v in ipairs(Nyx_getRarityOptionsNoAny()) do
				local Nyx_chipRarityColor

				for _, Nyx_item in ipairs(Nyx_rarityListAll) do
					if Nyx_item.rname == v then
						local _, _, Nyx_chipColorResolved = Nyx_resolveRarityInfo(Nyx_item.cat)

						Nyx_chipRarityColor = Nyx_chipColorResolved

						break
					end
				end

				Nyx_createRarityChip(v, Nyx_chipRarityColor)
			end

			ScrollingFrame.CanvasSize = UDim2.new(0, Nyx_createInvHeaderLabel_var2 + 6, 0, 0)

			local Frame2 = Instance.new("Frame")

			Frame2.Position = UDim2.fromOffset(14, 66)
			Frame2.Size = UDim2.new(1, -28, 0, 26)
			Frame2.BackgroundTransparency = 1
			Frame2.Parent = Frame

			local UIListLayout2 = Instance.new("UIListLayout", Frame2)

			UIListLayout2.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout2.Padding = UDim.new(0, 6)
			UIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
			Nyx_EggCheckerUI.sortBtns = {}

			local function Nyx_createSortButton(sortKey, label)
				local TextButton = Instance.new("TextButton")

				TextButton.Size = UDim2.fromOffset(96, 24)
				TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.BackgroundTransparency = 0.9
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.GothamBold
				TextButton.TextSize = 12
				TextButton.TextColor3 = Nyx_uiTheme.btnText
				TextButton.Text = label
				TextButton.Parent = Frame2
				Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 5)
				TextButton.MouseButton1Click:Connect(function()
					Nyx_EggCheckerUI.sort = sortKey
					Nyx_EggCheckerUI.paintChips()
					Nyx_EggCheckerUI.refresh()
				end)
				Nyx_EggCheckerUI.sortBtns[sortKey] = TextButton
			end

			Nyx_createSortButton("value", "Best Value")
			Nyx_createSortButton("rarity", "Rarity")

			local TextButton = Instance.new("TextButton")

			TextButton.Size = UDim2.fromOffset(76, 24)
			TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextButton.BackgroundTransparency = 0.9
			TextButton.AutoButtonColor = false
			TextButton.Font = Enum.Font.GothamBold
			TextButton.TextSize = 12
			TextButton.TextColor3 = Nyx_uiTheme.btnText
			TextButton.Text = "Clear"
			TextButton.Parent = Frame2
			Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 5)
			TextButton.MouseButton1Click:Connect(function()
				Nyx_EggCheckerUI.picked = {}
				Nyx_EggCheckerUI.paintRows()
			end)

			local Frame3 = Instance.new("Frame")

			Frame3.Position = UDim2.fromOffset(14, 96)
			Frame3.Size = UDim2.new(1, -28, 0, 26)
			Frame3.BackgroundTransparency = 1
			Frame3.Parent = Frame

			local UIListLayout3 = Instance.new("UIListLayout", Frame3)

			UIListLayout3.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout3.Padding = UDim.new(0, 4)
			UIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center

			local TextLabel5 = Instance.new("TextLabel")

			TextLabel5.Size = UDim2.fromOffset(38, 24)
			TextLabel5.BackgroundTransparency = 1
			TextLabel5.Font = Enum.Font.GothamBold
			TextLabel5.TextSize = 11
			TextLabel5.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel5.TextColor3 = Nyx_uiTheme.muted
			TextLabel5.Text = "MOVE"
			TextLabel5.Parent = Frame3
			Nyx_EggCheckerUI.modeBtns = {}

			local function Nyx_createModeButton(label, mode)
				local TextButton2 = Instance.new("TextButton")

				TextButton2.Size = UDim2.fromOffset(68, 24)
				TextButton2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextButton2.BackgroundTransparency = 0.9
				TextButton2.AutoButtonColor = false
				TextButton2.Font = Enum.Font.GothamBold
				TextButton2.TextSize = 12
				TextButton2.TextColor3 = Nyx_uiTheme.btnText
				TextButton2.Text = label
				TextButton2.Parent = Frame3
				Instance.new("UICorner", TextButton2).CornerRadius = UDim.new(0, 5)

				local UIStroke = Instance.new("UIStroke", TextButton2)

				UIStroke.Color = Nyx_uiTheme.accent
				UIStroke.Thickness = 1
				UIStroke.Transparency = 0.7
				TextButton2.MouseButton1Click:Connect(function()
					Nyx_applyElevatedIdentity()
					genv.__NyxStealMode = mode
					pcall(function()
						if type(applyStealMode) == "function" then
							applyStealMode(mode)
						end
					end)
					Nyx_EggCheckerUI.paintChips()
				end)
				Nyx_EggCheckerUI.modeBtns[mode] = TextButton2
			end

			Nyx_createModeButton("Low Speed User", "Instant")
			Nyx_createModeButton("High Speed User", "Fly")

			local ScrollingFrame2 = Instance.new("ScrollingFrame")

			ScrollingFrame2.Position = UDim2.fromOffset(14, 128)
			ScrollingFrame2.Size = UDim2.new(1, -28, 1, -188)
			ScrollingFrame2.BackgroundTransparency = 1
			ScrollingFrame2.BorderSizePixel = 0
			ScrollingFrame2.ScrollBarThickness = 3
			ScrollingFrame2.ScrollBarImageColor3 = Nyx_uiTheme.accent
			ScrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame2.Parent = Frame

			local UIListLayout4 = Instance.new("UIListLayout", ScrollingFrame2)

			UIListLayout4.Padding = UDim.new(0, 4)
			UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
			Nyx_EggCheckerUI.list = ScrollingFrame2

			local Frame4 = Instance.new("Frame")

			Frame4.Position = UDim2.new(0, 14, 1, -52)
			Frame4.Size = UDim2.new(1, -28, 0, 38)
			Frame4.BackgroundTransparency = 1
			Frame4.Parent = Frame

			local TextButton2 = Instance.new("TextButton")

			TextButton2.Size = UDim2.new(0.3, -4, 1, 0)
			TextButton2.BackgroundColor3 = Color3.fromRGB(90, 100, 140)
			TextButton2.BackgroundTransparency = 0.15
			TextButton2.AutoButtonColor = false
			TextButton2.Font = Enum.Font.GothamBold
			TextButton2.TextSize = 13
			TextButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextButton2.Text = "Refresh"
			TextButton2.Parent = Frame4
			Instance.new("UICorner", TextButton2).CornerRadius = UDim.new(0, 6)
			TextButton2.MouseButton1Click:Connect(function()
				pcall(function()
					EggState2.SyncFieldEggs()
				end)
				Nyx_EggCheckerUI.refresh()
			end)
			Nyx_EggCheckerUI.statusBtn = Instance.new("TextButton")
			Nyx_EggCheckerUI.statusBtn.AnchorPoint = Vector2.new(1, 0)
			Nyx_EggCheckerUI.statusBtn.Position = UDim2.fromScale(1, 0)
			Nyx_EggCheckerUI.statusBtn.Size = UDim2.new(0.69, -4, 1, 0)
			Nyx_EggCheckerUI.statusBtn.BackgroundColor3 = Nyx_uiTheme.accent
			Nyx_EggCheckerUI.statusBtn.BackgroundTransparency = 0.12
			Nyx_EggCheckerUI.statusBtn.AutoButtonColor = false
			Nyx_EggCheckerUI.statusBtn.Font = Enum.Font.GothamBold
			Nyx_EggCheckerUI.statusBtn.TextSize = 13
			Nyx_EggCheckerUI.statusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			Nyx_EggCheckerUI.statusBtn.Text = "Steal Selected"
			Nyx_EggCheckerUI.statusBtn.Parent = Frame4
			Instance.new("UICorner", Nyx_EggCheckerUI.statusBtn).CornerRadius = UDim.new(0, 6)
			Nyx_EggCheckerUI.statusBtn.MouseButton1Click:Connect(function()
				if Nyx_EggCheckerUI.running then
					return
				end

				local Nyx_createModeButton_var1 = {}

				for k in pairs(Nyx_EggCheckerUI.picked) do
					table.insert(Nyx_createModeButton_var1, k)
				end

				if #Nyx_createModeButton_var1 == 0 then
					Nyx_EggCheckerUI.statusBtn.Text = "Pick an egg first"
					task.delay(1.5, function()
						if Nyx_EggCheckerUI.statusBtn and not Nyx_EggCheckerUI.running then
							Nyx_EggCheckerUI.paintRows()
						end
					end)

					return
				end

				local __NyxEggRuntime = genv.__NyxEggRuntime

				if __NyxEggRuntime and type(__NyxEggRuntime.queueManual) == "function" then
					local Nyx_queuedCount = __NyxEggRuntime:queueManual(Nyx_createModeButton_var1)

					Nyx_EggCheckerUI.picked = {}
					Nyx_EggCheckerUI.statusBtn.Text = "Queued " .. Nyx_queuedCount
					task.delay(1.5, function()
						if Nyx_EggCheckerUI.statusBtn and not Nyx_EggCheckerUI.running then
							Nyx_EggCheckerUI.paintRows()
						end
					end)
					Nyx_EggCheckerUI.refresh()
				else
					Nyx_EggCheckerUI.statusBtn.Text = "Runtime not ready"
					task.delay(1.5, function()
						if Nyx_EggCheckerUI.statusBtn and not Nyx_EggCheckerUI.running then
							Nyx_EggCheckerUI.paintRows()
						end
					end)
				end
			end)
			Nyx_EggCheckerUI.paintChips()
			Nyx_EggCheckerUI.refresh()
		end

		local function Nyx_normalizePetNameKey(petName)
			if not petName or type(petName) ~= "string" then
				return "unknown"
			end

			local Nyx_normalizePetKey = petName:lower()

			if Nyx_normalizePetKey:find("kong") or Nyx_normalizePetKey:find("gorilla") then
				return "gorillaking"
			end

			if Nyx_normalizePetKey:find("phoenix") then
				return "phoenix"
			end

			if Nyx_normalizePetKey:find("lunar") or Nyx_normalizePetKey:find("dragon.-lunar") then
				return "lunardragon"
			end

			if Nyx_normalizePetKey:find("mosa") then
				return "mosasaurus"
			end

			if Nyx_normalizePetKey:find("tiger") or Nyx_normalizePetKey:find("oni") then
				return "onitiger"
			end

			if Nyx_normalizePetKey:find("kitsune") then
				return "kitsune"
			end

			if Nyx_normalizePetKey:find("unicorn") then
				return "unicorn"
			end

			if Nyx_normalizePetKey:find("godzilla") then
				return "godzilla"
			end

			if Nyx_normalizePetKey:find("pegasus") then
				return "pegasus"
			end

			if Nyx_normalizePetKey:find("archangel") then
				return "archangel"
			end

			if Nyx_normalizePetKey:find("ice.-dragon") then
				return "icedragon"
			end

			if Nyx_normalizePetKey:find("lava.-dragon") or Nyx_normalizePetKey:find("dragon") then
				return "lavadragon"
			end

			if Nyx_normalizePetKey:find("cosmic.-dragon") or Nyx_normalizePetKey:find("ember") then
				return "cosmicdragon"
			end

			if Nyx_normalizePetKey:find("trex") or Nyx_normalizePetKey:find("tyranno") or Nyx_normalizePetKey:find("t%-rex") then
				return "trex"
			end

			if Nyx_normalizePetKey:find("gargoyle") then
				return "gargoyle"
			end

			if Nyx_normalizePetKey:find("cerberus") then
				return "cerberus"
			end

			if Nyx_normalizePetKey:find("yeti") then
				return "yeti"
			end

			if Nyx_normalizePetKey:find("dreadscale") then
				return "dreadscale"
			end

			if Nyx_normalizePetKey:find("el.-maja") then
				return "elmaja"
			end

			return (Nyx_normalizePetKey:gsub("eternal", ""):gsub("ascended", ""):gsub("vermilion", ""):gsub("divine", ""):gsub("secret", ""):gsub("egg", ""):gsub("[^%a%d]", ""))
		end
		local function Nyx_roundToCycle(cycleSeconds)
			if not cycleSeconds or cycleSeconds <= 0 then
				return 0
			end

			return math.floor((cycleSeconds + 150) / 300) * 300
		end
		local function Nyx_formatTimestamp(timestamp, showSeconds)
			if not timestamp or timestamp <= 0 then
				return "--:--"
			end

			local now = os.time()
			local Nyx_nowTimeTable = os.date("*t", now)
			local Nyx_targetTimeTable = os.date("*t", timestamp)
			local Nyx_formatTimestamp_var1

			if Nyx_targetTimeTable.year == Nyx_nowTimeTable.year and Nyx_targetTimeTable.yday == Nyx_nowTimeTable.yday then
				Nyx_formatTimestamp_var1 = "Today"
			elseif Nyx_targetTimeTable.year == Nyx_nowTimeTable.year and Nyx_targetTimeTable.yday == Nyx_nowTimeTable.yday - 1 then
				Nyx_formatTimestamp_var1 = "Yesterday"
			elseif Nyx_targetTimeTable.year == Nyx_nowTimeTable.year and Nyx_targetTimeTable.yday == Nyx_nowTimeTable.yday + 1 then
				Nyx_formatTimestamp_var1 = "Tomorrow"
			else
				Nyx_formatTimestamp_var1 = string.format("%02d/%02d", Nyx_targetTimeTable.month, Nyx_targetTimeTable.day)
			end

			if showSeconds then
				return string.format("%s %02d:%02d:%02d", Nyx_formatTimestamp_var1, Nyx_targetTimeTable.hour, Nyx_targetTimeTable.min, Nyx_targetTimeTable.sec)
			end

			return string.format("%s %02d:%02d", Nyx_formatTimestamp_var1, Nyx_targetTimeTable.hour, Nyx_targetTimeTable.min)
		end
		local function Nyx_formatRelativeTime(timestamp)
			if not timestamp or timestamp <= 0 then
				return ""
			end

			local Nyx_ageSeconds = os.time() - timestamp

			if Nyx_ageSeconds < 0 then
				local Nyx_ageSecondsAbs = -Nyx_ageSeconds

				if Nyx_ageSecondsAbs < 60 then
					return "in <1m"
				end

				if Nyx_ageSecondsAbs < 3600 then
					return string.format("in %dm", math.floor(Nyx_ageSecondsAbs / 60))
				end

				return string.format("in %.1fh", Nyx_ageSecondsAbs / 3600)
			end

			if Nyx_ageSeconds < 60 then
				return "Just now"
			end

			if Nyx_ageSeconds < 3600 then
				return string.format("%dm ago", math.floor(Nyx_ageSeconds / 60))
			end

			if Nyx_ageSeconds < 86400 then
				return string.format("%.1fh ago", Nyx_ageSeconds / 3600)
			end

			return string.format("%.1fd ago", Nyx_ageSeconds / 86400)
		end
		local function Nyx_formatWindowRange(startTime, endTime)
			local Nyx_windowStartRounded = Nyx_roundToCycle(startTime)
			local Nyx_windowEndRounded = Nyx_roundToCycle(endTime)
			local now = os.time()
			local Nyx_nowTimeTable2 = os.date("*t", now)
			local Nyx_startTimeTable = os.date("*t", Nyx_windowStartRounded)
			local Nyx_endTimeTable = os.date("*t", Nyx_windowEndRounded)

			local function Nyx_getDayLabel(timeTable)
				if timeTable.year == Nyx_nowTimeTable2.year and timeTable.yday == Nyx_nowTimeTable2.yday then
					return "Today"
				end

				if timeTable.year == Nyx_nowTimeTable2.year and timeTable.yday == Nyx_nowTimeTable2.yday + 1 then
					return "Tomorrow"
				end

				if timeTable.year == Nyx_nowTimeTable2.year and timeTable.yday == Nyx_nowTimeTable2.yday - 1 then
					return "Yesterday"
				end

				return string.format("%02d/%02d", timeTable.month, timeTable.day)
			end

			local Nyx_startDayLabel = Nyx_getDayLabel(Nyx_startTimeTable)
			local Nyx_endDayLabel = Nyx_getDayLabel(Nyx_endTimeTable)

			if Nyx_startDayLabel == Nyx_endDayLabel then
				return string.format("%s %02d:%02d - %02d:%02d", Nyx_startDayLabel, Nyx_startTimeTable.hour, Nyx_startTimeTable.min, Nyx_endTimeTable.hour, Nyx_endTimeTable.min)
			end

			return string.format("%s %02d:%02d - %s %02d:%02d", Nyx_startDayLabel, Nyx_startTimeTable.hour, Nyx_startTimeTable.min, Nyx_endDayLabel, Nyx_endTimeTable.hour, Nyx_endTimeTable.min)
		end

		local Nyx_getDayLabel_var1 = {
			Mosasaurus = "rbxassetid://124293259998827",
			["Oni Tiger"] = "rbxassetid://109908891899435",
			["Eternal Lunar Dragon"] = "rbxassetid://93762296316916",
			["Lunar Dragon"] = "rbxassetid://93762296316916",
			["King Kong"] = "rbxassetid://135650224014044",
			["Gorilla King"] = "rbxassetid://135650224014044",
			["Ice Dragon"] = "rbxassetid://101397684798718",
			Phoenix = "rbxassetid://118067990008425",
			["Ascended Vermilion Phoenix"] = "rbxassetid://118067990008425",
			Dragon = "rbxassetid://78935088838538",
			["Lava Dragon"] = "rbxassetid://78935088838538",
			["Dragon (Lava)"] = "rbxassetid://78935088838538",
			Pegasus = "rbxassetid://112830316982322",
			["El Maja"] = "rbxassetid://77518688092604",
			Kitsune = "rbxassetid://107842067813602",
			Unicorn = "rbxassetid://70463817382627",
			Godzilla = "rbxassetid://102979882140882",
			ArchAngel = "rbxassetid://113289118499426",
			["Cosmic Dragon"] = "rbxassetid://107923370723949",
			TRex = "rbxassetid://124293259998827",
			Gargoyle = "rbxassetid://137949993315884",
			["King Snake"] = "rbxassetid://77518688092604"
		}
		local Nyx_getDayLabel_var2 = {}

		local function Nyx_getEggIcon(petName)
			if not petName then
				return ""
			end

			if Nyx_getDayLabel_var1[petName] then
				return Nyx_getDayLabel_var1[petName]
			end

			if Nyx_getDayLabel_var2[petName] ~= nil then
				return Nyx_getDayLabel_var2[petName]
			end

			Nyx_getDayLabel_var2[petName] = Nyx_findIconUrl(petName) or ""

			return Nyx_getDayLabel_var2[petName]
		end
		local function Nyx_httpRequest(requestParams)
			local request_ = syn and syn.request or http and http.request or request or http_request

			if request_ then
				local Nyx_httpRequest_var1

				if pcall(function()
					Nyx_httpRequest_var1 = request_(requestParams)
				end) and Nyx_httpRequest_var1 then
					return Nyx_httpRequest_var1
				end
			end

			if requestParams.Method == "GET" and game and game.HttpGet then
				local response

				if pcall(function()
					response = game:HttpGet(requestParams.Url, true)
				end) and response then
					return {
						StatusCode = 200,
						Body = response
					}
				end
			end

			return nil
		end

		local Nyx_eggTargets = {
			{
				id = "eternal_fast",
				title = "Eternal",
				cycleLabel = "45 - 90m",
				rarity = "Eternal",
				windowMin = 45,
				windowMax = 90,
				priority = 1,
				color = Color3.fromRGB(255, 215, 0),
				candidates = {
					{
						name = "Mosasaurus",
						area = "Prehistoric",
						chance = "10.85%",
						icon = "rbxassetid://124293259998827"
					},
					{
						name = "Oni Tiger",
						area = "Cherry Blossom",
						chance = "10.85%",
						icon = "rbxassetid://109908891899435"
					},
					{
						name = "Lunar Dragon",
						area = "Cosmic",
						chance = "10.85%",
						icon = "rbxassetid://93762296316916"
					},
					{
						name = "Gorilla King",
						area = "Titan Temple",
						chance = "10.85%",
						icon = "rbxassetid://135650224014044"
					},
					{
						name = "Ice Dragon",
						area = "Snow",
						chance = "10.85%",
						icon = "rbxassetid://101397684798718"
					},
					{
						name = "Phoenix",
						area = "Volcano",
						chance = "10.85%",
						icon = "rbxassetid://118067990008425"
					}
				}
			},
			{
				id = "divine_fast",
				title = "Divine",
				cycleLabel = "1.5 - 3h",
				rarity = "Divine",
				windowMinH = 1.5,
				windowMaxH = 3,
				priority = 2,
				color = Color3.fromRGB(255, 255, 255),
				candidates = {
					{
						name = "Kitsune",
						area = "Cherry Blossom",
						chance = "20%",
						icon = "rbxassetid://107842067813602"
					},
					{
						name = "ArchAngel",
						area = "Heaven",
						chance = "20%",
						icon = "rbxassetid://113289118499426"
					},
					{
						name = "Godzilla",
						area = "Prehistoric",
						chance = "20%",
						icon = "rbxassetid://102979882140882"
					},
					{
						name = "Pegasus",
						area = "Fantasy",
						chance = "20%",
						icon = "rbxassetid://112830316982322"
					},
					{
						name = "Unicorn",
						area = "Magical Forest",
						chance = "20%",
						icon = "rbxassetid://70463817382627"
					}
				}
			}
		}

		local function Nyx_recordEggSpawn(spawnData)
			if not spawnData or not spawnData.name then
				return false
			end

			local now = tonumber(spawnData.ts) or os.time()

			spawnData.ts = now

			local Nyx_rarityLower = (spawnData.rarity or ""):lower()

			if Nyx_rarityLower ~= "eternal" and Nyx_rarityLower ~= "divine" then
				return false
			end

			local Nyx_petKeyNorm = Nyx_normalizePetNameKey(spawnData.name)

			for _, v in ipairs(Nyx_EggDataUI.history) do
				if v.uid and spawnData.uid and v.uid == spawnData.uid then
					return false
				end

				if Nyx_normalizePetNameKey(v.name) ~= Nyx_petKeyNorm then
					continue
				end

				if not (math.abs((v.ts or 0) - now) < 600) then
					continue
				end

				return false
			end

			table.insert(Nyx_EggDataUI.history, spawnData)
			table.sort(Nyx_EggDataUI.history, function(entryA, entryB)
				return (entryA.ts or 0) > (entryB.ts or 0)
			end)

			if Nyx_rarityLower == "eternal" then
				if not Nyx_EggDataUI.lastEternal then
					Nyx_EggDataUI.lastEternal = spawnData
				elseif (Nyx_EggDataUI.lastEternal.ts or 0) <= now then
					Nyx_EggDataUI.lastEternal = spawnData

					return true
				end
			elseif Nyx_rarityLower == "divine" then
				if not Nyx_EggDataUI.lastDivine then
					Nyx_EggDataUI.lastDivine = spawnData
				elseif (Nyx_EggDataUI.lastDivine.ts or 0) <= now then
					Nyx_EggDataUI.lastDivine = spawnData

					return true
				end
			end

			return true
		end

		Nyx_EggDataUI.getLatestSpawn = function(rarity, candidateNames)
			for _, v in ipairs(Nyx_EggDataUI.history) do
				if rarity and (not v.rarity or v.rarity:lower() ~= rarity:lower()) then
					continue
				end

				if not candidateNames or not (#candidateNames > 0) then
					return v
				end

				local Nyx_petKeyNorm2 = Nyx_normalizePetNameKey(v.name)

				for _, Nyx_item in ipairs(candidateNames) do
					if Nyx_normalizePetNameKey(Nyx_item.name) == Nyx_petKeyNorm2 then
						return v
					end
				end
			end

			return nil
		end

		for _, v in ipairs({
			{
				uid = "afad935fc39f4ad0a28d83d74dad60f8",
				name = "Ice Dragon",
				area = "Snow",
				rarity = "Eternal",
				ts = 1789738200,
				reporter = "Server Alert"
			},
			{
				uid = "aac1107e3c3a428c93ecc8d5c4c03296",
				name = "Mosasaurus",
				area = "Prehistoric",
				rarity = "Eternal",
				ts = 1789735200,
				reporter = "Server Alert"
			},
			{
				uid = "2f08670c03054614b5c088092e0eab9e",
				name = "Eternal Lunar Dragon",
				area = "Cosmic",
				rarity = "Eternal",
				ts = 1789733400,
				reporter = "Server Alert"
			},
			{
				uid = "d2c1c02c35224ca78eddeda7128643a6",
				name = "Skeleton Horse",
				area = "Light Dark",
				rarity = "Eternal",
				ts = 1789731600,
				reporter = "Server Alert"
			},
			{
				uid = "a9f84b4645bd4d23a2a8887923febe6e",
				name = "Gorilla King",
				area = "Titan Temple",
				rarity = "Eternal",
				ts = 1789729800,
				reporter = "Server Alert"
			},
			{
				uid = "seed_divine_1",
				name = "Kitsune",
				area = "Cherry Blossom",
				rarity = "Divine",
				ts = 1789678800,
				reporter = "Server Alert"
			}
		}) do
			Nyx_recordEggSpawn(v)
		end

		local function Nyx_parseSpawnMessage(message)
			if not message or type(message) ~= "string" then
				return nil
			end

			if not message:find("spawned in") then
				return nil
			end

			local Nyx_cleanedSpawnText = message:gsub("<[^>]+>", ""):gsub("[%c]", "")
			local match, match2, Nyx_spawnAreaMatch = Nyx_cleanedSpawnText:match("A%s+(%a+)%s+(.-)%s+Egg%s+spawned%s+in%s+([^!]+)")

			if not match or not match2 or not Nyx_spawnAreaMatch then
				match2, match, Nyx_spawnAreaMatch = Nyx_cleanedSpawnText:match("([%w%s]+)%s*%((%a+)%)%s+has%s+spawned%s+in%s+([^!]+)")
			end

			if not match or not match2 or not Nyx_spawnAreaMatch then
				return nil
			end

			local Nyx_spawnArea = Nyx_spawnAreaMatch:gsub("%s+$", ""):gsub("^%s+", "")
			local Nyx_spawnRarity = match2:gsub("%s+$", ""):gsub("^%s+", "")

			return match:gsub("%s+$", ""):gsub("^%s+", ""), Nyx_spawnRarity, Nyx_spawnArea
		end
		local function Nyx_processSpawnMessage(message)
			local Nyx_spawnRarity2, Nyx_spawnPetName, Nyx_spawnArea2 = Nyx_parseSpawnMessage(message)

			if not Nyx_spawnRarity2 or not Nyx_spawnPetName or not Nyx_spawnArea2 then
				return
			end

			local now = os.time()
			local Nyx_spawnPetKey = Nyx_normalizePetNameKey(Nyx_spawnPetName)
			local Nyx_spawnAlertBucket = math.floor(now / 300)
			local Nyx_spawnAlertKey = string.format("alert_%s_%s_%d", Nyx_spawnPetKey, Nyx_spawnArea2:lower(), Nyx_spawnAlertBucket)

			if Nyx_EggDataUI.reportedUids[Nyx_spawnAlertKey] then
				return
			end

			Nyx_EggDataUI.reportedUids[Nyx_spawnAlertKey] = now
			Nyx_EggDataUI.lastAlert = {
				pet = Nyx_spawnPetName,
				area = Nyx_spawnArea2,
				rarity = Nyx_spawnRarity2,
				ts = now,
				norm = Nyx_spawnPetKey
			}

			if Nyx_recordEggSpawn({
				uid = Nyx_spawnAlertKey,
				name = Nyx_spawnPetName,
				area = Nyx_spawnArea2,
				rarity = Nyx_spawnRarity2,
				ts = now,
				reporter = "Server Alert"
			}) then
				pcall(Nyx_EggDataUI.paint)
			end
		end

		Nyx_EggDataUI.reportSpawn = function(uid, petName, area, rarity, timestamp)
			if not uid or Nyx_EggDataUI.reportedUids[uid] then
				return
			end

			local now = os.time()
			local Nyx_spawnReportTs = tonumber(timestamp) or now

			if now - Nyx_EggDataUI.lastReportTime < 3 then
				return
			end

			Nyx_EggDataUI.reportedUids[uid] = Nyx_spawnReportTs
			Nyx_EggDataUI.lastReportTime = now

			local Name = LocalPlayer and LocalPlayer.Name or "Player"

			if Nyx_recordEggSpawn({
				uid = tostring(uid),
				name = petName,
				area = area,
				rarity = rarity,
				ts = Nyx_spawnReportTs,
				reporter = Name
			}) then
				pcall(Nyx_EggDataUI.paint)
			end
		end
		Nyx_EggDataUI.syncBackend = function()
			local now = os.time()

			if now - Nyx_EggDataUI.lastSync < 10 then
				return
			end

			Nyx_EggDataUI.lastSync = now
			task.spawn(function()
				local NyxBackend = getgenv and getgenv().NyxBackend or {}
				local Api = NyxBackend.Api or "http://56.10.112.179:8080"
				local Key = NyxBackend.Key or ""
				local Nyx_localUserId = LocalPlayer and tostring(LocalPlayer.UserId) or "0"
				local Nyx_eggSyncResponse = Nyx_httpRequest({
					Url = Api .. "/egg/latest?key=" .. tostring(Key) .. "&uid=" .. tostring(Nyx_localUserId) .. "&t=" .. tostring(now),
					Method = "GET"
				})

				if Nyx_eggSyncResponse and (Nyx_eggSyncResponse.StatusCode == 200 or Nyx_eggSyncResponse.Status == 200) and Nyx_eggSyncResponse.Body then
					local HttpService2 = game:GetService("HttpService")
					local ok, result = pcall(function()
						return HttpService2:JSONDecode(Nyx_eggSyncResponse.Body)
					end)

					if ok and type(result) == "table" and result.ok then
						if result.last_eternal and type(result.last_eternal) == "table" and result.last_eternal.name then
							Nyx_recordEggSpawn(result.last_eternal)
						end

						if result.last_divine and type(result.last_divine) == "table" and result.last_divine.name then
							Nyx_recordEggSpawn(result.last_divine)
						end

						if type(result.recent_spawns) == "table" then
							for _, recentSpawn in ipairs(result.recent_spawns) do
								Nyx_recordEggSpawn(recentSpawn)
							end
						end

						pcall(Nyx_EggDataUI.paint)
					end
				end
			end)
		end
		Nyx_EggDataUI.scanField = function()
			local Nyx_processSpawnMessage_var2

			pcall(function()
				Nyx_processSpawnMessage_var2 = EggState2.ReadFieldEggs()
			end)

			if not Nyx_processSpawnMessage_var2 or not Nyx_processSpawnMessage_var2.Records then
				return
			end

			local now = os.time()

			if not Nyx_EggDataUI._fieldInitialized then
				Nyx_EggDataUI._fieldInitialized = true

				for _, record in ipairs(Nyx_processSpawnMessage_var2.Records) do
					if record.Uid then
						Nyx_EggDataUI.knownFieldUids[record.Uid] = true
					end
				end

				return
			end

			for _, record in ipairs(Nyx_processSpawnMessage_var2.Records) do
				if record.Uid and not Nyx_EggDataUI.knownFieldUids[record.Uid] then
					Nyx_EggDataUI.knownFieldUids[record.Uid] = true

					if record.State ~= "Claimed" and record.BottomCFrame then
						local AssetCategory = record.AssetCategory
						local _, Nyx_fieldEggRarity = Nyx_resolveRarityInfo(AssetCategory)

						if Nyx_fieldEggRarity == "Divine" or Nyx_fieldEggRarity == "Eternal" then
							local Nyx_fieldEggNameAliased = AssetCategory == "King Kong" and "Gorilla King" or AssetCategory == "Ascended Vermilion Phoenix" and "Phoenix" or AssetCategory
							local ts = now

							if Nyx_EggDataUI.lastAlert then
								if now - (Nyx_EggDataUI.lastAlert.ts or 0) <= 60 and Nyx_normalizePetNameKey(Nyx_EggDataUI.lastAlert.pet) == Nyx_normalizePetNameKey(Nyx_fieldEggNameAliased) then
									if Nyx_EggDataUI.lastAlert.area:lower() == (record.AreaId or ""):lower() then
										ts = Nyx_EggDataUI.lastAlert.ts
									end
								end
							end

							Nyx_EggDataUI.reportSpawn(record.Uid, Nyx_fieldEggNameAliased, record.AreaId or "Field", Nyx_fieldEggRarity, ts)
						end
					end
				end
			end
		end
		Nyx_EggDataUI.paint = function()
			Nyx_applyElevatedIdentity()

			if not Nyx_EggDataUI.list or not Nyx_EggDataUI.list.Parent then
				return
			end

			for _, child in ipairs(Nyx_EggDataUI.list:GetChildren()) do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end

			local now = os.time()
			local eternal = Nyx_EggDataUI.getLatestSpawn("eternal")
			local divine = Nyx_EggDataUI.getLatestSpawn("divine")
			local ts = eternal and eternal.ts or 1789738200
			local ts2 = divine and divine.ts or 1789678800

			if Nyx_EggDataUI.catBtnTargets and Nyx_EggDataUI.catBtnHistory then
				local Nyx_isTargetsTab = Nyx_EggDataUI.category == "targets"

				Nyx_EggDataUI.catBtnTargets.BackgroundColor3 = Nyx_isTargetsTab and Nyx_uiTheme.accent or Color3.fromRGB(24, 26, 36)
				Nyx_EggDataUI.catBtnTargets.TextColor3 = Nyx_isTargetsTab and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText

				local UIStroke = Nyx_EggDataUI.catBtnTargets:FindFirstChildOfClass("UIStroke")

				if UIStroke then
					UIStroke.Color = Nyx_isTargetsTab and Nyx_uiTheme.accent or Nyx_uiTheme.strokeCol
				end

				Nyx_EggDataUI.catBtnHistory.BackgroundColor3 = not Nyx_isTargetsTab and Nyx_uiTheme.accent or Color3.fromRGB(24, 26, 36)
				Nyx_EggDataUI.catBtnHistory.TextColor3 = not Nyx_isTargetsTab and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText

				local UIStroke2 = Nyx_EggDataUI.catBtnHistory:FindFirstChildOfClass("UIStroke")

				if UIStroke2 then
					UIStroke2.Color = not Nyx_isTargetsTab and Nyx_uiTheme.accent or Nyx_uiTheme.strokeCol
				end
			end

			if Nyx_EggDataUI.noticeBox then
				Nyx_EggDataUI.noticeBox.Visible = Nyx_EggDataUI.category == "targets"
			end

			if Nyx_EggDataUI.summaryBox then
				Nyx_EggDataUI.summaryBox.Visible = Nyx_EggDataUI.category == "history"

				if Nyx_EggDataUI.summaryText and Nyx_EggDataUI.category == "history" then
					local Nyx_latestEternal = eternal
					local name = Nyx_latestEternal and Nyx_latestEternal.name or "Phoenix"
					local area = Nyx_latestEternal and Nyx_latestEternal.area or "Volcano"
					local ts3 = Nyx_latestEternal and Nyx_latestEternal.ts or ts
					local Nyx_eternalTimeStr = Nyx_formatTimestamp(ts3, true)
					local Nyx_eternalAgeStr = Nyx_formatRelativeTime(ts3)
					local Nyx_latestDivine = divine
					local name2 = Nyx_latestDivine and Nyx_latestDivine.name or "Kitsune"
					local area2 = Nyx_latestDivine and Nyx_latestDivine.area or "Cherry Blossom"
					local ts4 = Nyx_latestDivine and Nyx_latestDivine.ts or ts2
					local Nyx_divineTimeStr = Nyx_formatTimestamp(ts4, true)
					local Nyx_divineAgeStr = Nyx_formatRelativeTime(ts4)

					Nyx_EggDataUI.summaryText.Text = string.format("<b>LAST ETERNAL:</b> <font color='#ffd700'><b>%s</b></font> (%s) - %s <font color='#8899aa'>(%s)</font>\n<b>LAST DIVINE:</b> <font color='#ffffff'><b>%s</b></font> (%s) - %s <font color='#8899aa'>(%s)</font>", name, area, Nyx_eternalTimeStr, Nyx_eternalAgeStr, name2, area2, Nyx_divineTimeStr, Nyx_divineAgeStr)
				end
			end

			if Nyx_EggDataUI.refreshBtn then
				Nyx_EggDataUI.refreshBtn.Text = Nyx_EggDataUI.category == "targets" and "Refresh Targets" or "Refresh History"
			end

			if Nyx_EggDataUI.category == "targets" then
				local Nyx_processSpawnMessage_var1 = 0

				for i, v in ipairs(Nyx_eggTargets) do
					if Nyx_EggDataUI.filter == "All" or Nyx_EggDataUI.filter == v.rarity then
						Nyx_processSpawnMessage_var1 += 1

						local divine2 = Nyx_EggDataUI.getLatestSpawn(v.rarity, v.candidates) or eternal

						if v.rarity == "Divine" then
							divine2 = Nyx_EggDataUI.getLatestSpawn("divine") or divine
						end

						local ts3 = divine2 and divine2.ts or v.rarity == "Divine" and ts2 or ts
						local Nyx_windowMinSec = v.windowMinH and v.windowMinH * 3600

						if not Nyx_windowMinSec then
							Nyx_windowMinSec = (v.windowMin or 45) * 60
						end

						local Nyx_windowMaxSec = v.windowMaxH and v.windowMaxH * 3600

						if not Nyx_windowMaxSec then
							Nyx_windowMaxSec = (v.windowMax or 90) * 60
						end

						local Nyx_windowRangeSec = Nyx_windowMaxSec - Nyx_windowMinSec
						local Nyx_windowStart = ts3 + Nyx_windowMinSec
						local Nyx_windowEnd = ts3 + Nyx_windowMaxSec

						if v.rarity == "Eternal" and Nyx_windowMinSec * 0.75 < now - Nyx_windowEnd then
							while Nyx_windowMinSec * 0.75 < now - Nyx_windowEnd do
								Nyx_windowStart = Nyx_windowEnd + Nyx_windowMinSec
								Nyx_windowEnd = Nyx_windowStart + Nyx_windowRangeSec
							end
						end

						local Nyx_windowStartRounded2 = Nyx_roundToCycle(Nyx_windowStart)
						local Nyx_windowEndRounded2 = Nyx_roundToCycle(Nyx_windowEnd)
						local text = "UPCOMING"
						local color3 = Color3.fromRGB(100, 200, 255)

						if Nyx_windowEndRounded2 < now then
							local Nyx_overdueMinutes = math.ceil((now - Nyx_windowEndRounded2) / 60)

							text = Nyx_overdueMinutes >= 60 and string.format("OVERDUE +%.1fh", Nyx_overdueMinutes / 60) or string.format("OVERDUE +%dm", Nyx_overdueMinutes)
							color3 = Color3.fromRGB(255, 0, 128)
						elseif Nyx_windowStartRounded2 <= now and now <= Nyx_windowEndRounded2 then
							text = "IN WINDOW"
							color3 = Color3.fromRGB(0, 255, 136)
						else
							local Nyx_timeUntilWindowMin = math.ceil((Nyx_windowStartRounded2 - now) / 60)

							if Nyx_timeUntilWindowMin > 0 and Nyx_timeUntilWindowMin < 60 then
								text = string.format("IN %dm", Nyx_timeUntilWindowMin)
								color3 = Color3.fromRGB(80, 210, 255)
							elseif Nyx_timeUntilWindowMin >= 60 then
								text = string.format("IN %.1fh", Nyx_timeUntilWindowMin / 60)
								color3 = Color3.fromRGB(80, 210, 255)
							end
						end

						local Frame = Instance.new("Frame")

						Frame.Size = UDim2.new(1, -6, 0, 122)
						Frame.BackgroundColor3 = Nyx_uiTheme.surface
						Frame.BackgroundTransparency = 0.15
						Frame.BorderSizePixel = 0
						Frame.LayoutOrder = i
						Frame.Parent = Nyx_EggDataUI.list
						Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

						local UIStroke = Instance.new("UIStroke", Frame)

						UIStroke.Color = v.color or Nyx_uiTheme.accent
						UIStroke.Thickness = 1
						UIStroke.Transparency = 0.78

						local Frame2 = Instance.new("Frame")

						Frame2.Size = UDim2.new(0, 4, 1, -12)
						Frame2.Position = UDim2.fromOffset(0, 6)
						Frame2.BorderSizePixel = 0
						Frame2.BackgroundColor3 = v.color or Nyx_uiTheme.accent
						Frame2.Parent = Frame
						Instance.new("UICorner", Frame2).CornerRadius = UDim.new(1, 0)

						local TextLabel5 = Instance.new("TextLabel")

						TextLabel5.BackgroundTransparency = 1
						TextLabel5.Position = UDim2.fromOffset(12, 6)
						TextLabel5.Size = UDim2.new(0.5, 0, 0, 16)
						TextLabel5.Font = Enum.Font.GothamBold
						TextLabel5.TextSize = 13
						TextLabel5.TextXAlignment = Enum.TextXAlignment.Left
						TextLabel5.TextColor3 = v.color or Color3.fromRGB(255, 255, 255)
						TextLabel5.Text = string.format("%s Window (%s)", v.title, v.cycleLabel)
						TextLabel5.Parent = Frame

						local TextLabel6 = Instance.new("TextLabel")

						TextLabel6.Position = UDim2.new(1, -12, 0, 6)
						TextLabel6.AnchorPoint = Vector2.new(1, 0)
						TextLabel6.Size = UDim2.fromOffset(math.max(76, #text * 7 + 14), 18)
						TextLabel6.BackgroundColor3 = color3
						TextLabel6.BackgroundTransparency = 0.2
						TextLabel6.Font = Enum.Font.GothamBold
						TextLabel6.TextSize = 10
						TextLabel6.TextColor3 = Color3.fromRGB(255, 255, 255)
						TextLabel6.Text = text
						TextLabel6.Parent = Frame
						Instance.new("UICorner", TextLabel6).CornerRadius = UDim.new(0, 4)

						local TextLabel7 = Instance.new("TextLabel")

						TextLabel7.BackgroundTransparency = 1
						TextLabel7.Position = UDim2.fromOffset(12, 24)
						TextLabel7.Size = UDim2.new(1, -24, 0, 14)
						TextLabel7.Font = Enum.Font.GothamMedium
						TextLabel7.TextSize = 10
						TextLabel7.TextXAlignment = Enum.TextXAlignment.Left
						TextLabel7.TextColor3 = Color3.fromRGB(150, 180, 220)
						TextLabel7.Text = string.format("Window: %s", Nyx_formatWindowRange(Nyx_windowStartRounded2, Nyx_windowEndRounded2))
						TextLabel7.Parent = Frame

						local ScrollingFrame = Instance.new("ScrollingFrame")

						ScrollingFrame.Position = UDim2.fromOffset(12, 42)
						ScrollingFrame.Size = UDim2.new(1, -24, 0, 72)
						ScrollingFrame.BackgroundTransparency = 1
						ScrollingFrame.BorderSizePixel = 0
						ScrollingFrame.ScrollBarThickness = 2
						ScrollingFrame.ScrollBarImageColor3 = v.color or Nyx_uiTheme.accent
						ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
						ScrollingFrame.CanvasSize = UDim2.new(0, #v.candidates * 64 + 4, 0, 0)
						ScrollingFrame.Parent = Frame

						local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)

						UIListLayout.FillDirection = Enum.FillDirection.Horizontal
						UIListLayout.Padding = UDim.new(0, 6)

						for _, candidate in ipairs(v.candidates) do
							local Frame3 = Instance.new("Frame")

							Frame3.Size = UDim2.fromOffset(58, 68)
							Frame3.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
							Frame3.BackgroundTransparency = 0.3
							Frame3.BorderSizePixel = 0
							Frame3.Parent = ScrollingFrame
							Instance.new("UICorner", Frame3).CornerRadius = UDim.new(0, 6)

							local UIStroke2 = Instance.new("UIStroke", Frame3)

							UIStroke2.Color = v.color or Nyx_uiTheme.strokeCol
							UIStroke2.Thickness = 1
							UIStroke2.Transparency = 0.75

							local ImageLabel = Instance.new("ImageLabel")

							ImageLabel.Position = UDim2.fromOffset(15, 4)
							ImageLabel.Size = UDim2.fromOffset(28, 28)
							ImageLabel.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
							ImageLabel.BackgroundTransparency = 0.4
							ImageLabel.BorderSizePixel = 0
							ImageLabel.ScaleType = Enum.ScaleType.Fit
							ImageLabel.Image = candidate.icon or Nyx_getEggIcon(candidate.name)
							ImageLabel.Parent = Frame3
							Instance.new("UICorner", ImageLabel).CornerRadius = UDim.new(0, 4)

							local TextLabel8 = Instance.new("TextLabel")

							TextLabel8.Position = UDim2.new(0, 1, 0, 34)
							TextLabel8.Size = UDim2.new(1, -2, 0, 12)
							TextLabel8.BackgroundTransparency = 1
							TextLabel8.Font = Enum.Font.GothamBold
							TextLabel8.TextSize = 8
							TextLabel8.TextTruncate = Enum.TextTruncate.AtEnd
							TextLabel8.TextColor3 = Color3.fromRGB(230, 235, 245)
							TextLabel8.TextXAlignment = Enum.TextXAlignment.Center
							TextLabel8.Text = candidate.name
							TextLabel8.Parent = Frame3

							local TextLabel9 = Instance.new("TextLabel")

							TextLabel9.Position = UDim2.new(0, 1, 0, 46)
							TextLabel9.Size = UDim2.new(1, -2, 0, 11)
							TextLabel9.BackgroundTransparency = 1
							TextLabel9.Font = Enum.Font.GothamMedium
							TextLabel9.TextSize = 7
							TextLabel9.TextTruncate = Enum.TextTruncate.AtEnd
							TextLabel9.TextColor3 = Nyx_uiTheme.muted
							TextLabel9.TextXAlignment = Enum.TextXAlignment.Center
							TextLabel9.Text = candidate.area
							TextLabel9.Parent = Frame3

							local TextLabel10 = Instance.new("TextLabel")

							TextLabel10.Position = UDim2.new(0, 1, 0, 58)
							TextLabel10.Size = UDim2.new(1, -2, 0, 11)
							TextLabel10.BackgroundTransparency = 1
							TextLabel10.Font = Enum.Font.GothamBold
							TextLabel10.TextSize = 8
							TextLabel10.TextColor3 = Color3.fromRGB(255, 185, 0)
							TextLabel10.TextXAlignment = Enum.TextXAlignment.Center
							TextLabel10.Text = candidate.chance
							TextLabel10.Parent = Frame3
						end
					end
				end

				Nyx_EggDataUI.list.CanvasSize = UDim2.new(0, 0, 0, Nyx_processSpawnMessage_var1 * 128 + 10)
			else
				local Nyx_historyList = {}

				for _, v in ipairs(Nyx_EggDataUI.history) do
					if Nyx_EggDataUI.filter == "All" or Nyx_EggDataUI.filter == v.rarity then
						local _, _, Nyx_historyEggColor = Nyx_resolveRarityInfo(v.name)

						table.insert(Nyx_historyList, {
							name = v.name,
							area = v.area,
							rarity = v.rarity,
							subText1 = string.format("[%s] - %s", (v.rarity or "Eternal"):upper(), v.area or "Field"),
							subText2 = string.format("Source: %s", v.reporter or "Server Alert"),
							rateText = Nyx_formatTimestamp(v.ts, false),
							badge = Nyx_formatRelativeTime(v.ts),
							badgeColor = Color3.fromRGB(0, 255, 136),
							color = Nyx_historyEggColor or v.rarity == "Divine" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 215, 0),
							icon = Nyx_getEggIcon(v.name),
							order = 1e10 - (v.ts or 0)
						})
					end
				end

				for i, v in ipairs(Nyx_historyList) do
					local Frame = Instance.new("Frame")

					Frame.Size = UDim2.new(1, -6, 0, 54)
					Frame.BackgroundColor3 = Nyx_uiTheme.surface
					Frame.BackgroundTransparency = 0.15
					Frame.BorderSizePixel = 0
					Frame.LayoutOrder = i
					Frame.Parent = Nyx_EggDataUI.list
					Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

					local UIStroke = Instance.new("UIStroke", Frame)

					UIStroke.Color = v.color or Nyx_uiTheme.accent
					UIStroke.Thickness = 1
					UIStroke.Transparency = 0.78

					local Frame2 = Instance.new("Frame")

					Frame2.Size = UDim2.new(0, 4, 1, -12)
					Frame2.Position = UDim2.fromOffset(0, 6)
					Frame2.BorderSizePixel = 0
					Frame2.BackgroundColor3 = v.color or Nyx_uiTheme.accent
					Frame2.Parent = Frame
					Instance.new("UICorner", Frame2).CornerRadius = UDim.new(1, 0)

					local ImageLabel = Instance.new("ImageLabel")

					ImageLabel.Position = UDim2.fromOffset(10, 8)
					ImageLabel.Size = UDim2.fromOffset(38, 38)
					ImageLabel.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
					ImageLabel.BackgroundTransparency = 0.4
					ImageLabel.BorderSizePixel = 0
					ImageLabel.ScaleType = Enum.ScaleType.Fit
					ImageLabel.Image = v.icon or ""
					ImageLabel.Parent = Frame
					Instance.new("UICorner", ImageLabel).CornerRadius = UDim.new(0, 6)

					local TextLabel5 = Instance.new("TextLabel")

					TextLabel5.BackgroundTransparency = 1
					TextLabel5.Position = UDim2.fromOffset(56, 6)
					TextLabel5.Size = UDim2.new(1, -165, 0, 16)
					TextLabel5.Font = Enum.Font.GothamBold
					TextLabel5.TextSize = 12
					TextLabel5.TextXAlignment = Enum.TextXAlignment.Left
					TextLabel5.TextTruncate = Enum.TextTruncate.AtEnd
					TextLabel5.TextColor3 = Nyx_uiTheme.text
					TextLabel5.Text = v.name
					TextLabel5.Parent = Frame

					local TextLabel6 = Instance.new("TextLabel")

					TextLabel6.BackgroundTransparency = 1
					TextLabel6.Position = UDim2.fromOffset(56, 22)
					TextLabel6.Size = UDim2.new(1, -165, 0, 14)
					TextLabel6.Font = Enum.Font.GothamMedium
					TextLabel6.TextSize = 10
					TextLabel6.TextXAlignment = Enum.TextXAlignment.Left
					TextLabel6.TextTruncate = Enum.TextTruncate.AtEnd
					TextLabel6.TextColor3 = Nyx_uiTheme.muted
					TextLabel6.Text = v.subText1
					TextLabel6.Parent = Frame

					local TextLabel7 = Instance.new("TextLabel")

					TextLabel7.BackgroundTransparency = 1
					TextLabel7.Position = UDim2.fromOffset(56, 36)
					TextLabel7.Size = UDim2.new(1, -165, 0, 13)
					TextLabel7.Font = Enum.Font.GothamMedium
					TextLabel7.TextSize = 9
					TextLabel7.TextXAlignment = Enum.TextXAlignment.Left
					TextLabel7.TextTruncate = Enum.TextTruncate.AtEnd
					TextLabel7.TextColor3 = Color3.fromRGB(150, 180, 220)
					TextLabel7.Text = v.subText2
					TextLabel7.Parent = Frame

					local Frame3 = Instance.new("Frame")

					Frame3.BackgroundTransparency = 1
					Frame3.AnchorPoint = Vector2.new(1, 0.5)
					Frame3.Position = UDim2.new(1, -8, 0.5, 0)
					Frame3.Size = UDim2.fromOffset(105, 38)
					Frame3.Parent = Frame

					local TextLabel8 = Instance.new("TextLabel")

					TextLabel8.BackgroundTransparency = 1
					TextLabel8.Size = UDim2.new(1, 0, 0, 18)
					TextLabel8.Font = Enum.Font.GothamBold
					TextLabel8.TextSize = 11
					TextLabel8.TextXAlignment = Enum.TextXAlignment.Right
					TextLabel8.TextTruncate = Enum.TextTruncate.AtEnd
					TextLabel8.TextColor3 = v.badgeColor
					TextLabel8.Text = string.format("[%s]", v.badge)
					TextLabel8.Parent = Frame3

					local TextLabel9 = Instance.new("TextLabel")

					TextLabel9.BackgroundTransparency = 1
					TextLabel9.Position = UDim2.new(0, 0, 0, 18)
					TextLabel9.Size = UDim2.new(1, 0, 0, 16)
					TextLabel9.Font = Enum.Font.GothamBold
					TextLabel9.TextSize = 10
					TextLabel9.TextXAlignment = Enum.TextXAlignment.Right
					TextLabel9.TextTruncate = Enum.TextTruncate.AtEnd
					TextLabel9.TextColor3 = Color3.fromRGB(170, 185, 210)
					TextLabel9.Text = v.rateText
					TextLabel9.Parent = Frame3
				end

				Nyx_EggDataUI.list.CanvasSize = UDim2.new(0, 0, 0, #Nyx_historyList * 58 + 10)
			end
		end
		Nyx_EggDataUI.build = function(parentFrame)
			local Frame = Instance.new("Frame")

			Frame.Size = UDim2.fromScale(1, 1)
			Frame.BackgroundTransparency = 1
			Frame.BorderSizePixel = 0
			Frame.Parent = parentFrame
			Nyx_EggDataUI.headLbl = Instance.new("TextLabel")
			Nyx_EggDataUI.headLbl.BackgroundTransparency = 1
			Nyx_EggDataUI.headLbl.Position = UDim2.fromOffset(14, 2)
			Nyx_EggDataUI.headLbl.Size = UDim2.new(1, -28, 0, 18)
			Nyx_EggDataUI.headLbl.Font = Enum.Font.GothamBold
			Nyx_EggDataUI.headLbl.TextSize = 12
			Nyx_EggDataUI.headLbl.TextXAlignment = Enum.TextXAlignment.Left
			Nyx_EggDataUI.headLbl.TextTruncate = Enum.TextTruncate.AtEnd
			Nyx_EggDataUI.headLbl.TextColor3 = Nyx_uiTheme.accent
			Nyx_EggDataUI.headLbl.Text = "Global Egg Data & History"
			Nyx_EggDataUI.headLbl.Parent = Frame

			local Frame2 = Instance.new("Frame")

			Frame2.Position = UDim2.fromOffset(14, 22)
			Frame2.Size = UDim2.new(1, -28, 0, 32)
			Frame2.BackgroundTransparency = 1
			Frame2.Parent = Frame

			local UIListLayout = Instance.new("UIListLayout", Frame2)

			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout.Padding = UDim.new(0, 8)

			local TextButton = Instance.new("TextButton")

			TextButton.Size = UDim2.new(0.5, -4, 1, 0)
			TextButton.BackgroundColor3 = Nyx_uiTheme.accent
			TextButton.AutoButtonColor = false
			TextButton.Font = Enum.Font.GothamBold
			TextButton.TextSize = 12
			TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextButton.Text = "Egg Data (Targets)"
			TextButton.Parent = Frame2
			Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 6)

			local UIStroke = Instance.new("UIStroke", TextButton)

			UIStroke.Color = Nyx_uiTheme.accent
			UIStroke.Thickness = 1
			Nyx_EggDataUI.catBtnTargets = TextButton

			local TextButton2 = Instance.new("TextButton")

			TextButton2.Size = UDim2.new(0.5, -4, 1, 0)
			TextButton2.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
			TextButton2.AutoButtonColor = false
			TextButton2.Font = Enum.Font.GothamBold
			TextButton2.TextSize = 12
			TextButton2.TextColor3 = Nyx_uiTheme.btnText
			TextButton2.Text = "Egg History"
			TextButton2.Parent = Frame2
			Instance.new("UICorner", TextButton2).CornerRadius = UDim.new(0, 6)

			local UIStroke2 = Instance.new("UIStroke", TextButton2)

			UIStroke2.Color = Nyx_uiTheme.strokeCol
			UIStroke2.Thickness = 1
			Nyx_EggDataUI.catBtnHistory = TextButton2
			TextButton.MouseButton1Click:Connect(function()
				Nyx_EggDataUI.category = "targets"
				Nyx_EggDataUI.filter = "All"

				for k, chip in pairs(Nyx_EggDataUI.chips) do
					local Nyx_isAllChipActive = k == "All"

					chip.BackgroundColor3 = Nyx_isAllChipActive and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
					chip.BackgroundTransparency = Nyx_isAllChipActive and 0.15 or 0.9
					chip.TextColor3 = Nyx_isAllChipActive and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText
				end

				Nyx_EggDataUI.paint()
			end)
			TextButton2.MouseButton1Click:Connect(function()
				Nyx_EggDataUI.category = "history"
				Nyx_EggDataUI.filter = "All"

				for k, chip in pairs(Nyx_EggDataUI.chips) do
					local Nyx_isAllChipActive2 = k == "All"

					chip.BackgroundColor3 = Nyx_isAllChipActive2 and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
					chip.BackgroundTransparency = Nyx_isAllChipActive2 and 0.15 or 0.9
					chip.TextColor3 = Nyx_isAllChipActive2 and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText
				end

				Nyx_EggDataUI.paint()
			end)

			local Frame3 = Instance.new("Frame")

			Frame3.Position = UDim2.fromOffset(14, 58)
			Frame3.Size = UDim2.new(1, -28, 0, 44)
			Frame3.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
			Frame3.BorderSizePixel = 0
			Frame3.Parent = Frame
			Instance.new("UICorner", Frame3).CornerRadius = UDim.new(0, 6)

			local UIStroke3 = Instance.new("UIStroke", Frame3)

			UIStroke3.Color = Color3.fromRGB(50, 80, 130)
			UIStroke3.Thickness = 1
			Nyx_EggDataUI.noticeBox = Frame3

			local TextLabel5 = Instance.new("TextLabel")

			TextLabel5.Position = UDim2.new(0, 8, 0, 4)
			TextLabel5.Size = UDim2.new(1, -16, 1, -8)
			TextLabel5.BackgroundTransparency = 1
			TextLabel5.Font = Enum.Font.GothamMedium
			TextLabel5.TextSize = 10
			TextLabel5.TextColor3 = Color3.fromRGB(180, 205, 235)
			TextLabel5.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel5.TextWrapped = true
			TextLabel5.RichText = true
			TextLabel5.Text = "<b>Note:</b> These are estimated spawn targets based on cycle timing, not 100% guaranteed predictions."
			TextLabel5.Parent = Frame3
			Nyx_EggDataUI.noticeText = TextLabel5

			local Frame4 = Instance.new("Frame")

			Frame4.Position = UDim2.fromOffset(14, 58)
			Frame4.Size = UDim2.new(1, -28, 0, 44)
			Frame4.BackgroundColor3 = Color3.fromRGB(22, 18, 28)
			Frame4.BorderSizePixel = 0
			Frame4.Visible = false
			Frame4.Parent = Frame
			Instance.new("UICorner", Frame4).CornerRadius = UDim.new(0, 6)

			local UIStroke4 = Instance.new("UIStroke", Frame4)

			UIStroke4.Color = Color3.fromRGB(130, 80, 40)
			UIStroke4.Thickness = 1
			Nyx_EggDataUI.summaryBox = Frame4

			local TextLabel6 = Instance.new("TextLabel")

			TextLabel6.Position = UDim2.new(0, 8, 0, 4)
			TextLabel6.Size = UDim2.new(1, -16, 1, -8)
			TextLabel6.BackgroundTransparency = 1
			TextLabel6.Font = Enum.Font.GothamMedium
			TextLabel6.TextSize = 10
			TextLabel6.TextColor3 = Color3.fromRGB(240, 220, 200)
			TextLabel6.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel6.TextWrapped = true
			TextLabel6.RichText = true
			TextLabel6.Text = ""
			TextLabel6.Parent = Frame4
			Nyx_EggDataUI.summaryText = TextLabel6

			local ScrollingFrame = Instance.new("ScrollingFrame")

			ScrollingFrame.Position = UDim2.fromOffset(14, 106)
			ScrollingFrame.Size = UDim2.new(1, -28, 0, 26)
			ScrollingFrame.BackgroundTransparency = 1
			ScrollingFrame.BorderSizePixel = 0
			ScrollingFrame.ScrollBarThickness = 2
			ScrollingFrame.ScrollBarImageColor3 = Nyx_uiTheme.accent
			ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
			ScrollingFrame.CanvasSize = UDim2.new(0, 220, 0, 0)
			ScrollingFrame.Parent = Frame
			Nyx_EggDataUI.chipBar = ScrollingFrame

			local UIListLayout2 = Instance.new("UIListLayout", ScrollingFrame)

			UIListLayout2.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout2.Padding = UDim.new(0, 6)
			UIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
			Nyx_EggDataUI.chips = {}

			for _, v in ipairs({
				"All",
				"Eternal",
				"Divine"
			}) do
				local TextButton3 = Instance.new("TextButton")

				TextButton3.Size = UDim2.fromOffset(60, 24)
				TextButton3.BackgroundColor3 = Nyx_EggDataUI.filter == v and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
				TextButton3.BackgroundTransparency = Nyx_EggDataUI.filter == v and 0.15 or 0.9
				TextButton3.AutoButtonColor = false
				TextButton3.Font = Enum.Font.GothamBold
				TextButton3.TextSize = 11
				TextButton3.TextColor3 = Nyx_EggDataUI.filter == v and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText
				TextButton3.Text = v
				TextButton3.Parent = ScrollingFrame
				Instance.new("UICorner", TextButton3).CornerRadius = UDim.new(1, 0)

				local UIStroke5 = Instance.new("UIStroke", TextButton3)

				UIStroke5.Color = Nyx_uiTheme.accent
				UIStroke5.Thickness = 1
				UIStroke5.Transparency = 0.65
				TextButton3.MouseButton1Click:Connect(function()
					Nyx_EggDataUI.filter = v

					for k, chip in pairs(Nyx_EggDataUI.chips) do
						local Nyx_isFilterChipActive = k == v

						chip.BackgroundColor3 = Nyx_isFilterChipActive and Nyx_uiTheme.accent or Color3.fromRGB(255, 255, 255)
						chip.BackgroundTransparency = Nyx_isFilterChipActive and 0.15 or 0.9
						chip.TextColor3 = Nyx_isFilterChipActive and Color3.fromRGB(255, 255, 255) or Nyx_uiTheme.btnText
					end

					Nyx_EggDataUI.paint()
				end)
				Nyx_EggDataUI.chips[v] = TextButton3
			end

			local ScrollingFrame2 = Instance.new("ScrollingFrame")

			ScrollingFrame2.Position = UDim2.fromOffset(14, 136)
			ScrollingFrame2.Size = UDim2.new(1, -28, 1, -180)
			ScrollingFrame2.BackgroundTransparency = 1
			ScrollingFrame2.BorderSizePixel = 0
			ScrollingFrame2.ScrollBarThickness = 4
			ScrollingFrame2.ScrollBarImageColor3 = Nyx_uiTheme.accent
			ScrollingFrame2.ScrollingDirection = Enum.ScrollingDirection.Y
			ScrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame2.Parent = Frame

			local UIListLayout3 = Instance.new("UIListLayout", ScrollingFrame2)

			UIListLayout3.Padding = UDim.new(0, 6)
			UIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
			Nyx_EggDataUI.list = ScrollingFrame2

			local Frame5 = Instance.new("Frame")

			Frame5.Position = UDim2.new(0, 14, 1, -40)
			Frame5.Size = UDim2.new(1, -28, 0, 32)
			Frame5.BackgroundTransparency = 1
			Frame5.Parent = Frame

			local TextButton3 = Instance.new("TextButton")

			TextButton3.Size = UDim2.new(0.48, -4, 1, 0)
			TextButton3.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
			TextButton3.BackgroundTransparency = 0.15
			TextButton3.AutoButtonColor = false
			TextButton3.Font = Enum.Font.GothamBold
			TextButton3.TextSize = 11
			TextButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextButton3.Text = "Refresh Targets"
			TextButton3.Parent = Frame5
			Instance.new("UICorner", TextButton3).CornerRadius = UDim.new(0, 6)
			TextButton3.MouseButton1Click:Connect(function()
				Nyx_EggDataUI.scanField()
				Nyx_EggDataUI.syncBackend()
				Nyx_EggDataUI.paint()
			end)
			Nyx_EggDataUI.refreshBtn = TextButton3

			local TextLabel7 = Instance.new("TextLabel")

			TextLabel7.AnchorPoint = Vector2.new(1, 0)
			TextLabel7.Position = UDim2.fromScale(1, 0)
			TextLabel7.Size = UDim2.new(0.5, -4, 1, 0)
			TextLabel7.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
			TextLabel7.BackgroundTransparency = 0.2
			TextLabel7.Font = Enum.Font.GothamBold
			TextLabel7.TextSize = 11
			TextLabel7.TextColor3 = Color3.fromRGB(0, 255, 136)
			TextLabel7.Text = "Online Synced"
			TextLabel7.Parent = Frame5
			Instance.new("UICorner", TextLabel7).CornerRadius = UDim.new(0, 6)
			Nyx_EggDataUI.statusLbl = TextLabel7

			if not Nyx_EggDataUI.bound then
				Nyx_EggDataUI.bound = true
				pcall(function()
					local ExperienceChat = game:GetService("CoreGui"):FindFirstChild("ExperienceChat")

					if ExperienceChat then
						for _, descendant in ipairs(ExperienceChat:GetDescendants()) do
							if descendant:IsA("TextLabel") then
								if descendant.Text:find("spawned in") then
									local Nyx_parsedRarity, Nyx_parsedPetName, Nyx_parsedArea = Nyx_parseSpawnMessage(descendant.Text)

									if Nyx_parsedRarity and Nyx_parsedPetName and Nyx_parsedArea then
										local Nyx_initSpawnKey = string.format("init_%s_%s", Nyx_normalizePetNameKey(Nyx_parsedPetName), Nyx_parsedArea:lower())

										if not Nyx_EggDataUI.reportedUids[Nyx_initSpawnKey] then
											Nyx_EggDataUI.reportedUids[Nyx_initSpawnKey] = os.time()
											Nyx_recordEggSpawn({
												uid = Nyx_initSpawnKey,
												name = Nyx_parsedPetName,
												area = Nyx_parsedArea,
												rarity = Nyx_parsedRarity,
												ts = os.time() - 120,
												reporter = "Server Alert"
											})
										end
									end
								end
							end
						end

						ExperienceChat.DescendantAdded:Connect(function(descendant)
							if descendant:IsA("TextLabel") then
								if descendant.Text:find("spawned in") then
									task.wait(0.05)
									Nyx_processSpawnMessage(descendant.Text)
								end
							end
						end)
					end
				end)
				pcall(function()
					game:GetService("TextChatService").MessageReceived:Connect(function(message)
						if message and message.Text then
							if message.Text:find("spawned in") then
								Nyx_processSpawnMessage(message.Text)
							end
						end
					end)
				end)
			end

			Nyx_EggDataUI.scanField()
			Nyx_EggDataUI.syncBackend()
			Nyx_EggDataUI.paint()
		end
		Nyx_EggDataUI.refresh = function()
			Nyx_EggDataUI.scanField()
			Nyx_EggDataUI.syncBackend()
			Nyx_EggDataUI.paint()
		end

		local Nyx_uiTabs = {
			"logs",
			"eggs",
			"inventory",
			"checker",
			"eggdata"
		}
		local Nyx_uiPanels = {
			logs = {
				name = "Egg Logs",
				w = 420,
				h = 500,
				build = function(parentFrame)
					return Nyx_buildEggLogsPanel(parentFrame)
				end
			},
			eggs = {
				name = "Egg Board",
				w = 420,
				h = 500,
				build = function(parentFrame)
					return Nyx_buildEggBoardPanel(parentFrame)
				end
			},
			inventory = {
				name = "Inventory & Base",
				w = 440,
				h = 510,
				build = function(parentFrame)
					return Nyx_buildInventoryPanel(parentFrame)
				end
			},
			checker = {
				name = "Egg Checker",
				w = 420,
				h = 500,
				build = function(parentFrame)
					return Nyx_EggCheckerUI.build(parentFrame)
				end
			},
			eggdata = {
				name = "Egg Data & History",
				w = 380,
				h = 570,
				build = function(parentFrame)
					return Nyx_EggDataUI.build(parentFrame)
				end
			}
		}

		local function Nyx_openPanelWindow(panelKey)
			Nyx_applyElevatedIdentity()

			local Nyx_panelConfig = Nyx_uiPanels[panelKey]

			if not Nyx_panelConfig then
				return
			end

			local name = "__SNE_Panel_" .. panelKey

			local function Nyx_getPlayerGui()
				local ok, result = pcall(function()
					return LocalPlayer:FindFirstChild("PlayerGui")
				end)
				local Nyx_playerGui = ok and result or nil

				return Nyx_playerGui
			end

			for _, v in ipairs({
				game:GetService("CoreGui"),
				Nyx_getPlayerGui()
			}) do
				if v then
					pcall(function()
						for _, descendant in ipairs(v:GetDescendants()) do
							if descendant.Name == name and descendant:IsA("ScreenGui") then
								pcall(function()
									descendant:Destroy()
								end)
							end
						end
					end)
				end
			end

			local Nyx_guiHost = Nyx_getUiHost()
			local ScreenGui = Instance.new("ScreenGui")

			ScreenGui.Name = name
			ScreenGui.ResetOnSpawn = false
			ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			ScreenGui.DisplayOrder = 99999
			ScreenGui.Parent = Nyx_guiHost

			local Nyx_getPlayerGui_var1 = 0

			for i, v in ipairs(Nyx_uiTabs) do
				if v == panelKey then
					Nyx_getPlayerGui_var1 = i - 1
				end
			end

			local Frame = Instance.new("Frame")

			Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			Frame.Size = UDim2.fromOffset(Nyx_panelConfig.w, Nyx_panelConfig.h)
			Frame.BackgroundTransparency = 1
			Frame.Active = true
			Frame.Parent = ScreenGui

			local UIScale = Instance.new("UIScale")

			UIScale.Name = "WindowScale"
			UIScale.Scale = 1
			UIScale.Parent = Frame

			local UserInputService = game:GetService("UserInputService")

			local function Nyx_fitPanelToViewport(initialLayout)
				local CurrentCamera = workspace.CurrentCamera
				local ViewportSize = CurrentCamera and CurrentCamera.ViewportSize or Vector2.new(1024, 768)

				if ViewportSize.X <= 0 or ViewportSize.Y <= 0 then
					return
				end

				local Nyx_isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled or ViewportSize.Y < 550
				local Nyx_fitScale = math.min(1, ViewportSize.X * (Nyx_isMobile and 0.86 or 0.94) / Nyx_panelConfig.w, ViewportSize.Y * (Nyx_isMobile and 0.88 or 0.92) / Nyx_panelConfig.h)

				if Nyx_isMobile and Nyx_fitScale > 0.82 then
					Nyx_fitScale = 0.82
				end

				UIScale.Scale = math.clamp(Nyx_fitScale, 0.48, 1)

				local Scale = UIScale.Scale
				local Nyx_scaledWidth = Nyx_panelConfig.w * Scale
				local Nyx_scaledHeight = Nyx_panelConfig.h * Scale

				if initialLayout then
					if Nyx_isMobile then
						local Nyx_mobileX = ViewportSize.X - math.floor(Nyx_scaledWidth / 2) - 14
						local Nyx_mobileY = math.floor(ViewportSize.Y / 2)

						Frame.Position = UDim2.fromOffset(Nyx_mobileX, Nyx_mobileY)
					else
						local Nyx_desktopYOffset = Nyx_getPlayerGui_var1 * 20

						Frame.Position = UDim2.fromOffset(math.floor(ViewportSize.X / 2 + Nyx_getPlayerGui_var1 * 24), math.floor(ViewportSize.Y / 2 + Nyx_desktopYOffset))
					end
				end

				local Nyx_halfScaledW = Nyx_scaledWidth / 2
				local Nyx_halfScaledH = Nyx_scaledHeight / 2
				local Nyx_clampXMin = math.min(Nyx_halfScaledW + 8, ViewportSize.X / 2)
				local Nyx_clampXMax = math.max(ViewportSize.X - Nyx_halfScaledW - 8, ViewportSize.X / 2)
				local Nyx_clampYMin = math.min(Nyx_halfScaledH + 8, ViewportSize.Y / 2)
				local Nyx_clampYMax = math.max(ViewportSize.Y - Nyx_halfScaledH - 8, ViewportSize.Y / 2)
				local Nyx_panelAbsoluteY = Frame.Position.Y.Scale * ViewportSize.Y + Frame.Position.Y.Offset
				local floor = math.floor

				Frame.Position = UDim2.fromOffset(math.floor(math.clamp(Frame.Position.X.Scale * ViewportSize.X + Frame.Position.X.Offset, Nyx_clampXMin, Nyx_clampXMax)), floor(math.clamp(Nyx_panelAbsoluteY, Nyx_clampYMin, Nyx_clampYMax)))
			end

			local ImageLabel = Instance.new("ImageLabel")

			ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			ImageLabel.Position = UDim2.fromScale(0.5, 0.5)
			ImageLabel.Size = UDim2.new(1, 40, 1, 40)
			ImageLabel.BackgroundTransparency = 1
			ImageLabel.Image = "rbxassetid://6015897843"
			ImageLabel.ImageColor3 = Nyx_buildAllUI_var1.shadow
			ImageLabel.ImageTransparency = 0.52
			ImageLabel.ScaleType = Enum.ScaleType.Slice
			ImageLabel.SliceCenter = Rect.new(49, 49, 450, 450)
			ImageLabel.ZIndex = 0
			ImageLabel.Parent = Frame

			local Frame2 = Instance.new("Frame")

			Frame2.Size = UDim2.fromScale(1, 1)
			Frame2.Position = UDim2.fromScale(0, 0)
			Frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Frame2.BackgroundTransparency = 0
			Frame2.BorderSizePixel = 0
			Frame2.ZIndex = 1
			Frame2.Parent = Frame
			Instance.new("UICorner", Frame2).CornerRadius = UDim.new(0, 8)

			local UIGradient = Instance.new("UIGradient", Frame2)

			UIGradient.Rotation = 16
			UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Nyx_buildAllUI_var1.obsTop),
				ColorSequenceKeypoint.new(0.52, Nyx_buildAllUI_var1.obsMid),
				ColorSequenceKeypoint.new(1, Nyx_buildAllUI_var1.obsLow)
			})

			local UIStroke = Instance.new("UIStroke", Frame2)

			UIStroke.Color = Nyx_buildAllUI_var1.strokeCol
			UIStroke.Thickness = 1
			UIStroke.Transparency = 0.72

			local TextLabel5 = Instance.new("TextLabel")

			TextLabel5.BackgroundTransparency = 1
			TextLabel5.Position = UDim2.fromOffset(42, 12)
			TextLabel5.Size = UDim2.fromOffset(200, 22)
			TextLabel5.Font = Enum.Font.GothamBold
			TextLabel5.TextSize = 16
			TextLabel5.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel5.TextColor3 = Nyx_buildAllUI_var1.text
			TextLabel5.Text = "Nyx"
			TextLabel5.Parent = Frame2

			local ImageLabel2 = Instance.new("ImageLabel")

			ImageLabel2.AnchorPoint = Vector2.new(0, 0.5)
			ImageLabel2.Position = UDim2.fromOffset(11, 23)
			ImageLabel2.Size = UDim2.fromOffset(20, 20)
			ImageLabel2.BackgroundTransparency = 1
			ImageLabel2.Image = "rbxassetid://96240498384290"
			ImageLabel2.ScaleType = Enum.ScaleType.Fit
			ImageLabel2.Parent = Frame2

			local Frame3 = Instance.new("Frame")

			Frame3.Position = UDim2.fromOffset(14, 44)
			Frame3.Size = UDim2.fromOffset(math.max(90, #Nyx_panelConfig.name * 8 + 26), 24)
			Frame3.BackgroundColor3 = Nyx_buildAllUI_var1.accent
			Frame3.BackgroundTransparency = 0.82
			Frame3.BorderSizePixel = 0
			Frame3.Parent = Frame2
			Instance.new("UICorner", Frame3).CornerRadius = UDim.new(0, 6)

			local UIStroke2 = Instance.new("UIStroke", Frame3)

			UIStroke2.Color = Nyx_buildAllUI_var1.accent
			UIStroke2.Thickness = 1
			UIStroke2.Transparency = 0.45

			local TextLabel6 = Instance.new("TextLabel")

			TextLabel6.BackgroundTransparency = 1
			TextLabel6.Size = UDim2.fromScale(1, 1)
			TextLabel6.Font = Enum.Font.GothamBold
			TextLabel6.TextSize = 12
			TextLabel6.TextColor3 = Nyx_buildAllUI_var1.text
			TextLabel6.Text = Nyx_panelConfig.name
			TextLabel6.Parent = Frame3

			local TextButton = Instance.new("TextButton")

			TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
			TextButton.Position = UDim2.new(0.5, 0, 1, -36)
			TextButton.Size = UDim2.fromOffset(176, 22)
			TextButton.BackgroundColor3 = Nyx_buildAllUI_var1.btnBg
			TextButton.BackgroundTransparency = 0.15
			TextButton.AutoButtonColor = false
			TextButton.Text = ""
			TextButton.Parent = Frame2
			Instance.new("UICorner", TextButton).CornerRadius = UDim.new(1, 6)

			local UIStroke3 = Instance.new("UIStroke", TextButton)

			UIStroke3.Color = Nyx_buildAllUI_var1.strokeCol
			UIStroke3.Thickness = 1
			UIStroke3.Transparency = 0.6

			local ImageLabel3 = Instance.new("ImageLabel")

			ImageLabel3.AnchorPoint = Vector2.new(0.5, 0.5)
			ImageLabel3.Position = UDim2.new(0, 12, 0.5, 0)
			ImageLabel3.Size = UDim2.fromOffset(12, 12)
			ImageLabel3.BackgroundTransparency = 1
			ImageLabel3.Image = "rbxassetid://94434236999817"
			ImageLabel3.ScaleType = Enum.ScaleType.Fit
			ImageLabel3.Parent = TextButton

			local TextLabel7 = Instance.new("TextLabel")

			TextLabel7.BackgroundTransparency = 1
			TextLabel7.Position = UDim2.fromOffset(24, 0)
			TextLabel7.Size = UDim2.new(1, -28, 1, 0)
			TextLabel7.Font = Enum.Font.GothamBold
			TextLabel7.TextSize = 12
			TextLabel7.TextXAlignment = Enum.TextXAlignment.Center
			TextLabel7.TextColor3 = Nyx_buildAllUI_var1.text
			TextLabel7.Text = "discord.gg/Nyxhub"
			TextLabel7.Parent = TextButton
			TextButton.MouseButton1Click:Connect(function()
				pcall(function()
					setclipboard("https://discord.gg/Nyxhub")
				end)
			end)

			local TextButton2 = Instance.new("TextButton")

			TextButton2.Position = UDim2.new(1, -36, 0, 8)
			TextButton2.Size = UDim2.fromOffset(26, 26)
			TextButton2.BackgroundColor3 = Nyx_buildAllUI_var1.btnBg
			TextButton2.BackgroundTransparency = 0.15
			TextButton2.AutoButtonColor = false
			TextButton2.Font = Enum.Font.GothamBold
			TextButton2.TextSize = 13
			TextButton2.TextColor3 = Nyx_buildAllUI_var1.btnText
			TextButton2.Text = "X"
			TextButton2.ZIndex = 5
			TextButton2.Parent = Frame2
			Instance.new("UICorner", TextButton2).CornerRadius = UDim.new(0, 4)

			local UIStroke4 = Instance.new("UIStroke", TextButton2)

			UIStroke4.Color = Nyx_buildAllUI_var1.strokeCol
			UIStroke4.Thickness = 1
			UIStroke4.Transparency = 0.6
			TextButton2.MouseButton1Click:Connect(function()
				Nyx_applyElevatedIdentity()
				ScreenGui.Enabled = false
			end)

			local Frame4 = Instance.new("Frame")

			Frame4.Position = UDim2.fromOffset(0, 72)
			Frame4.Size = UDim2.new(1, 0, 1, -120)
			Frame4.BackgroundTransparency = 1
			Frame4.BorderSizePixel = 0
			Frame4.Parent = Frame2

			local Nyx_fitPanelToViewport_var1 = false
			local Position
			local Position2

			local function Nyx_onDragStart(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Nyx_fitPanelToViewport_var1 = true
					Position = input.Position
					Position2 = Frame.Position
				end
			end

			TextLabel5.InputBegan:Connect(Nyx_onDragStart)
			Frame3.InputBegan:Connect(Nyx_onDragStart)
			Frame2.InputBegan:Connect(function(input)
				if input.Position.Y - Frame.AbsolutePosition.Y <= 44 * (UIScale and UIScale.Scale or 1) then
					Nyx_onDragStart(input)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if Nyx_fitPanelToViewport_var1 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local Nyx_dragDelta = input.Position - Position

					Frame.Position = UDim2.new(Position2.X.Scale, Position2.X.Offset + Nyx_dragDelta.X, Position2.Y.Scale, Position2.Y.Offset + Nyx_dragDelta.Y)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Nyx_fitPanelToViewport_var1 then
					Nyx_fitPanelToViewport_var1 = false
					pcall(Nyx_fitPanelToViewport, false)
				end
			end)
			Nyx_fitPanelToViewport(true)

			local CurrentCamera = workspace.CurrentCamera

			if CurrentCamera then
				CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
					if ScreenGui and ScreenGui.Parent and ScreenGui.Enabled then
						pcall(Nyx_fitPanelToViewport, false)
					end
				end)
			end

			windows[panelKey] = {
				gui = ScreenGui,
				page = Frame4,
				holder = Frame,
				fitScale = Nyx_fitPanelToViewport
			}
			pcall(function()
				Nyx_panelConfig.build(Frame4)
			end)
			pcall(function()
				Nyx_refreshPanelByKey(panelKey)
			end)
		end
		local function Nyx_openOrCreatePanel(panelKey)
			Nyx_applyElevatedIdentity()

			local Nyx_panelKey = panelKey or "logs"
			local Nyx_existingPanel = windows[Nyx_panelKey]

			if not Nyx_existingPanel or not Nyx_existingPanel.gui or not Nyx_existingPanel.gui.Parent then
				Nyx_openPanelWindow(Nyx_panelKey)

				return
			end

			Nyx_existingPanel.gui.Enabled = true

			if Nyx_existingPanel.fitScale then
				pcall(Nyx_existingPanel.fitScale, false)
			end

			pcall(function()
				Nyx_refreshPanelByKey(Nyx_panelKey)
			end)
		end
		local function Nyx_openAllPanels()
			for _, v in ipairs(Nyx_uiTabs) do
				Nyx_openOrCreatePanel(v)
			end
		end
		local function Nyx_closeAllPanels()
			for _, window in pairs(windows) do
				if window and window.gui then
					window.gui.Enabled = false
				end
			end
		end

		task.spawn(function()
			while Nyx_isCurrentSession() do
				pcall(function()
					local Nyx_fieldEggSnapshot2 = EggState2.ReadFieldEggs()

					if Nyx_fieldEggSnapshot2 and Nyx_fieldEggSnapshot2.Records then
						for _, record in ipairs(Nyx_fieldEggSnapshot2.Records) do
							Nyx_incrementEggLog(record)
						end
					end
				end)
				pcall(function()
					if Nyx_EggDataUI and type(Nyx_EggDataUI.scanField) == "function" then
						Nyx_EggDataUI.scanField()
					end
				end)

				for _, v in ipairs({
					"logs",
					"eggs",
					"inventory",
					"checker",
					"eggdata"
				}) do
					if Nyx_isWindowOpen(v) then
						pcall(Nyx_refreshPanelByKey, v)
					end
				end

				task.wait(2)
			end
		end)
		NyxPanels.windows = windows
		NyxPanels.openLogs = function()
			Nyx_openOrCreatePanel("logs")
		end
		NyxPanels.openBoard = function()
			Nyx_openOrCreatePanel("eggs")
		end
		NyxPanels.openInventory = function()
			Nyx_openOrCreatePanel("inventory")
		end
		NyxPanels.openChecker = function()
			Nyx_openOrCreatePanel("checker")
		end
		NyxPanels.openAnalyst = function()
			Nyx_openOrCreatePanel("eggdata")
		end
		NyxPanels.openAll = function()
			Nyx_openAllPanels()
		end
		NyxPanels.closeAll = function()
			Nyx_closeAllPanels()
		end
		pcall(function()
			getgenv().NyxPanels = NyxPanels
		end)
	end

	Nyx_buildAllUI()

	local function Nyx_buildMainWindow()
		pcall(function()
			local ChloeX_Instance = genv.ChloeX_Instance

			if type(ChloeX_Instance) == "table" and type(ChloeX_Instance.DestroyGui) == "function" then
				ChloeX_Instance:DestroyGui()
			end
		end)
		genv.ChloeX_Running = nil
		genv.ChloeX_ReopenPrompt = nil
		genv.ChloeX_Instance = nil

		local NyxLibOverride = genv.NyxLibOverride

		do
			if type(NyxLibOverride) ~= "table" then
				local ok, result = pcall(function()
					return loadstring(game:HttpGet("https://raw.githubusercontent.com/NyxDev32/NyxHub/refs/heads/main/Nyx_Ui.lua"))()
				end)

				NyxLibOverride = ok and type(result) == "table" and result or nil
			end
		end

		if not NyxLibOverride then
			warn("[Nyx] UI library failed to load")

			return
		end

		local function Nyx_cleanList(list)
			local Nyx_cleanList_var1 = {}
			local ipairs_ = ipairs
			local Nyx_listToClean = type(list) == "table" and list or {}

			for _, v in ipairs_(Nyx_listToClean) do
				if v ~= "None" and v ~= "" then
					Nyx_cleanList_var1[#Nyx_cleanList_var1 + 1] = v
				end
			end

			return Nyx_cleanList_var1
		end
		local function Nyx_getAllRarities()
			local Nyx_getAllRarities_var1 = {}

			pcall(function()
				for _, v in ipairs(Nyx_catalog.getRarities()) do
					Nyx_getAllRarities_var1[#Nyx_getAllRarities_var1 + 1] = v
				end
			end)

			if #Nyx_getAllRarities_var1 == 0 then
				Nyx_getAllRarities_var1 = {
					"Common",
					"Uncommon",
					"Rare",
					"Epic",
					"Legendary",
					"Mythic",
					"Cosmic",
					"Secret",
					"Eternal",
					"Divine"
				}
			end

			return Nyx_getAllRarities_var1
		end
		local function Nyx_prependAll(list)
			local Nyx_prependAll_var3 = { "All" }

			for _, v in ipairs(list) do
				if v ~= "All" then
					Nyx_prependAll_var3[#Nyx_prependAll_var3 + 1] = v
				end
			end

			return Nyx_prependAll_var3
		end

		local Nyx_mutationOptions = {}

		pcall(function()
			for _, v in ipairs(Nyx_catalog.getMutations()) do
				Nyx_mutationOptions[#Nyx_mutationOptions + 1] = v
			end
		end)

		if #Nyx_mutationOptions == 0 then
			Nyx_mutationOptions = {
				"Golden",
				"Rainbow",
				"Shocked",
				"Frozen",
				"Burnt",
				"Boss"
			}
		end

		local Nyx_rarityOptionsAll = { "None" }

		if not pcall(function()
			local Directory = require(game:GetService("ReplicatedStorage").Data.Areas).Directory
			local ok, result = pcall(function()
				return require(game:GetService("ReplicatedStorage").Data.Assets)
			end)

			if ok and result and result.Directory then
				local Directory2 = result.Directory
				local Nyx_prependAll_var4 = {}

				for _, v in pairs(Directory) do
					if type(v) == "table" and type(v.DropTable) == "table" then
						for _, Nyx_item in ipairs(v.DropTable) do
							local Nyx_dropEntry = Nyx_item[1]

							if type(Nyx_dropEntry) == "string" and not Nyx_prependAll_var4[Nyx_dropEntry] then
								Nyx_prependAll_var4[Nyx_dropEntry] = true

								local Nyx_dropAssetDef = Directory2[Nyx_dropEntry]

								Nyx_rarityOptionsAll[#Nyx_rarityOptionsAll + 1] = Nyx_dropAssetDef and Nyx_dropAssetDef.DisplayName or Nyx_dropEntry
							end
						end
					end
				end
			end
		end) or #Nyx_rarityOptionsAll <= 1 then
			Nyx_rarityOptionsAll = { "None" }
		end

		table.sort(Nyx_rarityOptionsAll, function(entryA, entryB)
			if entryA == "None" then
				return true
			end

			if entryB == "None" then
				return false
			end

			return entryA < entryB
		end)

		local Nyx_areaOptions = { "None" }

		do
			local Nyx_knownAreas = {
				"Lake",
				"Jungle",
				"Desert",
				"Snow",
				"Volcano",
				"Abyss Ocean",
				"Prehistoric",
				"Cosmic",
				"Cherry Blossom",
				"Titan Temple"
			}
			local Nyx_areaSet = {}

			if not pcall(function()
				for k, v in pairs(require(game:GetService("ReplicatedStorage").Data.Areas).Directory) do
					if type(v) == "table" and type(v.DropTable) == "table" then
						Nyx_areaSet[k] = true
					end
				end
			end) or next(Nyx_areaSet) == nil then
				for _, v in ipairs(Nyx_knownAreas) do
					Nyx_areaSet[v] = true
				end
			end

			local Nyx_excludedAreas = {
				None = true,
				Forest = true,
				["Titan Temple"] = true
			}

			for _, v in ipairs(Nyx_knownAreas) do
				if v ~= "Titan Temple" and Nyx_areaSet[v] then
					table.insert(Nyx_areaOptions, v)
					Nyx_excludedAreas[v] = true
				end
			end

			local Nyx_otherAreas = {}

			for k in pairs(Nyx_areaSet) do
				if not Nyx_excludedAreas[k] then
					table.insert(Nyx_otherAreas, k)
				end
			end

			table.sort(Nyx_otherAreas)

			for _, v in ipairs(Nyx_otherAreas) do
				table.insert(Nyx_areaOptions, v)
			end

			if Nyx_areaSet["Titan Temple"] then
				table.insert(Nyx_areaOptions, "Titan Temple")
			end
		end

		Nyx_AutoLoops.AutoPlaceLoop = function()
			if NyxConfig.IsAutoPlaceWorkerRunning then
				return
			end

			NyxConfig.IsAutoPlaceWorkerRunning = true

			while NyxConfig.AutoPlace and Nyx_isCurrentSession() do
				task.wait(1.5)

				local ok, result = pcall(function()
					if NyxConfig.IsStealing then
						return
					end

					local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

					game:GetService("HttpService")

					local EggState2 = require(ReplicatedStorage2.Client.EggState)
					local Assets = require(ReplicatedStorage2.Data.Assets)
					local Nyx_localPlot
					local Plots = workspace:FindFirstChild("Plots")

					if Plots then
						local Nyx_plotsIter, Nyx_plotsIterState, Nyx_plotsIterControl = ipairs(Plots:GetChildren())
						local Nyx_plotsIterator = geniter(Nyx_plotsIter, Nyx_plotsIterState, Nyx_plotsIterControl)

						while true do
							local Nyx_plotsPack = table.pack(Nyx_plotsIterator())

							if not Nyx_plotsPack[1] then
								break
							end

							local Nyx_plotChild = Nyx_plotsPack[3]
							local PlotSign = Nyx_plotChild:FindFirstChild("PlotSign")

							if PlotSign then
								local PlayerPlotSign = PlotSign:FindFirstChild("PlayerPlotSign")

								if PlayerPlotSign and PlayerPlotSign:FindFirstChild("Frame") then
									if PlayerPlotSign.Frame:FindFirstChild("PlayerName") then
										local Nyx_plotPlayerName = string.gsub(PlayerPlotSign.Frame.PlayerName.Text, "<[^>]+>", "")

										if string.find(string.lower(Nyx_plotPlayerName), string.lower(LocalPlayer.Name)) or string.find(string.lower(Nyx_plotPlayerName), string.lower(LocalPlayer.DisplayName)) then
											Nyx_localPlot = Nyx_plotChild

											break
										end
									end
								end
							end
						end
					end

					if not Nyx_localPlot then
						return
					end

					local ToUpdate = Nyx_localPlot:FindFirstChild("ToUpdate")
					local PetArea = ToUpdate and ToUpdate:FindFirstChild("PetArea")
					local CenterPoint = Nyx_localPlot:FindFirstChild("CenterPoint") or PetArea

					if not PetArea then
						return
					end

					local Nyx_prependAll_var5 = {}
					local Nyx_ownedEggsList = EggState2.GetOwnerRuntimeRecords(LocalPlayer.UserId)
					local Nyx_prependAll_var1 = 0

					if type(Nyx_ownedEggsList) == "table" then
						local Nyx_ownedEggsIter, Nyx_ownedEggsIterState, Nyx_ownedEggsIterControl = pairs(Nyx_ownedEggsList)

						for k, v in Nyx_ownedEggsIter, Nyx_ownedEggsIterState, Nyx_ownedEggsIterControl do
							if v.Placement == nil then
								local AssetCategory = v.AssetCategory
								local Nyx_ownedEggAssetDef = AssetCategory and Assets.Directory[AssetCategory]
								local Nyx_prependAll_var2 = "Unknown"

								if Nyx_ownedEggAssetDef and Nyx_ownedEggAssetDef.Rarity then
									local Rarity = Nyx_ownedEggAssetDef.Rarity

									Nyx_prependAll_var2 = Rarity.DisplayName or Rarity._id or Rarity.Name or "Unknown"
								end

								local Nyx_placeRarityMatch

								if #NyxConfig.PlaceRarities == 0 or table.find(NyxConfig.PlaceRarities, "None") or table.find(NyxConfig.PlaceRarities, "All") then
									Nyx_placeRarityMatch = true
								else
									Nyx_placeRarityMatch = table.find(NyxConfig.PlaceRarities, Nyx_prependAll_var2) ~= nil
								end

								local Nyx_ownedEggWeightRaw = tonumber(v.Kg) or tonumber(v.Weight) or tonumber(v.kg)

								if not Nyx_ownedEggWeightRaw and Nyx_ownedEggAssetDef then
									Nyx_ownedEggWeightRaw = tonumber(Nyx_ownedEggAssetDef.Kg) or tonumber(Nyx_ownedEggAssetDef.Weight) or tonumber(Nyx_ownedEggAssetDef.kg)
								end

								local Nyx_ownedEggWeightKg = Nyx_ownedEggWeightRaw or 0

								if Nyx_placeRarityMatch then
									table.insert(Nyx_prependAll_var5, {
										Uid = k,
										Rarity = Nyx_prependAll_var2,
										Kg = Nyx_ownedEggWeightKg
									})
								end
							else
								Nyx_prependAll_var1 += 1
							end
						end
					end

					table.sort(Nyx_prependAll_var5, function(entryA, entryB)
						return entryA.Kg > entryB.Kg
					end)

					local Character = LocalPlayer.Character

					if Character then
						Character:FindFirstChild("HumanoidRootPart")
					end

					if Character then
						Character:FindFirstChildOfClass("Humanoid")
					end

					local CFrame_2

					if #Nyx_prependAll_var5 == 0 or Nyx_prependAll_var1 >= 30 then
						return
					end

					local function Nyx_isStealWantsCharacter()
						local __NyxStealWantsCharacter = genv.__NyxStealWantsCharacter

						if __NyxStealWantsCharacter and __NyxStealWantsCharacter() then
							return true
						end

						local __NyxDronesWantCharacter = genv.__NyxDronesWantCharacter

						return __NyxDronesWantCharacter ~= nil and __NyxDronesWantCharacter() == true
					end

					if NyxConfig.IsStealing or Nyx_isStealWantsCharacter() then
						return
					end

					NyxConfig.IsPlacing = true

					local __NyxTreadmillManager = genv.__NyxTreadmillManager

					if __NyxTreadmillManager and __NyxTreadmillManager.activeTreadmill ~= nil then
						local Nyx_treadmillWaitDeadline = os.clock() + 5

						while __NyxTreadmillManager.activeTreadmill ~= nil and os.clock() < Nyx_treadmillWaitDeadline do
							pcall(function()
								__NyxTreadmillManager:_requestUnequip()
							end)
							task.wait(0.3)
						end
					end

					local Character2 = LocalPlayer.Character
					local HumanoidRootPart = Character2 and Character2:FindFirstChild("HumanoidRootPart")
					local Humanoid = Character2 and Character2:FindFirstChildOfClass("Humanoid")

					if HumanoidRootPart and HumanoidRootPart.Anchored then
						pcall(function()
							HumanoidRootPart.Anchored = false
						end)
					end

					if Humanoid then
						pcall(function()
							Humanoid:UnequipTools()
						end)
					end

					if HumanoidRootPart then
						CFrame_2 = HumanoidRootPart.CFrame
					end

					local function Nyx_isAutoPlaceCancelled()
						return not NyxConfig.AutoPlace or NyxConfig.IsStealing or Nyx_isStealWantsCharacter()
					end

					if HumanoidRootPart then
						local Nyx_petAreaCF = PetArea.CFrame * cFrameNew(0, 3, 0)

						if not Nyx_hasLineOfSight(HumanoidRootPart.Position + Vector3.new(0, 2, 0), Nyx_petAreaCF.Position + Vector3.new(0, 2, 0), Character2) then
							Nyx_glideTo(HumanoidRootPart, Humanoid, cFrameNew(518.66, 70.57, -364.73) * Angles(3.1415926535897931, -1.5676547341413067, 3.1415926535897931), Nyx_isAutoPlaceCancelled)

							if Nyx_isAutoPlaceCancelled() then
								return
							end
						end

						Nyx_glideTo(HumanoidRootPart, Humanoid, Nyx_petAreaCF, Nyx_isAutoPlaceCancelled)

						if Nyx_isAutoPlaceCancelled() then
							return
						end

						local Nyx_isAutoPlaceCancelled_var1 = 0

						while Nyx_isAutoPlaceCancelled_var1 < 0.5 and not Nyx_isAutoPlaceCancelled() do
							task.wait(0.05)
							Nyx_isAutoPlaceCancelled_var1 += 0.05
						end

						if Nyx_isAutoPlaceCancelled() then
							return
						end
					end

					local Nyx_plotFull = false
					local Nyx_isAutoPlaceCancelled_var3 = {}
					local Nyx_ownedEggsIter2, Nyx_ownedEggsIterState2, Nyx_ownedEggsIterControl2 = pairs(Nyx_ownedEggsList)

					for _, v in Nyx_ownedEggsIter2, Nyx_ownedEggsIterState2, Nyx_ownedEggsIterControl2 do
						if v.Placement then
							local Position

							if typeof(v.Placement) == "CFrame" then
								Position = v.Placement.Position
							elseif typeof(v.Placement) == "Vector3" then
								Position = v.Placement
							else
								Position = v.Placement.Position or Position
							end

							if Position then
								table.insert(Nyx_isAutoPlaceCancelled_var3, Position)
							end
						end
					end

					local Nyx_isAutoPlaceCancelled_var2 = 0
					local Nyx_placeEggsIter, Nyx_placeEggsIterState, Nyx_placeEggsIterControl = ipairs(Nyx_prependAll_var5)

					for _, v in Nyx_placeEggsIter, Nyx_placeEggsIterState, Nyx_placeEggsIterControl do
						if not NyxConfig.AutoPlace or Nyx_plotFull then
							break
						end

						if Nyx_prependAll_var1 >= 30 then
							break
						end

						if Nyx_isAutoPlaceCancelled() then
							return
						end

						local Uid = v.Uid
						local Nyx_placeEggRecord = EggState2.GetOwnerRuntimeRecords(LocalPlayer.UserId)[Uid]
						local Nyx_equipToolOk = EggState2.RequestEquipTool(Uid)

						if not Nyx_equipToolOk then
							continue
						end

						if Nyx_isAutoPlaceCancelled() then
							return
						end

						task.wait(0.15)

						local Nyx_placedSuccessfully = false

						while Nyx_isAutoPlaceCancelled_var2 < 30 and not Nyx_placedSuccessfully do
							local Nyx_placeTargetCF

							if CenterPoint then
								while Nyx_isAutoPlaceCancelled_var2 < 30 do
									local Nyx_petAreaWidth = PetArea.Size.X - 6
									local Nyx_placeCellSize = Nyx_petAreaWidth / 10
									local Nyx_placeCandidateLocal = CenterPoint.CFrame:PointToObjectSpace(PetArea.CFrame * Vector3.new(-(Nyx_petAreaWidth / 2) + Nyx_placeCellSize / 2 + Nyx_isAutoPlaceCancelled_var2 % 10 * Nyx_placeCellSize, 0, -((PetArea.Size.Z - 6) / 2) + 3 + math.floor(Nyx_isAutoPlaceCancelled_var2 / 10) * 6))
									local cFrame = cFrameNew(Nyx_placeCandidateLocal.X, -0.5, Nyx_placeCandidateLocal.Z)
									local Nyx_placeSlotOccupied = false

									for _, Nyx_item in ipairs(Nyx_isAutoPlaceCancelled_var3) do
										if (Nyx_item - cFrame.Position).Magnitude < 1 then
											Nyx_placeSlotOccupied = true

											break
										end
									end

									if not Nyx_placeSlotOccupied then
										Nyx_placeTargetCF = cFrame

										break
									end

									Nyx_isAutoPlaceCancelled_var2 += 1
								end
							end

							if not Nyx_placeTargetCF then
								Nyx_plotFull = true

								break
							end

							if Nyx_isAutoPlaceCancelled() then
								return
							end

							local Nyx_requestPlaceOk, Nyx_requestPlaceErr = EggState2.RequestPlaceEgg(Uid, Nyx_placeTargetCF)

							if Nyx_requestPlaceOk then
								table.insert(Nyx_isAutoPlaceCancelled_var3, Nyx_placeTargetCF.Position)
								Nyx_prependAll_var1 += 1
								Nyx_placedSuccessfully = true
								task.wait(0.15)

								continue
							end

							local Nyx_requestPlaceErrLower = Nyx_requestPlaceErr and string.lower(tostring(Nyx_requestPlaceErr)) or ""

							if not string.find(Nyx_requestPlaceErrLower, "full") and not string.find(Nyx_requestPlaceErrLower, "limit") and not string.find(Nyx_requestPlaceErrLower, "capacity") and not string.find(Nyx_requestPlaceErrLower, "maximum") then
								table.insert(Nyx_isAutoPlaceCancelled_var3, Nyx_placeTargetCF.Position)
								Nyx_isAutoPlaceCancelled_var2 += 1
								task.wait(0.1)

								continue
							end

							if NyxConfig.AutoPlace then
								NyxConfig.AutoPlace = false
							end

							Nyx_plotFull = true

							break
						end
					end

					if CFrame_2 and HumanoidRootPart and not Nyx_isAutoPlaceCancelled() then
						if not Nyx_hasLineOfSight(HumanoidRootPart.Position + Vector3.new(0, 2, 0), CFrame_2.Position + Vector3.new(0, 2, 0), Character2) then
							Nyx_glideTo(HumanoidRootPart, Humanoid, cFrameNew(518.66, 70.57, -364.73) * Angles(3.1415926535897931, -1.5676547341413067, 3.1415926535897931), Nyx_isAutoPlaceCancelled)
						end

						if Nyx_isAutoPlaceCancelled() then
							return
						end

						Nyx_glideTo(HumanoidRootPart, Humanoid, CFrame_2, Nyx_isAutoPlaceCancelled)
						task.wait(0.2)
					end
				end)

				NyxConfig.IsPlacing = false

				if not ok then
					warn("Auto Place Error: " .. tostring(result))
				end
			end

			NyxConfig.IsAutoPlaceWorkerRunning = false
		end

		do
			Nyx_AutoLoops.AutoHatchLoop = function()
				if NyxConfig.IsAutoHatchWorkerRunning then
					return
				end

				NyxConfig.IsAutoHatchWorkerRunning = true
				task.spawn(function()
					local Nyx_isAutoPlaceCancelled_var4 = {}

					while NyxConfig.AutoHatch and Nyx_isCurrentSession() do
						task.wait(1.5)
						pcall(function()
							local EggState2 = require(game:GetService("ReplicatedStorage").Client.EggState)
							local Nyx_ownedEggsRuntime = EggState2.GetOwnerRuntimeRecords(LocalPlayer.UserId)

							if not Nyx_ownedEggsRuntime then
								return
							end

							local Nyx_isAutoPlaceCancelled_var5 = {}

							for k, v in pairs(Nyx_ownedEggsRuntime) do
								if v.Placement ~= nil then
									table.insert(Nyx_isAutoPlaceCancelled_var5, k)
								end
							end

							local now = os.time()

							for _, v in ipairs(Nyx_isAutoPlaceCancelled_var5) do
								if not NyxConfig.AutoHatch then
									break
								end

								if not Nyx_isAutoPlaceCancelled_var4[v] or not (now < Nyx_isAutoPlaceCancelled_var4[v]) then
									local Nyx_hatchRecord = Nyx_ownedEggsRuntime[v]
									local Nyx_eggReadyToHatch = false

									if type(EggState2.IsReadyToHatch) == "function" then
										local ok, result = pcall(EggState2.IsReadyToHatch, v)

										Nyx_eggReadyToHatch = ok and result == true
									end

									if Nyx_eggReadyToHatch or Nyx_hatchRecord.Ready == true or not Nyx_isAutoPlaceCancelled_var4[v] then
										if EggState2.RequestHatchEgg(v) then
											EggState2.RequestCompleteHatchEgg(v)
											Nyx_isAutoPlaceCancelled_var4[v] = nil
											task.wait(0.1)
										else
											Nyx_isAutoPlaceCancelled_var4[v] = now + 10
										end
									end
								end
							end
						end)
					end

					NyxConfig.IsAutoHatchWorkerRunning = false
				end)
			end
		end

		do
			local Nyx_isAutoPlaceCancelled_var6 = false

			Nyx_AutoLoops.mutationSweep = function()
				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				local EggState2 = require(ReplicatedStorage2.Client.EggState)
				local Remotes = require(ReplicatedStorage2.Shared.Remotes)
				local Directory

				pcall(function()
					local Assets = require(ReplicatedStorage2.Data.Assets)

					Directory = Assets.Directory or Assets
				end)

				local function Nyx_getMutationSpeciesName(record)
					local Category = record.Category or record.AssetCategory
					local Nyx_mutationAssetDef = Directory and Category and Directory[Category]

					return Nyx_mutationAssetDef and Nyx_mutationAssetDef.DisplayName or Category
				end
				local function Nyx_getMutationRarityName(record)
					local Category = record.Category or record.AssetCategory
					local Nyx_mutationAssetDef2 = Directory and Category and Directory[Category]
					local Rarity = Nyx_mutationAssetDef2 and Nyx_mutationAssetDef2.Rarity

					return Rarity and (Rarity.DisplayName or Rarity._id) or nil
				end
				local function Nyx_isAutoMutationBlocked()
					if NyxConfig.IsStealing == true or NyxConfig.IsPlacing == true then
						return true
					end

					local __NyxStealWantsCharacter = genv.__NyxStealWantsCharacter

					if __NyxStealWantsCharacter and __NyxStealWantsCharacter() then
						return true
					end

					local __NyxDronesWantCharacter = genv.__NyxDronesWantCharacter

					if __NyxDronesWantCharacter ~= nil and __NyxDronesWantCharacter() == true then
						return true
					end

					return false
				end

				local Nyx_mutationIdTarget = NyxConfig.MutationChoice == "Fractured" and "Boss" or "Scrambled"

				local function Nyx_findMutationConsumable()
					for _, v in ipairs({
						LocalPlayer.Character,
						LocalPlayer:FindFirstChildOfClass("Backpack")
					}) do
						if not v then
							continue
						end

						for _, child in ipairs(v:GetChildren()) do
							if child:IsA("Tool") and child:GetAttribute("ItemType") == "MutationConsumable" and child:GetAttribute("MutationId") == Nyx_mutationIdTarget then
								return child
							end
						end
					end

					return nil
				end
				local function Nyx_hasMutationAlready(record)
					local Mutations = record and record.Mutations

					if Mutations == nil then
						return false
					end

					if type(Mutations) ~= "table" then
						return tostring(Mutations):find(Nyx_mutationIdTarget) ~= nil
					end

					for _, Mutation in ipairs(Mutations) do
						if Mutation == Nyx_mutationIdTarget then
							return true
						end
					end

					for k, Mutation in pairs(Mutations) do
						if k == Nyx_mutationIdTarget or Mutation == Nyx_mutationIdTarget then
							return true
						end
					end

					return false
				end

				if Nyx_isAutoMutationBlocked() then
					return
				end

				local Nyx_mutationConsumable = Nyx_findMutationConsumable()

				if not Nyx_mutationConsumable then
					if not Nyx_isAutoPlaceCancelled_var6 then
						warn("[AutoMutation] " .. tostring(NyxConfig.MutationChoice or "Scrambled") .. " consumable habis / gak ada di inventory - ronde di-skip.")
						Nyx_isAutoPlaceCancelled_var6 = true
					end

					return
				end

				Nyx_isAutoPlaceCancelled_var6 = false

				local Character = LocalPlayer.Character
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

				if not Humanoid then
					return
				end

				if not Character:FindFirstChild(Nyx_mutationConsumable.Name) then
					pcall(function()
						Humanoid:EquipTool(Nyx_mutationConsumable)
					end)
					task.wait(0.15)
				end

				local Nyx_ownedEggsForMutation = EggState2.GetOwnerRuntimeRecords(LocalPlayer.UserId)

				if type(Nyx_ownedEggsForMutation) ~= "table" then
					return
				end

				local MutationSpecies = NyxConfig.MutationSpecies
				local Nyx_hasSpeciesFilter = type(MutationSpecies) == "table" and #MutationSpecies > 0
				local MutationRarities = NyxConfig.MutationRarities
				local Nyx_hasRarityFilter3 = type(MutationRarities) == "table" and #MutationRarities > 0

				for k, v in pairs(Nyx_ownedEggsForMutation) do
					if not Nyx_isAutoMutationBlocked() then
						if type(v) ~= "table" or v.Placement == nil or Nyx_hasMutationAlready(v) then
							continue
						end

						local Category = v.Category or v.AssetCategory
						local Nyx_eggSpeciesName = Nyx_getMutationSpeciesName(v)
						local Nyx_speciesFilterPass = true

						if Nyx_hasSpeciesFilter then
							Nyx_speciesFilterPass = false

							local Nyx_speciesFilterIter, Nyx_speciesFilterIterState, Nyx_speciesFilterIterControl = ipairs(MutationSpecies)
							local Nyx_speciesFilterIterator = geniter(Nyx_speciesFilterIter, Nyx_speciesFilterIterState, Nyx_speciesFilterIterControl)

							while true do
								local Nyx_speciesFilterPack = table.pack(Nyx_speciesFilterIterator())

								if Nyx_speciesFilterPack[1] then
									local Nyx_speciesFilterEntry = Nyx_speciesFilterPack[3]

									if Nyx_speciesFilterEntry == Nyx_eggSpeciesName or Nyx_speciesFilterEntry == Category then
										Nyx_speciesFilterPass = true

										break
									end
								else
									break
								end
							end
						end

						if Nyx_speciesFilterPass and Nyx_hasRarityFilter3 then
							local Nyx_eggRarityName = Nyx_getMutationRarityName(v)

							Nyx_speciesFilterPass = false

							local Nyx_rarityFilterIter, Nyx_rarityFilterIterState, Nyx_rarityFilterIterControl = ipairs(MutationRarities)
							local Nyx_rarityFilterIterator = geniter(Nyx_rarityFilterIter, Nyx_rarityFilterIterState, Nyx_rarityFilterIterControl)

							while true do
								local Nyx_rarityFilterPack = table.pack(Nyx_rarityFilterIterator())

								if Nyx_rarityFilterPack[1] then
									if Nyx_rarityFilterPack[3] == Nyx_eggRarityName then
										Nyx_speciesFilterPass = true

										break
									end
								else
									break
								end
							end
						end

						if not Nyx_speciesFilterPass then
							continue
						end

						local Nyx_mutationConsumableNow = Nyx_findMutationConsumable()

						if Nyx_mutationConsumableNow then
							if not Character:FindFirstChild(Nyx_mutationConsumableNow.Name) then
								pcall(function()
									Humanoid:EquipTool(Nyx_mutationConsumableNow)
								end)
								task.wait(0.1)
							end

							local Nyx_hasMutationAlready_var1 = 0
							local Nyx_mutationApplied = false

							while not Nyx_isAutoMutationBlocked() and Nyx_findMutationConsumable() ~= nil do
								local ok, result = pcall(function()
									return Remotes.BossMastery.AskUseMutationConsumable:InvokeServer(k)
								end)

								Nyx_hasMutationAlready_var1 += 1

								if ok and type(result) == "table" then
									if result.Mutated == true then
										Nyx_mutationApplied = true
									end

									if result.Success == true then
										task.wait(0.25)

										if not Nyx_mutationApplied and NyxConfig.MutationRetry and not (Nyx_hasMutationAlready_var1 >= 40) then
											continue
										end
									end
								end

								break
							end

							continue
						end
					end

					break
				end
			end
		end

		do
			Nyx_AutoLoops.AutoMutationLoop = function()
				if NyxConfig.IsAutoMutationWorkerRunning then
					return
				end

				NyxConfig.IsAutoMutationWorkerRunning = true
				task.spawn(function()
					while NyxConfig.AutoMutation and Nyx_isCurrentSession() do
						task.wait(1)
						pcall(Nyx_AutoLoops.mutationSweep)
					end

					NyxConfig.IsAutoMutationWorkerRunning = false
				end)
			end
		end

		do
			Nyx_AutoLoops.RingEventLoop = function()
				if not NyxConfig.IsRingEventRunning then
					NyxConfig.IsRingEventRunning = true
					task.spawn(function()
						local cFrame = cFrameNew(544.76, 71.5, -416.48)
						local cFrame2 = cFrameNew(602, 70.78, -372)
						local cFrame3 = cFrameNew(5573, 70.77, -363)

						local function Nyx_isRingEventCancelled()
							return not NyxConfig.AutoRingEvent or not Nyx_isCurrentSession()
						end
						local function Nyx_ringEventGotoPos(targetPos)
							if Nyx_isRingEventCancelled() then
								return false
							end

							local Character = LocalPlayer.Character
							local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
							local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

							if not HumanoidRootPart or not Humanoid then
								task.wait(0.3)

								return not Nyx_isRingEventCancelled()
							end

							Nyx_glideTo(HumanoidRootPart, Humanoid, targetPos, Nyx_isRingEventCancelled, false, nil, true)

							return not Nyx_isRingEventCancelled()
						end

						while true do
							if not Nyx_isRingEventCancelled() and Nyx_ringEventGotoPos(cFrame) then
								if not Nyx_ringEventGotoPos(cFrame2) then
									break
								elseif Nyx_ringEventGotoPos(cFrame3) and Nyx_ringEventGotoPos(cFrame2) then
									continue
								end

								break
							end

							break
						end

						NyxConfig.IsRingEventRunning = false
					end)

					return
				end
			end
		end

		local Nyx_petNameFilterRef
		local Nyx_petRarityFilterRef
		local Nyx_eggRarityFilterRef
		local Nyx_nameFilterOptions, Nyx_areaFilterOptions, Nyx_rarityFilterOptions, Nyx_petNameOptions, Nyx_setAutoSteal, Nyx_setStealHold, Nyx_setGodMode, Nyx_setAutoTreadmillIdle, Nyx_setAntiTreadmill, Nyx_setHopNoMatch
		local Nyx_setPrivateServerMax, Nyx_setPrivateServerAuto, Nyx_setHopCooldown, Nyx_setAutoTreadmillUpgrade, Nyx_setStealMode, Nyx_setTweenSpeedSlider, Nyx_setStealFilter, Nyx_setStealValue, Nyx_setStealMutations, Nyx_setStealWeight
		local Nyx_setStealPriority, Nyx_setEggEsp, Nyx_setEspDetails, Nyx_setScrambleBanners, Nyx_setBackpackRates, Nyx_setAntiGuardKnockback, Nyx_setAutoFavorite, Nyx_setFavoriteRule, Nyx_setFavoriteRarities, Nyx_setFavoriteSpecies
		local Nyx_setAutoEquipBest, Nyx_setAutoClaimOffline, Nyx_setAutoBaseUpgrade, Nyx_setAutoClaimAlmanac, Nyx_setAutoFusePets, Nyx_setFuseRule, Nyx_setFuseRarities, Nyx_setFuseSpecies, Nyx_setNoclip, Nyx_setBottingMode
		local Nyx_setAntiCutscene, runOnce, Nyx_setScrambleAutoBuy, Nyx_setScrambleBuyList, Nyx_setAutoPlace, Nyx_setAutoHatch, Nyx_setAutoMutation, Nyx_setAutoRingEvent, Nyx_setMutationChoice, Nyx_setMutationSpecies
		local Nyx_setMutationRarities, Nyx_setMutationRetry, Nyx_setAutoSell, Nyx_setAutoSellEgg, Nyx_setSellPetMaxRate, Nyx_setSellEggMaxRate

		do
			local AssetEarnings

			local function Nyx_getRatePerSecond(record)
				if AssetEarnings == nil then
					pcall(function()
						AssetEarnings = require(game:GetService("ReplicatedStorage").Shared.Util.AssetEarnings)
					end)
				end

				if not AssetEarnings then
					return 0
				end

				for _, v in ipairs({
					AssetEarnings.LiveRatePerSecond,
					AssetEarnings.RatePerSecond,
					AssetEarnings.CatalogRatePerSecond
				}) do
					if type(v) == "function" then
						local ok, result = pcall(v, record)

						if not ok or not (type(result) == "number" and result > 0) then
							continue
						end

						return result
					end
				end

				return 0
			end
			local function Nyx_parseValueInput(valueInput)
				local Nyx_cleanedValueInput = string.lower(tostring(valueInput or "")):gsub("[%s,]", "")

				if Nyx_cleanedValueInput == "" then
					return 0
				end

				local Nyx_parsedValueNum, Nyx_parsedValueUnit = string.match(Nyx_cleanedValueInput, "^([%d]+%.?[%d]*)([kmb]?)$")
				local Nyx_parsedValueRaw = tonumber(Nyx_parsedValueNum)

				if not Nyx_parsedValueRaw then
					return 0
				end

				local Nyx_parseValueInput_var1 = 1

				if Nyx_parsedValueUnit == "k" then
					Nyx_parseValueInput_var1 = 1000
				elseif Nyx_parsedValueUnit == "m" then
					Nyx_parseValueInput_var1 = 1000000
				elseif Nyx_parsedValueUnit == "b" then
					Nyx_parseValueInput_var1 = 1e9
				end

				return Nyx_parsedValueRaw * Nyx_parseValueInput_var1
			end

			local Nyx_parseValueInput_var2 = false

			Nyx_AutoLoops.startAutoSellLoop = function()
				if Nyx_parseValueInput_var2 then
					return
				end

				Nyx_parseValueInput_var2 = true
				task.spawn(function()
					local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
					local Assets = require(ReplicatedStorage2.Data.Assets)
					local Save = require(ReplicatedStorage2.Shared.Save)
					local AssetRoster = require(ReplicatedStorage2.Client.AssetRoster)
					local Remotes = require(ReplicatedStorage2.Shared.Remotes)
					local LocalPlayer2 = game:GetService("Players").LocalPlayer

					local function Nyx_getOwnedEggSet()
						local ok, result = pcall(function()
							return AssetRoster.ReadOwnerPen(LocalPlayer2.UserId)
						end)

						if not ok or type(result) ~= "table" then
							return nil
						end

						local Nyx_getOwnedEggSet_var1 = {}

						for k, v in pairs(result) do
							if type(k) == "string" then
								Nyx_getOwnedEggSet_var1[k] = true
							end

							if type(v) == "table" and v.UID then
								Nyx_getOwnedEggSet_var1[v.UID] = true
							end
						end

						return Nyx_getOwnedEggSet_var1
					end
					local function Nyx_canSellPet(petEntry, placedSet)
						if not NyxConfig.AutoSell then
							return false, "toggle Auto Sell Pet udah OFF", "global"
						end

						if not Nyx_isSafeToSteal() then
							return false, "Auto Steal lagi megang kendali", "global"
						end

						local Nyx_sellNameFilter = Nyx_logDisconnect_var3(Nyx_petNameFilterRef)
						local Nyx_sellRarityFilter = Nyx_logDisconnect_var3(Nyx_petRarityFilterRef)

						if not Nyx_sellNameFilter or not Nyx_sellRarityFilter then
							return false, "filter dropdown gak bisa dibaca", "global"
						end

						if type(placedSet) ~= "table" then
							return false, "status pet dipajang gak bisa diverifikasi", "global"
						end

						if placedSet[petEntry.uid] then
							return false, "pet ini dipajang di plot", "pet"
						end

						if not Nyx_isFilterMatch(petEntry.petName, petEntry.rarity, Nyx_sellNameFilter, Nyx_sellRarityFilter) then
							return false, "pet ini udah gak match filter yang sekarang", "pet"
						end

						local Nyx_saveDataForSell = (Save.Peek or Save.Get)()
						local Inventory = Nyx_saveDataForSell and Nyx_saveDataForSell.Inventory and Nyx_saveDataForSell.Inventory[petEntry.uid]

						if Inventory == nil then
							return false, "pet ini udah gak ada di inventory", "pet"
						end

						local SellPetMaxRate = NyxConfig.SellPetMaxRate or 0

						if SellPetMaxRate > 0 then
							if SellPetMaxRate < Nyx_getRatePerSecond({
								Category = Inventory.Category or Inventory.AssetCategory,
								Scale = Inventory.Scale or Inventory.AssetScale or 1,
								Mutations = Inventory.Mutations or {}
							}) then
								return false, "money/s pet ini di atas batas value", "pet"
							end
						end

						if Inventory.IsFavorite == true then
							return false, "pet ini di-favorite", "pet"
						end

						if Inventory.InFuse == true then
							return false, "pet ini sedang di-fuse", "pet"
						end

						if table.find(Nyx_saveDataForSell.EquippedAssets or {}, petEntry.uid) == nil then
							return true
						end

						return false, "pet ini sedang dipasang", "pet"
					end

					while NyxConfig.AutoSell and Nyx_isCurrentSession() do
						local ok, result = pcall(function()
							if not Nyx_isSafeToSteal() then
								return
							end

							local Nyx_sellNameFilter2 = Nyx_logDisconnect_var3(Nyx_petNameFilterRef)
							local Nyx_sellRarityFilter2 = Nyx_logDisconnect_var3(Nyx_petRarityFilterRef)

							if not Nyx_sellNameFilter2 or not Nyx_sellRarityFilter2 then
								warn("[AutoSell] Filter dropdown gak bisa dibaca - ronde ini di-SKIP, gak ada yang dijual. Kalau ini terus-terusan, matiin Auto Sell Pet dan lapor.")

								return
							end

							local Nyx_saveDataForSell2 = (Save.Peek or Save.Get)()
							local Inventory = Nyx_saveDataForSell2 and Nyx_saveDataForSell2.Inventory or {}
							local Nyx_ownedEggSet = Nyx_getOwnedEggSet()

							if not Nyx_ownedEggSet then
								warn("[AutoSell] Status pet yang dipajang gak bisa diverifikasi - ronde ini di-SKIP, gak ada yang dijual.")

								return
							end

							local Nyx_canSellPet_var2 = {}
							local Nyx_canSellPet_var1 = 0

							if type(Inventory) == "table" then
								for k, v in pairs(Inventory) do
									Nyx_canSellPet_var1 += 1

									if Nyx_canSellPet_var1 % 250 == 0 then
										RunService.Heartbeat:Wait()

										if not NyxConfig.AutoSell then
											return
										end
									end

									if type(v) == "table" then
										local Nyx_isPlaced = Nyx_ownedEggSet[k] == true
										local Nyx_isFavorite = v.IsFavorite == true or v["Jadikan Favorit"] == true or v.Favorite == true
										local Nyx_isEquipped = table.find(Nyx_saveDataForSell2.EquippedAssets or {}, k) ~= nil
										local Nyx_isInFuse = v.InFuse == true
										local Category = v.Category or v.id or v.AssetCategory or v.ItemId
										local Nyx_petAssetDefForSell = Category and Assets.Directory[Category]
										local DisplayName = Nyx_petAssetDefForSell and (Nyx_petAssetDefForSell.DisplayName or Nyx_petAssetDefForSell._id or Nyx_petAssetDefForSell.Name) or "Unknown"
										local Rarity = Nyx_petAssetDefForSell and Nyx_petAssetDefForSell.Rarity
										local DisplayName2 = Rarity and (Rarity.DisplayName or Rarity._id or Rarity.Name) or "Unknown"
										local Nyx_petMatchesSellFilter = Nyx_isFilterMatch(DisplayName, DisplayName2, Nyx_sellNameFilter2, Nyx_sellRarityFilter2)
										local Nyx_petUnderMaxRate = true
										local SellPetMaxRate = NyxConfig.SellPetMaxRate or 0

										if SellPetMaxRate > 0 then
											Nyx_petUnderMaxRate = Nyx_getRatePerSecond({
												Category = Category,
												Scale = v.Scale or v.AssetScale or 1,
												Mutations = v.Mutations or {}
											}) <= SellPetMaxRate
										end

										if Nyx_petMatchesSellFilter and Nyx_petUnderMaxRate and not Nyx_isFavorite and not Nyx_isPlaced and not Nyx_isEquipped and not Nyx_isInFuse then
											table.insert(Nyx_canSellPet_var2, {
												uid = k,
												petName = DisplayName,
												rarity = DisplayName2
											})
										end
									end
								end
							end

							if #Nyx_canSellPet_var2 > 0 then
								for _, v in ipairs(Nyx_canSellPet_var2) do
									local Nyx_ownedEggSet2 = Nyx_getOwnedEggSet()
									local Nyx_petSellOk, Nyx_petSellError, Nyx_petSellScope = Nyx_canSellPet(v, Nyx_ownedEggSet2)

									if not Nyx_petSellOk then
										warn("[AutoSell] Gak jual " .. tostring(v.petName) .. " - " .. tostring(Nyx_petSellError))

										if Nyx_petSellScope ~= "global" then
											continue
										end
									elseif Nyx_isSafeToSteal() then
										local Character = LocalPlayer2.Character
										local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
										local Nyx_petTool

										for _, Nyx_item in ipairs({
											LocalPlayer2.Backpack,
											Character
										}) do
											if Nyx_item then
												for _, child in ipairs(Nyx_item:GetChildren()) do
													if child:IsA("Tool") and child:GetAttribute("UID") == v.uid then
														Nyx_petTool = child

														break
													end
												end
											end

											if Nyx_petTool then
												break
											end
										end

										if not Nyx_petTool or not Humanoid then
											continue
										end

										Humanoid:EquipTool(Nyx_petTool)
										task.wait(0.2)

										if Nyx_isSafeToSteal() then
											local Nyx_ownedEggSet3 = Nyx_getOwnedEggSet()
											local Nyx_petSellOk2, Nyx_petSellError2, Nyx_petSellScope2 = Nyx_canSellPet(v, Nyx_ownedEggSet3)

											if Nyx_petSellOk2 then
												Remotes.PetSatchel.SellPet:FireServer({ v.uid })
												task.wait(0.05)

												continue
											else
												warn("[AutoSell] Batal di detik terakhir, gak jual " .. tostring(v.petName) .. " - " .. tostring(Nyx_petSellError2))

												if Nyx_petSellScope2 ~= "global" then
													continue
												end
											end
										end
									end

									break
								end
							end
						end)

						if not ok then
							warn("Auto Sell Error:", result)
						end

						task.wait(1.5)
					end

					Nyx_parseValueInput_var2 = false
				end)
			end

			local Nyx_canSellPet_var3 = false
			local Nyx_canSellPet_var4 = false

			local function Nyx_hasAnyEggToSell()
				if not NyxConfig.AutoSellEgg then
					return false
				end

				local Nyx_eggRarityFilter2 = Nyx_logDisconnect_var3(Nyx_eggRarityFilterRef)

				if not Nyx_eggRarityFilter2 or #Nyx_eggRarityFilter2 == 0 or table.find(Nyx_eggRarityFilter2, "None") then
					return false
				end

				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				local ok, result = pcall(function()
					return require(ReplicatedStorage2.Shared.Save)
				end)

				if not ok or not result then
					return false
				end

				local Nyx_saveDataForEggSell = (result.Peek or result.Get)()
				local EggInventory = Nyx_saveDataForEggSell and Nyx_saveDataForEggSell.EggInventory

				if type(EggInventory) ~= "table" then
					return false
				end

				local ok2, result2 = pcall(function()
					return require(ReplicatedStorage2.Data.Assets)
				end)
				local Directory = ok2 and result2 and result2.Directory

				if not Directory then
					return false
				end

				for _, v in pairs(EggInventory) do
					local Nyx_eggAssetDefForSell = type(v) == "table" and Directory[v.AssetCategory]
					local DisplayName = Nyx_eggAssetDefForSell and Nyx_eggAssetDefForSell.Rarity and (Nyx_eggAssetDefForSell.Rarity.DisplayName or Nyx_eggAssetDefForSell.Rarity._id)
					local Nyx_eggUnderMaxRate = true
					local SellEggMaxRate = NyxConfig.SellEggMaxRate or 0

					if SellEggMaxRate > 0 and type(v) == "table" then
						Nyx_eggUnderMaxRate = Nyx_getRatePerSecond({
							Category = v.AssetCategory,
							Scale = v.AssetScale or 1,
							Mutations = v.Mutations or {}
						}) <= SellEggMaxRate
					end

					if v.Placement == nil and Nyx_eggUnderMaxRate then
						if not Nyx_isRarityInList(DisplayName or "Unknown", Nyx_eggRarityFilter2) then
							continue
						end

						return true
					end
				end

				return false
			end

			genv.__NyxIsAutoSellEggBusy = function()
				return Nyx_canSellPet_var4 or Nyx_hasAnyEggToSell()
			end
			Nyx_AutoLoops.startAutoSellEggLoop = function()
				if not Nyx_canSellPet_var3 then
					Nyx_canSellPet_var3 = true
					task.spawn(function()
						local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
						local Directory = require(ReplicatedStorage2.Data.Assets).Directory
						local EggState2 = require(ReplicatedStorage2.Client.EggState)
						local Remotes = require(ReplicatedStorage2.Shared.Remotes)
						local Save = require(ReplicatedStorage2.Shared.Save)

						while NyxConfig.AutoSellEgg and Nyx_isCurrentSession() do
							local Nyx_eggRarityFilter3 = Nyx_logDisconnect_var3(Nyx_eggRarityFilterRef)
							local Nyx_saveDataForEggSell2 = (Save.Peek or Save.Get)()
							local EggInventory = Nyx_saveDataForEggSell2 and Nyx_saveDataForEggSell2.EggInventory

							if Nyx_eggRarityFilter3 and type(EggInventory) == "table" and Nyx_isSafeToSteal() then
								for k, v in pairs(EggInventory) do
									if NyxConfig.AutoSellEgg and Nyx_isSafeToSteal() then
										local Nyx_eggAssetDefForSell2 = type(v) == "table" and Directory[v.AssetCategory]
										local DisplayName = Nyx_eggAssetDefForSell2 and Nyx_eggAssetDefForSell2.Rarity and (Nyx_eggAssetDefForSell2.Rarity.DisplayName or Nyx_eggAssetDefForSell2.Rarity._id)
										local Nyx_eggUnderMaxRate2 = true
										local SellEggMaxRate = NyxConfig.SellEggMaxRate or 0

										if SellEggMaxRate > 0 and type(v) == "table" then
											Nyx_eggUnderMaxRate2 = Nyx_getRatePerSecond({
												Category = v.AssetCategory,
												Scale = v.AssetScale or 1,
												Mutations = v.Mutations or {}
											}) <= SellEggMaxRate
										end

										if not (v.Placement == nil and Nyx_eggUnderMaxRate2) then
											continue
										end

										if not Nyx_isRarityInList(DisplayName or "Unknown", Nyx_eggRarityFilter3) then
											continue
										end

										if Nyx_isSafeToSteal() then
											Nyx_canSellPet_var4 = true

											if genv.__NyxTreadmillManager and genv.__NyxTreadmillManager.activeTreadmill ~= nil then
												genv.__NyxTreadmillManager:_cancelIdle(true)
												task.wait(0.25)
											end

											if not EggState2.WearEggTool(k) then
												continue
											end

											task.wait(0.2)

											if Nyx_isSafeToSteal() then
												local Nyx_saveDataForEggSell3 = (Save.Peek or Save.Get)()
												local EggInventory2 = Nyx_saveDataForEggSell3 and Nyx_saveDataForEggSell3.EggInventory and Nyx_saveDataForEggSell3.EggInventory[k]

												if EggInventory2 and EggInventory2.Placement == nil then
													Remotes.PetSatchel.SellPet:FireServer({ k })
													task.wait(0.25)
												end

												continue
											end
										end
									end

									break
								end
							end

							Nyx_canSellPet_var4 = false
							task.wait(0.5)
						end

						Nyx_canSellPet_var4 = false
						Nyx_canSellPet_var3 = false
					end)

					return
				end
			end

			local Nyx_allNames = {
				"None",
				"All"
			}

			pcall(function()
				local Nyx_dedupNames = {}

				for _, v in pairs(require(game:GetService("ReplicatedStorage").Data.Assets).Directory) do
					if type(v) == "table" and (v.DisplayName or v._id or v.Name) then
						local DisplayName = v.DisplayName or v._id or v.Name

						if not Nyx_dedupNames[DisplayName] then
							Nyx_dedupNames[DisplayName] = true
							table.insert(Nyx_allNames, DisplayName)
						end
					end
				end

				table.sort(Nyx_allNames, function(entryA, entryB)
					if entryA == "None" then
						return true
					end

					if entryB == "None" then
						return false
					end

					if entryA == "All" then
						return true
					end

					if entryB == "All" then
						return false
					end

					return entryA < entryB
				end)
			end)
			Nyx_nameFilterOptions = Nyx_cleanList(Nyx_rarityOptionsAll)
			Nyx_areaFilterOptions = Nyx_cleanList(Nyx_areaOptions)
			Nyx_rarityFilterOptions = Nyx_getAllRarities()
			Nyx_petNameOptions = Nyx_prependAll(Nyx_cleanList(Nyx_allNames))
			Nyx_setAutoSteal = function(enabled)
				NyxConfig.AutoSteal = enabled == true

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setEnabled(NyxConfig.AutoSteal)
				end

				if type(genv.__NyxSetStealDeclutter) == "function" then
					pcall(genv.__NyxSetStealDeclutter, NyxConfig.AutoSteal)
				end
			end
			Nyx_setStealHold = function(holdSeconds)
				NyxConfig.StealHoldSeconds = math.clamp(math.floor((tonumber(holdSeconds) or 5) + 0.5), 1, 10)
			end
			Nyx_setGodMode = function(enabled)
				NyxConfig.GodMode = enabled == true

				if Nyx_godMode then
					Nyx_godMode:setEnabled(NyxConfig.GodMode)
				end
			end

			local function Nyx_getTreadmillManager()
				return genv.__NyxTreadmillManager
			end

			Nyx_setAutoTreadmillIdle = function(enabled)
				NyxConfig.AutoTreadmillIdle = enabled == true

				local Nyx_treadmillManagerForIdle = Nyx_getTreadmillManager()

				if Nyx_treadmillManagerForIdle then
					Nyx_treadmillManagerForIdle:setIdleFarm(NyxConfig.AutoTreadmillIdle and not NyxConfig.AntiTreadmill)
				end
			end
			Nyx_setAntiTreadmill = function(enabled)
				NyxConfig.AntiTreadmill = enabled == true

				local Nyx_treadmillManagerForAnti = Nyx_getTreadmillManager()

				if NyxConfig.AntiTreadmill then
					if Nyx_treadmillManagerForAnti then
						Nyx_treadmillManagerForAnti:setIdleFarm(false)
					end

					Nyx_ServerHop.startAntiTreadmillLoop()
				elseif Nyx_treadmillManagerForAnti then
					Nyx_treadmillManagerForAnti:setIdleFarm(NyxConfig.AutoTreadmillIdle)
				end
			end
			Nyx_setHopNoMatch = function(enabled)
				NyxConfig.HopNoMatch = enabled == true

				if NyxConfig.HopNoMatch then
					Nyx_ServerHop.startHopLoop()
				end
			end
			Nyx_setPrivateServerMax = function(maxPlayers)
				if type(maxPlayers) == "table" then
					maxPlayers = maxPlayers[1]
				end

				NyxConfig.PrivateServerMax = tostring(maxPlayers or "2")
			end
			Nyx_setPrivateServerAuto = function(enabled)
				NyxConfig.PrivateServerAuto = enabled == true

				if NyxConfig.PrivateServerAuto then
					Nyx_ServerHop.startPrivateAutoHop()
				end
			end
			Nyx_setHopCooldown = function(cooldown)
				NyxConfig.HopCooldown = math.max(1, math.floor(tonumber(cooldown) or 5))
			end
			Nyx_setAutoTreadmillUpgrade = function(enabled)
				NyxConfig.AutoTreadmillUpgrade = enabled == true

				local Nyx_treadmillManagerForUpgrade = Nyx_getTreadmillManager()

				if Nyx_treadmillManagerForUpgrade then
					Nyx_treadmillManagerForUpgrade:setAutoUpgrade(NyxConfig.AutoTreadmillUpgrade)
				end
			end
			Nyx_setStealMode = function(modeString)
				local Nyx_stealModeString = type(modeString) == "string" and modeString or ""
				local stealMode = (Nyx_stealModeString:find("Fly") or Nyx_stealModeString:find("High")) and "Fly" or "Instant"
				local flyAerial = stealMode == "Fly" and (Nyx_stealModeString:find("%(Fly%)") ~= nil or Nyx_stealModeString:lower():find("aerial") ~= nil)

				NyxConfig.StealMode = stealMode
				NyxConfig.FlyAerial = flyAerial

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setStealMode(stealMode, flyAerial)
				end
			end
			Nyx_setTweenSpeedSlider = function(speedInput)
				local Nyx_clampedSpeedSlider = math.floor(math.clamp(math.floor((tonumber(speedInput) or 600) + 0.5), 500, 1000) / 10 + 0.5)

				Nyx_setTweenSpeedMultiplier(Nyx_clampedSpeedSlider)

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setSpeed(Nyx_clampedSpeedSlider)
				end
			end
			Nyx_setStealFilter = function(filterKey, filterEnabled, valueList)
				local Nyx_cleanedFilterList = Nyx_cleanList(valueList)

				if filterKey == "names" then
					NyxConfig.StealNamesFilter = Nyx_cleanedFilterList
				elseif filterKey == "areas" then
					NyxConfig.StealAreas = Nyx_cleanedFilterList
				elseif filterKey == "rarities" then
					NyxConfig.StealRarities = Nyx_cleanedFilterList
				end

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setFilter(filterKey, Nyx_cleanedFilterList)
					Nyx_eggRuntime:setFilterEnabled(filterEnabled, #Nyx_cleanedFilterList > 0)
				end
			end
			Nyx_setStealValue = function(valueInput)
				NyxConfig:applyStealValueInput(valueInput)

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setMinValuePerSec(NyxConfig.StealMinValue or 0)
				end
			end
			Nyx_setStealMutations = function(valueList)
				local Nyx_cleanedMutationList = Nyx_cleanList(valueList)

				NyxConfig.StealMutations = Nyx_cleanedMutationList

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setFilter("mutations", Nyx_cleanedMutationList)
					Nyx_eggRuntime:setFilterEnabled("mutation", #Nyx_cleanedMutationList > 0)
				end
			end
			Nyx_setStealWeight = function(valueInput)
				local tonumber_ = tonumber
				local Nyx_cleanedWeightInput = tostring(valueInput or ""):gsub("[^%d%.]", "")
				local stealMinWeight = tonumber_(Nyx_cleanedWeightInput) or 0

				NyxConfig.StealMinWeight = stealMinWeight

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setMinWeightKg(stealMinWeight)
				end
			end
			Nyx_setStealPriority = function(priority)
				NyxConfig.StealPriority = tostring(priority or "Rarity")

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setHighestValueFirst(NyxConfig.StealPriority == "Highest Value")
					Nyx_eggRuntime:setHeaviestFirst(NyxConfig.StealPriority == "Heaviest")
				end
			end
			Nyx_setEggEsp = function(enabled)
				NyxConfig.EggESP = enabled == true

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setEggEsp(NyxConfig.EggESP)
				end
			end
			Nyx_setEspDetails = function(detailList)
				local Nyx_cleanedEspDetails = Nyx_cleanList(detailList)

				NyxConfig.EspDetails = Nyx_cleanedEspDetails

				if not Nyx_eggRuntime then
					return
				end

				local Nyx_espDetailsMap = {}

				for _, v in ipairs(Nyx_cleanedEspDetails) do
					Nyx_espDetailsMap[v] = true
				end

				Nyx_eggRuntime:setEspOption("name", Nyx_espDetailsMap.Name == true)
				Nyx_eggRuntime:setEspOption("rarity", Nyx_espDetailsMap.Rarity == true)
				Nyx_eggRuntime:setEspOption("value", Nyx_espDetailsMap.Value == true)
				Nyx_eggRuntime:setEspOption("kg", Nyx_espDetailsMap.Weight == true)
				Nyx_eggRuntime:setEspOption("mutation", Nyx_espDetailsMap.Mutation == true)
				Nyx_eggRuntime:setEspOption("placed", Nyx_espDetailsMap["Placed Eggs"] == true)
			end
			Nyx_setScrambleBanners = function(bannerList)
				NyxConfig.ScrambleTradeInBanners = Nyx_cleanList(bannerList)
			end
			Nyx_setBackpackRates = function(enabled)
				Nyx_ServerHop.setBackpackRates(enabled == true)
			end
			Nyx_setAntiGuardKnockback = function(enabled)
				NyxConfig.AntiGuardKnockback = enabled == true

				local __NyxAntiGuard = genv.__NyxAntiGuard

				if __NyxAntiGuard and type(__NyxAntiGuard.setEnabled) == "function" then
					pcall(__NyxAntiGuard.setEnabled, __NyxAntiGuard, NyxConfig.AntiGuardKnockback)
				end
			end
			Nyx_setAutoFavorite = function(enabled)
				NyxConfig.AutoFavorite = enabled == true
			end
			Nyx_setFavoriteRule = function(rule)
				NyxConfig.FavMode = rule == "Species" and "Species" or "Rarity"
			end
			Nyx_setFavoriteRarities = function(rarityList)
				NyxConfig.FavRarities = Nyx_cleanList(rarityList)
			end
			Nyx_setFavoriteSpecies = function(speciesList)
				NyxConfig.FavSpecies = Nyx_cleanList(speciesList)
			end
			Nyx_setAutoEquipBest = function(enabled)
				NyxConfig.AutoEquipBest = enabled == true
			end
			Nyx_setAutoClaimOffline = function(enabled)
				NyxConfig.AutoClaimOffline = enabled == true
			end
			Nyx_setAutoBaseUpgrade = function(enabled)
				NyxConfig.AutoBaseUpgrade = enabled == true
			end
			Nyx_setAutoClaimAlmanac = function(enabled)
				NyxConfig.AutoClaimAlmanac = enabled == true
			end
			Nyx_setAutoFusePets = function(enabled)
				NyxConfig.AutoFusePets = enabled == true
			end
			Nyx_setFuseRule = function(rule)
				NyxConfig.FuseSelectedOnly = rule == "Selected Species"
			end
			Nyx_setFuseRarities = function(rarityList)
				NyxConfig.FuseRarities = Nyx_cleanList(rarityList)
			end
			Nyx_setFuseSpecies = function(speciesList)
				NyxConfig.FuseSpecies = Nyx_cleanList(speciesList)
			end
			Nyx_setNoclip = function(enabled)
				local __NyxRoaming = genv.__NyxRoaming

				if __NyxRoaming and type(__NyxRoaming.setNoclip) == "function" then
					pcall(__NyxRoaming.setNoclip, enabled == true)
				end
			end
			Nyx_setBottingMode = function(enabled)
				local __NyxRoaming = genv.__NyxRoaming

				if __NyxRoaming and type(__NyxRoaming.setBottingMode) == "function" then
					pcall(__NyxRoaming.setBottingMode, enabled == true)
				end
			end
			Nyx_setAntiCutscene = function(enabled)
				NyxConfig.AntiCutscene = enabled == true
			end
			runOnce = function(configKey, startFn, cleanupFn)
				local Nyx_prevConfigValue = NyxConfig[configKey]

				NyxConfig[configKey] = true
				task.spawn(startFn)
				task.delay(2.4, function()
					local Nyx_runOnceDeadline = os.clock() + 30

					while NyxConfig.IsPlacing and os.clock() < Nyx_runOnceDeadline do
						task.wait(0.25)
					end

					NyxConfig[configKey] = Nyx_prevConfigValue

					if cleanupFn then
						pcall(cleanupFn)
					end
				end)
			end
			Nyx_AutoLoops.runOnce = runOnce

			local function Nyx_setScrambleFarmDrones(enabled)
				NyxConfig.ScrambleFarmDrones = enabled == true
			end
			local function Nyx_setScrambleLostParts(enabled)
				NyxConfig.ScrambleLostParts = enabled == true
			end
			local function Nyx_setScrambleCollectSamples(enabled)
				NyxConfig.ScrambleCollectSamples = enabled == true
			end
			local function Nyx_setScrambleAutoVault(enabled)
				NyxConfig.ScrambleAutoVault = enabled == true
			end

			Nyx_setScrambleAutoBuy = function(enabled)
				NyxConfig.ScrambleAutoBuy = enabled == true
			end

			local function Nyx_setScrambleAreas(areaList)
				NyxConfig.ScrambleAreas = Nyx_cleanList(areaList)
			end
			local function Nyx_setScrambleDroneTypes(droneList)
				NyxConfig.ScrambleDroneTypes = Nyx_cleanList(droneList)
			end

			Nyx_setScrambleBuyList = function(buyList)
				NyxConfig.ScrambleBuyList = Nyx_cleanList(buyList)
			end
			Nyx_setAutoPlace = function(enabled)
				NyxConfig.AutoPlace = enabled == true

				if NyxConfig.AutoPlace then
					task.spawn(Nyx_AutoLoops.AutoPlaceLoop)
				end
			end
			Nyx_setAutoHatch = function(enabled)
				NyxConfig.AutoHatch = enabled == true

				if NyxConfig.AutoHatch then
					task.spawn(Nyx_AutoLoops.AutoHatchLoop)
				end
			end
			Nyx_setAutoMutation = function(enabled)
				NyxConfig.AutoMutation = enabled == true

				if NyxConfig.AutoMutation then
					task.spawn(Nyx_AutoLoops.AutoMutationLoop)
				end
			end
			Nyx_setAutoRingEvent = function(enabled)
				NyxConfig.AutoRingEvent = enabled == true

				if NyxConfig.AutoRingEvent then
					Nyx_AutoLoops.RingEventLoop()
				end
			end
			Nyx_setMutationChoice = function(mutationChoice)
				NyxConfig.MutationChoice = mutationChoice == "Fractured" and "Fractured" or "Scrambled"
			end
			Nyx_setMutationSpecies = function(speciesList)
				NyxConfig.MutationSpecies = Nyx_cleanList(speciesList)
			end
			Nyx_setMutationRarities = function(rarityList)
				NyxConfig.MutationRarities = Nyx_cleanList(rarityList)
			end
			Nyx_setMutationRetry = function(enabled)
				NyxConfig.MutationRetry = enabled == true
			end
			Nyx_setAutoSell = function(enabled)
				NyxConfig.AutoSell = enabled == true

				if NyxConfig.AutoSell then
					Nyx_AutoLoops.startAutoSellLoop()
				end
			end
			Nyx_setAutoSellEgg = function(enabled)
				NyxConfig.AutoSellEgg = enabled == true

				if NyxConfig.AutoSellEgg then
					Nyx_AutoLoops.startAutoSellEggLoop()
				end
			end
			Nyx_setSellPetMaxRate = function(valueInput)
				NyxConfig.SellPetMaxRate = Nyx_parseValueInput(valueInput)
			end
			Nyx_setSellEggMaxRate = function(valueInput)
				NyxConfig.SellEggMaxRate = Nyx_parseValueInput(valueInput)
			end
		end

		local Nyx_setSellEggMaxRate_var1 = false

		local function Nyx_setStartupBoost(enabled)
			local Nyx_wasStartupBoost = NyxConfig.StartupBoost == true

			NyxConfig.StartupBoost = enabled == true

			if not NyxConfig.StartupBoost then
				Nyx_setSellEggMaxRate_var1 = false

				if Nyx_wasStartupBoost or Nyx_FpsBoost.snapshot then
					task.spawn(Nyx_FpsBoost.revert)
				end

				return
			end

			if NyxConfig.StartupBoost and not Nyx_setSellEggMaxRate_var1 then
				Nyx_setSellEggMaxRate_var1 = true
				task.spawn(function()
					task.wait(1.5)

					if Nyx_isCurrentSession() and NyxConfig.StartupBoost then
						Nyx_leftTreadmillCheck_var2()
					end

					task.wait(4)

					if Nyx_isCurrentSession() and NyxConfig.StartupBoost then
						Nyx_leftTreadmillCheck_var2()
					end
				end)
			end
		end
		local function Nyx_runFpsBoostOnce(enabled)
			if enabled == true then
				task.spawn(Nyx_leftTreadmillCheck_var3)
			end
		end
		local function Nyx_setFpsCap(enabled)
			local __NyxSetCapFps = genv.__NyxSetCapFps

			if type(__NyxSetCapFps) == "function" then
				__NyxSetCapFps(enabled == true and 240 or 60)
			end
		end

		local Nyx_setFlyForCapture, Nyx_setInstantGrab, Nyx_setAutoStealCapture, Nyx_setInfiniteJump, Nyx_setAntiHitGuard, Nyx_setAntiAfk, Nyx_setAutoReconnect, Nyx_setAutoExecute, Nyx_applyElevatedIdentityFn, Nyx_uiSetupDone
		local Nyx_safeInvoke, __NyxPlayerSteal, Nyx_setStealPlayers, Nyx_setStealPlayerRarities, Nyx_setStealPlayerMinValue, Nyx_setAutoIndex, Nyx_setWebhookEnabled, Nyx_setWebhookUrl, Nyx_setWebhookRarities, Nyx_setWebhookMinValue
		local Nyx_mainWindow, Nyx_uiRefs, Nyx_waypoints, Nyx_setFpsCap_var1, Nyx_scrambleBuyOptions

		do
			local function Nyx_getMovementExtras()
				return genv.__NyxMovementExtras
			end

			Nyx_setFlyForCapture = function(enabled)
				NyxConfig.FlyForCapture = enabled == true

				local Nyx_movementExtrasForFly = Nyx_getMovementExtras()

				if Nyx_movementExtrasForFly then
					Nyx_movementExtrasForFly:setFlyForCapture(NyxConfig.FlyForCapture)
				end
			end
			Nyx_setInstantGrab = function(enabled)
				NyxConfig.InstantGrab = enabled == true

				local Nyx_movementExtrasForGrab = Nyx_getMovementExtras()

				if Nyx_movementExtrasForGrab then
					Nyx_movementExtrasForGrab:setInstantGrab(NyxConfig.InstantGrab)
				end
			end

			local function Nyx_setAdminBoost(enabled)
				genv.__NyxAdminBoost = enabled == true

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setSpeed(NyxConfig.TweenSpeedMultiplier or 60)
				end

				genv.__NyxAdminBoostSpeedGen = (genv.__NyxAdminBoostSpeedGen or 0) + 1

				local __NyxAdminBoostSpeedGen = genv.__NyxAdminBoostSpeedGen

				if enabled == true then
					task.spawn(function()
						local RunService2 = game:GetService("RunService")
						local Nyx_baseWalkSpeed
						local Nyx_appliedWalkSpeed

						while genv.__NyxAdminBoostSpeedGen == __NyxAdminBoostSpeedGen and Nyx_isCurrentSession() do
							local Character = LocalPlayer.Character
							local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

							if Humanoid then
								local WalkSpeed = Humanoid.WalkSpeed

								if Nyx_baseWalkSpeed == nil or Nyx_appliedWalkSpeed == nil or math.abs(WalkSpeed - Nyx_appliedWalkSpeed) > 0.5 then
									Nyx_baseWalkSpeed = WalkSpeed > 900 and WalkSpeed / 10 or WalkSpeed
								end

								if Nyx_baseWalkSpeed and Nyx_baseWalkSpeed > 0 then
									local walkSpeed = Nyx_baseWalkSpeed * 10

									Humanoid.WalkSpeed = walkSpeed
									Nyx_appliedWalkSpeed = walkSpeed
								end
							else
								Nyx_baseWalkSpeed = nil
								Nyx_appliedWalkSpeed = nil
							end

							RunService2.Heartbeat:Wait()
						end
					end)
				end
			end

			Nyx_setAutoStealCapture = function(enabled)
				NyxConfig.AutoStealCapture = enabled == true
			end
			Nyx_setInfiniteJump = function(enabled)
				NyxConfig.InfiniteJump = enabled == true

				local Nyx_movementExtrasForJump = Nyx_getMovementExtras()

				if Nyx_movementExtrasForJump then
					Nyx_movementExtrasForJump:setInfiniteJump(NyxConfig.InfiniteJump)
				end
			end

			local function Nyx_setSpeedMultiplier(multiplier)
				NyxConfig.WalkSpeedMultiplier = math.clamp(tonumber(multiplier) or 1, 1, 2.1)

				local Nyx_movementExtrasForSpeed = Nyx_getMovementExtras()

				if Nyx_movementExtrasForSpeed then
					Nyx_movementExtrasForSpeed:setSpeedMultiplier(NyxConfig.WalkSpeedMultiplier)
				end
			end

			Nyx_setAntiHitGuard = function(enabled)
				NyxConfig.AntiHitGuard = enabled == true

				local __NyxAntiHitGuard = genv.__NyxAntiHitGuard

				if __NyxAntiHitGuard then
					__NyxAntiHitGuard:setEnabled(NyxConfig.AntiHitGuard)
				end
			end
			Nyx_setAntiAfk = function(enabled)
				NyxConfig.AntiAFK = enabled == true
				genv.__NyxAntiAfkEnabled = NyxConfig.AntiAFK

				if type(genv.__NyxSetAntiAfkEnabled) == "function" then
					genv.__NyxSetAntiAfkEnabled(NyxConfig.AntiAFK)
				end
			end
			Nyx_setAutoReconnect = function(enabled)
				NyxConfig.AutoReconnect = enabled == true
				Nyx_configRef.autoReconnect = NyxConfig.AutoReconnect

				if getgenv then
					getgenv().SNE_AutoReconnect = NyxConfig.AutoReconnect
				end
			end
			Nyx_setAutoExecute = function(enabled)
				NyxConfig.AutoExecute = enabled == true
				Nyx_configRef.autoExecute = NyxConfig.AutoExecute

				if getgenv then
					getgenv().SNE_AutoExecute = NyxConfig.AutoExecute
				end

				if enabled then
					pcall(Nyx_writeAutoexecFile)
				else
					pcall(Nyx_clearAutoexecFile)
				end
			end

			local function Nyx_getIdentitySetter()
				local __NyxIdentitySetter = genv.__NyxIdentitySetter or type(setthreadidentity) == "function" and setthreadidentity or type(set_thread_identity) == "function" and set_thread_identity or type(setidentity) == "function" and setidentity or type(syn) == "table" and type(syn.set_thread_identity) == "function" and syn.set_thread_identity
				local __NyxUICapabilityIdentity = genv.__NyxUICapabilityIdentity or 8

				local function Nyx_applyIdentity()
					if type(__NyxIdentitySetter) == "function" then
						pcall(__NyxIdentitySetter, __NyxUICapabilityIdentity)
					end
				end

				return Nyx_applyIdentity
			end

			Nyx_applyElevatedIdentityFn = Nyx_getIdentitySetter()
			Nyx_uiSetupDone = true
			Nyx_safeInvoke = function(callback)
				local function Nyx_wrapCallback(value)
					if type(Nyx_applyElevatedIdentityFn) == "function" then
						Nyx_applyElevatedIdentityFn()
					end

					if Nyx_uiSetupDone then
						return
					end

					if type(callback) == "function" then
						callback(value)
					end
				end

				return Nyx_wrapCallback
			end
			__NyxPlayerSteal = genv.__NyxPlayerSteal
			Nyx_setStealPlayers = function(enabled)
				NyxConfig.StealPlayers = enabled == true

				if __NyxPlayerSteal then
					__NyxPlayerSteal:setEnabled(NyxConfig.StealPlayers)
				end
			end
			Nyx_setStealPlayerRarities = function(rarityList)
				NyxConfig.StealPlayerRarities = Nyx_cleanList(rarityList)
			end

			local function Nyx_parseValueInput2(valueInput)
				local Nyx_cleanedValueInput2 = string.lower(tostring(valueInput or "")):gsub("[%s,]", "")

				if Nyx_cleanedValueInput2 == "" then
					return 0
				end

				local Nyx_parsedValueNum2, Nyx_parsedValueUnit2 = string.match(Nyx_cleanedValueInput2, "^([%d]+%.?[%d]*)([kmb]?)$")
				local Nyx_parsedValueRaw2 = tonumber(Nyx_parsedValueNum2)

				if not Nyx_parsedValueRaw2 then
					return 0
				end

				if Nyx_parsedValueUnit2 == "k" then
					return Nyx_parsedValueRaw2 * 1000
				end

				if Nyx_parsedValueUnit2 == "m" then
					return Nyx_parsedValueRaw2 * 1000000
				end

				if Nyx_parsedValueUnit2 == "b" then
					return Nyx_parsedValueRaw2 * 1e9
				end

				return Nyx_parsedValueRaw2
			end

			Nyx_setStealPlayerMinValue = function(valueInput)
				NyxConfig.StealPlayerMinValue = Nyx_parseValueInput2(valueInput)
			end
			Nyx_setAutoIndex = function(enabled)
				NyxConfig.AutoIndex = enabled == true

				if Nyx_eggRuntime then
					Nyx_eggRuntime:setIndexObjective(NyxConfig.AutoIndex)
				end
			end
			Nyx_setWebhookEnabled = function(enabled)
				NyxConfig.WebhookEnabled = enabled == true
			end
			Nyx_setWebhookUrl = function(url)
				NyxConfig.WebhookURL = type(url) == "string" and url or ""
			end
			Nyx_setWebhookRarities = function(rarityList)
				NyxConfig.WebhookRarities = Nyx_cleanList(rarityList)
			end
			Nyx_setWebhookMinValue = function(valueInput)
				NyxConfig.WebhookMinValue = Nyx_parseValueInput2(valueInput)
			end

			local Nyx_setWebhookMinValue_var1 = {
				"Set",
				"SetValue",
				"LoadValue",
				"ResetValue",
				"SetContent",
				"SetTitle",
				"SetOptions",
				"Update",
				"Refresh",
				"Lock",
				"Unlock",
				"SetVisible"
			}

			local function Nyx_wrapControlSetter(control)
				if type(control) ~= "table" then
					return control
				end

				if rawget(control, "__NyxElevated") then
					return control
				end

				for _, v in ipairs(Nyx_setWebhookMinValue_var1) do
					local value = rawget(control, v)

					if type(value) == "function" then
						rawset(control, v, function(...)
							Nyx_applyElevatedIdentityFn()

							return value(...)
						end)
					end
				end

				rawset(control, "__NyxElevated", true)

				return control
			end

			local Nyx_wrapControlSetter_var1 = {
				"AddToggle",
				"AddSlider",
				"AddDropdown",
				"AddInput",
				"AddButton",
				"AddParagraph",
				"AddKeybind",
				"AddColorPicker",
				"AddActionList",
				"AddLiveChat",
				"AddSupportCard",
				"AddSubSection",
				"AddSection",
				"AddTab",
				"AddForum"
			}

			local function Nyx_wrapControlFactory(control)
				if type(control) ~= "table" then
					return control
				end

				Nyx_wrapControlSetter(control)

				if rawget(control, "__NyxFactoryGuarded") then
					return control
				end

				for _, v in ipairs(Nyx_wrapControlSetter_var1) do
					local value = rawget(control, v)

					if type(value) == "function" then
						rawset(control, v, function(...)
							Nyx_applyElevatedIdentityFn()

							local Nyx_wrappedResult = table.pack(value(...))

							if Nyx_wrappedResult.n > 0 then
								Nyx_wrappedResult[1] = Nyx_wrapControlFactory(Nyx_wrappedResult[1])
							end

							return table.unpack(Nyx_wrappedResult, 1, Nyx_wrappedResult.n)
						end)
					end
				end

				rawset(control, "__NyxFactoryGuarded", true)

				return control
			end

			Nyx_applyElevatedIdentityFn()
			Nyx_mainWindow = NyxLibOverride.CreateWindow({
				Title = "OXIO",
				Logo = 118755181202304,
				Anonymous = false,
				ConfigFolder = "OXIOSAEv4"
			})
			Nyx_wrapControlFactory(Nyx_mainWindow)
			Nyx_uiRefs = {}
			Nyx_waypoints = { "Respawn Point" }

			local __NyxRoaming = genv.__NyxRoaming

			if __NyxRoaming and type(__NyxRoaming.waypointList) == "function" then
				local ok, result = pcall(__NyxRoaming.waypointList)

				if ok and type(result) == "table" and #result > 0 then
					Nyx_waypoints = result
				end
			end

			Nyx_setFpsCap_var1 = Nyx_waypoints[1]
			Nyx_scrambleBuyOptions = {}

			local __NyxScrambleRuntime = genv.__NyxScrambleRuntime

			if __NyxScrambleRuntime and type(__NyxScrambleRuntime.snapshot) == "function" then
				pcall(function()
					local Nyx_scrambleSnapshot = __NyxScrambleRuntime.snapshot()

					if Nyx_scrambleSnapshot and type(Nyx_scrambleSnapshot.Shop) == "table" then
						for _, v in pairs(Nyx_scrambleSnapshot.Shop) do
							if v and v.Label then
								Nyx_scrambleBuyOptions[#Nyx_scrambleBuyOptions + 1] = tostring(v.Label)
							end
						end
					end
				end)
			end

			local Nyx_wrapControlFactory_var20 = Nyx_mainWindow:CreateTab({
				Name = "Admin Abuse",
				Icon = "flame"
			})

			Nyx_uiRefs.autoStealCapture = Nyx_wrapControlFactory_var20:CreateSection({ Name = "Capture The Egg", Side = "Left" }):AddToggle({
				Name = "Auto Steal Capture",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoStealCapture)
			})

			local Movement = Nyx_wrapControlFactory_var20:CreateSection({ Name = "Movement", Side = "Left" })

			Nyx_uiRefs.adminBoost = Movement:AddToggle({
				Name = "Admin Abuse Boost",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAdminBoost)
			})
			Nyx_uiRefs.flyForCapture = Movement:AddToggle({
				Name = "Fly For Capture",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setFlyForCapture)
			})
			Nyx_uiRefs.instantGrab = Movement:AddToggle({
				Name = "Instant Grab",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setInstantGrab)
			})
			Nyx_uiRefs.infiniteJump = Movement:AddToggle({
				Name = "Infinite Jump",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setInfiniteJump)
			})
			Nyx_uiRefs.noclip = Movement:AddToggle({
				Name = "Noclip",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setNoclip)
			})
			Nyx_uiRefs.autoRingEvent = Nyx_wrapControlFactory_var20:CreateSection({ Name = "Ring Event", Side = "Left" }):AddToggle({
				Name = "Auto Ring Event",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoRingEvent)
			})
		end

		do
			local Nyx_wrapControlFactory_var21 = Nyx_mainWindow:CreateTab({
				Name = "Main",
				Icon = "home"
			})
			local Nyx_wrapControlFactory_var22 = Nyx_wrapControlFactory_var21:CreateSection({ Name = "Auto Steal", Side = "Left" })

			Nyx_uiRefs.autoSteal = Nyx_wrapControlFactory_var22:AddToggle({
				Name = "Auto Steal",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoSteal)
			})
			Nyx_uiRefs.helpFriend = Nyx_wrapControlFactory_var22:AddToggle({
				Name = "Help Friend",
				Default = false,
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var2)
					NyxConfig.HelpFriend = Nyx_wrapControlFactory_var2 == true
				end)
			})
			Nyx_wrapControlFactory_var22:AddButton({
				Name = "Egg Checker",
				Callback = Nyx_safeInvoke(function()
					NyxPanels.openChecker()
				end)
			})
			Nyx_wrapControlFactory_var22:AddButton({
				Name = "Egg Spawn Analyst",
				Callback = Nyx_safeInvoke(function()
					NyxPanels.openAnalyst()
				end)
			})
			Nyx_uiRefs.godMode = Nyx_wrapControlFactory_var22:AddToggle({
				Name = "Aura Bat",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setGodMode)
			})
			Nyx_uiRefs.stealMode = Nyx_wrapControlFactory_var22:AddDropdown({
				Name = "Steal Mode",
				Options = {
					"Low Speed User",
					"High Speed User",
					"High Speed User (Fly)"
				},
				Default = "High Speed User",
				Callback = Nyx_safeInvoke(Nyx_setStealMode)
			})

			if (tonumber(NyxConfig.StealHoldSeconds) or 5) > 10 then
				NyxConfig.StealHoldSeconds = 5
			end

			Nyx_uiRefs.stealHold = Nyx_wrapControlFactory_var22:AddSlider({
				Name = "Low Speed Multiplier",
				Min = 1,
				Max = 10,
				Default = 5,
				Callback = Nyx_safeInvoke(Nyx_setStealHold)
			})

			local Nyx_wrapControlFactory_var23 = Nyx_wrapControlFactory_var21:CreateSection({ Name = "Egg Filter", Side = "Left" })

			Nyx_uiRefs.names = Nyx_wrapControlFactory_var23:AddMultiDropdown({
				Name = "Filter By Egg Name",
				Options = Nyx_nameFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var3)
					Nyx_setStealFilter("names", "name", Nyx_wrapControlFactory_var3)
				end)
			})
			Nyx_uiRefs.rarities = Nyx_wrapControlFactory_var23:AddMultiDropdown({
				Name = "Filter By Rarity",
				Options = Nyx_rarityFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var4)
					Nyx_setStealFilter("rarities", "rarity", Nyx_wrapControlFactory_var4)
				end)
			})
			Nyx_uiRefs.areas = Nyx_wrapControlFactory_var23:AddMultiDropdown({
				Name = "Select Area",
				Options = Nyx_areaFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var5)
					Nyx_setStealFilter("areas", "area", Nyx_wrapControlFactory_var5)
				end)
			})
			Nyx_uiRefs.value = Nyx_wrapControlFactory_var23:AddInput({
				Name = "Steal By Value",
				Placeholder = "e.g. 500k, 2m, 1b",
				Default = "",
				Callback = Nyx_safeInvoke(Nyx_setStealValue)
			})
			Nyx_uiRefs.mutations = Nyx_wrapControlFactory_var23:AddMultiDropdown({
				Name = "Filter By Mutation",
				Options = Nyx_mutationOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setStealMutations)
			})
			Nyx_uiRefs.weight = Nyx_wrapControlFactory_var23:AddInput({
				Name = "Steal By Weight",
				Placeholder = "e.g. 12000",
				Default = "",
				Callback = Nyx_safeInvoke(Nyx_setStealWeight)
			})
			Nyx_uiRefs.priority = Nyx_wrapControlFactory_var23:AddDropdown({
				Name = "Steal Priority",
				Options = {
					"Rarity",
					"Highest Value",
					"Heaviest"
				},
				Default = "Rarity",
				Callback = Nyx_safeInvoke(Nyx_setStealPriority)
			})
			Nyx_uiRefs.autoIndex = Nyx_wrapControlFactory_var23:AddToggle({
				Name = "Auto Index",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoIndex)
			})

			local Nyx_wrapControlFactory_var24 = Nyx_wrapControlFactory_var21:CreateSection({ Name = "Egg ESP", Side = "Left" })

			Nyx_uiRefs.eggEsp = Nyx_wrapControlFactory_var24:AddToggle({
				Name = "Egg ESP",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setEggEsp)
			})
			Nyx_uiRefs.espDetails = Nyx_wrapControlFactory_var24:AddMultiDropdown({
				Name = "ESP Details",
				Options = {
					"Name",
					"Rarity",
					"Value",
					"Weight",
					"Mutation",
					"Placed Eggs"
				},
				Default = {
					"Name",
					"Rarity",
					"Value"
				},
				Callback = Nyx_safeInvoke(Nyx_setEspDetails)
			})
			Nyx_uiRefs.backpackRates = Nyx_wrapControlFactory_var24:AddToggle({
				Name = "Backpack Value/s",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setBackpackRates)
			})

			local Nyx_wrapControlFactory_var25 = Nyx_wrapControlFactory_var21:CreateSection({ Name = "Steal Webhook", Side = "Left" })

			Nyx_uiRefs.webhookEnabled = Nyx_wrapControlFactory_var25:AddToggle({
				Name = "Steal Webhook",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setWebhookEnabled)
			})
			Nyx_uiRefs.webhookUrl = Nyx_wrapControlFactory_var25:AddInput({
				Name = "Webhook URL",
				Placeholder = "https://discord.com/api/webhooks/...",
				Default = "",
				Callback = Nyx_safeInvoke(Nyx_setWebhookUrl)
			})
			Nyx_uiRefs.webhookRarities = Nyx_wrapControlFactory_var25:AddMultiDropdown({
				Name = "Notify Rarities",
				Options = Nyx_rarityFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setWebhookRarities)
			})
			Nyx_uiRefs.webhookValue = Nyx_wrapControlFactory_var25:AddInput({
				Name = "Notify Minimum Value",
				Placeholder = "e.g. 500k, 2m, 1b",
				Default = "",
				Callback = Nyx_safeInvoke(Nyx_setWebhookMinValue)
			})
			Nyx_wrapControlFactory_var25:AddButton({
				Name = "Test Webhook",
				Callback = Nyx_safeInvoke(function()
					local __NyxWebhook = genv.__NyxWebhook

					if not __NyxWebhook or not __NyxWebhook.test() then
						NyxLibOverride.Notify({
							Title = "Steal Webhook",
							Text = "Enter a webhook URL first",
							Duration = 3
						})

						return
					end

					NyxLibOverride.Notify({
						Title = "Steal Webhook",
						Text = "Test embed sent",
						Duration = 3
					})
				end)
			})
		end

		do
			local Nyx_wrapControlFactory_var26 = Nyx_mainWindow:CreateTab({
				Name = "Auto",
				Icon = "repeat"
			})

			Nyx_uiRefs.privateTab = Nyx_mainWindow:CreateTab({
				Name = "Private Server",
				Icon = "users"
			})

			local Nyx_wrapControlFactory_var27 = Nyx_wrapControlFactory_var26:CreateSection({ Name = "Egg Automation", Side = "Left" })

			Nyx_uiRefs.autoPlace = Nyx_wrapControlFactory_var27:AddToggle({
				Name = "Auto Place Egg",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoPlace)
			})
			Nyx_uiRefs.placeRarity = Nyx_wrapControlFactory_var27:AddMultiDropdown({
				Name = "Place Egg Rarity",
				Options = Nyx_rarityFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var6)
					NyxConfig.PlaceRarities = Nyx_cleanList(Nyx_wrapControlFactory_var6)
				end)
			})
			Nyx_uiRefs.autoHatch = Nyx_wrapControlFactory_var27:AddToggle({
				Name = "Auto Hatch Egg",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoHatch)
			})
			Nyx_uiRefs.mutationChoice = Nyx_wrapControlFactory_var27:AddDropdown({
				Name = "Select Mutation",
				Options = {
					"Scrambled",
					"Fractured"
				},
				Default = "Scrambled",
				Callback = Nyx_safeInvoke(Nyx_setMutationChoice)
			})
			Nyx_uiRefs.mutationSpecies = Nyx_wrapControlFactory_var27:AddMultiDropdown({
				Name = "Mutate Egg Name",
				Options = Nyx_nameFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setMutationSpecies)
			})
			Nyx_uiRefs.mutationRarity = Nyx_wrapControlFactory_var27:AddMultiDropdown({
				Name = "Mutate Egg Rarity",
				Options = Nyx_rarityFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setMutationRarities)
			})
			Nyx_uiRefs.mutationRetry = Nyx_wrapControlFactory_var27:AddToggle({
				Name = "Retry Until Mutated",
				Default = true,
				Callback = Nyx_safeInvoke(Nyx_setMutationRetry)
			})
			Nyx_uiRefs.autoMutation = Nyx_wrapControlFactory_var27:AddToggle({
				Name = "Auto Apply Mutation",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoMutation)
			})
			Nyx_wrapControlFactory_var27:AddButton({
				Name = "Apply Mutation Now",
				Callback = Nyx_safeInvoke(function()
					task.spawn(function()
						pcall(Nyx_AutoLoops.mutationSweep)
					end)
				end)
			})

			local Nyx_wrapControlFactory_var28 = Nyx_mainWindow:CreateTab({
				Name = "Pets",
				Icon = "sparkles"
			})
			local Nyx_wrapControlFactory_var29 = Nyx_wrapControlFactory_var28:CreateSection({ Name = "Pet Selling", Side = "Left" })

			Nyx_uiRefs.autoSell = Nyx_wrapControlFactory_var29:AddToggle({
				Name = "Auto Sell Pet",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoSell)
			})
			Nyx_petNameFilterRef = Nyx_wrapControlFactory_var29:AddMultiDropdown({
				Name = "Pet Name Filter",
				Options = Nyx_petNameOptions,
				Default = {},
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var7)
					NyxConfig.SellNames = Nyx_cleanList(Nyx_wrapControlFactory_var7)
				end)
			})
			Nyx_petRarityFilterRef = Nyx_wrapControlFactory_var29:AddMultiDropdown({
				Name = "Pet Rarity Filter",
				Options = Nyx_prependAll(Nyx_rarityFilterOptions),
				Default = {},
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var8)
					NyxConfig.SellRarities = Nyx_cleanList(Nyx_wrapControlFactory_var8)
				end)
			})
			Nyx_uiRefs.sellPetValue = Nyx_wrapControlFactory_var29:AddInput({
				Name = "Sell By Value (max money/s)",
				Placeholder = "e.g. 100k, 2m",
				Default = "",
				Callback = Nyx_safeInvoke(Nyx_setSellPetMaxRate)
			})

			local Nyx_wrapControlFactory_var30 = Nyx_wrapControlFactory_var28:CreateSection({ Name = "Egg Selling", Side = "Left" })

			Nyx_uiRefs.autoSellEgg = Nyx_wrapControlFactory_var30:AddToggle({
				Name = "Auto Sell Egg",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoSellEgg)
			})
			Nyx_eggRarityFilterRef = Nyx_wrapControlFactory_var30:AddMultiDropdown({
				Name = "Egg Rarity Filter",
				Options = Nyx_prependAll(Nyx_rarityFilterOptions),
				Default = {},
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var9)
					NyxConfig.SellEggRarities = Nyx_cleanList(Nyx_wrapControlFactory_var9)
				end)
			})
			Nyx_uiRefs.sellEggValue = Nyx_wrapControlFactory_var30:AddInput({
				Name = "Sell By Value (max money/s)",
				Placeholder = "e.g. 100k, 2m",
				Default = "",
				Callback = Nyx_safeInvoke(Nyx_setSellEggMaxRate)
			})

			local Nyx_wrapControlFactory_var31 = Nyx_mainWindow:CreateTab({
				Name = "Events",
				Icon = "flame"
			})
			local Nyx_wrapControlFactory_var32 = Nyx_wrapControlFactory_var28:CreateSection({ Name = "Pet Favorite", Side = "Left" })

			Nyx_uiRefs.autoFavorite = Nyx_wrapControlFactory_var32:AddToggle({
				Name = "Auto Favorite",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoFavorite)
			})
			Nyx_uiRefs.favoriteRule = Nyx_wrapControlFactory_var32:AddDropdown({
				Name = "Favorite Rule",
				Options = {
					"Rarity",
					"Species"
				},
				Default = "Rarity",
				Callback = Nyx_safeInvoke(Nyx_setFavoriteRule)
			})
			Nyx_uiRefs.favoriteRarities = Nyx_wrapControlFactory_var32:AddMultiDropdown({
				Name = "Rarities to Keep",
				Options = Nyx_rarityFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setFavoriteRarities)
			})
			Nyx_uiRefs.favoriteSpecies = Nyx_wrapControlFactory_var32:AddMultiDropdown({
				Name = "Species to Keep",
				Options = Nyx_nameFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setFavoriteSpecies)
			})
			Nyx_uiRefs.unfavoriteAll = Nyx_wrapControlFactory_var32:AddButton({
				Name = "Unfavorite Everything",
				Callback = Nyx_safeInvoke(function()
					local __NyxPetBarn = genv.__NyxPetBarn
					local Nyx_wrapControlFactory_var1 = 0

					if __NyxPetBarn and type(__NyxPetBarn.unfavoriteAll) == "function" then
						Nyx_wrapControlFactory_var1 = __NyxPetBarn.unfavoriteAll() or 0
					end

					NyxLibOverride.Notify({
						Title = "Pet Favorite",
						Text = Nyx_wrapControlFactory_var1 .. " pets unfavorited",
						Duration = 3
					})
				end)
			})

			local Nyx_wrapControlFactory_var33 = Nyx_wrapControlFactory_var28:CreateSection({ Name = "Pet Fusion", Side = "Left" })

			Nyx_uiRefs.autoFuse = Nyx_wrapControlFactory_var33:AddToggle({
				Name = "Auto Fuse",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoFusePets)
			})
			Nyx_uiRefs.fuseRule = Nyx_wrapControlFactory_var33:AddDropdown({
				Name = "Fusion Rule",
				Options = {
					"Any Species",
					"Selected Species"
				},
				Default = "Any Species",
				Callback = Nyx_safeInvoke(Nyx_setFuseRule)
			})
			Nyx_uiRefs.fuseRarities = Nyx_wrapControlFactory_var33:AddMultiDropdown({
				Name = "Rarities to Fuse",
				Options = Nyx_rarityFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setFuseRarities)
			})
			Nyx_uiRefs.fuseSpecies = Nyx_wrapControlFactory_var33:AddMultiDropdown({
				Name = "Species to Fuse",
				Options = Nyx_nameFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setFuseSpecies)
			})

			local Nyx_wrapControlFactory_var34 = Nyx_wrapControlFactory_var26:CreateSection({ Name = "Equip & Collect", Side = "Left" })

			Nyx_uiRefs.autoEquipBest = Nyx_wrapControlFactory_var34:AddToggle({
				Name = "Auto Equip Best",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoEquipBest)
			})
			Nyx_uiRefs.autoClaimOffline = Nyx_wrapControlFactory_var34:AddToggle({
				Name = "Collect Offline Income",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoClaimOffline)
			})
			Nyx_uiRefs.autoBaseUpgrade = Nyx_wrapControlFactory_var34:AddToggle({
				Name = "Auto Upgrade Base",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoBaseUpgrade)
			})
			Nyx_uiRefs.autoClaimAlmanac = Nyx_wrapControlFactory_var34:AddToggle({
				Name = "Auto Claim Almanac",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoClaimAlmanac)
			})
			Nyx_uiRefs.upgradeBaseOnce = Nyx_wrapControlFactory_var34:AddButton({
				Name = "Upgrade Base Now",
				Callback = Nyx_safeInvoke(function()
					local __NyxUpgrades = genv.__NyxUpgrades
					local Nyx_wrapControlFactory_var35 = false
					local Nyx_wrapControlFactory_var18 = "Upgrades not ready"

					if __NyxUpgrades and type(__NyxUpgrades.upgradeBase) == "function" then
						Nyx_wrapControlFactory_var35, Nyx_wrapControlFactory_var18 = __NyxUpgrades.upgradeBase()
					end

					local Notify = NyxLibOverride.Notify
					local Nyx_wrapControlFactory_var19 = {
						Title = "Base"
					}
					local content = Nyx_wrapControlFactory_var35 and "Base upgraded"

					if not content then
						content = tostring(Nyx_wrapControlFactory_var18 or "Could not upgrade")
					end

					Nyx_wrapControlFactory_var19.Text = content
					Nyx_wrapControlFactory_var19.Duration = 3
					NyxLibOverride.Notify(Nyx_wrapControlFactory_var19)
				end)
			})

			local __NyxButterflyRuntime = genv.__NyxButterflyRuntime
			local Nyx_wrapControlFactory_var36 = Nyx_wrapControlFactory_var31:CreateSection({ Name = "Butterfly Bloom", Side = "Left" })
			local Nyx_bloomStatusRow = Nyx_wrapControlFactory_var36:AddLabel("Bloom Status")

			Nyx_uiRefs.bloomAutoNet = Nyx_wrapControlFactory_var36:AddToggle({
				Name = "Auto Claim Net",
				Default = false,
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var10)
					NyxConfig.ButterflyAutoNet = Nyx_wrapControlFactory_var10 == true
				end)
			})
			Nyx_uiRefs.bloomAutoCatch = Nyx_wrapControlFactory_var36:AddToggle({
				Name = "Auto Catch",
				Default = false,
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var11)
					NyxConfig.ButterflyAutoCatch = Nyx_wrapControlFactory_var11 == true
				end)
			})

			local Nyx_bloomModeOptions = __NyxButterflyRuntime and __NyxButterflyRuntime.modeOptions() or { "Tween to Butterfly" }

			Nyx_uiRefs.bloomMode = Nyx_wrapControlFactory_var36:AddDropdown({
				Name = "Catch Mode",
				Options = Nyx_bloomModeOptions,
				Default = Nyx_bloomModeOptions[1],
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var12)
					if __NyxButterflyRuntime then
						__NyxButterflyRuntime.setMode(Nyx_wrapControlFactory_var12)
					end
				end)
			})
			Nyx_uiRefs.bloomTiers = Nyx_wrapControlFactory_var36:AddMultiDropdown({
				Name = "Catch Tiers",
				Options = __NyxButterflyRuntime and __NyxButterflyRuntime.tierOptions() or {
					"Radiant",
					"Amethyst",
					"Sapphire",
					"Emerald"
				},
				Default = {},
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var13)
					if __NyxButterflyRuntime then
						__NyxButterflyRuntime.setTiers(Nyx_cleanList(Nyx_wrapControlFactory_var13))
					end
				end)
			})
			Nyx_uiRefs.bloomEsp = Nyx_wrapControlFactory_var36:AddToggle({
				Name = "Butterfly ESP",
				Default = false,
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var14)
					NyxConfig.ButterflyEsp = Nyx_wrapControlFactory_var14 == true
				end)
			})
			Nyx_uiRefs.bloomAutoTrade = Nyx_wrapControlFactory_var36:AddToggle({
				Name = "Auto Trade Up",
				Default = false,
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var15)
					NyxConfig.ButterflyAutoTrade = Nyx_wrapControlFactory_var15 == true
				end)
			})

			local Nyx_bloomRecipeOptions = __NyxButterflyRuntime and __NyxButterflyRuntime.recipeOptions() or { "All Recipes" }

			Nyx_uiRefs.bloomRecipe = Nyx_wrapControlFactory_var36:AddDropdown({
				Name = "Trade Recipe",
				Options = Nyx_bloomRecipeOptions,
				Default = Nyx_bloomRecipeOptions[1],
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var16)
					if __NyxButterflyRuntime then
						__NyxButterflyRuntime.setRecipe(Nyx_wrapControlFactory_var16)
					end
				end)
			})
			Nyx_uiRefs.bloomAutoCraft = Nyx_wrapControlFactory_var36:AddToggle({
				Name = "Auto Craft Essence",
				Default = false,
				Callback = Nyx_safeInvoke(function(Nyx_wrapControlFactory_var17)
					NyxConfig.ButterflyAutoCraft = Nyx_wrapControlFactory_var17 == true
				end)
			})

			local function Nyx_wrapControlFactory_var37(Nyx_v4822_var1, Nyx_v4822_var2, Nyx_v4822_var3, Nyx_v4822_var4)
				Nyx_wrapControlFactory_var36:AddButton({
					Title = Nyx_v4822_var1,
					Content = Nyx_v4822_var2,
					Callback = Nyx_safeInvoke(function()
						if not __NyxButterflyRuntime then
							return
						end

						task.spawn(function()
							__NyxButterflyRuntime.manual = true

							local ok, result, result2 = pcall(Nyx_v4822_var3)

							__NyxButterflyRuntime.manual = false

							if not ok then
								local Nyx_v4822_var14 = result

								result = false
								result2 = Nyx_v4822_var14
							end

							local Notify = NyxLibOverride.Notify
							local Nyx_v4822_var13 = {
								Title = "Butterfly Bloom"
							}
							local content = result and Nyx_v4822_var4(result2)

							if not content then
								content = tostring(result2 or "Could not do that")
							end

							Nyx_v4822_var13.Text = content
							Nyx_v4822_var13.Duration = 4
							NyxLibOverride.Notify(Nyx_v4822_var13)
						end)
					end)
				})
			end

			Nyx_wrapControlFactory_var37("Claim Net Now", "Claims the Butterfly Net right now.", function()
				return __NyxButterflyRuntime.claimNet()
			end, function()
				return "Butterfly Net claimed"
			end)
			Nyx_wrapControlFactory_var37("Trade Up Now", "Runs the trade recipe once, even with Auto Trade Up off.", function()
				return __NyxButterflyRuntime.tradeUp()
			end, function(Nyx_v4822_var5)
				return ("Traded up %d time(s)"):format(tonumber(Nyx_v4822_var5) or 0)
			end)
			Nyx_wrapControlFactory_var37("Craft Essence Now", "Crafts Enchanted Essence right now if you hold the full recipe.", function()
				return __NyxButterflyRuntime.craft()
			end, function(Nyx_v4822_var6)
				return ("Crafted %d Enchanted Essence"):format(tonumber(Nyx_v4822_var6) or 0)
			end)
			task.spawn(function()
				while Nyx_isCurrentSession() do
					if __NyxButterflyRuntime then
						pcall(function()
							local snap = __NyxButterflyRuntime.snap
							local Nyx_butterflyTiersForDisplay = __NyxButterflyRuntime.tiers() or {}
							local Nyx_bloomStatusText2

							if snap.active then
								local Nyx_bloomRemainingSec = math.floor(snap.left or 0)

								Nyx_bloomStatusText2 = ("LIVE - ends in %dm %02ds"):format(math.floor(Nyx_bloomRemainingSec / 60), Nyx_bloomRemainingSec % 60)
							elseif snap.enabled == false then
								Nyx_bloomStatusText2 = "Disabled on this server"
							elseif snap.nextIn then
								local Nyx_bloomNextInSec = math.floor(snap.nextIn)

								Nyx_bloomStatusText2 = ("Next in %dm %02ds"):format(math.floor(Nyx_bloomNextInSec / 60), Nyx_bloomNextInSec % 60)
							else
								Nyx_bloomStatusText2 = "Not running"
							end

							local Nyx_bloomAction_var1 = {}

							for _, v in ipairs({
								"Golden",
								"Purple",
								"Blue",
								"Green"
							}) do
								Nyx_bloomAction_var1[#Nyx_bloomAction_var1 + 1] = ("%s %d"):format(Nyx_butterflyTiersForDisplay[v] and Nyx_butterflyTiersForDisplay[v].name or v, snap.counts and snap.counts[v] or 0)
							end

							Nyx_bloomStatusRow:SetContent(("%s\n%s  ·  Essence %d  ·  Caught %d\n%s\n%s"):format(Nyx_bloomStatusText2, snap.net and (snap.holding and "Net equipped" or "Net owned") or "No Butterfly Net", snap.essence or 0, snap.caught or 0, table.concat(Nyx_bloomAction_var1, "  ·  "), tostring(__NyxButterflyRuntime.status or "Idle")))
						end)
					end

					task.wait(1)
				end
			end)

			local Nyx_v4822_var15 = Nyx_wrapControlFactory_var31:CreateSection({ Name = "Dr Scramble Event", Side = "Left" })

			Nyx_v4822_var15:AddLabel("About This Event")
			Nyx_uiRefs.scrambleBuy = Nyx_v4822_var15:AddToggle({
				Name = "Auto Buy Shop",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setScrambleAutoBuy)
			})
			Nyx_uiRefs.scrambleBuyList = Nyx_v4822_var15:AddMultiDropdown({
				Name = "Shop Buy List",
				Options = Nyx_scrambleBuyOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setScrambleBuyList)
			})
			Nyx_uiRefs.scrambleTradeInTrade = Nyx_v4822_var15:AddToggle({
				Name = "Auto Trade-In",
				Default = false,
				Callback = Nyx_safeInvoke(function(Nyx_v4822_var7)
					NyxConfig.ScrambleTradeInTrade = Nyx_v4822_var7 == true
				end)
			})
			Nyx_uiRefs.scrambleTradeInReroll = Nyx_v4822_var15:AddToggle({
				Name = "Auto Free Reroll",
				Default = false,
				Callback = Nyx_safeInvoke(function(Nyx_v4822_var8)
					NyxConfig.ScrambleTradeInReroll = Nyx_v4822_var8 == true
				end)
			})
			Nyx_uiRefs.scrambleTradeInBanners = Nyx_v4822_var15:AddMultiDropdown({
				Name = "Target Banners",
				Options = {
					"Biohazard Pets",
					"Experimental Pets",
					"Unstable DNA"
				},
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setScrambleBanners)
			})
			Nyx_v4822_var15:AddButton({
				Name = "Trade-In Once",
				Callback = Nyx_safeInvoke(function()
					local __NyxScrambleTradeIn = genv.__NyxScrambleTradeIn
					local Nyx_v4822_var16 = false
					local Nyx_v4822_var11 = "Trade-In not ready"

					if __NyxScrambleTradeIn then
						Nyx_v4822_var16, Nyx_v4822_var11 = __NyxScrambleTradeIn.tradeOnce()
					end

					NyxLibOverride.Notify({
						Title = "Dr Scramble",
						Text = Nyx_v4822_var16 and "Sacrifice complete" or tostring(Nyx_v4822_var11),
						Duration = 4
					})
				end)
			})
			Nyx_v4822_var15:AddButton({
				Name = "Use Free Reroll",
				Callback = Nyx_safeInvoke(function()
					local __NyxScrambleTradeIn = genv.__NyxScrambleTradeIn
					local Nyx_v4822_var17 = false
					local Nyx_v4822_var12 = "Trade-In not ready"

					if __NyxScrambleTradeIn then
						Nyx_v4822_var17, Nyx_v4822_var12 = __NyxScrambleTradeIn.reroll()
					end

					NyxLibOverride.Notify({
						Title = "Dr Scramble",
						Text = Nyx_v4822_var17 and "Recipe rerolled" or tostring(Nyx_v4822_var12),
						Duration = 4
					})
				end)
			})
			Nyx_v4822_var15:AddButton({
				Name = "Open Trade-In UI",
				Callback = Nyx_safeInvoke(function()
					if not pcall(function()
						require(ReplicatedStorage.Client.Tabs).Activate("DrScrambleTradeIn")
					end) then
						NyxLibOverride.Notify({
							Title = "Dr Scramble",
							Text = "Could not open the trade-in window",
							Duration = 3
						})
					end
				end)
			})

			local Nyx_tradeInStatusRow = Nyx_v4822_var15:AddLabel("Trade-In Status")

			task.spawn(function()
				while Nyx_isCurrentSession() do
					local __NyxScrambleTradeIn = genv.__NyxScrambleTradeIn

					if __NyxScrambleTradeIn then
						pcall(function()
							Nyx_tradeInStatusRow:SetContent(string.format([[%s  ·  %s
Rotates in %02d:%02d  ·  Pity %d/%d  ·  Free rerolls %d  ·  Traded %d
Recipe (%d/%d): %s
Held: %s
Missing: %s]], __NyxScrambleTradeIn.banner, __NyxScrambleTradeIn.status, math.floor(__NyxScrambleTradeIn.rotation / 60), __NyxScrambleTradeIn.rotation % 60, __NyxScrambleTradeIn.pity, __NyxScrambleTradeIn.pityMax, __NyxScrambleTradeIn.free, __NyxScrambleTradeIn.trades, __NyxScrambleTradeIn.ready, __NyxScrambleTradeIn.total, __NyxScrambleTradeIn.demands, __NyxScrambleTradeIn.stock, __NyxScrambleTradeIn.missing))
						end)
					end

					task.wait(1)
				end
			end)
			Nyx_uiRefs.scrambleBossAuto = Nyx_v4822_var15:AddToggle({
				Name = "Auto Boss",
				Default = false,
				Callback = Nyx_safeInvoke(function(Nyx_v4822_var9)
					NyxConfig.ScrambleBossAuto = Nyx_v4822_var9 == true

					if Nyx_eggRuntime and type(Nyx_eggRuntime._reconcileScramblePortal) == "function" then
						pcall(Nyx_eggRuntime._reconcileScramblePortal, Nyx_eggRuntime)
					end
				end)
			})

			local Nyx_bossStatusRow = Nyx_v4822_var15:AddLabel("Boss Status")

			task.spawn(function()
				while Nyx_isCurrentSession() do
					local __NyxScrambleBoss = genv.__NyxScrambleBoss

					if __NyxScrambleBoss then
						pcall(function()
							Nyx_bossStatusRow:SetContent(string.format("%s  ·  joins %d  ·  hits %d", tostring(__NyxScrambleBoss.status), __NyxScrambleBoss.joins or 0, __NyxScrambleBoss.hits or 0))
						end)
					end

					task.wait(1)
				end
			end)

			local Treadmill = Nyx_wrapControlFactory_var26:CreateSection({ Name = "Treadmill", Side = "Left" })

			Nyx_uiRefs.autoTreadmill = Treadmill:AddToggle({
				Name = "Auto Treadmill",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoTreadmillIdle)
			})
			Nyx_uiRefs.treadmillUpgrade = Treadmill:AddToggle({
				Name = "Auto Upgrade Treadmill",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoTreadmillUpgrade)
			})
		end

		do
			local Nyx_v4822_var18 = Nyx_mainWindow:CreateTab({
				Name = "Misc",
				Icon = "settings"
			})
			local Performance = Nyx_v4822_var18:CreateSection({ Name = "Performance", Side = "Left" })

			Nyx_uiRefs.startupBoost = Performance:AddToggle({
				Name = "Startup Boost",
				Default = true,
				Callback = Nyx_safeInvoke(Nyx_setStartupBoost)
			})
			Nyx_uiRefs.boostFps = Performance:AddToggle({
				Name = "Boost FPS",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_runFpsBoostOnce)
			})
			Nyx_uiRefs.uncapFps = Performance:AddToggle({
				Name = "Uncap FPS",
				Default = true,
				Callback = Nyx_safeInvoke(Nyx_setFpsCap)
			})

			local Guard = Nyx_v4822_var18:CreateSection({ Name = "Guard", Side = "Left" })

			Nyx_uiRefs.antiGuardKnockback = Guard:AddToggle({
				Name = "Anti Guard Knockback",
				Default = true,
				Callback = Nyx_safeInvoke(Nyx_setAntiGuardKnockback)
			})
			Nyx_uiRefs.antiHitGuard = Guard:AddToggle({
				Name = "Anti Hit Guard",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAntiHitGuard)
			})

			local Windows = Nyx_v4822_var18:CreateSection({ Name = "Windows", Side = "Left" })

			Windows:AddButton({
				Name = "Egg Logs",
				Callback = Nyx_safeInvoke(function()
					NyxPanels.openLogs()
				end)
			})
			Windows:AddButton({
				Name = "Egg Board",
				Callback = Nyx_safeInvoke(function()
					NyxPanels.openBoard()
				end)
			})
			Windows:AddButton({
				Name = "Inventory & Base",
				Callback = Nyx_safeInvoke(function()
					NyxPanels.openInventory()
				end)
			})
			Windows:AddButton({
				Name = "Egg Checker",
				Callback = Nyx_safeInvoke(function()
					NyxPanels.openChecker()
				end)
			})
			Windows:AddButton({
				Name = "Egg Data & History",
				Callback = Nyx_safeInvoke(function()
					NyxPanels.openAnalyst()
				end)
			})
			Windows:AddButton({
				Name = "Open All Windows",
				Callback = Nyx_safeInvoke(function()
					NyxPanels.openAll()
				end),
				SubCallback = Nyx_safeInvoke(function()
					NyxPanels.closeAll()
				end)
			})
			Nyx_uiRefs.antiTreadmill = Nyx_v4822_var18:CreateSection({ Name = "Blocker", Side = "Left" }):AddToggle({
				Name = "Anti Treadmill",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAntiTreadmill)
			})

			local Nyx_v4822_var19 = Nyx_v4822_var18:CreateSection({ Name = "Server Hop", Side = "Left" })

			Nyx_uiRefs.hopNoMatch = Nyx_v4822_var19:AddToggle({
				Name = "Hop When Nothing Matches",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setHopNoMatch)
			})
			Nyx_uiRefs.hopCooldown = Nyx_v4822_var19:AddSlider({
				Name = "Hop Cooldown",
				Min = 1,
				Max = 60,
				Default = 5,
				Callback = Nyx_safeInvoke(Nyx_setHopCooldown)
			})

			local Nyx_v4822_var20 = Nyx_uiRefs.privateTab:CreateSection({ Name = "Find Private Server", Side = "Left" })
			local Nyx_serverStatusRow = Nyx_v4822_var20:AddLabel("Current Server")

			Nyx_uiRefs.privateServerMax = Nyx_v4822_var20:AddDropdown({
				Name = "Max Players",
				Options = {
					"1",
					"2",
					"3",
					"4",
					"5"
				},
				Default = "2",
				Callback = Nyx_safeInvoke(Nyx_setPrivateServerMax)
			})
			Nyx_v4822_var20:AddButton({
				Name = "Hop Server Now",
				Callback = Nyx_safeInvoke(function()
					task.spawn(function()
						Nyx_ServerHop.hopPrivateOnce()
					end)
				end)
			})
			Nyx_uiRefs.privateServerAuto = Nyx_v4822_var20:AddToggle({
				Name = "Auto Hop",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setPrivateServerAuto)
			})
			task.spawn(function()
				local Nyx_lastServerStatusText

				while Nyx_isCurrentSession() do
					local Nyx_serverStatusText = "Now: " .. #Players:GetPlayers() .. " player(s)  ·  Max: " .. Nyx_ServerHop.privateMax() .. "\n" .. tostring(Nyx_ServerHop.privateStatus or "")

					if Nyx_serverStatusText ~= Nyx_lastServerStatusText then
						Nyx_lastServerStatusText = Nyx_serverStatusText
						pcall(function()
							Nyx_serverStatusRow:SetContent(Nyx_serverStatusText)
						end)
					end

					task.wait(1)
				end
			end)

			local Roaming = Nyx_v4822_var18:CreateSection({ Name = "Roaming", Side = "Left" })

			Nyx_uiRefs.waypoint = Roaming:AddDropdown({
				Name = "Waypoint",
				Options = Nyx_waypoints,
				Default = Nyx_waypoints[1],
				Callback = Nyx_safeInvoke(function(Nyx_v4822_var10)
					Nyx_setFpsCap_var1 = Nyx_v4822_var10
				end)
			})
			Roaming:AddButton({
				Name = "Teleport To Waypoint",
				Callback = Nyx_safeInvoke(function()
					local __NyxRoaming = genv.__NyxRoaming
					local Nyx_v4822_var21 = false

					if __NyxRoaming and type(__NyxRoaming.teleportWaypoint) == "function" then
						Nyx_v4822_var21 = __NyxRoaming.teleportWaypoint(Nyx_setFpsCap_var1) == true
					end

					NyxLibOverride.Notify({
						Title = "Waypoint",
						Text = Nyx_v4822_var21 and "Moved to " .. tostring(Nyx_setFpsCap_var1) or "That waypoint is not in this server",
						Duration = 3
					})
				end)
			})

			local Nyx_v4822_var22 = Nyx_v4822_var18:CreateSection({ Name = "Run Once", Side = "Left" })

			Nyx_v4822_var22:AddButton({
				Name = "Place Everything Now",
				Callback = Nyx_safeInvoke(function()
					runOnce("AutoPlace", Nyx_AutoLoops.AutoPlaceLoop)
				end)
			})
			Nyx_v4822_var22:AddButton({
				Name = "Hatch Everything Ready",
				Callback = Nyx_safeInvoke(function()
					runOnce("AutoHatch", Nyx_AutoLoops.AutoHatchLoop)
				end)
			})
			Nyx_v4822_var22:AddButton({
				Name = "Sell Pets Now",
				Callback = Nyx_safeInvoke(function()
					runOnce("AutoSell", Nyx_AutoLoops.startAutoSellLoop)
				end)
			})
			Nyx_v4822_var22:AddButton({
				Name = "Sell Eggs Now",
				Callback = Nyx_safeInvoke(function()
					runOnce("AutoSellEgg", Nyx_AutoLoops.startAutoSellEggLoop)
				end)
			})

			local Session = Nyx_v4822_var18:CreateSection({ Name = "Session", Side = "Left" })

			Nyx_uiRefs.bottingMode = Session:AddToggle({
				Name = "Botting Mode",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setBottingMode)
			})
			Nyx_uiRefs.antiCutscene = Session:AddToggle({
				Name = "Anti Cutscene",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAntiCutscene)
			})
			Session:AddButton({
				Name = "Rejoin This Server",
				Callback = Nyx_safeInvoke(function()
					pcall(function()
						game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
					end)
				end)
			})
			Session:AddButton({
				Name = "Stop & Unload",
				Callback = Nyx_safeInvoke(function()
					for _, v in ipairs({
						"AutoSteal",
						"AutoPlace",
						"AutoHatch",
						"AutoSell",
						"AutoSellEgg",
						"StealPlayers",
						"AutoFavorite",
						"AutoFusePets",
						"AutoEquipBest",
						"AutoClaimOffline",
						"AutoBaseUpgrade",
						"AutoClaimAlmanac",
						"Noclip",
						"BottingMode",
						"AntiCutscene"
					}) do
						NyxConfig[v] = false
					end

					Nyx_setNoclip(false)
					Nyx_setBottingMode(false)

					if Nyx_eggRuntime then
						pcall(Nyx_eggRuntime.setEnabled, Nyx_eggRuntime, false)
					end

					local __NyxHubShutdown = genv.__NyxHubShutdown

					if type(__NyxHubShutdown) == "function" then
						task.delay(0.2, function()
							pcall(__NyxHubShutdown)
						end)
					end
				end)
			})

			local Player = Nyx_v4822_var18:CreateSection({ Name = "Player", Side = "Left" })

			Nyx_uiRefs.antiAfk = Player:AddToggle({
				Name = "Anti AFK",
				Default = true,
				Callback = Nyx_safeInvoke(Nyx_setAntiAfk)
			})
			Nyx_uiRefs.autoReconnect = Player:AddToggle({
				Name = "Auto Reconnect",
				Default = true,
				Callback = Nyx_safeInvoke(Nyx_setAutoReconnect)
			})
			Nyx_uiRefs.autoExecute = Player:AddToggle({
				Name = "Auto Execute (Rejoin)",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setAutoExecute)
			})
		end

		do
			local Nyx_v4822_var23 = Nyx_mainWindow:CreateTab({
				Name = "Steal Players",
				Icon = "swords"
			})
			local Nyx_v4822_var24 = Nyx_v4822_var23:CreateSection({ Name = "Auto Steal", Side = "Left" })

			Nyx_uiRefs.stealPlayers = Nyx_v4822_var24:AddToggle({
				Name = "Auto Steal From Players",
				Default = false,
				Callback = Nyx_safeInvoke(Nyx_setStealPlayers)
			})
			Nyx_uiRefs.stealPlayerRarities = Nyx_v4822_var24:AddMultiDropdown({
				Name = "Rarity Filter",
				Options = Nyx_rarityFilterOptions,
				Default = {},
				Callback = Nyx_safeInvoke(Nyx_setStealPlayerRarities)
			})
			Nyx_uiRefs.stealPlayerValue = Nyx_v4822_var24:AddInput({
				Name = "Minimum Value",
				Placeholder = "e.g. 500k, 2m, 1b",
				Default = "",
				Callback = Nyx_safeInvoke(Nyx_setStealPlayerMinValue)
			})

			local Nyx_v4822_var25 = Nyx_v4822_var23:CreateSection({ Name = "Steal From Specific Player", Side = "Left" })
			local Nyx_v4822_var26 = Nyx_v4822_var23:CreateSection({ Name = "Steal History", Side = "Left" })
			local Nyx_v4822_var27
			local Nyx_v4822_var28

			if Nyx_v4822_var25.AddActionList then
				Nyx_v4822_var27 = Nyx_v4822_var25:AddActionList({
					Name = "Players in this server",
					EmptyText = "Nobody else is in this server.",
					VisibleRows = 6,
					ButtonWidth = 76
				})
				Nyx_v4822_var28 = Nyx_v4822_var26:AddActionList({
					Name = "History of stolen eggs from players",
					EmptyText = "No player steals yet.",
					VisibleRows = 5,
					ButtonWidth = 72
				})
			else
				Nyx_v4822_var25:AddLabel("Update required")
			end

			Nyx_v4822_var26:AddButton({
				Name = "Clear History",
				Callback = Nyx_safeInvoke(function()
					if __NyxPlayerSteal then
						__NyxPlayerSteal:clearHistory()
					end
				end)
			})

			if __NyxPlayerSteal and Nyx_v4822_var27 then
				local __NyxIdentitySetter = genv.__NyxIdentitySetter
				local __NyxUICapabilityIdentity = genv.__NyxUICapabilityIdentity or 8

				local function Nyx_v4822_var29(Nyx_v4877_var1)
					if __NyxIdentitySetter then
						pcall(__NyxIdentitySetter, __NyxUICapabilityIdentity)
					end

					if not Nyx_v4822_var28 or not Nyx_v4822_var28:Alive() then
						return
					end

					local Nyx_v4877_var2 = {}

					for i, v in ipairs(Nyx_v4877_var1.history) do
						Nyx_v4877_var2[i] = {
							id = tostring(i),
							name = v.player,
							sub = string.format("<font color=\"#A2A2AE\">%s</font>", os.date("!%H:%M:%S", v.at)),
							status = v.egg,
							statusSub = v.outcome,
							button = false
						}
					end

					Nyx_v4822_var28:Update(Nyx_v4877_var2)
				end

				__NyxPlayerSteal:onChanged(Nyx_v4822_var29)
				Nyx_v4822_var29(__NyxPlayerSteal)
				task.spawn(function()
					while genv.__NyxPlayerSteal == __NyxPlayerSteal do
						local ok, result = pcall(function()
							local Nyx_v4877_var3 = __NyxPlayerSteal:listEntries()

							if __NyxIdentitySetter then
								pcall(__NyxIdentitySetter, __NyxUICapabilityIdentity)
							end

							if Nyx_v4822_var27:Alive() then
								Nyx_v4822_var27:Update(Nyx_v4877_var3)
							end
						end)

						if not ok then
							warn("[Nyx Steal] Player list update loop error:", result)
						end

						task.wait(1)
					end
				end)
			end
		end

		Nyx_mainWindow:CreateTab({
			Name = "Live Chat",
			Icon = "chat"
			Title = "Live Chat",
			Height = 300
		})

		if type(Nyx_mainWindow.AddForum) == "function" then
			Nyx_mainWindow:AddForum({
				Name = "Forum",
				Icon = "forum",
				Section = "Config Forum"
			})
		end

		do
			local __NyxVisual = genv.__NyxVisual
			local Nyx_v4877_var4 = Nyx_mainWindow:CreateTab({
				Name = "Visual",
				Icon = "eye"
			})
			local Nyx_bloomAction_var2 = {
				rods = nil,
				fish = nil
			}
			local Nyx_visualStatusRow

			local function Nyx_updateVisualStatus()
				if Nyx_visualStatusRow and __NyxVisual then
					pcall(function()
						Nyx_visualStatusRow:SetContent(__NyxVisual.status)
					end)
				end
			end
			local function Nyx_spawnVisualItem(Nyx_spawnVisualItem_var1_2)
				if not __NyxVisual then
					return
				end

				task.spawn(function()
					__NyxVisual.spawn(Nyx_spawnVisualItem_var1_2, Nyx_bloomAction_var2[Nyx_spawnVisualItem_var1_2])
					Nyx_updateVisualStatus()
					NyxLibOverride.Notify({
						Title = "Visual",
						Text = __NyxVisual.status,
						Duration = 3
					})
				end)
				task.delay(0.1, Nyx_updateVisualStatus)
			end

			local Nyx_spawnVisualItem_var9 = Nyx_v4877_var4:CreateSection({ Name = "Fish It", Side = "Left" })


			local Nyx_spawnVisualItem_var10 = Nyx_spawnVisualItem_var9:AddDropdown({
				Name = "Select Rod",
				Options = {},
				Default = nil,
				Callback = Nyx_safeInvoke(function(Nyx_spawnVisualItem_var2_2)
					Nyx_bloomAction_var2.rods = Nyx_spawnVisualItem_var2_2
				end)
			})

			Nyx_spawnVisualItem_var9:AddButton({
				Name = "Spawn Rod",
				Callback = Nyx_safeInvoke(function()
					Nyx_spawnVisualItem("rods")
				end)
			})
			Nyx_spawnVisualItem_var9:AddSlider({
				Name = "Rod Size",
				Min = 0.5,
				Max = 2,
				Default = 1,
				Callback = Nyx_safeInvoke(function(Nyx_spawnVisualItem_var3_2)
					if not __NyxVisual or __NyxVisual.rodScale == Nyx_spawnVisualItem_var3_2 then
						return
					end

					__NyxVisual.rodScale = Nyx_spawnVisualItem_var3_2
					task.spawn(__NyxVisual.respawn, "rods")
				end)
			})

			local Nyx_spawnVisualItem_var11 = Nyx_spawnVisualItem_var9:AddDropdown({
				Name = "Select Fish",
				Options = {},
				Default = nil,
				Callback = Nyx_safeInvoke(function(Nyx_spawnVisualItem_var4)
					Nyx_bloomAction_var2.fish = Nyx_spawnVisualItem_var4
				end)
			})

			Nyx_spawnVisualItem_var9:AddButton({
				Name = "Spawn Fish",
				Callback = Nyx_safeInvoke(function()
					Nyx_spawnVisualItem("fish")
				end)
			})
			Nyx_spawnVisualItem_var9:AddSlider({
				Name = "Fish Weight",
				Min = 0,
				Max = 100,
				Default = 0,
				Callback = Nyx_safeInvoke(function(Nyx_spawnVisualItem_var5)
					local fishWeight = (tonumber(Nyx_spawnVisualItem_var5) or 0) / 100

					if not __NyxVisual or __NyxVisual.fishWeight == fishWeight then
						return
					end

					__NyxVisual.fishWeight = fishWeight
					task.spawn(__NyxVisual.respawn, "fish")
				end)
			})
			Nyx_visualStatusRow = Nyx_spawnVisualItem_var9:AddLabel("Status")
			Nyx_spawnVisualItem_var9:AddButton({
				Name = "Remove All Visual Items",
				Callback = Nyx_safeInvoke(function()
					if __NyxVisual then
						__NyxVisual.clear()
					end

					Nyx_updateVisualStatus()
				end)
			})
			task.spawn(function()
				if not __NyxVisual then
					return
				end

				local rods = __NyxVisual.names("rods")
				local fish = __NyxVisual.names("fish")

				pcall(function()
					Nyx_spawnVisualItem_var10:Refresh(rods)
				end)
				pcall(function()
					Nyx_spawnVisualItem_var11:Refresh(fish)
				end)
				__NyxVisual.status = #rods > 0 and string.format("%d rods and %d fish available", #rods, #fish) or "Could not load the item list. Try again later."
				Nyx_updateVisualStatus()
			end)

			local Nyx_spawnVisualItem_var12 = Nyx_v4877_var4:CreateSection({ Name = "Steal an Egg", Side = "Left" })
			local Nyx_spawnVisualItem_var2 = "Egg"
			local Nyx_spawnVisualItem_var1 = 50
			local Egg = genv.__NyxVisualSAE and genv.__NyxVisualSAE.categories("Egg") or {}
			local Nyx_spawnVisualItem_var3 = Egg[1]

			Nyx_spawnVisualItem_var12:AddDropdown({
				Name = "Type",
				Options = {
					"Egg",
					"Pet"
				},
				Default = "Egg",
				Callback = Nyx_safeInvoke(function(Nyx_spawnVisualItem_var6)
					Nyx_spawnVisualItem_var2 = Nyx_spawnVisualItem_var6 or "Egg"
				end)
			})
			Nyx_spawnVisualItem_var12:AddDropdown({
				Name = "Select Egg / Pet",
				Options = Egg,
				Default = Egg[1],
				Callback = Nyx_safeInvoke(function(Nyx_spawnVisualItem_var7)
					Nyx_spawnVisualItem_var3 = Nyx_spawnVisualItem_var7
				end)
			})
			Nyx_spawnVisualItem_var12:AddSlider({
				Name = "Size / Flex",
				Min = 1,
				Max = 100,
				Default = 50,
				Callback = Nyx_safeInvoke(function(Nyx_spawnVisualItem_var8)
					Nyx_spawnVisualItem_var1 = tonumber(Nyx_spawnVisualItem_var8) or 50
				end)
			})
			Nyx_spawnVisualItem_var12:AddButton({
				Name = "Hold in Hand",
				Callback = Nyx_safeInvoke(function()
					local __NyxVisualSAE = genv.__NyxVisualSAE

					if __NyxVisualSAE then
						__NyxVisualSAE.spawn(Nyx_spawnVisualItem_var2, Nyx_spawnVisualItem_var3, Nyx_spawnVisualItem_var1, true)
					end
				end)
			})
			Nyx_spawnVisualItem_var12:AddButton({
				Name = "Add to Backpack (Kg)",
				Callback = Nyx_safeInvoke(function()
					local __NyxVisualSAE = genv.__NyxVisualSAE

					if __NyxVisualSAE then
						__NyxVisualSAE.spawn(Nyx_spawnVisualItem_var2, Nyx_spawnVisualItem_var3, Nyx_spawnVisualItem_var1, false)
					end
				end)
			})
			Nyx_spawnVisualItem_var12:AddButton({
				Name = "Remove Egg / Pet Visuals",
				Callback = Nyx_safeInvoke(function()
					local __NyxVisualSAE = genv.__NyxVisualSAE

					if __NyxVisualSAE then
						__NyxVisualSAE.clear()
					end
				end)
			})
		end

		Nyx_mainWindow:CreateTab({
			Name = "Donate",
			Icon = "donator"
		do
			local function Nyx_applySavedConfigFn(Nyx_applySavedConfigFn_var1, Nyx_applySavedConfigFn_var2)
				Nyx_applyElevatedIdentityFn()

				if type(Nyx_applySavedConfigFn_var1) == "table" and Nyx_applySavedConfigFn_var1.Value ~= nil then
					pcall(Nyx_applySavedConfigFn_var2, Nyx_applySavedConfigFn_var1.Value)
				end
			end


			do
				local v4TabConfig = Nyx_mainWindow:CreateTab({
					Name = "Config",
					Icon = "settings"
				})
				local v4SecConfig = v4TabConfig:CreateSection({ Name = "Config Manager", Side = "Left" })
				v4SecConfig:ApplyConfigManager({})
			end
			Nyx_uiSetupDone = false
			Nyx_applySavedConfigFn(Nyx_uiRefs.speed, Nyx_setTweenSpeedSlider)
			Nyx_applySavedConfigFn(Nyx_uiRefs.stealMode, Nyx_setStealMode)
			Nyx_applySavedConfigFn(Nyx_uiRefs.stealHold, Nyx_setStealHold)
			Nyx_applySavedConfigFn(Nyx_uiRefs.antiTreadmill, Nyx_setAntiTreadmill)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoTreadmill, Nyx_setAutoTreadmillIdle)
			Nyx_applySavedConfigFn(Nyx_uiRefs.treadmillUpgrade, Nyx_setAutoTreadmillUpgrade)
			Nyx_applySavedConfigFn(Nyx_uiRefs.hopCooldown, Nyx_setHopCooldown)
			Nyx_applySavedConfigFn(Nyx_uiRefs.hopNoMatch, Nyx_setHopNoMatch)
			Nyx_applySavedConfigFn(Nyx_uiRefs.privateServerMax, Nyx_setPrivateServerMax)
			Nyx_applySavedConfigFn(Nyx_uiRefs.privateServerAuto, Nyx_setPrivateServerAuto)
			Nyx_applySavedConfigFn(Nyx_uiRefs.names, function(Nyx_applySavedConfigFn_var3)
				Nyx_setStealFilter("names", "name", Nyx_applySavedConfigFn_var3)
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.areas, function(Nyx_applySavedConfigFn_var4)
				Nyx_setStealFilter("areas", "area", Nyx_applySavedConfigFn_var4)
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.rarities, function(Nyx_applySavedConfigFn_var5)
				Nyx_setStealFilter("rarities", "rarity", Nyx_applySavedConfigFn_var5)
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.value, Nyx_setStealValue)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoIndex, Nyx_setAutoIndex)
			Nyx_applySavedConfigFn(Nyx_uiRefs.scrambleBuy, Nyx_setScrambleAutoBuy)
			Nyx_applySavedConfigFn(Nyx_uiRefs.scrambleBuyList, Nyx_setScrambleBuyList)
			Nyx_applySavedConfigFn(Nyx_uiRefs.bloomAutoNet, function(Nyx_applySavedConfigFn_var6)
				NyxConfig.ButterflyAutoNet = Nyx_applySavedConfigFn_var6 == true
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.bloomAutoCatch, function(Nyx_applySavedConfigFn_var7)
				NyxConfig.ButterflyAutoCatch = Nyx_applySavedConfigFn_var7 == true
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.bloomEsp, function(Nyx_applySavedConfigFn_var8)
				NyxConfig.ButterflyEsp = Nyx_applySavedConfigFn_var8 == true
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.bloomAutoTrade, function(Nyx_applySavedConfigFn_var9)
				NyxConfig.ButterflyAutoTrade = Nyx_applySavedConfigFn_var9 == true
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.bloomAutoCraft, function(Nyx_applySavedConfigFn_var10)
				NyxConfig.ButterflyAutoCraft = Nyx_applySavedConfigFn_var10 == true
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.bloomTiers, function(Nyx_applySavedConfigFn_var11)
				local __NyxButterflyRuntime = genv.__NyxButterflyRuntime

				if __NyxButterflyRuntime then
					__NyxButterflyRuntime.setTiers(Nyx_cleanList(Nyx_applySavedConfigFn_var11))
				end
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.bloomRecipe, function(Nyx_applySavedConfigFn_var12)
				local __NyxButterflyRuntime = genv.__NyxButterflyRuntime

				if __NyxButterflyRuntime then
					__NyxButterflyRuntime.setRecipe(Nyx_applySavedConfigFn_var12)
				end
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.bloomMode, function(Nyx_applySavedConfigFn_var13)
				local __NyxButterflyRuntime = genv.__NyxButterflyRuntime

				if __NyxButterflyRuntime then
					__NyxButterflyRuntime.setMode(Nyx_applySavedConfigFn_var13)
				end
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.noclip, Nyx_setNoclip)
			Nyx_applySavedConfigFn(Nyx_uiRefs.bottingMode, Nyx_setBottingMode)
			Nyx_applySavedConfigFn(Nyx_uiRefs.antiCutscene, Nyx_setAntiCutscene)
			Nyx_applySavedConfigFn(Nyx_uiRefs.waypoint, function(Nyx_applySavedConfigFn_var14)
				Nyx_setFpsCap_var1 = Nyx_applySavedConfigFn_var14
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoFavorite, Nyx_setAutoFavorite)
			Nyx_applySavedConfigFn(Nyx_uiRefs.favoriteRule, Nyx_setFavoriteRule)
			Nyx_applySavedConfigFn(Nyx_uiRefs.favoriteRarities, Nyx_setFavoriteRarities)
			Nyx_applySavedConfigFn(Nyx_uiRefs.favoriteSpecies, Nyx_setFavoriteSpecies)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoFuse, Nyx_setAutoFusePets)
			Nyx_applySavedConfigFn(Nyx_uiRefs.fuseRule, Nyx_setFuseRule)
			Nyx_applySavedConfigFn(Nyx_uiRefs.fuseRarities, Nyx_setFuseRarities)
			Nyx_applySavedConfigFn(Nyx_uiRefs.fuseSpecies, Nyx_setFuseSpecies)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoEquipBest, Nyx_setAutoEquipBest)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoClaimOffline, Nyx_setAutoClaimOffline)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoBaseUpgrade, Nyx_setAutoBaseUpgrade)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoClaimAlmanac, Nyx_setAutoClaimAlmanac)
			Nyx_applySavedConfigFn(Nyx_uiRefs.mutations, Nyx_setStealMutations)
			Nyx_applySavedConfigFn(Nyx_uiRefs.weight, Nyx_setStealWeight)
			Nyx_applySavedConfigFn(Nyx_uiRefs.priority, Nyx_setStealPriority)
			Nyx_applySavedConfigFn(Nyx_uiRefs.eggEsp, Nyx_setEggEsp)
			Nyx_applySavedConfigFn(Nyx_uiRefs.espDetails, Nyx_setEspDetails)
			Nyx_applySavedConfigFn(Nyx_uiRefs.backpackRates, Nyx_setBackpackRates)
			Nyx_applySavedConfigFn(Nyx_uiRefs.antiGuardKnockback, Nyx_setAntiGuardKnockback)
			Nyx_applySavedConfigFn(Nyx_uiRefs.placeRarity, function(Nyx_applySavedConfigFn_var15)
				NyxConfig.PlaceRarities = Nyx_cleanList(Nyx_applySavedConfigFn_var15)
			end)
			Nyx_applySavedConfigFn(Nyx_petNameFilterRef, function(Nyx_applySavedConfigFn_var16)
				NyxConfig.SellNames = Nyx_cleanList(Nyx_applySavedConfigFn_var16)
			end)
			Nyx_applySavedConfigFn(Nyx_petRarityFilterRef, function(Nyx_applySavedConfigFn_var17)
				NyxConfig.SellRarities = Nyx_cleanList(Nyx_applySavedConfigFn_var17)
			end)
			Nyx_applySavedConfigFn(Nyx_eggRarityFilterRef, function(Nyx_applySavedConfigFn_var18)
				NyxConfig.SellEggRarities = Nyx_cleanList(Nyx_applySavedConfigFn_var18)
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.sellPetValue, Nyx_setSellPetMaxRate)
			Nyx_applySavedConfigFn(Nyx_uiRefs.sellEggValue, Nyx_setSellEggMaxRate)
			Nyx_applySavedConfigFn(Nyx_uiRefs.godMode, Nyx_setGodMode)
			Nyx_applySavedConfigFn(Nyx_uiRefs.antiAfk, Nyx_setAntiAfk)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoReconnect, Nyx_setAutoReconnect)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoExecute, Nyx_setAutoExecute)
			Nyx_applySavedConfigFn(Nyx_uiRefs.antiHitGuard, Nyx_setAntiHitGuard)
			Nyx_applySavedConfigFn(Nyx_uiRefs.flyForCapture, Nyx_setFlyForCapture)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoStealCapture, Nyx_setAutoStealCapture)
			Nyx_applySavedConfigFn(Nyx_uiRefs.instantGrab, Nyx_setInstantGrab)
			Nyx_applySavedConfigFn(Nyx_uiRefs.infiniteJump, Nyx_setInfiniteJump)
			Nyx_applySavedConfigFn(Nyx_uiRefs.uncapFps, Nyx_setFpsCap)
			Nyx_applySavedConfigFn(Nyx_uiRefs.startupBoost, Nyx_setStartupBoost)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoPlace, Nyx_setAutoPlace)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoHatch, Nyx_setAutoHatch)
			Nyx_applySavedConfigFn(Nyx_uiRefs.mutationChoice, Nyx_setMutationChoice)
			Nyx_applySavedConfigFn(Nyx_uiRefs.mutationSpecies, Nyx_setMutationSpecies)
			Nyx_applySavedConfigFn(Nyx_uiRefs.mutationRarity, Nyx_setMutationRarities)
			Nyx_applySavedConfigFn(Nyx_uiRefs.mutationRetry, Nyx_setMutationRetry)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoMutation, Nyx_setAutoMutation)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoRingEvent, Nyx_setAutoRingEvent)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoSell, Nyx_setAutoSell)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoSellEgg, Nyx_setAutoSellEgg)
			Nyx_applySavedConfigFn(Nyx_uiRefs.stealPlayerRarities, Nyx_setStealPlayerRarities)
			Nyx_applySavedConfigFn(Nyx_uiRefs.stealPlayerValue, Nyx_setStealPlayerMinValue)
			Nyx_applySavedConfigFn(Nyx_uiRefs.webhookUrl, Nyx_setWebhookUrl)
			Nyx_applySavedConfigFn(Nyx_uiRefs.webhookRarities, Nyx_setWebhookRarities)
			Nyx_applySavedConfigFn(Nyx_uiRefs.webhookValue, Nyx_setWebhookMinValue)
			Nyx_applySavedConfigFn(Nyx_uiRefs.webhookEnabled, Nyx_setWebhookEnabled)
			Nyx_applySavedConfigFn(Nyx_uiRefs.helpFriend, function(Nyx_applySavedConfigFn_var19)
				NyxConfig.HelpFriend = Nyx_applySavedConfigFn_var19 == true
			end)
			Nyx_applySavedConfigFn(Nyx_uiRefs.autoSteal, Nyx_setAutoSteal)
			Nyx_applySavedConfigFn(Nyx_uiRefs.stealPlayers, Nyx_setStealPlayers)
		end

		do
			genv.__NyxHubShutdown = function()
				if __NyxPlayerSteal then
					pcall(__NyxPlayerSteal.setEnabled, __NyxPlayerSteal, false)
				end

				for _, v in ipairs({
					"AutoSteal",
					"AutoPlace",
					"AutoHatch",
					"AutoMutation",
					"AutoRingEvent",
					"AutoSell",
					"AutoSellEgg",
					"StealPlayers",
					"ScrambleBossAuto",
					"ButterflyAutoCatch",
					"ButterflyAutoNet",
					"ButterflyAutoTrade",
					"ButterflyAutoCraft"
				}) do
					NyxConfig[v] = false
				end

				if Nyx_eggRuntime then
					pcall(Nyx_eggRuntime.setEnabled, Nyx_eggRuntime, false)
				end
			end
		end
	end

	Nyx_buildMainWindow()
end