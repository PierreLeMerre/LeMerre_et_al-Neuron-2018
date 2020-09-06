%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure 4.B.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('PathDatabase','var')==0 && exist('LFP_Data','var')==0 && exist('LFP_Data_description','var')==0
[PathDatabase,LFP_Data,LFP_Data_description]=Load_LFP_Multisite_database;
end
%learned days
load([PathDatabase filesep 'Learning_Days_Mtrx.mat']);

%% Parameters
Mouse_list=unique(LFP_Data.Mouse_Name(strcmp(LFP_Data.Session_Type,'DT')==1));
sr=str2double(LFP_Data_description.Trial_LFP_wS1.SamplingFrequencyHz);
t=linspace(0,5,sr*5);
Stimtime=3; %in sec
Baseline_duration=100; %in samples

%% time windows in samples to look for peak amplitude for every channel
% (before first lick time)
Peak_window_in.wS1=12+6000;
Peak_window_in.wS2=12+6000;
Peak_window_in.wM1=20+6000;
Peak_window_in.PtA=20+6000;
Peak_window_in.dCA1=40+6000;
Peak_window_in.mPFC=60+6000;

Peak_window_out.wS1=80+6000;
Peak_window_out.wS2=100+6000;
Peak_window_out.wM1=100+6000;
Peak_window_out.PtA=120+6000;
Peak_window_out.dCA1=200+6000;
Peak_window_out.mPFC=200+6000;

%% Compute SEPs
Fields={'wS1','wS2','wM1','PtA','dCA1','mPFC'};
data_mouse_D1=[];
data_mouse_Exposed=[];

for j=1:6
    Field=char(Fields(j));
    
    for i=1:size(Mouse_list,1)
        Mouse=char(Mouse_list(i));
        eval(['data_mouse_H.' Field '(i,:)=nanmean(LFP_Data.Trial_LFP_' Field '(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(i,1) | LFP_Data.Session_Counter==LDM(i,2) | LFP_Data.Session_Counter==LDM(i,3)] & [LFP_Data.Trial_ID==1],:));'])
        eval(['data_mouse_H.' Field '(i,:)=data_mouse_H.' Field '(i,:)-nanmean(data_mouse_H.' Field '(i,Stimtime*sr-Baseline_duration:Stimtime*sr),2);'])
        eval(['data_mouse_M.' Field '(i,:)=nanmean(LFP_Data.Trial_LFP_' Field '(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(i,1) | LFP_Data.Session_Counter==LDM(i,2) | LFP_Data.Session_Counter==LDM(i,3)] & [LFP_Data.Trial_ID==0],:));'])
        eval(['data_mouse_M.' Field '(i,:)=data_mouse_M.' Field '(i,:)-nanmean(data_mouse_M.' Field '(i,Stimtime*sr-Baseline_duration:Stimtime*sr),2);'])
        
    end
    
    for i=1:size(Mouse_list,1)
        Mouse=char(Mouse_list(i));
        eval(['data_mouse_Learned.' Field '(i,:)=nanmean(LFP_Data.Trial_LFP_' Field '(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(i,1) | LFP_Data.Session_Counter==LDM(i,2) | LFP_Data.Session_Counter==LDM(i,3)] & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0],:));'])
        eval(['data_mouse_Learned.' Field '(i,:)=data_mouse_Learned.' Field '(i,:)-nanmean(data_mouse_Learned.' Field '(i,Stimtime*sr-Baseline_duration:Stimtime*sr),2);'])
        
     end    
        
end


%% Mesure Peak
Ref_Peak_Learned=[];
Peak_loc=[];
Peaks_H=[];
Peaks_M=[];
idx=[];
idx_learned=[];
idx2=[];


%Ref peaks from trained animals all stim trials
for j=1:6
    Field=char(Fields(j));
    for i=1:size(Mouse_list,1)
        if strcmp(Field,'mPFC')==1
            eval(['Ref_Peak_Learned.' Field '(i)=max(data_mouse_Learned.' Field '(i,Peak_window_in.' Field ':Peak_window_out.' Field '),[],2);'])
            eval(['P=Ref_Peak_Learned.' Field '(i);'])
            if isnan(P)==0
            eval(['idx.' Field '(i)=find(data_mouse_Learned.' Field '(i,Peak_window_in.' Field ':Peak_window_out.' Field ')==(Ref_Peak_Learned.' Field '(i)));'])
            else
            eval(['idx.' Field '(i)=nan;'])
            end    
        else
            eval(['Ref_Peak_Learned.' Field '(i)=min(data_mouse_Learned.' Field '(i,Peak_window_in.' Field ':Peak_window_out.' Field '),[],2);'])
                        eval(['P=Ref_Peak_Learned.' Field '(i);'])
            if isnan(P)==0
            eval(['idx.' Field '(i)=find(data_mouse_Learned.' Field '(i,Peak_window_in.' Field ':Peak_window_out.' Field ')==(Ref_Peak_Learned.' Field '(i)));'])
            else
            eval(['idx.' Field '(i)=nan;'])
            end 
        end        
    end
    eval(['idx_learned.' Field '=nanmean(idx.' Field ');'])
