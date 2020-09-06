%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure 3.D.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('spike_data','var')==0 && exist('spike_data_description','var')==0 && exist('LFP_data','var')==0 && exist('LFP_data_description','var')==0
[PathDatabase,spike_data,spike_data_description,LFP_data,LFP_data_description]=Load_Silicon_Probe_database;
end
%Load colormaps
load([PathDatabase filesep 'zscore_colormap.mat'])

%% Parameters DT
format long
set(0, 'DefaultFigureRenderer', 'painters')

Task='DT';
sr=spike_data_description.Cell_SpikeTimes.SamplingFrequencyHz;
PreTime=-1;
PostTime=1;
bin_size_Psth=0.010; %in s
bin_size_zscore=0.02; %bin size for plotting
Units2plot=0; %-1: all 0:Regular spiking Units, 1:Fast spiking Units

%% PSTH Stim 

Logical_task=strcmp(spike_data.Session_Type,Task);
if Units2plot==0
    Logical_units=logical(spike_data.Cell_RS);
elseif Units2plot==1
    Logical_units=logical(spike_data.Cell_FS);
end

DATA_2_PLOT=spike_data.Cell_SpikeTimes(Logical_units & Logical_task);


premature_lick_indices=[];
FR_STIM=NaN(size(DATA_2_PLOT,1),(PostTime-PreTime)/bin_size_Psth);
FR_STIM_Z=NaN(size(DATA_2_PLOT,1),(PostTime-PreTime)/bin_size_zscore);

for Unit=1:size(DATA_2_PLOT,1)
    SpikeTimes=cell2mat(DATA_2_PLOT{Unit, 1});
    Events=spike_data.Session_StimTimes(Logical_units & Logical_task);
    EventTimes=cell2mat(Events{Unit,1});
    FLTs_STIM=spike_data.Session_FirstLickTimes(Logical_units & Logical_task);
    FirstLicksTimes=cell2mat(FLTs_STIM{Unit,1});
   
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
    
    [SpikeRates,WindowCenters]= PSTH_Simple(SpikeTimes,EventTimes,PreTime,PostTime,sr,bin_size_Psth);
    FR_STIM(Unit,:)=nanmean(SpikeRates,2)';
    [SpikeRates_z,WindowCenters2]= PSTH_Simple(SpikeTimes,EventTimes,PreTime,PostTime,sr,bin_size_zscore);
    FR_STIM_Z(Unit,:)=nanmean(SpikeRates_z,2)';
end

Mean_FR_STIM=nanmean(FR_STIM,1);
Std_FR_STIM=nanstd(FR_STIM,[],1)/sqrt(size(FR_STIM,1));

%Remove the 10ms bin after stim and line interpolate.
mid_idx=2/bin_size_Psth/2;
ArtifactWindow=bin_size_Psth;
firstIndextoExclude=mid_idx+1;
lastIndextoExclude=firstIndextoExclude+ArtifactWindow/bin_size_Psth-1;
L=lastIndextoExclude-firstIndextoExclude+1;
Mean_FR_STIM(:,firstIndextoExclude:lastIndextoExclude)=linspace(Mean_FR_STIM(:,firstIndextoExclude-1),Mean_FR_STIM(:,lastIndextoExclude+1),L);

fig1=figure;
boundedline(WindowCenters./sr,Mean_FR_STIM,Std_FR_STIM,'r','alpha');
line([0 0],[0 5],'LineWidth',1,'Color',[0 0 0])
line([0.01 0.01],[0 5],'LineWidth',1,'Color',[0 0 0])
title('Stim PSTH mPFC RSU units, Detection task','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Firing Rate (Hz)')
xlim([-1 1]);
if Units2plot==0 || Units2plot==-1
    ylim([0 3.5]);
elseif Units2plot==1
    ylim([0 10]);
end

%% PLot z-scored heatmap DT
%Remove the 10ms bin after stim and line interpolate.
mid_idx=2/bin_size_zscore/2;
end_idx=2/bin_size_zscore;

fig2=figure;
Z_FR_STIM=zscore(FR_STIM_Z,0,2);

for i=1:size(FR_STIM_Z,1)
    Z_FR_STIM(i,:)=(FR_STIM_Z(i,:)-mean(FR_STIM_Z(i,1:mid_idx),2))/std(FR_STIM_Z(i,1:mid_idx),1,2); %% Getting mu and SD form baseline
end
    
   
[~,fr_order]=sort(mean(Z_FR_STIM(:,mid_idx+1:end_idx),2));
imagesc('XData',WindowCenters2./sr,'CData',Z_FR_STIM(fr_order,:));
xlim([-1 1]);
ylim([0 size(Z_FR_STIM,1)]);
ylabel('Units')
xlabel('Time(s)')
colormap(zscore_colormap);
c=colorbar('eastoutside');
    c.Label.String = 'Z score';
    caxis([-2, 4])
line([0 0],[0 size(FR_STIM_Z,1)],'LineWidth',1,'Color',[0 0 0])
if Units2plot==0
title('Z Scored Firing Rate of Stim trials RSU, Detection task','fontweight','bold','fontsize',12,'fontname','times new roman');
elseif Units2plot==1
title('Z Scored Firing Rate of Stim trials FSU, Detection task','fontweight','bold','fontsize',12,'fontname','times new roman');    
else
title('Z Scored Firing Rate of Stim All units, Detection task','fontweight','bold','fontsize',12,'fontname','times new roman');    
end 




