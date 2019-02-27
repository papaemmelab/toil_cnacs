#! /usr/loca/bin/perl -w
use strict;

open IN, '<', $ARGV[0] || die "cannot open $!";
open SNP1, '<', $ARGV[1] || die "cannot open $!";
open SNP2, '<', $ARGV[2] || die "cannot open $!";
open SNP3, '<', $ARGV[3] || die "cannot open $!";
open SNP4, '<', $ARGV[4] || die "cannot open $!";
open SNP5, '<', $ARGV[5] || die "cannot open $!";
open SNP6, '<', $ARGV[6] || die "cannot open $!";
open SNP7, '<', $ARGV[7] || die "cannot open $!";
open SNP8, '<', $ARGV[8] || die "cannot open $!";
open OUT, '>', $ARGV[9] || die "cannot open $!";
open STAT, '>', $ARGV[10] || die "cannot open $!";

my %line2bin;
my %line2gene;
my %bins;
my $line = 0;
while (<IN>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $pos = join("\t", @curRow[ 0 .. 2 ]);
	$line2bin{$line} = $pos;
	$bins{$pos} = 1;
	
	my $last = $#curRow;
	if ( $last > 2 ) {
		$line2gene{$line} = $curRow[3];
	} else {
		$line2gene{$line} = 'NA';
	}
}
close(IN);

my $line_num = $line;

my %tier1;
while (<SNP1>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 2 ]);
	my $snp = join("\t", @curRow[ 3 .. 6 ]);
	next if ( defined $tier1{$key} );
	$tier1{$key} = $snp;
}
close(SNP1);

my %tier2;
while (<SNP2>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 2 ]);
	my $snp = join("\t", @curRow[ 3 .. 6 ]);
	next if ( defined $tier2{$key} );
	$tier2{$key} = $snp;
}
close(SNP2);

my %tier3;
while (<SNP3>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 2 ]);
	my $snp = join("\t", @curRow[ 3 .. 6 ]);
	next if ( defined $tier3{$key} );
	$tier3{$key} = $snp;
}
close(SNP3);

my %tier4;
while (<SNP4>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 2 ]);
	my $snp = join("\t", @curRow[ 3 .. 6 ]);
	next if ( defined $tier4{$key} );
	$tier4{$key} = $snp;
}
close(SNP4);

my %tier5;
while (<SNP5>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 2 ]);
	my $snp = join("\t", @curRow[ 3 .. 6 ]);
	next if ( defined $tier5{$key} );
	$tier5{$key} = $snp;
}
close(SNP5);

my %tier6;
while (<SNP6>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 2 ]);
	my $snp = join("\t", @curRow[ 3 .. 6 ]);
	next if ( defined $tier6{$key} );
	$tier6{$key} = $snp;
}
close(SNP6);

my %tier7;
while (<SNP7>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 2 ]);
	my $snp = join("\t", @curRow[ 3 .. 6 ]);
	next if ( defined $tier7{$key} );
	$tier7{$key} = $snp;
}
close(SNP7);

my %tier8;
while (<SNP8>) {
	$line++;
	s/[\r\n]//g;
	my @curRow = split(/\t/, $_);
	my $key = join("\t", @curRow[ 0 .. 2 ]);
	my $snp = join("\t", @curRow[ 3 .. 6 ]);
	next if ( defined $tier8{$key} );
	$tier8{$key} = $snp;
}
close(SNP8);


my $tier1_num = 0;
my $tier2_num = 0;
my $tier3_num = 0;
my $tier4_num = 0;
my $tier5_num = 0;
my $tier6_num = 0;
my $tier7_num = 0;
my $tier8_num = 0;
my $none_num = 0;

foreach my $cur_line ( 1 .. $line_num ) {
	my $bin = $line2bin{$cur_line};
	my $gene = $line2gene{$cur_line};
	if ( defined $tier1{$bin} ) {
		print OUT $tier1{$bin} . "\t" . 'tier1' . "\t" . $gene . "\n";
		$tier1_num++;
	} elsif ( defined $tier2{$bin} ) {
		print OUT $tier2{$bin} . "\t" . 'tier2' . "\t" . $gene . "\n";
		$tier2_num++;
	} elsif ( defined $tier3{$bin} ) {
		print OUT $tier3{$bin} . "\t" . 'tier3' . "\t" . $gene . "\n";
		$tier3_num++;
	} elsif ( defined $tier4{$bin} ) {
		print OUT $tier4{$bin} . "\t" . 'tier4' . "\t" . $gene . "\n";
		$tier4_num++;
	} elsif ( defined $tier5{$bin} ) {
		print OUT $tier5{$bin} . "\t" . 'tier5' . "\t" . $gene . "\n";
		$tier5_num++;
	} elsif ( defined $tier6{$bin} ) {
		print OUT $tier6{$bin} . "\t" . 'tier6' . "\t" . $gene . "\n";
		$tier6_num++;
	} elsif ( defined $tier7{$bin} ) {
		print OUT $tier7{$bin} . "\t" . 'tier7' . "\t" . $gene . "\n";
		$tier7_num++;
	} elsif ( defined $tier8{$bin} ) {
		print OUT $tier8{$bin} . "\t" . 'tier8' . "\t" . $gene . "\n";
		$tier8_num++;
	} else {
		$none_num++;
	}
}

print STAT $line_num . "\t" . $tier1_num . "\t" . $tier2_num . "\t" . $tier3_num . "\t" . $tier4_num . "\t" . $tier5_num . "\t" . $tier6_num . "\t" . $tier7_num . "\t" . $tier8_num . "\t" . $none_num . "\n";
