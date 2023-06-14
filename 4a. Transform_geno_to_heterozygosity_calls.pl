# author: "Qiuyue Chen"
# date: '2023-01-04'

#!/usr/bin/perl -w
use strict;

if(@ARGV < 1) {
   print "parameter error! \n";
   print "Usage: perl Transform_geno_to_heterozygosity_calls.pl inputfile_name \n";
   exit;
}

my $file = $ARGV[0];
my $name = (split /\.txt/, $file)[0];

open IN, "$file" or die;
open OUT, "+>$name\_D.txt" or die;

#This is the Full/larger marker set (~235k)
#open IN, "./Genotype_Data_All_Years_filtered_MAF.05MR.01biallelic_numeric.txt" or die;
#open OUT, "+>./Genotype_Data_All_Years_filtered_MAF.05MR.01biallelic_numeric_D.txt" or die;

#This is the Reduced/smaller marker set (~10k)
#open IN, "./Genotype_Data_All_Years_filtered_MAF.05MR0biallelic_numeric.txt" or die;
#open OUT, "+>./Genotype_Data_All_Years_filtered_MAF.05MR0biallelic_numeric_D.txt" or die;

my $head1 = <IN>;
my $head2 = <IN>;

print OUT "$head1";
print OUT "$head2";

while(<IN>) {
	chomp;
	my ($id, $geno) = split (/\t/, $_, 2);

	#The input are numericalized genotype calls from TASSEL (0 = homoz. minor, 0.5 = het, 1 = homoz. major). 
	#Convert to heterozygosity calls.
	$geno =~ s/1/0/g;
	$geno =~ s/0\.5/1/g;
	$geno =~ s/NA/0/g;
	
	print OUT "$id\t$geno\n";
	
}
