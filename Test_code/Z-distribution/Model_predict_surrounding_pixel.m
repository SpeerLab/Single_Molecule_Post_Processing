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
iteration_num = 1000000;
image_name = [sprintf('%03d',section_id),'.tif'];
image_file = [storm_merged_folder,image_name];
A = imread(image_file);
A = A(:,:,channel_id);

Pixel_intensity_0 = [];
Pixel_intensity_1 = [];
Pixel_intensity_2 = [];
Pixel_num_mol_0 = [];
Pixel_num_mol_1 = [];
Pixel_num_mol_2 = [];
Pixel_currpix_0 = [];
Pixel_currpix_1 = [];
Pixel_currpix_2 = [];
Pixel_currpix_3 = [];

for i = 1:iteration_num
    if mod(i,10000) == 0
        disp(['Processing ' char(string(i/iteration_num*100)) '%']);
    end
    column_id = randi(infos.Width); %Iterate throught columns
    row_id = randi(infos.Height);
    if A(row_id,column_id) == 0
        continue;
    end
    if column_id <5 || column_id > (infos.Width-7)
        continue;
    end
    if row_id <2 || row_id > (infos.Height-1)
        continue;
    end

    row_weight = 1;

    Pixel_intensity_0_temp = sum(A((row_id - 1),(column_id-4):(column_id-1))) * row_weight + ...
        sum(A(row_id,(column_id-4):(column_id-1))) + ...
        sum(A((row_id + 1),(column_id-4):(column_id-1))) * row_weight;
    Pixel_intensity_1_temp = sum(A((row_id - 1),(column_id):(column_id+3))) * row_weight + ...
        sum(A(row_id,(column_id):(column_id+3))) + ...
        sum(A((row_id + 1),(column_id):(column_id+3))) * row_weight;
    Pixel_intensity_2_temp = sum(A((row_id - 1),(column_id+4):(column_id+7))) * row_weight + ...
        sum(A(row_id,(column_id+4):(column_id+7))) + ...
        sum(A((row_id + 1),(column_id+4):(column_id+7))) * row_weight;
    count_temp_0 = 0;
    count_temp_1 = 0;
    count_temp_2 = 0;
    for j = 1:size(Points_X_all,1)
        if Points_X_all(j) >= (column_id-5) && ...
                Points_X_all(j) < (column_id-1) && ...
                Points_Y_all(j) >= (row_id-1) && ...
                Points_Y_all(j) < row_id
            count_temp_0 = count_temp_0 + 1;
        end
        if Points_X_all(j) >= (column_id-1) && ...
                Points_X_all(j) < (column_id+3) && ...
                Points_Y_all(j) >= (row_id-1) && ...
                Points_Y_all(j) < row_id
            count_temp_1 = count_temp_1 + 1;
        end
        if Points_X_all(j) >= (column_id+3) && ...
                Points_X_all(j) < (column_id+7) && ...
                Points_Y_all(j) >= (row_id-1) && ...
                Points_Y_all(j) < row_id
            count_temp_2 = count_temp_2 + 1;
        end
    end
    if count_temp_1 < 10
            continue;
    end
    count_temp_0_currpix = 0;
    count_temp_1_currpix = 0;
    count_temp_2_currpix = 0;
    count_temp_3_currpix = 0;
    for j = 1:size(Points_X_all,1)
        if Points_X_all(j) >= (column_id-1) && ...
                Points_X_all(j) < (column_id) && ...
                Points_Y_all(j) >= (row_id-1) && ...
                Points_Y_all(j) < row_id
            count_temp_0_currpix = count_temp_0_currpix + 1;
        end
        if Points_X_all(j) >= (column_id) && ...
                Points_X_all(j) < (column_id+1) && ...
                Points_Y_all(j) >= (row_id-1) && ...
                Points_Y_all(j) < row_id
            count_temp_1_currpix = count_temp_1_currpix + 1;
        end
        if Points_X_all(j) >= (column_id+1) && ...
                Points_X_all(j) < (column_id+2) && ...
                Points_Y_all(j) >= (row_id-1) && ...
                Points_Y_all(j) < row_id
            count_temp_2_currpix = count_temp_2_currpix + 1;
        end
        if Points_X_all(j) >= (column_id+2) && ...
                Points_X_all(j) < (column_id+3) && ...
                Points_Y_all(j) >= (row_id-1) && ...
                Points_Y_all(j) < row_id
            count_temp_3_currpix = count_temp_3_currpix + 1;
        end
    end
    Pixel_intensity_0 = cat(1,Pixel_intensity_0,Pixel_intensity_0_temp);
    Pixel_intensity_1 = cat(1,Pixel_intensity_1,Pixel_intensity_1_temp);
    Pixel_intensity_2 = cat(1,Pixel_intensity_2,Pixel_intensity_2_temp);
    Pixel_num_mol_0 = cat(1,Pixel_num_mol_0,count_temp_0);
    Pixel_num_mol_1 = cat(1,Pixel_num_mol_1,count_temp_1);
    Pixel_num_mol_2 = cat(1,Pixel_num_mol_2,count_temp_2);
    Pixel_currpix_0 = cat(1,Pixel_currpix_0,count_temp_0_currpix);
    Pixel_currpix_1 = cat(1,Pixel_currpix_1,count_temp_1_currpix);
    Pixel_currpix_2 = cat(1,Pixel_currpix_2,count_temp_2_currpix);
    Pixel_currpix_3 = cat(1,Pixel_currpix_3,count_temp_3_currpix);
