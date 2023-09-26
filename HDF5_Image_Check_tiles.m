clear;clc;
expfolder = 'X:\Chenghang\4_Color\Raw\12.21.2020_P8EA_B_V2\';
analysis_folder = [expfolder,'analysis\'];
hdf5_input_folder = [analysis_folder 'Elastic_crop_hdf5\'];
ML_result_folder = [expfolder,'ML_result_647_pos_30synapse\'];

Check_id = 36;
Check_size = 72;
%
file_ID = fopen([ML_result_folder,'ROIs.txt'],'r');
line_ex = fgetl(file_ID);
%
for i = 1:Check_id
    line_ex = fgetl(file_ID);
end
line_mat = split(line_ex,",");
fclose(file_ID);
%
row = str2num(line_mat{1});
column = str2num(line_mat{2});

fprintf('%i\n', row)
fprintf('%i\n', column)


Starting_pixel = [column,row]; %matlab and python has different x,y order.
Starting_pixel_hdf5 = Starting_pixel - [1,1]; %python starts from 0.
section_id = str2num(line_mat{3});
section_id_hdf5 = section_id - 1;

channels = ["647","750","561","488"];
channel = 1;

A = imread([ML_result_folder sprintf('%06d',Check_id) '.tif']);

hdf5_name = [char(channels(channel)),'storm_',sprintf('%03d',section_id_hdf5),'.hdf5'];
Points_X_all = [];
Points_Y_all = [];
for k = 0:1:9999 %iteration through all tracks
    disp(k);
    try
        track_name = ['/tracks/tracks_' char(string(k))];
        Points_X = h5read([hdf5_input_folder,hdf5_name],[track_name '/x']); %Assume X and y represent same thing in MATLAB and python.
        Points_Y = h5read([hdf5_input_folder,hdf5_name],[track_name '/y']);
        allow_id = (Points_X > (Starting_pixel_hdf5(1)) & Points_X <(Starting_pixel_hdf5(1) + Check_size) & Points_Y > Starting_pixel_hdf5(2) & Points_Y <(Starting_pixel_hdf5(2) + Check_size));
        Points_X = Points_X(allow_id);
        Points_Y = Points_Y(allow_id);
        Points_X = Points_X - Starting_pixel_hdf5(1);
        Points_Y = Points_Y - Starting_pixel_hdf5(2);
        %Further filter based on
%         file_ID = fopen([ML_result_folder,'Pix_list\' sprintf('%06d',Check_id) '.txt'],'r');
%         line_ex = fgetl(file_ID);
%         for i = 1:(86*86)
%             line_ex = fgetl(file_ID);
%             if line_ex == (-1)
%                 break
%             end
%             line_mat = split(line_ex,",");
%             row = str2num(line_mat{1});
%             column = str2num(line_mat{2});
%             allow_id = (Points_X > column & Points_X <(column+1) & Points_Y > row & Points_Y <(row+1));
%             Points_X_all = cat(1,Points_X_all,Points_X(allow_id));
%             Points_Y_all = cat(1,Points_Y_all,Points_Y(allow_id));
%         end
%         fclose(file_ID);
        Points_X_all = cat(1,Points_X_all,Points_X);
        Points_Y_all = cat(1,Points_Y_all,Points_Y);
    catch
        %disp('break');
        break;
    end
end
%%
figure;
subplot(1,2,1);
imshow(A);
axis on;
%ax = gca;
%ax.XLim = [40 50];
%ax.YLim = [40 50];
subplot(1,2,2);
scatter(Points_X_all,Points_Y_all,'.');
set(gca, 'YDir','reverse')
ax = gca;
ax.XLim = [0 86];
ax.YLim = [0 86];