#python3 ../AIVAR.py -t model -i example.hg19_multianno.txt -o example -c example.class.txt

python3 ../AIVAR.py -t predict -i example.hg19_multianno.txt -o example -m example.model_weights.h5

