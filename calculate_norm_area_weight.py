from xspec import *
import os, argparse
from find_directory import read_file

def find_file_extension(dir_path, ext):
    res=[]
    for file in os.listdir(dir_path):
        if file.endswith(ext):
            res.append(file)
    return res

def parseArguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('region_filename', help='cfile (region name)')
    parser.add_argument('dirname', type=str, help='output directory name')
    args = parser.parse_args()
    return args

def main():
    args = parseArguments()

    cfile = args.region_filename
    cfile = cfile.split(".")[0]
    cfilename = cfile

    s1 = Spectrum(f"{cfilename}.pi")
    area = s1.backScale*(8192*0.492/60)**2; print(f"area of {cfilename} = {area} arcmin^2") 

    for file in find_file_extension(f'{args.dirname}','.total'):
        weight_total = read_file(os.path.join(f'{args.dirname}',file))[0].strip()
        print(f"total weight of {file} = {weight_total}")
        if float(weight_total) > 0:
            weight_total_final = weight_total
    
    norm = read_file(os.path.join(f'{args.dirname}','norm_error.cat'))[0].strip(); print(f"{norm}")

    with open(os.path.join(f'{args.dirname}',f"{args.dirname}_area_norm_weight.txt"), 'w') as f:
        f.write(f"area = {area}\n")
        f.write(f"{norm}\n")
        f.write(f"weight_total = {weight_total_final}\n")

    print(f"save file: {args.dirname}_area_norm_weight.txt")

if __name__ == "__main__":
    main()
