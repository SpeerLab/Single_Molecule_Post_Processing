clear;clc

arg1 = 'Y:\Chenghang\06_Testing\7.6.20.WT_P4Rev\';
local_exp =  arg1;
rel_conv_ints = '1111'; %rel_conv_ints will be used to rescale the pixel intensities for different channels.
analysisfolder = cat(2, local_exp, 'analysis/');
ISanalysisfolder = cat(2, analysisfolder, 'individual_sections/');

%folders for merged image ouput
mergeconv = cat(2, analysisfolder, 'unaligned/conv_merged/');
if exist(mergeconv,"dir") == 0
    mkdir(mergeconv);
end
mergestorm = cat(2, analysisfolder, 'unaligned/storm_merged/');
if exist(mergestorm,"dir") == 0
    mkdir(mergestorm);
end
conv488only = cat(2, analysisfolder, 'unaligned/conv_488/');
if exist(conv488only,"dir") == 0
    mkdir(conv488only);
end
mergeconv488561 = cat(2, analysisfolder, 'unaligned/storm_561_488/');
if exist(mergeconv488561,"dir") == 0
    mkdir(mergeconv488561);
end

slices = (numel(dir(fullfile(ISanalysisfolder, '0*')))-1);
% load transformation matrix
reg_pth = [local_exp 'acquisition/bead_registration/'];
load([reg_pth 'beadworkspace_region2_10x']);
%
poolobj = gcp('nocreate');
if isempty(poolobj)
    parpool(8);
else
	delete(poolobj);
	parpool(8);
end
%
parfor slice =  0:slices
    filename = [];
    filenameout = [];
    imreg = [];
    im = [];
    output = [];
