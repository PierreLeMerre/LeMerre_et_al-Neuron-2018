
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure S3.B.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('spike_data','var')==0 && exist('spike_data_description','var')==0 && exist('LFP_data','var')==0 && exist('LFP_data_description','var')==0
    [PathDatabase,spike_data,spike_data_description,LFP_data,LFP_data_description]=Load_Silicon_Probe_database;
end
%p_value colormap2
load([PathDatabase filesep 'p_value_colormap2.mat'])
%% Parameters
format long
set(0, 'DefaultFigureRenderer', 'painters')

Task='DT';
sr=spike_data_description.Cell_SpikeTimes.SamplingFrequencyHz;
sr_LFP=str2double(LFP_data_description.Trial_LFPs.SamplingFrequencyHz);
PreTime=-1;
PostTime=1;
bin_size=0.01; %10ms
Units2plot=0; %-1: all 0:Regular spiking Units, 1:Fast spiking Units

Mice_Names=[spike_data.Mouse_Name{:}];
Mouse_list=unique(Mice_Names(strcmp(spike_data.Session_Type,Task)==1))';

%% PSTH Hit

Logical_task=strcmp(spike_data.Session_Type,Task);

if Units2plot==0
    Logical_units=logical(spike_data.Cell_RS);
elseif Units2plot==1
    Logical_units=logical(spike_data.Cell_FS);
end

DATA_2_PLOT=spike_data.Cell_SpikeTimes(Logical_units & Logical_task);

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


%% Compute latency for Stim trials using catch trials

