local Vector2 = Vector2
local Vector3 = Vector3
local CFrame = CFrame
local Drawing = Drawing
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local Prediction = {}
Prediction.__index = Prediction

function Prediction.new()
	local self = setmetatable({}, Prediction)
	
	self.lastlanding = nil
	self.isairborne = false
	self.smoothedpositions = {}
	self.lastcamerapos = workspace.CurrentCamera.CFrame.Position
	self.lastcameracf = workspace.CurrentCamera.CFrame
	self.cameraturnspeed = 0
	self.prejumpenabled = false
	self.lastmoveinput = Vector3.new(0, 0, 1)
	self.smoothedprejumplines = {}
	for i = 1, 29 do
		self.smoothedprejumplines[i] = {from = Vector2.new(0, 0), to = Vector2.new(0, 0)}
	end
	self.smoothedprejumpdot = Vector2.new(0, 0)
	self.time = 0
	self.pulsetime = 0
	
	self.preddot = Drawing.new("Circle")
	self.preddot.Radius = 6
	self.preddot.Filled = true
	self.preddot.Color = Color3.fromRGB(0, 255, 255)
	self.preddot.Visible = false
	self.preddot.Transparency = 1
	self.preddot.NumSides = 32
	
	self.landdot = Drawing.new("Circle")
	self.landdot.Radius = 12
	self.landdot.Filled = true
	self.landdot.Color = Color3.fromRGB(255, 100, 100)
	self.landdot.Visible = false
	self.landdot.Transparency = 1
	self.landdot.NumSides = 32
	
	self.landoutline = Drawing.new("Circle")
	self.landoutline.Radius = 18
	self.landoutline.Filled = false
	self.landoutline.Color = Color3.fromRGB(255, 150, 150)
	self.landoutline.Visible = false
	self.landoutline.Transparency = 1
	self.landoutline.Thickness = 2
	self.landoutline.NumSides = 32
	
	self.velline = Drawing.new("Line")
	self.velline.Color = Color3.fromRGB(0, 255, 0)
	self.velline.Thickness = 3
	self.velline.Visible = false
	self.velline.Transparency = 1
	
	self.velcurve = {}
	for i = 1, 8 do
		local line = Drawing.new("Line")
		line.Color = Color3.fromRGB(0, 255, 0)
		line.Thickness = 3
		line.Visible = false
		line.Transparency = 1
		self.velcurve[i] = line
	end
	
	self.arclines = {}
	for i = 1, 29 do
		local line = Drawing.new("Line")
		line.Color = Color3.fromRGB(255, 240, 140)
		line.Thickness = 2
		line.Visible = false
		line.Transparency = 1
		self.arclines[i] = line
	end
	
	self.prejumplines = {}
	for i = 1, 29 do
		local line = Drawing.new("Line")
		line.Color = Color3.fromRGB(100, 200, 255)
		line.Thickness = 2
		line.Visible = false
		line.Transparency = 0.7
		self.prejumplines[i] = line
	end
	
	self.prejumplanddot = Drawing.new("Circle")
	self.prejumplanddot.Radius = 10
	self.prejumplanddot.Filled = true
	self.prejumplanddot.Color = Color3.fromRGB(100, 200, 255)
	self.prejumplanddot.Visible = false
	self.prejumplanddot.Transparency = 0.7
	self.prejumplanddot.NumSides = 32
	
	self.connection = nil
	self.keybindConnection = nil
	
	self:setupKeybind()
	self:start()
	
	return self
end

function Prediction:setupKeybind()
	self.keybindConnection = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.H then
			self.prejumpenabled = not self.prejumpenabled
			print(self.prejumpenabled and "on" or "off")
		end
	end)
end

function Prediction:lerp2(a, b, t)
	return a + (b - a) * t
end

function Prediction:predictpos(p0, v0, t)
	local grav = workspace.Gravity
	return p0 + v0 * t + Vector3.new(0, -grav, 0) * 0.5 * t * t
end

function Prediction:toscreen(pos)
	local screenpos, onscreen = workspace.CurrentCamera:WorldToViewportPoint(pos)
	return Vector2.new(screenpos.X, screenpos.Y), onscreen
end

function Prediction:isvisible(pos)
	local rayparams = RaycastParams.new()
	rayparams.FilterDescendantsInstances = {Players.LocalPlayer.Character}
	rayparams.FilterType = Enum.RaycastFilterType.Exclude
	local campos = workspace.CurrentCamera.CFrame.Position
	local dir = pos - campos
	local distance = dir.Magnitude
	if distance < 2 then return true end
	local ray = workspace:Raycast(campos, dir, rayparams)
	if ray and (ray.Position - campos).Magnitude < distance - 2 then
		return false
	end
	return true
