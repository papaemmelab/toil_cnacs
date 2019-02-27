#! /usr/loca/bin/perl -w
use strict;

open IN1000,  '<', $ARGV[0] || die "cannot open $!";
open IN3000,  '<', $ARGV[1] || die "cannot open $!";
open IN5000,  '<', $ARGV[2] || die "cannot open $!";
open IN10000, '<', $ARGV[3] || die "cannot open $!";
open IN30000, '<', $ARGV[4] || die "cannot open $!";
open IN50000, '<', $ARGV[5] || die "cannot open $!";
open IN100000,'<', $ARGV[6] || die "cannot open $!";

print 'BIN' . "\t" . 'Total_segments' . "\t" . 'Tier1' . "\t" . 'Tier2' . "\t" . 'Tier3' . "\t" . 'Tier4' . "\t" . 'Tier5' . "\t" . 'Tier6' . "\t" . 'Tier7' . "\t" . 'Tier8' . "\t" . 'No_appropriate_SNP' . "\n";

while (<IN1000>) {
	print '1000' . "\t" . $_;
}
close(IN1000);

while (<IN3000>) {
	print '3000' . "\t" . $_;
}
close(IN3000);

while (<IN5000>) {
	print '5000' . "\t" . $_;
}
close(IN5000);

while (<IN10000>) {
	print '10000' . "\t" . $_;
}
close(IN10000);

while (<IN30000>) {
	print '30000' . "\t" . $_;
}
close(IN30000);

while (<IN50000>) {
	print '50000' . "\t" . $_;
}
close(IN50000);

while (<IN100000>) {
	print '100000' . "\t" . $_;
}
close(IN100000);
