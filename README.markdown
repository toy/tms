# tms

Time Machine Status

View avaliable Time Machine backups and show changes

Name from [fernlightning.com](http://www.fernlightning.com/doku.php?id=software:misc:tms)

## INSTALL:

    gem install tms # use sudo if you need

## USAGE:

List backups:

    tms

Show changes for last backup (same as `tms -2 -1`):

    tms -1

Show changes between first and last backups:

    tms 1 -1

Show changes for last backup only under your user dir:

    tms -1 -f ~

List backups from another Time Machine:

    tms -d `/Volumes/Time Machine/Backups.backupdb/user name`

Show backups in progress:

    tms -i

Other options:

    tms -h

## REQUIREMENTS:

* OS X
* ruby
* Time Machine

## Copyright

Copyright (c) 2010-2019 Ivan Kuchin. See LICENSE.txt for details.
