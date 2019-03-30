#!/bin/sh

CONFIGDIR=/config
DOWNLOADSDIR=/downloads

echo "Setting owner for config and data directories."
mkdir -p $CONFIGDIR
mkdir -p $DOWNLOADSDIR
chown -R deluge $CONFIGDIR
chown deluge $DOWNLOADSDIR

if [ ! -d $CONFIGDIR ]; then
        echo "The config directory does not exist! Please add it as a volume."
        exit 1
fi
if [ ! -d $DOWNLOADSDIR ]; then
        echo "The data directory does not exist! Please add it as a volume."
        exit 1
fi

# Check if the authentication file exists.
if [ ! -f $CONFIGDIR/auth ]; then
        AUTHMISSING=true
fi

echo "$USERNAME:$PASSWORD:10" >> $CONFIGDIR/test

if [ $AUTHMISSING ]; then
        echo "Doing initial setup."
        # Starting deluge
        deluged -c $CONFIGDIR

        # Wait until auth file created.
        while [ ! -f $CONFIGDIR/auth ]; do
                sleep 1
        done

        # allow remote access
        deluge-console -c $CONFIGDIR "config -s allow_remote True"

        # setup default paths to go to the user's defined data folder.
        deluge-console -c $CONFIGDIR "config -s download_location $DOWNLOADSDIR"
        deluge-console -c $CONFIGDIR "config -s torrentfiles_location $DOWNLOADSDIR"
        deluge-console -c $CONFIGDIR "config -s move_completed_path $DOWNLOADSDIR"
        deluge-console -c $CONFIGDIR "config -s autoadd_location $DOWNLOADSDIR"

        # Stop deluged.
        pkill deluged

        echo "Adding initial authentication details."
        echo deluge:deluge:10 >>  $CONFIGDIR/auth
fi

echo "Starting deluged and deluge-web."
su -s /bin/sh deluge -c 'deluged -c /config'
su -s /bin/sh deluge -c 'deluge-web -c /config'