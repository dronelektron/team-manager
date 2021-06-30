static int g_playerCaptures[MAXPLAYERS + 1];
static bool g_isMovePlayerAfterDeath[MAXPLAYERS + 1];
static MovePlayerType g_movePlayerType[MAXPLAYERS + 1];

int GetPlayerCaptures(int client) {
    return g_playerCaptures[client];
}

void ResetPlayerCaptures(int client) {
    g_playerCaptures[client] = 0;
}

void IncrementPlayerCaptures(int client) {
    g_playerCaptures[client]++;
}

bool IsMovePlayerAfterDeath(int client) {
    return g_isMovePlayerAfterDeath[client];
}

void SetMovePlayerAfterDeath(int client, bool isMoveAfterDeath) {
    g_isMovePlayerAfterDeath[client] = isMoveAfterDeath;
}

MovePlayerType GetMovePlayerType(int client) {
    return g_movePlayerType[client];
}

void SetMovePlayerType(int client, MovePlayerType type) {
    g_movePlayerType[client] = type;
}

ArrayList GetPlayers(PlayerPredicate predicate) {
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

ArrayList TakeFirstPlayers(ArrayList players, int count) {
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

bool PlayerPredicate_ActivePlayers(int client) {
    int team = GetClientTeam(client);

    return team == TEAM_ALLIES || team == TEAM_AXIS;
}

bool PlayerPredicate_Allies(int client) {
    return GetClientTeam(client) == TEAM_ALLIES;
}

bool PlayerPredicate_Axis(int client) {
    return GetClientTeam(client) == TEAM_AXIS;
}
