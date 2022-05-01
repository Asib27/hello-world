#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE TABLE teams, games")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
    then
    # finding winner id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if  [[ -z $WINNER_ID ]]
    then
      TEAM_INSERT_RESULT=$($PSQL "INSERT INTO teams (name) VALUES('$WINNER')")
      if [[ $TEAM_INSERT_RESULT = 'INSERT 0 1' ]]
      then
        echo $WINNER entered into teams;
      fi
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # finding opponent id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if  [[ -z $OPPONENT_ID ]]
    then
      TEAM_INSERT_RESULT=$($PSQL "INSERT INTO teams (name) VALUES('$OPPONENT')")
      if [[ $TEAM_INSERT_RESULT = 'INSERT 0 1' ]]
      then
        echo $OPPONENT entered into teams;
      fi
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # inserting into games
    GAME_INSERT_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $GAME_INSERT_RESULT = "INSERT 0 1" ]]
    then
      echo $WINNER vs $OPPONENT round $ROUND $YEAR inserted succefully;
    fi
  fi
done