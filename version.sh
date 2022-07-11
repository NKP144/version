#bin/bash

BUILD_CONFIG=$1

VER=$(git describe --tag --dirty)

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -d "$SCRIPT_DIR/Src" ]; then
		rm -r $SCRIPT_DIR/Src
fi

mkdir $SCRIPT_DIR/Src

if [ -d "$SCRIPT_DIR/Inc" ]; then
		rm -r $SCRIPT_DIR//Inc
fi

mkdir $SCRIPT_DIR/Inc

sed -e "3s/= .*/= \"$VER\";/g" $SCRIPT_DIR/Template/version.ct >> $SCRIPT_DIR/Src/version.c

cat $SCRIPT_DIR/Template/version.ht >> $SCRIPT_DIR/Inc/version.h


# Version format (git describe --tag --dirty): 

#  /-> Git tag.
# _|_
# d.d-p-hash-[dirty]
# | | | |     |
# | | | |     \-> Dirty mark. If some not commited changesd exists.
# | | | \-------> Commits hash.
# | | \---------> Patch number (commits number after last tag).
# | \-----------> Version minor number.
# \-------------> Version major number.

# Examples:
# d.d
# d.d-dirty
# d.d-p-hash
# d.d-p-hash-dirty

# Version format (little endian) for meta data:
# C.p.d.d   (0x00 0x00 0x00 0x00)
# | | | \-> Buld configuration: D-debug, R-release, d-dirty (1 byte).
# | | \---> Patch number (1 byte).
# | \-----> Version minor number (1 byte).
# \ ------> Version major number (1 byte).

#Check git tag
MAJOR=$(echo $VER | awk -F "." '{print $1}');
MINOR=$(echo $VER | awk -F "." '{print $2}' | awk -F "-" '{print $1}')
PATCH_OR_DIRTY=$(echo $VER | awk -F "-" '{print $2}')
DIRTY=
PATCH=
HASH=
if [ "$PATCH_OR_DIRTY" = "dirty" ]; then
	DIRTY=$PATCH_OR_DIRTY
else
	PATCH=$PATCH_OR_DIRTY
	HASH=$(echo $VER | awk -F "-" '{print $3}')
	DIRTY=$(echo $VER | awk -F "-" '{print $4}')
fi

#Generate binary tag for metadata

if [ -f "$SCRIPT_DIR/meta_version.bin" ]; then
	   rm $SCRIPT_DIR/meta_version.bin
fi	   

if [ "$DIRTY" = "dirty" ]; then

echo -n d | cat >> $SCRIPT_DIR/meta_version.bin		

else if [ "$BUILD_CONFIG" = "DEBUG" ]; then
		 echo -n D | cat >> $SCRIPT_DIR/meta_version.bin
 	 else
		 echo -n R | cat >> $SCRIPT_DIR/meta_version.bin	
	 fi
fi

printf "0: %.2x" $PATCH | xxd -r -g0 >> $SCRIPT_DIR/meta_version.bin
printf "0: %.2x" $MINOR | xxd -r -g0 >> $SCRIPT_DIR/meta_version.bin
printf "0: %.2x" $MAJOR | xxd -r -g0 >> $SCRIPT_DIR/meta_version.bin



echo $VER
echo Major $MAJOR
echo Minor $MINOR
echo Patch $PATCH
echo Hash $HASH
echo $DIRTY

xxd meta_version.bin
