%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure 3.C.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('PathDatabase','var')==0 && exist('LFP_Data','var')==0 && exist('LFP_Data_description','var')==0
    [PathDatabase,LFP_Data,LFP_Data_description]=Load_LFP_Multisite_database;
end
%learned and Exposed days
load([PathDatabase filesep 'Learning_Days_Mtrx.mat']);
load([PathDatabase filesep 'Exposed_Days_Mtrx.mat']);

%% Plot SEP Stim trials, naive vs trained mice
sr=str2double(LFP_Data_description.Trial_LFP_wS1.SamplingFrequencyHz);
Stimtime=3; %in sec
Baseline_duration=100; %in samples
Pre_ts=-1; %sec before
Post_ts=1; %sec after
Stim_time=3; %sec after trial onset;
Fields={'wS1','wS2','wM1','PtA','dCA1','mPFC'};
win_size=20;
win_step=5;
win_nb=((Post_ts-Pre_ts)*sr-win_size)/win_step+1;
nboot=1; % Number of shuffling

%% Compute Stim Probability (SP)
%Detection task
Mouse_list=unique(LFP_Data.Mouse_Name(strcmp(LFP_Data.Session_Type,'DT')==1));
for j=1:6
    Field=char(Fields(j));
    
    for i=1:size(Mouse_list,1)
        Mouse=char(Mouse_list(i));
        data_mouse=[];
        eval(['data_mouse=LFP_Data.Trial_LFP_' Field '(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(i,1) | LFP_Data.Session_Counter==LDM(i,2) | LFP_Data.Session_Counter==LDM(i,3)],(Stim_time+Pre_ts)*sr:(Stim_time+Post_ts)*sr);'])
        
        % Make label vectors
        StimLabels=zeros(1,size(LFP_Data.Trial_ID,1));
        for k=1:size(LFP_Data.Trial_ID,1)
            if LFP_Data.Trial_ID(k)==1 || LFP_Data.Trial_ID(k)==0
                StimLabels(k)=1;
            else
                StimLabels(k)=0;
            end
        end
        StimLabels=StimLabels(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & (LFP_Data.Session_Counter==LDM(i,1) | LFP_Data.Session_Counter==LDM(i,2) | LFP_Data.Session_Counter==LDM(i,3)));
        
        
        for l=1:nboot
            %Shuffling
            StimLabels_shfld=StimLabels(randi(length(StimLabels),1,length(StimLabels))); %shuffled Stim vector
            while sum(StimLabels_shfld)==0 || sum(StimLabels_shfld)==size(StimLabels,1)
                StimLabels_shfld=StimLabels(randi(length(StimLabels),1,length(StimLabels))); %shuffled Stim vector
            end
            
            % Get Shuffled ROC curve
            for k=1:win_nb %%Sliding Window
                win_in=(k-1)*win_step+1;
                win_out=(k-1)*win_step+win_size;
                Scores=mean(data_mouse(:,win_in:win_out),2);
                eval(['[~,~,~,SP.DT.' Field '(i,k)]=perfcurve(StimLabels_shfld,Scores,0);'])
            end
        end
    end
end

%Neutral Exposition
Mouse_list=unique(LFP_Data.Mouse_Name(strcmp(LFP_Data.Session_Type,'X')==1));
for j=1:6
    Field=char(Fields(j));
    
    for i=1:size(Mouse_list,1)
        Mouse=char(Mouse_list(i));
        data_mouse=[];
        eval(['data_mouse=LFP_Data.Trial_LFP_' Field '(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==EDM(i,1) | LFP_Data.Session_Counter==EDM(i,2) | LFP_Data.Session_Counter==EDM(i,3)],(Stim_time+Pre_ts)*sr:(Stim_time+Post_ts)*sr);'])
        
        % Make label vectors
        StimLabels=zeros(1,size(LFP_Data.Trial_ID,1));
        for k=1:size(LFP_Data.Trial_ID,1)
            if LFP_Data.Trial_ID(k)==1 || LFP_Data.Trial_ID(k)==0
                StimLabels(k)=1;
            else
                StimLabels(k)=0;
            end
        end
        StimLabels=StimLabels(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & (LFP_Data.Session_Counter==EDM(i,1) | LFP_Data.Session_Counter==EDM(i,2) | LFP_Data.Session_Counter==EDM(i,3)));
        
        for l=1:nboot
            %Shuffling
            StimLabels_shfld=StimLabels(randi(length(StimLabels),1,length(StimLabels))); %shuffled Stim vector
            while sum(StimLabels_shfld)==0 || sum(StimLabels_shfld)==size(StimLabels,1)
                StimLabels_shfld=StimLabels(randi(length(StimLabels),1,length(StimLabels))); %shuffled Stim vector
            end
            
            % Get Shuffled ROC curve
            for k=1:win_nb %%Sliding Window
                win_in=(k-1)*win_step+1;
                win_out=(k-1)*win_step+win_size;
                Scores=mean(data_mouse(:,win_in:win_out),2);
                eval(['[~,~,~,SP.X.' Field '(i,k)]=perfcurve(StimLabels_shfld,Scores,0);'])
            end
        end
    end
end

%% PLot
set(0, 'DefaultFigureRenderer', 'painters')
t=linspace(Pre_ts+win_size/(2*sr),Post_ts-win_size/(2*sr),win_nb);
for j=1:6
    Field=char(Fields(j));
    ax(1)=subplot(3,2,j);
    if strcmp(Field,'mPFC')==1
        eval(['data1=nanmean(SP.DT.' Field '(:,:,1))*-1+1;'])
        eval(['data2=nanmean(SP.X.' Field '(:,:,1))*-1+1;'])
        eval(['sem1=(nanstd(SP.DT.' Field '(:,:,1))*-1)/sqrt(size(SP.DT.' Field ',1));'])
        eval(['sem2=(nanstd(SP.X.' Field '(:,:,1))*-1)/sqrt(size(SP.X.' Field ',1));'])
    else
        eval(['data1=nanmean(SP.DT.' Field '(:,:,1));'])
        eval(['data2=nanmean(SP.X.' Field '(:,:,1));'])
        eval(['sem1=nanstd(SP.DT.' Field '(:,:,1))/sqrt(size(SP.DT.' Field ',1));'])
        eval(['sem2=nanstd(SP.X.' Field '(:,:,1))/sqrt(size(SP.X.' Field ',1));'])
    end
    
    boundedline(t,data1,sem1,'k');
    hold on
    boundedline(t,data2,sem2,'k');
    title(Field,'fontweight','bold','fontsize',12,'fontname','times new roman');
    xlim([-0.05 0.2]);
    ylim([0 1]);
    xlabel('Time(s)')
    line([0 0],get(ax(1),'yLim'),'LineWidth',1,'Color',[0 0 0])
    line([0.006 0.006],get(ax(1),'yLim'),'LineWidth',1,'Color',[0.5 0.5 0.5])
end

%%

clear all
