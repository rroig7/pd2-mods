_G.ForceStart = ForceStart or {}

ForceStart.mod_path = ModPath
ForceStart.save_path = SavePath .. "forcestart_settings.txt"
ForceStart.password_path = SavePath .. "forcestart_password.txt"
local default_password = "/forcestart"
ForceStart.password = default_password

ForceStart.settings = {
	client_permission = 2,
	log_mode = 4
}

function ForceStart:log(text,...)
	local log_mode = self.settings.log_mode
	if log_mode == 1 or log_mode == 3 then 
		if Console then 
			Console:Log(managers.localization:text("forcestart_prefix") .. " " .. tostring(text),...)
		else
			log(managers.localization:text("forcestart_prefix") .. " " .. tostring(text),...)
		end
	end
	if log_mode == 2 or log_mode == 3 then 
		if managers.chat then 
			managers.chat:_receive_message(managers.chat._channel_id or 1, managers.localization:text("forcestart_prefix"), tostring(text), Color("FFD700"), "infamy_icon_4")
		end
	end
end

function ForceStart:GetClientPermissionSetting() 
	return self.settings.client_permission
end

function ForceStart:IsFriend(peer)
	local steamid = peer:user_id()
	for _,friend in pairs(Steam:friends()) do 
		if friend:id() == steamid then --the user_id() and id() will both return id64s even though the method names don't match; argument [peer] is a Peer, and [friend] is a ScriptSteamUser
			return true
		end
	end	
	return false
end

