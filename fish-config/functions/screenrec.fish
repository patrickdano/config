function screenrec
ffmpeg -f x11grab -y -r 30 -s 2560x1440 -i :0.0 -vcodec huffyuv (date "+%Y-%m-%d_%H.%m.%S").avi
end
