public Action Command_MovePlayer(int client, int args) {
    if (args < 2) {
        MessageReply_MovePlayerUsage(client);

        return Plugin_Handled;
    }

    char playerNameArg[COMMAND_ARG_MAX_LENGTH];
    char moveTypeArg[COMMAND_ARG_MAX_LENGTH];

    GetCmdArg(1, playerNameArg, sizeof(playerNameArg));
    GetCmdArg(2, moveTypeArg, sizeof(moveTypeArg));

    int target = FindTarget(client, playerNameArg);
    MovePlayerType moveType = view_as<MovePlayerType>(StringToInt(moveTypeArg));

    if (target > -1) {
        UseCase_MovePlayer(client, target, moveType);
    }

    return Plugin_Handled;
}

public Action Command_SwapTeams(int client, int args) {
    UseCase_SwapTeams(client);

    return Plugin_Handled;
}

public Action Command_ScrambleTeams(int client, int args) {
    UseCase_ScrambleTeams(client);

    return Plugin_Handled;
}

public Action Command_BalanceTeams(int client, int args) {
    if (args < 1) {
        MessageReply_BalanceTeamsUsage(client);

        return Plugin_Handled;
    }

    char balanceTypeArg[COMMAND_ARG_MAX_LENGTH];

    GetCmdArg(1, balanceTypeArg, sizeof(balanceTypeArg));

    MoveExcessPlayerType moveType = view_as<MoveExcessPlayerType>(StringToInt(balanceTypeArg));

    UseCase_BalanceTeams(client, moveType);

    return Plugin_Handled;
}
