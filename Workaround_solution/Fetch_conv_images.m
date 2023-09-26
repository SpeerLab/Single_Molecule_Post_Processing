clear;clc;
expfolder = 'X:\Chenghang\4_Color\Raw\12.21.2020_P8EA\';
individual_section_folder = [expfolder,'analysis\individual_sections\'];
num_images = 140;
channel_list = ["488","561","647","750"];
parfor i = 0:(num_images-1)
    individual_image_folder = [individual_section_folder,sprintf('%04d',i),'\rawimages\'];
    individual_image_outfolder = [individual_section_folder,sprintf('%04d',i),'\unaligned\'];
    if exist(individual_image_outfolder,'dir') ~= 7
        mkdir(individual_image_outfolder);
    end
    for_matlab_folder = [individual_section_folder,sprintf('%04d',i),'\rawimages\for_matlab'];
    if exist("for_matlab_folder",'dir') ~= 7
        mkdir(for_matlab_folder);
    end
    for j = 1:4
        image_name = [char(channel_list(j)),'Conv_',sprintf('%03d',i),'.tif'];
        A = imread([individual_image_folder,image_name]);
        A = imresize(A,10);
        imwrite(A,[individual_image_outfolder,'Conv_',char(channel_list(j)),'.tif']);
    end
end