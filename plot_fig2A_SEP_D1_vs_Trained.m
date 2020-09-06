%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure 2.A.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('PathDatabase','var')==0 && exist('LFP_Data','var')==0 && exist('LFP_Data_description','var')==0
[PathDatabase,LFP_Data,LFP_Data_description]=Load_LFP_Multisite_database;
end
%learned days
load([PathDatabase filesep 'Learning_Days_Mtrx.mat']);
% p_value colormap
load([PathDatabase filesep 'p_value_colormap.mat']);

%% Plot SEP Stim trials, naive vs trained mice
Mouse_list=unique(LFP_Data.Mouse_Name(strcmp(LFP_Data.Session_Type,'DT')==1));
sr=str2double(LFP_Data_description.Trial_LFP_wS1.SamplingFrequencyHz);
t=linspace(0,5,sr*5);
Stimtime=3; %in sec
Baseline_duration=100; %in samples

%% Compute p_value vector
p=[];
Amp_D1=[];
Amp_Trained=[];
start_idx=1;
end_idx=5*sr;
win_size=10;
win_step=10;
win_nb=floor((size(LFP_Data.Trial_LFP_wS1,2)-win_size)/win_step+1);
Fields={'wS1','wS2','wM1','PtA','dCA1','mPFC'};

data_mouse_D1=[];
data_mouse_Learned=[];

for j=1:6
    Field=char(Fields(j));
    
    for i=1:size(Mouse_list,1)
        Mouse=char(Mouse_list(i));
        eval(['data_mouse_D1.' Field '(i,:)=nanmean(LFP_Data.Trial_LFP_' Field '(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==1 & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0],:));'])
        eval(['data_mouse_Learned.' Field '(i,:)=nanmean(LFP_Data.Trial_LFP_' Field '(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(i,1) | LFP_Data.Session_Counter==LDM(i,2) | LFP_Data.Session_Counter==LDM(i,3)] & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0],:));'])
        eval(['data_mouse_D1.' Field '(i,:)=data_mouse_D1.' Field '(i,:)-nanmean(data_mouse_D1.' Field '(i,Stimtime*sr-Baseline_duration:Stimtime*sr),2);'])
        eval(['data_mouse_Learned.' Field '(i,:)=data_mouse_Learned.' Field '(i,:)-nanmean(data_mouse_Learned.' Field '(i,Stimtime*sr-Baseline_duration:Stimtime*sr),2);'])
   
    end
    
    for k=1:win_nb-1 %%Sliding Window
        win_in=(k-1)*win_step+start_idx;
        win_out=(k-1)*win_step+win_size+start_idx;
        eval(['Amp_D1=nanmean(data_mouse_D1.' Field '(:,win_in:win_out),2);'])
        eval(['Amp_Trained=nanmean(data_mouse_Learned.' Field '(:,win_in:win_out),2);'])
        eval(['p.' Field '(1,k)=signrank(Amp_D1,Amp_Trained);'])
    end
end

% Plot D1 vs Trained with p values colormaps

for j=1:6
    fig=figure;
    Field=char(Fields(j));
    ax(1)=subplot(3,1,[1 2]);
    eval(['data1=nanmean(data_mouse_D1.' Field ')*10^(6);'])
    eval(['data3=data_mouse_Learned.' Field ';'])
    eval(['sem1=nanstd((data_mouse_D1.' Field '*10^(6)),[],1)/sqrt(sum(~isnan(data_mouse_D1.' Field '(:,1))));'])
    boundedline(t,data1,sem1,'b');
    hold on
    eval(['data2=nanmean(data_mouse_Learned.' Field ')*10^(6);'])
    eval(['sem2=nanstd((data_mouse_Learned.' Field '*10^(6)),[],1)/sqrt(sum(~isnan(data_mouse_Learned.' Field '(:,1))));'])
    boundedline(t,data2,sem2,'r','alpha');
    set(0, 'DefaultFigureRenderer', 'painters')
    title([Field ' n=' num2str(size(data3(isnan(data3(:,1))==0,1),1))],'fontweight','bold','fontsize',12,'fontname','times new roman');
    xlim([2.95 3.2]);
    ylim([-400 100]);
    xlabel('Time(s)')
    ylabel('(V)')
    line([3 3],get(ax(1),'yLim'),'LineWidth',1,'Color',[0 0 0])
    line([3.006 3.006],get(ax(1),'yLim'),'LineWidth',1,'Color',[0.5 0.5 0.5])
    
    
    ax(2)=subplot(3,1,3);
    linkaxes(ax,'x');
    y=[0 1];
    eval(['imagesc(t,y,1-log(p.' Field '));'])
    colormap(p_value_colormap);
    xlim([2.95 3.2]);
    ylim([0 1])
    
    line([3 3],get(ax(2),'yLim'),'LineWidth',1,'Color',[0 0 0])
    c=colorbar('southoutside','Ticks',[0,1-log(0.05),1-log(0.01),1-log(0.001),1-log(0.0001)],...
        'TickLabels',{num2str(0),num2str(0.05),num2str(0.01),num2str(0.001),num2str(0.0001)});
    c.Label.String = 'p value';
    caxis([1, 1-log(0.0005)])
    
    
    
end

%%

clear all

