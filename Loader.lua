task.spawn(function() 
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoYunUwU/Scripts/refs/heads/main/Loader.lua"))()
    end)
    
    if not success then
    local errMsg = tostring(result)
    local message = Instance.new("Message", game:GetService("CoreGui"))
    if errMsg:find("HttpError") or errMsg:find("ConnectFail") or errMsg:find("Timedout") or errMsg:find("Ssl") or errMsg:find("NetFail") or errMsg:find("DnsResolve") then
        message.Text = "XA Hub：错误，请更换加速器后重试 ("..errMsg..")"
    else
        message.Text = "XA Hub：错误，"..errMsg
    end
    warn(errMsg)
    task.wait(60)
    message:Destroy()
    end
    end)
    local TS = game:GetService("TweenService")local A = Instance.new("ScreenGui", gethui())local B = Instance.new("ImageLabel", A)local C = TS:Create(B, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0), {ImageTransparency = 0})local D = TS:Create(B, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0), {ImageTransparency = 1})local E = Instance.new("ScreenGui", gethui())local F = Instance.new("Frame")local G = Instance.new("TextLabel")local H = TS:Create(G, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0})local I = TS:Create(G, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 1})B.AnchorPoint = Vector2.new(.5, .5)B.Position = UDim2.new(.5, 0, .5, 0)B.Size = UDim2.new(0, 500, 0, 500)B.BackgroundTransparency = 1 B.Image = "rbxassetid://96484256426204"B.ImageTransparency = 1 F.BackgroundTransparency = 1 F.BorderSizePixel = 0 F.Position = UDim2.new(1, -200, 1, -50)F.Size = UDim2.new(0, 200, 0, 50)F.BackgroundTransparency = 1 F.Parent = E G.BackgroundTransparency = 1 G.Font = Enum.Font.SourceSans G.Text = "Welcome to use the XA Hub"G.TextColor3 = Color3.fromRGB(255, 255, 255)G.TextSize = 16 G.Position = UDim2.new(0, 0, 0, 10)G.Size = UDim2.new(1, -20, 1, -20)G.TextTransparency = 1 G.Parent = F C:Play()H:Play()task.wait(1)task.wait(2)D:Play()I:Play()task.wait(1)A:Destroy()E:Destroy()