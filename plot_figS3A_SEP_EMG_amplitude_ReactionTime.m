
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure S3.A.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('PathDatabase','var')==0 && exist('LFP_Data','var')==0 && exist('LFP_Data_description','var')==0
[PathDatabase,LFP_Data,LFP_Data_description]=Load_LFP_Multisite_database;
end
load([PathDatabase filesep 'SEP_colormtrx.mat'])

%% Plot SEP hit trials, trained mice
format long
set(0, 'DefaultFigureRenderer', 'painters')

Mouse_list=unique(LFP_Data.Mouse_Name(strcmp(LFP_Data.Session_Type,'DT')==1));
sr=str2double(LFP_Data_description.Trial_LFP_wS1.SamplingFrequencyHz);
t=linspace(-3,2,sr*5);

fig1=figure;
WS1_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_wS1,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    WS1_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_wS1(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    WS1_LFP_AVG(i,:)=WS1_LFP_AVG(i,:)-nanmean(WS1_LFP_AVG(i,5800:6000),2);
end
WS1_LFP_GDAVG=nanmean(WS1_LFP_AVG);
y_offset=WS1_LFP_GDAVG(6710)-WS1_LFP_GDAVG(6700);
Valve_corrected_WS1_LFP_GDAVG=[WS1_LFP_GDAVG(1:6700) WS1_LFP_GDAVG(6701:end)-y_offset];
%Remove the 5ms bin of valve artifact.
firstIndextoExclude=6700;
lastIndextoExclude=6710;
L=lastIndextoExclude-firstIndextoExclude+1;
Valve_corrected_WS1_LFP_GDAVG(firstIndextoExclude:lastIndextoExclude)=linspace(Valve_corrected_WS1_LFP_GDAVG(firstIndextoExclude),Valve_corrected_WS1_LFP_GDAVG(lastIndextoExclude),L);
plot(t,Valve_corrected_WS1_LFP_GDAVG*10^(6),'color',SEP_colormtrx(1,:));
hold on

WS2_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_wS2,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    WS2_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_wS2(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    WS2_LFP_AVG(i,:)=WS2_LFP_AVG(i,:)-nanmean(WS2_LFP_AVG(i,5800:6000),2);
end
WS2_LFP_GDAVG=nanmean(WS2_LFP_AVG);
y_offset=WS2_LFP_GDAVG(6710)-WS2_LFP_GDAVG(6700);
Valve_corrected_WS2_LFP_GDAVG=[WS2_LFP_GDAVG(1:6700) WS2_LFP_GDAVG(6701:end)-y_offset];
%Remove the 5ms bin of valve artifact.
firstIndextoExclude=6700;
lastIndextoExclude=6710;
L=lastIndextoExclude-firstIndextoExclude+1;
Valve_corrected_WS2_LFP_GDAVG(firstIndextoExclude:lastIndextoExclude)=linspace(Valve_corrected_WS2_LFP_GDAVG(firstIndextoExclude),Valve_corrected_WS2_LFP_GDAVG(lastIndextoExclude),L);
plot(t,Valve_corrected_WS2_LFP_GDAVG*10^(6),'color',SEP_colormtrx(2,:));



WM1_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_wM1,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    WM1_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_wM1(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    WM1_LFP_AVG(i,:)=WM1_LFP_AVG(i,:)-nanmean(WM1_LFP_AVG(i,5800:6000),2);
end
WM1_LFP_GDAVG=nanmean(WM1_LFP_AVG);
y_offset=WM1_LFP_GDAVG(6710)-WM1_LFP_GDAVG(6700);
Valve_corrected_WM1_LFP_GDAVG=[WM1_LFP_GDAVG(1:6700) WM1_LFP_GDAVG(6701:end)-y_offset];
%Remove the 5ms bin of valve artifact.
firstIndextoExclude=6700;
lastIndextoExclude=6710;
L=lastIndextoExclude-firstIndextoExclude+1;
Valve_corrected_WM1_LFP_GDAVG(firstIndextoExclude:lastIndextoExclude)=linspace(Valve_corrected_WM1_LFP_GDAVG(firstIndextoExclude),Valve_corrected_WM1_LFP_GDAVG(lastIndextoExclude),L);
plot(t,Valve_corrected_WM1_LFP_GDAVG*10^(6),'color',SEP_colormtrx(3,:));



PtA_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_PtA,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    PtA_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_PtA(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    PtA_LFP_AVG(i,:)=PtA_LFP_AVG(i,:)-nanmean(PtA_LFP_AVG(i,5800:6000),2);
end
PtA_LFP_GDAVG=nanmean(PtA_LFP_AVG);
y_offset=PtA_LFP_GDAVG(6710)-PtA_LFP_GDAVG(6700);
Valve_corrected_PtA_LFP_GDAVG=[PtA_LFP_GDAVG(1:6700) PtA_LFP_GDAVG(6701:end)-y_offset];
%Remove the 5ms bin of valve artifact.
firstIndextoExclude=6700;
lastIndextoExclude=6710;
L=lastIndextoExclude-firstIndextoExclude+1;
Valve_corrected_PtA_LFP_GDAVG(firstIndextoExclude:lastIndextoExclude)=linspace(Valve_corrected_PtA_LFP_GDAVG(firstIndextoExclude),Valve_corrected_PtA_LFP_GDAVG(lastIndextoExclude),L);
plot(t,Valve_corrected_PtA_LFP_GDAVG*10^(6),'color',SEP_colormtrx(4,:));


dCA1_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_dCA1,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    dCA1_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_dCA1(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    dCA1_LFP_AVG(i,:)=dCA1_LFP_AVG(i,:)-nanmean(dCA1_LFP_AVG(i,5800:6000),2);
end
dCA1_LFP_GDAVG=nanmean(dCA1_LFP_AVG);
y_offset=dCA1_LFP_GDAVG(6710)-dCA1_LFP_GDAVG(6700);
Valve_corrected_dCA1_LFP_GDAVG=[dCA1_LFP_GDAVG(1:6700) dCA1_LFP_GDAVG(6701:end)-y_offset];
%Remove the 5ms bin of valve artifact.
firstIndextoExclude=6700;
lastIndextoExclude=6710;
L=lastIndextoExclude-firstIndextoExclude+1;
Valve_corrected_dCA1_LFP_GDAVG(firstIndextoExclude:lastIndextoExclude)=linspace(Valve_corrected_dCA1_LFP_GDAVG(firstIndextoExclude),Valve_corrected_dCA1_LFP_GDAVG(lastIndextoExclude),L);
plot(t,Valve_corrected_dCA1_LFP_GDAVG*10^(6),'color',SEP_colormtrx(5,:));



mPFC_LFP_AVG=zeros(size(Mouse_list,1),size(LFP_Data.Trial_LFP_mPFC,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    mPFC_LFP_AVG(i,:)=nanmean(LFP_Data.Trial_LFP_mPFC(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1,:));
    mPFC_LFP_AVG(i,:)=mPFC_LFP_AVG(i,:)-nanmean(mPFC_LFP_AVG(i,5800:6000),2);
end
mPFC_LFP_GDAVG=nanmean(mPFC_LFP_AVG);
y_offset=mPFC_LFP_GDAVG(6710)-mPFC_LFP_GDAVG(6700);
Valve_corrected_mPFC_LFP_GDAVG=[mPFC_LFP_GDAVG(1:6700) mPFC_LFP_GDAVG(6701:end)-y_offset];
%Remove the 5ms bin of valve artifact.
firstIndextoExclude=6700;
lastIndextoExclude=6710;
L=lastIndextoExclude-firstIndextoExclude+1;
Valve_corrected_mPFC_LFP_GDAVG(firstIndextoExclude:lastIndextoExclude)=linspace(Valve_corrected_mPFC_LFP_GDAVG(firstIndextoExclude),Valve_corrected_mPFC_LFP_GDAVG(lastIndextoExclude),L);
plot(t,Valve_corrected_mPFC_LFP_GDAVG*10^(6),'color',SEP_colormtrx(6,:));



title('SEP, Hit trials, Trained mice','fontweight','bold','fontsize',12,'fontname','times new roman');
xlim([-0.1 1]);
%ylim([-400 100]);
xlabel('Time(s)')
ylabel('(uV)')
line([0 0],get(gca,'yLim'),'LineWidth',1,'Color',[0 0 0])
line([0.006 0.006],get(gca,'yLim'),'LineWidth',1,'Color',[0 0 0])
set(gcf, 'Position', [1 800 800 200])
    

%% EMG Amplitude

data_EMG=nan(size(Mouse_list,1),size(LFP_Data.Trial_EMG,2));
AMP_HT_EMG_H=nan(size(Mouse_list,1),size(LFP_Data.Trial_EMG,2));
for i=1:size(Mouse_list,1)
    Mouse=char(Mouse_list(i));
    data_EMG(i,:)=nanmean(LFP_Data.Trial_EMG(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1 & LFP_Data.Trial_FirstLickTime>200,:));   
    HilbertT_EMG_H=[];
    HilbertT_EMG_H(:,:)=hilbert(LFP_Data.Trial_EMG(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Trial_ID==1 & LFP_Data.Trial_FirstLickTime>200,:));
    Amp_HilbertT_H=NaN(size(HilbertT_EMG_H,1),10000);
    for j=1:size(HilbertT_EMG_H,1)
    Amp_HilbertT_H(j,:)=sqrt((real(HilbertT_EMG_H(j,:)').^2)+(imag(HilbertT_EMG_H(j,:)').^2)); 
    end
    AMP_HT_EMG_H(i,:)=nanmean(Amp_HilbertT_H,1);
end
fig2=figure;
plot(t,nanmean(AMP_HT_EMG_H)*10^(6),'k');
title('EMG amplitude, Hit trials, Trained mice','fontweight','bold','fontsize',12,'fontname','times new roman');
xlim([-0.1 1]);
%ylim([-400 100]);
xlabel('Time(s)')
ylabel('(uV)')
line([0 0],get(gca,'yLim'),'LineWidth',1,'Color',[0 0 0])
line([0.006 0.006],get(gca,'yLim'),'LineWidth',1,'Color',[0 0 0])
set(gcf, 'Position', [1 800 800 200])

%% Reaction Times
fig3=figure;
RT_Hit(:,:)=LFP_Data.Trial_FirstLickTime(LFP_Data.Trial_ID==1 & LFP_Data.Trial_FirstLickTime>200,:);
h=histogram(RT_Hit./2000,'FaceColor','b','EdgeColor','k','Normalization','probability');
h.NumBins=90;
h.BinWidth=0.01;
xlim([-0.1 1]);
ylim([0 0.05]);
title('Reaction Times - Hit trials','fontweight','bold','fontsize',12);
xlabel('Time after stimulation (s)')
line([0 0],get(gca,'yLim'),'LineWidth',1,'Color',[0 0 0])
line([0.006 0.006],get(gca,'yLim'),'LineWidth',1,'Color',[0 0 0])
set(gcf, 'Position', [1 800 800 200])   

%%

clear all

