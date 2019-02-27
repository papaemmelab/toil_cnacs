#! /usr/local/perl -w
use strict;

my $max_length = $ARGV[0];
open BED, '>', $ARGV[1] || die "cannot open $!";
open LENGTH, '>', $ARGV[2] || die "cannot open $!";

my @length_array;

while (<STDIN>) {
	s/[\r\n]//g;
	if ( $_ =~ /^@/ ) {
		print $_ . "\n";
		next;
	}
	
	my @curRow = split(/\t/, $_);
	my $flag = $curRow[1];
	my @flags = reverse split(//, sprintf("%011b", $flag));
	
	next if ( $flags[1] == 0 );   # read not mapped in proper pair
	next if ( $flags[2] == 1 );   # read unmapped
	next if ( $flags[3] == 1 );   # mate unmapped
	next if ( $flags[8] == 1 );   # not primary alignment
	next if ( $flags[9] == 1 );   # read fails platform/vendor quality checks
	
	my $pair_chr = $curRow[6];
	next unless ( $pair_chr eq '=' );
	
	my $length = abs ($curRow[8]);
	next if ( $length > $max_length );
	
	my $seq = $curRow[9];
	my @bases = split(//, $seq);
	my $read_length = @bases;
	
	if ( $flags[4] == 1 ) {   # read reverse strand
		
		my $chr = $curRow[2];
		my $start = $curRow[3];
		my $pair_pos = $curRow[7];
		
		my $bed_start;
		if ( $start > $pair_pos ) {
			$bed_start = $pair_pos - 1;
		} else {
			$bed_start = $start - 1;
		}
		
		if ( $flags[10] == 0 ) {   # unique reads
			my $bed_end = $bed_start + $length;
			print BED $chr . "\t" . $bed_start . "\t" . $bed_end . "\n";
			push(@length_array, $length);
		}
		
	} else {   # mate reverse strand
		
		my $overlap = 2 * $read_length - $length;
		if ( $overlap > 0 ) {
			# mask overlapping bases between pair reads
			my $remaining = $read_length - $overlap - 1;
			if ( $remaining >= 0 ) {
				$seq = join("", @bases[ 0 .. $remaining ]) . 'N' x $overlap;
			} else {
				$seq = 'N' x $read_length;
			}
		}
		
	}
	
	print join("\t", @curRow[ 0 .. 8 ]) . "\t" . $seq . "\t" . join("\t", @curRow[ 10 .. $#curRow ]) . "\n";
}


my $percentile12_5 = int( &percentile(12.5, @length_array) );
my $first_quartile = int( &percentile(25, @length_array) );
my $percentile37_5 = int( &percentile(37.5, @length_array) );
my $median = int( &percentile(50, @length_array) );
my $percentile62_5 = int( &percentile(62.5, @length_array) );
my $third_quartile = int( &percentile(75, @length_array) );
my $percentile87_5 = int( &percentile(87.5, @length_array) );

print LENGTH $percentile12_5 . "\n" . $first_quartile . "\n" . $percentile37_5 . "\n" . $median . "\n" . $percentile62_5 . "\n" . $third_quartile . "\n" . $percentile87_5;
close(LENGTH);


sub percentile {
	my $percent = $_[0];
	my @sorted = sort { $a <=> $b } @_[ 1 .. $#_ ];
	my $idx = int( @sorted * $percent / 100 );
	my $down_dif = @sorted * $percent / 100 - $idx;
	my $up_dif = 1 - $down_dif;
	my $value = $sorted[ $idx - 1 ] * $up_dif + $sorted[ $idx ] * $down_dif;
	return $value;
}
