#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_DATA=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1")
  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
  then
    ELEMENT_DATA=$($PSQL "SELECT * FROM elements WHERE symbol='$1'")
  elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
  then
    ELEMENT_DATA=$($PSQL "SELECT * FROM elements WHERE name='$1'")
  fi
    if [[ -z $ELEMENT_DATA ]]
    then
      echo "I could not find that element in the database."
    else
      echo "$ELEMENT_DATA" | while read ATOMIC_NUMBER PIPE SYMBOL PIPE NAME
      do
        ELEMENT_PROPERTIES=$($PSQL "SELECT * FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
        echo "$ELEMENT_PROPERTIES" | while read ATOMIC_NUMBER PIPE ATOMIC_MASS PIPE MELTING_POINT PIPE BOILING_POINT PIPE TYPE_ID
        do
          ELEMENT_TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
          TYPE=$(echo "$ELEMENT_TYPE" | sed 's/^ *| *$//g')
          echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a$TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
        done
      done
    fi
fi
