#! /usr/local/perl -w
use strict;

while (<STDIN>) {
    s/[\r\n]//g;
    if ( $_ =~ /^\@SQ/ ) {
		my @curRow = split(/\t/, $_);
		if ( $curRow[1] =~ /^SN:\d+/ || $curRow[1] =~ /^SN:X/ || $curRow [1] =~ /^SN:Y/ ) {
			$curRow[1] =~ s/^SN:/SN:chr/;
		} elsif ( $curRow[1] =~ /^SN:MT/ ) {
			$curRow[1] =~ s/^SN:MT/SN:chrM/;
		} else {
			my $tmp = 0;
		}
		
		print join("\t", @curRow) . "\n";
		next;
    } elsif ( $_ =~ /^\@/) {
		print $_ . "\n";
    } else {
		my @curRow = split(/\t/, $_);
		if ( $curRow[2] =~ /^\d+$/ || $curRow[2] =~ /^X$/ || $curRow[2] =~ /^Y$/ ) {
			$curRow[2] = 'chr' . $curRow[2];
		}
		if ( $curRow[2] =~ /^MT$/ ) {
			$curRow[2] = 'chrM';
		}
		print join("\t", @curRow) . "\n";
	}
}
