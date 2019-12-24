#define CROUCH_DIST 18.02
#define FEET_THRESHOLD 52.0

public ConfigureFeetOnly() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, FeetOnlyOnTakeDamageHook);
		}
	}
}

public ResetFeetOnly() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client)) {
			SDKUnhook(client, SDKHook_OnTakeDamage, FeetOnlyOnTakeDamageHook);
		}
	}
}

public Action:FeetOnlyOnTakeDamageHook(victim, &attacker, &inflictor, &Float:damage, &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	float eyePos[3];
	GetClientEyePosition(victim, eyePos);

	float eyeDist = GetVectorDistance(eyePos, damagePosition);

	float duckAmount = GetEntPropFloat(victim, Prop_Send, "m_flDuckAmount");

	if (eyeDist > FEET_THRESHOLD - duckAmount * CROUCH_DIST) {
		return Plugin_Continue;
	}

	return Plugin_Handled;
}
