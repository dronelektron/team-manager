void UseCase_MovePlayer(int client, int target, MovePlayerType moveType) {
    switch (moveType) {
        case MovePlayerType_Immediately: {
            if (UseCase_MovePlayerToOppositeTeam(target)) {
                Message_PlayerWasMovedToOpposingTeam(client, target);
            }
        }

        case MovePlayerType_AfterDeath: {
            if (Player_IsMoveFlagEnabled(target, MOVE_PLAYER_FLAG_AFTER_DEATH)) {
                Player_DisableMoveFlag(target, MOVE_PLAYER_FLAG_AFTER_DEATH);
                Message_PlayerWillNotBeMoved(client, target, AFTER_DEATH);
            } else {
                Player_EnableMoveFlag(target, MOVE_PLAYER_FLAG_AFTER_DEATH);
                Message_PlayerWillBeMoved(client, target, AFTER_DEATH);
            }
        }

        case MovePlayerType_AfterRoundEnd: {
            if (Player_IsMoveFlagEnabled(target, MOVE_PLAYER_FLAG_ROUND_END)) {
                Player_DisableMoveFlag(target, MOVE_PLAYER_FLAG_ROUND_END);
                Message_PlayerWillNotBeMoved(client, target, AFTER_ROUND_END);
            } else {
                Player_EnableMoveFlag(target, MOVE_PLAYER_FLAG_ROUND_END);
                Message_PlayerWillBeMoved(client, target, AFTER_ROUND_END);
            }
        }

        case MovePlayerType_ToSpectators: {
            if (UseCase_MovePlayerToSpectators(target)) {
                Message_PlayerWasMovedToSpectators(client, target);
            }
        }
    }
}

void UseCase_MovePlayerToOppositeTeamAfterDeath(int client) {
    if (Player_IsMoveFlagEnabled(client, MOVE_PLAYER_FLAG_AFTER_DEATH)) {
        UseCase_MovePlayerToOppositeTeam(client);
    }
}

void UseCase_MovePlayerToOppositeTeamAfterRoundEnd() {
    ArrayList players = Player_GetAll(PlayerPredicate_WithRoundEndFlag);

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);

        UseCase_MovePlayerToOppositeTeam(player);
    }

    delete players;
}

bool UseCase_MovePlayerToOppositeTeam(int client) {
    int team = GetClientTeam(client);

    if (team == TEAM_ALLIES) {
        ChangeClientTeam(client, TEAM_AXIS);

        return true;
    } else if (team == TEAM_AXIS) {
        ChangeClientTeam(client, TEAM_ALLIES);

        return true;
    }

    return false;
}

bool UseCase_MovePlayersToSpectators(ArrayList players) {
    bool arePlayersMoved = false;

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);

        arePlayersMoved |= UseCase_MovePlayerToSpectators(player);
    }

    return arePlayersMoved;
}

bool UseCase_MovePlayerToSpectators(int client) {
    if (GetClientTeam(client) != TEAM_SPECTATOR) {
        ChangeClientTeam(client, TEAM_SPECTATOR);

        return true;
    }

    return false;
}

void UseCase_SwapTeams(int client) {
    ArrayList players = Player_GetAll(PlayerPredicate_All);
    bool areTeamsSwapped = false;

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);

        areTeamsSwapped |= UseCase_MovePlayerToOppositeTeam(player);
    }

    delete players;

    if (areTeamsSwapped) {
        Message_TeamsWasSwapped(client);
    }
}

void UseCase_ScrambleTeams(int client) {
    ArrayList players = Player_GetAll(PlayerPredicate_ActivePlayer);
    // Fisher-Yates shuffle
    for (int i = players.Length - 1; i > 0; i--) {
        int j = GetRandomInt(0, i);

        players.SwapAt(i, j);
    }

    bool areTeamsScrambled = UseCase_AssignTeams(players);

    delete players;

    if (areTeamsScrambled) {
        Message_TeamsWasScrambled(client);
    }
}

void UseCase_BalanceTeams(int client, MoveExcessPlayerType moveType) {
    bool isExcessPlayersWasMoved = UseCase_MoveExcessPlayers(moveType);

    if (isExcessPlayersWasMoved) {
        Message_TeamsWasBalanced(client);
    } else {
        MessageReply_TeamsAlreadyBalanced(client);
    }
}

bool UseCase_AssignTeams(ArrayList players) {
    int priorityTeam = GetRandomInt(TEAM_ALLIES, TEAM_AXIS);
    bool areTeamsAssigned = false;

    for (int i = 0; i < players.Length; i++) {
        int player = players.Get(i);
        int team = priorityTeam;

        if (priorityTeam == TEAM_ALLIES) {
            team += i % 2;
        } else {
            team -= i % 2;
        }

        int oldTeam = GetClientTeam(player);

        areTeamsAssigned |= (oldTeam != team);

        ChangeClientTeam(player, team);
    }

    return areTeamsAssigned;
}

bool UseCase_MoveExcessPlayers(MoveExcessPlayerType type) {
    ArrayList allies = Player_GetAll(PlayerPredicate_Allies);
    ArrayList axis = Player_GetAll(PlayerPredicate_Axis);
    int diff = allies.Length - axis.Length;
    int playersCount = diff < 0 ? -diff : diff;
    ArrayList excessPlayers = null;
    bool result = false;

    if (diff > UNBALANCE_LIMIT) {
        allies.SortCustom(SortFunc_ByLowestRank);
        excessPlayers = Player_TakeFirst(allies, playersCount);
    } else if (diff < -UNBALANCE_LIMIT) {
        axis.SortCustom(SortFunc_ByLowestRank);
        excessPlayers = Player_TakeFirst(axis, playersCount);
    }

    if (excessPlayers != null) {
        switch (type) {
            case MoveExcessPlayerType_ToSpectators: {
                UseCase_MovePlayersToSpectators(excessPlayers);
            }

            case MoveExcessPlayerType_Distribute: {
                UseCase_AssignTeams(excessPlayers);
            }
        }

        delete excessPlayers;

        result = true;
    }

    delete axis;
    delete allies;

    return result;
}

void UseCase_PointCaptured(const char[] cappers) {
    for (int i = 0; i < strlen(cappers); i++) {
        int player = cappers[i];

        Player_IncrementCaptures(player);
    }
}

int SortFunc_ByLowestRank(int index1, int index2, Handle array, Handle hndl) {
    ArrayList players = view_as<ArrayList>(array);
    int player1 = players.Get(index1);
    int player2 = players.Get(index2);
    int captures1 = Player_GetCaptures(player1);
    int captures2 = Player_GetCaptures(player2);

    if (captures1 != captures2) {
        return captures1 - captures2;
    }

    int frags1 = GetClientFrags(player1);
    int frags2 = GetClientFrags(player2);

    if (frags1 != frags2) {
        return frags1 - frags2;
    }

    int deaths1 = GetClientDeaths(player1);
    int deaths2 = GetClientDeaths(player2);

    return deaths2 - deaths1;
}
