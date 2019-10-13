public Action MatchOverEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	ServerCommand("mp_match_restart_delay 600");
}

public Action:RoundEndEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	SafeKillTimer(voteTimer);
	voteTimer = INVALID_HANDLE;
}

public Action:RoundStartEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	if (IsPugSetupMatchLive() || inGame) {
		ResetLastRound();

		ReadNewRound();
		// Don't create new timer if another already exists
		if (voteTimer == INVALID_HANDLE && !nextRoundVoted) {
			voteTimer = CreateTimer(GetConVarInt(mp_freezetime) + 15.0, VoteTimer);
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
