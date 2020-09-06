%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure 4.C.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('spike_data','var')==0 && exist('spike_data_description','var')==0 && exist('LFP_data','var')==0 && exist('LFP_data_description','var')==0
[PathDatabase,spike_data,spike_data_description,LFP_data,LFP_data_description]=Load_Silicon_Probe_database;
end

%% Parameters DT
format long
set(0, 'DefaultFigureRenderer', 'painters')

Task='DT';
sr=spike_data_description.Cell_SpikeTimes.SamplingFrequencyHz;
PreTime=-1;
PostTime=1;
bin_size=0.010; %in s
bin_size_plot=0.02; %bin size for plotting
Units2plot=0; %-1: all 0:Regular spiking Units, 1:Fast spiking Units

Mice_Names=[spike_data.Mouse_Name{:}];
Mouse_list=unique(Mice_Names(strcmp(spike_data.Session_Type,Task)==1))';

%% PSTH H

Logical_task=strcmp(spike_data.Session_Type,Task);

if Units2plot==0
    Logical_units=logical(spike_data.Cell_RS);
elseif Units2plot==1
    Logical_units=logical(spike_data.Cell_FS);
end

DATA_2_PLOT=spike_data.Cell_SpikeTimes(Logical_units & Logical_task);


premature_lick_indices=[];
FR_H=NaN(size(DATA_2_PLOT,1),(PostTime-PreTime)/bin_size);

for Unit=1:size(DATA_2_PLOT,1)
    SpikeTimes=cell2mat(DATA_2_PLOT{Unit, 1});
    Events=spike_data.Session_StimTimes_Hit(Logical_units & Logical_task);
    EventTimes=cell2mat(Events{Unit,1});
    FLTs_H=spike_data.Session_FirstLickTimes_Hit(Logical_units & Logical_task);
    FirstLicksTimes=cell2mat(FLTs_H{Unit,1});
   
    for j=1:size(EventTimes,2)
        premature_lick_indices=zeros(size(size(EventTimes)));
        for k=1:size(FirstLicksTimes,2)
            if 0<FirstLicksTimes(1,k)-EventTimes(1,j) && FirstLicksTimes(1,k)-EventTimes(1,j)<0.1*sr
                premature_lick_indices(k)=1;
            else
                premature_lick_indices(k)=0;
            end
        end
    end
    EventTimes(premature_lick_indices==1)=[];
    
    [SpikeRates,WindowCenters]= PSTH_Simple(SpikeTimes,EventTimes,PreTime,PostTime,sr,bin_size);
    FR_H(Unit,:)=nanmean(SpikeRates,2)';
end

Mean_FR_H=nanmean(FR_H,1);
Std_FR_H=nanstd(FR_H,[],1)/sqrt(size(FR_H,1));

%Remove the 10ms bin after stim and line interpolate.
mid_idx=2/bin_size/2;
ArtifactWindow=0.01;
firstIndextoExclude=mid_idx+1;
lastIndextoExclude=firstIndextoExclude+ArtifactWindow/bin_size-1;
L=lastIndextoExclude-firstIndextoExclude+1;
Mean_FR_H(:,firstIndextoExclude:lastIndextoExclude)=linspace(Mean_FR_H(:,firstIndextoExclude-1),Mean_FR_H(:,lastIndextoExclude+1),L);


%% PSTH M

premature_lick_indices=[];
EventTimes=[];
FirstLicksTimes=[];
FR_M=NaN(size(DATA_2_PLOT,1),(PostTime-PreTime)/bin_size);

for Unit=1:size(DATA_2_PLOT,1)
    SpikeTimes=cell2mat(DATA_2_PLOT{Unit, 1});
    Events=spike_data.Session_StimTimes_Miss(Logical_units & Logical_task);
    EventTimes=cell2mat(Events{Unit,1});
    
    [SpikeRates,WindowCenters]= PSTH_Simple(SpikeTimes,EventTimes,PreTime,PostTime,sr,bin_size);
    FR_M(Unit,:)=nanmean(SpikeRates,2)';
end

Mean_FR_M=nanmean(FR_M,1);
Std_FR_M=nanstd(FR_M,[],1)/sqrt(size(FR_M,1));

%Remove the 10ms bin after stim and line interpolate.
mid_idx=2/bin_size/2;
ArtifactWindow=0.01;
firstIndextoExclude=mid_idx+1;
lastIndextoExclude=firstIndextoExclude+ArtifactWindow/bin_size-1;
L=lastIndextoExclude-firstIndextoExclude+1;
Mean_FR_M(:,firstIndextoExclude:lastIndextoExclude)=linspace(Mean_FR_M(:,firstIndextoExclude-1),Mean_FR_M(:,lastIndextoExclude+1),L);

%% PLot H vs M FR

fig1=figure;
boundedline(WindowCenters./sr,Mean_FR_M,Std_FR_M,'k','alpha');
hold on
boundedline(WindowCenters./sr,Mean_FR_H,Std_FR_H,'r','alpha');
line([0 0],[0 5],'LineWidth',1,'Color',[0 0 0])
line([0.01 0.01],[0 5],'LineWidth',1,'Color',[0 0 0])
title('Stim PSTH mPFC RSU, Hit vs Miss','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Firing Rate (Hz)')
xlim([-1 1]);
if Units2plot==0 || Units2plot==-1
    ylim([0 3.5]);
elseif Units2plot==1
    ylim([0 10]);
end

%%
clear all
