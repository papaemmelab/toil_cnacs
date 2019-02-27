#! /usr/local/bin/perl -w
use strict;

### Load all BAFs including homozygous SNPs ###

open BAF, '<', $ARGV[2] || die "cannot open $!";

my %pos2baf;
while (<BAF>) {
        s/[\r\n]//g;
        my @curRow = split(/\t/, $_);
        my $chr = $curRow[0];
        my $pos = $curRow[1];
        my $key = $chr . "\t" . $pos;
        $pos2baf{$key} = $curRow[2];
}
close(BAF);

### End of loading all BAFs ###



### Load all the CNAs ###

open SEG, '<', $ARGV[1] || die "cannot open $!";
open OUT_SEG, '>', $ARGV[4] || die "cannot open $!";

my %start2end;

while (<SEG>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr_num = $curRow[1];
	my $chr = 'chr' . $chr_num;
	if ( $chr_num == 23 ) {
		$chr = 'chrX';
	} elsif ( $chr_num == 24 ) {
		$chr = 'chrY';
	}
	
	my $start = $curRow[2];
	my $end = $curRow[3];
	
	my $key = $chr . "\t" . $start;
	$start2end{$key} = $end;
	
	my $ploidy = 'NA';
	if ($curRow[5] =~ /\d/ ) {
		$ploidy = $curRow[5] + 5;
	}
	my $as = $curRow[6];
	
	$chr =~ s/^chr//;
	if ( $chr eq 'X' ) {
		$chr = 23;
	} elsif ( $chr eq 'Y' ) {
		$chr = 24;
	} elsif ( $chr =~ /[\D]/ ) {
		next;
	}
	$start = $start / 1000000;
	$end = $end / 1000000;
	
	print OUT_SEG $chr . ',' . $start . ',' . $end . ',' . $ploidy . ',' . $as . "\n";
}
close(SEG);
close(OUT_SEG);

### End of loading all the CNAs ###



### Check whether heterozygous SNPs are present in the CNA regions ###

open SIG, '<', $ARGV[0] || die "cannot open $!";
my %seg2flag;
my %seg2as;
my $seg_id = 0;
my $processing = 0;
my $cur_end;

while (<SIG>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $pos = $curRow[1];
	my $key = $chr . "\t" . $pos;
	
	if ( defined $start2end{$key} ) {
		$seg_id++;
		$seg2flag{$seg_id} = 1;
		$processing = 1;
		$cur_end = $start2end{$key};
	}
	
	my $as = $curRow[3];
	if ( $processing == 1 ) {
		$seg2flag{$seg_id} = 0 if ( ( $as ne 'NA' ) && ( $as > 0.12 ) );
		
		if ( $pos == $cur_end ) {
			$cur_end = "";
			$processing = 0;
		}
		
		if ( $as eq 'NA' ) {
			$as = $pos2baf{$key} if ( defined $pos2baf{$key} );
			next if ( ! defined $pos2baf{$key} );
		}
		
		if ( defined $seg2as{$seg_id} ) {
			$seg2as{$seg_id} .= ',' . $as;
		} else {
			$seg2as{$seg_id} = $as;
		}
	}
}
close(SIG);

### End of checking heterozygous SNPs ###



### Determine threshold of BAFs for drawing plots ###

my %seg2thresh;
foreach my $id ( keys %seg2as ) {
	my @nums = split(/,/, $seg2as{$id});
	my $median = 1;
	$median = &percentile(50, @nums) if ( @nums > 0 );
	$seg2thresh{$id} = $median;
}

### End of determining thresholds ###



### Output ###
open SIG, '<', $ARGV[0] || die "cannot open $!";
open OUT_SIG, '>', $ARGV[3] || die "cannot open $!";
$seg_id = 0;
while (<SIG>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[0];
	my $pos = $curRow[1];
	my $key = $chr . "\t" . $pos;
	if ( defined $start2end{$key} ) {
		$seg_id++;
		if ( $seg2flag{$seg_id} == 1 ) {
			$processing = 1;
			$cur_end = $start2end{$key};
		}
	}
	
	my $ploidy = $curRow[2];
	$ploidy += 5 if ( $ploidy ne 'NA' );
	
	my $as = $curRow[3];
	my $thresh = 0.12;
	if ( $processing == 1 ) {
		$thresh = $seg2thresh{$seg_id} if ( defined $seg2thresh{$seg_id} );
		$as = $pos2baf{$key} if ( defined $pos2baf{$key} );
		if ( $pos == $cur_end ) {
			$cur_end = "";
			$processing = 0;
		}
	}
	unless ( ( $as =~ /\d/ ) && ( $as > $thresh ) ) {
		$as = 'NA';
	}
	
	$chr =~ s/^chr//;
	if ( $chr eq 'X' ) {
		$chr = 23;
	} elsif ( $chr eq 'Y' ) {
		$chr = 24;
	} elsif ( $chr =~ /[\D]/ ) {
		next;
	}
	
	$pos = $pos / 1000000;
	
	print OUT_SIG $chr . ',' . $pos . ',' . $ploidy . ',' . $as . "\n";
}
close(SIG);
close(OUT_SIG);

### End of output ###


sub percentile {
	my $percent = $_[0];
	my @sorted = sort { $a <=> $b } @_[ 1 .. $#_ ];
	my $idx = int( @sorted * $percent / 100 );
	my $down_dif = @sorted * $percent / 100 - $idx;
	my $up_dif = 1 - $down_dif;
	my $value = $sorted[ $idx - 1 ] * $up_dif + $sorted[ $idx ] * $down_dif;
	return $value;
}