end

function Prediction:isgrounded(hrp)
	local rayparams = RaycastParams.new()
	rayparams.FilterDescendantsInstances = {Players.LocalPlayer.Character}
	rayparams.FilterType = Enum.RaycastFilterType.Exclude
	local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -3, 0), rayparams)
	return ray ~= nil
end

function Prediction:simulate(p0, v0)
	local positions = {}
	local prev = p0
	local landed = nil
	local rayparams = RaycastParams.new()
	rayparams.FilterDescendantsInstances = {Players.LocalPlayer.Character}
	rayparams.FilterType = Enum.RaycastFilterType.Exclude
	for t = 0, 2.5, 0.03 do
		local pos = self:predictpos(p0, v0, t)
		table.insert(positions, pos)
		local dir = pos - prev
		if dir.Magnitude > 0.01 then
			local ray = workspace:Raycast(prev, dir, rayparams)
			if ray then
				landed = ray.Position
				break
			end
		end
		prev = pos
	end
	if not landed and #positions > 0 then
		local last = positions[#positions]
		local down = workspace:Raycast(last + Vector3.new(0, 1, 0), Vector3.new(0, -5000, 0), rayparams)
		if down then
			landed = down.Position
		end
	end
	return positions, landed
end

function Prediction:update(dt)
	self.pulsetime = self.pulsetime + dt
	
	local localplayer = Players.LocalPlayer
	local char = localplayer.Character
	if not char or not char.Parent then return end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not hrp or not hum then return end
	
	local p0 = hrp.Position
	local v0 = hrp.AssemblyLinearVelocity
	local grounded = self:isgrounded(hrp)
	
	local currentcf = workspace.CurrentCamera.CFrame
	local relativecf = self.lastcameracf:Inverse() * currentcf
	local _, yaw, _ = relativecf:ToEulerAnglesXYZ()
	local turndir = yaw / math.max(dt, 0.001)
	self.cameraturnspeed = self.cameraturnspeed * 0.7 + turndir * 0.3
	self.lastcameracf = currentcf
	
	local wasairborne = self.isairborne
	self.isairborne = not grounded and v0.Y < -5
	
	if not wasairborne and self.isairborne then
		self.lastlanding = nil
	end
	
	if self.isairborne and grounded then
		self.lastlanding = nil
	end
	
	local pred3 = self:predictpos(p0, v0, 0.25)
	local pred2, predon = self:toscreen(pred3)
	self.preddot.Position = pred2
	self.preddot.Visible = predon and self:isvisible(pred3)
	
	if v0.Magnitude > 1 then
		local curvature = -self.cameraturnspeed * 0.8
		local vellength = math.min(v0.Magnitude * 0.5, 20)
		local segments = 8
		for i = 1, segments do
			local t0 = (i - 1) / segments
			local t1 = i / segments
			local offset0 = t0 * vellength
			local offset1 = t1 * vellength
			local curve0 = curvature * offset0 * offset0 * 0.06
			local curve1 = curvature * offset1 * offset1 * 0.06
			local dir = v0.Unit
			local up = Vector3.new(0, 1, 0)
			local right = dir:Cross(up).Unit
			local pos0 = p0 + dir * offset0 + right * curve0
			local pos1 = p0 + dir * offset1 + right * curve1
			local start2, starton = self:toscreen(pos0)
			local end2, endon = self:toscreen(pos1)
			local visible0 = self:isvisible(pos0)
			local visible1 = self:isvisible(pos1)
			self.velcurve[i].From = start2
			self.velcurve[i].To = end2
			self.velcurve[i].Visible = starton and endon and visible0 and visible1
		end
		self.velline.Visible = false
	else
		self.velline.Visible = false
		for i = 1, 8 do
			self.velcurve[i].Visible = false
		end
	end
	
	local positions, landing = self:simulate(p0, v0)
	if #positions > 1 then
		for i = 1, 29 do
			local idx1 = math.floor((i - 1) * (#positions - 1) / 29) + 1
			local idx2 = math.floor(i * (#positions - 1) / 29) + 1
			idx1 = math.clamp(idx1, 1, #positions)
			idx2 = math.clamp(idx2, 1, #positions)
			local pos1 = positions[idx1]
			local pos2 = positions[idx2]
			local s1, on1 = self:toscreen(pos1)
			local s2, on2 = self:toscreen(pos2)
			local midpoint = (pos1 + pos2) * 0.5
			local visible = self:isvisible(midpoint)
			self.arclines[i].From = s1
			self.arclines[i].To = s2
			self.arclines[i].Visible = on1 and on2 and visible
		end
	else
		for i = 1, 29 do
			self.arclines[i].Visible = false
		end
	end
	
	if self.isairborne and landing then
		self.lastlanding = landing
	end
	
	if self.lastlanding and self.isairborne then
		local land2, landon = self:toscreen(self.lastlanding)
		self.landdot.Position = land2
		self.landdot.Visible = landon and self:isvisible(self.lastlanding)
		local pulse = math.abs(math.sin(self.pulsetime * 3))
		self.landoutline.Position = land2
		self.landoutline.Radius = 18 + pulse * 8
		self.landoutline.Transparency = 0.3 + pulse * 0.7
		self.landoutline.Visible = landon and self:isvisible(self.lastlanding)
	else
		self.landdot.Visible = false
		self.landoutline.Visible = false
	end
	
	if self.prejumpenabled and not self.isairborne then
		local camlook = workspace.CurrentCamera.CFrame.LookVector
		local camright = workspace.CurrentCamera.CFrame.RightVector
		local movevec = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			movevec = movevec + Vector3.new(camlook.X, 0, camlook.Z).Unit
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			movevec = movevec - Vector3.new(camlook.X, 0, camlook.Z).Unit
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			movevec = movevec - Vector3.new(camright.X, 0, camright.Z).Unit
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			movevec = movevec + Vector3.new(camright.X, 0, camright.Z).Unit
		end
		if movevec.Magnitude > 0.1 then
			self.lastmoveinput = movevec.Unit
		end
		local walkspeed = hum.WalkSpeed or 16
		local futurevel = self.lastmoveinput * walkspeed
		local jumpvel = futurevel + Vector3.new(0, 50, 0)
		local prejumppositions, prejumplanding = self:simulate(p0, jumpvel)
		if #prejumppositions > 1 then
			for i = 1, 29 do
				local idx1 = math.floor((i - 1) * (#prejumppositions - 1) / 29) + 1
				local idx2 = math.floor(i * (#prejumppositions - 1) / 29) + 1
				idx1 = math.clamp(idx1, 1, #prejumppositions)
				idx2 = math.clamp(idx2, 1, #prejumppositions)
				local pos1 = prejumppositions[idx1]
				local pos2 = prejumppositions[idx2]
				local s1, on1 = self:toscreen(pos1)
				local s2, on2 = self:toscreen(pos2)
				local midpoint = (pos1 + pos2) * 0.5
				local visible = self:isvisible(midpoint)
				self.prejumplines[i].From = s1
				self.prejumplines[i].To = s2
				self.prejumplines[i].Visible = on1 and on2 and visible
			end
		else
			for i = 1, 29 do
				self.prejumplines[i].Visible = false
			end
		end
		if prejumplanding then
			local preland2, prelandon = self:toscreen(prejumplanding)
			self.prejumplanddot.Position = preland2
			self.prejumplanddot.Visible = prelandon and self:isvisible(prejumplanding)
		else
			self.prejumplanddot.Visible = false
		end
	else
		for i = 1, 29 do
			self.prejumplines[i].Visible = false
		end
		self.prejumplanddot.Visible = false
	end
end

function Prediction:start()
	if self.connection then return end
	self.connection = RunService.RenderStepped:Connect(function(dt)
		self:update(dt)
	end)
end

function Prediction:stop()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end

function Prediction:destroy()
	self:stop()
	if self.keybindConnection then
		self.keybindConnection:Disconnect()
		self.keybindConnection = nil
	end
	self.preddot:Remove()
	self.landdot:Remove()
	self.landoutline:Remove()
	self.velline:Remove()
	for _, line in ipairs(self.velcurve) do
		line:Remove()
	end
	for _, line in ipairs(self.arclines) do
		line:Remove()
	end
	for _, line in ipairs(self.prejumplines) do
		line:Remove()
	end
	self.prejumplanddot:Remove()
end

function Prediction:setPreJumpEnabled(enabled)
	self.prejumpenabled = enabled
end

function Prediction:togglePreJump()
	self.prejumpenabled = not self.prejumpenabled
end

return Prediction