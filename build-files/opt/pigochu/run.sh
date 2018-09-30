#!/bin/bash
# copy replcaefiles
cp -rf --no-preserve=mode,ownership,xattr /root/.replace-files/* /

# do template replace
for sourcefile in $(find /root/.template-files -type f);
    do
        targetfile=$(echo "$sourcefile" | cut -c 22-)
        echo "template : $sourcefile to $targetfile"
		envsubst < $sourcefile > $targetfile
done

# run boot script

for shellfile in $(find /root/.bootscript-files -type f);
    do
	    echo "run file: $shellfile"
        eval $shellfile
done