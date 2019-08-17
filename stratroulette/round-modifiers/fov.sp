public ConfigureFov(char fov[500]) {
	new newFov = StringToInt(fov);

	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && !IsFakeClient(client)) {
			SetEntProp(client, Prop_Send, "m_iDefaultFOV", newFov);
			SetEntProp(client, Prop_Send, "m_iFOV", newFov);
		}
	}
}

public ResetFov() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && !IsFakeClient(client)) {
			SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
			SetEntProp(client, Prop_Send, "m_iFOV", 90);
		}
	}
}
