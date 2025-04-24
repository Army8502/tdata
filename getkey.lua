-- URLs
local ESP_LUA_URL    = "https://raw.githubusercontent.com/Army8502/tdata/main/ESP.lua"
local FULL_LUA_URL   = "https://raw.githubusercontent.com/Army8502/tdata/main/full.lua"
local GITHUB_KEY_URL = "https://raw.githubusercontent.com/Army8502/tdata/main/tdata.lua"

local HttpService = game:GetService("HttpService")

-- ฟังก์ชันโหลดและรัน ESP
local function loadAndRunESPScript()
    local ok, content = pcall(function()
        return game:HttpGet(ESP_LUA_URL)
    end)
    if ok and content then
        loadstring(content)()
    else
        warn("ไม่สามารถโหลด ESP script:", content)
    end
end

-- สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SeeYouUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- ฟังก์ชันสร้างกรอบพร้อมเอฟเฟกต์
local function makeFrame(props)
    local f = Instance.new("Frame")
    f.Size = props.Size
    f.Position = props.Position
    f.BackgroundTransparency = props.BackgroundTransparency or 0  -- เพิ่มการตั้งค่า BackgroundTransparency
    f.Parent = props.Parent
    f.LayoutOrder = props.LayoutOrder or 0

    -- พื้นหลังไล่โทน
    local grad = Instance.new("UIGradient", f)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, props.GradientFrom),
        ColorSequenceKeypoint.new(1, props.GradientTo),
    }
    grad.Rotation = props.GradientRotation or 90
    
    -- ขอบโค้งมน + เส้นขอบ
    local corner = Instance.new("UICorner", f)
    corner.CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 2
    stroke.Color = props.StrokeColor or Color3.fromRGB(255,255,255)
    stroke.Transparency = 0.7

    return f
end

-- ฟังก์ชันสร้างปุ่ม
local function makeButton(text, parent, posY, colorFrom, colorTo, callback)
    local btn = makeFrame{
        Size             = UDim2.new(0, 240, 0, 50),
        Position         = UDim2.new(0.5, -120, posY, 0),
        Parent           = parent,
        GradientFrom     = colorFrom,
        GradientTo       = colorTo,
        StrokeColor      = Color3.fromRGB(255,255,255),
        GradientRotation = 0,
    }
    btn.Name = text:gsub(" ", "") .. "Btn"

    local click = Instance.new("TextButton", btn)
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = text
    click.Font = Enum.Font.GothamSemibold
    click.TextSize = 20
    click.TextColor3 = Color3.fromRGB(255,255,255)
    click.AutoButtonColor = false
    click.MouseEnter:Connect(function()
        btn.UIStroke.Transparency = 0.3
    end)
    click.MouseLeave:Connect(function()
        btn.UIStroke.Transparency = 0.7
    end)
    click.MouseButton1Click:Connect(callback)

    return btn
end

-- Main frame
-- Main frame
local mainFrame = makeFrame{
    Size         = UDim2.new(0, 400, 0, 380),
    Position     = UDim2.new(0.5, -200, 0.5, -190),
    Parent       = screenGui,
    GradientFrom = Color3.fromRGB(40, 40, 40),
    GradientTo   = Color3.fromRGB(30, 30, 30),
    StrokeColor  = Color3.fromRGB(200,200,200),
    BackgroundTransparency = 0.2  -- โปร่งใส 50%
}


-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -40, 0, 50)
title.Position = UDim2.new(0, 20, 0, 20)
title.BackgroundTransparency = 1
title.Text = "SEE YOU"
title.Font = Enum.Font.GothamBlack
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Key input box
local keyBox = makeFrame{
    Size            = UDim2.new(1, -40, 0, 50),
    Position        = UDim2.new(0, 20, 0, 90),
    Parent          = mainFrame,
    GradientFrom    = Color3.fromRGB(60,60,60),
    GradientTo      = Color3.fromRGB(50,50,50),
    StrokeColor     = Color3.fromRGB(180,180,180),
}
local input = Instance.new("TextBox", keyBox)
input.Size = UDim2.new(1, -20, 1, -10)
input.Position = UDim2.new(0, 10, 0, 5)
input.BackgroundTransparency = 1
input.Text = "กรุณากรอก Key"        -- แสดงข้อความตั้งต้น
input.PlaceholderText = ""           -- ไม่ใช้ placeholder
input.ClearTextOnFocus = true        -- ล้างข้อความเมื่อคลิก
input.Font = Enum.Font.Gotham
input.TextSize = 20
input.TextColor3 = Color3.fromRGB(230,230,230)

-- Feedback label
local feedbackLabel = Instance.new("TextLabel", mainFrame)
feedbackLabel.Size = UDim2.new(1, -40, 0, 30)
feedbackLabel.Position = UDim2.new(0, 20, 0, 300)
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.Text = ""
feedbackLabel.Font = Enum.Font.Gotham
feedbackLabel.TextSize = 18
feedbackLabel.TextColor3 = Color3.fromRGB(255,100,100)
feedbackLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Check Key function
local function checkKey()
    local key = input.Text
    if key == "" or key == "กรุณากรอก Key" then
        feedbackLabel.TextColor3 = Color3.fromRGB(255,100,100)
        feedbackLabel.Text = "กรุณากรอก Key ก่อน"
        return
    end
    local ok, data = pcall(function()
        return game:HttpGet(GITHUB_KEY_URL)
    end)
    if not ok then
        feedbackLabel.TextColor3 = Color3.fromRGB(255,100,100)
        feedbackLabel.Text = "ไม่สามารถเชื่อมต่อ GitHub"
        return
    end

    local found = false
    for line in data:gmatch("[^\r\n]+") do
        if line == key then
            found = true
            break
        end
    end

    if found then
        feedbackLabel.TextColor3 = Color3.fromRGB(100,255,100)
        feedbackLabel.Text = "Key ถูกต้อง! กำลังโหลด..."
        loadstring(game:HttpGet(FULL_LUA_URL))()
        loadstring(game:HttpGet(ESP_LUA_URL))()
        screenGui:Destroy()
    else
        feedbackLabel.TextColor3 = Color3.fromRGB(255,100,100)
        feedbackLabel.Text = "Key ไม่ถูกต้อง"
    end
end

-- Create buttons
makeButton("ตรวจสอบ Key", mainFrame, 0.45, Color3.fromRGB(85,170,255), Color3.fromRGB(75,150,235), checkKey)
makeButton("ปิดโปรแกรม",   mainFrame, 0.65, Color3.fromRGB(255,85,85),   Color3.fromRGB(235,75,75), function()
    screenGui:Destroy()
    print("โปรแกรมถูกปิดแล้ว")
end)
