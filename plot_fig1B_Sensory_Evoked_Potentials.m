
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure 1.C.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('PathDatabase','var')==0 && exist('LFP_Data','var')==0 && exist('LFP_Data_description','var')==0
[PathDatabase,LFP_Data,LFP_Data_description]=Load_LFP_Multisite_database;
end
load([PathDatabase filesep 'SEP_colormtrx.mat'])
%% Plot SEP hit trials, trained mice
Mouse_list=unique(LFP_Data.Mouse_Name(strcmp(LFP_Data.Session_Type,'DT')==1));
sr=str2double(LFP_Data_description.Trial_LFP_wS1.SamplingFrequencyHz);
t=linspace(-3,2,sr*5);

figure
WS1_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_wS1,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    WS1_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_wS1(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    WS1_LFP_AVG(i,:)=WS1_LFP_AVG(i,:)-nanmean(WS1_LFP_AVG(i,5800:6000),2);
end
plot(t,nanmean(WS1_LFP_AVG)*10^(6),'color',SEP_colormtrx(1,:));
hold on


WS2_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_wS2,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    WS2_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_wS2(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    WS2_LFP_AVG(i,:)=WS2_LFP_AVG(i,:)-nanmean(WS2_LFP_AVG(i,5800:6000),2);
end
plot(t,nanmean(WS2_LFP_AVG)*10^(6),'color',SEP_colormtrx(2,:));


WM1_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_wM1,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    WM1_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_wM1(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    WM1_LFP_AVG(i,:)=WM1_LFP_AVG(i,:)-nanmean(WM1_LFP_AVG(i,5800:6000),2);
end
plot(t,nanmean(WM1_LFP_AVG)*10^(6),'color',SEP_colormtrx(3,:));

PtA_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_PtA,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    PtA_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_PtA(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    PtA_LFP_AVG(i,:)=PtA_LFP_AVG(i,:)-nanmean(PtA_LFP_AVG(i,5800:6000),2);
end
plot(t,nanmean(PtA_LFP_AVG)*10^(6),'color',SEP_colormtrx(4,:));

dCA1_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_dCA1,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    dCA1_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_dCA1(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    dCA1_LFP_AVG(i,:)=dCA1_LFP_AVG(i,:)-nanmean(dCA1_LFP_AVG(i,5800:6000),2);
end
plot(t,nanmean(dCA1_LFP_AVG)*10^(6),'color',SEP_colormtrx(5,:));

mPFC_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_mPFC,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    mPFC_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_mPFC(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    mPFC_LFP_AVG(i,:)=mPFC_LFP_AVG(i,:)-nanmean(mPFC_LFP_AVG(i,5800:6000),2);
end
plot(t,nanmean(mPFC_LFP_AVG)*10^(6),'color',SEP_colormtrx(6,:));

title('SEP Hit trials Trained mice','fontweight','bold','fontsize',12,'fontname','times new roman');
xlim([-0.05 0.2]);
ylim([-400 100]);
xlabel('Time(s)')
ylabel('(uV)')
line([0 0],get(gca,'yLim'),'LineWidth',1,'Color',[0 0 0])
line([0.006 0.006],get(gca,'yLim'),'LineWidth',1,'Color',[0 0 0])

%%
clear all
    
