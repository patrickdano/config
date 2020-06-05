# Defined in /tmp/fish.TjwMTG/cowtalk.fish @ line 1
function cowtalk
	fortune | cowsay -f (random choice /usr/share/cows/*.cow) | lolcat
end
