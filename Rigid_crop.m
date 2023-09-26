clear;clc;
expfolder = 'Y:\Chenghang\ET33_Tigre\20230828_1\';
analysis_folder = [expfolder,'analysis\'];
hdf5_input_folder = [analysis_folder 'Rigid_hdf5\'];
hdf5_output_folder = [analysis_folder 'Rigid_crop_hdf5\'];
if exist(hdf5_output_folder,'dir') ~= 7
    mkdir(hdf5_output_folder);
end
num_images = 48;
load([expfolder '\analysis\rigid_align\rot_crop.mat']);
column_min = crop_storm(1)-1;
row_min = crop_storm(2)-1;

parfor i = 0:(num_images-1)
    channel_list = ["488","647","750"];
    disp(i);
    for j = 1:3
        hdf5_name = [char(channel_list(j)),'storm_',sprintf('%03d',i),'.hdf5'];
        for k = 0:1:9999 %iteration through all tracks
            try
                track_name = ['/tracks_' char(string(k))];
                Points_X = h5read([hdf5_input_folder,hdf5_name],[track_name '/x']); %Assume X and y represent same thing in MATLAB and python. 
                Points_Y = h5read([hdf5_input_folder,hdf5_name],[track_name '/y']);
                Points_Z = h5read([hdf5_input_folder,hdf5_name],[track_name '/z']);
                if size(Points_X,1) <= 0
                    break;
                end
                Points_X_new = Points_X - column_min;
                Points_Y_new = Points_Y - row_min;
                Points_Z_new = Points_Z;
            catch
                break;
            end
            %Write the output to hdf5 files. 
            size_hdf5 = numel(Points_X_new);
            h5create([hdf5_output_folder,hdf5_name],[track_name '/x'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_name],[track_name '/x'],Points_X_new);
            h5create([hdf5_output_folder,hdf5_name],[track_name '/y'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_name],[track_name '/y'],Points_Y_new);
            h5create([hdf5_output_folder,hdf5_name],[track_name '/z'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_name],[track_name '/z'],Points_Z_new);
        end
    end
end