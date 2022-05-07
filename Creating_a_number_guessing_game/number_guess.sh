#!/bin/bash

function GUESS_GAME() {
  echo "Guess the secret number between 1 and 1000:"
  GUESS=-1
  
  # echo $1
  while (( $GUESS != $1 ))
  do
    COUNT=$(( (COUNT+1) ))
    read GUESS

    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      COUNT=$(( (COUNT-1) ))
    elif (( $GUESS > $1 ))
    then
      echo "It's lower than that, guess again:"
    elif (( $GUESS < $1 ))
    then
      echo "It's higher than that, guess again:"
    fi
  done

  echo "You guessed it in $COUNT tries. The secret number was $1. Nice job!"
}

NUMBER=$(( (RANDOM % 1000) + 1 ))
echo "Enter your username: "
read USERNAME

PSQL="psql -X --username=freecodecamp --dbname=guessing_game --tuples-only --no-align -c"
INFO=$($PSQL "SELECT user_id,no_of_games, best_game  FROM users WHERE name='$USERNAME'")

COUNT=0
if [[ -z $INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GUESS_GAME $NUMBER
  INSERT_RESULT=$($PSQL "INSERT INTO users(name, no_of_games, best_game) VALUES('$USERNAME', 1, $COUNT)")
else
  IFS="|"
  read USER_ID NO_GAMES BEST_GAME <<< $INFO
  echo "Welcome back, $USERNAME! You have played $NO_GAMES games, and your best game took $BEST_GAME guesses."
  GUESS_GAME $NUMBER
  
  IFS=" "
  UPDATE_RESULT=$($PSQL "UPDATE users SET no_of_games=$(( ($NO_GAMES + 1) )) WHERE name='$USERNAME'")

  if (( $COUNT < $BEST_GAME ))
  then 
    UPDATE_RESULT_2=$($PSQL "UPDATE users SET best_game=$COUNT WHERE name='$USERNAME'")
  fi
fi