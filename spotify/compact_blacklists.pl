#!/usr/bin/perl -T
#
#   Author: Hari Sekhon
#   Date: 2013-05-14 18:53:30 +0100 (Tue, 14 May 2013)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sts=4:et

$VERSION = "0.1";

use strict;
use warnings;
use File::Basename;

$ENV{'PATH'} = "/bin:/usr/bin";
delete $ENV{'ENV'};

my $srcdir            = dirname(__FILE__);
my $blacklistdir      = "$srcdir/blacklists";
my $blacklisttrackdir = "$srcdir/../blacklists"; 
chdir($srcdir) or die "Failed to chdir to $srcdir";

opendir my $fh, "$blacklistdir" or die "Can't opendir blacklist dir '$blacklistdir': $!\n";
my @filelist;
foreach(readdir($fh)){
    if(/^(\d+)$/){
        push(@filelist, $1);
    }
}

# Only working on number files
@filelist = sort grep { $_ =~ /^\d+$/ } @filelist;
#print "filelist:\n";
#foreach(@filelist){
#    print "$_\n";
#}

my %fileslots;

foreach(my $i=1;$i<=$filelist[-1];$i++){
    if ( -e "$blacklistdir/$i"){
        $fileslots{$i} = "1";
    }
}

foreach my $i (@filelist){
    my $next_free_slot = 0;
    my @slots = sort keys %fileslots;
    my $highest_slot = $slots[-1];
    foreach(my $j=1; $j < $highest_slot; $j++){
        ( -e "$blacklistdir/$j" ) and next;
        $next_free_slot = $j;
        last;
    }
    if($next_free_slot eq 0){
        print "Nothing to compact\n";
        exit 0;
    }
    next if ($next_free_slot ge $i);

    if ( $i ne $next_free_slot ){
        system("mv -vn '$blacklistdir/$i' '$blacklistdir/$next_free_slot'") and die "Failed to move $i => $next_free_slot";
        system("mv -vn '$blacklisttrackdir/$i' '$blacklisttrackdir/$next_free_slot'") and die "Failed to move tracks $i => $next_free_slot";
        $fileslots{$next_free_slot} = 1;
        delete $fileslots{$i};
    }
}
