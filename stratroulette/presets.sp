public Action:DenyDropListener(int client, const char[] command, int args) {
	return Plugin_Stop;
}

public bool PlayerRayFilter(int entity, mask, any:data) {
	if (entity == data) {
		return false;
	}
	return true;
}