end
%
Pixel_intensity = cat(2,Pixel_intensity_0,Pixel_intensity_1,Pixel_intensity_2);
Pixel_num_mol = cat(2,Pixel_num_mol_0,Pixel_num_mol_1,Pixel_num_mol_2);
Pixel_currpix = cat(2,Pixel_currpix_0,Pixel_currpix_1,Pixel_currpix_2,Pixel_currpix_3);
%%
for idx = 6:10
    figure;
    y = Pixel_intensity(idx,:) / sum(Pixel_intensity(idx,:));
%     x = 0:2;
%     x=x*1.5;
%     plot(x,y,'r');
%     hold on;
    y1 = y(1);
    y2 = 1/3*y(1) + 2/3*y(2);
    y3 = 2/3*y(2) + 1/3*y(3);
    y4 = y(3);
    x = 0:3;
    y = [y1,y2,y3,y4] / sum([y1,y2,y3,y4]);
    plot(x,y,'black');
    hold on;
    plot([0:3],Pixel_currpix(idx,:) / sum(Pixel_currpix(idx,:)),'r');
end
%%
Error_simu = 0;
Error_rand = 0;
num_simu_large = 0;
for idx = 1:size(Pixel_currpix,1)
    y = Pixel_intensity(idx,:) / sum(Pixel_intensity(idx,:));
    y1 = y(1);
    y2 = 1/3*y(1) + 2/3*y(2);
    y3 = 2/3*y(2) + 1/3*y(3);
    y4 = y(3);
    model_y = [y1,y2,y3,y4] / sum([y1,y2,y3,y4]);
    Pix4_y = Pixel_currpix(idx,:) / sum(Pixel_currpix(idx,:));
    Rand_y = [0.25,0.25,0.25,0.25];
    %Error_simu_temp = sqrt((Pix4_y - model_y) * (Pix4_y - model_y)');
    %Error_rand_temp = sqrt((Pix4_y - Rand_y) * (Pix4_y - Rand_y)');
    Error_simu_temp = sqrt((Pix4_y(1) - model_y(1)) * (Pix4_y(1) - model_y(1)));
    Error_rand_temp = sqrt((Pix4_y(1) - Rand_y(1)) * (Pix4_y(1) - Rand_y(1))');
    if Error_simu_temp > Error_rand_temp
        num_simu_large = num_simu_large + 1;
    end
    Error_simu = cat(1,Error_simu,Error_simu_temp);
    Error_rand = cat(1,Error_rand,Error_rand_temp);
end
%
disp(sum(Error_simu) / numel(Error_simu));
disp(sum(Error_rand) / numel(Error_rand));
disp(num_simu_large / size(Pixel_currpix,1));
