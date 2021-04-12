#    MissJuliaRobot (A Telegram Bot Project)
#    Copyright (C) 2019-Present Anonymous (https://t.me/MissJulia_Robot)

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, in version 3 of the License.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.

#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see < https://www.gnu.org/licenses/agpl-3.0.en.html >


# Made by @MissJulia_Robot
# So you are tired of updating your pypi dependencies whenever they breaks.
# For example dependencies like youtube_dl, howdoi etc. aren't stable and they need to be updated to function properly.
# So, I have made a easy solution for you.
# If you are using this script in your project please don't remove these few lines, if you respect the creator.


# we first fetch the environment variables
geturl="${SOURCE_URL}"
authkey="${HEROKU_API_KEY}"
appname="${HEROKU_APP_NAME}"
reqpath='requirements.txt' # change if necessary
should_update="${AUTO_UPDATE_DEPS}" # < bool: true/false >


# Give users their own choice
if $should_update; then

 # while loop
 while true; do

  # Read the dependencies
  while IFS= read -r line; do

   # Fetch all the outdated dependencies
   outdated=$(pip --disable-pip-version-check list --outdated)

   # Here i am using some pattern check to strip out unstable dependencies
   # Logic: if dependencies has == then it's version is fixed, and if it has < then it cannot exceed its current version
   if ! [[ $line =~ == ]] && ! [[ $line =~ '<' ]]; then
      
      # Check if any of the striped dependencies is outdated
      if grep -q "$line" <<< "$outdated"; then
   
          # deploy a new version
          curl -n -X POST "https://api.heroku.com/apps/${appname}/builds" \
          -d "{\""source_blob\"": {\""url\"": \""${geturl}\""}}" \
          -H "Content-Type: application/json" \
          -H "Authorization: Bearer ${authkey}" \
          -H "Accept: application/vnd.heroku+json; version=3" &> /dev/null

          # show that a new version is being deployed
          echo -e "\nFound outdated dependencies. Auto Updating ...\n"

          # Directly break the first while loop
          break 2

      fi     

   fi
  
  done < $reqpath

 # You can increase/decrease the time if you want
 sleep 60 

 done

else

 # do nothing (pass)
 :

fi
