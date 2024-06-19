#!/bin/bash

echo 'Welcome to MobiLog for BASH!'

sleep 1.27

# Prompt the user for the PC's Asset tag and store that string in a variable. Prompts user to try again if it does not follow convention.
while true; do
	read -p "Please enter the PC's Asset-Tag: " userInput

        # Check the user's input
	if [[ $userInput == ?????CPU ]]; then

		echo 'succeeded'
	break

	else
		echo 'invalid CPU number - Please try again.'
	fi
done

# Define variables for endpoint's url of SNOW intance and admin account's password
instanceUrl="https://dev178128.service-now.com/api/now/table/x_1116441_mobilog_test_assets"
password=$SNOW-admin-pass

# Grab Sysid of the Asset

assettSysid=$(curl "$instanceUrl?sysparm_display_value=true&sysparm_limit=10" --request GET --header "Accept:application/json" --user 'admin':'lEmSRn*/E3w6' | awk '{ match($0, /"asset_tag":"'$userInput'","sys_id":"/); if (RSTART > 0) { print substr($0, RSTART + RLENGTH, 32); exit } }')

# Ask user if Assett is leaving or entering Stockroom

while true; do

	read -p "Is this PC going entering or leaving the stockroom? (ent/Leav):" mobInput

	if [[ $mobInput == ent ]]; then
		assettDstate=$(curl "https://dev178128.service-now.com/api/now/table/x_1116441_mobilog_test_assets/$assettSysid?sysparm_input_display_value=true" --request PATCH --header "Accept:application/json" --header "Content-Type:application/json" --data "{\"deployment_state\":\"In stock\"}" --user 'admin':'lEmSRn*/E3w6' | grep -o '"deployment_state":"[^"]*' | cut -d '"' -f 4)
	break

	elif [[ $mobInput == Leav ]]; then
		assettDstate=$(curl "https://dev178128.service-now.com/api/now/table/x_1116441_mobilog_test_assets/$assettSysid?sysparm_input_display_value=true" \--request PATCH \--header "Accept:application/json" \--header "Content-Type:application/json" \--data "{\"deployment_state\":\"In use\"}" \--user 'admin':'lEmSRn*/E3w6' | grep -o '"deployment_state":"[^"]*' | cut -d '"' -f 4)
	break

	else echo invalid input given please try again

	sleep 0.9

	fi

done

echo Deployment state for $userInput has been updated to $assettDstate

exit 0
