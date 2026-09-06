-- 確保舊的 UI 存在時先清除，避免重複生成
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

if CoreGui:FindFirstChild("KLAuthUI") then
    CoreGui.KLAuthUI:Destroy()
end

-- 建立主 GUI 容器
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KLAuthUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 主視窗背景框
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 210)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- 圓角裝飾
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- 標題文字
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "KL Auth - 卡號驗證系統"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- 卡號輸入框 (TextBox)
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 45)
KeyBox.Position = UDim2.new(0.075, 0, 0, 60)
KeyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
KeyBox.PlaceholderText = "請輸入你的卡號 (Key)..."
KeyBox.Text = ""
KeyBox.TextSize = 14
KeyBox.Font = Enum.Font.Gotham
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = KeyBox

-- 驗證按鈕 (TextButton)
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.85, 0, 0, 42)
VerifyBtn.Position = UDim2.new(0.075, 0, 0, 125)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "確認驗證"
VerifyBtn.TextSize = 15
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = VerifyBtn

-- 按鈕點擊互動與 API 驗證邏輯
VerifyBtn.MouseButton1Click:Connect(function()
    local userKey = KeyBox.Text
    
    if userKey == "" or userKey:match("^%s*$") then
        VerifyBtn.Text = "❌ 卡號不能為空！"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        task.wait(1.5)
        VerifyBtn.Text = "確認驗證"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
        return
    end

    VerifyBtn.Text = "⏳ 驗證中..."
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)

    -- 發送 POST 請求到你的 kl-auth-api
    local success, response = pcall(function()
        return HttpService:PostAsync("https://你的-kl-auth-api網址.com/api/verify", HttpService:JSONEncode({
            key = userKey,
            hwid = "GET_HWID_OR_IDENTIFIER" -- 這裡可以填入對應 Executor 的 HWID 函數
        }), Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        if data.status == "success" then
            VerifyBtn.Text = "✔ 驗證成功！載入中..."
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            task.wait(1)
            
            -- 關閉 UI 介面
            ScreenGui:Destroy()
            
            -- TODO: 驗證成功後，在此處載入你的主腳本功能
            -- 例如：loadstring(game:HttpGet("你的主腳本網址"))()
            
        else
            VerifyBtn.Text = data.message or "❌ 卡號無效或已過期"
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            task.wait(2)
            VerifyBtn.Text = "確認驗證"
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
        end
    else
        VerifyBtn.Text = "❌ 無法連線至驗證伺服器"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        task.wait(2)
        VerifyBtn.Text = "確認驗證"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
    end
end)
