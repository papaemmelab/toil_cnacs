#! /usr/local/bin/perl -w
use strict;
open IN, '<', $ARGV[0] || die "cannot open $!";
open GAIN, '>', $ARGV[1] || die "cannot open $!";
open LOSS, '>', $ARGV[2] || die "cannot open $!";

my %key2length_gain;
my %key2length_loss;
my %key2info_gain;
my %key2info_loss;

while (<IN>) {
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $id = $curRow[0];
	my $chr = $curRow[1];
	my $key = $id . "\t" . $chr;
	
	my $start = $curRow[2];
	my $end = $curRow[3];
	my $length = $end - $start;
	if ( $length < 500000 ) {
		$length = 500000;
		$end = $start + 500000;
	}
	
	my $total = $curRow[5];
	my $allelic_ratio = $curRow[6];
	next if ( $total eq 'NA' );
	
	if ( $total > 2 ){
		if ( $allelic_ratio ne 'NA' ) {
			next if ( ( $total < 2.2 ) && ( $allelic_ratio < 3 - $total  ) );  # considered to be UPD
		}
		
		if ( defined $key2length_gain{$key} ) {
			$key2length_gain{$key} += $length;
			$key2info_gain{$key} .= "\n" . $start . "\t" . $end . "\t" . $curRow[5];
		} else {
			$key2length_gain{$key} = $length;
			$key2info_gain{$key} = $start . "\t" . $end . "\t" . $curRow[5];
		}
	} else {
		if ( $allelic_ratio ne 'NA' ) {
			next if ( ( $total > 1.8 ) && ( $allelic_ratio < 1.5 * $total - 2  ) );  # considered to be UPD
		}
		
		if ( defined $key2length_loss{$key} ) {
			$key2length_loss{$key} += $length;
			$key2info_loss{$key} .= "\n" . $start . "\t" . $end . "\t" . $curRow[5];
		} else {
			$key2length_loss{$key} = $length;
			$key2info_loss{$key} = $start . "\t" . $end . "\t" . $curRow[5];
		}
	}
}
close(IN);


foreach my $cur_chr ( 1 .. 23 ) {
	my $id_gain = 0;
	my $id_loss = 0;
	foreach my $cur_key ( sort { $key2length_gain{$b} <=> $key2length_gain{$a} } keys %key2length_gain ) {
		my @cur_items = split(/\t/, $cur_key);
		next unless ( $cur_items[1] == $cur_chr );
		$id_gain++;
		
		my @cnas = split(/\n/, $key2info_gain{$cur_key});
		foreach my $cur_cna ( @cnas ) {
			my @cur_info = split(/\t/, $cur_cna);
			print GAIN $cur_chr . "\t" . $id_gain . "\t" . join("\t", @cur_info) . "\n";
		}
	}
	
	foreach my $cur_key ( sort { $key2length_loss{$a} <=> $key2length_loss{$b} } keys %key2length_loss ) {
		my @cur_items = split(/\t/, $cur_key);
		next unless ( $cur_items[1] == $cur_chr );
		$id_loss++;
		
		my @cnas = split(/\n/, $key2info_loss{$cur_key});
		foreach my $cur_cna ( @cnas ) {
			my @cur_info = split(/\t/, $cur_cna);
			print LOSS $cur_chr . "\t" . $id_loss . "\t" . join("\t", @cur_info) . "\n";
		}
	}
}
