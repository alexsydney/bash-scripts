#!/bin/sh

for server in 'webprod.pa' 'dbprod.pa' 'webalt.pa' 'dbalt.pa'; do
	rsync -ru * gannon@$server.ucsf.edu:/home/gannon/scripts
done

