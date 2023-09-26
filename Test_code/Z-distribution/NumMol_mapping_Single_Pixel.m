clear;clc;
expfolder = 'X:\Chenghang\4_Color\Raw\12.21.2020_P8EA_B_V2\';
analysis_folder = [expfolder,'analysis\'];
hdf5_input_folder = [analysis_folder 'Elastic_crop_hdf5\'];
elastic_align_folder = [analysis_folder 'elastic_align\'];
storm_merged_folder = [elastic_align_folder 'storm_merged\'];

files = [dir([storm_merged_folder '*.tif']) dir([storm_merged_folder '*.png'])];
infos = imfinfo([storm_merged_folder files(1,1).name]);
num_images = numel(files);

channel_list = ["647","750","561"];
channel_id = 1;

section_id = 1;
hdf5_name = [char(channel_list(channel_id)),'storm_',sprintf('%03d',(section_id-1)),'.hdf5'];
hdf5_file = [hdf5_input_folder hdf5_name];
Points_X_all = [];
Points_Y_all = [];
for i = 0:1:9999 %iteration through all tracks
    try
        track_name = ['/tracks_' char(string(i))];
        Points_X = h5read([hdf5_input_folder,hdf5_name],[track_name '/x']); %Assume X and y represent same thing in MATLAB and python.
        Points_Y = h5read([hdf5_input_folder,hdf5_name],[track_name '/y']);
        if size(Points_X,1) <= 0
            break;
        end
        Points_X_all = cat(1,Points_X_all,Points_X);
        Points_Y_all = cat(1,Points_Y_all,Points_Y);
    catch
        break;
    end
end
%%
iteration_num = 100000;
image_name = [sprintf('%03d',section_id),'.tif'];
image_file = [storm_merged_folder,image_name];
A = imread(image_file);
A = A(:,:,channel_id);

Pixel_intensity = [];
Pixel_num_mol = [];

for i = 1:iteration_num
    column_id = randi(infos.Width);
    row_id = randi(infos.Height);
    if A(row_id,column_id) == 0
        continue;
    end
    Pixel_intensity = cat(1,Pixel_intensity,A(row_id,column_id));
    count_temp = 0;
    for j = 1:size(Points_X_all,1)
        if Points_X_all(j) >= (column_id-1) && ...
                Points_X_all(j) < column_id && ...
                Points_Y_all(j) >= (row_id-1) && ...
                Points_Y_all(j) < row_id
            count_temp = count_temp + 1;
        end
    end
%     if A(row_id,column_id) > 100 && count_temp == 0
%         break;
%     end
    Pixel_num_mol = cat(1,Pixel_num_mol,count_temp);
end
%%
column_range = [4970,4990];
row_range = [360,380];
figure;scatter(Points_X_all+1,Points_Y_all+1,'.');
set(gca, 'YDir','reverse');
ax = gca;
ax.XLim = column_range;
ax.YLim = row_range;
figure;imshow(A(row_range(1):row_range(2),column_range(1):column_range(2)));
axis on;
%%
figure;scatter(Points_X_all,Points_Y_all,'.');
set(gca, 'YDir','reverse');
figure;imshow(A);
axis on;
%%
figure;scatter(Pixel_intensity,Pixel_num_mol,'.');
