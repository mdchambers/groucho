#!/usr/bin/env bash
# MAnorm.sh
# Modified MAnorm script (mostly comments and to work on Hoffman cluster)
# Original: Song Lab
# Modifications: Michael Chambers, 2014
USAGE='Usage: MAnorm_hoffman.sh peak1.bed peak2.bed read1.bed read2.bed bp_shift_1 bp_shift_2
	The first 4 parameters should be input files in bed format with no header lines
	The first 2 files have ONLY 3 columns: chromosome, start, end.
	The next 2 files should have 4 columns: chromosome, start, end, strand (+/-)
	The last 2 parameters are the number of bp to be shifted for each read. These two
		parameters are found from MACS peak file *_peaks.xls after "# d =".'
source /u/local/Modules/default/init/modules.sh
module load samtools
module load bedtools
module load R

# Check if correct number of arguments
if [ $# -ne 6 ]; then
  echo "$USAGE" >&2
  exit
fi

echo "StepI: clean input" >&2
# sed removes whitespace from end of lines?
# Nope. Not sure what it does. Essentially nothing.
# awk removes reads that don't fit the criteria
# Essentially no chrM, no random chr, no reads where end is before start or start/end -lt 0
sed 's/\s$//g' $1 | awk 'BEGIN {OFS="\t"}
     {if ($1~/chr/ && $1 !="chrM" && $1 !~/random/ && $3>$2 && $2>0 && $3>0)
          print $1,$2,$3>"peak1.bed";
      else
          print $0 > "peak1_dump.bed"}'
sed 's/\s$//g' $2 | awk 'BEGIN {OFS="\t"}
     {if ($1~/chr/ && 1 !="chrM"  && $1 !~/random/ && $3>$2  && $2>0 && $3>0)
          print $1,$2,$3>"peak2.bed";
      else
          print $0 > "peak2_dump.bed"}'

# sed does nothing
# Awk does several things
# -Remove reads that chrM/random or violate bed rules (start < end or start/end < 0)
# -If read on pos strand, add length to start and end
# -If read on neg strand, subtract length from start and end
sed 's/\s$//g' $3 | awk -v var=$5 'BEGIN {OFS="\t"}
     {if ($1~/chr/ && $1 !="chrM" && $4=="+" && $1 !~/random/ && $3>$2  && $2>0 && $3>0)
          print $1,$2+var,$3+var>"read1.bed";
      else if ($1~/chr/  && $1 !="chrM" && $4=="-" && $1 !~/random/ && $3>$2  && $2>var && $3>var)
          print $1,$2-var,$3-var>"read1.bed";
      else
          print $0 > "read1_dump.bed"}'
sed 's/\s$//g' $4 | awk -v var=$6 'BEGIN {OFS="\t"}
     {if ($1~/chr/ && $1 !="chrM" && $4=="+" && $1 !~/random/ && $3>$2  && $2>0 && $3>0)
          print $1,$2+var,$3+var>"read2.bed";
      else if ($1~/chr/  && $1 !="chrM" && $4=="-" && $1 !~/random/ && $3>$2  && $2>var && $3>var)
          print $1,$2-var,$3-var>"read2.bed";
      else
          print $0 > "read2_dump.bed"}'


# Use some bedtools
echo "StepII: classify common or unique peaks"
# Report every peak from peak1 or peak2 that overlaps with the other set
# Beds are sorted by chr, then start, then end
intersectBed -a peak1.bed -b peak2.bed -u | sort -k1,1 -k2,2n -k3,3n > common_peak1.bed
intersectBed -a peak2.bed -b peak1.bed -u | sort -k1,1 -k2,2n -k3,3n > common_peak2.bed
# And report opposite (peaks that do not overlap)
intersectBed -a peak1.bed -b peak2.bed -v | sort -k1,1 -k2,2n -k3,3n > unique_peak1.bed
intersectBed -a peak2.bed -b peak1.bed -v | sort -k1,1 -k2,2n -k3,3n > unique_peak2.bed

# No idea why this is commented out. Maybe piping did not work on all systems
#cat common_peak1.bed common_peak2.bed | mergeBed -i - > common_peak.bed
# Joins common peaks into common file, overlaps are taken care of
cat common_peak1.bed common_peak2.bed > temp_common_peak.bed
mergeBed -i temp_common_peak.bed > common_peak.bed



echo "StepIII: count peak read"
if [ -f MAnorm.bed ];
then
rm MAnorm.bed
fi
coverageBed -a read1.bed -b unique_peak1.bed | sort -k1,1 -k2,2n -k3,3n  | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,"unique_peak1" >> "MAnorm.bed"; print $4 > "unique_peak1_count_read1"}'
coverageBed -a read2.bed -b unique_peak1.bed | sort -k1,1 -k2,2n -k3,3n  | awk '{print $4 > "unique_peak1_count_read2"}'
coverageBed -a read1.bed -b common_peak1.bed | sort -k1,1 -k2,2n -k3,3n  | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,"common_peak1" >> "MAnorm.bed";print $4 > "common_peak1_count_read1"}'
coverageBed -a read2.bed -b common_peak1.bed | sort -k1,1 -k2,2n -k3,3n  | awk '{print $4 > "common_peak1_count_read2"}'
coverageBed -a read1.bed -b common_peak2.bed | sort -k1,1 -k2,2n -k3,3n  | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,"common_peak2"  >> "MAnorm.bed";print $4 > "common_peak2_count_read1"}'
coverageBed -a read2.bed -b common_peak2.bed |sort -k1,1 -k2,2n -k3,3n  |  awk '{print $4 > "common_peak2_count_read2"}'
coverageBed -a read1.bed -b unique_peak2.bed | sort -k1,1 -k2,2n -k3,3n  | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,"unique_peak2">> "MAnorm.bed";print $4 > "unique_peak2_count_read1"}'
coverageBed -a read2.bed -b unique_peak2.bed | sort -k1,1 -k2,2n -k3,3n  | awk '{print $4 > "unique_peak2_count_read2"}'


