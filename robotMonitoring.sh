#!/bin/zsh
setopt shwordsplit      # this can be unset by saying: unsetopt shwordsplit

#Start software, get window ID, place it
source /opt/ros/kinetic/setup.zsh
source /usr/local/setup.zsh

#source robotMonitoring.cfg

#Netdata needs to be opened before start since the visualization is in google-chrome
netdata

# Parses arguments
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
   -c|--config)
    CONFIG="$2"
		source $CONFIG
    shift # past argument
    ;;
    -r|--rviz)
    RVIZ="$2"
		echo RVIZ_OPTION = "--display-config=${RVIZ}"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done



declare -a software_name=('PlotJuggler' 
                          'rviz'
                          'chrome'
                          )
declare -a software_launch=("/usr/local/lib/plotjuggler/PlotJuggler" 
                            "rviz"
                            "/usr/bin/google-chrome"
                            )
declare -a software_parameters=("" 
                                "${RVIZ_OPTION}"
                                "http://localhost:19999"
                                )

# Gets screen size
SCREEN_SIZE=$(xdpyinfo  | grep -oP 'dimensions:\s+\K\S+')
echo $SCREEN_SIZE

SCREEN_X=$(echo "$SCREEN_SIZE" | cut -d'x' -f1)
SCREEN_Y=$(echo "$SCREEN_SIZE" | cut -d'x' -f2)

# Gravity -> put to 0
# X
# Y
# Width
# Height
#Predefined positions
TOP="0,0,0,$(($SCREEN_X)),$(($SCREEN_Y/2))"
BOTTOM="0,0,$(($SCREEN_Y/2)),$(($SCREEN_X)),$(($SCREEN_Y/2))"
LEFT="0,0,0,$(($SCREEN_X/2)),$(($SCREEN_Y))" 
RIGHT="0,$(($SCREEN_X/2)),0,$(($SCREEN_X/2)),$(($SCREEN_Y))" 
TOP_LEFT="0,0,0,$(($SCREEN_X/2)),$(($SCREEN_Y/2))"
TOP_RIGHT="0,$(($SCREEN_X/2)),0,$(($SCREEN_X/2)),$(($SCREEN_Y/2))" 
BOTTOM_LEFT="0,0,$(($SCREEN_Y/2)),$(($SCREEN_X/2)),$(($SCREEN_Y/2))"
BOTTOM_RIGHT="0,$(($SCREEN_X/2)),$(($SCREEN_Y/2)),$(($SCREEN_X/2)),$(($SCREEN_Y/2))" 

declare -a software_positions=($LEFT $TOP_RIGHT $BOTTOM_RIGHT)

## now loop through the array
x=1

for i in "${software_launch[@]}"
do

  echo "Start $i $x ${software_parameters[x]}"
  $i ${software_parameters[x]} &
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
