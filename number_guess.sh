#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
GUESSES=0

GAME_INIT(){
  echo Enter your username:
  read NAME
  #check if name exists
  USERNAME=$($PSQL "SELECT user_name FROM games WHERE user_name='$NAME'")
  if [[ -z $USERNAME ]]
  then 
    GAMES_PLAYED=0
    BEST_GAME=1000
    INSERT_USER_RESULT=$($PSQL "INSERT INTO games(user_name, games_played, best_game) VALUES('$NAME', $GAMES_PLAYED, $BEST_GAME)")
    USERNAME=$($PSQL "SELECT user_name FROM games WHERE user_name='$NAME'")
    echo Welcome, $USERNAME! It looks like this is your first time here.
    GAME_START
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE user_name='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE user_name='$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    GAME_START
  fi
}

GAME_START(){
  echo Guess the secret number between 1 and 1000:
  RAND_NUM
  read GUESS
  GAME_PLAY
  ((GUESSES++))
}

GAME_PLAY(){
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
   echo That is not an integer, guess again:
   read GUESS
   ((GUESSES++))
   GAME_PLAY
  else 
    if [[ $GUESS -lt $RAND_INT ]]
    then 
      echo It\'s higher than that, guess again:
      read GUESS
      ((GUESSES++))
      GAME_PLAY
    elif [[ $GUESS -gt $RAND_INT ]]
    then 
      echo It\'s lower than that, guess again:
      read GUESS
      ((GUESSES++))
      GAME_PLAY
    else
      ((GUESSES++))
      echo "You guessed it in $GUESSES tries. The secret number was $RAND_INT. Nice job!"
      ((GAMES_PLAYED++))
      GAME_COUNT=$($PSQL "UPDATE games SET games_played=$GAMES_PLAYED WHERE user_name='$USERNAME'")
      if [[ $GUESSES -lt $BEST_GAME ]]
      then
        INSERT_BEST=$($PSQL "UPDATE games SET best_game=$GUESSES WHERE user_name='$USERNAME'")
      fi
      exit
    fi
  fi
}

#Randomly generate a number: for users to guess
RAND_NUM(){
  min=1
  max=1000
  RAND_INT=$(( RANDOM % (max - min + 1) + min ))
}

GAME_INIT