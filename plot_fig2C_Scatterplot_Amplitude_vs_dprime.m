%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure 2.C.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('PathDatabase','var')==0 && exist('LFP_Data','var')==0 && exist('LFP_Data_description','var')==0
    [PathDatabase,LFP_Data,LFP_Data_description]=Load_LFP_Multisite_database;
end
%learned days
load([PathDatabase filesep 'Learning_Days_Mtrx.mat']);
%Load colormap
load([PathDatabase filesep 'scatterplot_colormap.mat']);

%% Parameters
Mouse_list_DT=unique(LFP_Data.Mouse_Name(strcmp(LFP_Data.Session_Type,'DT')==1));
sr=str2double(LFP_Data_description.Trial_LFP_wS1.SamplingFrequencyHz);
t=linspace(0,5,sr*5);
Stimtime=3; %in sec
Baseline_duration=100; %in samples

% time windows in samples to look for peak amplitude for every channel
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

data_mouse_Learned=[];
% Compute Learned SEP to get the peak location for every mouse
for j=1:6
    Field=char(Fields(j));
    for i=1:size(Mouse_list_DT,1)
        Mouse=char(Mouse_list_DT(i));
        eval(['data_mouse_Learned.' Field '(i,:)=nanmean(LFP_Data.Trial_LFP_' Field '(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(i,1) | LFP_Data.Session_Counter==LDM(i,2) | LFP_Data.Session_Counter==LDM(i,3)] & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0],:));'])
        eval(['data_mouse_Learned.' Field '(i,:)=data_mouse_Learned.' Field '(i,:)-nanmean(data_mouse_Learned.' Field '(i,Stimtime*sr-Baseline_duration:Stimtime*sr),2);'])
    end
end

data_mouse_Days=[];
for l=1:13
    for j=1:6
        Field=char(Fields(j));
        eval(['data_mouse_Days.D' num2str(l) '.' Field '=NaN(14,10000);'])
    end
end


for j=1:6
    Field=char(Fields(j));
    for i=1:size(Mouse_list_DT,1)
        Mouse=char(Mouse_list_DT(i));
        Session_nb=unique(LFP_Data.Session_Counter(strcmp(LFP_Data.Mouse_Name,Mouse)==1));
        for l=1:size(Session_nb,1)
            ss_nb=Session_nb(l);
            eval(['data_mouse_Days.D' num2str(ss_nb) '.' Field '(i,:)=nanmean(LFP_Data.Trial_LFP_' Field '(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==ss_nb & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0],:));'])
            eval(['data_mouse_Days.D' num2str(ss_nb) '.' Field '(i,:)=data_mouse_Days.D' num2str(ss_nb) '.' Field '(i,:)-nanmean(data_mouse_Days.D' num2str(ss_nb) '.' Field '(i,Stimtime*sr-Baseline_duration:Stimtime*sr),2);'])
            
        end
    end
end

%% Mesure Peaks

%Ref peaks from trained animals all stim trials
for j=1:6
    Field=char(Fields(j));
    for i=1:size(Mouse_list_DT,1)
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

Peak_mouse_Days=[];
for l=1:13
    for j=1:6
        Field=char(Fields(j));
        eval(['Peak_mouse_Days.D' num2str(l) '.' Field '=NaN(14,1);'])
    end
end

for j=1:6
    Field=char(Fields(j));
    for i=1:size(Mouse_list_DT,1)
        Mouse=char(Mouse_list_DT(i));
        Session_nb=unique(LFP_Data.Session_Counter(strcmp(LFP_Data.Mouse_Name,Mouse)==1));
        for l=1:size(Session_nb,1)
            ss_nb=Session_nb(l);
            if strcmp(Field,'mPFC')==1
                eval(['Peak_loc.' Field '(i)=idx_learned.' Field '+Peak_window_in.' Field ';'])
                eval(['Peak_mouse_Days.D' num2str(ss_nb) '.' Field '(i)=mean(data_mouse_Days.D' num2str(ss_nb) '.' Field '(i,round(Peak_loc.' Field '(i))-5:round(Peak_loc.' Field '(i))+5),2);'])
            else
                eval(['Peak_loc.' Field '(i)=idx_learned.' Field '+Peak_window_in.' Field ';'])
                eval(['Peak_mouse_Days.D' num2str(ss_nb) '.' Field '(i)=mean(data_mouse_Days.D' num2str(ss_nb) '.' Field '(i,round(Peak_loc.' Field '(i))-5:round(Peak_loc.' Field '(i))+5),2);'])
            end
        end
    end
