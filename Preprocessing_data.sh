
################################
### Seperate data for each chromosome 

for chr in {1..22}; do \
plink --bfile DupsRemoved.genotypes --chr $chr --make-bed --out chr_bed_files/merged_dupsremoved_chr${chr}; \
done

################################
## Convert to vcf files

for chr in {1..22}; do \
plink --noweb --bfile chr_bed_files/merged_dupsremoved_chr${chr} --recode vcf --keep-allele-order --out final_vcf_files/DupsRemoved_chr${chr};\
done

## bgzip all vcf files

for chr in {1..22}; do \
sed 's/GSA-//g' DupsRemoved_chr"${chr}".vcf |bgzip >DupsRemoved_chr"${chr}".vcf.gz;\
done


########################## 
##Fix strand issue using conform-gt tool 

java -jar conform-gt.24May16.cee.jar gt=DupsRemoved_chr20.vcf.gz chrom=20 ref=1000_genomes_phase3_data/genotype_data/chr20.1kg.phase3.v5a.vcf.gz out=mod.chrom20  excludesamples=1000_genomes_phase3_data/genotype_data/non.eur.excl.txt  

##Manually update the chr2.1kg.phase3 file that has Non-unique marker ID as identified below by conform-gt

##First Error in chr2 files from 1000 genomes

Exception in thread "main" java.lang.IllegalArgumentException: Non-unique marker ID: .
2	11656437	.;rs531258135	GGTGTGTGTGTGTGT	GGTGTGTGTGTCTGT,G
2	18004148	.;rs541466601	AGAGCCCA	AGAGCCCG,A
	at conform.ConformMarkers.idMap(ConformMarkers.java:135)
	at conform.MatchedMarkers.<init>(MatchedMarkers.java:66)
	at conform.ConformMain.<init>(ConformMain.java:114)
	at conform.ConformMain.main(ConformMain.java:97)
	
##Remove the markers with non-unique marker ID
gunzip -c 1000_genomes_phase3_data/genotype_data/chr2.1kg.phase3.v5a.vcf.gz |grep -v rs531258135 |grep -v rs541466601 |bgzip >chr2.1kg.phase3.v5a_updated.vcf

## Rerun conform-gt with the updates file
java -jar conform-gt.24May16.cee.jar gt=DupsRemoved_chr2.vcf.gz chrom=2 ref=1000_genomes_phase3_data/genotype_data/chr2.1kg.phase3.v5a_updated.vcf.gz out=mod_chr2 excludesamples=1000_genomes_phase3_data/genotype_data/non.eur.excl.txt

##Second error 

Exception in thread "main" java.lang.IllegalArgumentException: Non-unique marker ID: .
2	33172927	.;rs554173463	GC	GA,G
2	40484170	.;rs537996337	AAATAAATA	AAATAAATG,A
	at conform.ConformMarkers.idMap(ConformMarkers.java:135)
	at conform.MatchedMarkers.<init>(MatchedMarkers.java:66)
	at conform.ConformMain.<init>(ConformMain.java:114)
	at conform.ConformMain.main(ConformMain.java:97)


gunzip -c 1000_genomes_phase3_data/genotype_data/chr2.1kg.phase3.v5a_updated.vcf.gz |grep -v rs554173463| grep -v rs537996337|bgzip >1000GP_Phase3/beagle_files/chr2.1kg.phase3.v5a_updated2.vcf.gz

## Third error

Exception in thread "main" java.lang.IllegalArgumentException: Non-unique marker ID: .
2	44234879	rs550419970;.;rs533534296	ATAAA	ATAAATAAA,ATAAG,A
2	45515468	.;rs544467622	CTTTTGT	CTTTTAT,C
	at conform.ConformMarkers.idMap(ConformMarkers.java:135)
	at conform.MatchedMarkers.<init>(MatchedMarkers.java:66)
	at conform.ConformMain.<init>(ConformMain.java:114)
	at conform.ConformMain.main(ConformMain.java:97)

gunzip -c 1000GP_Phase3/beagle_files/chr2.1kg.phase3.v5a_updated2.vcf.gz |grep -v rs550419970| grep -v rs544467622|bgzip >1000GP_Phase3/beagle_files/chr2.1kg.phase3.v5a_updated3.vcf.gz


######################
##Make index of vcf files using bcftools

for chr in {1..22}; do \
bcftools index mod_chr"${chr}".vcf.gz;
done


##Merge all vcf files 

 bcftools merge *vcf.gz --force-samples -Oz -o merged.vcf.gz
