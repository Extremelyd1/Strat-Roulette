public Action MatchOverEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	ServerCommand("mp_match_restart_delay 600");
}

public Action:RoundEndEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	EndRoundVote();
}

public Action:RoundStartEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	if (FindEntityByClassname(-1, "func_hostage_rescue") == -1) {
		int entity = CreateEntityByName("func_hostage_rescue");
		DispatchKeyValue(entity, "targetname", "fake_hostage_rescue");
		DispatchKeyValue(entity, "origin", "-1000 -1000, -1000");
		DispatchSpawn(entity);
	}

	if (IsPugSetupMatchLive() || inGame) {
		ResetLastRound();

		ReadNewRound();
	}
}

public Action:PlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	if (IsPugSetupMatchLive() || inGame) {
		new client = GetClientOfUserId(GetEventInt(event, "userid"));

		if (IsClientInGame(client) && !IsFakeClient(client)) {
			int team = GetClientTeam(client);
			if ((team == CS_TEAM_CT && GetConVarInt(mp_respawn_on_death_ct) == 0)
				|| (team == CS_TEAM_T && GetConVarInt(mp_respawn_on_death_t) == 0)) {
				PlayerDeathCheckVote(client);
			}
		}
	}
}

public Action:SwitchTeamEvent(Event event, const char[] name, bool dontBroadcast) {

	if (!pugSetupLoaded && !inGame && g_AutoStart.IntValue == 1) {
		int numPlayers = GetEventInt(event, "numPlayers");

		if (numPlayers >= g_AutoStartMinPlayers.IntValue) {
			ServerCommand("mp_warmup_end 5");
			inGame = true;
		}
	}
}
