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
WindowSize=0.02; %bin size for plotting
Units2plot=0; %-1: all 0:Regular spiking Units, 1:Fast spiking Units

Mice_Names=[spike_data.Mouse_Name{:}];
Mouse_list=unique(Mice_Names(strcmp(spike_data.Session_Type,Task)==1))';

%% Significantly modulated Hit units 
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


%% Significantly modulated Miss units
  
    
P_values_neg_m=NaN(size(DATA_2_PLOT,1),1);
P_values_pos_m=NaN(size(DATA_2_PLOT,1),1);
firing_rate_vector_M=NaN(size(DATA_2_PLOT,1),(PostTime-PreTime)/bin_size);

for Unit=1:size(DATA_2_PLOT,1)
    
    SpikeTimes=cell2mat(DATA_2_PLOT{Unit, 1});
    
    Events=spike_data.Session_StimTimes_Miss(Logical_units & Logical_task);
    EventTimes=cell2mat(Events{Unit,1});

    [SpikeRates,WindowCenters]= PSTH_Simple(SpikeTimes,EventTimes,PreTime,PostTime,sr,bin_size);
    firing_rate_vector_M(Unit,:)=mean(SpikeRates,2);
    
    % Bootstrap Inc Dec units
    
    nboot=1000;
    
    fr_m_base=nanmean(SpikeRates(1:100,:),1);
    fr_m_stim=nanmean(SpikeRates(102:200,:),1);
    
    Diff_vect=bootstrp(nboot,@(x,y)mean(x-y),fr_m_stim',fr_m_base');
    
    p_value_neg=sum(Diff_vect>=0)/numel(Diff_vect);
    p_value_pos=sum(Diff_vect<=0)/numel(Diff_vect);
    
    P_values_neg_m(Unit)=p_value_neg;
    P_values_pos_m(Unit)=p_value_pos;
    
end

idx_p_value_neg_m_vect=(P_values_neg_m<0.05);
idx_p_value_pos_m_vect=(P_values_pos_m<0.05);

%% Scatter Plot

H=nanmean(firing_rate_vector_H(:,101:200),2)-nanmean(firing_rate_vector_H(:,1:99),2);  
M=nanmean(firing_rate_vector_M(:,101:200),2)-nanmean(firing_rate_vector_M(:,1:99),2);
idx_pos=zeros(1,size(idx_p_value_pos_h_vect,2));
idx_neg=zeros(1,size(idx_p_value_pos_h_vect,2));

for i=1:size(DATA_2_PLOT,1)
    if idx_p_value_pos_h_vect(i)==1 && idx_p_value_pos_m_vect(i)==1
        idx_pos(i)=1;
    elseif idx_p_value_pos_h_vect(i)==1 && idx_p_value_pos_m_vect(i)==0
        idx_pos(i)=2;
    end
    
    if idx_p_value_neg_h_vect(i)==1 && idx_p_value_neg_m_vect(i)==1
        idx_neg(i)=1;
        elseif idx_p_value_neg_h_vect(i)==1 && idx_p_value_neg_m_vect(i)==0
        idx_neg(i)=2;
    end
    
end   

 H_inc1=nanmean(firing_rate_vector_H(idx_pos==1,101:200),2)-nanmean(firing_rate_vector_H(idx_pos==1,1:99),2);
 M_inc1=nanmean(firing_rate_vector_M(idx_pos==1,101:200),2)-nanmean(firing_rate_vector_M(idx_pos==1,1:99),2);
 H_dec1=nanmean(firing_rate_vector_H(idx_neg==1,101:200),2)-nanmean(firing_rate_vector_H(idx_neg==1,1:99),2);
 M_dec1=nanmean(firing_rate_vector_M(idx_neg==1,101:200),2)-nanmean(firing_rate_vector_M(idx_neg==1,1:99),2);
 
 H_inc2=nanmean(firing_rate_vector_H(idx_pos==2,101:200),2)-nanmean(firing_rate_vector_H(idx_pos==2,1:99),2);
 M_inc2=nanmean(firing_rate_vector_M(idx_pos==2,101:200),2)-nanmean(firing_rate_vector_M(idx_pos==2,1:99),2);
 H_dec2=nanmean(firing_rate_vector_H(idx_neg==2,101:200),2)-nanmean(firing_rate_vector_H(idx_neg==2,1:99),2);
 M_dec2=nanmean(firing_rate_vector_M(idx_neg==2,101:200),2)-nanmean(firing_rate_vector_M(idx_neg==2,1:99),2);
 


figure;
h2=scatter(H_inc1,H_inc1-M_inc1,'r');
    set(h2, 'Marker', 'o')
    set(h2, 'MarkerFaceColor',[1 1 1])
    set(h2, 'MarkerEdgeColor', 'r')
    set(h2, 'SizeData', 150) 

hold on
h3=scatter(H_dec1,H_dec1-M_dec1,'b');
    set(h3, 'Marker', 'o')
    set(h3, 'MarkerFaceColor',[1 1 1])
    set(h3, 'MarkerEdgeColor', 'b')
    set(h3, 'SizeData', 150)
   
h4=scatter(H_inc2,H_inc2-M_inc2,'r','filled');
    set(h4, 'Marker', 'o')
    set(h4, 'MarkerEdgeColor', 'r')
    set(h4, 'SizeData', 150)
   
h5=scatter(H_dec2,H_dec2-M_dec2,'b','filled');
    set(h5, 'Marker', 'o')
    set(h5, 'MarkerEdgeColor', 'b')
    set(h5, 'SizeData', 150)    
ylim([-5 10]);
xlim([-5 10]);
 line([0 0],[-10 25],'Color','k')
line([-10 25],[0 0],'Color','k')

title('Scatter plot modulated units','fontweight','bold','fontsize',12,'fontname','times new roman');

  xlabel({'Rate change Hit trials (Hz)'}); 
  ylabel({'Hit-Miss (Hz)'}); 

  %%
  clear all
