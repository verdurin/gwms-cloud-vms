#!/bin/sh
# Create the pool users needed for glexec
groupadd -g 30000 lt2-glexec
for user in $(seq 30000 1 30400);
	do useradd -b /home/grid -u $user -g 30000 -m lt2-glexec-$user; 
done
