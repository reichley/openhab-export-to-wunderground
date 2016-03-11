#!/bin/bash
###############################################################
###### openhab2wunderground by Nick Reichley 23 Feb 2016 ######
###############################################################

echo "welcome. this is a simple script that transmits your most recent openhab sensor states to wunderground"
echo "using by using the cURL and cut commands (and the openhab rest API). you will need your openhab item names"
echo " and to have set up a personal weather station on Wunderground (your station ID and password). Let's get started!"
echo ""
echo ""

read -p "enter your wunderground station ID (and press ENTER) " station_id
echo ""

read -p "enter your password (and press ENTER) " password
echo ""

read -p "please enter the local ip address of your openhab server (and press ENTER) " ip_addy
echo ""

while true
do
  read -p "is your openhab server running on the default port [8080]? (y/n) " answer
  case $answer in
   [yY]* ) port=8080
           echo "setting default port..."
           break;;
   [nN]* ) read -p "please enter the port number " port
           break;;
       * ) echo "please enter y or n"
	   break;;
  esac
done

echo ""
echo "great. now we'll set up your weather inputs (just temp and hum, but can modify script to add more variables). have your openhab item names handy."
echo ""

while true
do
  read -p "how many fields do you wish to set up (2 max)? " number_fields
  case $number_fields in
    1 ) read -p "please enter the openhab item name for field 1 [temp] (and press ENTER) " field1
        echo $field1
        break;;
    2 ) read -p "please enter the openhab item name for field 1 [temp] (and press ENTER) " field1
        echo $field1
        read -p "please enter the openhab item name for field 2 [humidity] (and press ENTER) " field2
        echo $field2
        break;;
    * ) echo "please enter 1-2... "
        break;;
  esac
done

echo ""
echo "cURLing openhab, will output data and push to wunderground shortly..."
echo ""
f1=`curl -s http://$ip_addy:$port/rest/items/$field1/state | cut -c 1-5`
echo $f1
f2=`curl -s http://$ip_addy:$port/rest/items/$field2/state | cut -c 1-5`
echo $f2


read -p "would you like a .sh script (habwundercron.sh) created following the execution of this script to add to your crontab? (y/n) " answer2

if [ "$answer2" == "y" ] || [ "$answer2" == "Y" ]; then
	printf "#!/bin/bash\n" >> habwundercron.sh
	printf "station_id=$station_id\n" >> habwundercron.sh
	printf "password=$password\n" >> habwundercron.sh
	printf "ip_addy=$ip_addy\n" >> habwundercron.sh
	printf "port=$port\n" >> habwundercron.sh
	printf "field1=$field1\n" >> habwundercron.sh
	printf "field2=$field2\n" >> habwundercron.sh
	printf "f1=\`curl -s http://$ip_addy:$port/rest/items/$field1/state | cut -c 1-5\`\n" >> habwundercron.sh
	printf "f2=\`curl -s http://$ip_addy:$port/rest/items/$field2/state | cut -c 1-5\`\n" >> habwundercron.sh
	printf "d=\`date\`\n" >> habwundercron.sh
	printf "printf \"%%s = \" \"\$d\"; curl -k --data \"ID=\$station_id&PASSWORD=\$password&dateutc=now&tempf=\$f1&humidity=\$f2&action=updateraw\" http://weatherstation.wunderground.com/weatherstation/updateweatherstation.php?" >> habwundercron.sh
fi
d=`date`
printf "%s = " "$d"; curl -k --data "ID=$station_id&PASSWORD=$password&dateutc=now&tempf=$f1&humidity=$f2&action=updateraw" http://weatherstation.wunderground.com/weatherstation/updateweatherstation.php?
echo ""
echo "finished!"
echo ""
echo ""
echo "*********************************************************************************************************************************************************************"
echo "*************   add habwundercron.sh to your crontab by executing sudo crontab -e and adding */15 * * * * /home/(username)/habwundercron.sh to the bottom   ***********"
echo "*********************************************************************************************************************************************************************"
echo ""
echo ""
sleep 1
