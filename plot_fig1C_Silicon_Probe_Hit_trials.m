%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure 1.C.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('spike_data','var')==0 && exist('spike_data_description','var')==0 && exist('LFP_data','var')==0 && exist('LFP_data_description','var')==0
[PathDatabase,spike_data,spike_data_description,LFP_data,LFP_data_description]=Load_Silicon_Probe_database;
end

%% Parameters
format long
set(0, 'DefaultFigureRenderer', 'painters')

Task='DT';
sr=spike_data_description.Cell_SpikeTimes.SamplingFrequencyHz;
sr_LFP=str2double(LFP_data_description.Trial_LFPs.SamplingFrequencyHz);
PreTime=-1;
PostTime=1;
WindowSize=0.01; %10ms
Units2plot=0; %-1: all 0:Regular spiking Units, 1:Fast spiking Units


Mice_Names=[spike_data.Mouse_Name{:}];
Mouse_list=unique(Mice_Names(strcmp(spike_data.Session_Type,Task)==1))';


%% LFP mPFC for Hit trials

Premature_lick_indices=zeros(size(spike_data.Mouse_Name));
Task_indices=strcmp(LFP_data.Session_Type,Task);
Hit_indices=LFP_data.Trial_ID==1;

for i=1:size(LFP_data.Mouse_Name)
    if isnan(LFP_data.Trial_FirstLickTime(i,1))
        Premature_lick_indices(i,1)=0;
    elseif (LFP_data.Trial_FirstLickTime(i,1)-LFP_data.Trial_StartTime(i,1))<200
        Premature_lick_indices(i,1)=1;
    end
end

Hit_LFPs=NaN(size(Mouse_list,1),32,(PostTime-PreTime)*sr_LFP+1); %mice*channels*time bins
Average_Hit_LFPs=NaN(size(Mouse_list,1),1,(PostTime-PreTime)*sr_LFP+1);

for i=1:size(Mouse_list,1)
    Mouse=Mouse_list(i);
    logical_mouse_LFP=zeros(size(spike_data.Mouse_Name));
    for j=1:size(LFP_data.Mouse_Name,1)
        logical_mouse_LFP(j,1)=strcmp(LFP_data.Mouse_Name{j,1},Mouse);
    end
    % Hit LFPs
    Hit_LFPs(i,:,:)=nanmean(LFP_data.Trial_LFPs((logical_mouse_LFP==1 & Premature_lick_indices==0 & Hit_indices),:,2000:6000)./4,1);
    % Average over channels
    Average_Hit_LFPs(i,:,:)=nanmean(Hit_LFPs(i,:,:),2);
end

GD_AVG_Hit=squeeze(nanmean(Average_Hit_LFPs,1))';
GD_SEM_Hit=squeeze(nanstd(Average_Hit_LFPs,[],1)/sqrt(size(Average_Hit_LFPs,1)))';

%Remove the 15ms bin after stim and line interpolate because of the coil artifact.
firstIndextoExclude=2000;
lastIndextoExclude=2030;
L=lastIndextoExclude-firstIndextoExclude+1;
GD_AVG_Hit(firstIndextoExclude:lastIndextoExclude)=linspace(GD_AVG_Hit(firstIndextoExclude),GD_AVG_Hit(lastIndextoExclude),L);
GD_SEM_Hit(firstIndextoExclude:lastIndextoExclude)=linspace(GD_SEM_Hit(firstIndextoExclude),GD_SEM_Hit(lastIndextoExclude),L);

fig1=figure;
t=linspace(PreTime,PostTime,sr_LFP*(PostTime-PreTime)+1);
boundedline(t,GD_AVG_Hit',GD_SEM_Hit','b','alpha');
line([0 0],[0 5],'LineWidth',1,'Color',[0 0 0])
title('mPFC Silicon Probe - LFP','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Amp (uV)')
xlim([-0.15 0.3]);
YLIMS=ylim;
line([0 0],YLIMS,'LineWidth',1,'Color',[0 0 0])
line([0.015 0.015],YLIMS,'LineWidth',1,'Color',[0 0 0])


%% PSTH Hit

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
FR_H=NaN(size(DATA_2_PLOT,1),(PostTime-PreTime)/WindowSize);

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
            end
        end
    end
    EventTimes(premature_lick_indices==1)=[];
    
    [SpikeRates,WindowCenters]= PSTH_Simple(SpikeTimes,EventTimes,PreTime,PostTime,sr,WindowSize);
    FR_H(Unit,:)=nanmean(SpikeRates,2)';
end

Mean_FR_H=nanmean(FR_H,1);
SEM_FR_H=nanstd(FR_H,[],1)/sqrt(size(FR_H,1));

