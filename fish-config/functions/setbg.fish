# Defined in /tmp/fish.OctSXf/setbg.fish @ line 2
function setbg
    #set bg = random choice ~/Dropbox/Wallpapers/*
    #exec feh --bg-scale $bg
    #set dir = ~/Dropbox/Wallpapers
    #set bglist eval ls $dir 
    #set bg eval $bglist | shuf -n 1
    #echo $bg
    #feh --bg-scale $bg 
    feh --bg-scale (random choice ~/Dropbox/Wallpapers/*)
end
