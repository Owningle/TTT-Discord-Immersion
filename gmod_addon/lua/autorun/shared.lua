AddCSLuaFile()
resource.AddFile("materials/deaf-icon.png")

local function log(msg)
    print('[Discord] ' .. msg)
end

local function err(msg)
    print('[Discord] [ERROR] ' .. msg)
end

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

local token         = CreateConVar('discord_token', '', FCVAR_ARCHIVE, 'Set the bot token.')
local guildID       = CreateConVar('discord_guild', '', FCVAR_ARCHIVE, 'Set the guild the bot is in')
local enabled       = CreateConVar('discord_enabled', 1, FCVAR_ARCHIVE + FCVAR_NOTIFY, 'Enable / disable the bot')

if pcall(require, 'chttp') then
    log('Using CHTTP (timschumi/gmod-chttp)')
    HTTP = CHTTP
else
    err('CHTTP is not installed!! The addon will not work without it. Please install it and then re-enable this addon: https://github.com/timschumi/gmod-chttp')
    enabled:SetBool(false)
end

local function request(method, endpoint, fail, success, body)

    if not enabled:GetBool() then return end
    
    fail = function(msg) err('Unable to communicate with the Discord API:\n'..msg) end

    local req = {
        failed = fail,
        success = success,
        method = method,
        url = 'https://discord.com/api' .. endpoint,
        body = body,
        headers = {
            ['Authorization'] = 'Bot ' .. token:GetString(),
        }
    }

    if body then
        req['type'] = 'application/json'
    end

    CHTTP(req)
end

local kvs = {}
kvs.data = {}

function kvs:open( filename )

    self.filename = filename
    self.data_raw = file.Read(filename, 'DATA')
    self.data = {}

    if self.data_raw then
        self.data = util.JSONToTable(self.data_raw)
    end
end

function kvs:get( key )
    return self.data[key]
end

function kvs:set( key, value )
    self.data[key] = value
    file.Write(self.filename, util.TableToJSON(self.data, true))
end

kvs:open('discordids.dat')

local function findUserByID( id, fail, success )
    
    request('GET', '/guilds/'..guildID:GetString()..'/members/'..id, nil, function(code, body, headers)
        if code ~= 200 then
            fail()
        end
        
        res = util.JSONToTable(body)
        success(res)
    end)
end

local function findUserByNameTag( tag, name, fail, success, after )

    local endpoint = '/guilds/'..guildID:GetString()..'/members?limit=1000'
    if after then endpoint = endpoint .. '&after=' .. after end

    request('GET', endpoint, nil, function(code, body, headers)

        if code ~= 200 then
            return fail()
        end 

        res = util.JSONToTable(body)
        local foundTag = nil

        for k, v in pairs(res) do
            if tag == v.user.discriminator then

                if foundTag and not username then
                    return fail()
                end

                foundTag = v

                if name == v.user.username then
                    return success(v)
                end
            end
        end

        if foundTag then
            return success(foundTag)
        end

        if table.getn(res) == 1000 then
            return findUserByNameTag(tag, name, fail, success, tonumber(after) + 1000)
        else
            return fail()
        end
    end)
end

local function findUser( search, fail, success )

    if string.find(search, '#') then
        local tag = string.sub(search, -4)
        local username = string.sub(search, 0, -5)
        findUserByNameTag(tag, username, fail, success)

    elseif #search > 4 then
        findUserByID(search, fail, success)

    elseif #search == 4 then
        findUserByNameTag(search, nil, fail, success)
    end
end

local plymeta = FindMetaTable('Player')
function plymeta:getDiscordID() return kvs:get(self:SteamID()) end
function plymeta:setDiscordID(id) return kvs:set(self:SteamID(), id) end

function plymeta:setDiscordDeaf( val )

    if not self:getDiscordID() then return end
    if not enabled:GetBool() or GAMEMODE.Name == 'Sandbox' then return end
    if val == self.discord_deaf then return end
    local oldstate = self.discord_deaf
    self.discord_deaf = val

    request('PATCH', '/guilds/'..guildID:GetString()..'/members/'..self:getDiscordID(), nil, function(code, body, headers)
        if code == 204 then
            if val then
                self:PrintMessage(HUD_PRINTCENTER, 'You are deafened in Discord!')
            else
                self:PrintMessage(HUD_PRINTCENTER, 'You are no longer deafened in Discord!')
            end

            net.Start('drawDeaf')
            net.WriteBool(val)
            net.Send(self)
            return
        end

        self.discord_deaf = oldstate
        res = util.JSONToTable(body)
        err('Failed to deafen user ' .. self:Nick() .. ': Code(' .. code .. '/' .. res.code .. ') ' .. res.message)

    end, '{"deaf": ' .. tostring(val) .. '}')

end

hook.Add('PlayerSay', 'TTTDiscordCommands', function(ply, msg)
    if string.sub(msg, 1, 8) != '!discord' then return end

    local inp = string.sub(msg, 10)

    findUser(inp, function()
        ply:PrintMessage(HUD_PRINTTALK, 'Failed to find user!')
    end,

    function(dUser)
        ply:setDiscordID(dUser.user.id)
        ply:PrintMessage(HUD_PRINTTALK, 'Successfully bound to user ' .. dUser.user.username .. '#' .. dUser.user.discriminator)
    end)

    return ''
end)

hook.Add('PlayerSpawn', 'PlayerSpawnDiscord', function(ply)
    if not ply:getDiscordID() then
        ply:PrintMessage(HUD_PRINTTALK, 'You are not connect to discord! Please use the !discord {ID or Tag or Username#Tag} command.')
    end

    if GAMEMODE.round_state == ROUND_ACTIVE then
        ply:setDiscordDeaf(true)
    end
end)

hook.Add('PlayerDeath', 'PlayerSpawnDiscord', function(ply, infl, atk)
    if GAMEMODE.round_state == ROUND_ACTIVE and ply:GetRole() ~= ROLE_JESTER and ply:GetRole() ~= ROLE_SWAPPER then
        ply:setDiscordDeaf(false)
    end
end)

hook.Add('TTTBeginRound', 'TTTBeginRoundDiscord', function(ply)
    DiscordDeafChecker()
end)

hook.Add('TTTEndRound', 'TTTEndRoundDiscord', function(ply)
    DiscordDeafChecker()
end)

hook.Add('ShutDown', 'ShutDownDiscord', function(ply)
    DiscordDeafChecker()
end)

function DiscordDeafChecker()
    for k, v in pairs(player.GetAll()) do
        if GAMEMODE.round_state == ROUND_ACTIVE then
            v:setDiscordDeaf(v:Alive())
        else
            v:setDiscordDeaf(false)
        end
    end
end

timer.Create('DiscordChecker', 1, 0, DiscordDeafChecker)