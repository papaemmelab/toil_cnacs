#! /usr/local/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
my $max_length = $ARGV[1];
my $median = $ARGV[2];
my $sex = $ARGV[3];
open PAR, '<', $ARGV[4] || die "cannot open $!";

my $pos2gc = $ARGV[5] . '.txt';
my $pos2gc_1 = $ARGV[5] . '.1.txt';
my $pos2gc_2 = $ARGV[5] . '.2.txt';
my $pos2gc_3 = $ARGV[5] . '.3.txt';
my $pos2gc_4 = $ARGV[5] . '.4.txt';
my $pos2gc_5 = $ARGV[5] . '.5.txt';
my $pos2gc_6 = $ARGV[5] . '.6.txt';
my $pos2gc_7 = $ARGV[5] . '.7.txt';
my $pos2gc_8 = $ARGV[5] . '.8.txt';
my $pos2gc_9 = $ARGV[5] . '.9.txt';
my $pos2gc_10 = $ARGV[5] . '.10.txt';
my $pos2gc_11 = $ARGV[5] . '.11.txt';
my $pos2gc_12 = $ARGV[5] . '.12.txt';
my $pos2gc_13 = $ARGV[5] . '.13.txt';
my $pos2gc_14 = $ARGV[5] . '.14.txt';
my $pos2gc_15 = $ARGV[5] . '.15.txt';
my $pos2gc_16 = $ARGV[5] . '.16.txt';
my $pos2gc_17 = $ARGV[5] . '.17.txt';
my $pos2gc_18 = $ARGV[5] . '.18.txt';
my $pos2gc_19 = $ARGV[5] . '.19.txt';
my $pos2gc_20 = $ARGV[5] . '.20.txt';
my $pos2gc_21 = $ARGV[5] . '.21.txt';
my $pos2gc_22 = $ARGV[5] . '.22.txt';
my $pos2gc_23 = $ARGV[5] . '.23.txt';
open POS2GC, '>', $pos2gc || die "cannot open $!";
open POS2GC_1, '>', $pos2gc_1 || die "cannot open $!";
open POS2GC_2, '>', $pos2gc_2 || die "cannot open $!";
open POS2GC_3, '>', $pos2gc_3 || die "cannot open $!";
open POS2GC_4, '>', $pos2gc_4 || die "cannot open $!";
open POS2GC_5, '>', $pos2gc_5 || die "cannot open $!";
open POS2GC_6, '>', $pos2gc_6 || die "cannot open $!";
open POS2GC_7, '>', $pos2gc_7 || die "cannot open $!";
open POS2GC_8, '>', $pos2gc_8 || die "cannot open $!";
open POS2GC_9, '>', $pos2gc_9 || die "cannot open $!";
open POS2GC_10, '>', $pos2gc_10 || die "cannot open $!";
open POS2GC_11, '>', $pos2gc_11 || die "cannot open $!";
open POS2GC_12, '>', $pos2gc_12 || die "cannot open $!";
open POS2GC_13, '>', $pos2gc_13 || die "cannot open $!";
open POS2GC_14, '>', $pos2gc_14 || die "cannot open $!";
open POS2GC_15, '>', $pos2gc_15 || die "cannot open $!";
open POS2GC_16, '>', $pos2gc_16 || die "cannot open $!";
open POS2GC_17, '>', $pos2gc_17 || die "cannot open $!";
open POS2GC_18, '>', $pos2gc_18 || die "cannot open $!";
open POS2GC_19, '>', $pos2gc_19 || die "cannot open $!";
open POS2GC_20, '>', $pos2gc_20 || die "cannot open $!";
open POS2GC_21, '>', $pos2gc_21 || die "cannot open $!";
open POS2GC_22, '>', $pos2gc_22 || die "cannot open $!";
open POS2GC_23, '>', $pos2gc_23 || die "cannot open $!";

open GC2NUM, '>', $ARGV[6] || die "cannot open $!";


my %gc2count;

# define pseudo-autosomal regions
my @par_start;
my @par_end;
while (<PAR>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	push(@par_start, $curRow[1]);
	push(@par_end, $curRow[2]);
}
close(PAR);

