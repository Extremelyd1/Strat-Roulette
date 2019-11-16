bool crouchOnlyActive = false;

public ConfigureCrouchOnly() {
	crouchOnlyActive = true;
}

public ResetCrouchOnly() {
	crouchOnlyActive = false;
}

public Action:CrouchOnlyOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (!crouchOnlyActive) {
		return Plugin_Continue;
	}

	if (buttons & IN_DUCK) {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	} else {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
	}

	return Plugin_Continue;
}
