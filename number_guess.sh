#!/bin/bash
# Create PSQL variable for querying the db
PSQL="psql --username=freecodecamp --dbname=players -t --no-align -c"


# Prompt user for a username
echo "Enter your username:"
read USERNAME
USERNAME_INPUT=$($PSQL "SELECT username FROM players WHERE username = '$USERNAME'")
# If input is not an integer
# If the username has not been used before
if [[ -z $USERNAME_INPUT ]]
then
echo -e "Welcome, $USERNAME! It looks like this is your first time here."
# Insert username into db
NEW_USER=$($PSQL "INSERT INTO players(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
else
# Read from db 
CURRENT_USER=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username = '$USERNAME'")
echo $CURRENT_USER | while IFS="|" read C_USERNAME GAMES_PLAYED BEST_GAME
do
echo "Welcome back, $C_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
done
fi
  let GAMES_PLAYED=0
  let NUM_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
# Generate a random number
SECRET_NUMBER=$((RANDOM%1000 +1))
echo $SECRET_NUMBER
GAME() {
  read USER_NUMBER
  if ! [[ $USER_NUMBER =~ ^[0-9]+$ ]]
    then
    echo "That is not an integer, guess again:"
    GAME
  fi

  let NUM_GUESSES++

  if [[ $USER_NUMBER = $SECRET_NUMBER ]]
    then
    echo "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    INSERT_BEST_GAME=$($PSQL "UPDATE players SET best_game='$NUM_GUESSES' WHERE username='$USERNAME' AND best_game >= '$NUM_GUESSES' OR best_game = '0'")
    exit
  elif [[ $USER_NUMBER > $SECRET_NUMBER ]]
    then
    echo "It's lower than that, guess again:"
    GAME
  else
    echo "It's higher than that, guess again:"
    GAME
  fi
}
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME'")
  let GAMES_PLAYED++
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played='$GAMES_PLAYED' WHERE username='$USERNAME'")

GAME
