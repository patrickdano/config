# Defined in /tmp/fish.cG4S8Y/ls.fish @ line 2
function ls --description 'List contents of directory'
#    set -l opt --color=auto
#            isatty stdout
#            and set -a opt -F
#            command ls $opt $argv
#    exa -la $argv
     exa -lah --color=always --group-directories-first $argv
end