while (<IN>) {
	$_ =~ s/[\r\n]//g;
	my @info = split(/;/, $_);
	my $chr = $info[0];
	$chr =~ s/^\>//;
	last if ( $chr =~ /^chr[YM]/ );
	my $bait_start = $info[1] + 1;
	my $bait_length = $info[2] - $info[1];
	
	my $chr_num = $chr;
	$chr_num =~ s/^chr//;
	if ( $chr_num eq 'X' ) {
		$chr_num = 23;
	}
	
	my $seq = <IN>;
	$seq =~ s/[\r\n]//g;
	
	my $start = $bait_start - $max_length + 1;
	my $pos1 = $max_length - $median;
	my $pos2 = $pos1 + 1;
	my $pos3 = $max_length + $bait_length - 1;
	
	foreach my $num1 ( 1 .. $pos1 ) {
		my $pos = $start + $num1 - 1;
		my $offset = $num1 + 1;  # skip first 2 bases
		my $tmp_seq = substr($seq, $offset, $median - 4);  # skip last 2 bases
		my $tmp_seq2 = $tmp_seq;
		my $gc = ( $tmp_seq =~ s/[GC]//ig );
		my $total = ( $tmp_seq2 =~ s/[ACGT]//ig );
		next if ( $total == 0 );
		my $gc_percent = int( 100 * $gc / $total );
		
		print POS2GC $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		if ( $chr_num == 1 ) {
			print POS2GC_1 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 2 ) {
			print POS2GC_2 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 3 ) {
			print POS2GC_3 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 4 ) {
			print POS2GC_4 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 5 ) {
			print POS2GC_5 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 6 ) {
			print POS2GC_6 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 7 ) {
			print POS2GC_7 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 8 ) {
			print POS2GC_8 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 9 ) {
			print POS2GC_9 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 10 ) {
			print POS2GC_10 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 11 ) {
			print POS2GC_11 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 12 ) {
			print POS2GC_12 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 13 ) {
			print POS2GC_13 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 14 ) {
			print POS2GC_14 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 15 ) {
			print POS2GC_15 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 16 ) {
			print POS2GC_16 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 17 ) {
			print POS2GC_17 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 18 ) {
			print POS2GC_18 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 19 ) {
			print POS2GC_19 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 20 ) {
			print POS2GC_20 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 21 ) {
			print POS2GC_21 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 22 ) {
			print POS2GC_22 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 23 ) {
			print POS2GC_23 $chr . ':' . $pos . "\t" . $gc_percent . "\n";
		}
	}
	
	foreach my $num2 ( $pos2 .. $pos3 ) {
		my $pos = $start + $num2 - 1;
		my $offset = $num2 + 1;  # skip fist 2 bases
		my $tmp_seq = substr($seq, $offset, $median - 4);  # skip last 2 bases
		my $tmp_seq2 = $tmp_seq;
		my $gc = ( $tmp_seq =~ s/[GC]//ig );
		my $total = ( $tmp_seq2 =~ s/[ACGT]//ig );
		next if ( $total == 0 );
		my $gc_percent = int( 100 * $gc / $total );
		
		print POS2GC '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		if ( $chr_num == 1 ) {
			print POS2GC_1 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 2 ) {
			print POS2GC_2 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 3 ) {
			print POS2GC_3 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 4 ) {
			print POS2GC_4 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 5 ) {
			print POS2GC_5 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 6 ) {
			print POS2GC_6 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 7 ) {
			print POS2GC_7 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 8 ) {
			print POS2GC_8 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 9 ) {
			print POS2GC_9 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 10 ) {
			print POS2GC_10 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 11 ) {
			print POS2GC_11 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 12 ) {
			print POS2GC_12 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 13 ) {
			print POS2GC_13 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 14 ) {
			print POS2GC_14 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 15 ) {
			print POS2GC_15 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 16 ) {
			print POS2GC_16 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 17 ) {
			print POS2GC_17 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 18 ) {
			print POS2GC_18 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 19 ) {
			print POS2GC_19 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 20 ) {
			print POS2GC_20 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 21 ) {
			print POS2GC_21 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 22 ) {
			print POS2GC_22 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		} elsif ( $chr_num == 23 ) {
			print POS2GC_23 '"' . $chr . ':' . $pos . '"' . "\t" . $gc_percent . "\n";
		}
		
		if ( ! defined $gc2count{$gc_percent} ) {
			$gc2count{$gc_percent} = 2;   # add "2" for diploid regions
		} else {
			$gc2count{$gc_percent} += 2;  # add "2" for diploid regions
		}
		
		if ( ( $chr =~ /X/ ) && ( $sex eq 'M' ) ) {
			my $par_flag = 0;
			foreach my $idx ( 0 .. $#par_start ) {
				$par_flag = 1 if ( ( $pos > $par_start[$idx] ) && ( $pos <= $par_end[$idx] ) );
			}
			$gc2count{$gc_percent} += -1 if ( $par_flag == 0 );   # consideration of a number of chrX
		}
	}
}
close(IN);

my @gc_count;
foreach my $percent ( 0 .. 100 ) {
	if ( defined $gc2count{$percent} ) {
		push(@gc_count, $gc2count{$percent});
	} else {
		push(@gc_count, "0" );
	}
}
print GC2NUM join(",", @gc_count) . "\n";