% 
%     if exist(strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/750storm_',sprintf('%03d',slice),'.tif'),'file') == 2
%         disp('Images already aligned. Continue...');
%         continue;
%     end

    if exist(strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/'),'dir') ~= 7
        mkdir(strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/'));
    end

    filename.storm488 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/rawimages/for_matlab/488storm_',sprintf('%03d',slice),'.tiff');
    filename.storm561 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/rawimages/for_matlab/561storm_',sprintf('%03d',slice),'.tiff');
    filename.storm647 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/rawimages/for_matlab/647storm_',sprintf('%03d',slice),'.tiff');
    filename.storm750 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/rawimages/for_matlab/750storm_',sprintf('%03d',slice),'.tiff');
    filename.convVis488 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/rawimages/488conv_',sprintf('%02d',slice),'.tif');
    filename.convVis561 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/rawimages/561conv_',sprintf('%02d',slice),'.tif');
    filename.convVis647 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/rawimages/647conv_',sprintf('%02d',slice),'.tif');
    filename.convIR647 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/rawimages/647conv_',sprintf('%02d',slice),'.tif');
    filename.convIR750 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/rawimages/750conv_',sprintf('%02d',slice),'.tif');
    filenameout.storm488 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/488storm_',sprintf('%03d',slice),'.tif');
    filenameout.storm647 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/647storm_',sprintf('%03d',slice),'.tif');
    filenameout.storm561 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/561storm_',sprintf('%03d',slice),'.tif');
    filenameout.storm750 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/750storm_',sprintf('%03d',slice),'.tif');
    filenameout.convVis488 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/488Visconv_',sprintf('%03d',slice),'.tif');
    filenameout.convVis561 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/561Visconv_',sprintf('%03d',slice),'.tif');
    filenameout.convVis647 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/647Visconv_',sprintf('%03d',slice),'.tif');
    filenameout.convIR647 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/647IRconv_',sprintf('%03d',slice),'.tif');
    filenameout.convIR750 = strcat(ISanalysisfolder,sprintf('%04d',slice),'/aligned/750IRconv_',sprintf('%03d',slice),'.tif');
    
    filenameout.extra488merge = strcat(mergeconv488561,sprintf('%03d',slice),'.tif');
    
    % filenames for saving merged STORM, conventional, and alignment images
    filenameout.stormmerge = strcat(mergestorm,sprintf('%03d', slice),'.tif');
    filenameout.mergeconv = strcat(mergeconv,sprintf('%03d', slice),'.tif');
    filenameout.conv488only = strcat(conv488only,sprintf('%03d', slice),...
        '.tif');
    % filenameout.mergeconv488561 = strcat(mergeconv488561,...
    %     sprintf('%03d', slice),'.tif');
    
    % load data
    im.conv488 = im2double(imread(filename.convVis488));
    im.conv488 = imresize(im.conv488,10)./ str2double(rel_conv_ints(4));
    im.conv488adj = imadjust(im.conv488,stretchlim(im.conv488,[0.8 1]),[0 1]);
    
    im.conv561 = im2double(imread(filename.convVis561));
    im.conv561 = imresize(im.conv561,10)./str2double(rel_conv_ints(3));
    im.conv561adj = imadjust(im.conv561,stretchlim(im.conv561,[0 1]),[0 1]);
    
    im.conv647 = im2double(imread(filename.convVis647));
    im.conv647 = imresize(im.conv647,10)./str2double(rel_conv_ints(2));
    im.conv647adj = imadjust(im.conv647,stretchlim(im.conv647,[0 1]),[0 1]);
    
    im.convIR647 = im2double(imread(filename.convIR647));
    im.convIR647 = imresize(im.convIR647,10)./str2double(rel_conv_ints(2));
    im.convIR647adj = imadjust(im.convIR647,stretchlim(im.convIR647,[0 1]),[0 1]);
    
    im.conv750 = im2double(imread(filename.convIR750));
    im.conv750 = imresize(im.conv750,10)./str2double(rel_conv_ints(1));
    im.conv750adj = imadjust(im.conv750,stretchlim(im.conv750,[0 1]),[0 1]);
    disp(strcat('images loaded for slice # ',sprintf('%04d',slice)));
    
    if exist(filename.storm488,'file')==2
        im.storm488 = im2double(imread(filename.storm488));
    else
        im.storm488 = im.conv488adj;
        disp('storm488 is not used, loading cov488 instead');
    end
    
    if exist(filename.storm561,'file')==2
        im.storm561 = im2double(imread(filename.storm561));
    else
        im.storm561 = im.conv561adj;
        disp('storm561 is not used, loading cov561 instead');
    end
    
    if exist(filename.storm647,'file')==2 %#ok<*EXIST>
        im.storm647 = im2double(imread(filename.storm647));
    else
        im.storm647 = im.conv647adj;
        disp('storm647 is not used, loading cov647 instead');
    end
    
    if exist(filename.storm750,'file')==2
        im.storm750 = im2double(imread(filename.storm750));
    else
        im.storm750 = im.conv750adj;
        disp('storm750 is not used, loading cov750 instead');
    end
    
    %correct for storm to conv drift
    [output.storm488] = dftregistration(fft2(im.conv488adj),fft2(im.storm488),100);
    %output.storm488 = im.storm488;
    [output.storm561] = dftregistration(fft2(im.conv561adj),fft2(im.storm561),100);
    %output.storm561 = im.storm561;
    [output.storm647] = dftregistration(fft2(im.conv647adj),fft2(im.storm647),100);
    %output.storm647 = im.storm647;
    [output.storm750] = dftregistration(fft2(im.conv750adj),fft2(im.storm750),100);
    %output.storm750 = im.storm750;
    
    xform647 = [ 1  0  0
        0  1  0
        (output.storm647(4)) (output.storm647(3))  1 ];
    tform_translate647 = maketform('affine',xform647); %#ok<*MTFA1>
    imagesize = size(im.conv647);
    xdata = [1 imagesize(2)];
    ydata = [1 imagesize(1)];
    imreg.storm647 = imtransform(im.storm647, tform_translate647, 'XData',xdata,'YData',ydata);%#ok<*DIMTRNS>
    %
    xform561 = [ 1  0  0
        0  1  0
        (output.storm561(4)) (output.storm561(3))  1 ];
    tform_translate561 = maketform('affine',xform561); %#ok<*MTFA1>
    imreg.storm561 = imtransform(im.storm561, tform_translate561, 'XData',xdata,'YData',ydata);
    
    xform488 = [  1  0  0
        0  1  0
        (output.storm488(4)) (output.storm488(3))  1 ];
    tform_translate488 = maketform('affine',xform488);
    [imreg.storm488] = imtransform(im.storm488, tform_translate488, 'XData',xdata,'YData',ydata);
    
    xform750 = [  1  0  0
        0  1  0
        (output.storm750(4)) (output.storm750(3))  1 ];
    tform_translate750 = maketform('affine',xform750);
    [imreg.storm750] = imtransform(im.storm750, tform_translate750, 'XData',xdata,'YData',ydata);
    %pad images for warping
    
    [im.conv488_warp] = imtransform(im.conv488, tform_488_2_647,'XData',[1 imagesize(2)],'YData',[1 imagesize(1)]);
    [im.conv561_warp] = imtransform(im.conv561, tform_561_2_647,'XData',[1 imagesize(2)],'YData',[1 imagesize(1)]);
    [im.conv750_warp] = imtransform(im.conv750, tform_750_2_647,'XData',[1 imagesize(2)],'YData',[1 imagesize(1)]);
    
    % if exist(filename.storm488)==2
    
    [im.storm488_warp] = imtransform(imreg.storm488, tform_488_2_647,'XData',[1 imagesize(2)],'YData',[1 imagesize(1)]);
    [im.storm561_warp] = imtransform(imreg.storm561, tform_561_2_647,'XData',[1 imagesize(2)],'YData',[1 imagesize(1)]);
    [im.storm750_warp] = imtransform(imreg.storm750, tform_750_2_647,'XData',[1 imagesize(2)],'YData',[1 imagesize(1)]);
    %end
    disp(strcat('storm images #',sprintf('%04d',slice),' aligned'));
    
    %save files
    imwrite(im.conv488_warp, filenameout.convVis488);
    imwrite(im.conv561_warp, filenameout.convVis561);
    imwrite(im.conv647, filenameout.convVis647);
    imwrite(im.conv750_warp, filenameout.convIR750);
    
    %if exist(filename.storm488)==2
    imwrite(imreg.storm647, filenameout.storm647);
    imwrite(im.storm561_warp, filenameout.storm561);
    imwrite(im.storm488_warp, filenameout.storm488);
    imwrite(im.storm750_warp, filenameout.storm750);
    disp(strcat('chromatic alignment done for slice #',sprintf('%04d',slice)));
    
    
    % write out merged images (these codes might need modified for different experiment setup.)
    im.conv_rgb = cat(3, im.conv647,im.conv750_warp,im.conv561_warp);
    imwrite(im.conv_rgb, filenameout.mergeconv);
    
    im.storm_rgb = cat(3, imreg.storm647,im.storm750_warp,im.storm561_warp);
    imwrite(im.storm_rgb, filenameout.stormmerge);
    
    im.storm_extra = cat(3,imreg.storm647,im.storm750_warp,im.storm488_warp);
    imwrite(im.storm_extra,filenameout.extra488merge);
    
    imwrite(im.conv488_warp, filenameout.conv488only);
    
    %im.align561488 = imfuse(im.conv561_warp,im.conv488_warp);
    %imwrite(im.align561488, filenameout.mergeconv488561);
    fname = [strcat(ISanalysisfolder,sprintf('%04d',slice)),'/Subpix_align.mat'];
    parsave(fname,xform488,xform561,xform647,xform750);
    
end

function parsave(fname,xform488,xform561,xform647,xform750)
    save(fname,'xform488','xform561','xform647','xform750');
end