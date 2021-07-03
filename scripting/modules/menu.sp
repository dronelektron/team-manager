TopMenuObject g_teamManagerCategory = INVALID_TOPMENUOBJECT;
TopMenuObject g_menuItemMovePlayer = INVALID_TOPMENUOBJECT;
TopMenuObject g_menuItemSwapTeams = INVALID_TOPMENUOBJECT;
TopMenuObject g_menuItemScrambleTeams = INVALID_TOPMENUOBJECT;
TopMenuObject g_menuItemBalanceTeams = INVALID_TOPMENUOBJECT;

void AddTeamManagerToAdminMenu() {
    g_teamManagerCategory = g_adminMenu.AddCategory(TEAM_MANAGER, TopMenuHandler_TeamManager);

    if (g_teamManagerCategory != INVALID_TOPMENUOBJECT) {
        g_menuItemMovePlayer = g_adminMenu.AddItem(MOVE_PLAYER, TopMenuHandler_TeamManager, g_teamManagerCategory);
        g_menuItemSwapTeams = g_adminMenu.AddItem(SWAP_TEAMS, TopMenuHandler_TeamManager, g_teamManagerCategory);
        g_menuItemScrambleTeams = g_adminMenu.AddItem(SCRAMBLE_TEAMS, TopMenuHandler_TeamManager, g_teamManagerCategory);
        g_menuItemBalanceTeams = g_adminMenu.AddItem(BALANCE_TEAMS, TopMenuHandler_TeamManager, g_teamManagerCategory);
    }
}

public void TopMenuHandler_TeamManager(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength) {
    if (action == TopMenuAction_DisplayOption) {
        if (topobj_id == g_teamManagerCategory) {
            Format(buffer, maxlength, "%T", TEAM_MANAGER, param);
        } else if (topobj_id == g_menuItemMovePlayer) {
            Format(buffer, maxlength, "%T", MOVE_PLAYER, param);
        } else if (topobj_id == g_menuItemSwapTeams) {
            Format(buffer, maxlength, "%T", SWAP_TEAMS, param);
        } else if (topobj_id == g_menuItemScrambleTeams) {
            Format(buffer, maxlength, "%T", SCRAMBLE_TEAMS, param);
        } else if (topobj_id == g_menuItemBalanceTeams) {
            Format(buffer, maxlength, "%T", BALANCE_TEAMS, param);
        }
    } else if (action == TopMenuAction_DisplayTitle) {
        if (topobj_id == g_teamManagerCategory) {
            Format(buffer, maxlength, "%T", TEAM_MANAGER, param);
        }
    } else if (action == TopMenuAction_SelectOption) {
        if (topobj_id == g_menuItemMovePlayer) {
            CreateMovePlayerMenu(param);
        } else if (topobj_id == g_menuItemSwapTeams) {
            if (SwapTeams()) {
                CPrintToChatAll("%t %t", "Prefix", "Teams was swapped");
                LogAction(param, -1, "\"%L\" swapped teams", param);
            }
        } else if (topobj_id == g_menuItemScrambleTeams) {
            if (ScrambleTeams()) {
                CPrintToChatAll("%t %t", "Prefix", "Teams was scrambled");
                LogAction(param, -1, "\"%L\" scrambled teams", param);
            }
        } else if (topobj_id == g_menuItemBalanceTeams) {
            CreateBalanceTeamsMenu(param);
        }
    }
}

void CreateMovePlayerMenu(int client) {
    Menu menu = new Menu(MenuHandler_MovePlayer);

    menu.SetTitle("%T", MOVE_PLAYER, client);

    AddFormattedItem(menu, IMMEDIATELY, client);
    AddFormattedItem(menu, AFTER_DEATH, client);
    AddFormattedItem(menu, AFTER_ROUND_END, client);
    AddFormattedItem(menu, TO_SPECTATORS, client);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_MovePlayer(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        if (StrEqual(info, IMMEDIATELY)) {
            SetMovePlayerType(param1, MovePlayerType_Immediately);
        } else if (StrEqual(info, AFTER_DEATH)) {
            SetMovePlayerType(param1, MovePlayerType_AfterDeath);
        } else if (StrEqual(info, AFTER_ROUND_END)) {
            SetMovePlayerType(param1, MovePlayerType_AfterRoundEnd);
        } else if (StrEqual(info, TO_SPECTATORS)) {
            SetMovePlayerType(param1, MovePlayerType_ToSpectators);
        }

        CreatePlayersMenu(param1);
    } else {
        MenuHandler_Default(menu, action, param1, param2)
    }

    return 0;
}

void CreateBalanceTeamsMenu(int client) {
    Menu menu = new Menu(MenuHandler_BalanceTeams);

    menu.SetTitle("%T", BALANCE_TEAMS, client);

    AddFormattedItem(menu, MOVE_EXCESS_PLAYERS_TO_SPECTATORS, client);
    AddFormattedItem(menu, DISTRIBUTE_EXCESS_PLAYERS, client);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_BalanceTeams(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        bool isExcessPlayersWasMoved = false;

        if (StrEqual(info, MOVE_EXCESS_PLAYERS_TO_SPECTATORS)) {
            isExcessPlayersWasMoved = MoveExcessPlayers(MoveExcessPlayerType_ToSpectators);
        } else if (StrEqual(info, DISTRIBUTE_EXCESS_PLAYERS)) {
            isExcessPlayersWasMoved = MoveExcessPlayers(MoveExcessPlayerType_Distribute);
        }

        if (isExcessPlayersWasMoved) {
            CPrintToChatAll("%t %t", "Prefix", "Teams was balanced");
            LogAction(param1, -1, "\"%L\" balanced teams", param1);
        }
    } else {
        MenuHandler_Default(menu, action, param1, param2)
    }

    return 0;
}

