server='chrislinux'

for f in "$@"
do

sourcepath="$f"
filename=$(basename "$sourcepath")

if [[ $filename = *fail ]] || [[ $filename = *transfer ]]; then
	continue
fi

#filename=`printf "%q" "$filename"`

echo "filename after cleansing is  : $filename"

if (ping -c 1 $server) then

	destinationpath="/home/chris/torrent/watch/$filename"

	echo "server up, transferring file $filename"
	
	(echo put \""$sourcepath"\"; echo rename \""$filename"\" \""$destinationpath"\") | sftp -b - $server
		
	if (`ssh $server "ls \"$destinationpath\">/dev/null"`) then
		echo "transfer success - deleting file"
        rm "$sourcepath"
	else
		echo "transfer failure - creating failure file"
        > "$sourcepath.fail"
	fi
	
fi

done