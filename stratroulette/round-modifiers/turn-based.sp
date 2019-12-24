bool ctMove = false;

Handle turnBasedTimer;

public ConfigureTurnBased() {
	ctMove = false;

	TurnBasedFreezeTeam(CS_TEAM_CT);

	turnBasedTimer = CreateTimer(5.0, TurnBasedTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetTurnBased() {
	SafeKillTimer(turnBasedTimer);
}

public Action:TurnBasedTimer(Handle timer) {
	ctMove = !ctMove;

	if (ctMove) {
		TurnBasedFreezeTeam(CS_TEAM_T);
	} else {
		TurnBasedFreezeTeam(CS_TEAM_CT);
	}
}

public TurnBasedFreezeTeam(int team) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetClientTeam(client) == team) {
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Float: {0.0, 0.0, 0.0});
				SendMessage(client, "%t", "TurnBasedEnemyMove");
			} else {
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
				SendMessage(client, "%t", "TurnBasedMoveAgain");
			}
		}
	}
}
