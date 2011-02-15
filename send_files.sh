#!/bin/sh

if [ -n "$1" ]
then
  rsync -rvut --executability --delete --exclude="test_articles" * $1:/home/gannon/scripts
  if [ -n "$2" ]
  then
    rsync -rvut --executability --delete --exclude="test_articles" * $2:/home/gannon/scripts
  fi
else

for server in 'webprod.pa' 'dbprod.pa' 'webalt.pa' 'dbalt.pa'; do
        echo $server
	rsync -rut --executability --delete --exclude="test_articles" * gannon@$server.ucsf.edu:/home/gannon/scripts
done

fi
