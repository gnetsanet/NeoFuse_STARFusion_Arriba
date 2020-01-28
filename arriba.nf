process runArriba{

	memory 200.GB	

	script:
	"""
	mkdir -p /efs/Mouse_gencode_M20_CTAT_lib_Oct012019.plug-n-play/
	
	mkdir -p /efs/B16F10_RNA_FASTQS

	mkdir -p /efs/B16F10_STAR_OUT
	
	mkdir -p /efs/B16F10_ARRIBA_OUT

	cd /efs/B16F10_RNA_FASTQS

	aws s3 cp s3://bioinformatics-analysis/B16_F10/B16_F10.Tumor.RNA.MedG.R1.fastq ./
	aws s3 cp s3://bioinformatics-analysis/B16_F10/B16_F10.Tumor.RNA.MedG.R2.fastq ./

	cd /efs/Mouse_gencode_M20_CTAT_lib_Oct012019.plug-n-play/

	aws s3 cp s3://bioinformatics-analysis/Mouse_gencode_M20_CTAT_lib_Oct012019.plug-n-play/ctat_genome_lib_build_dir/ ./ctat_genome_lib_build_dir/ --recursive

	cd cd /efs/B16F10_STAR_OUT

	STAR --runThreadN 24 \
		 --runMode alignReads \
		 --genomeDir  /efs/Mouse_gencode_M20_CTAT_lib_Oct012019.plug-n-play/ctat_genome_lib_build_dir	\   
		 --readFilesIn /efs/B16F10_RNA_FASTQS/B16_F10.Tumor.RNA.MedG.R1.fastq \
		   /efs/B16F10_RNA_FASTQS/B16_F10.Tumor.RNA.MedG.R2.fastq  \
		 --outFileNamePrefix B16F10.  \
		 --genomeLoad NoSharedMemory  \
		 --outReadsUnmapped Fastx	\ 
		 --outSAMtype BAM SortedByCoordinate > B16F10.STAR.log 2>B16F10.STAR.err &

	cd /efs/B16F10_ARRIBA_OUT

	STAR --runThreadN 24 \
	--genomeDir /efs/Mouse_gencode_M20_CTAT_lib_Oct012019.plug-n-play/ctat_genome_lib_build_dir/ --genomeLoad NoSharedMemory \
	--readFilesIn /efs/B16F10_RNA_FASTQS/B16_F10.Tumor.RNA.MedG.R1.fastq /efs/B16F10_RNA_FASTQS/B16_F10.Tumor.RNA.MedG.R2.fastq \
	--outStd BAM_Unsorted --outSAMtype BAM Unsorted --outSAMunmapped Within --outBAMcompression 0 \
	--outFilterMultimapNmax 1 --outFilterMismatchNmax 3 \
	--outFileNamePrefix B16F10. \
	--chimSegmentMin 10 --chimOutType WithinBAM SoftClip --chimJunctionOverhangMin 10 --chimScoreMin 1 \
	--chimScoreDropMax 30 --chimScoreJunctionNonGTAG 0 --chimScoreSeparation 1 --alignSJstitchMismatchNmax 5 -1 5 5 \
	--chimSegmentReadGapMax 3 |
	arriba \
	-x /dev/stdin \
	-o B16F10.ARRIBA.fusions.tsv -O B16F10.ARRIBA.fusions.discarded.tsv \
	-a /efs/Mouse_gencode_M20_CTAT_lib_Oct012019.plug-n-play/ctat_genome_lib_build_dir/ref_genome.fa -g /efs/Mouse_gencode_M20_CTAT_lib_Oct012019.plug-n-play/ctat_genome_lib_build_dir/ref_annot.gtf  \
	-b blacklist.tsv \
	-T -P -i 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, X, Y \
	> B16F10.arriba.log 2>B16F10.arriba.err
	"""
}
