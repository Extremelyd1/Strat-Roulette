public Action:Hook_DenyTransmit(entity, client) {
    if (entity != client) {
        if (IsClientInGame(entity)) {
            if (!IsPlayerAlive(client)) {
                if (GetClientTeam(entity) != GetClientTeam(client)) {
                        return Plugin_Handled;
                }
            } else {
                return Plugin_Handled;
            }
        }
    }
    return Plugin_Continue;
}

public Action:Hook_MonkeySeeTransmit(entity, client) {
    /* if (!IsClientInGame(entity)) {
        return Plugin_Continue;
    }

    if (client != ctLeader && GetClientTeam(client) == CS_TEAM_CT) {
        if (entity != ctLeader && GetClientTeam(entity) == CS_TEAM_CT) {
            return Plugin_Handled;
        }
    }
    if (client != tLeader && GetClientTeam(client) == CS_TEAM_T) {
        if (entity != tLeader && GetClientTeam(entity) == CS_TEAM_T) {
            return Plugin_Handled;
        }
    } */

    return Plugin_Continue;
}

public Action:Hook_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
    if (g_Bomberman) {
        new victimHealth = GetEntProp(victim, Prop_Send, "m_iHealth");
        if (victimHealth <= damage) {
            // Victim would have been killed by bomb damage

            // Check whether team is wiped
            bool ctWiped = true;
            bool tWiped = true;

            for (int client = 1; client <= MaxClients; client++) {
                if (IsClientInGame(client) && IsPlayerAlive(client)
                    && !IsFakeClient(client) && client != victim) {
                    if (GetClientTeam(client) == CS_TEAM_CT) {
                        ctWiped = false;
                    } else if (GetClientTeam(client) == CS_TEAM_T) {
                        tWiped = false;
                    }
                }
            }

            if (!ctWiped && !tWiped) {
                KillPlayer(victim, victim);
                return Plugin_Handled;
            }

            DataPack data = new DataPack();

            if (ctWiped) {
                data.WriteCell(CS_TEAM_CT);
            } else if (tWiped) {
                data.WriteCell(CS_TEAM_T);
            }

            // Wait 0.1 seconds before killing player manually,
            // to allow round end by bomb to be bypassed
            CreateTimer(0.1, WipeTeamTimer, data);

            return Plugin_Handled;
        }
    }

    if (g_Bodyguard) {
        if (victim != ctLeader && victim != tLeader) {
            return Plugin_Handled;
        }
    }

    if (g_BuddySystem) {
        new String:victimIdString[64];
        IntToString(victim, victimIdString, sizeof(victimIdString));
        float currentChickenHealth;
        if (chickenHealth.GetValue(victimIdString, currentChickenHealth)) {
            if (damage < currentChickenHealth) {
                chickenHealth.SetValue(victimIdString, currentChickenHealth - damage);
                return Plugin_Handled;
            }
            chickenHealth.Remove(victimIdString);
            return Plugin_Continue;
        }
    }

    if (g_BuddySystem || g_HotPotato) {
        if (g_HotPotato) {
            if (attacker != victim && victim != 0 && attacker != 0 &&
                GetClientTeam(victim) != GetClientTeam(attacker)) {
                SelectHotPotato(victim);
            }
        }

        return Plugin_Handled;
    }

    if (g_Vampire) {
		if (attacker == 0) {
			return Plugin_Continue;
		}

		new attackerHealth = GetEntProp(attacker, Prop_Send, "m_iHealth");
		if (IsClientInGame(attacker) && IsPlayerAlive(attacker) && !IsFakeClient(attacker)) {
			new giveHealth = RoundToNearest(attackerHealth + damage);
    		SetEntityHealth(attacker, giveHealth);
		}
	}

    if (g_MonkeySee) {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}
