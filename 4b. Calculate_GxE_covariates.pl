# author: "Qiuyue Chen"
# date: '2023-01-04'

#Generate the GxE covariates by multiplying the top 10 PCs by each column of the 100 ECs with lowest pvalue in regression of yield on each EC.

#!/usr/bin/perl -w
use strict;

open IN, "./Prediction_Datasets/G2F_FullMarker_PC10_EC100.csv" or die;
open OUT, "+>./Prediction_Datasets/G2F_FullMarker_PC10xEC100.csv" or die;

my $head = <IN>;
chomp $head;
my @head = split /,/, $head;

my @new_head;
for(my $a=0; $a<100 ; $a++) {
	for(my $b=100; $b<$#head+1; $b++) {
		my $new_head = $head[$a] . "_" . $head[$b];
		push(@new_head, $new_head);
	}
}
my $out_head = join ",", @new_head;
print OUT "$out_head\n";


#my $n = 0;
while(<IN>) {
	chomp;
	my @aa = split /,/, $_;
	my @new = ();
	for(my $i=0; $i<100 ; $i++) {
		for(my $j=100; $j<$#aa+1; $j++) {
			my $new = $aa[$i] * $aa[$j];
			push(@new, $new);
		}
	}

	my $out = join ",", @new;
	print OUT "$out\n";

	#$n++;
	#print "$n\n";
}