cat common_peak1_count_read1 common_peak2_count_read1 > common_peak_count_read1
cat common_peak1_count_read2 common_peak2_count_read2 > common_peak_count_read2
cat unique_peak1_count_read1 common_peak1_count_read1 common_peak2_count_read1 unique_peak2_count_read1 > peak_count_read1
cat unique_peak1_count_read2 common_peak1_count_read2 common_peak2_count_read2 unique_peak2_count_read2 > peak_count_read2

if [ -f MAnorm_merge.bed ];
then
rm MAnorm_merge.bed
fi

cat  unique_peak1.bed | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,"unique_peak1" >> "MAnorm_merge.bed"}'
coverageBed -a read1.bed -b common_peak.bed | sort -k1,1 -k2,2n -k3,3n  | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,"merged_common_peak" >> "MAnorm_merge.bed"; print $4 > "merge_common_read1"}'
coverageBed -a read2.bed -b common_peak.bed | sort -k1,1 -k2,2n -k3,3n  | awk '{print $4 > "merge_common_read2"}'
cat  unique_peak2.bed | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,"unique_peak2" >> "MAnorm_merge.bed"}'

cat unique_peak1_count_read1 merge_common_read1  unique_peak2_count_read1 > merge_common_peak_count_read1
cat unique_peak1_count_read2 merge_common_read2  unique_peak2_count_read2 > merge_common_peak_count_read2




echo "SetpIV: normalize using common peaks"
#R --vanilla MAnorm.r >Rcommand.out
R CMD BATCH ~/bin/MAnorm.r Rcommand.out

awk 'BEGIN{OFS="\t"}{if($4~/1/) print $1,$2,$3,$7>"sample1_peaks.wig"}' MAnorm_result.xls
awk 'BEGIN{OFS="\t"}{if($4~/2/) print $1,$2,$3,$7>"sample2_peaks.wig"}' MAnorm_result.xls


rm temp_common_peak.bed
rm *count*
rm *read1*
rm *read2*
rm *peak1*
rm *peak2*
rm MAnorm.bed
rm MAnorm_merge.bed
rm common_peak.bed
