#define PROPULSION_KNOCKBACK 700.0
#define PROPULSION_VELOCITY 0.3

Handle propulsionTimer;

public ConfigurePropulsion() {
	HookEvent("weapon_fire", PropulsionWeaponFireEvent);

	propulsionTimer = CreateTimer(0.1, PropulsionMovementTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public ResetPropulsion() {
	SafeKillTimer(propulsionTimer);

	UnhookEvent("weapon_fire", PropulsionWeaponFireEvent);
}

public Action:PropulsionMovementTimer(Handle timer) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			if (GetEntityFlags(client) & FL_ONGROUND) {
				SetEntityMoveType(client, MOVETYPE_NONE);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Float: {0.0, 0.0, 0.0});
			}
		}
	}
}

public Action:PropulsionWeaponFireEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (GetActiveWeaponClipAmmo(client) <= 0) {
		return Plugin_Continue;
	}

	SetEntityMoveType(client, MOVETYPE_WALK);

	float velocity[3];

	GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);

	float eyeAngles[3];
	float forwardVectors[3];

	GetClientEyeAngles(client, eyeAngles);
	GetAngleVectors(eyeAngles, forwardVectors, NULL_VECTOR, NULL_VECTOR);

	for (int i = 0; i < 3; i++) {
		velocity[i] = velocity[i] * PROPULSION_VELOCITY - forwardVectors[i] * PROPULSION_KNOCKBACK;
	}

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);

	return Plugin_Continue;
}
