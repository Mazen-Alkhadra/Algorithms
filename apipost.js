//Post Requests
module.exports = function (app, passport) {
    var connection = require('../db/connect');
    
    // Create a mini league, post data: name and league, path: /mini/create?league=&name=
    app.post('/mini/create', function (req, res) { // must pass season id, Fee, Type, StartGameWeekNumber.     
        if(!passport.chekAuthority(req, res, 'mini')) {
            return;
        }
        var league = req.body.league || req.query.league;
        var name = req.body.name || req.query.name;
        var queryString = "set @@session.time_zone = '+00:00';";
        queryString+="select @lid:=IdRealLeague from Real_League where LeagueName = ?;";
        queryString += "INSERT INTO competition(Name, Fee, Type, Code, SeasonId, StartGameWeekNumber, AdminUserId, Available, CreationDate ) Values (?";
        queryString += ", 0, 'i', null, (select @season:=max(IdSeason) from Season where RealLeagueId = @lid),coalesce((select max(Number) from Game_Week where SeasonId = @season AND StartDate < current_timestamp()), 1), ?, true, current_timestamp());";
        queryString += "SET @lid = NULL;SET @season = NULL;";
        connection.query(queryString, [league, name, req.user.IdUser], function (err, rows) {
            if (err) {
                console.log('Error in Execution SQL Query for create mini league:\n ' + err.message);
                res.status(404);
                res.end('Creation Failed');
                return;
            }
            res.json(rows[1]);
        });
    });

    // Add player to team, post data: player id and game id, path: /addgplayer?game=&player=&position=
    app.post('/addgplayer', function (req, res) {// must pass CaptainOrVice
        if(!passport.chekAuthority(req, res, 'players')) {
            return;
        }
        var game = req.body.game || req.query.game;
        var player = req.body.player || req.query.player;
        var position = req.body.position || req.query.position;
        var queryString = "INSERT INTO User_Player(UserTeamId, RealPlayerId, Position) Values((SELECT IdUserTeam FROM user_team WHERE Valid = 1 AND IdUserTeam = ? AND UserId = ? ), ?, ?)";
        connection.query(queryString, [game, req.user.IdUser, player, position], function (err, rows) {
            if (err) {
                console.log('Error in Execution SQL Query for add player to a team:\n ' + err.message);
                res.status(404);
                res.end('Adding operation Failed');
                return;
            }
            res.json(rows);
        });
    });
    // Remove player from user team, post data: player id and game id, path: /removegplayer
    app.post('/removegplayer', function (req, res) {
        if(!passport.chekAuthority(req, res, 'players')) {
            return;
        }
        var game = req.body.game || req.query.game;
        var player = req.body.player || req.query.player;
        var queryString = "DELETE FROM User_Player WHERE UserTeamId = ? AND RealPlayerId = ? AND (SELECT UserId FROM user_team WHERE IdUserTeam = ? AND Valid = 1) = ?";
        connection.query(queryString,[game, player, game, req.user.IdUser], function (err, rows) {
            if (err) {
                console.log('Error in Execution SQL Query for Remove player from user team:\n ' + err.message);
                res.status(404);
                res.end('Deleting operation Failed');
                return;
            }
            res.json(rows);
        });
    });
    //Update a user to have joined a Competition or mini league, params: Competition id, path: /joingame?game= 
    app.post('/joingame', function (req, res) {  // must pass game week id or season id, photo
        if(!passport.chekAuthority(req, res, 'game')) {
            return;
        }
        var game = req.body.game || req.query.game;
        var user = req.user.IdUser;
        var queryString = "INSERT INTO user_team(Name, CompetitionId, userId, Valid, GameWeekId) Values('', ?,?, 1,";
        queryString += "(select max(IdGameWeek) from game_week  WHERE StartDate < current_timestamp())) ON DUPLICATE KEY UPDATE Valid = VALUES(Valid);SELECT IdUserTeam,Budget FROM user_team WHERE CompetitionId=? AND userId=? AND Valid = 1;"
        connection.query(queryString,[game, user, game, user], function (err, rows) {
            if (err) {
                console.log('Error in Execution SQL Query create mini league:\n ' + err.message);
                res.status(404);
                res.end('Join Failed');
                return;
            }
            res.json(rows);
        });
    });

    app.post('/login', function (req, res) {
        passport.authenticate('logIn', {/*successRedirect: '/players/0', failureRedirect: '/players/0'*/}, 
            function(err, user, info) {
                 res.status(401);
                if(user) {
                    req.logIn(user, function(err){
                        if(err){
                            return res.end(err.message);       
                        }
                    res.status(200);    
                    });
                }
                res.end(info.message);
            })(req, res);
        });

    app.post('/signup', function(req, res) {
        var body = req.body;
        connection.query('SELECT Email, UserName FROM user WHERE Email = ? OR UserName = ? ', [body.email, body.userName], function(err, rows){
            if(err) {
                console.log('Error in Execution SQL Query for check duplication in username and email :\n ' + err.message);
                res.end('Failed');
                return;
            }
            if(rows.length !== 0) {
            if(rows[0].Email === body.email)
               res.end('Email address already exists');
            else   
               res.end('Username already exists');
            return;
            } 
            var queryString = 'INSERT INTO User(FirstName, LastName, Country, Gender, BirthDate, UserName, Email, Password, FavClub, Photo, EmailNotification) VALUES (?);';
            queryString += 'INSERT INTO privileges(USerId) SELECT max(IdUser) FROM User;';
            connection.query(queryString,
                [[body.firstName, body.lastName, body.country, body.gender[0], body.birthdate, body.userName, body.email, body.password, body.favClub, body.photo, body.emailNotification[0]]],
                function(err, rows) {
                    if(err){
                        console.log('Error in Execution SQL Query for signup a user:\n ' + err.message);
                        res.end('Failed');
                        return;
                    }
                    res.end('Success');            
                });
          });            
    });
}