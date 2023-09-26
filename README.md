# Single_Molecule_Post_Processing
Apply TrakEM2 transformation to single molecule positions from STORM. 

[Old STORM image processing pipelines](https://star-protocols.cell.com/protocols/1201) were done in the image-space, where all single molecule localizations were transformed to image pixel intensity before anly image alignment/biological investigation. This method will apply all image-space transformation to the single-molecule localizations. 

Output of this pipeline is used for training data generation to produce a image resolution enhancement neural network. In the future, the single-molecule data can be used for better subcluster identification and anlaysis. 

Currently the transformation application is desigend for 4-color experiments. The repository can be packaged for processing of customized experiment design. 

Update FIJI before running! 

## Core
Run the following files in order to get elastic aligned single molecule positions: 
* (Raw HDF5 files are stored in acquisition/bins/)
* XY_aligned_to_hdf5.m
* Rigid_alignment_2_hdf5.bsh (run in FIJI)
* Rigid_crop.m
* Elastic_alignment_2_hdf5.bsh (run in FIJI)
* Elastic_crop.m (optional)
* HDF5_Image_Check.m and HDF5_Image_Check_tiles.m: check the results.

## Whole_Map_Testing
Test whether the data structure is correct. It will render a image with single-molecule localization distribution and the two images shoule match. 

## Workaround_solution
An early method to solve the problem. Raw STORM images were elastically aligned to the final images in one-step and the transformation will be applied to the raw single-molecule locations. 
