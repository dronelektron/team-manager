void PerformPlayerMovement(int client, int target, MovePlayerType moveType) {
    switch (moveType) {
        case MovePlayerType_Immediately: {
            if (ChangePlayerTeamToOpposite(target)) {
                ShowActivity2(client, PREFIX, "%t", "Player was moved", target);
                LogAction(client, target, "\"%L\" moved \"%L\" to opposing team", client, target);
            }
        }

        case MovePlayerType_AfterDeath: {
            if (IsMovePlayerFlagEnabled(target, MOVE_PLAYER_FLAG_AFTER_DEATH)) {
                DisableMovePlayerFlag(target, MOVE_PLAYER_FLAG_AFTER_DEATH);
                ShowActivity2(client, PREFIX, "%t", "Player will not be moved", target, AFTER_DEATH);
                LogAction(client, target, "\"%L\" disabled flag '%s' on \"%L\"", client, AFTER_DEATH, target);
            } else {
                EnableMovePlayerFlag(target, MOVE_PLAYER_FLAG_AFTER_DEATH);
                ShowActivity2(client, PREFIX, "%t", "Player will be moved", target, AFTER_DEATH);
                LogAction(client, target, "\"%L\" enabled flag '%s' on \"%L\"", client, AFTER_DEATH, target);
            }
        }

        case MovePlayerType_AfterRoundEnd: {
            if (IsMovePlayerFlagEnabled(target, MOVE_PLAYER_FLAG_ROUND_END)) {
                DisableMovePlayerFlag(target, MOVE_PLAYER_FLAG_ROUND_END);
                ShowActivity2(client, PREFIX, "%t", "Player will not be moved", target, AFTER_ROUND_END);
                LogAction(client, target, "\"%L\" disabled flag '%s' on \"%L\"", client, AFTER_ROUND_END, target);
            } else {
                EnableMovePlayerFlag(target, MOVE_PLAYER_FLAG_ROUND_END);
                ShowActivity2(client, PREFIX, "%t", "Player will be moved", target, AFTER_ROUND_END);
                LogAction(client, target, "\"%L\" enabled flag '%s' on \"%L\"", client, AFTER_ROUND_END, target);
            }
        }

        case MovePlayerType_ToSpectators: {
            if (MovePlayerToSpectators(target)) {
                ShowActivity2(client, PREFIX, "%t", "Player was moved", target);
                LogAction(client, target, "\"%L\" moved \"%L\" to spectators", client, target);
            }
        }
    }
}

void PerformTeamsSwapping(int client) {
    bool isTeamsSwapped = SwapTeams();

    if (isTeamsSwapped) {
        ShowActivity2(client, PREFIX, "%t", "Teams was swapped");
        LogAction(client, -1, "\"%L\" swapped teams", client);
    }
}

void PerformTeamsScrambling(int client) {
    bool isTeamsScrambled = ScrambleTeams();

    if (isTeamsScrambled) {
        ShowActivity2(client, PREFIX, "%t", "Teams was scrambled");
        LogAction(client, -1, "\"%L\" scrambled teams", client);
    }
}

bool PerformTeamsBalancing(int client, MoveExcessPlayerType moveType) {
    bool isExcessPlayersWasMoved = MoveExcessPlayers(moveType);

    if (isExcessPlayersWasMoved) {
        ShowActivity2(client, PREFIX, "%t", "Teams was balanced");
        LogAction(client, -1, "\"%L\" balanced teams", client);
    }

    return isExcessPlayersWasMoved;
}
