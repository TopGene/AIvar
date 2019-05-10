#!/usr/bin/python3
#-*-coding:utf-8-*-
'''
Author:
	ziyi
Version:
        1.2
'''
import sys, os, argparse, re
import numpy as np
import subprocess
################################################################################
parser = argparse.ArgumentParser(description='AIVAR is a tool for benign/pathogenic variants, and present a tool for pathogenicity estimation utilizing a 2-tier (benign/likely benign, pathogenic/likely pathogenic) classification system that aims to re-classify VUS into a clinically informative category.')
parser.add_argument('-t','--type',help='Please specify analysis module to be used: AIVAR model generation[model] or variant pathogenicity prediction[predict],required',required=True)
parser.add_argument('-i','--input',help='Please specify ANNOVAR annotation results, required',required=True)
parser.add_argument('-o','--output',help='Please specify output file ,required',required=True)
parser.add_argument('-c','--categorize',help='Please specify class file containing pathogenicity classification for each variant in the training set (only required for AIVAR model generation),optional',required=False)
parser.add_argument('-m','--model',help='Please specify AIVAR model to be used,optional',required=False)
args = parser.parse_args()

###############################################################################
from keras.models import Sequential,load_model
from keras.layers import Dense, Dropout, Activation,Flatten
from keras.optimizers import SGD,Adam
from keras.layers import Conv2D, MaxPooling2D
from keras.utils.np_utils import to_categorical
import h5py

################################################################################
Bin=os.path.dirname(os.path.realpath(__file__))
#################################################################################
try:
	assert args.type
except AssertionError:
	print('Error: Please specify the parameter "-t"\n')
	sys.exit(1)

###############################################################################
type=args.type
infile=args.input
outfile=args.output

##############################################################################
def annovar2gnum(anno,out):
	if not os.path.exists(anno):
		print("Error: %s not exists! please check!"%(anno))
		exit(1)
	cmd="perl %s/bin/annovar2gnum_v1.3.pl -i %s -o %s  > /dev/null 2>&1"%(Bin,anno,out)
	flag=0
	#if not os.path.exists(out):  
	#	flag=os.system(cmd)
	flag=os.system(cmd)
	if (flag!=0):
		print("annovar2gnum Warning!\n")
		exit(1)

def generate_model(gnum,clin,out):

	s=open(clin)
	index=0
	for line in s:
		line.rstrip()
		if index==0:
			index+=1
			continue
		if re.search(r'^\#|^\s*$',line):
			continue
		line=int(line)
		if line==1 or line==0:
			if index == 1:
				y_train=np.array(line)
				index+=1
			else:
				y_train= np.c_[y_train,line]
				index+=1
		else:
			print("Error: clinical file informations must be 1 or 0")
			exit(1)
	s.close()

	
	s=open(gnum)
	index_new=0
	dim_count=0	
	for line in s:
		line = line.rstrip()
		if index_new==0:
			index_new+=1
			continue
		if re.search(r'^\#|^\s*$',line):
			continue
		lines = re.split(r'\s+',line)
		dim_count=len(lines)-5
		nums= lines[5:]
		nums = [float(x) for x in nums]
		if index_new==1:
			x_train = np.array(nums[:])
			index_new+=1
		else:
			x_train = np.c_[x_train,nums[:]]
			index_new+=1
	s.close()
	print("No. of features: "+str(dim_count))	
	if index != index_new:
		print("Error:The number of -i and -c rows is different!")
		exit(1)

	x_train=x_train.transpose()
	y_train=y_train.transpose()
	y_train=to_categorical(y_train, num_classes=2)
	
	model = Sequential()
	model.add(Dense(64, activation='relu', input_dim=dim_count))
	model.add(Dense(64, activation='relu'))
	model.add(Dense(64, activation='relu'))
	model.add(Dense(64, activation='relu'))
	model.add(Dropout(0.2))
	model.add(Dense(2, activation='softmax'))
	#sgd = SGD(lr=0.02, decay=1e-6, momentum=0.9, nesterov=True)
	#adam=Adam(lr=0.2)
	model.compile(loss='categorical_crossentropy',optimizer='adam', metrics=['accuracy'])
	model.fit(x_train, y_train,epochs=200,batch_size=2048)
	model.save(out)

