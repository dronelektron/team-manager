void MessageReply_MovePlayerUsage(int client) {
    ReplyToCommand(client, "%s%s", COMMAND_USAGE_PREFIX, COMMAND_DESCRIPTION_MOVE_PLAYER);
}

void MessageReply_BalanceTeamsUsage(int client) {
    ReplyToCommand(client, "%s%s", COMMAND_USAGE_PREFIX, COMMAND_DESCRIPTION_BALANCE_TEAMS);
}

void Message_PlayerWasMovedToOpposingTeam(int client, int target) {
    ShowActivity2(client, PREFIX, "%t", "Player was moved", target);
    LogAction(client, target, "\"%L\" moved \"%L\" to opposing team", client, target);
}

void Message_PlayerWasMovedToSpectators(int client, int target) {
    ShowActivity2(client, PREFIX, "%t", "Player was moved", target);
    LogAction(client, target, "\"%L\" moved \"%L\" to spectators", client, target);
}

void Message_PlayerWillNotBeMoved(int client, int target, const char[] flag) {
    ShowActivity2(client, PREFIX, "%t", "Player will not be moved", target, flag);
    LogAction(client, target, "\"%L\" disabled flag '%s' on \"%L\"", client, flag, target);
}

void Message_PlayerWillBeMoved(int client, int target, const char[] flag) {
    ShowActivity2(client, PREFIX, "%t", "Player will be moved", target, flag);
    LogAction(client, target, "\"%L\" enabled flag '%s' on \"%L\"", client, flag, target);
}

void Message_TeamsWasSwapped(int client) {
    ShowActivity2(client, PREFIX, "%t", "Teams was swapped");
    LogAction(client, -1, "\"%L\" swapped teams", client);
}

void Message_TeamsWasScrambled(int client) {
    ShowActivity2(client, PREFIX, "%t", "Teams was scrambled");
    LogAction(client, -1, "\"%L\" scrambled teams", client);
}

void Message_TeamsWasBalanced(int client) {
    ShowActivity2(client, PREFIX, "%t", "Teams was balanced");
    LogAction(client, -1, "\"%L\" balanced teams", client);
}

void MessageReply_TeamsAlreadyBalanced(int client) {
    ReplyToCommand(client, "%s%t", PREFIX, "Teams already balanced");
}

void MessagePrint_PlayerIsNoLongerAvailable(int client) {
    PrintToChat(client, "%s%t", PREFIX, "Player is no longer available");
}
