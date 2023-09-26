clear;clc;
expfolder = 'Y:\Chenghang\04_4_Color\Exp_Group\9.29.2020_B2P2A_B_V2\';
analysis_folder = [expfolder,'analysis\'];
hdf5_input_folder = [analysis_folder 'Elastic_crop_hdf5\'];
image_input_folder = [analysis_folder 'elastic_align\storm_merged\'];

Check_size = 100;
Starting_pixel = [1000,2568];
Starting_pixel_hdf5 = Starting_pixel - [1,1];
section_id = 2;
section_id_hdf5 = section_id - 1;
channels = ["647","750","561","488"];
channel = 2;

A = imread([image_input_folder sprintf('%03d',section_id) '.tif']);
A = A(:,:,channel);
A = A(Starting_pixel(1):Starting_pixel(1)+Check_size,Starting_pixel(2):Starting_pixel(2)+Check_size);

hdf5_name = [char(channels(channel)),'storm_',sprintf('%03d',section_id_hdf5),'.hdf5'];
Points_X_all = [];
Points_Y_all = [];
for k = 0:1:9999 %iteration through all tracks
    try
        track_name = ['/tracks_' char(string(k))];
        Points_X = h5read([hdf5_input_folder,hdf5_name],[track_name '/x']); %Assume X and y represent same thing in MATLAB and python.
        Points_Y = h5read([hdf5_input_folder,hdf5_name],[track_name '/y']);
        allow_id = (Points_X > Starting_pixel_hdf5(2) & Points_X <(Starting_pixel_hdf5(2) + Check_size) & Points_Y > Starting_pixel_hdf5(1) & Points_Y <(Starting_pixel_hdf5(1) + Check_size));
        Points_X = Points_X(allow_id);
        Points_Y = Points_Y(allow_id);
        Points_X = Points_X - Starting_pixel_hdf5(2);
        Points_Y = Points_Y - Starting_pixel_hdf5(1);
        Points_X_all = cat(1,Points_X_all,Points_X);
        Points_Y_all = cat(1,Points_Y_all,Points_Y);
    catch
        break;
    end
end
%%
figure;
subplot(1,2,1);
imshow(A);
subplot(1,2,2);
scatter(Points_X_all,Points_Y_all,'.');
set(gca, 'YDir','reverse')