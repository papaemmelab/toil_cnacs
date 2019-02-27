#! /usr/local/perl -w
use strict;

my %gc2count;

foreach my $num ( 1 .. 23 ) {
	# load mapped positions
	my %pos2gc;
	
	open IN, '<', $ARGV[0] || die "cannot open $!";
	while (<IN>) {
		s/[\r\n]//g;
		my @curRow = split(/\t/, $_);
		my $chr = $curRow[0];
		my $chr_num = $chr;
		$chr_num =~ s/^chr//;
		$chr_num = 23 if ( $chr eq 'chrX' );
		last if ( $chr_num =~ /[\D]/ );
		last if ( $chr_num > $num );
		next if ( $chr_num < $num );
		
		my $start = $curRow[1] + 1;
		my $end = $curRow[2];
		
		my $key = $chr . ':' . $start;
		next if ( defined $pos2gc{$key} );
		$pos2gc{$key} = 1;
	}
	close(IN);
	
	# load %GC for mapped positions
	my $file_tag = $ARGV[1];
	my $pos2gc_file = $ARGV[1] . '.' . $num . '.txt';
	open POS2GC, '<', $pos2gc_file || die "cannot open $!";
	while (<POS2GC>) {
		s/[\r\n]//g;
		my @curRow = split(/\t/, $_);
		my $pos = $curRow[0];
		$pos =~ s/\"//g;
		next if ( ! defined $pos2gc{$pos} );
		$pos2gc{$pos} = $curRow[1];
	}
	close(POS2GC);
	
	# calculate total number of fragments of each %GC bin
	open IN, '<', $ARGV[0] || die "cannot open $!";
	while (<IN>) {
		s/[\r\n]//g;
		my @curRow = split(/\t/, $_);
		my $chr = $curRow[0];
		my $chr_num = $chr;
		$chr_num =~ s/^chr//;
		$chr_num = 23 if ( $chr eq 'chrX' );
		last if ( $chr_num =~ /[\D]/ );
		last if ( $chr_num > $num );
		next if ( $chr_num < $num );
		
		my $start = $curRow[1] + 1;
		my $end = $curRow[2];
		
		my $key = $chr . ':' . $start;
		next if ( ! defined $pos2gc{$key} );
		my $gc = $pos2gc{$key};
		
		if ( ! defined $gc2count{$gc} ) {
			$gc2count{$gc} = 1;
		} else {
			$gc2count{$gc}++;
		}
	}
	close(IN);
}


# load total number of mappable positions of each %GC bin
open GC2NUM, '<', $ARGV[2] || die "cannot open $!";

my @gc2num;
while (<GC2NUM>) {
	s/[\r\n]//g;
	@gc2num = split(/,/, $_);
}
close(GC2NUM);


# load total number of positions of each %GC bin
# calculate rate of fragments mapped to each %GC bin
my %gc2rate;
foreach my $tmp_gc ( 0 .. 100 ) {
	my $pos_num = $gc2num[$tmp_gc];
	if ( $pos_num == 0 ) {
		if ( ! defined $gc2count{$tmp_gc} ) {
			print $tmp_gc . "\t" . '0' . "\t" . '0' . "\t" . 'NA' . "\n";
		} else {
			print $tmp_gc . "\t" . $gc2count{$tmp_gc} . "\t" . '0' . "\t" . 'NA' . "\n";
		}
	} else {
		if ( ! defined $gc2count{$tmp_gc} ) {
			print $tmp_gc . "\t" . '0' . "\t" . $pos_num . "\t" . '0' . "\n";
		} else {
			$gc2rate{$tmp_gc} = $gc2count{$tmp_gc} / $pos_num;
			print $tmp_gc . "\t" . $gc2count{$tmp_gc} . "\t" . $pos_num . "\t" . $gc2rate{$tmp_gc} . "\n";
		}
	}
}
