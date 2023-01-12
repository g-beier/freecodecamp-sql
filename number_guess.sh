#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

RANDOM_NUMBER=$(( ($RANDOM % 1000) + 1 ))
echo $RANDOM_NUMBER

MAIN_MENU() {
echo -e "\n\n~~~   Number Guessing   ~~~\n\n"
echo "Enter your username:"
read USERNAME
USER_DATA=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]
then # IF ITS A NEW USER, GREETINGS
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else # IF ITS AN OLD USER, GETS DATA TO SHOW
  echo "$USER_DATA" | while read USER_ID PIPE USERNAME PIPE GAMES_PLAYED PIPE BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo -e "\nGuess the secret number between 1 and 1000:"

COUNT=1
read GUESS

while [[ $GUESS != $RANDOM_NUMBER ]]
do # WHILE THE GUESSES ARE WRONG, KEEP ASKING
  if [[ $GUESS =~ ^[0-9]*$ ]]
  then
    COUNT=$(( $COUNT + 1 ))
    if [[ $GUESS > $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
  read GUESS
done

if [[ -z $USER_DATA ]]
then
  # NOVO JOGADOR: inserir no DB
  NEW_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $COUNT)")
  
else
  # JOGADOR VELHO: inserir no DB
    # aumentar games_played
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$(($GAMES_PLAYED + 1)) WHERE username='$USERNAME'")
    # verificar se altera #best_game
  if [[ $COUNT < $BEST_GAME ]]
  then
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET best_game=$COUNT WHERE username='$USERNAME'")
  fi
fi
echo "You guessed it in $COUNT tries. The secret number was $GUESS. Nice job!"
}

MAIN_MENU
