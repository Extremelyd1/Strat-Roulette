Handle slowMotionTimer;
bool currentSlowMotion = false;

public ConfigureSlowMotion() {
	slowMotionTimer = CreateTimer(1.0, SlowMotionTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetSlowMotion() {
	SafeKillTimer(slowMotionTimer);

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
	}
	SetConVarInt(sv_gravity, 800);
}

public Action:SlowMotionTimer(Handle timer) {
	int randomInt = GetRandomInt(0, 2);

	if (randomInt == 0) {
		currentSlowMotion = !currentSlowMotion;
		for (new i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && IsPlayerAlive(i)) {
				if (currentSlowMotion) {
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.3);
				} else {
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
				}
			}
		}
		if (currentSlowMotion) {
			SetConVarInt(sv_gravity, 400);
		} else {
			SetConVarInt(sv_gravity, 800);
		}
	}

	return Plugin_Continue;
}
