#! /bin/bash
#scripts to show stuff on the bar
upgrades() {
	upgrades="$(pamac checkupdates | awk '/available/ {print $1}')"
	upglen=${#upgrades}
	if (($upglen == 0))
	then
	        echo -e ""
	else
	        echo -e " $upgrades"
	fi
}


dte() {
	  date="$(date +"%a, %b %d %R")"
	  echo -e " $date "
    }

############################## 
#	    DISK
##############################

hdd() {
	  #hdd="$(df -h /home | grep /dev | awk '{print $3 " / " $5}')"
	  ssd="$(df -h / | grep /dev/nvme | awk '{print $3 "("$5")"} ')"
	  hdd="$(df -h /dev/sda2 | grep sda2 | awk '{print $3 "("$5")"}')"
	    echo -e " SSD: $ssd HD: $hdd"
    }
##############################
#	    RAM
##############################

mem() {
	mem="$(free -h | awk '/Mem:/ {printf $3 "/" $2}')"
	echo -e " RAM: $mem "
}
##############################	
#	    CPU
##############################

cpu() {
	  read cpu a b c previdle rest < /proc/stat
	    prevtotal=$((a+b+c+previdle))
	      sleep 0.5
	        read cpu a b c idle rest < /proc/stat
		  total=$((a+b+c+idle))
		    cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
		    
		    #if (($cpu -lt 50))
		    #then
		#	    echo -e "+@fg=2;$cpu%" 
		 #   elif (($cpu -lt 75))
		#	    echo -e "+@fg=3;$cpu%"
		 #   else
		#	    echo -e "+@fg=1;$cpu%"
		 #   fi

		    echo -e " CPU: $cpu% "
	      }
##############################
#	    VOLUME
##############################

vol() {
	vol="$(amixer -D pulse get Master | awk -F'[][]' 'END{ print $2 }')"
	echo -e " Vol $vol "
}

nitrogen --restore &
picom &
lxsession &
xrandr --output DP-2 --mode 2560x1440 --rate 74.92 --output DVI-I-1 --mode 2560x1440 --rate 59.95

while true
do
	xsetroot -name "$(hdd) $(mem) $(cpu) $(dte)"
	sleep 1
done
