%Wrapper for processing all explore and bsocial clock subjects with our SCEPTIC model

%Set up main data directory
data_dirs = glob('subjects\*');

%Add proper paths (explore clock, explore/vba or just move make VBA
%regreessors to the main explore clock dir)

%Load the sceptic config files and initialize the tracking data.
%As a new user you will have to create the config files (see
%https://github.com/DecisionNeurosciencePsychopathology/temporal_instrumental_agent
%for more help) & set the paths to said file.
if strfind(pwd,'bpd')
    %Load in clock version specific config file
    load('C:\kod\bpd_clock\vba\sceptic_bpd_data_struct.mat')
    
    %Initalize task data
    task_data=initialize_task_tracking_data('clockbpd');
    
    %Dir pointer to Throndike (server) reg housing
    dest_folder='/Volumes/bek/bsocial/bpd_clock/regs';
    
    %get file paths
    currfolder=pwd;
elseif strfind(pwd,'ksoc')
    %Load in clock version specific config file
    load('E:\programma\ksoc_clock\sceptic_ksoc_data_struct.mat')
    
    %Initalize task data
    task_data=initialize_task_tracking_data('ksoc_clock');
    
    %Dir pointer to Throndike (server) reg housing
    dest_folder='/Volumes/bek/ksocial/ksoc_clock/regs';
    
    %get file paths
    currfolder=pwd;
else
    %Load in clock version specific config file
    load('C:\kod\explore_clock\vba\sceptic_explore_data_struct.mat')
    
    %Initalize task data
    task_data=initialize_task_tracking_data('clockrev');
    
    %Dir pointer to Throndike (server) reg housing
    dest_folder='/Volumes/bek/explore/clock_rev/regs';
    
    %get file paths
    currfolder=pwd;
end

%Create directory if it doesn't exist
if ~exist(s.results_dir,'dir'), mkdir(s.results_dir); end;

%Set model names -- note I removed the previous for loop, this may have to
%be reinstated!
model = char(s.modelnames);

%% Main loop
for i = 1:length(data_dirs)
    try
        subj_dir = data_dirs{i};
        
        id = str2double(subj_dir(isstrprop(subj_dir,'digit')));
        
        %create generic path name
        mat_file_path=sprintf('subjects/%d/fMRI*.mat',id);
        mat_file_path=glob(mat_file_path);
        
        csv_file_path=sprintf('subjects/%d/fMRI*_%d_1_tc_tcExport.csv',id,id);
        csv_file_path=glob(csv_file_path);
        
        %% If subject is not processed yet
        foldername = ['subjects/' mat2str(id)];
        
        %ensure file path is a string
        file_path = char(csv_file_path);
        if ~exist(file_path, 'file')
            fprintf('\nSubject not processed...\n')
            %Convert the .mat file to a .csv
            ClockToCSV(char(mat_file_path))
        end
        
        %Grab the subj's data
        subj_file = glob([subj_dir '\*.csv']);
        subj_file = subj_file{:};
        
        %Update task_tracking data
        task_data.behave_completed=1;
        
        %% Run SCEPTIC -- for more info see the README on GitHub ('https://github.com/DecisionNeurosciencePsychopathology/temporal_instrumental_agent')
        [posterior,out] = clock_sceptic_vba(s,id,model,subj_file);
        L(i) = out.F;
        
        %Update task_tracking data
        task_data.behave_processed=1;
        
        %% Create and move the basic regressors to Bek, the PE regressors
        %will have to be dealt with in the future
        [out]=makeClockRegressor(id,subj_file,out);
        
        %move the regressor files to thorndike
        moveregs(currfolder,id,dest_folder);
        
        %write the task data to file
        record_subj_to_file(id,task_data)
        
    catch exception
        %write the task data to file
        record_subj_to_file(id,task_data)
        
        %Record errors in logger
        errorlog(task_data.name,id,exception)
    end
end



%%%%%%OLD CODE%%%%%
% % %             %% write completed subj data to file
% % %             %Note: Let's try to clean this code up into a function, well
% % %             %have a better idea once we know the final format of dat or
% % %             %xlsx file we'll use, but we should still contain it in a
% % %             %function to follow the DRY principle!
% % %
% % %             %write the ids that successfully ran into a cell
% % %             ID(jj,1)=id;
% % %
% % %             Task{jj,1}=task;
% % %
% % %             if pl==2
% % %                 trialdone=fopen('idlog_clock.txt','a+');
% % %             else
% % %                 trialdone=fopen('idlog_bpdclock.txt','a+');
% % %             end
% % %
% % %             trialdone=fscanf(trialdone,'%d');
% % %
% % %             trialdone1=0;
% % %             for aa=1:length(trialdone)
% % %                 if trialdone(aa,1) == id
% % %                     trialdone1=1;
% % %                 end
% % %             end
% % %
% % %             if trialdone1 == 1
% % %                 td={'yes'};
% % %             else
% % %                 td={'no'};
% % %             end
% % %             fMRI_Preprocess_Complete{jj,1}=td;
% % %             jj=jj+1;
% % %
% % %             %turn completed cell into table
% % %             t=table(ID,Task,fMRI_Preprocess_Complete);
% % %
% % %             if pl==2
% % %                 ct=t;
% % %                 save('completed','ct');
% % %             else
% % %                 bct=t;
% % %                 save('completed','bct');
% % %             end
% % %
% % %         catch exception
% % %
% % %             %put IDs that didn't run into table
% % %             ID2(hh,1)=id;
% % %
% % %             cdir= cd;
% % %             if strcmp(cdir,'C:\Users\emtre\OneDrive\Documents\GitHub\bpd_clock')
% % %                 currfolder='bpd_clock';
% % %                 newfolder='/Volumes/bek/bsocial/bpd_clock/regs'; %folder to be place in within thorndike
% % %                 task={'bpdclock_rev'};
% % %                 pl=1;
% % %                 errorlog('bpdclockrev',id,exception)
% % %             else
% % %                 currfolder='explore_clock';
% % %                 newfolder='/Volumes/bek/explore/clock_rev/regs'; %folder to be place in within thorndike
% % %                 task={'clock_rev'};
% % %                 pl=2;
% % %                 errorlog('clockrev',id,exception)
% % %             end
% % %
% % %
% % %             Task2{hh,1}=task;
% % %
% % %             hh=hh+1;
% % %
% % %             t2=table(ID2,Task2);
% % %
% % %             if pl==2
% % %                 ct2=t2;
% % %                 save('unable_to_run','ct2');
% % %             else
% % %                 bct2=t2;
% % %                 save('unable_to_run','bct2');
% % %             end
% % %             %
% % %         end
% % %
% % %
% % %         if pl==2
% % %
% % %             if exist('ct2')==0
% % %                 ID2=0;
% % %                 Task2={'clock_rev'};
% % %                 ct2=table(ID2,Task2);
% % %                 save('unable_to_run','ct2')
% % %             end
% % %
% % %         else
% % %
% % %             if exist('bct2')==0
% % %                 ID2=0;
% % %                 Task2={'bpd_clock'};
% % %                 bct2=table(ID2,Task2);
% % %                 save('unable_to_run','bct2')
% % %             end
% % %
% % %         end
% % %     end
% % % end