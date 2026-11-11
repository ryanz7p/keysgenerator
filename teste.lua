-- Savannah Hub - Kill Aura SAFE-STABLE + ESP + Fly + extras + Auto Food/Drink
-- Interface: Empirix
local G={}
G.alive=true
G.P=game:GetService("Players")
G.R=game:GetService("ReplicatedStorage")
G.W=game:GetService("Workspace")
G.L=game:GetService("Lighting")
G.RS=game:GetService("RunService")
G.pl=G.P.LocalPlayer
G.pg=G.pl:WaitForChild("PlayerGui")
G.TS=game:GetService("TweenService")
G.UIS=game:GetService("UserInputService")
G.logHistory={}

local function LOG(msg,level)
    local m=tostring(msg)
    local pfx=""
    if level=="ok"then pfx="[+] "
    elseif level=="warn"then pfx="[!] "
    elseif level=="err"then pfx="[X] "
    else pfx="[.] " end
    G.logHistory[#G.logHistory+1]={t=os.time(),msg=pfx..m,lvl=level or "info"}
    if #G.logHistory>200 then table.remove(G.logHistory,1)end
end

local ATTACK_RANGE=220
local ATTACK_RATE=100
local DAMAGE_VALUE=99999999
local KA_LOG_INTERVAL=5

local WALKSPEED_MIN=16
local WALKSPEED_MAX=200
local SCAN_INTERVAL=1.0
local GRAB_RANGE=30
local GRAB_COOLDOWN=3.0
local FLY_CEILING=800
local TP_COOLDOWN=12
local ALREADY_NEAR_DIST=15
local MAX_Y_DROP=300

G.S={
    killAura=false, autoGrab=false, antiGrab=false,
    esp=false, espBox=true, espName=true, espHealth=true, espDistance=true, espLine=true,
    espMaxDist=600,
    espCarcass=false, espLivingAnimal=false,
    infiniteStamina=false, walkSpeed=false, walkSpeedValue=50,
    fly=false, flySpeed=100,
    fullbright=false, autoFood=false, autoDrink=false,
    regenThreshold=90,
}
G.keybinds={ killAura=nil, esp=nil, walkSpeed=nil, fly=nil }
G.keybindListening=nil
G.keybindDisplays={}
G.toggleHandlers={}
G.espData={}
G.carcassData={}
G.livingAnimalData={}
G.staminaTargets={}
G.staminaConnections=nil
G.walkSpeedConnection=nil
G.originalWalkSpeed=nil
G.flyConnection=nil
G.flyLanding=false
G.flyLandingStart=0
G.flyPaint=nil
G.flyLastDir=Vector3.new(0,0,-1)
G.fbConnection=nil
G.foodConn=nil
G.drinkConn=nil
G.foodState="clear"
G.drinkState="clear"
G.lastGrab=0
G.lastAntiGrab=0
G.lastCarcassScan=0
G.lastAnimalScan=0
G.originalLighting={}

local function findR(n)
    for _,d in ipairs(G.R:GetDescendants())do
        if(d:IsA("RemoteEvent")or d:IsA("RemoteFunction"))and d.Name:find(n,1,true)then return d end
    end
end

local function getMy()
    local c=G.pl.Character if not c then return nil,nil,nil end
    return c,c:FindFirstChild("HumanoidRootPart"),c:FindFirstChildOfClass("Humanoid")
end

local function getAllInRange(range)
    range=range or ATTACK_RANGE
    local _,myHrp=getMy()
    if not myHrp then return {} end
    local list={}
    local seen={}

    for _,p in ipairs(G.P:GetPlayers())do
        if p~=G.pl and p.Character then
            local h=p.Character:FindFirstChild("HumanoidRootPart")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if h and hum and hum.Health>0 then
                local d=(h.Position-myHrp.Position).Magnitude
                if d<=range then
                    table.insert(list,{player=p,char=p.Character,hrp=h,hum=hum,dist=d})
                    seen[p.Character]=true
                end
            end
        end
    end

    local containers = {G.W}
    local charsFolder = G.W:FindFirstChild("Characters")
    if charsFolder then table.insert(containers, charsFolder) end
    local npcsFolder = G.W:FindFirstChild("NPCs")
    if npcsFolder then table.insert(containers, npcsFolder) end
    local enemiesFolder = G.W:FindFirstChild("Enemies")
    if enemiesFolder then table.insert(containers, enemiesFolder) end

    for _,container in ipairs(containers)do
        for _,obj in ipairs(container:GetChildren())do
            if obj:IsA("Model") and obj ~= G.pl.Character and not seen[obj] then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if hum and hrp and hum.Health>0 then
                    local d = (hrp.Position - myHrp.Position).Magnitude
                    if d <= range then
                        table.insert(list,{player=nil, char=obj, hrp=hrp, hum=hum, dist=d, isNpc=true, name=obj.Name})
                        seen[obj]=true
                    end
                end
            end
        end
    end

    table.sort(list,function(a,b)return a.dist<b.dist end)
    return list
end

local function getInputName(input)
    if input.UserInputType==Enum.UserInputType.Keyboard then return input.KeyCode.Name
    elseif input.UserInputType==Enum.UserInputType.MouseButton1 then return "Mouse1"
    elseif input.UserInputType==Enum.UserInputType.MouseButton2 then return "Mouse2"
    elseif input.UserInputType==Enum.UserInputType.MouseButton3 then return "Mouse3"
    end
end

G.RM={}
G.RM.attackHandler=findR("AttackHandlerRemoteEvent")
G.RM.regular=findR("SpecialAttackRemoteEvent_RegularAttack")
G.RM.pounce=findR("SpecialAttackRemoteEvent_PounceAttack")
G.RM.latched=findR("LatchedPlayersNotifyRemoteEvent")
G.RM.ragdoll=findR("TriggerRagdollRemoteEvent")
G.RM.subState=findR("AskServerToSetSubStateRemoteFunction")
G.RM.saveStats=findR("SaveCharacterStatsRemoteEvent")
G.RM.attack=G.RM.attackHandler or G.RM.regular

LOG("Savannah Hub carregado","ok")
LOG("Ataque: "..(G.RM.attack and "OK" or "FALTA"),G.RM.attack and "ok" or "err")
LOG("SubState: "..(G.RM.subState and "OK" or "FALTA"),G.RM.subState and "ok" or "err")
LOG(string.format("KA safe: rate=%dms · dmg=%d · range=%d · alvo=mais_proximo", ATTACK_RATE, DAMAGE_VALUE, ATTACK_RANGE), "info")

G.UIS.InputBegan:Connect(function(input,gp)
    if not G.alive then return end
    if gp then return end
    if G.keybindListening then
        local fn=G.keybindListening
        if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Enum.KeyCode.Escape then
            G.keybinds[fn]=nil
        else
            local name=getInputName(input)
            if name then G.keybinds[fn]=name end
        end
        G.keybindListening=nil
        local disp=G.keybindDisplays[fn]
        if disp then disp() end
        return
    end
    local inputName=getInputName(input)
    if not inputName then return end
    for fn,kn in pairs(G.keybinds)do
        if kn==inputName then
            local h=G.toggleHandlers[fn]
            if h then h.set(not h.get()) h.paint() end
            break
        end
    end
end)

local function fireAttack(t)
    local r=G.RM.attack
    if not r or not t or not t.hum then return false end
    local ok = pcall(function()
        if r:IsA("RemoteEvent")then r:FireServer(t.hum,DAMAGE_VALUE)
        else r:InvokeServer(t.hum,DAMAGE_VALUE) end
    end)
    return ok
end

local lastAttack=0
local atkCount=0
local lastKALog=0
task.spawn(function()
    while G.alive do
        task.wait(0.02)
        if G.S.killAura and G.RM.attack then
            local now=tick()*1000
            if now-lastAttack>=ATTACK_RATE then
                lastAttack=now
                pcall(function()
                    local all=getAllInRange(ATTACK_RANGE)
                    if #all>0 then
                        local t=all[1]
                        if fireAttack(t) then
                            atkCount=atkCount+1
                            local nm = t.player and t.player.Name or t.name or "NPC"
                            if atkCount%15==0 then
                                LOG(string.format("KA → %s (%.0fm)", nm, t.dist), "ok")
                            end
                        end
                    end
                    local nowS=tick()
                    if nowS-lastKALog>=KA_LOG_INTERVAL then
                        lastKALog=nowS
                        LOG(string.format("KA ativo · %d alvos em %dm · rate=%dms", #all, ATTACK_RANGE, ATTACK_RATE), "info")
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    while G.alive do
        task.wait(0.5)
        if G.S.autoGrab and G.RM.pounce then
            local now=tick()
            if now-G.lastGrab>=GRAB_COOLDOWN then
                local all=getAllInRange(GRAB_RANGE)
                local firstPlayer
                for _,t in ipairs(all) do if t.player then firstPlayer=t break end end
                if firstPlayer then
                    pcall(function() G.RM.pounce:FireServer(firstPlayer.hum) end)
                    G.lastGrab=now
                    LOG("Auto Grab → "..firstPlayer.player.Name,"ok")
                end
            end
        end
    end
end)

if G.RM.latched then
    G.RM.latched.OnClientEvent:Connect(function()
        if not G.S.antiGrab then return end
        local now=tick()
        if now-G.lastAntiGrab<2 then return end
        G.lastAntiGrab=now
        LOG("Anti Grab: latch","warn")
        if G.RM.subState then pcall(function() G.RM.subState:InvokeServer("Normal") end) end
        if G.RM.ragdoll then pcall(function() G.RM.ragdoll:FireServer(false) end) end
        local _,_,hum=getMy()
        if hum then pcall(function() hum.PlatformStand=false hum.Sit=false end) end
    end)
end

local FB_VALUES={Ambient=Color3.fromRGB(200,200,200),OutdoorAmbient=Color3.fromRGB(200,200,200),Brightness=2,GlobalShadows=false,FogEnd=100000,FogStart=0}
local function applyFullbright()
    for k,v in pairs(FB_VALUES)do pcall(function() G.L[k]=v end) end
    for _,child in ipairs(G.L:GetChildren())do
        if child:IsA("Atmosphere")or child:IsA("BloomEffect")or child:IsA("ColorCorrectionEffect")or child:IsA("SunRaysEffect")or child:IsA("DepthOfFieldEffect")or child:IsA("BlurEffect")then
            pcall(function()
                if child:GetAttribute("_fbOrig")==nil then child:SetAttribute("_fbOrig",child.Enabled) end
                child.Enabled=false
            end)
        end
    end
end
local function restoreLighting()
    pcall(function()
        G.L.Ambient=G.originalLighting.Ambient or Color3.fromRGB(70,70,70)
        G.L.OutdoorAmbient=G.originalLighting.OutdoorAmbient or Color3.fromRGB(128,128,128)
        G.L.Brightness=G.originalLighting.Brightness or 1
        G.L.GlobalShadows=G.originalLighting.GlobalShadows ~= false
        G.L.FogEnd=G.originalLighting.FogEnd or 100000
        G.L.FogStart=G.originalLighting.FogStart or 0
    end)
    for _,child in ipairs(G.L:GetChildren())do
        local orig=child:GetAttribute("_fbOrig")
        if orig~=nil then
            pcall(function() child.Enabled=orig end)
            pcall(function() child:SetAttribute("_fbOrig",nil) end)
        end
    end
end
local function enableFullbright()
    if G.fbConnection then return end
    G.originalLighting={Ambient=G.L.Ambient,OutdoorAmbient=G.L.OutdoorAmbient,Brightness=G.L.Brightness,GlobalShadows=G.L.GlobalShadows,FogEnd=G.L.FogEnd,FogStart=G.L.FogStart}
    applyFullbright()
    G.fbConnection=task.spawn(function()
        while G.alive and G.S.fullbright do task.wait(0.5) applyFullbright() end
    end)
    LOG("Fullbright ativado","ok")
end
local function disableFullbright()
    if G.fbConnection then task.cancel(G.fbConnection) G.fbConnection=nil end
    restoreLighting()
    LOG("Fullbright desativado","ok")
end

local STAMINA_KEYWORDS = {"stamina","sprint","energy","fatigue","exhaust","hunger","thirst","warmth","temperature","endurance","vitality"}
local function isStaminaName(name)
    if type(name) ~= "string" then return false end
    local l = string.lower(name)
    for _, kw in ipairs(STAMINA_KEYWORDS) do
        if string.find(l, kw, 1, true) then return true end
    end
    return false
end
local function recordStamina()
    G.staminaTargets = {}
    local locations = {
        {name="Player", obj=G.pl},
        {name="Character", obj=G.pl.Character},
        {name="Humanoid", obj=G.pl.Character and G.pl.Character:FindFirstChildOfClass("Humanoid")},
        {name="PlayerGui", obj=G.pg},
        {name="Backpack", obj=G.pl:FindFirstChild("Backpack")},
    }
    for _, loc in ipairs(locations) do
        if loc.obj then
            local ok, attrs = pcall(function() return loc.obj:GetAttributes() end)
            if ok and attrs then
                for name, val in pairs(attrs) do
                    if isStaminaName(name) and type(val) == "number" then
                        table.insert(G.staminaTargets, {obj=loc.obj, name=name, kind="attribute", targetValue=999999})
                    end
                end
            end
            for _, child in ipairs(loc.obj:GetChildren()) do
                if (child:IsA("NumberValue") or child:IsA("IntValue")) and isStaminaName(child.Name) then
                    table.insert(G.staminaTargets, {obj=child, name="Value", kind="value", targetValue=999999})
                end
            end
        end
    end
end
local function calibrateStamina(t)
    if t.kind == "attribute" then pcall(function() t.obj:SetAttribute(t.name, 999999) end)
    elseif t.kind == "value" then pcall(function() t.obj.Value = 999999 end) end
    task.wait(0.15)
    local after
    if t.kind == "attribute" then
        local ok, v = pcall(function() return t.obj:GetAttribute(t.name) end)
        if ok then after = v end
    elseif t.kind == "value" then after = t.obj.Value end
    if type(after) == "number" and after >= 50 then t.targetValue = after
    else t.targetValue = 999999 end
end
local function updateStamina()
    for _, t in ipairs(G.staminaTargets) do
        if t.targetValue ~= nil then
            if t.kind == "attribute" then
                local ok, current = pcall(function() return t.obj:GetAttribute(t.name) end)
                if ok and type(current) == "number" and current < t.targetValue then
                    pcall(function() t.obj:SetAttribute(t.name, t.targetValue) end)
                end
            elseif t.kind == "value" then
                if t.obj.Value < t.targetValue then pcall(function() t.obj.Value = t.targetValue end) end
            end
        end
    end
end
local function enableStamina()
    if G.staminaConnections then return end
    recordStamina()
    if #G.staminaTargets == 0 then LOG("Stamina: nenhum", "err"); return end
    LOG("Stamina: "..#G.staminaTargets.." target(s)", "ok")
    G.staminaConnections = {
        G.RS.RenderStepped:Connect(function() if G.S.infiniteStamina then pcall(updateStamina) end end),
        G.RS.Heartbeat:Connect(function() if G.S.infiniteStamina then pcall(updateStamina) end end),
        G.RS.Stepped:Connect(function() if G.S.infiniteStamina then pcall(updateStamina) end end),
    }
    task.spawn(function() for _, t in ipairs(G.staminaTargets) do pcall(calibrateStamina, t) end end)
end
local function disableStamina()
    if G.staminaConnections then
        for _, conn in ipairs(G.staminaConnections) do pcall(function() conn:Disconnect() end) end
        G.staminaConnections = nil
    end
end

local WATER_KWS = {"water","lake","river","ocean","pond","sea"}
local GRASS_MATS = {Enum.Material.Grass, Enum.Material.LeafyGrass, Enum.Material.Ground}

local function isWaterPart(part)
    if not part or not part.Name then return false end
    local l = string.lower(part.Name)
    for _, kw in ipairs(WATER_KWS) do
        if string.find(l, kw, 1, true) then return true end
    end
    return false
end

local function findWaterPos()
    local char = G.pl.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    local downHit = G.W:Raycast(hrp.Position, Vector3.new(0, -30, 0), params)
    if downHit and isWaterPart(downHit.Instance) then
        return hrp.Position, 0, "already_in_"..downHit.Instance.Name
    end
    local bestPart, bestDist
    for _, obj in ipairs(G.W:GetDescendants()) do
        if obj:IsA("BasePart") and isWaterPart(obj) then
            local d = (obj.Position - hrp.Position).Magnitude
            if not bestDist or d < bestDist then
                bestPart, bestDist = obj, d
            end
        end
    end
    if not bestPart then return nil end
    local topY = bestPart.Position.Y + bestPart.Size.Y * 0.5
    local rayStart = Vector3.new(bestPart.Position.X, topY + 20, bestPart.Position.Z)
    local hit = G.W:Raycast(rayStart, Vector3.new(0, -(bestPart.Size.Y + 60), 0), params)
    local surfaceY
    if hit and isWaterPart(hit.Instance) then
        surfaceY = hit.Position.Y
    else
        surfaceY = topY
    end
    if surfaceY < hrp.Position.Y - MAX_Y_DROP then
        return nil, bestDist, "too_low"
    end
    return Vector3.new(bestPart.Position.X, surfaceY + 3, bestPart.Position.Z), bestDist, bestPart.Name
end

local function findGrassPos()
    local char = G.pl.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    local downHit = G.W:Raycast(hrp.Position, Vector3.new(0, -15, 0), params)
    if downHit then
        for _, m in ipairs(GRASS_MATS) do
            if downHit.Material == m then
                return hrp.Position, 0, "already_in_"..downHit.Material.Name
            end
        end
    end
    for r = 5, 500, 20 do
        for i = 0, 15 do
            local a = (i/15)*math.pi*2
            local cp = hrp.Position + Vector3.new(math.cos(a)*r, 0, math.sin(a)*r)
            local hit = G.W:Raycast(cp + Vector3.new(0, 80, 0), Vector3.new(0, -160, 0), params)
            if hit then
                for _, m in ipairs(GRASS_MATS) do
                    if hit.Material == m then
                        return hit.Position + Vector3.new(0, 3, 0), r, hit.Material.Name
                    end
                end
            end
        end
    end
    return nil
end

local function teleportSafely(hrp, destPos, label)
    if not hrp or not hrp.Parent then return false end
    local currentY = hrp.Position.Y
    local newY = destPos.Y
    if newY < currentY - MAX_Y_DROP then
        LOG(string.format("%s: TP abortado (Y cai %.0f studs, max %d)", label, currentY - newY, MAX_Y_DROP), "warn")
        return false
    end
    pcall(function()
        hrp.CFrame = CFrame.new(destPos + Vector3.new(0, 2, 0))
    end)
    return true
end

local function enableAutoDrink()
    if G.drinkConn then return end
    if not G.RM.subState then LOG("Auto Drink: sem substate remote", "err"); return end
    G.drinkState = "clear"
    local current = G.pl.Character and G.pl.Character:GetAttribute("Water") or 0
    LOG(string.format("Auto Drink ON · thr=%d · Water=%.1f", G.S.regenThreshold, current), "ok")
    G.drinkConn = task.spawn(function()
        local lastTP = 0
        local lastSubstate = 0
        local lastLog = 0
        while G.alive and G.S.autoDrink do
            task.wait(0.2)
            local char = G.pl.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local water = char:GetAttribute("Water") or 100
                    local threshold = G.S.regenThreshold or 90
                    local now = tick()
                    if now - lastLog > 3 then
                        lastLog = now
                        local st = (water < threshold) and "regen" or "idle"
                        LOG(string.format("AutoDrink %s: Water=%.0f thr=%.0f", st, water, threshold), "info")
                    end
                    if water < threshold then
                        if now - lastTP > TP_COOLDOWN then
                            lastTP = now
                            local pos, dist, name = findWaterPos()
                            if pos and dist and dist > ALREADY_NEAR_DIST then
                                local ok = teleportSafely(hrp, pos, "AutoDrink")
                                if ok then
                                    LOG(string.format("AutoDrink: TP %s @ %.0fm", tostring(name), dist), "info")
                                end
                            elseif pos and dist and dist <= ALREADY_NEAR_DIST then
                                LOG("AutoDrink: já perto da água", "info")
                            end
                        end
                        if now - lastSubstate > 0.4 then
                            lastSubstate = now
                            pcall(function() G.RM.subState:InvokeServer("Drinking") end)
                        end
                        G.drinkState = "drinking"
                    else
                        if G.drinkState == "drinking" then
                            G.drinkState = "clear"
                            pcall(function() G.RM.subState:InvokeServer() end)
                        end
                    end
                end
            end
        end
        G.drinkConn = nil
        if G.RM.subState then pcall(function() G.RM.subState:InvokeServer() end) end
        G.drinkState = "clear"
    end)
end

local function disableAutoDrink()
    if G.drinkConn then
        pcall(function() task.cancel(G.drinkConn) end)
        G.drinkConn = nil
    end
    if G.RM.subState then pcall(function() G.RM.subState:InvokeServer() end) end
    G.drinkState = "clear"
    LOG("Auto Drink OFF", "ok")
end

local function enableAutoFood()
    if G.foodConn then return end
    if not G.RM.subState then LOG("Auto Food: sem substate remote", "err"); return end
    G.foodState = "clear"
    local current = G.pl.Character and G.pl.Character:GetAttribute("Food") or 0
    LOG(string.format("Auto Food ON · thr=%d · Food=%.1f", G.S.regenThreshold, current), "ok")
    G.foodConn = task.spawn(function()
        local lastTP = 0
        local lastSubstate = 0
        local lastLog = 0
        while G.alive and G.S.autoFood do
            task.wait(0.2)
            local char = G.pl.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local food = char:GetAttribute("Food") or 100
                    local threshold = G.S.regenThreshold or 90
                    local now = tick()
                    if now - lastLog > 3 then
                        lastLog = now
                        local st = (food < threshold) and "regen" or "idle"
                        LOG(string.format("AutoFood %s: Food=%.0f thr=%.0f", st, food, threshold), "info")
                    end
                    if food < threshold then
                        if now - lastTP > TP_COOLDOWN then
                            lastTP = now
                            local pos, dist, mat = findGrassPos()
                            if pos and dist and dist > ALREADY_NEAR_DIST then
                                local ok = teleportSafely(hrp, pos, "AutoFood")
                                if ok then
                                    LOG(string.format("AutoFood: TP %s @ %.0fm", tostring(mat), dist), "info")
                                end
                            elseif pos and dist and dist <= ALREADY_NEAR_DIST then
                                LOG("AutoFood: já em grama", "info")
                            end
                        end
                        if now - lastSubstate > 0.4 then
                            lastSubstate = now
                            pcall(function() G.RM.subState:InvokeServer("Eating") end)
                        end
                        G.foodState = "eating"
                    else
                        if G.foodState == "eating" then
                            G.foodState = "clear"
                            pcall(function() G.RM.subState:InvokeServer() end)
                        end
                    end
                end
            end
        end
        G.foodConn = nil
        if G.RM.subState then pcall(function() G.RM.subState:InvokeServer() end) end
        G.foodState = "clear"
    end)
end

local function disableAutoFood()
    if G.foodConn then
        pcall(function() task.cancel(G.foodConn) end)
        G.foodConn = nil
    end
    if G.RM.subState then pcall(function() G.RM.subState:InvokeServer() end) end
    G.foodState = "clear"
    LOG("Auto Food OFF", "ok")
end

local function enableWalkSpeed()
    if G.walkSpeedConnection then return end
    local _,_,hum=getMy()
    if hum then G.originalWalkSpeed=hum.WalkSpeed end
    G.walkSpeedConnection=G.RS.Heartbeat:Connect(function()
        if not G.S.walkSpeed then return end
        local _,_,h=getMy()
        if h and h.WalkSpeed~=G.S.walkSpeedValue then
            pcall(function() h.WalkSpeed=G.S.walkSpeedValue end)
        end
    end)
    LOG("WalkSpeed ativado","ok")
end
local function disableWalkSpeed()
    if G.walkSpeedConnection then G.walkSpeedConnection:Disconnect() G.walkSpeedConnection=nil end
    local _,_,hum=getMy()
    if hum and G.originalWalkSpeed then pcall(function() hum.WalkSpeed=G.originalWalkSpeed end) end
    G.originalWalkSpeed=nil
end

local function getFlyDirection(cam, myHrp)
    local ok, mouseLoc = pcall(function() return G.UIS:GetMouseLocation() end)
    if ok and mouseLoc then
        local ok2, ray = pcall(function() return cam:ViewportPointToRay(mouseLoc.X, mouseLoc.Y) end)
        if ok2 and ray then
            local target = ray.Origin + ray.Direction * 200
            local delta = target - myHrp.Position
            if delta.Magnitude > 5 then return delta.Unit end
        end
    end
    return cam.CFrame.LookVector
end
local function enableFly()
    if G.flyConnection then return end
    local _,hrp,hum = getMy()
    if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AG_FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0)
    bv.P = 12500
    bv.Parent = hrp
    pcall(function() hum.PlatformStand = true end)
    G.flyConnection = G.RS.RenderStepped:Connect(function()
        if not G.S.fly then return end
        local _, myHrp = getMy()
        if not myHrp then return end
        local bvRef = myHrp:FindFirstChild("AG_FlyBV")
        if not bvRef then return end
        if G.flyLanding then
            if tick() - G.flyLandingStart > 12 then G.flyLanding = false; return end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {G.pl.Character}
            local hit = G.W:Raycast(myHrp.Position, Vector3.new(0, -100, 0), params)
            if hit and hit.Distance <= 4 then
                G.flyLanding = false
                G.S.fly = false
                task.defer(function()
                    if G.flyPaint then G.flyPaint() end
                    LOG("Pousou", "ok")
                end)
                task.defer(disableFly)
                return
            end
            bvRef.Velocity = Vector3.new(0, -50, 0)
            return
        end
        local cam = G.W.CurrentCamera
        if not cam then return end
        local dirFull = getFlyDirection(cam, myHrp)
        if dirFull.Magnitude < 0.001 then dirFull = G.flyLastDir else G.flyLastDir = dirFull end
        local horiz = Vector3.new(dirFull.X, 0, dirFull.Z)
        local rightHoriz
        if horiz.Magnitude > 0.001 then
            horiz = horiz.Unit
            rightHoriz = Vector3.new(-horiz.Z, 0, horiz.X)
        else
            rightHoriz = Vector3.new(1, 0, 0)
        end
        local move = Vector3.new(0,0,0)
        if G.UIS:IsKeyDown(Enum.KeyCode.W) then move = move + dirFull end
        if G.UIS:IsKeyDown(Enum.KeyCode.S) then move = move - dirFull end
        if G.UIS:IsKeyDown(Enum.KeyCode.D) then move = move + rightHoriz end
        if G.UIS:IsKeyDown(Enum.KeyCode.A) then move = move - rightHoriz end
        if myHrp.Position.Y >= FLY_CEILING and move.Y > 0 then move = Vector3.new(move.X, 0, move.Z) end
        if move.Magnitude > 0.001 then bvRef.Velocity = move.Unit * (G.S.flySpeed or 100)
        else bvRef.Velocity = Vector3.new(0,0,0) end
    end)
    LOG("Fly ativado @ "..tostring(G.S.flySpeed).." spd", "ok")
end
local function disableFly()
    G.flyLanding = false
    if G.flyConnection then
        pcall(function() G.flyConnection:Disconnect() end)
        G.flyConnection = nil
    end
    local _, hrp, hum = getMy()
    if hrp then
        local bv = hrp:FindFirstChild("AG_FlyBV")
        if bv then pcall(function() bv:Destroy() end) end
    end
    if hum then pcall(function() hum.PlatformStand = false end) end
    LOG("Fly desativado", "ok")
end
local function landFly()
    if not G.S.fly then LOG("Pousar: fly desligado", "warn"); return end
    G.flyLanding = true
    G.flyLandingStart = tick()
    LOG("Pousando...", "info")
end
G.pl.CharacterAdded:Connect(function()
    if not G.alive then return end
    if G.S.fly then
        task.wait(0.6)
        disableFly()
        if G.S.fly then enableFly() end
    end
end)

G.espGui=Instance.new("ScreenGui")
G.espGui.Name="AG_ESP_Visual"
G.espGui.ResetOnSpawn=false
G.espGui.IgnoreGuiInset=true
G.espGui.DisplayOrder=50
G.espGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
G.espGui.Parent=G.pg

local function makeFrame(parent,color,zIndex,anchor)
    local fr=Instance.new("Frame")
    fr.BackgroundColor3=color
    fr.BorderSizePixel=0
    fr.Visible=false
    fr.ZIndex=zIndex or 1
    fr.AnchorPoint=anchor or Vector2.new(0,0)
    fr.Parent=parent
    return fr
end

local function createPlayerESP(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")
    local adornee_part = head or hrp
    local hl=Instance.new("Highlight")
    hl.FillColor=Color3.fromRGB(255,190,50)
    hl.FillTransparency=0.5
    hl.OutlineColor=Color3.fromRGB(255,240,150)
    hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee=char
    hl.Enabled=false
    hl.Parent=G.espGui
    local bb=Instance.new("BillboardGui")
    bb.Size=UDim2.new(0,220,0,48)
    bb.StudsOffset=Vector3.new(0,4,0)
    bb.AlwaysOnTop=true
    bb.MaxDistance=10000
    bb.LightInfluence=0
    bb.Adornee=adornee_part
    bb.Enabled=false
    bb.Parent=G.espGui
    local nameLbl=Instance.new("TextLabel")
    nameLbl.BackgroundTransparency=1
    nameLbl.Size=UDim2.new(1,0,0,18)
    nameLbl.TextColor3=Color3.fromRGB(255,255,255)
    nameLbl.TextStrokeTransparency=0
    nameLbl.TextStrokeColor3=Color3.fromRGB(0,0,0)
    nameLbl.Font=Enum.Font.GothamBold
    nameLbl.TextSize=14
    nameLbl.TextXAlignment=Enum.TextXAlignment.Center
    nameLbl.Parent=bb
    local distLbl=Instance.new("TextLabel")
    distLbl.BackgroundTransparency=1
    distLbl.Size=UDim2.new(1,0,0,14)
    distLbl.Position=UDim2.new(0,0,0,30)
    distLbl.TextColor3=Color3.fromRGB(220,220,220)
    distLbl.TextStrokeTransparency=0
    distLbl.TextStrokeColor3=Color3.fromRGB(0,0,0)
    distLbl.Font=Enum.Font.Gotham
    distLbl.TextSize=12
    distLbl.TextXAlignment=Enum.TextXAlignment.Center
    distLbl.Parent=bb
    local boxTop=makeFrame(G.espGui,Color3.fromRGB(255,200,50),5)
    local boxBottom=makeFrame(G.espGui,Color3.fromRGB(255,200,50),5)
    local boxLeft=makeFrame(G.espGui,Color3.fromRGB(255,200,50),5)
    local boxRight=makeFrame(G.espGui,Color3.fromRGB(255,200,50),5)
    local healthBg=makeFrame(G.espGui,Color3.fromRGB(0,0,0),4)
    local healthFill=makeFrame(G.espGui,Color3.fromRGB(0,255,0),5)
    local line=makeFrame(G.espGui,Color3.fromRGB(255,255,255),3,Vector2.new(0.5,0.5))
    return {hl=hl,bb=bb,nameLbl=nameLbl,distLbl=distLbl,boxTop=boxTop,boxBottom=boxBottom,boxLeft=boxLeft,boxRight=boxRight,healthBg=healthBg,healthFill=healthFill,line=line}
end

local function hidePlayerESP(d)
    d.hl.Enabled=false
    d.bb.Enabled=false
    d.boxTop.Visible=false d.boxBottom.Visible=false d.boxLeft.Visible=false d.boxRight.Visible=false
    d.healthBg.Visible=false d.healthFill.Visible=false
    d.line.Visible=false
end
local function destroyPlayerESP(d)
    pcall(function() d.hl:Destroy() end)
    pcall(function() d.bb:Destroy() end)
    pcall(function() d.boxTop:Destroy() end)
    pcall(function() d.boxBottom:Destroy() end)
    pcall(function() d.boxLeft:Destroy() end)
    pcall(function() d.boxRight:Destroy() end)
    pcall(function() d.healthBg:Destroy() end)
    pcall(function() d.healthFill:Destroy() end)
    pcall(function() d.line:Destroy() end)
end
local function updatePlayerESP(p,d)
    local char=p.Character
    if not char then hidePlayerESP(d) return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local head=char:FindFirstChild("Head")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health<=0 then hidePlayerESP(d) return end
    if d.hl.Adornee ~= char then d.hl.Adornee = char end
    local target_adornee = head or hrp
    if d.bb.Adornee ~= target_adornee then d.bb.Adornee = target_adornee end
    local _,myHrp=getMy()
    local realDist=0
    if myHrp then realDist=(hrp.Position-myHrp.Position).Magnitude end
    if realDist>(G.S.espMaxDist or 600) then hidePlayerESP(d) return end
    d.hl.Enabled=G.S.esp
    if G.S.esp then d.hl.FillTransparency=0.5+math.sin(tick()*3)*0.1 end
    d.bb.Enabled=G.S.esp and (G.S.espName or G.S.espDistance)
    if d.bb.Enabled then
        d.nameLbl.Visible=G.S.espName
        d.nameLbl.Text=p.Name
        d.distLbl.Visible=G.S.espDistance
        d.distLbl.Text=math.floor(realDist).."m"
    else
        d.nameLbl.Visible=false
        d.distLbl.Visible=false
    end
    local cam=G.W.CurrentCamera
    if not cam then hidePlayerESP(d) return end
    local headPos = head and head.Position or (hrp.Position + Vector3.new(0,1.5,0))
    local hs = cam:WorldToViewportPoint(headPos + Vector3.new(0,0.4,0))
    local fs = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
    local vp = cam.ViewportSize
    if hs.X ~= hs.X or hs.Y ~= hs.Y or fs.X ~= fs.X or fs.Y ~= fs.Y then
        d.boxTop.Visible=false d.boxBottom.Visible=false d.boxLeft.Visible=false d.boxRight.Visible=false
        d.healthBg.Visible=false d.healthFill.Visible=false
        d.line.Visible=false
        return
    end
    local box_ok = hs.Z > 0 and fs.Z > 0
    local h = 0 local w = 0 local x = 0 local y = 0
    if box_ok then
        h = math.abs(fs.Y - hs.Y)
        w = h * 0.5
        x = hs.X - w/2
        y = hs.Y
    end
    local draw_box = G.S.espBox and box_ok and h >= 4
    if draw_box then
        d.boxTop.Position=UDim2.new(0,x,0,y)
        d.boxTop.Size=UDim2.new(0,w,0,1)
        d.boxTop.Visible=true
        d.boxBottom.Position=UDim2.new(0,x,0,y+h-1)
        d.boxBottom.Size=UDim2.new(0,w,0,1)
        d.boxBottom.Visible=true
        d.boxLeft.Position=UDim2.new(0,x,0,y)
        d.boxLeft.Size=UDim2.new(0,1,0,h)
        d.boxLeft.Visible=true
        d.boxRight.Position=UDim2.new(0,x+w-1,0,y)
        d.boxRight.Size=UDim2.new(0,1,0,h)
        d.boxRight.Visible=true
    else
        d.boxTop.Visible=false d.boxBottom.Visible=false d.boxLeft.Visible=false d.boxRight.Visible=false
    end
    if G.S.espHealth and draw_box then
        local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
        local barX=x-7
        d.healthBg.Position=UDim2.new(0,barX,0,y)
        d.healthBg.Size=UDim2.new(0,3,0,h)
        d.healthBg.Visible=true
        local fh=h*hp
        d.healthFill.Position=UDim2.new(0,barX,0,y+h-fh)
        d.healthFill.Size=UDim2.new(0,3,0,fh)
        d.healthFill.BackgroundColor3=Color3.fromHSV(hp*0.33,1,1)
        d.healthFill.Visible=true
    else
        d.healthBg.Visible=false d.healthFill.Visible=false
    end
    if G.S.espLine and hs.Z > 0 then
        local fromX = vp.X / 2
        local fromY = vp.Y - 50
        local toX = hs.X
        local toY = hs.Y
        local dx = toX - fromX
        local dy = toY - fromY
        local length = math.sqrt(dx*dx + dy*dy)
        if length > 1 then
            local angle = math.deg(math.atan2(dy, dx))
            local midX = (fromX + toX) / 2
            local midY = (fromY + toY) / 2
            d.line.Position = UDim2.new(0, midX, 0, midY)
            d.line.Size = UDim2.new(0, length, 0, 1)
            d.line.Rotation = angle
            d.line.Visible = true
        else
            d.line.Visible = false
        end
    else
        d.line.Visible = false
    end
end
local function addPlayerESP(p)
    if p==G.pl or G.espData[p]then return end
    local char = p.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local ok,d=pcall(createPlayerESP, char)
    if not ok or not d then LOG("Erro ESP "..p.Name..": "..tostring(d),"err") return end
    G.espData[p]=d
end
local function removePlayerESP(p)
    local d=G.espData[p]
    if not d then return end
    destroyPlayerESP(d)
    G.espData[p]=nil
end
local function refreshPlayerESP()
    if not G.S.esp then return end
    for p in pairs(G.espData)do
        if not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart")then removePlayerESP(p) end
    end
    for _,p in ipairs(G.P:GetPlayers())do
        if p~=G.pl and p.Character and p.Character:FindFirstChild("HumanoidRootPart")and not G.espData[p]then addPlayerESP(p) end
    end
end

G.carcassHLFolder=Instance.new("Folder")
G.carcassHLFolder.Name="AG_Carcass_HL"
G.carcassHLFolder.Parent=G.pg
local function createCarcassDrawing(model)
    local hl=Instance.new("Highlight")
    hl.Name="AG_Carcass_HL" hl.Adornee=model
    hl.FillColor=Color3.fromRGB(220,50,50) hl.FillTransparency=0.55
    hl.OutlineColor=Color3.fromRGB(255,130,130) hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Enabled=false
    hl.Parent=G.carcassHLFolder
    return {highlight=hl}
end
local function hideCarcass(d) if d.highlight then pcall(function() d.highlight.Enabled=false end) end end
local function destroyCarcass(d) if d.highlight then pcall(function() d.highlight:Destroy() end) end end
local function isDeadModel(m)
    if not m:IsA("Model")then return false end
    local h=m:FindFirstChildOfClass("Humanoid")
    return h and h.Health<=0
end
local function scanCarcasses()
    local now=tick()
    if now-G.lastCarcassScan<SCAN_INTERVAL then return end
    G.lastCarcassScan=now
    local found={}
    local folder=G.W:FindFirstChild("CarcassesStorageModel")
    if folder then for _,c in ipairs(folder:GetChildren())do if c:IsA("Model")then found[c]=true end end end
    for _,c in ipairs(G.W:GetChildren())do if isDeadModel(c)then found[c]=true end end
    for m,d in pairs(G.carcassData)do
        if not found[m] or not m.Parent then destroyCarcass(d) G.carcassData[m]=nil end
    end
    for m in pairs(found)do
        if not G.carcassData[m]then
            local ok,d=pcall(createCarcassDrawing,m)
            if ok and d then G.carcassData[m]=d end
        end
    end
end
local function updateCarcass(m,d)
    if not m or not m.Parent then hideCarcass(d) return end
    local hrp=m:FindFirstChild("HumanoidRootPart")
    local pos
    if hrp then pos=hrp.Position
    elseif m.PrimaryPart then pos=m.PrimaryPart.Position
    else local p=m:FindFirstChildWhichIsA("BasePart") if p then pos=p.Position end end
    if not pos then hideCarcass(d) return end
    local _,myHrp=getMy()
    local realDist=0
    if myHrp then realDist=(pos-myHrp.Position).Magnitude end
    if realDist>(G.S.espMaxDist or 600) then hideCarcass(d) return end
    if d.highlight then
        d.highlight.Enabled=true
        d.highlight.FillTransparency=0.55+math.sin(tick()*3)*0.12
    end
end
local function refreshCarcass()
    if not G.S.espCarcass then
        for m,d in pairs(G.carcassData)do destroyCarcass(d) G.carcassData[m]=nil end
        return
    end
    pcall(scanCarcasses)
    for m,d in pairs(G.carcassData)do pcall(updateCarcass,m,d) end
end

G.livingAnimalHLFolder=Instance.new("Folder")
G.livingAnimalHLFolder.Name="AG_LivingAnimal_HL"
G.livingAnimalHLFolder.Parent=G.pg
local function createLivingDrawing(model)
    local hl=Instance.new("Highlight")
    hl.Name="AG_LivingAnimal_HL" hl.Adornee=model
    hl.FillColor=Color3.fromRGB(50,150,255) hl.FillTransparency=0.55
    hl.OutlineColor=Color3.fromRGB(150,210,255) hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Enabled=false
    hl.Parent=G.livingAnimalHLFolder
    return {highlight=hl}
end
local function hideLiving(d) if d.highlight then pcall(function() d.highlight.Enabled=false end) end end
local function destroyLiving(d) if d.highlight then pcall(function() d.highlight:Destroy() end) end end
local function isLivingAnimal(m)
    if not m:IsA("Model")then return false end
    if m==G.pl.Character then return false end
    local h=m:FindFirstChildOfClass("Humanoid")
    return h and h.Health>0
end
local function scanLiving()
    local now=tick()
    if now-G.lastAnimalScan<SCAN_INTERVAL then return end
    G.lastAnimalScan=now
    local found={}
    for _,c in ipairs(G.W:GetDescendants())do if isLivingAnimal(c)then found[c]=true end end
    for m,d in pairs(G.livingAnimalData)do
        if not found[m] or not m.Parent then destroyLiving(d) G.livingAnimalData[m]=nil end
    end
    for m in pairs(found)do
        if not G.livingAnimalData[m]then
            local ok,d=pcall(createLivingDrawing,m)
            if ok and d then G.livingAnimalData[m]=d end
        end
    end
end
local function updateLiving(m,d)
    if not m or not m.Parent then hideLiving(d) return end
    local hrp=m:FindFirstChild("HumanoidRootPart")
    local pos
    if hrp then pos=hrp.Position
    elseif m.PrimaryPart then pos=m.PrimaryPart.Position
    else local p=m:FindFirstChildWhichIsA("BasePart") if p then pos=p.Position end end
    if not pos then hideLiving(d) return end
    local _,myHrp=getMy()
    local realDist=0
    if myHrp then realDist=(pos-myHrp.Position).Magnitude end
    if realDist>(G.S.espMaxDist or 600) then hideLiving(d) return end
    if d.highlight then
        d.highlight.Enabled=true
        d.highlight.FillTransparency=0.55+math.sin(tick()*3)*0.12
    end
end
local function refreshLiving()
    if not G.S.espLivingAnimal then
        for m,d in pairs(G.livingAnimalData)do destroyLiving(d) G.livingAnimalData[m]=nil end
        return
    end
    pcall(scanLiving)
    for m,d in pairs(G.livingAnimalData)do pcall(updateLiving,m,d) end
end

G.P.PlayerRemoving:Connect(function(p) removePlayerESP(p) end)
G.P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not G.alive then return end
        if G.S.esp then addPlayerESP(p) end
    end)
end)

task.spawn(function()
    while G.alive do
        if G.S.esp then
            pcall(refreshPlayerESP)
            for p,data in pairs(G.espData)do pcall(updatePlayerESP,p,data) end
        end
        if G.S.espCarcass then pcall(refreshCarcass) end
        if G.S.espLivingAnimal then pcall(refreshLiving) end
        task.wait(0.03)
    end
end)

-- ═══ GUI (Empirix) ═══
local function buildGUI()
    assert(type(G) == "table" and G.pg,
        "buildGUI: G não está em escopo — cole o ARQUIVO INTEIRO, não só a seção GUI")
    pcall(function() local o=G.pg:FindFirstChild("AG") if o then o:Destroy() end end)

    local EC = {
        Main       = Color3.fromRGB(20, 20, 23),
        Side       = Color3.fromRGB(24, 24, 28),
        Item       = Color3.fromRGB(32, 32, 37),
        Text       = Color3.fromRGB(235, 235, 240),
        Muted      = Color3.fromRGB(130, 130, 140),
        ToggleOff  = Color3.fromRGB(65, 65, 72),
        ToggleOn   = Color3.fromRGB(90, 200, 120),
        Selected   = Color3.fromRGB(40, 40, 46),
        Stroke     = Color3.fromRGB(50, 50, 58),
        Red        = Color3.fromRGB(180, 50, 50),
        Green      = Color3.fromRGB(100, 220, 130),
        Warn       = Color3.fromRGB(240, 200, 90),
        Err        = Color3.fromRGB(240, 100, 100),
    }

    local function corner(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = obj
        return c
    end

    local function makeLabel(parent, text, size, font, color)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color or EC.Text
        l.Font = font or Enum.Font.GothamMedium
        l.TextSize = size or 14
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Size = UDim2.new(1, 0, 1, 0)
        l.Parent = parent
        return l
    end

    local g = Instance.new("ScreenGui")
    g.Name = "AG"
    g.ResetOnSpawn = false
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    g.DisplayOrder = 100
    g.Parent = G.pg

    local MAIN_W, MAIN_H = 480, 420
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
    main.Position = UDim2.new(0.5, -MAIN_W/2, 0.5, -MAIN_H/2)
    main.BackgroundColor3 = EC.Main
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Active = true
    main.Parent = g
    local mainCorner = corner(main, 12)
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = EC.Stroke
    mainStroke.Thickness = 1
    mainStroke.Parent = main

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 130, 1, 0)
    sidebar.BackgroundColor3 = EC.Side
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    corner(sidebar, 12)

    local sidebarCover = Instance.new("Frame")
    sidebarCover.Size = UDim2.new(0, 20, 1, 0)
    sidebarCover.Position = UDim2.new(1, -20, 0, 0)
    sidebarCover.BackgroundColor3 = EC.Side
    sidebarCover.BorderSizePixel = 0
    sidebarCover.Parent = sidebar

    local title = makeLabel(sidebar, "Savannah", 20, Enum.Font.GothamBold, EC.Text)
    title.Position = UDim2.new(0, 14, 0, 10)
    title.Size = UDim2.new(1, -28, 0, 22)
    title.ZIndex = 1

    local version = makeLabel(sidebar, "hub v1.0", 11, Enum.Font.Gotham, EC.Muted)
    version.Position = UDim2.new(0, 14, 0, 32)
    version.Size = UDim2.new(1, -28, 0, 14)
    version.ZIndex = 1

    -- Drag handle: cobre o topo da sidebar inteira.
    -- Active=true garante que recebe InputBegan mesmo sobre os TextLabels.
    local dragHandle = Instance.new("Frame")
    dragHandle.Name = "DragHandle"
    dragHandle.Size = UDim2.new(1, 0, 0, 56)
    dragHandle.Position = UDim2.new(0, 0, 0, 0)
    dragHandle.BackgroundTransparency = 1
    dragHandle.Active = true
    dragHandle.ZIndex = 5
    dragHandle.Parent = sidebar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -26, 0, 6)
    closeBtn.BackgroundColor3 = EC.Red
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = true
    closeBtn.ZIndex = 20
    closeBtn.Parent = main
    corner(closeBtn, 6)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 20, 0, 20)
    minBtn.Position = UDim2.new(1, -50, 0, 6)
    minBtn.BackgroundColor3 = EC.Item
    minBtn.Text = "–"
    minBtn.TextColor3 = EC.Text
    minBtn.TextSize = 16
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    minBtn.AutoButtonColor = true
    minBtn.ZIndex = 20
    minBtn.Parent = main
    corner(minBtn, 6)

    local tabNames = {"Combat", "Visual", "Auto", "Extras", "Logs"}
    local tabButtons = {}
    local pages = {}

    local tabList = Instance.new("Frame")
    tabList.Size = UDim2.new(1, -16, 0, 200)
    tabList.Position = UDim2.new(0, 8, 0, 62)
    tabList.BackgroundTransparency = 1
    tabList.Parent = sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabList

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -150, 1, -20)
    content.Position = UDim2.new(0, 140, 0, 10)
    content.BackgroundTransparency = 1
    content.Parent = main

    local pageTitle = makeLabel(content, "Combat", 16, Enum.Font.GothamBold, EC.Text)
    pageTitle.Size = UDim2.new(1, -60, 0, 24)
    pageTitle.Position = UDim2.new(0, 0, 0, 0)

    local function showTab(name)
        for tn, page in pairs(pages) do
            page.Visible = (tn == name)
        end
        for tn, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = (tn == name) and EC.Selected or EC.Side
            btn.TextColor3 = (tn == name) and EC.Text or EC.Muted
        end
        pageTitle.Text = name
    end

    for _, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = EC.Side
        btn.Text = "  " .. name
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextColor3 = EC.Muted
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.Parent = tabList
        corner(btn, 8)
        tabButtons[name] = btn

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, -58)
        page.Position = UDim2.new(0, 0, 0, 34)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Visible = false
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = EC.Selected
        page.Parent = content
        pages[name] = page

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        layout.Parent = page

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 4)
        pad.Parent = page

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end)

        btn.MouseButton1Click:Connect(function()
            showTab(name)
        end)
    end

    local ord = {}
    local function nextOrder(page)
        ord[page] = (ord[page] or 0) + 1
        return ord[page]
    end

    local function addToggle(page, text, getter, setter)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 36)
        row.BackgroundColor3 = EC.Item
        row.BorderSizePixel = 0
        row.LayoutOrder = nextOrder(page)
        row.Parent = page
        corner(row, 8)

        local lbl = makeLabel(row, text, 13, Enum.Font.GothamMedium, EC.Text)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Size = UDim2.new(1, -70, 1, 0)

        local track = Instance.new("TextButton")
        track.Size = UDim2.new(0, 38, 0, 20)
        track.Position = UDim2.new(1, -50, 0.5, -10)
        track.BackgroundColor3 = getter() and EC.ToggleOn or EC.ToggleOff
        track.Text = ""
        track.AutoButtonColor = false
        track.BorderSizePixel = 0
        track.Parent = row
        corner(track, 10)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = getter() and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.Parent = track
        corner(knob, 8)

        local function paint()
            local on = getter()
            G.TS:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = on and EC.ToggleOn or EC.ToggleOff}):Play()
            G.TS:Create(knob, TweenInfo.new(0.2), {Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        end

        track.MouseButton1Click:Connect(function()
            setter(not getter())
            paint()
        end)

        return paint
    end

    local function addSlider(page, text, minV, maxV, defaultVal, onChange)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 56)
        row.BackgroundColor3 = EC.Item
        row.BorderSizePixel = 0
        row.LayoutOrder = nextOrder(page)
        row.Parent = page
        corner(row, 8)

        local lbl = makeLabel(row, text, 13, Enum.Font.GothamMedium, EC.Text)
        lbl.Position = UDim2.new(0, 12, 0, 6)
        lbl.Size = UDim2.new(1, -80, 0, 18)

        local valueLbl = makeLabel(row, tostring(defaultVal), 12, Enum.Font.GothamBold, EC.Text)
        valueLbl.Position = UDim2.new(1, -60, 0, 6)
        valueLbl.Size = UDim2.new(0, 48, 0, 18)
        valueLbl.TextXAlignment = Enum.TextXAlignment.Right

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 6)
        track.Position = UDim2.new(0, 12, 0, 36)
        track.BackgroundColor3 = EC.ToggleOff
        track.BorderSizePixel = 0
        track.Parent = row
        corner(track, 3)

        local r0 = (defaultVal - minV) / (maxV - minV)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(r0, 0, 1, 0)
        fill.BackgroundColor3 = EC.ToggleOn
        fill.BorderSizePixel = 0
        fill.Parent = track
        corner(fill, 3)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new(r0, -7, 0.5, -7)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.Parent = track
        corner(knob, 7)

        local value = defaultVal
        local dragging = false

        local function update(x)
            local ax = track.AbsolutePosition.X
            local sz = track.AbsoluteSize.X
            if sz <= 0 then return end
            local ratio = math.clamp((x - ax) / sz, 0, 1)
            local nv = math.floor(minV + ratio * (maxV - minV) + 0.5)
            nv = math.clamp(nv, minV, maxV)
            if nv ~= value then
                value = nv
                local r = (nv - minV) / (maxV - minV)
                fill.Size = UDim2.new(r, 0, 1, 0)
                knob.Position = UDim2.new(r, -7, 0.5, -7)
                valueLbl.Text = tostring(nv)
                if onChange then onChange(nv) end
            end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input.Position.X)
            end
        end)
        G.UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input.Position.X)
            end
        end)
        G.UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local function addButton(page, text, cb, color)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 36)
        row.BackgroundColor3 = color or EC.Item
        row.BorderSizePixel = 0
        row.LayoutOrder = nextOrder(page)
        row.Parent = page
        corner(row, 8)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = row

        local lbl = makeLabel(row, text, 13, Enum.Font.GothamMedium, EC.Text)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Size = UDim2.new(1, -40, 1, 0)

        btn.MouseButton1Click:Connect(function()
            local ok, err = pcall(cb)
            if not ok then LOG("Erro botão: " .. tostring(err), "err") end
        end)
    end

    local function addKeybind(page, text, kbName)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 36)
        row.BackgroundColor3 = EC.Item
        row.BorderSizePixel = 0
        row.LayoutOrder = nextOrder(page)
        row.Parent = page
        corner(row, 8)

        local lbl = makeLabel(row, text, 13, Enum.Font.GothamMedium, EC.Text)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Size = UDim2.new(1, -90, 1, 0)

        local keyBtn = Instance.new("TextButton")
        keyBtn.Size = UDim2.new(0, 50, 0, 22)
        keyBtn.Position = UDim2.new(1, -60, 0.5, -11)
        keyBtn.BackgroundColor3 = EC.Selected
        keyBtn.Text = "—"
        keyBtn.TextSize = 11
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.TextColor3 = EC.Muted
        keyBtn.BorderSizePixel = 0
        keyBtn.AutoButtonColor = false
        keyBtn.Parent = row
        corner(keyBtn, 5)

        local function upd()
            local k = G.keybinds[kbName]
            if k then
                keyBtn.Text = k
                keyBtn.TextColor3 = EC.ToggleOn
            else
                keyBtn.Text = "—"
                keyBtn.TextColor3 = EC.Muted
            end
        end
        G.keybindDisplays[kbName] = upd

        keyBtn.MouseButton1Click:Connect(function()
            if G.keybindListening == kbName then
                G.keybindListening = nil
                upd()
                return
            end
            if G.keybindListening then
                local old = G.keybindListening
                local oldD = G.keybindDisplays[old]
                if oldD then oldD() end
            end
            G.keybindListening = kbName
            keyBtn.Text = "..."
            keyBtn.TextColor3 = EC.ToggleOn
        end)
    end

    local function addSection(page, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -24, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = "  " .. text
        lbl.TextColor3 = EC.Muted
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = nextOrder(page)
        lbl.Parent = page
    end

    -- ═══ Combat ═══
    local pgCombat = pages["Combat"]
    local function setKA(v)
        G.S.killAura = v
        LOG("Kill Aura " .. (v and "ON" or "OFF"), v and "ok" or "info")
    end
    local paintKA = addToggle(pgCombat, "Kill Aura", function() return G.S.killAura end, setKA)
    G.toggleHandlers.killAura = { get = function() return G.S.killAura end, set = setKA, paint = paintKA }

    addToggle(pgCombat, "Auto Grab", function() return G.S.autoGrab end, function(v) G.S.autoGrab = v end)
    addToggle(pgCombat, "Anti Grab", function() return G.S.antiGrab end, function(v) G.S.antiGrab = v end)

    -- ═══ Visual ═══
    local pgVisual = pages["Visual"]
    local function setESP(v)
        G.S.esp = v
        if v then
            pcall(refreshPlayerESP)
            local n = 0
            for _ in pairs(G.espData) do n = n + 1 end
            LOG("ESP: " .. n .. " player(s)", "ok")
        else
            for p in pairs(G.espData) do removePlayerESP(p) end
            LOG("ESP OFF", "ok")
        end
    end
    local paintESP = addToggle(pgVisual, "ESP Jogadores", function() return G.S.esp end, setESP)
    G.toggleHandlers.esp = { get = function() return G.S.esp end, set = setESP, paint = paintESP }

    addToggle(pgVisual, "Caixa", function() return G.S.espBox end, function(v) G.S.espBox = v end)
    addToggle(pgVisual, "Linha", function() return G.S.espLine end, function(v) G.S.espLine = v end)
    addToggle(pgVisual, "Vida", function() return G.S.espHealth end, function(v) G.S.espHealth = v end)
    addToggle(pgVisual, "Nome", function() return G.S.espName end, function(v) G.S.espName = v end)
    addToggle(pgVisual, "Distância", function() return G.S.espDistance end, function(v) G.S.espDistance = v end)
    addSlider(pgVisual, "Alcance ESP (m)", 50, 2000, G.S.espMaxDist, function(v) G.S.espMaxDist = v end)
    addToggle(pgVisual, "ESP Mortos", function() return G.S.espCarcass end, function(v)
        G.S.espCarcass = v
        if v then LOG("Mortos ON", "ok")
        else
            for m, d in pairs(G.carcassData) do destroyCarcass(d) end
            G.carcassData = {}
            LOG("Mortos OFF", "ok")
        end
    end)
    addToggle(pgVisual, "ESP Holograma", function() return G.S.espLivingAnimal end, function(v)
        G.S.espLivingAnimal = v
        if v then LOG("Holograma ON", "ok")
        else
            for m, d in pairs(G.livingAnimalData) do destroyLiving(d) end
            G.livingAnimalData = {}
            LOG("Holograma OFF", "ok")
        end
    end)

    -- ═══ Auto ═══
    local pgAuto = pages["Auto"]
    addSlider(pgAuto, "Threshold (regen abaixo)", 20, 99, G.S.regenThreshold, function(v) G.S.regenThreshold = v end)
    addToggle(pgAuto, "Auto Food (Eating)", function() return G.S.autoFood end, function(v)
        G.S.autoFood = v
        if v then enableAutoFood() else disableAutoFood() end
    end)
    addToggle(pgAuto, "Auto Drink (Drinking)", function() return G.S.autoDrink end, function(v)
        G.S.autoDrink = v
        if v then enableAutoDrink() else disableAutoDrink() end
    end)

    -- ═══ Extras ═══
    local pgExtras = pages["Extras"]
    addToggle(pgExtras, "Stamina Infinita", function() return G.S.infiniteStamina end, function(v)
        G.S.infiniteStamina = v
        if v then enableStamina() else disableStamina() end
    end)

    local function setWS(v)
        G.S.walkSpeed = v
        if v then enableWalkSpeed() else disableWalkSpeed() end
    end
    local paintWS = addToggle(pgExtras, "WalkSpeed", function() return G.S.walkSpeed end, setWS)
    G.toggleHandlers.walkSpeed = { get = function() return G.S.walkSpeed end, set = setWS, paint = paintWS }

    addSlider(pgExtras, "Velocidade", WALKSPEED_MIN, WALKSPEED_MAX, G.S.walkSpeedValue, function(v) G.S.walkSpeedValue = v end)

    local function setFly(v)
        G.S.fly = v
        if v then enableFly() else disableFly() end
    end
    local paintFly = addToggle(pgExtras, "Fly (mouse 3D)", function() return G.S.fly end, setFly)
    G.flyPaint = paintFly
    G.toggleHandlers.fly = { get = function() return G.S.fly end, set = setFly, paint = paintFly }

    addSlider(pgExtras, "Velocidade Fly", 20, 500, G.S.flySpeed, function(v)
        G.S.flySpeed = v
        if G.S.fly then
            local _, hrp = getMy()
            if hrp then
                local bv = hrp:FindFirstChild("AG_FlyBV")
                if bv and bv.Velocity.Magnitude > 0.01 then
                    bv.Velocity = bv.Velocity.Unit * v
                end
            end
        end
    end)
    addButton(pgExtras, "Pousar (Fly)", function() landFly() end)

    addToggle(pgExtras, "Fullbright", function() return G.S.fullbright end, function(v)
        G.S.fullbright = v
        if v then enableFullbright() else disableFullbright() end
    end)

    addSection(pgExtras, "Keybinds")
    addKeybind(pgExtras, "Kill Aura", "killAura")
    addKeybind(pgExtras, "ESP", "esp")
    addKeybind(pgExtras, "WalkSpeed", "walkSpeed")
    addKeybind(pgExtras, "Fly (mouse 3D)", "fly")

    -- ═══ Logs ═══
    local pgLogs = pages["Logs"]
    addButton(pgLogs, "Copiar logs", function()
        local sc = setclipboard or (getgenv and getgenv().setclipboard) or (syn and syn.write_clipboard)
        if not sc then LOG("setclipboard indisponível", "err"); return end
        local lines = {}
        for _, e in ipairs(G.logHistory) do
            table.insert(lines, "[" .. os.date("%H:%M:%S", e.t) .. "] " .. e.msg)
        end
        local ok = pcall(sc, table.concat(lines, "\n"))
        if ok then LOG("Logs copiados (" .. #G.logHistory .. ")", "ok")
        else LOG("Falha ao copiar", "err") end
    end)

    local logFrame = Instance.new("Frame")
    logFrame.Size = UDim2.new(1, -24, 0, 260)
    logFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 19)
    logFrame.BorderSizePixel = 0
    logFrame.LayoutOrder = nextOrder(pgLogs)
    logFrame.Parent = pgLogs
    corner(logFrame, 8)

    local logScroll = Instance.new("ScrollingFrame")
    logScroll.Size = UDim2.new(1, -10, 1, -10)
    logScroll.Position = UDim2.new(0, 5, 0, 5)
    logScroll.BackgroundTransparency = 1
    logScroll.BorderSizePixel = 0
    logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    logScroll.ScrollBarThickness = 4
    logScroll.ScrollBarImageColor3 = EC.Selected
    logScroll.Parent = logFrame

    local logLayout = Instance.new("UIListLayout")
    logLayout.Padding = UDim.new(0, 2)
    logLayout.Parent = logScroll
    logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        logScroll.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 6)
    end)

    local logLines = {}
    local lastLogCount = 0

    task.spawn(function()
        while g.Parent and G.alive do
            task.wait(0.5)
            if #G.logHistory ~= lastLogCount then
                lastLogCount = #G.logHistory
                for _, l in ipairs(logLines) do
                    if l.Parent then l:Destroy() end
                end
                logLines = {}
                local startIdx = math.max(1, #G.logHistory - 50)
                for i = startIdx, #G.logHistory do
                    local e = G.logHistory[i]
                    if e then
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 0, 14)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = os.date("%H:%M:%S", e.t) .. "  " .. e.msg
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.TextSize = 10
                        lbl.Font = Enum.Font.Code
                        lbl.TextTruncate = Enum.TextTruncate.AtEnd
                        if e.lvl == "ok" then lbl.TextColor3 = EC.Green
                        elseif e.lvl == "warn" then lbl.TextColor3 = EC.Warn
                        elseif e.lvl == "err" then lbl.TextColor3 = EC.Err
                        else lbl.TextColor3 = EC.Text end
                        lbl.Parent = logScroll
                        table.insert(logLines, lbl)
                    end
                end
            end
        end
    end)

    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 20)
    statusBar.Position = UDim2.new(0, 0, 1, -24)
    statusBar.BackgroundTransparency = 1
    statusBar.Parent = content

    local statusLbl = makeLabel(statusBar, "Idle", 10, Enum.Font.Gotham, EC.Muted)
    statusLbl.TextTruncate = Enum.TextTruncate.AtEnd

    task.spawn(function()
        while g.Parent and G.alive do
            task.wait(0.3)
            local parts = {}
            if G.S.killAura then
                pcall(function()
                    local all = getAllInRange(ATTACK_RANGE)
                    parts[#parts+1] = "KA:" .. #all
                end)
            end
            if G.S.autoGrab then parts[#parts+1] = "Grab" end
            if G.S.antiGrab then parts[#parts+1] = "Anti" end
            if G.S.autoFood then
                local ch = G.pl.Character
                local f = ch and ch:GetAttribute("Food") or 0
                parts[#parts+1] = string.format("Food:%.0f", f)
            end
            if G.S.autoDrink then
                local ch = G.pl.Character
                local w = ch and ch:GetAttribute("Water") or 0
                parts[#parts+1] = string.format("Wat:%.0f", w)
            end
            if G.S.infiniteStamina then parts[#parts+1] = "Stam" end
            if G.S.walkSpeed then parts[#parts+1] = "Spd:" .. G.S.walkSpeedValue end
            if G.S.fly then
                if G.flyLanding then parts[#parts+1] = "Landing"
                else parts[#parts+1] = "Fly:" .. G.S.flySpeed end
            end
            if G.S.fullbright then parts[#parts+1] = "FB" end
            if G.S.esp then
                local n = 0
                for _ in pairs(G.espData) do n = n + 1 end
                parts[#parts+1] = "ESP:" .. n
            end
            if G.S.espCarcass then
                local n = 0
                for _ in pairs(G.carcassData) do n = n + 1 end
                parts[#parts+1] = "M:" .. n
            end
            if G.S.espLivingAnimal then
                local n = 0
                for _ in pairs(G.livingAnimalData) do n = n + 1 end
                parts[#parts+1] = "H:" .. n
            end
            if #parts == 0 then
                statusLbl.Text = "Idle"
                statusLbl.TextColor3 = EC.Muted
            else
                statusLbl.Text = table.concat(parts, " · ")
                statusLbl.TextColor3 = EC.ToggleOn
            end
        end
    end)

    local profile = Instance.new("Frame")
    profile.Size = UDim2.new(1, -16, 0, 50)
    profile.Position = UDim2.new(0, 8, 1, -58)
    profile.BackgroundTransparency = 1
    profile.Parent = sidebar

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 36, 0, 36)
    avatar.Position = UDim2.new(0, 4, 0.5, -18)
    avatar.BackgroundColor3 = EC.Item
    avatar.Image = ""
    avatar.BorderSizePixel = 0
    avatar.Parent = profile
    corner(avatar, 18)

    local nameLabel = makeLabel(profile, G.pl.DisplayName, 12, Enum.Font.GothamBold, EC.Text)
    nameLabel.Position = UDim2.new(0, 48, 0, 8)
    nameLabel.Size = UDim2.new(1, -52, 0, 16)

    local userLabel = makeLabel(profile, "@" .. G.pl.Name, 10, Enum.Font.Gotham, EC.Muted)
    userLabel.Position = UDim2.new(0, 48, 0, 26)
    userLabel.Size = UDim2.new(1, -52, 0, 14)

    local function refreshAvatar()
        local ok, url = pcall(function()
            return G.P:GetUserThumbnailAsync(G.pl.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and url then avatar.Image = url end
    end
    task.spawn(function()
        while g.Parent and G.alive do
            refreshAvatar()
            task.wait(30)
        end
    end)

    G.pl:GetPropertyChangedSignal("DisplayName"):Connect(function()
        nameLabel.Text = G.pl.DisplayName
    end)

    -- ═══ Drag: handle do header (expanded) ═══
    local dragging, dragStart, startPos = false, nil, nil

    dragHandle.InputBegan:Connect(function(input)
        if minimized then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    -- ═══ Drag: bolha minimizada ═══
    local minDragging, minDragStart, minStartPos, minMoved = false, nil, nil, false

    minBtn.InputBegan:Connect(function(input)
        if not minimized then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            minDragging = true
            minMoved = false
            minDragStart = input.Position
            minStartPos = main.Position
        end
    end)

    G.UIS.InputChanged:Connect(function(input)
        local isMove = (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
        if not isMove then return end
        if dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        elseif minDragging then
            local delta = input.Position - minDragStart
            if delta.Magnitude > 3 then minMoved = true end
            main.Position = UDim2.new(
                minStartPos.X.Scale, minStartPos.X.Offset + delta.X,
                minStartPos.Y.Scale, minStartPos.Y.Offset + delta.Y
            )
        end
    end)

    G.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            minDragging = false
        end
    end)

    -- ═══ Minimize ═══
    local minimized = false

    local function applyMinimized(state)
        minimized = state
        sidebar.Visible = not state
        content.Visible = not state
        closeBtn.Visible = not state

        if state then
            mainCorner.CornerRadius = UDim.new(1, 0)
            G.TS:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 52, 0, 52),
                BackgroundColor3 = EC.Side,
            }):Play()
            G.TS:Create(mainStroke, TweenInfo.new(0.2), { Color = EC.ToggleOn, Thickness = 2 }):Play()
            minBtn.Size = UDim2.new(1, 0, 1, 0)
            minBtn.Position = UDim2.new(0, 0, 0, 0)
            minBtn.BackgroundTransparency = 1
            minBtn.Text = "S"
            minBtn.TextSize = 22
            minBtn.TextColor3 = EC.ToggleOn
            minBtn.AutoButtonColor = false
        else
            mainCorner.CornerRadius = UDim.new(0, 12)
            G.TS:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, MAIN_W, 0, MAIN_H),
                BackgroundColor3 = EC.Main,
            }):Play()
            G.TS:Create(mainStroke, TweenInfo.new(0.2), { Color = EC.Stroke, Thickness = 1 }):Play()
            minBtn.Size = UDim2.new(0, 20, 0, 20)
            minBtn.Position = UDim2.new(1, -50, 0, 6)
            minBtn.BackgroundTransparency = 0
            minBtn.Text = "–"
            minBtn.TextSize = 16
            minBtn.TextColor3 = EC.Text
            minBtn.AutoButtonColor = true
        end
    end

    minBtn.MouseButton1Click:Connect(function()
        if minimized and minMoved then return end
        applyMinimized(not minimized)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        G.S.killAura = false G.S.autoGrab = false G.S.antiGrab = false
        G.S.esp = false G.S.espCarcass = false G.S.espLivingAnimal = false
        G.S.infiniteStamina = false G.S.walkSpeed = false
        G.S.fly = false
        G.S.fullbright = false G.S.autoFood = false G.S.autoDrink = false
        pcall(disableStamina) pcall(disableWalkSpeed) pcall(disableFullbright) pcall(disableFly)
        pcall(disableAutoFood) pcall(disableAutoDrink)
        for p in pairs(G.espData) do pcall(removePlayerESP, p) end
        for m, d in pairs(G.carcassData) do pcall(destroyCarcass, d) end
        for m, d in pairs(G.livingAnimalData) do pcall(destroyLiving, d) end
        G.carcassData = {} G.livingAnimalData = {} G.espData = {}
        for k in pairs(G.keybinds) do G.keybinds[k] = nil end
        G.keybindListening = nil
        G.alive = false g.Enabled = false G.espGui.Enabled = false
        LOG("X — tudo desligado", "warn")
    end)

    showTab("Combat")
end
buildGUI()
