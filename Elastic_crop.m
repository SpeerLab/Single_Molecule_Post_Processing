clear;clc;
expfolder = 'Y:\Chenghang\ET33_Tigre\20230817_1\';
num_images = 74;

analysis_folder = [expfolder,'analysis\'];
hdf5_input_folder = [analysis_folder 'Elastic_hdf5\'];
hdf5_output_folder = [analysis_folder 'Elastic_crop_hdf5\'];
if exist(hdf5_output_folder,'dir') ~= 7
    mkdir(hdf5_output_folder);
end

load([expfolder '\analysis\elastic_align_pre\rot_crop.mat']);
column_min = crop_storm(1)-1;
row_min = crop_storm(2)-1;

parfor i = 0:(num_images-1)
    channel_list = ["488","647","750"];
    disp(i);
    for j = 1:3
        hdf5_name = [char(channel_list(j)),'storm_',sprintf('%03d',i),'.hdf5'];
        n_groups = 0;
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
            h5create([hdf5_output_folder,hdf5_name],['/tracks' track_name '/x'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_name],['/tracks' track_name '/x'],Points_X_new);
            h5create([hdf5_output_folder,hdf5_name],['/tracks' track_name '/y'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_name],['/tracks' track_name '/y'],Points_Y_new);
            h5create([hdf5_output_folder,hdf5_name],['/tracks' track_name '/z'],size_hdf5);
            h5write([hdf5_output_folder,hdf5_name],['/tracks' track_name '/z'],Points_Z_new);

            fid = H5F.open([hdf5_output_folder,hdf5_name],'H5F_ACC_RDWR','H5P_DEFAULT');
            gid = H5G.open(fid,['/tracks' track_name]);
            typeID = H5T.copy("H5T_NATIVE_INT32");
            spaceID = H5S.create("H5S_SCALAR");
            acpl = H5P.create("H5P_ATTRIBUTE_CREATE");
            %h5writeatt([hdf5_output_folder,hdf5_name],'/tracks','n_groups',int2str(n_groups));
            attrID = H5A.create(gid,"n_tracks",typeID,spaceID,acpl);
            H5A.write(attrID,"H5ML_DEFAULT",int32(size_hdf5))
            H5A.close(attrID);
            H5S.close(spaceID);
            H5T.close(typeID);
            H5F.close(fid);
            H5G.close(gid);
            H5P.close(acpl);
            %h5writeatt([hdf5_output_folder,hdf5_name],['/tracks' track_name],'n_tracks',int32(size_hdf5));
            n_groups = n_groups + 1;
        end
        try
            fid = H5F.open([hdf5_output_folder,hdf5_name],'H5F_ACC_RDWR','H5P_DEFAULT');
        catch
            h5create([hdf5_output_folder,hdf5_name],['/tracks' track_name '/x'],1);
            h5write([hdf5_output_folder,hdf5_name],['/tracks' track_name '/x'],1);
            fid = H5F.open([hdf5_output_folder,hdf5_name],'H5F_ACC_RDWR','H5P_DEFAULT');
        end
        gid = H5G.open(fid,"/tracks");
        typeID = H5T.copy("H5T_NATIVE_INT32");
        spaceID = H5S.create("H5S_SCALAR");
        acpl = H5P.create("H5P_ATTRIBUTE_CREATE");
        %h5writeatt([hdf5_output_folder,hdf5_name],'/tracks','n_groups',int2str(n_groups));
        attrID = H5A.create(gid,"n_groups",typeID,spaceID,acpl);
        H5A.write(attrID,"H5ML_DEFAULT",int32(n_groups))
        H5A.close(attrID);
        H5S.close(spaceID);
        H5T.close(typeID);
        H5F.close(fid);
        H5G.close(gid);
        H5P.close(acpl);
    end
end