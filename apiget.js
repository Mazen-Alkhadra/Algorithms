//Get Requests 
module.exports = function (app, passport) {
    var connection = require('../db/connect');
    // Get all competitions
    app.get('/compets', function (req, res) {
        if(!passport.chekAuthority(req, res, 'compets')) {
            return;
        }
        var queryString = "SELECT * FROM competition WHERE Type = 'm' AND Available = true;"
        connection.query(queryString, function (err, rows) {
            if (err) {
                console.log('Error in Execution SQL Query for get all competitions:\n ' + err.message);
                return;
            }
            res.json(rows);
        });
    });
    // Get all competitions in a particular league, Parameters: league, path: /compets/spanish   
    app.get('/compets/:league', function (req, res) { // must pass Real League Id.
        if(!passport.chekAuthority(req, res, 'compets')) {
            return;
        }
        var queryString = "SELECT @lid:=IdRealLeague FROM Real_League WHERE LeagueName = ?;";
        queryString += "SELECT * FROM competition WHERE Available = true AND Type = 'm' AND SeasonId IN (SELECT IdSeason FROM Season WHERE RealLeagueId = @lid);"
        queryString += "SET @lid = NULL;";
        connection.query(queryString, [req.params.league], function (err, rows) {
            if (err) {
                console.log('Error in Execution SQL Query for get all competitions in a particular league:\n ' + err.message);
                return;
            }
            res.json(rows[1]);
        });
    });
    // Get all mini leagues in a particular league, Parameters: league, path: /mini?league=spanish
    app.get('/mini', function (req, res) {  // must pass Real League Id and competition type.
        if(!passport.chekAuthority(req, res, 'mini')) {
            return;
        }
        var queryString = "SELECT @lid:=IdRealLeague FROM Real_League WHERE LeagueName = ?;";
        queryString += "SELECT * FROM competition WHERE Available = true AND Type !='m' AND SeasonId IN (SELECT IdSeason FROM Season WHERE RealLeagueId = @lid);"
        queryString += "SET @lid = NULL;";
        connection.query(queryString, [req.query['league']], function (err, rows) {
            if (err) {
                console.log('Error in Execution SQL Query for Get all mini leagues in a particular league:\n ' + err.message);
                return;
            }
            res.json(rows[1]);
        });
    });
    //Get All Players, path:/players/sid.
    app.get('/players/:sid', function (req, res) { 
        if(!passport.chekAuthority(req, res, 'players')) {
            return;
        }
        var queryString = "SELECT idRealPlayer, firstName, lastName, photo, position, teamName team, \
            (SELECT price FROM real_player_in_gameweek rpiw WHERE IdRealPlayer = rpiw.RealPlayerId AND GameWeekId = (SELECT max(IdGameWeek) FROM game_week WHERE SeasonId = ? AND StartDate < current_timestamp())) price\
            FROM real_player rp INNER JOIN real_player_In_Season rpis ON rp.IdRealPlayer = rpis.RealPlayerId AND SeasonId = ? \
            INNER JOIN Real_Team ON RealTeamId = IdRealTeam;";
        connection.query(queryString, [req.params.sid, req.params.sid], function (err, rows) {
            if (err) {
                console.log('Error in Execution SQL Query for get All Players:\n ' + err.message);
                return;
            }
            res.json(rows);
           });  
    });
    // Get players selected by user to be in his squad given team id, Parameters: team id, path: /sqplayers?game=id . note: gameId is equivelent to teamId in db.
    app.get('/sqplayers', function (req, res) {  
        if(!passport.chekAuthority(req, res, 'players')) {
            return;
        }
        var queryString = "SELECT IdUserPlayer, user_player.RealPlayerId, UserTeamId, FirstName, LastName, BirthDate, Nationality, Real_player.photo, user_player.position,real_player_In_Season.position as realPosition, CaptainOrVice\
                           FROM User_player INNER JOIN Real_player on User_player.RealPlayerId = Real_player.IdRealPlayer AND UserTeamId = ? INNER JOIN real_player_In_Season on real_player_In_Season.RealPlayerId=user_player.RealPlayerId INNER JOIN user_team ON user_team.IdUserTeam=UserTeamId AND user_team.UserId=?";
        connection.query(queryString, [req.query['game'], req.user.IdUser], function (err, rows) {
            if (err) {
                console.log('Error in Execution SQL Query for Get players selected by user to be in his squad:\n ' + err.message);
                return;
            }
            res.json(rows);
        });
    });
    //Get player details, history, and fixtures, parameters: Player id, path: /playerdetails/seasonId/playerId
    app.get('/playerdetails/:sid/:pid', function (req, res) {    
        if(!passport.chekAuthority(req, res, 'players')) {
            return;
        }
        var queryString = "call prcPlayerDetHisFix (?, ?)";
        connection.query(queryString, [req.params.sid, req.params.pid], function (err, rows) {
          if (err) {
                console.log('Error in Execution SQL Query for get Player details:\n ' + err.message);
                return;
            }
            var format = require('./players');
            res.json(format(rows[0],rows[1]));
        });
    });
    // Get Details of Points gained by a player in specific match, parameters: match id - Player id , path: /ppdim/:mid/:pid
    app.get('/ppdim/:mid/:pid', function (req, res) {    
        if(!passport.chekAuthority(req, res, 'players')) {
            return;
        }
        var queryString = "SELECT GoalsScored, Assists, CleanSheets, MinutesPlayed, PenaltiesSaved, PenaltiesMissed, OwnGoal, YellowCards, RedCards, Saves, MinutesPlayedPoints, GoalsScoredPoints, CleanSheetsPoints, AssistPoints, PenaltiesMissedPoints, YellowCardsPoints, RedCardsPoints, OwnGoalsPoints, PenaltiesSavedPoints, SavesPoints, ConcededPoints, Points\
                           FROM real_player_in_match WHERE RealPlayerId = ? AND MatchId = ?;";
        connection.query(queryString, [req.params.pid, req.params.mid], function (err, rows) {
          if (err) {
                console.log('Error in Execution SQL Query for get Details of Points gained by a player in specific match:\n ' + err.message);
                return;
            }
            res.json(rows);
        });
    });
    // Chack if Logged In
    app.get('/checklogin', function(req, res,next) {
        if(req.isAuthenticated())
            res.end('1');
        else
            res.end('0');
    });
    // Logging out
    app.get('/logout', function(req, res) {
            if(req.user)
                delete passport.cachUsers[req.user.IdUser];
            req.logOut();
            res.end('Success');
    });

    //anything else
    app.get('/*', function (req, res) { res.end("Fantasy Socerr Game: invalid request") });
}