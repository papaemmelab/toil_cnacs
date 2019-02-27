#! /usr/local/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
open MARKER, '<', $ARGV[1] || die "cannot open $!";
open LIST, '<', $ARGV[2] || die "cannot open #!";

my %case;
while (<LIST>) {
	s/[\r\n]//g;
	s/"//g;
	s/^s_//;
	$case{$_} = 1;
}
close(LIST);

my %chr2marker;
my $header = <MARKER>;
while (<MARKER>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $chr = $curRow[1];
	my $pos = $curRow[2];
	
	if ( defined $chr2marker{$chr} ) {
		$chr2marker{$chr} .= "\t" . $pos;
	} else {
		$chr2marker{$chr} = $pos;
	}
}
close(MARKER);


my %cna;
while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $id = $curRow[0];
	$id =~ s/"//g;
	$id =~ s/s_//g;
	my $chr = $curRow[1];
	
	my $key = $id . "\t" . $chr;
	if ( defined $cna{$key} ) {
		$cna{$key} .= "\n" . join("\t", @curRow[ 2 .. $#curRow ]);
	} else {
		$cna{$key} = join("\t", @curRow[ 2 .. $#curRow ]);
	}
}
close(IN);


foreach my $cur_id ( sort keys %case ) {
	foreach my $cur_chr ( 1 .. 23 ) {
		my $cur_key = $cur_id . "\t" . $cur_chr;
		my @markers = split(/\t/, $chr2marker{$cur_chr});
		my $probe_num = @markers;
		
		if ( defined $cna{$cur_key} ) {
			my @cnas = split(/\n/, $cna{$cur_key});
			my @starts_tmp;
			my %start2end;
			my %start2sig;
			foreach my $cur_cna ( @cnas ) {
				my @info = split(/\t/, $cur_cna);
				next if ( $info[3] eq 'NA' );
				push(@starts_tmp, $info[0]);
				$start2end{$info[0]} = $info[1];
				$start2sig{$info[0]} = log($info[3]/2) / log(2);
			}
			my @starts = sort { $a <=> $b } @starts_tmp;
			
			my $start_key;
			my $cur_region_start = 0;
			my $cur_region_length = 0;
			my $pre_pos;
			my $cna_region = 0;
			my $next_start = 1000000000000;
			$next_start = shift( @starts ) if ( @starts > 0 );
			my $next_end = 0;
			foreach my $cur_pos ( @markers ) {
				if ( $cna_region == 0 ) {
					if ( $cur_pos >= $next_start ) {
						unless ( $cur_region_start == 0 ) {
							print $cur_key . "\t". $cur_region_start . "\t" . $pre_pos . "\t" . $cur_region_length . "\t" . '0' . "\n";
						}
						
						$start_key = $next_start;
						$next_start = 1000000000000;
						$next_start = shift( @starts ) if ( @starts > 0 );
						
						$cur_region_start = $cur_pos;
						$pre_pos = $cur_pos;
						$cur_region_length = 1;
						$cna_region = 1;
						$next_end = $start2end{$start_key};
						if ( $cur_pos >= $next_end ) {
							my $signal = $start2sig{$start_key};
							print $cur_key . "\t" . $cur_region_start . "\t" . $pre_pos . "\t" . $cur_region_length . "\t" . $signal . "\n";
							
							$cur_region_start = 0;
							$cur_region_length = 0;
							$next_end = 0;
							$cna_region = 0;
						}
					} else {
						if ( $cur_region_start == 0 ) {
							$cur_region_start = $cur_pos;
						}
						$cur_region_length++;
						$pre_pos = $cur_pos;
						if ( $cur_pos == $markers[$#markers] ) {
							print $cur_key . "\t" . $cur_region_start . "\t" . $cur_pos . "\t" . $cur_region_length . "\t" . '0' . "\n";
						}
					}
				} else {
					if ( ( $cur_pos == $next_end ) || ( $cur_pos == $markers[$#markers] ) ) {
						$cur_region_length++;
						my $signal = $start2sig{$start_key};
						print $cur_key . "\t" . $cur_region_start . "\t" . $cur_pos . "\t" . $cur_region_length . "\t" . $signal . "\n";
						
						$cur_region_start = 0;
						$cur_region_length = 0;
						$next_end = 0;
						$cna_region = 0;
					} elsif ( $cur_pos > $next_end ) {
						my $signal = $start2sig{$start_key};
						print $cur_key . "\t" . $cur_region_start . "\t" . $pre_pos . "\t" . $cur_region_length . "\t" . $signal . "\n";
						
						$cur_region_start = 0;
						$cur_region_length = 1;
						$next_end = 0;
						$cna_region = 0;
					} else {
						$cur_region_length++;
					}
					$pre_pos = $cur_pos;
				}
			}
		} else {
			print $cur_key . "\t" . $markers[0] . "\t" . $markers[-1] . "\t" . $probe_num . "\t" . '0' . "\n";
		}
	}
}
close(IN);
