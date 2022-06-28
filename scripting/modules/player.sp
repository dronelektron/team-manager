static int g_playerCaptures[MAXPLAYERS + 1];
static int g_movePlayerFlags[MAXPLAYERS + 1];
static MovePlayerType g_movePlayerType[MAXPLAYERS + 1];

int Player_GetCaptures(int client) {
    return g_playerCaptures[client];
}

void Player_ResetCaptures(int client) {
    g_playerCaptures[client] = 0;
}

void Player_IncrementCaptures(int client) {
    g_playerCaptures[client]++;
}

bool Player_IsMoveFlagEnabled(int client, int flag) {
    return (g_movePlayerFlags[client] & flag) == flag;
}

void Player_ResetMoveFlags(int client) {
    g_movePlayerFlags[client] = 0;
}

void Player_EnableMoveFlag(int client, int flag) {
    g_movePlayerFlags[client] |= flag;
}

void Player_DisableMoveFlag(int client, int flag) {
    g_movePlayerFlags[client] &= ~flag;
}

MovePlayerType Player_GetMoveType(int client) {
    return g_movePlayerType[client];
}

void Player_SetMoveType(int client, MovePlayerType type) {
    g_movePlayerType[client] = type;
}

ArrayList Player_GetAll(PlayerPredicate predicate) {
    ArrayList players = new ArrayList();
    bool predicateResult;

    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i)) {
            continue;
        }

        Call_StartFunction(INVALID_HANDLE, predicate);
        Call_PushCell(i);
        Call_Finish(predicateResult);

        if (predicateResult) {
            players.Push(i);
        }
    }

    return players;
}

ArrayList Player_TakeFirst(ArrayList players, int count) {
    ArrayList result = new ArrayList();

    for (int i = 0; i < count; i++) {
        int player = players.Get(i);

        result.Push(player);
    }

    return result;
}

bool PlayerPredicate_All(int client) {
    return true;
}

bool PlayerPredicate_ActivePlayer(int client) {
    int team = GetClientTeam(client);

    return team == TEAM_ALLIES || team == TEAM_AXIS;
}

bool PlayerPredicate_Allies(int client) {
    return GetClientTeam(client) == TEAM_ALLIES;
}

bool PlayerPredicate_Axis(int client) {
    return GetClientTeam(client) == TEAM_AXIS;
}

bool PlayerPredicate_WithRoundEndFlag(int client) {
    return Player_IsMoveFlagEnabled(client, MOVE_PLAYER_FLAG_ROUND_END);
}
