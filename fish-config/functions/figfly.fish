# Defined in /tmp/fish.3RQdiJ/figfly.fish @ line 2
function figfly
    figlet -t -f (random choice /usr/share/figlet/fonts/*.flf) $hostname | lolcat
end
