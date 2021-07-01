public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);

    if (IsMovePlayerFlagEnabled(client, MOVE_PLAYER_FLAG_AFTER_DEATH)) {
        ResetMovePlayerFlags(client);
        ChangePlayerTeamToOpposite(client);
    }
}

public Action Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);

    ResetMovePlayerFlags(client);

    return Plugin_Handled;
}

public void Event_PointCaptured(Event event, const char[] name, bool dontBroadcast) {
    char cappers[EVENT_STRING_MAX_SIZE];

    event.GetString("cappers", cappers, sizeof(cappers));

    for (int i = 0; i < strlen(cappers); i++) {
        int player = cappers[i];

        IncrementPlayerCaptures(player);
    }
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
    ArrayList players = GetPlayers(PlayerPredicate_WithRoundEndFlag);

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);

        ResetMovePlayerFlags(player);
        ChangePlayerTeamToOpposite(player);
    }

    delete players;
}
