if Network:is_server() then 
	Hooks:PostHook(ChatManager,"receive_message_by_peer","check_forcestart_chatcommand",function(self,channel_id,peer,raw_message)
		if (raw_message == ForceStart:GetPassword()) then 
			local client_access = ForceStart:GetClientPermissionSetting()
			if ((peer == managers.network:session():local_peer()) or (client_access == 1) or ((client_access == 2) and ForceStart:IsFriend(peer))) then
				ForceStart:DoForceStart(peer)
			end
		end
	end)
end