end



%% Plot Amplitude vs dprime for every area, every mouse, every day.

Amp_Stim_vector=[];
HR_vector=[];
FAR_vector=[];
dprime_vector=[];
h_nb=[];
stim_nb=[];
fa_nb=[];
nostim_nb=[];
Sessions=nan(1,size(Mouse_list_DT,1)+1);
Sessions(1)=0;

for k=1:size(Mouse_list_DT,1)
    Mouse=char(Mouse_list_DT(k));
    Session_nb=unique(LFP_Data.Session_Counter(strcmp(LFP_Data.Mouse_Name,Mouse)==1));
    Sessions(k+1)=Sessions(k)+size(Session_nb,1);
    
    for l=1:size(Session_nb,1)
        ss_nb=Session_nb(l);
        eval('h_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==ss_nb & LFP_Data.Trial_ID==1)+0.5];')
        eval('stim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==ss_nb & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0])+1];')
        eval(['HR_vector.' Mouse '(ss_nb,1)=h_nb/stim_nb;']) % with loglinear correction for HR and FAR
        eval('fa_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==ss_nb & LFP_Data.Trial_ID==3)+0.5];')
        eval('nostim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==ss_nb & [LFP_Data.Trial_ID==2 | LFP_Data.Trial_ID==3])+1];')
        eval(['FAR_vector.' Mouse '(ss_nb,1)=fa_nb/nostim_nb;']) % with loglinear correction for HR and FAR        
        eval(['dprime_vector.' Mouse '(ss_nb,1)=norminv(HR_vector.' Mouse '(ss_nb,1))-norminv(FAR_vector.' Mouse '(ss_nb,1));'])
        
        
        for j=1:6
            Field=char(Fields(j));
            eval(['Amp_Stim_vector.' Mouse '.' Field '(ss_nb,1)=Peak_mouse_Days.D' num2str(ss_nb) '.' Field '(k);'])
        end
        
    end
end

for j=1:6
    Field=char(Fields(j));
    eval(['Amp_Stim_vector.PL203.' Field '(5,1)=nan;'])
end

