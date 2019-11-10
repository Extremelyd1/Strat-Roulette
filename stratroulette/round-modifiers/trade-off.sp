public ConfigureTradeOff() {
	HookEvent("player_death", TradeOffPlayerDeathEvent);
}

public ResetTradeOff() {
	UnhookEvent("player_death", TradeOffPlayerDeathEvent);
}

public Action:TradeOffPlayerDeathEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));

	RemoveWeaponsClient(killer);
}
