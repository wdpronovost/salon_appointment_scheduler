#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
    if [[ ! $1 ]]; then
        EXIT
    else
        echo -e "\n$1\n"
        AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
        echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE; do
            echo "$SERVICE_ID) $SERVICE"
        done
        read SERVICE_ID_SELECTED

        # if the selection is not a service
        if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
            # send to main menu
            MAIN_MENU "I could not find that service. What would you like today?"
        else
            # start appointment creation
            SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
            SERVICE_FORMATTED=$(echo $SERVICE | sed -E 's/^ *| *$//g')
            # get customer phone number to see if they have an account
            echo -e "\nWhat's your phone number?"
            read CUSTOMER_PHONE
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
            # if they don't have an account
            if [[ -z $CUSTOMER_NAME ]]; then
                # get name
                echo -e "\nI don't have a record for that phone number, what's your name?"
                read CUSTOMER_NAME
                # create account
                INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
            fi
            # get customer id
            CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME_FORMATTED'")
            # get appointment time
            echo -e "\nWhat time would you like your $SERVICE_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
            read SERVICE_TIME
            SERVICE_TIME_FORMATTED=$(echo $SERVICE_TIME | sed -E 's/^ *| *$//g')
            # create appointment record
            INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
            echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED."
            MAIN_MENU
        fi
    fi
}

EXIT() {
    # just an exit
    echo -e "\nThank you for visiting My Salon!"
}

MAIN_MENU "Welcome to My Salon, how can I help you?"