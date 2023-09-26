0_Stormtiffs should be restored first. 
1_Fetch_conv_images: 
    Take saved conventional images in ./analysis/individual_sections/****/rawimages/. 
    Save them as *10 conventional images in: ./analysis/individual_sections/****/unaligned/
1+Storm_save: 
    Use the storm save macro in Fiji/marcor to save the Storm images. As uint16. 
2_XY_aligned_to_hdf5.m: 
    Apply 2 XY alignment to the molecule list. 
    It requries chromatic alignment information stores in ./acquistiion/bead_registration/
    It requries etch_conv_images.m output for sub_pixel alignment. 
3_split.py: 
    Split the files into two folders for ipsilateral and contralateral regions. 
4_rigid_alignment.py: 
    Apply rigid alignment on individual sections. 
5_elastic_alignment.py: 
    Apply elastic alginment on individual sections. 