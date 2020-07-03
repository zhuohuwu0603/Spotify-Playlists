#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-03 17:14:30 +0100 (Fri, 03 Jul 2020)
#
#  https://github.com/harisekhon/playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC2034
usage_description="
Iterates over all playlists, showing diffs and then committing each in turn

First shows only the net additions/removals in standard Spotify URIs for a playlist
(to avoid variations in Spotify artist/track/tags from creating false positives)

Then shows the full human readable playlist diff and spotify URI diff underneath

If satisfactory, hitting enter at the end of the playlist diff will commit both
the Spotify URI and human readable playlist simultaneously

This allows quick decisions such as if there are no net differences or only additions, it's
obviously safe to just scan the human diff and commit quickly

Requires DevOps-Perl-tools to be in \$PATH for diffnet.pl
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/utils.sh"

# shellcheck disable=SC1090
. "$srcdir/bash-tools/.bash.d/git.sh"

help_usage "$@"

for playlist in $(git status --porcelain |
                  grep '^.M' |
                  awk '{print $2}' |
                  sed 's,spotify/,,' |
                  sort -u); do
    echo "Net Difference for playlist $playlist:"
    echo
    git diff "spotify/$playlist" | diffnet.pl
    echo
    read -r -p "Hit enter to see full human and spotify diffs or Control-C to cancel"
    echo
    gitu "$playlist" "spotify/$playlist"
done