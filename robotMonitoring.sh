#!/bin/zsh

#Start software, get window ID, place it

source /opt/ros/kinetic/setup.zsh
source /usr/local/setup.zsh
declare -a software_name=('PlotJuggler' 'rviz')
declare -a software_launch=("/usr/local/lib/plotjuggler/PlotJuggler" 
                            "rviz"
                            )

# Gravity -> put to 0
# X
# Y
# Width
# Height

declare -a software_positions=("0,50,50,250,250"
                               "0,50,50,250,250"
                              )

## now loop through the array
x=1

for i in "${software_launch[@]}"
do

  echo "Start $i $x"
  $i &
  sleep 5
  PIDS="$(pidof ${software_name[x]})"
  echo "PIDS=" $PIDS

  for pid in $PIDS
  do
    WID=$(wmctrl -lp | grep $pid | cut "-d " -f1)
    if [ -n "$WID" ]; then
      echo "wid=" $WID
      break
    fi
  done

  # Disables maximized window
  wmctrl -i -r $WID -b remove,maximized_vert,maximized_horz

  # Reposition window
  wmctrl -i -r $WID -e "${software_positions[x]}"

  ((x++))
  WID=""
  sleep 2

done
