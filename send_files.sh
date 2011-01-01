#!/bin/sh

for server in 'webprod.pa' 'dbprod.pa' 'webalt.pa' 'dbalt.pa'; do
	rsync -ru --delete * gannon@$server.ucsf.edu:/home/gannon/scripts
done