%% Parameters X
Task='X';

%% PSTH Stim 

Logical_task=strcmp(spike_data.Session_Type,Task);

if Units2plot==0
    Logical_units=logical(spike_data.Cell_RS);
elseif Units2plot==1
    Logical_units=logical(spike_data.Cell_FS);
end

DATA_2_PLOT=spike_data.Cell_SpikeTimes(Logical_units & Logical_task);

premature_lick_indices=[];
EventTimes=[];
FirstLicksTimes=[];
FR_STIM_X=NaN(size(DATA_2_PLOT,1),(PostTime-PreTime)/bin_size_Psth);
FR_STIM_X_Z=NaN(size(DATA_2_PLOT,1),(PostTime-PreTime)/bin_size_zscore);

for Unit=1:size(DATA_2_PLOT,1)
    SpikeTimes=cell2mat(DATA_2_PLOT{Unit, 1});
    Events=spike_data.Session_StimTimes(Logical_units & Logical_task);
    EventTimes=cell2mat(Events{Unit,1});
    FLTs_STIM=spike_data.Session_FirstLickTimes(Logical_units & Logical_task);
    FirstLicksTimes=cell2mat(FLTs_STIM{Unit,1});
   
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
    
    [SpikeRates_x,WindowCenters_x]= PSTH_Simple(SpikeTimes,EventTimes,PreTime,PostTime,sr,bin_size_Psth);
    FR_STIM_X(Unit,:)=nanmean(SpikeRates_x,2)';
    [SpikeRates_z,WindowCenters_z]= PSTH_Simple(SpikeTimes,EventTimes,PreTime,PostTime,sr,bin_size_zscore);
    FR_STIM_X_Z(Unit,:)=nanmean(SpikeRates_z,2)';
end

Mean_FR_STIM_X=nanmean(FR_STIM_X,1);
Std_FR_STIM_X=nanstd(FR_STIM_X,[],1)/sqrt(size(FR_STIM_X,1));

%Remove the 10ms bin after stim and line interpolate.
mid_idx=2/bin_size_Psth/2;
ArtifactWindow=bin_size_Psth;
firstIndextoExclude=mid_idx+1;
lastIndextoExclude=firstIndextoExclude+ArtifactWindow/bin_size_Psth-1;
L=lastIndextoExclude-firstIndextoExclude+1;
Mean_FR_STIM_X(:,firstIndextoExclude:lastIndextoExclude)=linspace(Mean_FR_STIM_X(:,firstIndextoExclude-1),Mean_FR_STIM_X(:,lastIndextoExclude+1),L);

fig3=figure;
boundedline(WindowCenters_x./sr,Mean_FR_STIM_X,Std_FR_STIM_X,'g','alpha');
line([0 0],[0 5],'LineWidth',1,'Color',[0 0 0])
line([0.01 0.01],[0 5],'LineWidth',1,'Color',[0 0 0])
title('Stim PSTH mPFC RSU, Neutral Exposure','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Firing Rate (Hz)')
xlim([-1 1]);
if Units2plot==0 || Units2plot==-1
    ylim([0 3.5]);
elseif Units2plot==1
    ylim([0 10]);
end


%% PLot z-scored heatmap X
mid_idx=2/bin_size_zscore/2;
end_idx=2/bin_size_zscore;
ArtifactWindow=bin_size_zscore;
fig4=figure;
Z_FR_STIM_X=zscore(FR_STIM_X_Z,0,2);

for i=1:size(FR_STIM_X_Z,1)
    Z_FR_STIM_X(i,:)=(FR_STIM_X_Z(i,:)-mean(FR_STIM_X_Z(i,1:mid_idx),2))/std(FR_STIM_X_Z(i,1:mid_idx),1,2); %% Getting mu and SD form baseline
end
    
   
[~,fr_order]=sort(mean(Z_FR_STIM_X(:,mid_idx+1:end_idx),2));
imagesc('XData',WindowCenters_z./sr,'CData',Z_FR_STIM_X(fr_order,:));
xlim([-1 1]);
ylim([0 size(Z_FR_STIM_X,1)]);
ylabel('Units')
xlabel('Time(s)')
colormap(zscore_colormap);
c=colorbar('eastoutside');
    c.Label.String = 'Z score';
    caxis([-2, 4])
line([0 0],[0 size(FR_STIM_X_Z,1)],'LineWidth',1,'Color',[0 0 0])
if Units2plot==0
title('Z Score Firing Rate of Stim trials RSU, Neutral Exposure','fontweight','bold','fontsize',12,'fontname','times new roman');
elseif Units2plot==1
title('Z Score Firing Rate of Stim trials FSU, Neutral Exposure','fontweight','bold','fontsize',12,'fontname','times new roman');    
else
title('Z Score Firing Rate of Stim trials All Units,, Neutral Exposure','fontweight','bold','fontsize',12,'fontname','times new roman');    
end 

%%

clear all



