%Wrapper for processing all explore clock subjects with out SCEPTIC model

%Set up main data directory
data_dirs = glob('subjects\*');

%Add proper paths (explore clock, explore/vba or just move make VBA
%regreessors to the main explore clock dir)

%Set up variables
nbasis = 16;
multinomial = 1;
multisession = 0;
fixed_params_across_runs = 1;
fit_propspread = 0;
n_steps = 50;
data_str=0;


%Place the results depending on the version of clock
if strfind(pwd,'bpd')
    results_dir='E:/data/sceptic/vba_out/bpd_clock_test_autoproc/';
    task_data=initialize_task_tracking_data('BPD_Clock');
else
    results_dir='E:/data/sceptic/vba_out/clock_test_autoproc/';
    task_data=initialize_task_tracking_data('Rev_Clock');
end

%Create directory if it doesn't exist
if ~exist(results_dir,'dir'), mkdir(results_dir); end;

u_aversion = 1; % allow for uncertainty aversion in UV_sum
saveresults = 0; %don't save to prevent script from freezing on Thorndike

graphics = 0; %If we want to plot or not

%Which models to use
%modelnames = {'fixed' 'fixed_uv' 'fixed_decay' 'kalman_softmax' 'kalman_processnoise' 'kalman_uv_sum' 'kalman_sigmavolatility' 'kalman_logistic'};
modelnames = {'fixed_decay'};


%For now only create the regs once
made_and_moved_regs_already=-1;

for m=1:length(modelnames)
    made_and_moved_regs_already=made_and_moved_regs_already+1;
    model = char(modelnames(m));
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
            
            %% Run SCEPTIC -- for more info see the README on GitHub ('enter hyperlink to repo')
            [posterior,out] = clock_sceptic_vba(id,model,nbasis, multinomial,multisession,fixed_params_across_runs,fit_propspread,n_steps,u_aversion,data_str, saveresults, graphics,results_dir,subj_file);
            L(m,i) = out.F;
            
            %Update task_tracking data
            task_data.behave_processed=1;
            
            
            %% Create and move the basic regressors to Bek, the PE regressors
            %will have to be dealt with in the future
            if made_and_moved_regs_already==0
                [out,task_data]=makeClockRegressor(id,subj_file,out,task_data);
                cdir= cd;
                
                %change later whenever we need to move the regs
                if strcmp(cdir,'C:\Users\emtre\OneDrive\Documents\GitHub\bpd_clock')
                    currfolder='bpd_clock';
                    newfolder='/Volumes/bek/bsocial/bpd_clock/regs'; %folder to be place in within thorndike
                    task={'bpdclock_rev'};
                    pl=1;
                else
                    currfolder='explore_clock';
                    newfolder='/Volumes/bek/explore/clock_rev/regs'; %folder to be place in within thorndike
                    task={'clock_rev'};
                    pl=2;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Hold off for now
                %move the regressor files to thorndike
                %moveregs(currfolder,num2str(id),newfolder);
                
            end
            
            %% write completed subj data to file
            %Note: Let's try to clean this code up into a function, well
            %have a better idea once we know the final format of dat or
            %xlsx file we'll use, but we should still contain it in a
            %function to follow the DRY principle!
            
            %write the task data to file
            record_subj_to_file(id,task_data)
            
        catch exception
            %write the task data to file
            record_subj_to_file(id,task_data)
            
            %Record errors in logger
            errorlog(task_data.name,id,exception)
        end
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