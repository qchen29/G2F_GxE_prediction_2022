# author: "Qiuyue Chen"
# date: '2023-01-03'
# I used TASSEL to filter SNPs and transform genotypes to numeric format where 0 = homozygous minor, 0.5 = heterozygous, 1 = homozygous major


# Smaller marker set: filter genotypic data by retaining bi-allelic SNPs with MAF greater than 5% and no missing data (total n=4928)
~/software/tassel-5-standalone/run_pipeline.pl -Xms10g -Xmx20g -importGuess ./Training_Data/5_Genotype_Data_All_Years.vcf -filterAlign -filterAlignMinFreq 0.05 -filterAlignMinCount 4928 -filterAlignRemMinor -NumericalGenotypePlugin -endPlugin -export Genotype_Data_All_Years_filtered_MAF.05MR0biallelic_numeric.txt -exportType ReferenceProbability


# Larger marker set: filter genotypic data by retaining bi-allelic SNPs with MAF greater than 5% and missing data lower than 1% (total n=4928)
~/software/tassel-5-standalone/run_pipeline.pl -Xms10g -Xmx20g -importGuess ./Training_Data/5_Genotype_Data_All_Years.vcf -filterAlign -filterAlignMinFreq 0.05 -filterAlignMinCount 4879 -filterAlignRemMinor -NumericalGenotypePlugin -endPlugin -export Genotype_Data_All_Years_filtered_MAF.05MR.01biallelic_numeric.txt -exportType ReferenceProbability



