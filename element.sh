#!/bin/bash
PSQL="psql --username=postgres --dbname=periodic_table -t -q --no-align -c"
if [ -z "$1" ]; then
    echo "Please provide an element as an argument."
    exit 0  # Exit with a non-zero status to indicate an error
fi

NOT_FOUND_ELEMENTS(){
  echo I could not find that element in the database.
}
SEARCH_BY_SYMBOL(){
local RESULT=$($PSQL "
  SELECT el.atomic_number, el.symbol, el.name, pr.atomic_mass, pr.melting_point_celsius, pr.boiling_point_celsius, t.type 
   FROM elements AS el
   FULL JOIN properties AS pr ON el.atomic_number = pr.atomic_number
   FULL JOIN types AS t ON t.type_id=pr.type_id
  WHERE el.symbol='$1'
")
if [[ ! -z $RESULT ]]
  then
    read ATOMIC_NUMBER SYMBOL ELEMENT_NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< $(echo $RESULT | sed 's/[|]/ /g')
    echo The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME \($SYMBOL\). It\'s a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius.
  else
    # else notify the absence of the symbol
    NOT_FOUND_ELEMENTS
  fi
  exit 0

}
SEARCH_BY_ATOMIC_NUMBER(){
local RESULT=$($PSQL "
  SELECT el.atomic_number, el.symbol, el.name, pr.atomic_mass, pr.melting_point_celsius, pr.boiling_point_celsius, t.type 
   FROM elements AS el
   FULL JOIN properties AS pr ON el.atomic_number = pr.atomic_number
   FULL JOIN types AS t ON t.type_id=pr.type_id
  WHERE el.atomic_number='$1'
")
if [[ ! -z $RESULT ]]
  then
    read ATOMIC_NUMBER SYMBOL ELEMENT_NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< $(echo $RESULT | sed 's/[|]/ /g')
    echo The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME \($SYMBOL\). It\'s a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius.
  else
   NOT_FOUND_ELEMENTS
  fi
  exit 0
}
SERACH_BY_NAME(){
 local RESULT=$($PSQL "
  SELECT el.atomic_number, el.symbol, el.name, pr.atomic_mass, pr.melting_point_celsius, pr.boiling_point_celsius, t.type 
   FROM elements AS el
   FULL JOIN properties AS pr ON el.atomic_number = pr.atomic_number
   FULL JOIN types AS t ON t.type_id=pr.type_id
  WHERE el.name='$1'
")
if [[ ! -z $RESULT ]]
  then
    read ATOMIC_NUMBER SYMBOL ELEMENT_NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< $(echo $RESULT | sed 's/[|]/ /g')
    echo The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME \($SYMBOL\). It\'s a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius.
  else
    NOT_FOUND_ELEMENTS
  fi
  exit 0
}


if [[ $1 =~ ^[A-Z][a-z]?$ ]];
then
  SYMBOL=$1
  SEARCH_BY_SYMBOL  $SYMBOL
elif [[ $1 =~ ^[1-9][0-9]*$ ]]
then
  ATOMIC_NUMBER=$1
  SEARCH_BY_ATOMIC_NUMBER $ATOMIC_NUMBER
elif [[ $1 =~ ^[A-Z][a-z]+$ && ${#1} -ge 3 ]]
then
  ELEMENT_NAME=$1
  SERACH_BY_NAME $ELEMENT_NAME
else
  NOT_FOUND_ELEMENTS
fi