function ForceStart:Load()
	local file = io.open(self.save_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
	self:LoadPassword()
end

function ForceStart:LoadPassword()
	local file = io.open(self.password_path, "r")
	if file then 
		local contents = file:read("*all")
		local contents_tbl
		if contents and (contents ~= "") then 
			contents_tbl = string.split(contents,"\n")
		end
		self.password = contents_tbl and contents_tbl[1] or contents or default_password
	else
		file = io.open(self.password_path,"w+")
		file:write(self.password)
		file:close()
	end
end

function ForceStart:Save()
	local file = io.open(self.save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function ForceStart:GetPassword()
	return self.password 
end

function ForceStart:ShowPassword()
	QuickMenu:new(managers.localization:text("forcestart_show_password_title"),tostring(self.password),{
		{
			text = managers.localization:text("forcestart_dialog_ok"),
			is_cancel_button = true
		}
	},true)
end

function ForceStart:ShowHelp()
	QuickMenu:new(managers.localization:text("forcestart_password_info_prompt_title"),managers.localization:text("forcestart_password_info_prompt_desc"),{
		{
			text = managers.localization:text("forcestart_dialog_ok"),
			is_cancel_button = true
		}
	},true)
end

function ForceStart:DoForceStart(instigator)
	local session = managers.network and managers.network:session()
	if not session then 
		return
	end
	instigator = instigator or session:local_peer() --hey wanna hear a joke? what do you call a predatory reptile with great reflexes
	local instigator_name = instigator and instigator.name and instigator:name() or "[ERROR]"

	--check for dupliate names, append the peerid number if duplicate is present
	for i, peer in pairs(session:peers()) do
		if (peer ~= instigator) and (peer:name() == instigator_name) then 
			instigator_name = instigator_name .. "(" .. tostring(instigator.id and instigator:id() or "#ERROR") ..")"
			break
		end
	end
	
	if game_state_machine and game_state_machine:verify_game_state(GameStateFilters.waiting_for_players) then
		if Network:is_server() then 
			local is_desynced
			local desynced_players = {}
			for i, peer in pairs(session:peers()) do
				if not peer:synched() then
					desynced_players[i] = peer:name()
					is_desynced = true
				end
			end
			if not is_desynced then
				if managers.chat and instigator then 
					managers.chat:send_message(managers.chat._channel_id or 1,session:local_peer(),managers.localization:text("forcestart_prefix") .. " " .. string.gsub(managers.localization:text("forcestart_text_started"),"$USERNAME",instigator_name))
					
					game_state_machine:current_state():start_game_intro()
				else
					self:log("Error force-starting session: ChatManager or instigator peer is invalid. (" .. instigator_name .. " attempted to Force Start)")
				end
			elseif is_desynced then 
				self:log("Error force-starting session! You are desynced from the following players: " .. tostring(table.concat(desynced_players,",")) .. "(" .. instigator_name .. " attempted to Force Start)")
			end	
		else
			self:log("You cannot force-start a session in which you are not the host! (" .. instigator_name .. " attempted to Force Start)")
		end
	elseif game_state_machine and game_state_machine:verify_game_state(GameStateFilters.any_ingame_playing) then 
		--already in-game so do nothing
	else
		self:log("Error! No valid session to force-start! (" .. instigator_name .. " attempted to Force Start)")
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_ForceStart", function( loc )
	loc:add_localized_strings({
		forcestart_prefix = "[ForceStart]",
		forcestart_menu_title = "ForceStart Menu",
		forcestart_show_password_title = "Your ForceStart Keyword",
		forcestart_show_password_desc = "Show your starting keyword",
		forcestart_reload_password_title = "Reload keyword",
		forcestart_reload_password_desc = "Reloads your start keyword from the file",
		forcestart_set_client_permission_title = "Client Permissions",
		forcestart_set_client_permission_desc = "Choose who can use the keyword to force start the game",
		forcestart_permission_a = "All players",
		forcestart_permission_b = "Friends only",
		forcestart_permission_c = "None (only you)",
		forcestart_set_log_mode_title = "(Debug) Set Log Mode",
		forcestart_set_log_mode_desc = "Choose how errors are displayed.",
		forcestart_password_info_title = "How do I set my keyword?",
		forcestart_password_info_desc = "Click for more information",
		forcestart_password_info_prompt_title = "How to set your keyword",
		forcestart_password_info_prompt_desc = "You can change your keyword by editing your keyword file in the location:\n   " .. ForceStart.password_path .. "\nThe text on the first line of this file will be your exact keyword, including spaces. If you are changing your keyword while you are in-game, you should click the \"Reload keyword\" button below when you have saved your new keyword in the file.\nOtherwise, you are ready to play.",
		forcestart_log_mode_a = "BLT Log Only",
		forcestart_log_mode_b = "Chat Log Only",
		forcestart_log_mode_c = "All",
		forcestart_log_mode_d = "Disabled",
		forcestart_keybind_title = "Bind a key to start the game",
		forcestart_keybind_desc = "Starts the game even if not all players are ready",
		forcestart_button_title = "Force start the game",
		forcestart_button_desc = "Starts the game even if not all players are ready",
		forcestart_dialog_ok = "OK",
		forcestart_text_started = "$USERNAME force-started the game."
	})
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_ForceStart", function(menu_manager)
	
	--multiplechoice; allow client access
	--1: allow anyone to force-start the game with the password
	--2: allow only steam friends to force-start the game with the password
	--3 or literally any other value: do not allow others to force-start the game
	MenuCallbackHandler.callback_forcestart_set_client_permission = function(self,item)
		local value = tonumber(item:value())
		ForceStart.settings.client_permission = value
		ForceStart:Save()
	end
	
	--multiplechoice; log behavior
	--1: BLT log only
	--2: Chat only
	--3: BLT log + chat
	--4: Nothing
	--any other value: nothing
	MenuCallbackHandler.callback_forcestart_set_log_mode = function(self,item)
		local value = tonumber(item:value())
		ForceStart.settings.log_mode = value
		ForceStart:Save()
	end
	
	--button: opens a quickmenu window to show you your password
	MenuCallbackHandler.callback_forcestart_show_password = function(self) --delete
		ForceStart:ShowPassword()
	end
	
	--button: opens a quickmenu window to tell you how to set your password
	MenuCallbackHandler.callback_forcestart_password_info = function(self)
		ForceStart:ShowHelp()
	end
	
	--button; reloads the password saved in your forcestart_password.txt file
	MenuCallbackHandler.callback_forcestart_reload_password = function(self) --refresh
		ForceStart:LoadPassword()
	end	
	
	--button; starts the game
	MenuCallbackHandler.callback_forcestart_game = function(self)
		ForceStart:DoForceStart()
	end
	
	ForceStart:Load()
	MenuHelper:LoadFromJsonFile(ForceStart.mod_path .. "options.txt", ForceStart, ForceStart.settings)
	
end)
	