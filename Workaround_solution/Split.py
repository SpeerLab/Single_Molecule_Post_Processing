import os
import glob
import shutil

Base_folder = 'X:\\Chenghang\\4_Color\\Raw\\12.21.2020_P8EA\\'
Num_part_1 = 70
Base_folder = Base_folder + "analysis\\"
Dest_folder1 = Base_folder + "individual_sections_1\\"
Dest_folder2 = Base_folder + "individual_sections_2\\"

#Creat and/or read the dir name
if os.path.isdir(Dest_folder1) == False:
    os.mkdir(Dest_folder1)
if os.path.isdir(Dest_folder2) == False:
    os.mkdir(Dest_folder2)

count = 0
all_folders = glob.glob(Base_folder + "individual_sections\\*\\")
all_folders = sorted(all_folders)
for i in range(Num_part_1):
    shutil.copytree(Base_folder+"individual_sections\\" + "%04d"%(i) +"\\", Dest_folder1+ "%04d"%(i) + "\\")
    count += 1
    print(count)
for i in range(len(all_folders)-Num_part_1):
    shutil.copytree(Base_folder+"individual_sections\\" + "%04d"%(count) +"\\", Dest_folder2 + "%04d"%(i) + "\\" )
    count += 1
    print(count)