%Remove the 10ms bin after stim and line interpolate.
mid_idx=2/WindowSize/2;
ArtifactWindow=0.01;
firstIndextoExclude=mid_idx+1;
lastIndextoExclude=firstIndextoExclude+ArtifactWindow/WindowSize-1;
L=lastIndextoExclude-firstIndextoExclude+1;
Mean_FR_H(:,firstIndextoExclude:lastIndextoExclude)=linspace(Mean_FR_H(:,firstIndextoExclude-1),Mean_FR_H(:,lastIndextoExclude+1),L);

fig2=figure;
boundedline(WindowCenters./sr,Mean_FR_H,SEM_FR_H,'b','alpha');
line([0 0],[0 5],'LineWidth',1,'Color',[0 0 0])
line([0.01 0.01],[0 5],'LineWidth',1,'Color',[0 0 0])
title('Hit PSTH mPFC RSU units','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Firing Rate (Hz)')
xlim([-0.15 0.3]);
if Units2plot==0 || Units2plot==-1
    ylim([0 3.5]);
elseif Units2plot==1
    ylim([0 10]);
end



%% Significantly modulated Hit units

%Initiating
bin_size=0.010; %bin size for bootstrap (not the same as the plotting bin size)

P_values_neg_h=NaN(size(DATA_2_PLOT,1),1);
P_values_pos_h=NaN(size(DATA_2_PLOT,1),1);
firing_rate_vector_H=NaN(size(DATA_2_PLOT,1),(PostTime-PreTime)/bin_size);

for Unit=1:size(DATA_2_PLOT,1)
    
    SpikeTimes=cell2mat(DATA_2_PLOT{Unit, 1});
    
    Events=spike_data.Session_StimTimes_Hit(Logical_units & Logical_task);
    EventTimes=cell2mat(Events{Unit,1});
    FLTs_H=spike_data.Session_FirstLickTimes_Hit(Logical_units & Logical_task);
    FirstLicksTimes=cell2mat(FLTs_H{Unit,1});
    
    % Removing trials with first lick before 100ms
    
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
    firing_rate_vector_H(Unit,:)=mean(SpikeRates,2);
    
    % Bootstrap Inc Dec units
    
    nboot=1000;
    
    fr_h_base=nanmean(SpikeRates(1:100,:),1);
    fr_h_stim=nanmean(SpikeRates(102:200,:),1);
    
    Diff_vect=bootstrp(nboot,@(x,y)mean(x-y),fr_h_stim',fr_h_base');
    
    p_value_neg=sum(Diff_vect>=0)/numel(Diff_vect);
    p_value_pos=sum(Diff_vect<=0)/numel(Diff_vect);
    
    P_values_neg_h(Unit)=p_value_neg;
    P_values_pos_h(Unit)=p_value_pos;
    
end

idx_p_value_neg_h_vect=(P_values_neg_h<0.05);
idx_p_value_pos_h_vect=(P_values_pos_h<0.05);


% Plot PSTH significantly Inc Dec RSU HIT


Mean_FR_H_inc=nanmean(firing_rate_vector_H(idx_p_value_pos_h_vect,:),1);
Sem_FR_H_inc=nanstd(firing_rate_vector_H(idx_p_value_pos_h_vect,:),[],1)/sqrt(sum(idx_p_value_pos_h_vect));

Mean_FR_H_dec=nanmean(firing_rate_vector_H(idx_p_value_neg_h_vect,:),1);
Sem_FR_H_dec=nanstd(firing_rate_vector_H(idx_p_value_neg_h_vect,:),[],1)/sqrt(sum(idx_p_value_neg_h_vect));


%Remove the 10ms bin after stim and line interpolate.
Mean_FR_H_inc(:,firstIndextoExclude:lastIndextoExclude)=linspace(Mean_FR_H_inc(:,firstIndextoExclude-1),Mean_FR_H_inc(:,lastIndextoExclude+1),L);
Mean_FR_H_dec(:,firstIndextoExclude:lastIndextoExclude)=linspace(Mean_FR_H_dec(:,firstIndextoExclude-1),Mean_FR_H_dec(:,lastIndextoExclude+1),L);


fig3=figure;
boundedline(WindowCenters./sr,Mean_FR_H_inc,Sem_FR_H_inc,'r','alpha');
hold on
boundedline(WindowCenters./sr,Mean_FR_H_dec,Sem_FR_H_dec,'b','alpha');
line([0 0],[0 20],'LineWidth',1,'Color',[0 0 0])
line([0.01 0.01],[0 20],'LineWidth',1,'Color',[0 0 0])
title('Coil PSTH Inc/Dec RS Units, Hit trials ','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Firing Rate (Hz)')
legend('','Inc RSU','','Dec RSU')
xlim([-0.15 0.3]);
if Units2plot==0 || Units2plot==-1
    ylim([0 8]);
elseif Units2plot==1
    ylim([0 8]);
end

%%

clear all