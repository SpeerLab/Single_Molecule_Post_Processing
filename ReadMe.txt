0_Stormtiffs should be restored first. 
1_Storm_save: 
    Use the storm save macro in Fiji/marcor to save the Storm images. As uint16. 
1_Restore_images_and_XY_trans: 
    Take saved conventional images in ./analysis/individual_sections/****/rawimages/. 
    Save them as *10 conventional images in: ./analysis/individual_sections/****/unaligned/
2_XY_aligned_to_hdf5.m: 
    Apply 2 XY alignment to the molecule list. 
    It requries chromatic alignment information stores in ./acquistiion/bead_registration/
    It requries each_conv_images.m output for sub_pixel alignment. 
    Output in folder 'XYalinged_hdf5'. 
3_Use data_clean_V2.py to clean the data into two folders if necessary. 
    It's file copy, might take a while. 
5_Run normal Z-alginment. 
6_Rigid_alignment_2_hdf5.bsh. 
7_Rigid_crop.m. 
8_Elastic_alignment_2_hdf5.bsh. 
9_Elastic_crop.m
9+_Structure_correction. 
10_Deleting files. 

Tools_HDF5_Image_Check.m: Quickly check whehter the coordinate is coorect. 
