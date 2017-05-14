CREATE SCHEMA IF NOT EXISTS `fantasy_soccer_game` DEFAULT CHARACTER SET utf8 ;
USE `fantasy_soccer_game` ;

-- -----------------------------------------------------
-- Table `Admin`  Admins of soccer game system
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`admin` (
  `IdAdmin` INT(20) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `FirstName` NVARCHAR(50) NOT NULL ,
  `LastName` NVARCHAR(50) NOT NULL ,
  `Country` NVARCHAR(50) NOT NULL ,
  `Gender` CHAR(1) NOT NULL ,
  `BirthDate` DATE NOT NULL ,
  `UserName` NVARCHAR(50) NOT NULL ,
  `Email` VARCHAR(100) NOT NULL ,
  `Password` NVARCHAR(50) NOT NULL ,
  `Photo` VARCHAR(200) NULL DEFAULT NULL ,
  PRIMARY KEY (`IdAdmin`) ,
  UNIQUE INDEX `UserName` (`UserName` ASC) ,
  UNIQUE INDEX `Email` (`Email` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;
-- -----------------------------------------------------
-- Table `User`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`user` (
  `IdUser` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `FirstName` NVARCHAR(50) NOT NULL ,
  `LastName` NVARCHAR(50) NOT NULL ,
  `Country` NVARCHAR(50) NOT NULL ,
  `Gender` CHAR(1) NOT NULL ,
  `BirthDate` DATE NOT NULL ,
  `UserName` NVARCHAR(50) NOT NULL ,
  `Email` VARCHAR(100) NOT NULL ,
  `Password` NVARCHAR(50) NOT NULL ,
  `FavClub` NVARCHAR(50) NOT NULL ,
  `Photo` VARCHAR(200) NULL DEFAULT NULL ,
  `EmailNotification` CHAR(1) NOT NULL ,
  `TotalPoints` DOUBLE NOT NULL DEFAULT 0 ,
  `TotalCoins` DOUBLE UNSIGNED NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`IdUser`) ,
  UNIQUE INDEX `UserName` (`UserName` ASC) ,
  UNIQUE INDEX `Email` (`Email` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `RealLeague` English , Spanish etc..
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`real_league` (
  `IdRealLeague` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `ApiId` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `LeagueName` NVARCHAR(50) NOT NULL ,
  `LeaguePhoto` VARCHAR(200) NULL DEFAULT NULL ,
  `NumberOfTeams` INT(5) UNSIGNED NOT NULL DEFAULT 20 ,
  `LeagueNameAbb` NVARCHAR(10) NOT NULL , --  League Name Abbreviation
  PRIMARY KEY (`IdRealLeague`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table `Season`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`season` (
  `IdSeason` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `StartDate` DATE NULL DEFAULT NULL ,
  `EndDate` DATE NULL DEFAULT NULL ,
  `RealLeagueId` INT(10) UNSIGNED NOT NULL ,
  PRIMARY KEY (`IdSeason`) ,
  CONSTRAINT `FK_Season_RealLeague`
    FOREIGN KEY (`RealLeagueId` )
    REFERENCES `fantasy_soccer_game`.`real_league` (`IdRealLeague` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
    )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;
CREATE INDEX `INDX_Season_RealLeague` ON `Season` (`RealLeagueId` ASC) ;
-- -----------------------------------------------------
-- Table `GameWeek`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`game_week` (
  `IdGameWeek` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `StartDate` DATETIME NOT NULL ,
  `EndDate` DATETIME NULL DEFAULT NULL ,
  `SeasonId` INT(10) UNSIGNED NOT NULL ,
  `Number` INT(2) UNSIGNED NOT NULL , -- 0 - 38
  PRIMARY KEY (`IdGameWeek`) ,
  CONSTRAINT `FK_GameWeek_Season`
    FOREIGN KEY (`SeasonId`)
    REFERENCES `fantasy_soccer_game`.`season` (`IdSeason` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
    )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_GameWeek_Season` ON `Game_Week` (`SeasonID` ASC) ;


-- --------------------------------------------------------------------------------------
-- Table `Competition` platform competitions + private mini-leagues + public mini-leagues.
-- --------------------------------------------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`competition` (
  `IdCompetition` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `Name` NVARCHAR(50) NOT NULL ,
  `Fee` DOUBLE UNSIGNED NULL DEFAULT 0 ,
  `Type` CHAR(1) NOT NULL , -- Type:'b' for public, 'i' for private,'m' for platform's competitions 
  `Code` VARCHAR(50) NULL DEFAULT NULL , -- for private mini-league
  `SeasonId` INT(10) UNSIGNED NOT NULL ,
  `StartGameWeekNumber` INT(2) UNSIGNED NOT NULL , -- Scoring Start Week Number .
  `AdminUserId` BIGINT(20) UNSIGNED NULL DEFAULT NULL , -- for private mini-leagues
  `Available`   BOOL NOT NULL DEFAULT true,
  `CreationDate` DATETIME NOT NULL ,
  PRIMARY KEY (`IdCompetition`) ,
  UNIQUE INDEX `Code` (`Code` ASC) ,
  CONSTRAINT `FK_Competition_Admin`
    FOREIGN KEY (`AdminUserId` )
    REFERENCES `fantasy_soccer_game`.`user` (`IdUser` )
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `FK_Competition_Season`
    FOREIGN KEY (`SeasonId` )
    REFERENCES `fantasy_soccer_game`.`season` (`IdSeason` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `Check_Competition_Type` check(Type in ('b','i','m'))
    )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


CREATE INDEX `INDX_Competition_Admin` ON `Competition` (`AdminUserId` ASC) ;

CREATE INDEX `INDX_Competition_Season` ON `Competition` (`SeasonId` ASC) ;

-- -----------------------------------------------------
-- Table `Prizes Store`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`prizes_store` (
  `IdPrize` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `Name` NVARCHAR(50) NOT NULL ,
  `Photo` VARCHAR(200) NULL DEFAULT NULL ,
  `Price` DOUBLE UNSIGNED NOT NULL , -- in coins
  `Comment` NVARCHAR(300) NULL DEFAULT NULL ,
  PRIMARY KEY (`IdPrize`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- -------------------------------------------------------------------------------------------
-- Table `Competition_Prizes` prizes set for a competition  : form prizes store or pot or coins .
-- -------------------------------------------------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`competition_prizes` (
  `CompetitionId` BIGINT(20) UNSIGNED NOT NULL ,
  `WinnerPlace` INT(3) UNSIGNED NOT NULL , -- 1st place, seconde place ..
  `PrizeId` INT(10) UNSIGNED NULL DEFAULT NULL , --  NULL means the prize is not from the Prizes Store.
  `PotDiscount` DOUBLE NULL DEFAULT NULL , -- NULL means the prize is not Pot , 0 mean the prize is the pot and no discount . 
  `Coins` DOUBLE UNSIGNED NULL DEFAULT NULL , --  NULL means the prize is not Coins .
   CONSTRAINT `FK_CompetitionPrizes_Competition`
    FOREIGN KEY (`CompetitionId` )
    REFERENCES `fantasy_soccer_game`.`competition` (`IdCompetition` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_CompetitionPrizes_Prizes`
    FOREIGN KEY (`PrizeId` )
    REFERENCES `fantasy_soccer_game`.`prizes_store` (`IdPrize` )
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_CompetitionPrizes_Competition` ON `Competition_Prizes` (`CompetitionId` ASC) ;
CREATE INDEX `CompetitionPrizes_Prizes` ON `Competition_Prizes` (`PrizeId` ASC) ;

-- -----------------------------------------------------
-- Table `RealTeam` 
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`real_team` (
  `IdRealTeam` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `TeamName` NVARCHAR(50) NOT NULL ,
  `TeamPhoto` VARCHAR(200) NULL DEFAULT NULL ,
  `Home` NVARCHAR(50) NOT NULL , -- Team's city 
  `ApiId` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `TeamNameAbb` NVARCHAR(10) NOT NULL , --  Team Name Abbreviation
  PRIMARY KEY (`IdRealTeam`) )
ENGINE = InnoDB
-- AUTO_INCREMENT = 41
DEFAULT CHARACTER SET = utf8;

-- -----------------------------------------------------
-- Table `RealPlayer` 
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`real_player` (
  `IdRealPlayer` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `FirstName` NVARCHAR(50) NULL DEFAULT NULL ,
  `LastName` NVARCHAR(50) NOT NULL ,
  `DisplayName` NVARCHAR(50) NOT NULL ,
  `BirthDate` DATE NULL DEFAULT NULL ,
  `Nationality` NVARCHAR(50) NULL DEFAULT NULL ,
  `Photo` VARCHAR(200) NULL DEFAULT NULL ,
  `ApiId` INT(10) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`IdRealPlayer`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;
-- -----------------------------------------------------
-- Table `Match` Real Match
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`match` (
  `IdMatch` INT(20) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `StartDate` DATETIME NOT NULL ,
  `ApiId` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `Team1Score` INT(2) UNSIGNED NULL DEFAULT NULL ,
  `Team2Score` INT(2) UNSIGNED NULL DEFAULT NULL ,
  `GameWeekId` INT(10) UNSIGNED NOT NULL ,
  `Team1Id` INT(10) UNSIGNED NOT NULL , -- Real Team 
  `Team2Id` INT(10) UNSIGNED NOT NULL , -- Real Team 
  `Place` NVARCHAR(100) NOT NULL , -- city or country the match will be played
  `Team1Coach` NVARCHAR(50) NULL DEFAULT NULL ,
  `Team2Coach` NVARCHAR(50) NULL DEFAULT NULL ,
  PRIMARY KEY (`IdMatch`) ,
  CONSTRAINT `FK_Match_GameWeek`
    FOREIGN KEY (`GameWeekId` )
    REFERENCES `fantasy_soccer_game`.`game_week` (`IdGameWeek` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_Match_RealTeam1`
    FOREIGN KEY (`Team1Id` )
    REFERENCES `fantasy_soccer_game`.`real_team` (`IdRealTeam` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_Match_RealTeam2`
    FOREIGN KEY (`Team2Id` )
    REFERENCES `fantasy_soccer_game`.`real_team` (`IdRealTeam` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_Match_GameWeek` ON `Match` (`GameWeekId` ASC) ;

CREATE INDEX `INDX_Match_RealTeam1` ON `Match` (`Team1Id` ASC) ;

CREATE INDEX `INDX_Match_RealTeam2` ON `Match` (`Team2Id` ASC) ;
-- -----------------------------------------------------
-- Table `Real_Team_In_RealLeague`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`real_team_in_realleague` (
  `RealTeamId` INT(10) UNSIGNED NOT NULL ,
  `RealLeagueId` INT(10) UNSIGNED NOT NULL ,
  `Rank` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `Wins` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `Ties` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `Losses` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `GoalsScored` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `GoalsConceded` INT(10) UNSIGNED NULL DEFAULT NULL ,
  `TeamPoints` DOUBLE NULL DEFAULT NULL ,
  PRIMARY KEY (`RealLeagueId`, `RealTeamId`) ,
  CONSTRAINT `FK_RealTeamInRealLeague_RealLeague`
    FOREIGN KEY (`RealLeagueId` )
    REFERENCES `fantasy_soccer_game`.`real_league` (`IdRealLeague` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_RealTeamInRealLeague_RealTeam`
    FOREIGN KEY (`RealTeamId` )
    REFERENCES `fantasy_soccer_game`.`real_team` (`IdRealTeam` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_RealTeamInRealLeague_RealLeague` ON `Real_Team_In_RealLeague` (`RealLeagueId` ASC) ;

CREATE INDEX `INDX_RealTeamInRealLeague_RealTeam` ON `Real_Team_In_RealLeague` (`RealTeamId` ASC) ;

-- -----------------------------------------------------
-- Table `Real_Team_In_Season`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`real_team_in_season` (
  `RealTeamId` INT(10) UNSIGNED NOT NULL ,
  `SeasonId` INT(10) UNSIGNED NOT NULL ,
  `Rank` INT(10) UNSIGNED NOT NULL ,
  `Wins` INT(10) UNSIGNED NOT NULL ,
  `Ties` INT(10) UNSIGNED NOT NULL ,
  `Losses` INT(10) UNSIGNED NOT NULL ,
  `GoalsScored` INT(10) UNSIGNED NOT NULL ,
  `GoalsConceded` INT(10) UNSIGNED NOT NULL ,
  `TeamPoints` DOUBLE NOT NULL ,
  PRIMARY KEY (`SeasonId`, `RealTeamId`) ,
  CONSTRAINT `FK_RealTeamInSeason_RealTeam`
    FOREIGN KEY (`RealTeamId` )
    REFERENCES `fantasy_soccer_game`.`real_team` (`IdRealTeam` )
	ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_RealTeamInSeason_Season`
    FOREIGN KEY (`SeasonId` )
    REFERENCES `fantasy_soccer_game`.`season` (`IdSeason` )
	ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_RealTeamInSeason_Season` ON `Real_Team_In_Season` (`SeasonId` ASC) ;

CREATE INDEX `INDX_RealTeamInSeason_RealTeam` ON `Real_Team_In_Season` (`RealTeamId` ASC) ;

-- -----------------------------------------------------
-- Table `Real_Team_In_Match`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`real_team_in_match` (
  `RealTeamId` INT(10) UNSIGNED NOT NULL ,
  `MatchId` INT(20) UNSIGNED NOT NULL ,
  `MinutesPlayed` double unsigned NOT NULL DEFAULT 90,-- number of minutes played in the match
  `YCards` INT(10) UNSIGNED NOT NULL DEFAULT 0 , -- number of yellow cards collected by the team in a Match
  `RedCards` INT(10) UNSIGNED NOT NULL DEFAULT 0 ,
  `Shots` INT(10) UNSIGNED NOT NULL DEFAULT 0 ,
  `Passes` INT(10) UNSIGNED NOT NULL DEFAULT 0 ,
  `Fouls` INT(10) UNSIGNED NOT NULL DEFAULT 0 ,
  `Corners` INT(10) UNSIGNED NOT NULL DEFAULT 0 ,
  `Points` DOUBLE NOT NULL DEFAULT 0 ,
  `Score` INT(2) UNSIGNED NOT NULL DEFAULT 0 ,
  `Result` CHAR(1) NOT NULL DEFAULT 't' , -- 'w' for win , 't' for tie , 'l' for lose. 
  PRIMARY KEY (`MatchId`, `RealTeamId`) ,
  CONSTRAINT `FK_RealTeamInMatch_Match`
    FOREIGN KEY (`MatchId` )
    REFERENCES `fantasy_soccer_game`.`match` (`IdMatch` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_RealTeamInMatch_RealTeam`
    FOREIGN KEY (`RealTeamId` )
    REFERENCES `fantasy_soccer_game`.`real_team` (`IdRealTeam` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_RealTeamInMatch_Season` ON `Real_Team_In_Match` (`MatchId` ASC) ;

CREATE INDEX `INDX_RealTeamInMatch_RealTeam` ON `Real_Team_In_Match` (`RealTeamId` ASC) ;


-- -----------------------------------------------------
-- Table `Real_Player_In_Season`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`real_player_in_season` (
  `RealPlayerId` INT(10) UNSIGNED NOT NULL ,
  `SeasonId` INT(10) UNSIGNED NOT NULL ,
  `Number` VARCHAR(5) NOT NULL ,
  `Height` DOUBLE UNSIGNED NULL DEFAULT 0 ,
  `Weight` DOUBLE UNSIGNED NULL DEFAULT 0 ,
  `Speed` DOUBLE UNSIGNED NULL DEFAULT  NULL ,
  `Position` NVARCHAR(20) NOT NULL ,
  `GoalsScored` INT(11) NULL DEFAULT NULL ,
  `Assists` INT(11) NULL DEFAULT NULL ,
  `CleanSheets` INT(11) NULL DEFAULT NULL ,
  `RealTeamId` INT(10) UNSIGNED NOT NULL ,
  PRIMARY KEY (`RealPlayerId`, `SeasonId`) ,
  CONSTRAINT `FK_RealPlayerInSeason_RealPlayer`
    FOREIGN KEY (`RealPlayerId` )
    REFERENCES `fantasy_soccer_game`.`real_player` (`IdRealPlayer` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_RealPlayerInSeason_RealTeam`
    FOREIGN KEY (`RealTeamId` )
    REFERENCES `fantasy_soccer_game`.`real_team` (`IdRealTeam` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_RealPlayerInSeason_Season`
    FOREIGN KEY (`SeasonId` )
    REFERENCES `fantasy_soccer_game`.`season` (`IdSeason` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_RealPlayerInSeason_RealTeam` ON `Real_Player_In_Season` (`RealTeamId` ASC) ;
CREATE INDEX `INDX_RealPlayerInSeason_RealPlayer` ON `Real_Player_In_Season` (`RealPlayerId` ASC) ;
CREATE INDEX `INDX_RealPlayerInSeason_season` ON `Real_Player_In_Season` (`SeasonId` ASC) ;

-- -----------------------------------------------------
-- Table `Real_Player_In_GameWeek`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`real_player_in_gameweek` (
  `RealPlayerId` INT(10) UNSIGNED NOT NULL ,
  `GameWeekId` INT(10) UNSIGNED NOT NULL ,
  `Price` DOUBLE UNSIGNED NOT NULL DEFAULT 0 ,
  `Points` DOUBLE NOT NULL DEFAULT 0 ,
  `GoalsScored` INT(11) NULL DEFAULT NULL ,
  `Assists` INT(11) NULL DEFAULT NULL ,
  `CleanSheets` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY (`RealPlayerId`, `GameWeekId`) ,
  CONSTRAINT `FK_RealPlayerInGameWeek_RealPlayer`
    FOREIGN KEY (`RealPlayerId` )
    REFERENCES `fantasy_soccer_game`.`real_player` (`IdRealPlayer` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_RealPlayerInGameWeek_GameWeek`
    FOREIGN KEY (`GameWeekId` )
    REFERENCES `fantasy_soccer_game`.`game_week` (`IdGameWeek` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_RealPlayerInGameWeek_GameWeek` ON `Real_Player_In_GameWeek` (`GameWeekId` ASC) ;
CREATE INDEX `INDX_RealPlayerInGameWeek_RealPlayer` ON `Real_Player_In_GameWeek` (`RealPlayerId` ASC) ;
-- -----------------------------------------------------
-- Table `Real_Player_In_Match`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`real_player_in_match` (
  `RealPlayerId` INT(10) UNSIGNED NOT NULL ,
  `MatchId` INT(20) UNSIGNED NOT NULL ,
  `Points` DOUBLE NOT NULL DEFAULT 0 ,
  `GoalsScored` INT(5) NULL DEFAULT NULL ,
  `Assists` INT(5) NULL DEFAULT NULL ,
  `CleanSheets` INT(5) NULL DEFAULT NULL ,
  `MinutesPlayed` DOUBLE UNSIGNED NOT NULL DEFAULT 0 ,
  `PenaltiesSaved` INT(3) NULL DEFAULT 0 ,
  `PenaltiesMissed` INT(3) NOT NULL DEFAULT 0 ,
  `OwnGoal` INT(3) NULL DEFAULT 0 ,
  `YellowCards` INT(3) NULL DEFAULT 0 ,
  `RedCards` INT(3) NULL DEFAULT 0 ,
  `Offsides` INT(3) NULL DEFAULT 0 ,
  `Corners` INT(3) NULL DEFAULT 0 ,
  `Clears` INT(3) NULL DEFAULT 0 ,
  `Tackles` INT(3) NULL DEFAULT 0 ,
  `Fouls` INT(3) NULL DEFAULT 0 ,
  `GameWinningGoal` INT(3) NULL DEFAULT 0 ,
  `GameWinningAssist` INT(3) NULL DEFAULT 0 ,
  `Shots` INT(3) NULL DEFAULT 0 ,
  `Rank` INT(10) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`RealPlayerId`, `MatchId`) ,
  CONSTRAINT `FK_RealPlayerInMatch_Match`
    FOREIGN KEY (`MatchId` )
    REFERENCES `fantasy_soccer_game`.`match` (`IdMatch` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_RealPlayerInMatch_RealPlayer`
    FOREIGN KEY (`RealPlayerId` )
    REFERENCES `fantasy_soccer_game`.`real_player` (`IdRealPlayer` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_RealPlayerInMach_Match` ON `Real_Player_In_Match` (`MatchId` ASC) ;
CREATE INDEX `INDX_RealPlayerInMatch_RealPlayer` ON `Real_Player_In_Match` (`RealPlayerId` ASC) ;

-- -----------------------------------------------------
-- Table `user_team`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`user_team` (
  `IdUserTeam` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `Name` VARCHAR(50) NOT NULL ,
  `Photo` VARCHAR(200) NULL DEFAULT NULL ,
  `UserId` BIGINT(20) UNSIGNED NOT NULL ,
  `CompetitionId` BIGINT(20) UNSIGNED NOT NULL ,
  `GameWeekId` INT(10) UNSIGNED NOT NULL ,
  `GainedPoints` DOUBLE NOT NULL DEFAULT 0 , -- number of pointes collected by this user team
  `GainedPrize` INT(10) UNSIGNED NULL DEFAULT NULL , -- prize Id
  `GainedCoins` DOUBLE UNSIGNED NOT NULL DEFAULT 0 ,
  `Budget` DOUBLE UNSIGNED NOT NULL DEFAULT '100000000' ,
  `Valid` TINYINT(1) NOT NULL DEFAULT 0 ,
  `Rank` INT(20) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`IdUserTeam`) ,
  CONSTRAINT `FK_UserTeam_User`
    FOREIGN KEY (`UserId` )
    REFERENCES `fantasy_soccer_game`.`user` (`IdUser` )
     ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_UserTeam_GameWeek`
    FOREIGN KEY (`GameWeekId` )
    REFERENCES `fantasy_soccer_game`.`game_week` (`IdGameWeek` )
	ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_UserTeam_Competition`
    FOREIGN KEY (`CompetitionId` )
    REFERENCES `fantasy_soccer_game`.`competition` (`IdCompetition` )
	ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_UserTeam_GainedPrize`
    FOREIGN KEY (`GainedPrize` )
    REFERENCES `fantasy_soccer_game`.`prizes_store` (`IdPrize` )
	ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_UserTeam_User` ON `User_Team` (`UserId` ASC) ;

CREATE INDEX `INDX_UserTeam_GameWeek` ON `User_Team` (`GameWeekId` ASC) ;

CREATE INDEX `INDX_UserTeam_Competition` ON `User_Team` (`CompetitionId` ASC) ;
-- -----------------------------------------------------
-- Table `UserPlayer`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`user_player` (
  `IdUserPlayer` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `Position` NVARCHAR(20) NOT NULL , -- on bench, defender, etc..
  `UserTeamId` BIGINT(20) UNSIGNED NOT NULL ,
  `RealPlayerId` INT(10) UNSIGNED NOT NULL ,
  `CaptainOrVice` CHAR(1) NULL DEFAULT NULL ,
  PRIMARY KEY (`IdUserPlayer`) ,
  CONSTRAINT `FK_UserPlayer_UserTeam`
    FOREIGN KEY (`UserTeamId` )
    REFERENCES `fantasy_soccer_game`.`user_team` (`IdUserTeam` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `FK_UserPlayer_RealPlayer`
    FOREIGN KEY (`RealPlayerId` )
    REFERENCES `fantasy_soccer_game`.`real_player` (`IdRealPlayer` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE INDEX `INDX_UserPlayer_User` ON `User_Player` (`UserTeamId` ASC) ;
CREATE INDEX `INDX_UserPlayer_RealPlayer` ON `User_Player` (`RealPlayerId` ASC) ;

-- -----------------------------------------------------
-- Table `Injuries`
-- -----------------------------------------------------

CREATE  TABLE IF NOT EXISTS `fantasy_soccer_game`.`injury` (
  `IdInjury` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `ApiId` INT(10) UNSIGNED NOT NULL ,
  `StartDate` DATETIME NULL DEFAULT NULL ,
  `EndDate` DATETIME NULL DEFAULT NULL ,
  `description` NVARCHAR(100) NULL DEFAULT NULL ,
  `PlayerId` INT(10) UNSIGNED NOT NULL ,
  `MatchId` INT(20) UNSIGNED NOT NULL ,
  `TeamId` INT(10) UNSIGNED NOT NULL ,
  PRIMARY KEY (`IdInjury`) ,
  CONSTRAINT `FK_Injury_Match`
    FOREIGN KEY (`MatchId` )
    REFERENCES `fantasy_soccer_game`.`match` (`IdMatch` ),
  CONSTRAINT `FK_Injury_RealPlayer`
    FOREIGN KEY (`PlayerId` )
    REFERENCES `fantasy_soccer_game`.`real_player` (`IdRealPlayer` ),
  CONSTRAINT `FK_Injury_RealTeam`
    FOREIGN KEY (`TeamId` )
    REFERENCES `fantasy_soccer_game`.`real_team` (`IdRealTeam` ),
  INDEX `INDX_Injury_RealPlayer` (`PlayerId` ASC) ,
  INDEX `INDX_Injury_RealTeam` (`TeamId` ASC) ,
  INDEX `INDX_Injury_Match` (`MatchId` ASC)   
)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;