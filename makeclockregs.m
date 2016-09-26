% created 9.7.2016

%call up subject folder
dirs=dir('subjects');


%assign ids to variable ids
i=1;
for j=1:length(dirs)
    if length(dirs(j).name)==6
        x=str2num(dirs(j).name);
        ids(i)=x;
        i=i+1;
    end    
    j=j+1;
end
    
    
%run through sharkmakeregressor
for k=1:length(ids)
    makeClockRegressor(ids(k));
end