def predict_result(model,input,output):
	model=load_model(model)	
	s=open(input)
	out=open(output,'w')
	output_score=output+'.score'
	out2=open(output_score,'w')
	index=0
	out_info={}
	for line in s:
		line = line.rstrip()
		if re.search(r'^\#|^\s*$',line):
			continue
		lines = re.split(r'\s+',line)
		if index==0:
#			out.write("\t".join(lines[:5])+"\tB/LB\tP/LP\n")
			out.write("#AIVAR\n")
			out2.write("#prob_P/LP\n")
			index+=1
			continue
		nums= lines[5:]
		nums = [float(x) for x in nums]
		if index==1:
			x_test=np.array(nums[:])
		else:
			x_test=np.c_[x_test,nums[:]]
		out_info[index]="\t".join(lines[:5])
		index+=1
	s.close()
	x_test=x_test.transpose()
	pred=model.predict(x_test)
	for k, v in enumerate(pred):
#		out.write(out_info[index]+"\t"+str(v[0])+"\t"+str(v[1])+"\n")
		if (v[1]>=0.5):
			 out.write("1\n")
		else:
			out.write("0\n")
		out2.write(str(v[1])+'\n')
	out.close()
	out2.close()

#############################################################################
out_gnum=outfile+'.gnum.txt'

if type == 'model':
	try:
		assert args.categorize
	except AssertionError:
		print('Error: Please specify the parameter -c when used: model\n')
		exit(1)
	annovar2gnum(infile,out_gnum)
	out_model=outfile+'.model_weights.h5'
	generate_model(out_gnum,args.categorize,out_model)

elif type == 'predict':
	annovar2gnum(infile,out_gnum)
	model_file=args.model
	if model_file is None:
		model_file=Bin+'/bin/AIVAR.model_weights.h5'
	elif not os.path.exists(model_file):
		print("Error: %s not exists! please check!"%(model_file))
	outfile=outfile+'.AIVAR.result.txt'
	predict_result(model_file,out_gnum,outfile)
	if not args.categorize:
		print("Done\n")
	else:
#		output1 = subprocess.getoutput("paste %s %s | perl -ane \'chomp($F[-1]);if($F[0]!=$F[1]){print }\' |wc -l"%(outfile,args.categorize))
		os.system("paste %s %s > %s "%(outfile,args.categorize,outfile+'.merge.list'))
#		output2 = subprocess.getoutput("wc -l %s"%(outfile))
#		output2=output2.split(" ")[0]
#		output1=int(output1)
#		output2=int(output2)-1
#		rate=1-output1/output2
		from collections import defaultdict
		hash = defaultdict(dict)
		hash['1']['1']=0;
		hash['0']['0']=0;
		hash['0']['1']=0;
		hash['1']['0']=0;
		st=open(outfile+'.merge.list','r')
		for line in st:
			if re.search(r'^\s*$|^\#',line):
				continue
			lines=re.split(r"\s+",line)
			if str(lines[0]) in hash.keys():
				if str(lines[1]) in hash[str(lines[0])]:
					hash[str(lines[0])][str(lines[1])]+=1
				else:
					hash[str(lines[0])][str(lines[1])]=1
			else:
				hash[str(lines[0])]={}
				hash[str(lines[0])][str(lines[1])]=1
		if((hash['1']['1']+hash['0']['1'])==0):
			sen=0
		else:
			sen=hash['1']['1']/(hash['1']['1']+hash['0']['1'])*100
		spe=hash['0']['0']/(hash['0']['0']+hash['1']['0'])*100
		ppv=hash['1']['1']/(hash['1']['1']+hash['1']['0'])*100
		npv=hash['0']['0']/(hash['0']['0']+hash['0']['1'])*100
		acc=(hash['1']['1']+hash['0']['0'])/(hash['1']['1']+hash['0']['1']+hash['0']['0']+hash['1']['0'])*100
		print('#############')
		print('#result/class\t1\t0')
		print('1\t'+str(hash['1']['1'])+'\t'+str(hash['1']['0']))
		print('0\t'+str(hash['0']['1'])+'\t'+str(hash['0']['0']))
		print('Accuracy:\t'+"%.2f"%(acc))	
		print('Sensitivity:\t'+"%.2f"%(sen))	
		print('Specificity:\t'+"%.2f"%(spe))
		print('PPV:\t'+"%.2f"%(ppv))
		print('NPV:\t'+"%.2f"%(npv))
		print('#############')
	
else:
	print("Error: -t must input: model or predict!\n")
	exit(1)


##########################################
