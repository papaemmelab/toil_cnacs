#! /usr/local/bin/perl -w
use strict;

my @files = @ARGV;
my @coef1;
my @coef2;
my @coef3;
my @coef4;

foreach my $file ( @files ) {
	open IN, '<', $file || die "cannot open $!";
	my $coef1;
	my $coef2;
	my $coef3;
	my $coef4;
	my $line = 0;
	my $flag = 0;
	my $std;
	while (<IN>) {
		$line++;
		s/[\r\n]//g;
		if ( $_ eq 'NA' ) {
			$flag = 1;
			last;
		}
		if ( $_ == 0 ) {
			$flag = 1;
			last;
		}
		
		if ( $line == 1 ) {
			$std = $_;
			$coef1 = 1;
		} elsif ( $line == 2 ) {
			$coef2 = $_ / $std;
		} elsif ( $line == 3 ) {
			$coef3 = $_ / $std;
		} elsif ( $line == 4 ) {
			$coef4 = $_ / $std;
		}
	}
	close(IN);
	
	if ( $flag == 0 ) {
		push(@coef1, $coef1);
		push(@coef2, $coef2);
		push(@coef3, $coef3);
		push(@coef4, $coef4);
	}
}

print join(",", @coef1) . "\n";
print join(",", @coef2) . "\n";
print join(",", @coef3) . "\n";
print join(",", @coef4) . "\n";
