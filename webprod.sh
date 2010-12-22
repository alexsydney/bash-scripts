#!/bin/sh

sudo cp -r root/* / && sudo cp webprod.pa/* / && sudo /etc/init.d/httpd restart
