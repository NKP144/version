# Version

Versioning script.

# Description
Script generates project version files: Inc/version.h and Src/Version.c
Also this script generate meta_version.bin file for [EFM](https://git.big3.ru/hardware_developers/efm) module.

File version.c contains:
* Version string (formart: d.d-p-hash-[dirty] Debug/Release)
* Build date string (format: mounth day year)
* Build time string (format: hh:mm:ss)

#Versioning strategy:

d.d-p-hash-[dirty] Debug/Release

__d.d__ - git tag.

* First __d__ - major version number for releases and global changes.
* Second __d__ - minor version number for bug fixing and small canges.

__p__ - patch number after last tag.

__dirty__ - dirty mark. Means that version has uncommited changes.

__Release/Debug__ - Release/Debug mark just for print. 


# How to use:
Add this repository to target project repository as a submodule.

run script from project directory:
	
	/version/version.sh

In Debug configuration 
	
	/version/version.sh DEBUG

