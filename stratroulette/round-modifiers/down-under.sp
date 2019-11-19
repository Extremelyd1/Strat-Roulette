bool downUnderActive = false;

new downUnderArray[MAXPLAYERS + 1];

public ConfigureDownUnder() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
			float position[3];
			GetClientEyePosition(client, position);

			int entity = CreateViewEntity();

			TeleportEntity(entity, position, NULL_VECTOR, NULL_VECTOR);

			float angle[3];
			GetEntPropVector(entity, Prop_Send, "m_angRotation", angle);

			angle[2] = 180.0;

			TeleportEntity(entity, NULL_VECTOR, angle, NULL_VECTOR);

			SetClientViewEntity(client, entity);

			downUnderArray[client] = entity;
		}
	}

	downUnderActive = true;
}

public ResetDownUnder() {
	downUnderActive = false;

	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			// Reset player angle
			float angles[3];
			GetClientEyeAngles(i, angles);

			angles[2] = 0.0;

			TeleportEntity(i, NULL_VECTOR, angles, NULL_VECTOR);

			// Reset view
			SetClientViewEntity(i, i);
		}
	}
}

public Action:DownUnderOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (downUnderActive) {
		// Get entity that belongs to player
		new entity = downUnderArray[client];
		if (entity != -1) {
			if (IsValidEntity(entity)) {
				// Set position and angles
				float eyeAngles[3];
				GetClientEyeAngles(client, eyeAngles);

				float position[3];
				GetClientEyePosition(client, position);

				eyeAngles[2] = 180.0;

				TeleportEntity(entity, position, eyeAngles, NULL_VECTOR);

				SetClientViewEntity(client, entity);
			}
		}
	}
}
