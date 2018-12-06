# AIvar

We take advantage of machine learning to unravel the hidden characteristic signatures for benign/pathogenic variants, and present a tool for pathogenicity estimation utilizing a 2-tier (benign/likely benign, pathogenic/likely pathogenic) classification system that aims to re-classify VUS into a clinically informative category.

Dependecy
----------

* [python 3.X](https://www.python.org/downloads/)
* [perl](http://www.perl.org/get.html)

SetUp
----------

**1**.Download the AIvar package to any directory.

**2**.Dowload external tools

  python 3.x required packages: argparse,numpy,keras,h5py

  perl 5.2x:

**3**.Download database

  Required databases are deposited under the example dirctory, or use the links provided below for direct download：

  * [RefGene](https://genome.ucsc.edu/cgi-bin/hgTables)
  * [LOF genes](https://github.com/WGLab/InterVar/blob/master/intervardb/PVS1.LOF.genes.hg19)

  **Notes**: modify the file bin/database.cfg

**4**.Prepare Input Data

  The input data for AIvar is the annotated output file of the variants.Please use [ANNOVAR](http://annovar.openbioinformatics.org/en/latest/) and the relative annotation databases for variant annotations.
  
  ANNOVAR usage to generate required variant annotations for input to AIvar：
  
  **Usage**：
  
	 $ table_annovar.pl --vcfinput example.vcf database/hg19 -out example_out -buildver hg19 -remove -protocol refGene,1000g2015aug_all,1000g2015aug_eas,1000g2015aug_afr,1000g2015aug_amr,1000g2015aug_eur,1000g2015aug_sas,hrcr1,cg69,gnomad_genome,exac03,esp6500siv2_all,esp6500siv2_aa,esp6500siv2_ea,gnomad_exome,ljb26_all,intervar_20170202,dbnsfp31a_interpro,dbscsnv11,avsnp147,tfbsConsSites,wgRna,targetScanS,gwasCatalog,eigen -operation g,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,r,r,r,r,f -nastring . --onetranscript

  the annotation output file example_out.hg19_multianno.txt is the input file for AIvar
  
**5**.How to run
   
  We strongly recommend going through the example/ directory  where you can view commands and example input file formats required for running.
  
  **command-line**：

	 $ python3 AIvar.py --help

  arguments:

  -h, --help	
  	show this help message and exit

  -t TYPE, --type TYPE  

 	Please specify analysis module to be used: AIvar model generation or variant pathogenicity prediction,required

  -i INPUT, --input INPUT

  	Please specify ANNOVAR annotation results, required

  -o OUTPUT, --output OUTPUT

  	Please specify output file ,required

  -c CATEGORIZE, --categorize CATEGORIZE

  	Please specify class file containing pathogenicity classification for each variant in the training set (only required for AIvar model generation),optional

  -m MODEL, --model MODEL

  	Please specify AIvar model to be used,optional

  **Building an AIvar model**

  We have a ready-to-use model (trained already) under the directory: bin/AIvar.model_weights.h5 

  Users can also build their own AIvar model
  
  **Usage**：

	 $ python3 AIvar.py -t model -i clinvar_20180128.example.hg19_multianno.txt -o clinvar_20180128.example -c clinvar_20180128.example.clinical.txt

  -t choose type of analysis module, in this case 'model'

  -i annotation output file from ANNOVAR（see 4.Prepare Input Data）

  -o the output filename

  -c class file, a 1-column text file containing pathogenicity classification (0 for benign/likely benign and 1 for pathogenic/likely pathogenic) of each variant in the ANNOVAR output file (number of labels has to match with the number of variants); the column has a header line named '#class'
  
  class file like:

	 #class
	 0
	 1
	 0
	 0
	 1
	 1
	 0
	 0
	 0
	 1
	 1
	 0
	 1
	 ...
  
  **Using AIvar model to predict variant pathogenicity**

  **usage**：
  
	 $ python3 AIvar.py -t predict -i clinvar_20180128.example.hg19_multianno.txt -o clinvar_20180128.example -m class_20180128.example.model_weights.h5

  -t choose type of analysis module, in this case 'predict'

  -i annotation output file from ANNOVAR（see 4.Prepare Input Data）

  -o the output filename

  -m the AIvar model to be used for prediction（default：bin/AIvar.model_weights.h5）


  
  
LICENSE
----------
AIvar is free for non-commercial use without warranty.


  
