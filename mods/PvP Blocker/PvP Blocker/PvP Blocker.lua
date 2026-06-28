local orig_sync_friendly_fire_damage = UnitNetworkHandler.sync_friendly_fire_damage
function UnitNetworkHandler:sync_friendly_fire_damage(peer_id, unit, damage, variant, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if managers.mutators:is_mutator_active(MutatorFriendlyFire) then
		orig_sync_friendly_fire_damage(self, peer_id, unit, damage, variant, sender)
	else
		if Network:is_server() then
			if not managers.ban_list:banned(peer:user_id()) then
				managers.ban_list:ban(peer:user_id(), peer:name())
			end

			managers.network:session():send_to_peers("kick_peer", peer:id(), 6)
			managers.network:session():on_peer_kicked(peer, peer:id(), 6)

			managers.chat:_receive_message(ChatManager.GAME, peer:name(), "Banned trying to kill you...", Color.green)
		else
			managers.chat:_receive_message(ChatManager.GAME, peer:name(), "is trying to kill you...", Color.red)
		end
	end
end