%% Plot
figure
for j=1:6
    Field=char(Fields(j));
    ax(1)=subplot(3,2,j);
    X_all=nan(1,sum(Sessions));
    Y_all=nan(1,sum(Sessions));
    
    if j~=6
        for k=1:size(Mouse_list_DT,1)
            Mouse=char(Mouse_list_DT(k));
            eval([' X=dprime_vector.' Mouse ';'])
            eval([' Y=Amp_Stim_vector.' Mouse '.' Field ';'])
            if strcmp(Mouse,'PL203')
            X(5)=[];
            Y(5)=[];
            end  
            
            X_all(1,Sessions(k)+1:Sessions(k+1))=X';
            Y_all(1,Sessions(k)+1:Sessions(k+1))=Y';
            
            % Make color vector from colormap
            color_vect=[];
            color_vect(1,:)=scatterplot_colormap(1,:);
            for c_idx=1:(length(Y)-1)
                if isnan(Y(c_idx+1))==0
                    c_step=64/length(Y(~isnan(Y)));
                    color_vect(c_idx+1,:)=scatterplot_colormap(round(c_step*c_idx),:);
                else
                    color_vect(c_idx+1,:)=[NaN NaN NaN];
                end
            end
            color_vect(end,:)=scatterplot_colormap(64,:);
            
            %Scatter plot
            h1=scatter(X,Y.*-10^6,[],color_vect,'filled');
            hold on
            set(h1, 'Marker', 'o')
            set(h1, 'MarkerEdgeColor', 'k')
            set(h1, 'SizeData', 80)
            
        end
        
        % Compute linear correlation
        nan_idx1=find(isnan(Y_all)==1);
        X_all(nan_idx1)=[];
        Y_all(nan_idx1)=[];
        Y_all=Y_all.*-10^6;
        [rho, pval]= corr(X_all',Y_all','type','Spearman','rows','complete');
        [rho1, pval1]= corr(X_all',Y_all','type','Pearson','rows','complete');
        xlabel({'dprime',['Spearman : \rho=' num2str(rho) ', p=' num2str(pval)]...
            ,['Pearson : \rho=' num2str(rho1) ', p=' num2str(pval1)]})
        title(Field,'fontweight','bold','fontsize',12);
        ylabel('Amp_{Stim}');
        set(gca,'xlim',[-1 5]);
        myfit = polyfit(X_all,Y_all,1);
        x = -1:0.01:4.5;
        y=myfit(1)*x+myfit(2);
        plot(x,y,'k');
        
        if j==1
            set(gca,'ylim',[0 600]);
        elseif j==2 || j==5
            set(gca,'ylim',[-50 400]);
        elseif j==3
            set(gca,'ylim',[-100 150]);
        elseif j==4
            set(gca,'ylim',[-100 200]);
        elseif j==6
            set(gca,'ylim',[-50 300]);
        end
        
    else
        
        for k=1:size(Mouse_list_DT,1)
            Mouse=char(Mouse_list_DT(k));
            eval([' X=dprime_vector.' Mouse ';'])
            eval([' Y=Amp_Stim_vector.' Mouse '.' Field ';'])
            if strcmp(Mouse,'PL203')
            X(5)=[];
            Y(5)=[];
            end  
            X_all(1,Sessions(k)+1:Sessions(k+1))=X';
            Y_all(1,Sessions(k)+1:Sessions(k+1))=Y';
            
            % Make color vector from colormap
            color_vect=[];
            color_vect(1,:)=scatterplot_colormap(1,:);
            for c_idx=1:(length(Y)-1)
                if isnan(Y(c_idx+1))==0
                    c_step=64/length(Y(~isnan(Y)));
                    color_vect(c_idx+1,:)=scatterplot_colormap(round(c_step*c_idx),:);
                else
                    color_vect(c_idx+1,:)=[NaN NaN NaN];
                end
            end
            color_vect(end,:)=scatterplot_colormap(64,:);
            
            %Scatter plot
            h1=scatter(X,Y.*10^6,[],color_vect,'filled');
            hold on
            set(h1, 'Marker', 'o')
            set(h1, 'MarkerEdgeColor', 'k')
            set(h1, 'SizeData', 80)
        end
        
        % Compute linear correlation
        nan_idx1=find(isnan(Y_all)==1);
        X_all(nan_idx1)=[];
        Y_all(nan_idx1)=[];
        Y_all=Y_all.*10^6;
        [rho, pval]= corr(X_all',Y_all','type','Spearman','rows','complete');
        [rho1, pval1]= corr(X_all',Y_all','type','Pearson','rows','complete');
        xlabel({'dprime',['Spearman : \rho=' num2str(rho) ', p=' num2str(pval)]...
            ,['Pearson : \rho=' num2str(rho1) ', p=' num2str(pval1)]})
        title(Field,'fontweight','bold','fontsize',12);
        ylabel('Amp_{Stim}');
        set(gca,'xlim',[-1 5]);
        myfit = polyfit(X_all,Y_all,1);
        x = -1:0.01:4.5;
        y=myfit(1)*x+myfit(2);
        plot(x,y,'k');
        
        if j==1
            set(gca,'ylim',[0 600]);
        elseif j==2 || j==5
            set(gca,'ylim',[-50 400]);
        elseif j==3
            set(gca,'ylim',[-100 150]);
        elseif j==4
            set(gca,'ylim',[-100 200]);
        elseif j==6
            set(gca,'ylim',[-50 300]);
        end
        
    end
    
end

%%

clear all









