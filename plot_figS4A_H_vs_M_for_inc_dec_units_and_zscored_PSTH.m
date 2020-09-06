
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure S4.A.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('spike_data','var')==0 && exist('spike_data_description','var')==0 && exist('LFP_data','var')==0 && exist('LFP_data_description','var')==0
    [PathDatabase,spike_data,spike_data_description,LFP_data,LFP_data_description]=Load_Silicon_Probe_database;
end
%Load colormaps
load([PathDatabase filesep 'zscore_colormap.mat'])
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
bin_size_zscore=0.02; %20ms
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

%% Significantly modulated Hit units

P_values_neg_h=nan(size(DATA_2_PLOT,1),1);
P_values_pos_h=nan(size(DATA_2_PLOT,1),1);
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


%% Plot PSTH for Hit vs Miss trials for modulated units inc and dec

%Increasing units
Inc_DATA_H=DATA_2_PLOT(idx_p_value_pos_h_vect'==1);
FR_inc_hit=nan(size(Inc_DATA_H,1),(PostTime-PreTime)/bin_size);
FR_inc_miss=nan(size(Inc_DATA_H,1),(PostTime-PreTime)/bin_size);
FR_inc_hit_z=nan(size(Inc_DATA_H,1),(PostTime-PreTime)/bin_size_zscore);
FR_inc_miss_z=nan(size(Inc_DATA_H,1),(PostTime-PreTime)/bin_size_zscore);

for Unit=1:size(Inc_DATA_H,1)
    SpikeTimes=cell2mat(Inc_DATA_H{Unit, 1});
    Events_hit=spike_data.Session_StimTimes_Hit(Logical_units & Logical_task);
    Events_miss=spike_data.Session_StimTimes_Miss(Logical_units & Logical_task);
    Events_inc_hit=Events_hit(idx_p_value_pos_h_vect'==1);
    Events_inc_miss=Events_miss(idx_p_value_pos_h_vect'==1);
    EventTimes_hit=cell2mat(Events_inc_hit{Unit, 1});
    EventTimes_miss=cell2mat(Events_inc_miss{Unit, 1});
    
    FLTs_H=spike_data.Session_FirstLickTimes_Hit(Logical_units & Logical_task);
    FLTs_H_Inc=FLTs_H(idx_p_value_pos_h_vect'==1);
    FLTs_FA=spike_data.Session_FirstLickTimes_FalseAlarm(Logical_units & Logical_task);
    FLTs_FA_Inc=FLTs_FA(idx_p_value_pos_h_vect'==1);
    FirstLicksTimes=sort([cell2mat(FLTs_H_Inc{Unit, 1}) cell2mat(FLTs_FA_Inc{Unit, 1})]);
    
    for j=1:size(EventTimes_hit,2)
        premature_lick_indices=zeros(size(size(EventTimes)));
        for k=1:size(FirstLicksTimes,2)
            if 0<FirstLicksTimes(1,k)-EventTimes_hit(1,j) && FirstLicksTimes(1,k)-EventTimes_hit(1,j)<0.1*sr
                premature_lick_indices(k)=1;
            else
                premature_lick_indices(k)=0;
            end
        end
    end
    EventTimes_hit(premature_lick_indices==1)=[];
    
    for j=1:size(EventTimes_miss,2)
        premature_lick_indices=zeros(size(size(EventTimes)));
        for k=1:size(FirstLicksTimes,2)
            if 0<FirstLicksTimes(1,k)-EventTimes_miss(1,j) && FirstLicksTimes(1,k)-EventTimes_miss(1,j)<0.1*sr
                premature_lick_indices(k)=1;
            else
                premature_lick_indices(k)=0;
            end
        end
    end
    EventTimes_miss(premature_lick_indices==1)=[];
    
    [SpikeRates_hit,~]=PSTH_Simple(SpikeTimes,EventTimes_hit,PreTime,PostTime,sr,bin_size);    
    [SpikeRates_hit_z,~]=PSTH_Simple(SpikeTimes,EventTimes_hit,PreTime,PostTime,sr,bin_size_zscore);
    [SpikeRates_miss,~]=PSTH_Simple(SpikeTimes,EventTimes_miss,PreTime,PostTime,sr,bin_size);
    [SpikeRates_miss_z,~]=PSTH_Simple(SpikeTimes,EventTimes_miss,PreTime,PostTime,sr,bin_size_zscore);
   
    FR_inc_hit(Unit,:)=nanmean(SpikeRates_hit,2)';
    FR_inc_hit_z(Unit,:)=nanmean(SpikeRates_hit_z,2)';
    FR_inc_miss(Unit,:)=nanmean(SpikeRates_miss,2)';
    FR_inc_miss_z(Unit,:)=nanmean(SpikeRates_miss_z,2)';
end

%Remove the 10ms bin after stim and line interpolate.
mid_idx=2/bin_size/2;
ArtifactWindow=0.01;
firstIndextoExclude=mid_idx+1;
lastIndextoExclude=firstIndextoExclude+ArtifactWindow/bin_size-1;
L=lastIndextoExclude-firstIndextoExclude+1;
for Unit=1:size(FR_inc_hit,1)
    FR_inc_hit(Unit,firstIndextoExclude:lastIndextoExclude)=linspace(FR_inc_hit(Unit,firstIndextoExclude-1),FR_inc_hit(Unit,lastIndextoExclude+1),L);
    FR_inc_miss(Unit,firstIndextoExclude:lastIndextoExclude)=linspace(FR_inc_miss(Unit,firstIndextoExclude-1),FR_inc_miss(Unit,lastIndextoExclude+1),L);
end


%Decreasing Units
Dec_DATA_M=DATA_2_PLOT(idx_p_value_neg_h_vect'==1);
FR_dec_hit=nan(size(Dec_DATA_M,1),(PostTime-PreTime)/bin_size);
FR_dec_miss=nan(size(Dec_DATA_M,1),(PostTime-PreTime)/bin_size);
FR_dec_hit_z=nan(size(Dec_DATA_M,1),(PostTime-PreTime)/bin_size_zscore);
FR_dec_miss_z=nan(size(Dec_DATA_M,1),(PostTime-PreTime)/bin_size_zscore);

for Unit=1:size(Dec_DATA_M,1)
    SpikeTimes=cell2mat(Dec_DATA_M{Unit, 1});
    Events_Hit=spike_data.Session_StimTimes_Hit(Logical_units & Logical_task);
    Events_Miss=spike_data.Session_StimTimes_Miss(Logical_units & Logical_task);
    Events_dec_hit=Events_Hit(idx_p_value_neg_h_vect'==1);
    Events_dec_miss=Events_Miss(idx_p_value_neg_h_vect'==1);
    EventTimes_hit=cell2mat(Events_dec_hit{Unit, 1});
    EventTimes_miss=cell2mat(Events_dec_miss{Unit, 1});
    
    FLTs_H=spike_data.Session_FirstLickTimes_Hit(Logical_units & Logical_task);
    FLTs_H_Dec=FLTs_H(idx_p_value_neg_h_vect'==1);
    FLTs_FA=spike_data.Session_FirstLickTimes_FalseAlarm(Logical_units & Logical_task);
    FLTs_FA_Dec=FLTs_FA(idx_p_value_neg_h_vect'==1);
    FirstLicksTimes=sort([cell2mat(FLTs_H_Dec{Unit, 1}) cell2mat(FLTs_FA_Dec{Unit, 1})]);
    
    for j=1:size(EventTimes_hit,2)
        premature_lick_indices=zeros(size(size(EventTimes)));
        for k=1:size(FirstLicksTimes,2)
            if 0<FirstLicksTimes(1,k)-EventTimes_hit(1,j) && FirstLicksTimes(1,k)-EventTimes_hit(1,j)<0.1*sr
                premature_lick_indices(k)=1;
            else
                premature_lick_indices(k)=0;
            end
        end
    end
    EventTimes_hit(premature_lick_indices==1)=[];
    
    for j=1:size(EventTimes_miss,2)
        premature_lick_indices=zeros(size(size(EventTimes)));
        for k=1:size(FirstLicksTimes,2)
            if 0<FirstLicksTimes(1,k)-EventTimes_miss(1,j) && FirstLicksTimes(1,k)-EventTimes_miss(1,j)<0.1*sr
                premature_lick_indices(k)=1;
            else
                premature_lick_indices(k)=0;
            end
        end
    end
    EventTimes_miss(premature_lick_indices==1)=[];
    
    [SpikeRates_hit,~]= PSTH_Simple(SpikeTimes,EventTimes_hit,PreTime,PostTime,sr,bin_size);
    [SpikeRates_miss,~]= PSTH_Simple(SpikeTimes,EventTimes_miss,PreTime,PostTime,sr,bin_size);
    [SpikeRates_hit_z,~]= PSTH_Simple(SpikeTimes,EventTimes_hit,PreTime,PostTime,sr,bin_size_zscore);
    [SpikeRates_miss_z,~]= PSTH_Simple(SpikeTimes,EventTimes_miss,PreTime,PostTime,sr,bin_size_zscore);
    
    FR_dec_hit(Unit,:)=nanmean(SpikeRates_hit,2)';
    FR_dec_hit_z(Unit,:)=nanmean(SpikeRates_hit_z,2)';
    FR_dec_miss(Unit,:)=nanmean(SpikeRates_miss,2)';
    FR_dec_miss_z(Unit,:)=nanmean(SpikeRates_miss_z,2)';
end

%Remove the 10ms bin after stim and line interpolate.
firstIndextoExclude=mid_idx;
lastIndextoExclude=mid_idx+1;
L=lastIndextoExclude-firstIndextoExclude+1;
for Unit=1:size(FR_dec_hit,1)
    FR_dec_hit(Unit,firstIndextoExclude:lastIndextoExclude)=linspace(FR_dec_hit(Unit,firstIndextoExclude-1),FR_dec_hit(Unit,lastIndextoExclude+1),L);
    FR_dec_miss(Unit,firstIndextoExclude:lastIndextoExclude)=linspace(FR_dec_miss(Unit,firstIndextoExclude-1),FR_dec_miss(Unit,lastIndextoExclude+1),L);
end


Mean_FR_H_inc_hit=nanmean(FR_inc_hit,1);
Std_FR_H_inc_hit=nanstd(FR_inc_hit,[],1)/sqrt(size(FR_inc_hit,1));
Mean_FR_H_inc_miss=nanmean(FR_inc_miss,1);
Std_FR_H_inc_miss=nanstd(FR_inc_miss,[],1)/sqrt(size(FR_inc_miss,1));

Mean_FR_H_dec_hit=nanmean(FR_dec_hit,1);
Std_FR_H_dec_hit=nanstd(FR_dec_hit,[],1)/sqrt(size(FR_dec_hit,1));
Mean_FR_H_dec_miss=nanmean(FR_dec_miss,1);
Std_FR_H_dec_miss=nanstd(FR_dec_miss,[],1)/sqrt(size(FR_dec_miss,1));

Mean_FR_H_inc_hit_z=nanmean(FR_inc_hit_z,1);

fig1=figure;
ax(1)=subplot(3,1,[1 2]);
boundedline(WindowCenters./sr,Mean_FR_H_inc_hit,Std_FR_H_inc_hit,'r','alpha');
hold on
boundedline(WindowCenters./sr,Mean_FR_H_inc_miss,Std_FR_H_inc_miss,'k','alpha');
line([0 0],[0 20],'LineWidth',1,'Color',[0 0 0])
line([0.01 0.01],[0 20],'LineWidth',1,'Color',[0 0 0])
title('Hit vs Miss PSTH Inc RSU','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Firing Rate (Hz)')
legend('','Inc RSU Hit','','Inc RSU Miss')
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
    vect_fr_hit_inc=FR_inc_hit(:,k);
    vect_fr_miss_inc=FR_inc_miss(:,k);
    p_value_inc(k)=signrank(vect_fr_hit_inc,vect_fr_miss_inc);
end
y=[0 1];
imagesc(WindowCenters./sr,y,1-log(p_value_inc));
colormap(p_value_colormap2);
c=colorbar('southoutside','Ticks',[0,1-log(0.05),1-log(0.01),1-log(0.001),1-log(0.0001)],...
    'TickLabels',{num2str(0),num2str(0.05),num2str(0.01),num2str(0.001),num2str(0.0001)});
c.Label.String = 'p value';
caxis([1, 1-log(0.0005)])
xlim([-1 1]);



fig2=figure;
ax(1)=subplot(3,1,[1 2]);
boundedline(WindowCenters./sr,Mean_FR_H_dec_hit,Std_FR_H_dec_hit,'b','alpha');
hold on
boundedline(WindowCenters./sr,Mean_FR_H_dec_miss,Std_FR_H_dec_miss,'k','alpha');
line([0 0],[0 20],'LineWidth',1,'Color',[0 0 0])
line([0.01 0.01],[0 20],'LineWidth',1,'Color',[0 0 0])
title('Hit vs Miss PSTH Decreasing RSU','fontweight','bold','fontsize',12,'fontname','times new roman');
xlabel('Time(s)')
ylabel('Firing Rate (Hz)')
legend('','Dec RSU Hit','','Dec RSU Miss')
if Units2plot==0 || Units2plot==-1
    ylim([0 10]);
elseif Units2plot==1
    ylim([0 10]);
end

ax(2)=subplot(3,1,3);
linkaxes(ax,'x');
p_value_dec=nan(1,size(WindowCenters,2));
for k=1:size(WindowCenters,2)
    vect_fr_hit_dec=FR_dec_hit(:,k);
    vect_fr_miss_dec=FR_dec_miss(:,k);
    p_value_dec(k)=signrank(vect_fr_hit_dec,vect_fr_miss_dec);
end

y=[0 1];
imagesc(WindowCenters./sr,y,1-log(p_value_dec));
colormap(p_value_colormap2);
c=colorbar('southoutside','Ticks',[0,1-log(0.05),1-log(0.01),1-log(0.001),1-log(0.0001)],...
    'TickLabels',{num2str(0),num2str(0.05),num2str(0.01),num2str(0.001),num2str(0.0001)});
c.Label.String = 'p value';
caxis([1, 1-log(0.0005)])
xlim([-1 1]);

%% Z score Hit and Miss inc stim units
mid_idx=2/bin_size_zscore/2;
max_idx=size(Mean_FR_H_inc_hit_z,2);

fig3=figure;
Z_FR_Stim_inc_hit=zscore(FR_inc_hit_z,0,2);


for i=1:size(FR_inc_hit_z,1)
    Z_FR_Stim_inc_hit(i,:)=(FR_inc_hit_z(i,:)-mean(FR_inc_hit_z(i,1:mid_idx),2))/std(FR_inc_hit_z(i,1:mid_idx),1,2); %% Getting mu and SD form baseline
end

[~,fr_order]=sort(mean(Z_FR_Stim_inc_hit(:,21:max_idx),2));
imagesc('XData',WindowCenters./sr,'CData',Z_FR_Stim_inc_hit(fr_order,:));
xlim([-1 1]);
ylim([0 size(Z_FR_Stim_inc_hit,1)]);
ylabel('Units')
xlabel('Time(s)')
colormap(zscore_colormap);
c=colorbar('eastoutside');
c.Label.String = 'Z score';
caxis([-2, 4])
line([0 0],[0 size(FR_inc_hit_z,1)],'LineWidth',1,'Color',[0 0 0])
if Units2plot==0
    title('Z Score Firing Rate of Hit trials Inc. RSU','fontweight','bold','fontsize',12,'fontname','times new roman');
elseif Units2plot==1
    title('Z Score Firing Rate of Hit trials Inc. FSU','fontweight','bold','fontsize',12,'fontname','times new roman');
else
    title('Z Score Firing Rate of Hit trials Inc. All Units','fontweight','bold','fontsize',12,'fontname','times new roman');
end

fig4=figure;
Z_FR_Stim_inc_miss=zscore(FR_inc_miss_z,0,2);

for i=1:size(FR_inc_miss_z,1)
    Z_FR_Stim_inc_miss(i,:)=(FR_inc_miss_z(i,:)-mean(FR_inc_miss_z(i,1:mid_idx),2))/std(FR_inc_miss_z(i,1:mid_idx),1,2); %% Getting mu and SD form baseline
end

[~,fr_order]=sort(mean(Z_FR_Stim_inc_miss(:,21:max_idx),2));
imagesc('XData',WindowCenters./sr,'CData',Z_FR_Stim_inc_miss(fr_order,:));
xlim([-1 1]);
ylim([0 size(Z_FR_Stim_inc_miss,1)]);
ylabel('Units')
xlabel('Time(s)')
colormap(zscore_colormap);
c=colorbar('eastoutside');
c.Label.String = 'Z score';
caxis([-2, 4])
line([0 0],[0 size(FR_inc_miss_z,1)],'LineWidth',1,'Color',[0 0 0])
if Units2plot==0
    title('Z Score Firing Rate of Miss trials Inc. RSU' ,'fontweight','bold','fontsize',12,'fontname','times new roman');
elseif Units2plot==1
    title('Z Score Firing Rate of Miss trials Inc. FSU' ,'fontweight','bold','fontsize',12,'fontname','times new roman');
else
    title('Z Score Firing Rate of Miss trials Inc. All Units' ,'fontweight','bold','fontsize',12,'fontname','times new roman');
end



%% Z score Hit and Miss dec stim units

fig5=figure;
Z_FR_Stim_dec_hit=zscore(FR_dec_hit_z,0,2);

for i=1:size(FR_dec_hit_z,1)
    Z_FR_Stim_dec_hit(i,:)=(FR_dec_hit_z(i,:)-mean(FR_dec_hit_z(i,1:mid_idx),2))/std(FR_dec_hit_z(i,1:mid_idx),1,2); %% Getting mu and SD form baseline
end

[~,fr_order]=sort(mean(Z_FR_Stim_dec_hit(:,21:max_idx),2));
imagesc('XData',WindowCenters./sr,'CData',Z_FR_Stim_dec_hit(fr_order,:));
xlim([-1 1]);
ylim([0 size(Z_FR_Stim_dec_hit,1)]);
ylabel('Units')
xlabel('Time(s)')
colormap(zscore_colormap);
c=colorbar('eastoutside');
c.Label.String = 'Z score';
caxis([-2, 4])
line([0 0],[0 size(FR_dec_hit_z,1)],'LineWidth',1,'Color',[0 0 0])
if Units2plot==0
    title('Z Score Firing Rate of Hit trials Dec. RSU','fontweight','bold','fontsize',12,'fontname','times new roman');
elseif Units2plot==1
    title('Z Score Firing Rate of Hit trials Dec. FSU','fontweight','bold','fontsize',12,'fontname','times new roman');
else
    title('Z Score Firing Rate of Hit trials Dec. All Units','fontweight','bold','fontsize',12,'fontname','times new roman');
end

fig6=figure;
Z_FR_Stim_dec_miss=zscore(FR_dec_miss_z,0,2);

for i=1:size(FR_dec_miss_z,1)
    Z_FR_Stim_dec_miss(i,:)=(FR_dec_miss_z(i,:)-mean(FR_dec_miss_z(i,1:mid_idx),2))/std(FR_dec_miss_z(i,1:mid_idx),1,2); %% Getting mu and SD form baseline
end

[x,fr_order]=sort(mean(Z_FR_Stim_dec_miss(:,21:max_idx),2));
imagesc('XData',WindowCenters./sr,'CData',Z_FR_Stim_dec_miss(fr_order,:));
xlim([-1 1]);
ylim([0 size(Z_FR_Stim_dec_miss,1)]);
ylabel('Units')
xlabel('Time(s)')
colormap(zscore_colormap);
c=colorbar('eastoutside');
c.Label.String = 'Z score';
caxis([-2, 4])
line([0 0],[0 size(FR_dec_miss_z,1)],'LineWidth',1,'Color',[0 0 0])
if Units2plot==0
    title('Z Score Firing Rate of Miss trials Dec. RSU','fontweight','bold','fontsize',12,'fontname','times new roman');
elseif Units2plot==1
    title('Z Score Firing Rate of Miss trials FSU','fontweight','bold','fontsize',12,'fontname','times new roman');
else
    title('Z Score Firing Rate of Miss trials All Units','fontweight','bold','fontsize',12,'fontname','times new roman');
end

%%
clear all

