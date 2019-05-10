# AIVAR

We took advantages of neural network methods and developed an in silico method, AIVAR (Artificial Intelligent VARiant classifier), which is highly comparable to human experts on known data sets.

Dependecy
----------

* [python 3.X](https://www.python.org/downloads/)
* [perl](http://www.perl.org/get.html)

SetUp
----------

**1**.Download the AIVAR package to any directory.

**2**.Dowload external tools

  python 3.x required packages: argparse,numpy,keras,h5py

  perl 5.2x:

**3**.Download database

  Required databases are deposited under the example dirctory, or use the links provided below for direct download：

  * [RefGene](https://genome.ucsc.edu/cgi-bin/hgTables)
  * [LOF genes](https://github.com/WGLab/InterVar/blob/master/intervardb/PVS1.LOF.genes.hg19)

  **Notes**: don't forget to give the paths to the above database files specified in bin/database.cfg

**4**.Prepare Input Data

  The input data for AIVAR is the annotated output file of the variants.Please use [ANNOVAR](http://annovar.openbioinformatics.org/en/latest/) and the relative annotation databases for variant annotations.
  
  ANNOVAR usage to generate required variant annotations for input to AIVAR：
  
  **Usage**：
  
	 $ table_annovar.pl --vcfinput example.vcf database/hg19 -out example_out -buildver hg19 -remove -protocol refGene,1000g2015aug_all,1000g2015aug_eas,1000g2015aug_afr,1000g2015aug_amr,1000g2015aug_eur,1000g2015aug_sas,hrcr1,cg69,gnomad_genome,exac03,esp6500siv2_all,esp6500siv2_aa,esp6500siv2_ea,gnomad_exome,ljb26_all,intervar_20170202,dbnsfp31a_interpro,dbscsnv11,avsnp147,tfbsConsSites,wgRna,targetScanS,gwasCatalog,eigen -operation g,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,r,r,r,r,f -nastring . --onetranscript

  the annotation output file example_out.hg19_multianno.txt is the input file for AIVAR
  
**5**.How to run
   
  We strongly recommend going through the example/ directory  where you can view commands and example input file formats required for running.
  
  **command-line**：

	 $ python3 AIVAR.py --help

  arguments:

  -h, --help	
  	show this help message and exit

  -t TYPE, --type TYPE  

 	Please specify analysis module to be used: AIVAR model generation or variant pathogenicity prediction,required

  -i INPUT, --input INPUT

  	Please specify ANNOVAR annotation results, required

  -o OUTPUT, --output OUTPUT

  	Please specify output file ,required

  -c CATEGORIZE, --categorize CATEGORIZE

  	Please specify class file containing pathogenicity classification for each variant in the training set (only required for AIVAR model generation),optional

  -m MODEL, --model MODEL

  	Please specify AIVAR model to be used,optional

  **Building an AIVAR model**

  We have a ready-to-use model (trained already) under the directory: bin/AIVAR.model_weights.h5 

  Users can also build their own AIVAR model
  
  **Usage**：

	 $ python3 AIVAR.py -t model -i example.hg19_multianno.txt -c example.class -o example

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
  
  **Using AIVAR model to predict variant pathogenicity**

  **usage**：
  
	 $ python3 AIVAR.py -t predict -i example.hg19_multianno.txt -o example -m example.model_weights.h5

  -t choose type of analysis module, in this case 'predict'

  -i annotation output file from ANNOVAR（see 4.Prepare Input Data）

  -o the output filename

  -m the AIVAR model to be used for prediction（default：bin/AIVAR.model_weights.h5）


  
  
LICENSE
----------
AIVAR is free for non-commercial use without warranty.


  
