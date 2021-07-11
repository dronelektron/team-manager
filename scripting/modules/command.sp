public Action Command_MovePlayer(int client, int args) {
    if (args < 2) {
        ReplyToCommand(client, "%s%s", COMMAND_USAGE_PREFIX, COMMAND_DESCRIPTION_MOVE_PLAYER);

        return Plugin_Handled;
    }

    char playerNameArg[COMMAND_ARG_MAX_LENGTH];
    char moveTypeArg[COMMAND_ARG_MAX_LENGTH];

    GetCmdArg(1, playerNameArg, sizeof(playerNameArg));
    GetCmdArg(2, moveTypeArg, sizeof(moveTypeArg));

    int target = FindTarget(client, playerNameArg);
    MovePlayerType moveType = view_as<MovePlayerType>(StringToInt(moveTypeArg));

    if (target > -1) {
        PerformPlayerMovement(client, target, moveType);
    }

    return Plugin_Handled;
}

public Action Command_SwapTeams(int client, int args) {
    PerformTeamsSwapping(client);

    return Plugin_Handled;
}

public Action Command_ScrambleTeams(int client, int args) {
    PerformTeamsScrambling(client);

    return Plugin_Handled;
}

public Action Command_BalanceTeams(int client, int args) {
    if (args < 1) {
        ReplyToCommand(client, "%s%s", COMMAND_USAGE_PREFIX, COMMAND_DESCRIPTION_BALANCE_TEAMS);

        return Plugin_Handled;
    }

    char balanceTypeArg[COMMAND_ARG_MAX_LENGTH];

    GetCmdArg(1, balanceTypeArg, sizeof(balanceTypeArg));

    MoveExcessPlayerType moveType = view_as<MoveExcessPlayerType>(StringToInt(balanceTypeArg));

    if (!PerformTeamsBalancing(client, moveType)) {
        ReplyToCommand(client, "%s%t", PREFIX, "Teams already balanced");
    }

    return Plugin_Handled;
}
