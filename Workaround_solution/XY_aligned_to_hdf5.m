clear;clc;
expfolder = 'X:\Chenghang\4_Color\Raw\12.21.2020_P8EA\';
individual_section_folder = [expfolder,'analysis\individual_sections\'];
hdf5_output_folder = [expfolder,'analysis\XYalinged_hdf5\'];
if exist(hdf5_output_folder,'dir') ~= 7
    mkdir(hdf5_output_folder);
end
hdf5_folder = [expfolder,'acquisition\bins\'];
num_images = 140;
channel_list = ["488","561","647","750"];
load([expfolder 'acquisition\bead_registration\beadworkspace_region2_10x']);
parfor i = 0:(num_images-1)
    for j = 1:4
        %Read the images and generate the transformations: 
        conv_image_name = ['Conv_',char(channel_list(j)),'.tif'];
        conv_image = [individual_section_folder,sprintf('%04d',i),'\unaligned\',conv_image_name];
        B = imread(conv_image);
        storm_image_name = [char(channel_list(j)),'storm_',sprintf('%03d',i),'.tiff'];
        storm_image = [individual_section_folder,sprintf('%04d',i),'\rawimages\for_matlab\',storm_image_name];
        A = imread(storm_image);
        A = im2uint8(A);
        Sub_pix_trans = dftregistration(fft2(B),fft2(A),100);
        Sub_pix_form = [1,0,0;0,1,0;Sub_pix_trans(4),Sub_pix_trans(3),1];
        switch j
            case 1
                chromatic_form = tform_488_2_647;
            case 2
                chromatic_form = tform_561_2_647;
            case 4
                chromatic_form = tform_750_2_647;
        end
        %Read the hdf5, apply the transformation, and write a new hdf5 file. 
        %Only x,y, and z. 
        hdf5_name = [char(channel_list(j)),'storm_',sprintf('%03d',i),'_mlist.hdf5'];
        hdf5_output_name = [char(channel_list(j)),'storm_',sprintf('%03d',i),'.hdf5'];
        for k = 0:10000
            try
                track_name = ['tracks_' char(string(k))];
                Points_X = h5read([hdf5_folder,hdf5_name],['/tracks/' track_name '/x']);
                Points_Y = h5read([hdf5_folder,hdf5_name],['/tracks/' track_name '/y']);
                Points_Z = h5read([hdf5_folder,hdf5_name],['/tracks/' track_name '/z']);
                Points_X = Points_X*10; Points_Y  = Points_Y *10; Points_Z = Points_Z+1;
                [Points_X_new,Points_Y_new] = transformPointsForward(affine2d(Sub_pix_form),Points_X,Points_Y);
                try
                    chromatic_form = chromatic_form.tdata.T;
                    [Points_X_new,Points_Y_new] = transformPointsForward(affine2d(chromatic_form),Points_X_new,Points_Y_new);
                catch
                    chromatic_form = chromatic_form.tdata;
                    Points_XY_new = ...
                        [ones(numel(Points_X_new),1),Points_X_new,Points_Y_new,...
                        Points_X_new.*Points_Y_new,Points_X_new.^2,Points_Y_new.^2]...
                        * chromatic_form(1:6,:);
                end
                Points_Z_new = Points_Z;
            catch
                break;
            end
            Points_X_new = Points_XY_new(:,1);
            Points_Y_new = Points_XY_new(:,2);

            %Write the output to hdf5 files. 
            size_hdf5 = numel(Points_X_new);
            h5create([hdf5_output_folder,hdf5_output_name],['/tracks/' track_name '/x'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_output_name],['/tracks/' track_name '/x'],Points_X_new);
            h5create([hdf5_output_folder,hdf5_output_name],['/tracks/' track_name '/y'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_output_name],['/tracks/' track_name '/y'],Points_Y_new);
            h5create([hdf5_output_folder,hdf5_output_name],['/tracks/' track_name '/z'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_output_name],['/tracks/' track_name '/z'],Points_Z_new);
        end
    end
end