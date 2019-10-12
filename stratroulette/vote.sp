public Action:VoteTimer(Handle timer) {
	CreateRoundVoteMenu();
	voteTimer = INVALID_HANDLE;
}

public CreateRoundVoteMenu() {
	Menu menu = new Menu(VoteMenuHandler, MENU_ACTIONS_ALL);
	menu.SetTitle("RoundVoteTitle");

	ArrayList options = GetEnabledStrats();

	for (int i = 1; i < 6; i++) {
		if (options.Length == 0) {
			break;
		}

		int randomRound = options.Get(GetRandomInt(0, options.Length - 1));

		options.Erase(options.FindValue(randomRound));

		char randomRoundString[16];
		IntToString(randomRound, randomRoundString, sizeof(randomRoundString));

		KeyValues kv = new KeyValues("Strats");
		kv.ImportFromFile(STRAT_FILE);

		if (!kv.JumpToKey(randomRoundString)) {
			PrintToServer("Strat number %s could not be found for voting!", randomRoundString);

			delete kv;
			continue;
		}

		char roundName[256];
		kv.GetString("name", roundName, sizeof(roundName), "No name round!");
		Colorize(roundName, sizeof(roundName), true);

		menu.AddItem(randomRoundString, roundName);

		delete kv;
	}

	menu.ExitButton = false;

	menu.DisplayVoteToAll(20);
}

public int VoteMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_VoteEnd) {
		char winningRound[32];
		char winningRoundName[256];
		int style;
		menu.GetItem(param1, winningRound, sizeof(winningRound), style, winningRoundName, sizeof(winningRoundName));

		Format(voteRoundNumber, sizeof(voteRoundNumber), winningRound);
		nextRoundVoted = true;

		for (new i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && !IsFakeClient(i)) {
				char translatedRoundName[128];
				Format(translatedRoundName, sizeof(translatedRoundName), "%T", winningRoundName, i);
				SendMessage(i, "%t", "RoundVotingFinished", translatedRoundName);
			}
		}
	}

	if (action == MenuAction_DisplayItem) {
		/* Get the display string, we'll use it as a translation phrase */
		char display[64];
		menu.GetItem(param2, "", 0, _, display, sizeof(display));

		/* Translate the string to the client's language */
		char buffer[255];
		Format(buffer, sizeof(buffer), "%T", display, param1);

		/* Override the text */
		return RedrawMenuItem(buffer);
	}

	if (action == MenuAction_Display) {
		/* Panel Handle is the second parameter */
		Panel panel = view_as<Panel>(param2);

		/* Translate to our phrase */
		char buffer[255];
		Format(buffer, sizeof(buffer), "%T", "RoundVoteTitle", param1);

		panel.SetTitle(buffer);
	}

	if (action == MenuAction_End) {
		delete menu;
	}

	return 0;
}