void CreatePlayersMenu(int client) {
    Menu menu = new Menu(MenuHandler_Players);

    menu.SetTitle("%T", SELECT_PLAYER, client);

    AddPlayersToMenu(client, menu);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Players(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[MENU_ITEM_INFO_MAX_SIZE];

        menu.GetItem(param2, info, sizeof(info));

        int userId = StringToInt(info);
        int target = GetClientOfUserId(userId);

        if (target == 0) {
            CPrintToChat(param1, "%t %t", "Prefix", "Player is no longer available");
            LogAction(param1, -1, "\"%L\" tried to move player", param1);

            return 0;
        }

        switch (GetMovePlayerType(param1)) {
            case MovePlayerType_Immediately: {
                if (ChangePlayerTeamToOpposite(target)) {
                    CPrintToChatAll("%t %t", "Prefix", "Player was moved", target, OPPOSING_TEAM);
                    LogAction(param1, target, "\"%L\" moved \"%L\" to %s", param1, target, OPPOSING_TEAM);
                }
            }

            case MovePlayerType_AfterDeath: {
                if (IsMovePlayerFlagEnabled(target, MOVE_PLAYER_FLAG_AFTER_DEATH)) {
                    DisableMovePlayerFlag(target, MOVE_PLAYER_FLAG_AFTER_DEATH);
                    CPrintToChatAll("%t %t", "Prefix", "Player will not be moved", target, AFTER_DEATH);
                    LogAction(param1, target, "\"%L\" disabled flag '%s' on \"%L\"", param1, AFTER_DEATH, target);
                } else {
                    EnableMovePlayerFlag(target, MOVE_PLAYER_FLAG_AFTER_DEATH);
                    CPrintToChatAll("%t %t", "Prefix", "Player will be moved", target, AFTER_DEATH);
                    LogAction(param1, target, "\"%L\" enabled flag '%s' on \"%L\"", param1, AFTER_DEATH, target);
                }
            }

            case MovePlayerType_AfterRoundEnd: {
                if (IsMovePlayerFlagEnabled(target, MOVE_PLAYER_FLAG_ROUND_END)) {
                    DisableMovePlayerFlag(target, MOVE_PLAYER_FLAG_ROUND_END);
                    CPrintToChatAll("%t %t", "Prefix", "Player will not be moved", target, AFTER_ROUND_END);
                    LogAction(param1, target, "\"%L\" disabled flag '%s' on \"%L\"", param1, AFTER_ROUND_END, target);
                } else {
                    EnableMovePlayerFlag(target, MOVE_PLAYER_FLAG_ROUND_END);
                    CPrintToChatAll("%t %t", "Prefix", "Player will be moved", target, AFTER_ROUND_END);
                    LogAction(param1, target, "\"%L\" enabled flag '%s' on \"%L\"", param1, AFTER_ROUND_END, target);
                }
            }

            case MovePlayerType_ToSpectators: {
                if (MovePlayerToSpectators(target)) {
                    CPrintToChatAll("%t %t", "Prefix", "Player was moved", target, SPECTATORS);
                    LogAction(param1, target, "\"%L\" moved \"%L\" to %s", param1, target, SPECTATORS);
                }
            }
        }
    } else if (action == MenuAction_Cancel) {
        if (param2 == MenuCancel_ExitBack) {
            CreateMovePlayerMenu(param1);
        }
    } else {
        MenuHandler_Default(menu, action, param1, param2)
    }

    return 0;
}

void MenuHandler_Default(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_End) {
        delete menu;
    } else if (action == MenuAction_Cancel) {
        if (param2 == MenuCancel_ExitBack && g_adminMenu != null) {
            g_adminMenu.Display(param1, TopMenuPosition_LastCategory);
        }
    }
}

void AddFormattedItem(Menu menu, const char[] phrase, int client) {
    char buffer[TEXT_BUFFER_MAX_SIZE];

    Format(buffer, sizeof(buffer), "%T", phrase, client);

    menu.AddItem(phrase, buffer);
}

void AddPlayersToMenu(int client, Menu menu) {
    ArrayList players = GetPlayers(PlayerPredicate_ActivePlayers);

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);
        int userId = GetClientUserId(player);
        char userIdStr[TEXT_BUFFER_MAX_SIZE];
        char item[TEXT_BUFFER_MAX_SIZE];

        IntToString(userId, userIdStr, sizeof(userIdStr));

        switch (GetMovePlayerType(client)) {
            case MovePlayerType_AfterDeath: {
                bool isMovePlayerAfterDeath = IsMovePlayerFlagEnabled(player, MOVE_PLAYER_FLAG_AFTER_DEATH);

                FormatPlayerItem(item, sizeof(item), player, isMovePlayerAfterDeath);
            }

            case MovePlayerType_AfterRoundEnd: {
                bool isMovePlayerAfterRoundEnd = IsMovePlayerFlagEnabled(player, MOVE_PLAYER_FLAG_ROUND_END);

                FormatPlayerItem(item, sizeof(item), player, isMovePlayerAfterRoundEnd);
            }

            default: {
                Format(item, sizeof(item), MENU_PLAYER_ITEM, player);
            }
        }

        menu.AddItem(userIdStr, item);
    }

    delete players;
}

void FormatPlayerItem(char[] item, int itemMaxLen, int player, bool condition) {
    if (condition) {
        Format(item, itemMaxLen, MENU_PLAYER_ITEM_ENABLED, player);
    } else {
        Format(item, itemMaxLen, MENU_PLAYER_ITEM_DISABLED, player);
    }
}
