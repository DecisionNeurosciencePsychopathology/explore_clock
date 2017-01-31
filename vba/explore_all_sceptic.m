%Wrapper for processing all explore clock subjects with out SCEPTIC model


jj=1;
hh=1;




%Set up main data directory
data_dirs = glob('subjects\*');

%Set up variables
nbasis = 16;
multinomial = 1;
multisession = 0;
fixed_params_across_runs = 1;
fit_propspread = 0;
n_steps = 50;

u_aversion = 1; % allow for uncertainty aversion in UV_sum
saveresults = 0; %don't save to prevent script from freezing on Thorndike

graphics = 0; %If we want to plot or not

%Which models to use
%modelnames = {'fixed' 'fixed_uv' 'fixed_decay' 'kalman_softmax' 'kalman_processnoise' 'kalman_uv_sum' 'kalman_sigmavolatility' 'kalman_logistic'};
modelnames = {'fixed_decay'};





for m=1:length(modelnames)
   
    model = char(modelnames(m));
    for i = 1:length(data_dirs)
        try
        subj_dir = data_dirs{i};

        id = str2double(subj_dir(isstrprop(subj_dir,'digit')));
        
        %create generic path name
        gpath=sprintf('subjects/%d/fMRI*.mat',id);
        fpath=glob(gpath);

        gpath2=sprintf('subjects/%d/fMRI*_%d_1_tc_tcExport.csv',id,id);
        fpath2=glob(gpath2);
        
        %If subject is not processed yet
        foldername = ['subjects/' mat2str(id)];
        %make fpath2 a string
        file_path = char(fpath2);
        if ~exist(file_path, 'file')
            fprintf('\nSubject not processed...\n')
            %Convert the .mat file to a .csv
            ClockToCSV(fpath)
        end
        
        subj_file = glob([subj_dir '\*.csv']);
        subj_file = subj_file{:};
        [posterior,out] = explore_clock_sceptic_vba(subj_file,id,model,nbasis, multinomial, multisession, fixed_params_across_runs, fit_propspread,n_steps,u_aversion,saveresults,graphics);
        L(m,i) = out.F;
        
%   try
        makeClockRegressor(id,out)
            cdir= cd;
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
            
        %move the regressor files to thorndike    
        moveregs(currfolder,num2str(id),newfolder);
        
        
    %write the ids that successfully ran into a cell
    ID(jj,1)=id;
  
    
    
    Task{jj,1}=task; 
    
    if pl==2
        trialdone=fopen('idlog_clock.txt');
    else
        trialdone=fopen('idlog_bpdclock.txt');
    end
        
    trialdone=fscanf(trialdone,'%d');
    
    trialdone1=0;
    for aa=1:length(trialdone)
        if trialdone(aa,1) == id
            trialdone1=1;
        end
    end
    
    if trialdone1 == 1
        td={'yes'};
    else
        td={'no'};
    end
    fMRI_Preprocess_Complete{jj,1}=td; 
      jj=jj+1;
    
    %turn completed cell into table
    t=table(ID,Task,fMRI_Preprocess_Complete);
    
    if pl==2
        ct=t;
        save('completed','ct');
    else
        bct=t;
        save('completed','bct');
    end
        
        catch exception
                     
        %put IDs that didn't run into table
        ID2(hh,1)=id; 
        
        cdir= cd;
            if strcmp(cdir,'C:\Users\emtre\OneDrive\Documents\GitHub\bpd_clock')
                currfolder='bpd_clock';
                newfolder='/Volumes/bek/bsocial/bpd_clock/regs'; %folder to be place in within thorndike
                task={'bpdclock_rev'};
                pl=1;
                errorlog('bpdclockrev',id,exception)
            else
                currfolder='explore_clock';
                newfolder='/Volumes/bek/explore/clock_rev/regs'; %folder to be place in within thorndike
                task={'clock_rev'};
                pl=2;
                errorlog('clockrev',id,exception)
            end
            
    
        Task2{hh,1}=task; 
        
        hh=hh+1;
        
        t2=table(ID2,Task2);
       
       if pl==2
        ct2=t2;
        save('unable_to_run','ct2');
       else
        bct2=t2;
        save('unable_to_run','bct2');
       end
%         
   end

    end
    
    if pl==2
        
        if exist('ct2')==0
            ID2=0;
            Task2={'clock_rev'};
            ct2=table(ID2,Task2);
            save('unable_to_run','ct2')
        end

    else
        
        if exist('bct2')==0
            ID2=0;
            Task2={'bpd_clock'};
            bct2=table(ID2,Task2);
            save('unable_to_run','bct2')
        end
        
    end



end 



