#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

# Looping minta service ID sampai valid
while true
do
  # Tampilkan list layanan
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS="|" read ID NAME
  do
    echo "$ID) $NAME"
  done
  
  read SERVICE_ID_SELECTED
  
  # Cek apakah ID ada di database
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | xargs)
  
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. What would you like today?\n"
  else
    break
  fi
done

# Minta nomor telepon
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Cek apakah nomor telepon sudah terdaftar
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs)

# Kalau belum terdaftar, minta nama dan simpan
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" > /dev/null
fi

# Minta waktu
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Ambil customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs)

# Insert ke tabel appointments
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" > /dev/null

# Tampilkan pesan sukses
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."