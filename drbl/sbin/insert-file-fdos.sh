#!/bin/bash
# Author: Steven Shiau <steven _at_ nchc org tw>
# License: GPL
REQ_FILES="$*"
fdos_img_src="/usr/lib/freedos/fdos1440.img"
img_output="fdos1440_drbl.img"
pxecfg_pd="/tftpboot/nbi_img"

USAGE="Usage: $0 files"
if [ ! "$UID" = "0" ]; then
   echo
   echo "[$LOGNAME] You need to run this script as root."
   echo
   exit 1
fi
if [ $# -eq 0 ]; then
  echo "$USAGE"
  echo "$0 FILE_OR_DIR"
  echo "Example:"
  echo "$0 ~/tmp/bios"
  echo "It will insert the file /tmp/bios to the directory \"drbl\" in the output image $img_output."
  echo "The output image \"$img_output\" will be also copied to $pxecfg_pd"
  exit 1
fi

# Find the command unix2dos
unix2dos_cmd=""
if type unix2dos &>/dev/null; then
  unix2dos_cmd=unix2dos
elif type todos &>/dev/null; then
  unix2dos_cmd=todos
fi

if [ -z "$unix2dos_cmd" ]; then
  echo "No command (e.g. unix2dos, todos) to convert UNIX plain txt file to DOS format!"
  echo "Program terminated!"
  exit 1
fi

# Check the size of the files to be inserted, it can not exceed the free space of the image
REQ_FILES_SIZE="$(LC_ALL=C du -k -c $REQ_FILES | tail -n 1 | cut -f1)"

# Prompt the $unix2dos_cmd command
echo
echo "************************************************************************"
echo "Note!!! Remeber to use the command \"$unix2dos_cmd\" to convert the batch file you want to insert, otherwise it may NOT run correctly in FreeDOS!"
echo "This program $0 will NOT do that for you!"
echo "************************************************************************"
echo

# Clean the old file
[ -f $img_output ] && rm -f $img_output
#[ -d kernel.sys ] && rm -f kernel.sys

# Process the fdos image
img_mt="$(mktemp -d fdos_img.XXXXXX)"
cp $fdos_img_src $img_output
mount -o loop $img_output $img_mt

# clean some directories... this is not necessary if we use Freedos OEM image.
[ -d "$img_mt/special" ] && rm -rf $img_mt/special
[ -d "$img_mt/testing" ] && rm -rf $img_mt/testing
[ -d "$img_mt/htmlhelp" ] && rm -rf $img_mt/htmlhelp
# [ -d "$img_mt/driver" ] && rm -rf $img_mt/driver


FREE_SIZE=`df -k $img_mt |tail -n 1|sed -e "s/ \+/ /g" |cut -d" " -f4`
if [ $REQ_FILES_SIZE -gt $FREE_SIZE ]; then
  echo "Requested files space and Free space in image (kB): $REQ_FILES_SIZE, $FREE_SIZE"
  echo "Requested files space too large, abort!" 
  exit 1
fi
mkdir -p $img_mt/drbl
echo -n "Inserting file(s) ($REQ_FILES) to the $img_output..."
cp -rf $REQ_FILES $img_mt/drbl
RETVAL="$?"
[ $RETVAL -gt 0 ] && echo "Failed to insert files to image..." && exit 1

# Not directory output the file to floppy, it's getting full...
# $unix2dos_cmd needs soem working space
cat <<-EOF >config.sys
!FILES=20
!BUFFERS=20
!LASTDRIVE=Z

;
; Freedos configuration file for system drivers
; Contents provided by Bernd Blaauw
; http://members.home.nl/bblaauw , bblnews@hotmail.com
; and by Jeremy Davis 
; http://www.fdos.org/ , jeremyd@computer.org
; Please edit to suit your needs.
MENU
MENU
MENU
MENU DRBL tool
MENU
MENU 1 - Use the files you inserted in directory DRBL
MENU    (press 0 to run Memtest86 - physical memory test program)
MENU    FreeDOS is a trademark of Jim Hall 1994-2003
MENU    ************************************************************************
MENU    This tool is written by NCHC free software labs.
MENU    Working with DRBL environment.
MENU    http://drbl.sf.net, http://drbl.nchc.org.tw
MENU    ************************************************************************
MENU
MENUDEFAULT=1,7

1?ECHO DRBL . . .
EOF

echo -n "."
#
cat <<-EOF >autoexec.bat
@echo off
set dircmd=/p /ogn
echo Welcome to FreeDOS (http://www.freedos.org)!

REM if drbl booting, skip loading CDEx, etc.
if [%config%]==[6] GOTO drbl

:drbl
echo The files you insert are in directory "drbl"
echo Changing to directory drbl...
cd drbl
GOTO END

:END
EOF

echo -n "."
# Overwrite the orininal ones...
$unix2dos_cmd config.sys
if [ "$?" -gt 0 ]; then
 echo "Failed to convert config.sys to dos format" 
 exit 1
fi
$unix2dos_cmd autoexec.bat
if [ "$?" -gt 0 ]; then
 echo "Failed to convert autoexec.bat to dos format" 
 exit 1
fi

echo -n "."
cp -f config.sys autoexec.bat $img_mt/

echo -n "."
#
umount $img_mt
echo -n "."
echo " done!"

echo
if [ -f $img_output ]; then
 echo "The extra files you insert are in the \"a:/drbl\""
 echo "The output image is created as $pxecfg_pd/$img_output,"
 cp -f $img_output $pxecfg_pd
 chmod 644 $img_output
fi

# Clean the tmp dir
[ -d "$img_mt" -a -n "$(echo $img_mt | grep "fdos_img")" ] && rm -rf $img_mt
