#!/bin/sh
# Create the pool users needed for glexec
groupadd -g 30000 lt2-cms
for user in $(seq 0 1 9);
	do useradd -b /home/grid -u 30000$user -g 30000 -m;
done;
