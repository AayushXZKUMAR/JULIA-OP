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


# Made by @MissJuliaRobot
# A script to convert python source to C and get it's .so (shared object) file
# This may boost/speed up python compilation time and performance
# However there is no such guarantee it will do so
# If you are using this script in your project please don't remove these few lines, if you respect the creator.


main () { 

 # iter through all directories and subdirectories
 for i in $(find . -type f); do

    # only match python files
    # don't include __main__.py # => python package
    if [[ $i == *.py ]] && [[ $i != "__main__.py" ]] && [[ $i != ./.heroku* ]] && [[ $i != ./.apt* ]]; then

        # demojize all filenames containing emoji
        g=$(python -c "import emoji; print(emoji.demojize('${i}'))")

        # rename the files
        mv $i $g  &> /dev/null # ignore errors

    fi

 done
 
 # re-run
 # iter through all directories and subdirectories
 for i in $(find . -type f); do

    # only match python files
    # don't include __main__.py # => python package
    if [[ $i == *.py ]] && [[ $i != "__main__.py" ]] && [[ $i != ./.heroku* ]] && [[ $i != ./.apt* ]]; then

        # convert all .py files to .so binary 
        python3 -m nuitka --module --no-progress --quiet --remove-output --nofollow-imports --no-pyi-file $p &> /dev/null # ignore errors 
        
        # remove the .py files
        rm -rf $p

    fi

 done

 # iter through all directories and subdirectories
 for z in $(find . -type f); do

     # only match .so files
     if [[ $z == *.so ]]; then
        
        # emojize all filenames containing emoji
        g=$(python -c "import emoji; print(emoji.emojize('${z}'))")

        # rename the files
        mv $i $g  &> /dev/null # ignore errors

     fi    

 done 
 
 # This will give __main__.bin
 # We can execute directly with ./__main__.bin
 python3 -m nuitka --no-progress --quiet --remove-output --nofollow-imports __main__.py
 rm -rf __main__.py

}


main () & PID=$! # PID of main() function

echo "Compiling Resources"

printf "["

# While main() is running...
while kill -0 $PID 2> /dev/null; do 

    printf  "▓"

    sleep 1

done

printf "] done!"
