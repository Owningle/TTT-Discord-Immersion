AddCSLuaFile()
resource.AddFile("materials/deaf-icon.png")
if (CLIENT) then

	local drawDeaf = false
	local deafIcon = Material("materials/deaf-icon.png")

	net.Receive("drawDeaf",function()
		drawDeaf = net.ReadBool()
	end)

	hook.Add( "HUDPaint", "ttt_dcrdint_HUDPaint", function()
		if (!drawDeaf) then return end
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(deafIcon)
		surface.DrawTexturedRect(0, 0, 64, 64)
	end )


	return
end

util.AddNetworkString("drawDeaf")
CreateConVar("ttt_dcrdint_host", "localhost", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Sets the node server address.")
CreateConVar("ttt_dcrdint_port", "37405", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Sets the node server port.")
CreateConVar("ttt_dcrdint_name", "[TTT Discord Immersion] ", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Sets the Plugin Prefix for helpermessages.") --The name which will be displayed in front of any Message
CreateConVar("ttt_dcrdint_cachefile", "ttt_dcrdint.dat", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Sets the cache file used tro store discord and steam ids that have been paired.")
CreateConVar("ttt_dcrdint_bottries", 4, FCVAR_ARCHIVE + FCVAR_NOTIFY, "Sets the amount of times the addon should try and communicate with the discord bot server.")
CreateConVar("ttt_dcrdint_enabled", 1, FCVAR_ARCHIVE + FCVAR_NOTIFY, "Enable or disables the addon.")
CreateConVar("ttt_dcrdint_phoenixdeafen", 1, FCVAR_ARCHIVE + FCVAR_NOTIFY, "Enables or disables the deafening of the phoenix on first death.")

phoenixDead = {}
deafened = {}

currentlyPrep = false
denyDeafen = true
print("DISCORD INTEGRATION ENABLED")
idTable = {}
idTable_raw = file.Read( GetConVar("ttt_dcrdint_cachefile"):GetString(), "DATA" )
if (idTable_raw) then
    idTable = util.JSONToTable(idTable_raw)
end

function printCon(message, error)
    if error then
        prefix = "[WARN] - "..GetConVar("ttt_dcrdint_name"):GetString()
    else
        prefix = GetConVar("ttt_dcrdint_name"):GetString()
    end
    print(prefix..message)
end


function saveIDs()
	file.Write( GetConVar("ttt_dcrdint_cachefile"):GetString(), util.TableToJSON(idTable))
end

function GET(req,params,cb,tries)
	httpAdress = ("http://"..GetConVar("ttt_dcrdint_host"):GetString()..":"..GetConVar("ttt_dcrdint_port"):GetString())
	http.Fetch(httpAdress,function(res)
			--print(res)
		cb(util.JSONToTable(res))
	end,function(err)
		print("["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."Request to bot failed. Is the bot running?")
		print("Err: "..err)
		if (!tries) then tries = GetConVar("ttt_dcrdint_bottries"):GetInt() end
		if (tries != 0) then GET(req,params,cb, tries-1) end
	end,{req=req,params=util.TableToJSON(params)})
end

function sendClientIconInfo(ply,deaf)
	net.Start("drawDeaf")
	net.WriteBool(deaf)
	net.Send(ply)
end

function sendClientIconInfoAll(deaf)
	net.Start("drawDeaf")
	net.WriteBool(deaf)
	net.Broadcast()
end

function isDeafened(ply)
	return deafened[ply]
end

function idString()
    idStringBuilder = ""
    firstItteration = true
    for _, ply in ipairs(player.GetAll()) do
        for steam, discordID in pairs(idTable) do
            if ply:SteamID() == steam then
                print(steam.." True")
                if firstItteration then
                    idStringBuilder = discordID
                    firstItteration = false
                else
                    print(steam.." False")
                    idStringBuilder = idStringBuilder..",;,"..discordID
              end
            end
        end
    end
    return idStringBuilder
end

function unDeafen(ply)
    if (idTable[ply:SteamID()]) then
        GET("undeafen",{ids=idTable[ply:SteamID()]}, function(res)
            if (res.success) then
                if (ply ~= nil) then 
                    ply:PrintMessage(HUD_PRINTCENTER,"["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."You're not deafened in discord!")
                end
                sendClientIconInfo(ply,false)
                deafened[ply] = false
            else
                print("["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."Error: "..res.error)
            end
        end)
    end
end

function deafenAll()
    if (!denyDeafen) then
        if (!currentlyPrep) then
            GET("deafen", {ids=idString()}, function(res)
                if (res.success) then
                    PrintMessage(HUD_PRINTCENTER,"["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."You're deafened in discord!")
                    sendClientIconInfoAll(true)
                    for i=#deafened -1, 0, -1 do
                        deafened[i] = true
                    end
                else
                    print("["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."Error: "..res.error)
                end
            end)
        end
    end
end

function deafen(ply)
    if (!denyDeafen) then
        if (!currentlyPrep) then
            GET("deafen", {ids=idTable[ply:SteamID()]}, function(res)
                if (res.success) then
                    ply:PrintMessage(HUD_PRINTCENTER,"["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."You're deafened in discord!")
                    sendClientIconInfo(ply, true)
                    deafened[ply] = true
                else
                    print("["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."Error: "..res.error)
                end
            end)
        end
    end
end

function unDeafenAll()
    GET("undeafen",{ids=idString()}, function(res)
        if (res.success) then
            PrintMessage(HUD_PRINTCENTER,"["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."You're not deafened in discord!")
            sendClientIconInfoAll(false)
            for i = #deafened -1, 0, -1 do
                deafened[i] = false
            end
        else
            print("["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."Error: "..res.error)
        end
    end)
end

function commonRoundState()
    if gmod.GetGamemode().Name == "Trouble in Terrorist Town" or
       gmod.GetGamemode().Name == "TTT2 (Advanced Update)" then
      -- Round state 3 => Game is running
      return ((GetRoundState() == 3) and 1 or 0)
    end
  
    if gmod.GetGamemode().Name == "Murder" then
      -- Round state 1 => Game is running
      return ((gmod.GetGamemode():GetRound() == 1) and 1 or 0)
    end
  
    -- Round state could not be determined
    return -1
end




hook.Add("PlayerSay", "ttt_dcrdint_PlayerSay", function(ply,msg)
    if (string.sub(msg,1,9) != '!discord ') then return end
    tag = string.sub(msg,10)
    tag_utf8 = ""
  
    for p, c in utf8.codes(tag) do
      tag_utf8 = string.Trim(tag_utf8.." "..c)
    end
    GET("connect",{tag=tag_utf8},function(res)
        if (res.answer == 0) then ply:PrintMessage(HUD_PRINTTALK,"["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."No guild member with a discord tag like '"..tag.."' found.") end
        if (res.answer == 1) then ply:PrintMessage(HUD_PRINTTALK,"["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."Found more than one user with a discord tag like '"..tag.."'. Please specify!") end
        if (res.tag && res.id) then
            ply:PrintMessage(HUD_PRINTTALK,"["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."SteamID '"..ply:SteamID().."' successfully bound to Discord tag '"..res.tag.."'")
            idTable[ply:SteamID()] = res.id
            saveIDs()
        end
    end)
    return ""
end)

function playerdeath(ply, attacker, dmg)
    print("DIEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")
    if (attacker.IsPlayer() and attacker ~= ply) then
        if attacker:GetRole() == 7 then
            return
        end
        if GetConVar("ttt_dcrdint_phoenixdeafen"):GetBool() then
            if ply:GetRole() == 5 then
                if !phoenixDead[ply] then
                    phoenixDead[ply] = true
                    return
                end
            end
        end
        if ply:GetRole() == 4 then
            return
        end
    end
    unDeafen(ply)
end



hook.Add("PlayerInitialSpawn", "ttt_dcrdint_PlayerInitialSpawn", function(ply)
	if (idTable[ply:SteamID()]) then
        ply:PrintMessage(HUD_PRINTTALK,"["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."You are connected with discord.")
	else
		ply:PrintMessage(HUD_PRINTTALK,"["..GetConVar("ttt_dcrdint_name"):GetString().."] ".."You are not connected with discord. Write '!discord DISCORDTAG' in the chat. E.g. '!discord marcel.js#4402'")
	end
end)
hook.Add("PlayerDisconnected", "ttt_dcrdint_PlayerDisconnected", function(ply)
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then unDeafen(ply) end
  end)
hook.Add("ShutDown","ttt_dcrdint_ShutDown", function()
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then unDeafenAll() end
end)
hook.Add("TTTEndRound", "ttt_dcrdint_TTTEndRound", function()
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then
        denyDeafen = true
        unDeafenAll()
        phoenixDead = {}
    end
end)
hook.Add("OnEndRound", "ttt_dcrdint_OnEndRound", function()
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then
        denyDeafen = true
        unDeafenAll()
    end
end)
hook.Add("TTTBeginRound", "ttt_dcrdint_TTTBeginRound", function()
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then deafenAll() end
end)
hook.Add("OnStartRound", "ttt_dcrdint_OnStartRound", function()
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then deafenAll() end
end)
hook.Add("DoPlayerDeath", "ttt_dcrdint_DoPlayerDeath", function(ply, attacker, dmg)
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then 
        if (commonRoundState() == 1) then
            playerdeath(ply, attacker, dmg)
        end
    end
end)
hook.Add("TTTBeginRound", "ttt_dcrdint_TTTBeginRound", function()
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then
        denyDeafen = false
        currentlyPrep = false
        deafenAll()
    end
end)
hook.Add("PlayerSpawn", "ttt_dcrdint_PlayerSpawn", function(ply)
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then deafen(ply) end
end)
hook.Add("TTTPrepareRound", "ttt_dcrdint_TTTPrepareRound", function()
    if GetConVar("ttt_dcrdint_enabled"):GetBool() then
        denyDeafen = true
        currentlyPrep = true
    end
end)
