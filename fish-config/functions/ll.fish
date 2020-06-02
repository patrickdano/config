# Defined in /usr/share/fish/functions/ll.fish @ line 4
function ll --description 'List contents of directory using long format'
    exa -lh $argv
end