end

for j=1:6
    Field=char(Fields(j));
    for i=1:size(Mouse_list,1)
        
        if strcmp(Field,'mPFC')==1
                        
           
                eval(['Peak_loc.' Field '(i)=idx_learned.' Field '+Peak_window_in.' Field ';'])
                eval(['Peaks_H.' Field '(i)=mean(data_mouse_H.' Field '(i,round(Peak_loc.' Field '(i))-5:round(Peak_loc.' Field '(i))+5),2);'])
                eval(['Peaks_M.' Field '(i)=mean(data_mouse_M.' Field '(i,round(Peak_loc.' Field '(i))-5:round(Peak_loc.' Field '(i))+5),2);'])
            
        else

                eval(['Peak_loc.' Field '(i)=idx_learned.' Field '+Peak_window_in.' Field ';'])
                eval(['Peaks_H.' Field '(i)=mean(data_mouse_H.' Field '(i,round(Peak_loc.' Field '(i))-5:round(Peak_loc.' Field '(i))+5),2);'])
                eval(['Peaks_M.' Field '(i)=mean(data_mouse_M.' Field '(i,round(Peak_loc.' Field '(i))-5:round(Peak_loc.' Field '(i))+5),2);'])

            
        end
    end
end

Peaks_H.mPFC(12)=NaN; %Not enought misses (n=1)
Peaks_M.mPFC(12)=NaN;

%% Compute Amplitude p values

for j=1:6
    Field=char(Fields(j));
    if j~=6
        eval(['p_value(j)=signrank(Peaks_H.' Field '*-10^(6),Peaks_M.' Field '*-10^(6));'])
    else
        eval(['p_value(j)=signrank(Peaks_H.' Field '*10^(6),Peaks_M.' Field '*10^(6));'])
    end
    
end

%% Plot peak amplitude with SD

Peaks_H.wS1=Peaks_H.wS1';
Peaks_H.wS2=Peaks_H.wS2';
Peaks_H.wM1=Peaks_H.wM1';
Peaks_H.PtA=Peaks_H.PtA';
Peaks_H.dCA1=Peaks_H.dCA1';
Peaks_H.mPFC=Peaks_H.mPFC';

Peaks_M.wS1=Peaks_M.wS1';
Peaks_M.wS2=Peaks_M.wS2';
Peaks_M.wM1=Peaks_M.wM1';
Peaks_M.PtA=Peaks_M.PtA';
Peaks_M.dCA1=Peaks_M.dCA1';
Peaks_M.mPFC=Peaks_M.mPFC';


figure
for j=1:6
    Field=char(Fields(j));
    ax(1)=subplot(3,2,j);
    if j~=6
        eval(['temp=[Peaks_H.' Field '*-10^(6) Peaks_M.' Field '*-10^(6)];'])
        plot(temp','color',[0.5,0.5,0.5]);
        hold on
        eval(['temp1=[nanmean(Peaks_H.' Field '*-10^(6),1)  NaN];'])
        eval(['temp2=[NaN nanmean(Peaks_M.' Field '*-10^(6),1)];'])
        
        eval(['SemH=[nanstd((Peaks_H.' Field '*-10^(6)),[],1); NaN];'])
        eval(['SemM=[NaN; nanstd((Peaks_M.' Field '*-10^(6)),[],1)];'])
    else
        eval(['temp=[Peaks_H.' Field '*10^(6) Peaks_M.' Field '*10^(6)];'])
        plot(temp','color',[0.5,0.5,0.5]);
        hold on
        eval(['temp1=[nanmean(Peaks_H.' Field '*10^(6),1)  NaN];'])
        eval(['temp2=[NaN nanmean(Peaks_M.' Field '*10^(6),1)];'])
        
        eval(['SemH=[nanstd((Peaks_H.' Field '*10^(6)),[],1); NaN];'])
        eval(['SemM=[NaN; nanstd((Peaks_M.' Field '*10^(6)),[],1)];'])
    end
    errorbar(temp1,SemH,'ro');
    errorbar(temp2,SemM,'ko');
    title(Field ,'fontweight','bold','fontsize',12,'fontname','times new roman');
    xlim([0.5 2.5]);
    NumTicks = 4;
    L1 = get(gca,'XLim');
    set(gca,'XTick',linspace(L1(1),L1(2),NumTicks))
    set(gca,'XTickLabel',{'','H','M',''})
    ylabel('Amp (\muV)')
    
    if strcmp(Field,'wS1')==1
        ylim([100 500]);
        NumTicks = 5;
    elseif strcmp(Field,'wS2')==1
        ylim([0 300]);
    elseif strcmp(Field,'wM1')==1
        ylim([0 200]);
    elseif strcmp(Field,'PtA')==1
        ylim([-50 200]);
    elseif strcmp(Field,'dCA1')==1
        ylim([-50 200]);
    elseif strcmp(Field,'mPFC')==1
        ylim([-50 200]);
    end
    
    if p_value(j)<0.05
        xlabel(['p=' num2str(p_value(j))],'color','r')
    else
        xlabel(['p=' num2str(p_value(j))])
    end
    
end

%%
clear all


