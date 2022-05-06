#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c "

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# if atomic no given
if [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NO=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
fi

# if symbol is given
if [[ -z $ATOMIC_NO ]]
then
  ATOMIC_NO=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
fi

# if name is given
if [[ -z $ATOMIC_NO ]]
then
  ATOMIC_NO=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
fi

# if doesn't match
if [[ -z $ATOMIC_NO ]]
then
  echo "I could not find that element in the database."
  exit
fi


# removing spaces
ATOMIC_NO=$(echo $ATOMIC_NO  | xargs)

# query and output
INFO=$($PSQL "SELECT e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM properties as p INNER JOIN elements AS e USING (atomic_number) INNER JOIN types AS t USING (type_id) WHERE atomic_number=$ATOMIC_NO")

read NAME BAR SYMBOL BAR TYPE BAR MASS BAR MELTING BAR BOILING  <<< $INFO

echo "The element with atomic number $ATOMIC_NO is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."