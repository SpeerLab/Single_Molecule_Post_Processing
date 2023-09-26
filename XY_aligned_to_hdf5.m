clear;clc;
expfolder = 'Y:\Chenghang\ET33_Tigre\20230828_1\';
num_images = 48;
individual_section_folder = [expfolder,'analysis\individual_sections\'];
hdf5_output_folder = [expfolder,'analysis\XYaligned_hdf5\'];
if exist(hdf5_output_folder,'dir') ~= 7
    mkdir(hdf5_output_folder);
end
hdf5_folder = [expfolder,'acquisition\bins\'];
load([expfolder 'acquisition\bead_registration\beadworkspace_region2_10x']);
parfor i = 0:(num_images-1)
%parfor i = 140:143
    channel_list = ["488","647","750"];
    disp(i);
    for j = 1:3
        xform488 = load([individual_section_folder,sprintf('%04d',i),'/Subpix_align.mat'],'xform488');
        %xform561 = load([individual_section_folder,sprintf('%04d',i),'/Subpix_align.mat'],'xform561');
        xform647 = load([individual_section_folder,sprintf('%04d',i),'/Subpix_align.mat'],'xform647');
        xform750 = load([individual_section_folder,sprintf('%04d',i),'/Subpix_align.mat'],'xform750');
        Sub_pix_form = [];
        chromatic_form = [];
        switch j
            case 1
                Sub_pix_form = xform488.xform488;
                chromatic_form = tform_488_2_647;
            %case 2
                %Sub_pix_form = xform561.xform561;
                %chromatic_form = tform_561_2_647;
            case 2
                Sub_pix_form = xform647.xform647;
                chromatic_form.tdata.T = [1,0,0;0,1,0;0,0,1];
            case 3
                Sub_pix_form = xform750.xform750;
                chromatic_form = tform_750_2_647;
        end
        %Read the hdf5, apply the transformation, and write a new hdf5 file. 
        %Only x,y, and z. 
        hdf5_name = [char(channel_list(j)),'storm_',sprintf('%02d',i),'_mlist.hdf5'];
        hdf5_output_name = [char(channel_list(j)),'storm_',sprintf('%03d',i),'.hdf5'];
        for k = 0:1:9999 %iteration through all tracks
            try
                track_name = ['tracks_' char(string(k))];
                Points_X = h5read([hdf5_folder,hdf5_name],['/tracks/' track_name '/x']);
                Points_Y = h5read([hdf5_folder,hdf5_name],['/tracks/' track_name '/y']);
                Points_Z = h5read([hdf5_folder,hdf5_name],['/tracks/' track_name '/z']);
                if size(Points_X,1) <= 0
                    break;
                end
                Points_X = Points_X*10; Points_Y  = Points_Y *10; Points_Z = Points_Z+1;
                [Points_X_new,Points_Y_new] = transformPointsForward(affine2d(Sub_pix_form),Points_X,Points_Y);
                try
                    chromatic_form_use = chromatic_form.tdata.T;
                    [Points_X_new,Points_Y_new] = transformPointsForward(affine2d(chromatic_form_use),Points_X_new,Points_Y_new);
                catch
                    chromatic_form_use = chromatic_form.tdata;
                    Points_XY_new = ...
                        [ones(numel(Points_X_new),1),Points_X_new,Points_Y_new,...
                        Points_X_new.*Points_Y_new,Points_X_new.^2,Points_Y_new.^2]...
                        * chromatic_form_use(1:6,:);
                    Points_X_new = Points_XY_new(:,1);
                    Points_Y_new = Points_XY_new(:,2);
                end
                Points_Z_new = Points_Z;
            catch
                break;
            end
            %Write the output to hdf5 files. 
            size_hdf5 = numel(Points_X_new);
            h5create([hdf5_output_folder,hdf5_output_name],['/' track_name '/x'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_output_name],['/' track_name '/x'],Points_X_new);
            h5create([hdf5_output_folder,hdf5_output_name],['/' track_name '/y'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_output_name],['/' track_name '/y'],Points_Y_new);
            h5create([hdf5_output_folder,hdf5_output_name],['/' track_name '/z'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_output_name],['/' track_name '/z'],Points_Z_new);
        end
    end
end