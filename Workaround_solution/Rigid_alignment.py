import os, re, time
import glob
from ini.trakem2 import ControlWindow, Project
from ini.trakem2.display import Display, Patch, LayerSet
from java.awt import Color
from ij import IJ  
import math
from ij.process import ImageStatistics as IS
from ij import Prefs
from ij import ImagePlus

exp_folder = r"X:/Chenghang/4_Color/Raw/12.21.2020_P8EA/"
target_folder = r"X:/Chenghang/Backup_Raw_Data/12.21.2020_P8EA_A/"
im_width = 6400
im_height = 6400

print exp_folder
IJ.run("Memory & Threads...", "maximum=300000 parallel=24 run");

individual_folder = exp_folder + "analysis/individual_sections_1/"
all_folders = glob.glob(individual_folder + "*/")
all_folders = sorted(all_folders)
num_images = len(all_folders)

ControlWindow.setGUIEnabled(False)

for i in range(num_images):
    print i
    # 1. Create a TrakEM2 project
    out_folder = all_folders[i] + r"rigid_aligned/"
    if not os.path.exists(out_folder):
        os.mkdir(out_folder)
    project = Project.newFSProject("blank", None, out_folder)
    loader = project.getLoader()
    loader.setMipMapsRegeneration(False) # disable mipmaps
    layerset = project.getRootLayerSet()
    #  2. Create 2 layers (or as many as you need)
    layerset.getLayer(1, 1, True)
    layerset.setDimensions(im_width,im_height,LayerSet.NORTHWEST)
    layerset.getLayer(2, 1, True)
    layerset.setDimensions(im_width,im_height,LayerSet.NORTHWEST)
    # ... and update the LayerTree:
    project.getLayerTree().updateList(layerset)
    # ... and the display slider
    Display.updateLayerScroller(layerset)

    filename1 = "%03d"%(i+1) + ".tif"
    filename2 = "Conv_488.tif"
    
    #3 Load in images
    for j,layer in enumerate(layerset.getLayers()):
        if j == 0:
            filepath = all_final_images + filename1
            patch = Patch.createPatch(project, filepath)
            layer.add(patch, False)
        else:
            filepath = all_folders[i] + r"unaligned/" + filename2
            patch = Patch.createPatch(project, filepath)
            layer.add(patch, False)
 
    Display.update(layer);  

    from mpicbg.trakem2.align import Align, AlignTask

    Align.alignLayersLinearly(layerset.getLayers(),1) #rigid alignment


    # 5. Resize width and height of the world to fit the montages
    layerset.setMinimumDimensions()

    project.saveAs(project.getLoader().getStorageFolder() + "rigid.xml", True); # overwriting any existing xml file with that name  

    #write the aligned image_pre aligned
    layer = layerset.getLayers().get(0)
    rectangle = layerset.get2DBounds()
    backgroundColor = Color.black

    patch = layer.getAll(Patch)
    scale = 1
    name = patch[0].getImageFilePath() 
    basename = os.path.basename(name)
    ip = Patch.makeFlatImage(ImagePlus.COLOR_RGB,layer,rectangle,scale,patch,backgroundColor,True)
    imp = ImagePlus("img", ip)
    imp2 = imp.flatten()
    IJ.saveAs(imp2, "PNG", (out_folder + "pre_aligned" + ".png"))
    
    #Write image_post-aligned
    layer = layerset.getLayers().get(1)
    rectangle = layerset.get2DBounds()
    backgroundColor = Color.black

    patch = layer.getAll(Patch)
    scale = 1
    name = patch[0].getImageFilePath() 
    basename = os.path.basename(name)
    ip = Patch.makeFlatImage(ImagePlus.COLOR_RGB,layer,rectangle,scale,patch,backgroundColor,True)
    imp = ImagePlus("img", ip)
    imp2 = imp.flatten()
    IJ.saveAs(imp2, "PNG", (out_folder + "post_aligned" + ".png"))

print("Done")
IJ.run("Quit")	

