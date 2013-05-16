#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-07-19 12:07:15 +0100 (Thu, 19 Jul 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

set -e
set -u
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

"$srcdir/paste_playlists.sh" $@
#read -p "Press enter to process with dumping of track names"
playlists_changed=""
for x in $@; do
    if hg st -A "$x" | grep -v -e "^C" | grep -q '.*'; then
        playlists_changed="$playlists_changed $x"
    fi
done
if [ -n "$playlists_changed" ]; then
    "$srcdir/dump_playlists.sh" -a $playlists_changed
fi
