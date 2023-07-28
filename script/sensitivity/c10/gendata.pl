#!/usr/bin/perl
#
#

use strict;
use warnings;

my $dir = 'data/';
my $i;

my $rows = 2000000;
my $num_distinct = 100;
my $rows_per_distinct = $rows / $num_distinct;
my $typ;
my $oldtyp;
my $dat;
my $oocutoff = 0.003;
my $ooprob;

print "generate plan\n";

open(FH, "> $dir/plan.dat") || die ("cannot open plan.dat: $!");

$typ = 0;
for ($i = 0; $i < $rows; $i++) {

	if ($i % $rows_per_distinct == 0) {
		$typ++;
	}

 	$oldtyp = $typ;
	$ooprob = rand(1);
    if ($ooprob < $oocutoff) {
        $dat = '2013-04-24 00:00:000';
    } else {
        $dat = '';
    }

    print FH "$i,$typ,$dat,xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n";
}
close (FH);
