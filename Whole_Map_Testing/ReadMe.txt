T_to_single_point.py: 
1. import the transformation from xml file. 
2. apply it to a point [10.0,10.0]. 
It's working! 

10_14_20_TrakEM2_localization_warp.bsh: 
Shared from Colenso and Stephan. It can apply current transformation (in opened TrakEM2 project) to a hdf5 file. 
10_14_20_TrakEM2_localization_warp_ReadXML_test.bsh: 
Modified from the script above. It reads a transformation from XML and applies it to a hdf5. 
The hdf5 and transofrmation are not carefully pre-aligned. It's just for a test and check how long it will take. 