#!/usr/bin/perl -w
#Contact:   ziyi
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
my $BEGIN_TIME=time();
my $version="1.3";
my @Times=localtime();
my $Year=$Times[5]+1900;
my $Month=$Times[4]+1;
my $Day=$Times[3];
#######################################################################################

sub USAGE {
    my $usage=<<"USAGE";
---------------------------------------------------------------------------------------------------------------------------------------
 ProgramName:	$Script
     Version:   $version
 Description:   This program is used to ANNOVAR annotation result to AIVAR input 
        Options:
	-i	<file>	input file,forced

	-o	<file>	output file,forced

	-h	help
---------------------------------------------------------------------------------------------------------------------------------------
USAGE
    print $usage;
    exit;
}

#######################################################################################
# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($infile,$outfile);

GetOptions(
                "help|?" =>\&USAGE,
                "o:s"=>\$outfile,
                "i:s"=>\$infile,
                ) or &USAGE;
&USAGE unless ($infile and $outfile);
# ------------------------------------------------------------------
# 
# ------------------------------------------------------------------
my %hash_db=(
	'Func.refGeneuniq'=>{
	 	'downstream'=>'2',
		'exonic'=>'11',
		'splicing'=>'10',
		'intergenic'=>'1',
	    	'intronic'=>'4',
	    	'ncRNA_exonic'=>'9',
	   	'ncRNA_intronic'=>'7',
	    	'ncRNA_splicing'=>'8',
	    	'splicing'=>'10',
	    	'upstream'=>'3',
	    	'UTR3'=>'5',
	    	'UTR5'=>'6',
	},
	'Func.refGene'=>{
	    	'downstream'=>'2',
		'exonic'=>'11',
		'splicing'=>'10',
		'intergenic'=>'1',
		'intronic'=>'4',
		'ncRNA_exonic'=>'9',
		'ncRNA_intronic'=>'7',
		'ncRNA_splicing'=>'8',
		'splicing'=>'10',
		'upstream'=>'3',
		'UTR3'=>'5',
		'UTR5'=>'6',
	},
	'ExonicFunc.refGeneuniq'=>{
		'frameshift deletion'=>'5',
		'frameshift insertion'=>'5',
		'frameshift substitution'=>'5',
		'nonframeshift deletion'=>'1',
		'nonframeshift insertion'=>'1',
		'nonframeshift substitution'=>'1',
		'nonsynonymous SNV'=>'6',
		'stopgain'=>'4',
		'stoploss'=>'3',
		'synonymous SNV'=>'2',
	},
	'ExonicFunc.refGene'=>{
	    	'frameshift deletion'=>'5',
		'frameshift insertion'=>'5',
		'frameshift substitution'=>'5',
		'nonframeshift deletion'=>'1',
		'nonframeshift insertion'=>'1',
		'nonframeshift substitution'=>'1',
		'nonsynonymous SNV'=>'6',
		'stopgain'=>'4',
		'stoploss'=>'3',
		'synonymous SNV'=>'2',
	},
	'1000g2015aug_all'=>{
		'1000g2015aug_all'=>'SAME',
	},
	'1000g2015aug_eas'=>{
		'1000g2015aug_eas'=>'SAME',
	},
	'1000g2015aug_afr'=>{
		'1000g2015aug_afr'=>'SAME',
	},
	'1000g2015aug_amr'=>{
		'1000g2015aug_amr'=>'SAME',
	},
	'1000g2015aug_eur'=>{
		'1000g2015aug_eur'=>'SAME',
	},
	'1000g2015aug_sas'=>{
		'1000g2015aug_sas'=>'SAME',
	},
	'HRC_AF'=>{
		'HRC_AF'=>'SAME',
	},
	'HRC_non1000G_AF'=>{
		'HRC_non1000G_AF'=>'SAME',
	},
	'cg69'=>{
		'cg69'=>'SAME',
	},
	'gnomAD_genome_ALL'=>{
		'gnomAD_genome_ALL'=>'SAME',
	},
	'gnomAD_genome_AFR'=>{
		'gnomAD_genome_AFR'=>'SAME',
	},
	'gnomAD_genome_AMR'=>{
		'gnomAD_genome_AMR'=>'SAME',
	},
	'gnomAD_genome_ASJ'=>{
		'gnomAD_genome_ASJ'=>'SAME',
	},
	'gnomAD_genome_EAS'=>{
		'gnomAD_genome_EAS'=>'SAME',
	},
	'gnomAD_genome_FIN'=>{
		'gnomAD_genome_FIN'=>'SAME',
	},
	'gnomAD_genome_NFE'=>{
		'gnomAD_genome_NFE'=>'SAME',
	},
	'gnomAD_genome_OTH'=>{
		'gnomAD_genome_OTH'=>'SAME',
	},
	'ExAC_ALL'=>{
		'ExAC_ALL'=>'SAME',
	},
	'ExAC_AFR'=>{
		'ExAC_AFR'=>'SAME',
	},
	'ExAC_AMR'=>{
		'ExAC_AMR'=>'SAME',
	},
	'ExAC_EAS'=>{
		'ExAC_EAS'=>'SAME',
	},
	'ExAC_FIN'=>{
		'ExAC_FIN'=>'SAME',
	},
	'ExAC_NFE'=>{
		'ExAC_NFE'=>'SAME',
	},
	'ExAC_OTH'=>{
		'ExAC_OTH'=>'SAME',
	},
	'ExAC_SAS'=>{
	    	'ExAC_SAS'=>'SAME',
	},
	'esp6500siv2_all'=>{
	    	'esp6500siv2_all'=>'SAME',
	},
	'esp6500siv2_aa'=>{
		'esp6500siv2_aa'=>'SAME',
	},
	'esp6500siv2_ea'=>{
	    	'esp6500siv2_ea'=>'SAME',
	},	
	'gnomAD_exome_ALL'=>{
	    	'gnomAD_exome_ALL'=>'SAME',
	},	
	'gnomAD_exome_AFR'=>{
	    	'gnomAD_exome_AFR'=>'SAME',
	},
	'gnomAD_exome_AMR'=>{
	    	'gnomAD_exome_AMR'=>'SAME',
	},
	'gnomAD_exome_ASJ'=>{
	    	'gnomAD_exome_ASJ'=>'SAME',
	},
	'gnomAD_exome_EAS'=>{
	    	'gnomAD_exome_EAS'=>'SAME',
	},
	'gnomAD_exome_FIN'=>{
	    	'gnomAD_exome_FIN'=>'SAME',
	},
	'gnomAD_exome_NFE'=>{
	    	'gnomAD_exome_NFE'=>'SAME',
	},
	'gnomAD_exome_OTH'=>{
	    	'gnomAD_exome_OTH'=>'SAME',
	},
	'gnomAD_exome_SAS'=>{
	    	'gnomAD_exome_SAS'=>'SAME',
	},
	'LRT_pred'=>{
		'N'=>'1',
		'D'=>'2',
	},
	'RadialSVM_pred'=>{
		'T'=>'1',
		'D'=>'2',
	},
	'LR_pred'=>{
		'T'=>'1',
		'D'=>'2',
	},
	'VEST3_score'=>{
		'VEST3_score'=>'SAME',
	},
	'CADD_phred'=>{
		'CADD_phred'=>'SAME',
	},
	'GERP++_RS'=>{
		'GERP++_RS'=>'SAME',
	},
	'Eigen'=>{
		'Eigen'=>'SAME',
	},
	'phyloP46way_placental'=>{
		'phyloP46way_placental'=>'SAME',
	},
	'phyloP100way_vertebrate'=>{
		'phyloP100way_vertebrate'=>'SAME',
	},
	'SiPhy_29way_logOdds'=>{
		'SiPhy_29way_logOdds'=>'SAME',
	},
	'dbscSNV_ADA_SCORE'=>{
		'dbscSNV_ADA_SCORE'=>'SAME',
	},
	'dbscSNV_RF_SCORE'=>{
		'dbscSNV_RF_SCORE'=>'SAME',
	},
	'Mutation_type'=>{
		'Deletion'=>'1',
		'Duplication'=>'2',
		'copy_number_loss'=>'1',
		'Indel'=>'4',
		'Insertion'=>'2',
		'Microsatellite'=>'4',
		'Variation'=>'4',
		'single_nucleotide_variant'=>'3',
		'Inversion'=>'4',
	},
	'avsnp147'=>{
		'avsnp147'=>'INT',
	},
	'Interpro_domain'=>{
		'Interpro_domain'=>'INT',
	},
	'tfbsConsSites'=>{
		'tfbsConsSites'=>'INT',
	},
	'gwasCatalog'=>{
		'gwasCatalog'=>'INT',
	},
	'wgRna'=>{
		'wgRna'=>'INT',
	},
	'targetScanS'=>{
		'targetScanS'=>'INT',
	}
);
##########################################
open (IN,"$Bin/database.cfg") or die $!;
my (%hash_region,%hash_ref,%hash_hotspot);
while (<IN>){
    	chomp;
	next if (/^\#|^\s*$/);
	my ($data,$file)=(split /\s+|\t/,$_);
	if (-f $file){
		open (DB,$file) or die $!;
		while(<DB>){
			chomp;
			next if (/^\#|^\s*$/);
			my @lines=split /\t|\s+/;
			if ($data eq 'RefGene'){
				$hash_ref{"$lines[12]:$lines[1]"}="$lines[8]:$lines[3]";
			}elsif($data eq 'LOF_genes'){
				$hash_hotspot{$lines[0]}=1;
#		    	}elsif($data eq 'Repeat'){
#			    	$lines[0]=~s/^chr//ig;
#				push @{$hash_region{$data}{$lines[0]}},[$lines[1],$lines[2]];
			}	
		}
		close DB;
	}else{
		print "Warning:$file does not exist!\n";
	}
}
close IN;
#foreach my $key(sort keys %hash_region){
#	foreach my $chr (sort keys %{$hash_region{$key}}){
#		@{$hash_region{$key}{$chr}}=sort {$a->[0]<=>$b->[0]||$a->[1]<=>$b->[1]}	@{$hash_region{$key}{$chr}};

#	}
#}
#####################
open (IN,$infile) or die $!;
open (OUT,">$outfile") or die $!;
my %hash_index;
while (<IN>) { 
	chomp;
	next if (/^\s*$/);
	my @lines=split /\t/,$_;
	print OUT join("\t",@lines[0..4]);
	if ($.==1){
		for(my $i=5;$i<@lines-1;$i++){
		    	next if (!exists $hash_db{$lines[$i]});
			$hash_index{$i}=$lines[$i];
			print OUT "\t$lines[$i]";
		}
#		print OUT "\tMutation_type\tGenotype\tRepeat\tFirst_Exon\tEnd_Exon\tHotspot\n";
		print OUT "\tMutation_type\tFirst_Exon\tEnd_Exon\tHotspot\n";
	}else{
		for(my $i=5;$i<@lines-1;$i++){
			if (exists $hash_index{$i}){
			   	my $out=0;
			    	foreach $a(split /\;/,$lines[$i]){
					if (exists $hash_db{$hash_index{$i}}){
					    	if (exists $hash_db{$hash_index{$i}}{$hash_index{$i}}){
						    	if ($hash_db{$hash_index{$i}}{$hash_index{$i}} eq 'SAME'){
								$out=$lines[$i];
							}elsif($hash_db{$hash_index{$i}}{$hash_index{$i}} eq 'INT' and $lines[$i] ne '.'){
								$out=1;
							}
						}elsif(exists $hash_db{$hash_index{$i}}{$a}){
							$out=$hash_db{$hash_index{$i}}{$a} if ($hash_db{$hash_index{$i}}{$a}>$out);
					    	}
					}
					$out=0 if ($out!~/^-?\d+\.?(\d+)?(e-\d+)?$/);
				}
				print OUT "\t$out";
			}
		}
		$lines[0]=~s/^chr//ig;
		my ($mutation_type,$gt,$repeat,$first_exon,$end_exon,$hotspot)=(0)x7;
		$mutation_type=&Get_Mutation_type($lines[3],$lines[4]);
#		$gt=&Get_Genotype($lines[-1]);
#		$repeat=&Get_Region($lines[0],$lines[1],"Repeat");
		if ($lines[5] eq 'exonic' and $lines[9] ne '.'){
			($first_exon,$end_exon)=&Get_Exon($lines[9]);
			$hotspot=&Get_Hotspot($lines[6]);
		}
#		print OUT "\t$mutation_type\t$gt\t$repeat\t$first_exon\t$end_exon\t$hotspot\n";
		print OUT "\t$mutation_type\t$first_exon\t$end_exon\t$hotspot\n";
	}
}

close IN;
close OUT;

#######################################################################################
print STDOUT "\nperl $Script Done. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
# ------------------------------------------------------------------
# sub function
# ------------------------------------------------------------------
################################################################################################################
sub Get_Hotspot()
{
	my $gene=shift;
	if (exists $hash_hotspot{$gene}){
		return(1);
	}else{
		return(0);
	}
}
########################
sub Get_Exon()#first_exon=1,end_exon=1
{
	my $info=shift;
	my ($gene,$tarn,$exon,$chgvs,$phgvs)=(split /\:/,$info);
	if ($gene and $tarn and exists $hash_ref{"$gene:$tarn"}){
	    	$exon=~s/exon//ig;
		my ($exon_num,$strand)=(split /\:/,$hash_ref{"$gene:$tarn"});
		if ($exon=~/wholegene/i){
			return(1,1);
		}elsif($exon==1){
		    	if ($exon_num==1){
				return(1,1);
			}else{
				return(1,0);
			}
		}elsif($exon==$exon_num){
				return(0,1);
		}else{
			return(0,0);
		}
	}else{
		return(0,0);
	}
}
#################################################
sub Get_Region() #IN=1,Not in=0
{
	my ($chr,$pos,$key)=@_;
	if (exists $hash_region{$key}{$chr}){
		my $end=$#{$hash_region{$key}{$chr}};
		my $start=0;
		while($start<$end){
			if ($pos>${$hash_region{$key}{$chr}}[$end]->[1]){
				return(0);
			}elsif($pos<${$hash_region{$key}{$chr}}[$start]->[0]){
				return(0);
			}
			my $mid=$start+int(($pos-${$hash_region{$key}{$chr}}[$start]->[0])/(${$hash_region{$key}{$chr}}[$end]->[1]-${$hash_region{$key}{$chr}}[$start]->[0])*($end-$start));
			if ($pos>=${$hash_region{$key}{$chr}}[$mid]->[0]){
				if ($pos<=${$hash_region{$key}{$chr}}[$mid]->[1]){
					return(1);	
				}else{
					$start=$mid+1;
				}
			}else{
				$end=$mid-1;
			}	
		}
		return(0);
	}else{
		return(0);
	}
}
##########################################
sub Get_Genotype()#Hom=1,Het=2,Unknow=0
{
	my $info=shift;	
    	if ($info=~/(\d+)\/(\d+)/){
		if ($1==$2){
			return(1);
		}else{
			return(2);
		}
	}else{
		return(0);
	}
}
#############################
sub Get_Mutation_type() #INS=1,DEL=2,SNV=3,Sub=4,Other=0
{
	my ($base,$alt)=@_;
	if ($base eq '-' or $alt eq '-'){
	    	if ($base eq '-'){
			return(1);
		}else{
			return(2);
		}
	}else{
		if (length($base)==length($alt)){
			if (length($base)==1){
				return(3);
			}else{
				return(4);
			}
		}else{
			return(5);
		}
	}
}
############################################################
#                             .       .
#                            / `.   .' \
#                    .---.  <    > <    >  .---.
#                    |    \  \ - ~ ~ - /  /    |
#                     ~-..-~             ~-..-~
#                 \~~~\.'                    `./~~~/
#       .-~~^-.    \__/                        \__/
#     .'  O    \     /               /       \  \
#    (_____,    `._.'               |         }  \/~~~/
#     `----.          /       }     |        /    \__/
#           `-.      |       /      |       /      `. ,~~|
#               ~-.__|      /_ - ~ ^|      /- _      `..-'   f: f:
#                    |     /        |     /     ~-.     `-. _||_||_
#                    |_____|        |_____|         ~ - . _ _ _ _ _>
#

