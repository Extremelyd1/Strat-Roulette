bool oneDirectionActive = false;

public ConfigureOneDirection() {
	oneDirectionActive = true;
}

public ResetOneDirection() {
	oneDirectionActive = false;
}

public Action:OneDirectionOnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if (oneDirectionActive) {
		if (buttons & IN_FORWARD || buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT) {
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}
