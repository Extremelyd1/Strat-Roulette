public ConfigureSpeed(char speed[500]) {
	float newPlayerSpeed = StringToFloat(speed);
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client)) {
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", newPlayerSpeed);
		}
	}
}

public ResetSpeed() {
	// Not necessary, gets reset on new round
}