Inc_DATA=DATA_2_PLOT(idx_p_value_pos_h_vect'==1); %significantly increasing units during hit trials
FR_Stim_inc_stim=nan(size(Inc_DATA,1),(PostTime-PreTime)/bin_size);
FR_Stim_inc_nostim=nan(size(Inc_DATA,1),(PostTime-PreTime)/bin_size);

for Unit=1:size(Inc_DATA,1)
    SpikeTimes=cell2mat(Inc_DATA{Unit, 1});
    Events_stim=spike_data.Session_StimTimes(Logical_units & Logical_task);
    Events_nostim=spike_data.Session_NoStimTimes(Logical_units & Logical_task);
    Events_inc_stim=Events_stim(idx_p_value_pos_h_vect'==1);
    Events_inc_nostim=Events_nostim(idx_p_value_pos_h_vect'==1);
    EventTimes_stim=cell2mat(Events_inc_stim{Unit, 1});
    EventTimes_nostim=cell2mat(Events_inc_nostim{Unit, 1});
    
    FLTs_H=spike_data.Session_FirstLickTimes_Hit(Logical_units & Logical_task);
    FLTs_H_Inc=FLTs_H(idx_p_value_pos_h_vect'==1);
    FLTs_FA=spike_data.Session_FirstLickTimes_FalseAlarm(Logical_units & Logical_task);
    FLTs_FA_Inc=FLTs_FA(idx_p_value_pos_h_vect'==1);
    FirstLicksTimes=sort([cell2mat(FLTs_H_Inc{Unit, 1}) cell2mat(FLTs_FA_Inc{Unit, 1})]);
    
    for j=1:size(EventTimes_stim,2)
        premature_lick_indices=zeros(size(size(EventTimes)));
        for k=1:size(FirstLicksTimes,2)
            if 0<FirstLicksTimes(1,k)-EventTimes_stim(1,j) && FirstLicksTimes(1,k)-EventTimes_stim(1,j)<0.1*sr
                premature_lick_indices(k)=1;
            else
                premature_lick_indices(k)=0;
            end
        end
    end
    EventTimes_stim(premature_lick_indices==1)=[];
    
    for j=1:size(EventTimes_nostim,2)
        premature_lick_indices=zeros(size(size(EventTimes)));
        for k=1:size(FirstLicksTimes,2)
            if 0<FirstLicksTimes(1,k)-EventTimes_nostim(1,j) && FirstLicksTimes(1,k)-EventTimes_nostim(1,j)<0.1*sr
                premature_lick_indices(k)=1;
            else
                premature_lick_indices(k)=0;
            end
        end
        
    end
    EventTimes_nostim(premature_lick_indices==1)=[];
    
    [SpikeRates_stim,~]= PSTH_Simple(SpikeTimes,EventTimes_stim,PreTime,PostTime,sr,bin_size);
    [SpikeRates_nostim,~]= PSTH_Simple(SpikeTimes,EventTimes_nostim,PreTime,PostTime,sr,bin_size);
    FR_Stim_inc_stim(Unit,:)=nanmean(SpikeRates_stim,2)';
    FR_Stim_inc_nostim(Unit,:)=nanmean(SpikeRates_nostim,2)';
end

%Remove the 10ms bin after stim and line interpolate.
mid_idx=2/bin_size/2;
firstIndextoExclude=mid_idx-1;
lastIndextoExclude=mid_idx+2;
L=lastIndextoExclude-firstIndextoExclude+1;
for Unit=1:size(FR_Stim_inc_stim,1)
    FR_Stim_inc_stim(Unit,firstIndextoExclude:lastIndextoExclude)=linspace(FR_Stim_inc_stim(Unit,firstIndextoExclude),FR_Stim_inc_stim(Unit,lastIndextoExclude),L);
    FR_Stim_inc_nostim(Unit,firstIndextoExclude:lastIndextoExclude)=linspace(FR_Stim_inc_nostim(Unit,firstIndextoExclude),FR_Stim_inc_nostim(Unit,lastIndextoExclude),L);
end





Dec_DATA=DATA_2_PLOT(idx_p_value_neg_h_vect'==1);  %significantly increasing units during hit trials
FR_Stim_dec_stim=nan(size(Dec_DATA,1),(PostTime-PreTime)/bin_size);
FR_Stim_dec_nostim=nan(size(Dec_DATA,1),(PostTime-PreTime)/bin_size);


for Unit=1:size(Dec_DATA,1)
    SpikeTimes=cell2mat(Dec_DATA{Unit, 1});
    Events_stim=spike_data.Session_StimTimes(Logical_units & Logical_task);
    Events_nostim=spike_data.Session_NoStimTimes(Logical_units & Logical_task);
    Events_dec_stim=Events_stim(idx_p_value_neg_h_vect'==1);
    Events_dec_nostim=Events_nostim(idx_p_value_neg_h_vect'==1);
    EventTimes_stim=cell2mat(Events_dec_stim{Unit, 1});
    EventTimes_nostim=cell2mat(Events_dec_nostim{Unit, 1});
    
    FLTs_H=spike_data.Session_FirstLickTimes_Hit(Logical_units & Logical_task);
    FLTs_H_Dec=FLTs_H(idx_p_value_neg_h_vect'==1);
    FLTs_FA=spike_data.Session_FirstLickTimes_FalseAlarm(Logical_units & Logical_task);
    FLTs_FA_Dec=FLTs_FA(idx_p_value_neg_h_vect'==1);
    FirstLicksTimes=sort([cell2mat(FLTs_H_Dec{Unit, 1}) cell2mat(FLTs_FA_Dec{Unit, 1})]);
    
    for j=1:size(EventTimes_stim,2)
        premature_lick_indices=zeros(size(size(EventTimes)));
        for k=1:size(FirstLicksTimes,2)
            if 0<FirstLicksTimes(1,k)-EventTimes_stim(1,j) && FirstLicksTimes(1,k)-EventTimes_stim(1,j)<0.1*sr
                premature_lick_indices(k)=1;
            else
                premature_lick_indices(k)=0;
            end
        end
    end
    EventTimes_stim(premature_lick_indices==1)=[];
    
    for j=1:size(EventTimes_nostim,2)
        premature_lick_indices=zeros(size(size(EventTimes)));
        for k=1:size(FirstLicksTimes,2)
            if 0<FirstLicksTimes(1,k)-EventTimes_nostim(1,j) && FirstLicksTimes(1,k)-EventTimes_nostim(1,j)<0.1*sr
                premature_lick_indices(k)=1;
            else
                premature_lick_indices(k)=0;
            end
        end
    end
    EventTimes_nostim(premature_lick_indices==1)=[];
    
    [SpikeRates_stim,~]= PSTH_Simple(SpikeTimes,EventTimes_stim,PreTime,PostTime,sr,bin_size);
    [SpikeRates_nostim,~]= PSTH_Simple(SpikeTimes,EventTimes_nostim,PreTime,PostTime,sr,bin_size);
    FR_Stim_dec_stim(Unit,:)=nanmean(SpikeRates_stim,2)';
    FR_Stim_dec_nostim(Unit,:)=nanmean(SpikeRates_nostim,2)';
end

%Remove the 10ms bin after stim and line interpolate.
firstIndextoExclude=mid_idx-1;
lastIndextoExclude=mid_idx+2;
L=lastIndextoExclude-firstIndextoExclude+1;
for Unit=1:size(FR_Stim_dec_stim,1)
    FR_Stim_dec_stim(Unit,firstIndextoExclude:lastIndextoExclude)=linspace(FR_Stim_dec_stim(Unit,firstIndextoExclude),FR_Stim_dec_stim(Unit,lastIndextoExclude),L);
    FR_Stim_dec_nostim(Unit,firstIndextoExclude:lastIndextoExclude)=linspace(FR_Stim_dec_nostim(Unit,firstIndextoExclude),FR_Stim_dec_nostim(Unit,lastIndextoExclude),L);
end

Mean_FR_STIM_inc_stim=nanmean(FR_Stim_inc_stim,1);
Std_FR_STIM_inc_stim=nanstd(FR_Stim_inc_stim,[],1)/sqrt(size(FR_Stim_inc_stim,1));
Mean_FR_STIM_inc_nostim=nanmean(FR_Stim_inc_nostim,1);
Std_FR_STIM_inc_nostim=nanstd(FR_Stim_inc_nostim,[],1)/sqrt(size(FR_Stim_inc_nostim,1));

Mean_FR_STIM_dec_stim=nanmean(FR_Stim_dec_stim,1);
Std_FR_STIM_dec_stim=nanstd(FR_Stim_dec_stim,[],1)/sqrt(size(FR_Stim_dec_stim,1));
Mean_FR_STIM_dec_nostim=nanmean(FR_Stim_dec_nostim,1);
Std_FR_STIM_dec_nostim=nanstd(FR_Stim_dec_nostim,[],1)/sqrt(size(FR_Stim_dec_nostim,1));


fig7=figure;
ax(1)=subplot(3,1,[1 2]);
boundedline(WindowCenters./sr,Mean_FR_STIM_inc_stim,Std_FR_STIM_inc_stim,'r','alpha');
hold on
boundedline(WindowCenters./sr,Mean_FR_STIM_inc_nostim,Std_FR_STIM_inc_nostim,'k','alpha');
line([0 0],[0 20],'LineWidth',1,'Color',[0 0 0])
line([0.01 0.01],[0 20],'LineWidth',1,'Color',[0 0 0])
title('Stim/NoStim PSTH Increasing Hit RSU','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Firing Rate (Hz)')
legend('','Stim','','No Stim')
%xlim([-0.15 0.3]);
if Units2plot==0 || Units2plot==-1
    ylim([0 10]);
elseif Units2plot==1
    ylim([0 10]);
end

ax(2)=subplot(3,1,3);
linkaxes(ax,'x');

p_value_inc=nan(1,size(WindowCenters,2));
for k=1:size(WindowCenters,2)
    vect_fr_stim_inc=FR_Stim_inc_stim(:,k);
    vect_fr_nostim_inc=FR_Stim_inc_nostim(:,k);
    p_value_inc(k)=signrank(vect_fr_stim_inc,vect_fr_nostim_inc);
end

y=[0 1];
imagesc(WindowCenters./sr,y,1-log(p_value_inc));
colormap(p_value_colormap2);
c=colorbar('southoutside','Ticks',[0,1-log(0.05),1-log(0.01),1-log(0.001),1-log(0.0001)],...
    'TickLabels',{num2str(0),num2str(0.05),num2str(0.01),num2str(0.001),num2str(0.0001)});
c.Label.String = 'p value';
caxis([1, 1-log(0.0005)])
xlim([-0.1 1]);




fig8=figure;
ax(1)=subplot(3,1,[1 2]);
boundedline(WindowCenters./sr,Mean_FR_STIM_dec_stim,Std_FR_STIM_dec_stim,'b','alpha');
hold on
boundedline(WindowCenters./sr,Mean_FR_STIM_dec_nostim,Std_FR_STIM_dec_nostim,'k','alpha');
line([0 0],[0 20],'LineWidth',1,'Color',[0 0 0])
line([0.01 0.01],[0 20],'LineWidth',1,'Color',[0 0 0])
title('Stim/NoStim PSTH Decreasing Hit RSU','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Firing Rate (Hz)')
legend('','Stim','','No Stim')
if Units2plot==0 || Units2plot==-1
    ylim([0 10]);
elseif Units2plot==1
    ylim([0 10]);
end

ax(2)=subplot(3,1,3);
linkaxes(ax,'x');
p_value_dec=nan(1,size(WindowCenters,2));
for k=1:size(WindowCenters,2)
    vect_fr_stim_dec=FR_Stim_dec_stim(:,k);
    vect_fr_nostim_dec=FR_Stim_dec_nostim(:,k);
    p_value_dec(k)=signrank(vect_fr_stim_dec,vect_fr_nostim_dec);
end

y=[0 1];
imagesc(WindowCenters./sr,y,1-log(p_value_dec));
colormap(p_value_colormap2);
c=colorbar('southoutside','Ticks',[0,1-log(0.05),1-log(0.01),1-log(0.001),1-log(0.0001)],...
    'TickLabels',{num2str(0),num2str(0.05),num2str(0.01),num2str(0.001),num2str(0.0001)});
c.Label.String = 'p value';
caxis([1, 1-log(0.0005)])
xlim([-0.1 1]);

%%

clear all

