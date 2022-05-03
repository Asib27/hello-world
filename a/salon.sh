#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


function MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e $1
  fi

  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
    HANDLE_CLIENT $SERVICE_ID
  fi
}

function HANDLE_CLIENT () {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # finding customer id , if not in database then by adding
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$1")

  echo -e "\nWhat time would you like your$SERVICE,$NAME?"
  read SERVICE_TIME

  RESULT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $1)")
  if [[ $RESULT == "INSERT 0 1" ]]
  then
    echo "I have put you down for a$SERVICE at $SERVICE_TIME,$NAME."
  else
    echo "Sorry, some error has occured."
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?\n"


