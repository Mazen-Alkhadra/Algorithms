// calc_players_points_in_match
function calc_players_points_in_match(match_ApiId, callback4) {
    var players = [];
    var values = [];

    function get_t1t2_players(callback1) {
        connection.query('SELECT  m.IdMatch , ps.RealPlayerId ,p.ApiId, ps.RealTeamId ,ps.Position FROM `match` m \
                          INNER JOIN real_player_in_season ps ON ps.RealTeamId IN (m.Team1Id, m.Team2Id) AND m.ApiId = ?\
                          INNER JOIN real_player p ON p.IdRealPlayer = ps.RealPlayerId', match_ApiId, function (err, body) {
            if (err) {
                console.log('Error in Execution SQL Query for get_t1t2_players:\n ' + err.message);
                return;
            }
            players = body;
            callback1(null, players);
        });
    }

    get_t1t2_players(function () {
        function calc_player_points(callback3) {
            function a(i) {
                // get the current time
                var timeFromEpoch = moment.utc().unix();
                // set the API key
                var apiKey = 'bnn28y8duen622yfek4csd6m';
                // set the shared secret key
                var secret = '5yRHJRp7hV';
                // generate signature
                var sig = crypto.createHash('sha256').update(apiKey + secret + timeFromEpoch).digest('hex');
                request('http://api.stats.com/v1/stats/soccer/epl/stats/players/' + players[i].ApiId + '/events/' + match_ApiId + '/?accept=json&api_key=' + apiKey + '&sig=' + sig,
                    function (err, response, body) {
                        console.log("request for player number : " + i);
                        if (err || (response.statusCode !== 200 && response.statusCode !== 404)) {
                            console.log('Error in Request from Stats API:\n');
                            console.log(body);
                            console.log('Retry..\n');
                            setTimeout(function () {
                                a(i)
                            }, 5000);
                            return;
                        }
                        if (response.statusCode === 404) {
                            console.log('No Results From stats for player: ' + players[i].ApiId + ' in match: ' + match_ApiId + '\n');
                            if (i === 0) {
                                callback3(null, values);
                            }
                            else {
                                setTimeout(function () {
                                    a(i - 1)
                                }, 5000);
                            }
                            return;
                        }
                        var parsedBody = JSON.parse(body);
                        var j = parsedBody.apiResults[0].league.players[0].seasons[0].eventType[0].splits[0].events[0];
                        var goals = j.playerStats.goals.total;
                        var ast = j.playerStats.assists.total;
                        var minuts = j.playerStats.minutesPlayed;
                        var info = j.goaltenderStats;
                        var owng = j.playerStats.goals.ownGoal;
                        var red = j.playerStats.redCards;
                        var offside = j.playerStats.offsides;
                        var corner = j.playerStats.cornerKicks;
                        var yellow = j.playerStats.yellowCards;
                        var clear = j.playerStats.clears;
                        var tackle = j.playerStats.tackles;
                        var foul = j.playerStats.foulsCommitted;
                        var gwg = j.playerStats.goals.gameWinning;
                        var gwa = j.playerStats.assists.gameWinning;
                        var shots = j.playerStats.shots;
                        var csh, ps, saves;
                        if (typeof info == 'undefined') {
                            csh = null;
                            ps = null;
                            saves = null;
                        }
                        else {
                            csh = info.shutouts;
                            ps = info.penaltyKicks.saves;
                            saves = info.saves;
                        }
                        var pm = j.playerStats.penaltyKicks.shots - j.playerStats.penaltyKicks.goals;
                        var point = 0;
                        /*var isInjury = true;

                         function getInjury(callback2) {
                         connection.query('SELECT IdInjury FROM injury WHERE PlayerId =? AND MatchId = ?;', [players[i].RealPlayerId, players[i].IdMatch], function (err, body) {
                         if (err) {
                         console.log('Error in Execution SQL Query for getInjury for player:\n' + err.message);
                         isInjury = false;
                         }
                         else if (body.length == 0)
                         isInjury = false;
                         callback2(null, isInjury);
                         });
                         }*/

                        /* getInjury(function () {
                         if (minuts >= 60 && isInjury == true)
                         point += 2;
                         else if (minuts >= 60 && isInjury == false)
                         point++;*/
                        if (minuts >= 1 && minuts < 60)
                            point++;
                        else if (minuts >= 60)
                            point += 2;
                        if (players[i].Position == 'F')
                            point += (goals * 4);
                        if (players[i].Position == 'M') {
                            point += (goals * 5);
                            if (j.outcome.opponentTeamScore && minuts >= 60 == 0)
                                point++;
                        }
                        if (players[i].Position == 'D' || players[i].Position == 'GK') {
                            point += (goals * 6);
                            if (j.outcome.opponentTeamScore && minuts >= 60 == 0)
                                point += 4;
                            else point -= (j.outcome.opponentTeamScore / 2) | 0;
                        }
                        point += (ast * 3);
                        point -= (pm * 2);
                        point -= (yellow * 1);
                        point -= (owng * 2);
                        point -= (red * 3);
                        if (players[i].Position == 'GK') {
                            point += (saves / 3) | 0;
                            point += (ps * 5);
                        }
                        if (minuts == 0)
                            point = 0;
                        values.push([players[i].RealPlayerId, players[i].IdMatch, point, goals, ast, csh, minuts, ps, pm, owng, yellow, red, offside, corner, clear, tackle, foul, gwg, gwa, shots, saves, players[i].RealTeamId]);
                        if (i === 0) {
                            callback3(null, values);
                        }
                        else setTimeout(function () {
                            a(i - 1)
                        }, 5000);
                    });
                //});
            }

            a(players.length - 1);
        }

        calc_player_points(function () {
            console.log(values);
            connection.query('REPLACE INTO real_player_in_match (RealPlayerId,MatchId,Points,GoalsScored,Assists,CleanSheets,MinutesPlayed,PenaltiesSaved,PenaltiesMissed,OwnGoal,YellowCards,RedCards,Offsides,Corners,Clears,Tackles,Fouls,GameWinningGoal,GameWinningAssist,Shots,Saves, HisTeamId) VALUES ?', [values], function (err, result) {
                if (err) {
                    console.log("Error : replace in Real_Player_in_Match epl" + err.message);
                }
                else {
                    console.log("Success : replace in Real_Player_in_Match epl");
                    callback4();
                }
            });
        });
    });
}