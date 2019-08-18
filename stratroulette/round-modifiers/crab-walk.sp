bool crabWalkActive = false;

public ConfigureCrabWalk() {
	crabWalkActive = true;
}

public ResetCrabWalk() {
	crabWalkActive = false;
}

public Action:CrabWalkOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (crabWalkActive) {
		if (buttons & IN_FORWARD || buttons & IN_BACK) {
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}
