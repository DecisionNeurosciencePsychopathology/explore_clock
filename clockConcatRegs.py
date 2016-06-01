#Quick script idea to concatenate the output of the R script for the clock tasks (EXPLORE protocol and BPD)




import sys, getopt, fileinput

#Re think this we don't want to go back and delete asterisks every time we mess up or add things...
def conCatFiles(inputfile1,inputfile2,outputfile):
	#This will be the first file, we need to add the astrisks
	with open(inputfile1, 'a') as file:
		file.write("*\t*\t*\n")
		file.close()

		#Perhaps just runs the write lines command twice with a write("*\t..") in the middle?
	filenames = [inputfile1, inputfile2]
	with open(outputfile, 'w') as outfile:
		input_lines= fileinput.input(filenames)
		outfile.writelines(input_lines)
		#for fname in filenames:
		#	with open(fname, 'r') as infile:
		#		outfile.write(infile.read())
		#		outfile.write("\n")



#It would probably work better to read in a list of ids and a list of regressor names AKA USE GLOB 


def main(argv):
   inputfile1 = ''
   inputfile2 = ''
   outputfile = ''
   try:
      opts, args = getopt.getopt(argv,"hi:j:o:",["ifile=","jfile=","ofile="])
   except getopt.GetoptError:
      print 'clockConcatRegs.py -i <inputfile> -j <inputfile> -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'clockConcatRegs.py -i <inputfile> -j <inputfile> -o <outputfile>'
         sys.exit()
      elif opt in ("-i", "--ifile"):
         inputfile1 = arg
      elif opt in ("-j", "--ii1file"):
         inputfile2 = arg
      elif opt in ("-o", "--ofile"):
         outputfile = arg
   print 'Input file one is "', inputfile1
   print 'Input file two is "', inputfile2
   print 'Output file is "', outputfile

   conCatFiles(inputfile1,inputfile2,outputfile)

if __name__ == "__main__":
   main(sys.argv[1:])



