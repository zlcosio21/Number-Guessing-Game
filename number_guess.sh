#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

echo "Enter your username:"
read USERNAME

SEARCH_USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME';")

if [[ -n $SEARCH_USERNAME ]]; then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL);")
fi


echo "Guess the secret number between 1 and 1000:"
read NUMBER

SECRET_NUMBER=$((1 + RANDOM % 1000))
NUMBER_OF_GUESSES=1

while [[ "$SECRET_NUMBER" -ne "$NUMBER" ]]; do
  if ! [[ "$NUMBER" =~ ^-?[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif [ "$NUMBER" -gt "$SECRET_NUMBER" ]; then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi

  read NUMBER
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
done


UPDATING_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")

if [[ -z $BEST_GAME ]] || [[ "$NUMBER_OF_GUESSES" -lt "$BEST_GAME" ]]; then
  UPDATING_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME';")
fi


echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"