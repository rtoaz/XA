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
    local W=Instance.new("ScreenGui",gethui())local E=Instance.new("ImageLabel",W)E.AnchorPoint=Vector2.new(.5,.5)E.Position=UDim2.new(.5,0,.5,0)E.Size=UDim2.new(0,500,0,500)E.BackgroundTransparency=1 E.Image="rbxassetid://96484256426204"E.ImageTransparency=1 local o=game:GetService("TweenService")local U=TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)local j={ImageTransparency=0}local e=TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)local J={ImageTransparency=1}local k=o:Create(E,U,j)local T=o:Create(E,e,J)k:Play()k.Completed:Wait()task.wait(2)T:Play()T.Completed:Wait()W:Destroy()