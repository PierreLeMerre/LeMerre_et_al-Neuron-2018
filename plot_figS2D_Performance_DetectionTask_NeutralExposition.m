%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure S2.D.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('PathDatabase','var')==0 && exist('LFP_Data','var')==0 && exist('LFP_Data_description','var')==0
[PathDatabase,LFP_Data,LFP_Data_description]=Load_LFP_Multisite_database;
end
%learned days
load([PathDatabase filesep 'Learning_Days_Mtrx.mat']);
%exposed days
load([PathDatabase filesep 'Exposed_Days_Mtrx.mat']);

Mouse_list_DT=unique(LFP_Data.Mouse_Name(strcmp(LFP_Data.Session_Type,'DT')==1));
Mouse_list_X=unique(LFP_Data.Mouse_Name(strcmp(LFP_Data.Session_Type,'X')==1));

%% Get HR, FAR and dprime D1 vs Trained

HR_D1=NaN(size(Mouse_list_DT,1),1);
FAR_D1=NaN(size(Mouse_list_DT,1),1);
dprime_D1=NaN(size(Mouse_list_DT,1),1);
HR_Trained=NaN(size(Mouse_list_DT,1),1);
FAR_Trained=NaN(size(Mouse_list_DT,1),1);
dprime_Trained=NaN(size(Mouse_list_DT,1),1);

for k=1:size(Mouse_list_DT,1)
    Mouse=char(Mouse_list_DT(k));
    eval('h_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==1 & LFP_Data.Trial_ID==1)+0.5];')
    eval('stim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==1 & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0])+1];')
    eval('HR_D1(k,1)=h_nb/stim_nb;') % with loglinear correction for HR and FAR
    eval('fa_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==1 & LFP_Data.Trial_ID==3)+0.5];')
    eval('nostim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==1 & [LFP_Data.Trial_ID==2 | LFP_Data.Trial_ID==3])+1];')
    eval('FAR_D1(k,1)=fa_nb/nostim_nb;') % with loglinear correction for HR and FAR
    eval('dprime_D1(k,1)=norminv(HR_D1(k,1))-norminv(FAR_D1(k,1));')
    
    eval('h_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(k,1) | LFP_Data.Session_Counter==LDM(k,2) | LFP_Data.Session_Counter==LDM(k,3)]  & LFP_Data.Trial_ID==1)+0.5];')
    eval('stim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(k,1) | LFP_Data.Session_Counter==LDM(k,2) | LFP_Data.Session_Counter==LDM(k,3)] & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0])+1];')
    eval('HR_Trained(k,1)=h_nb/stim_nb;') % with loglinear correction for HR and FAR
    eval('fa_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(k,1) | LFP_Data.Session_Counter==LDM(k,2) | LFP_Data.Session_Counter==LDM(k,3)] & LFP_Data.Trial_ID==3)+0.5];')
    eval('nostim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==LDM(k,1) | LFP_Data.Session_Counter==LDM(k,2) | LFP_Data.Session_Counter==LDM(k,3)] & [LFP_Data.Trial_ID==2 | LFP_Data.Trial_ID==3])+1];')
    eval('FAR_Trained(k,1)=fa_nb/nostim_nb;') % with loglinear correction for HR and FAR
    eval('dprime_Trained(k,1)=norminv(HR_Trained(k,1))-norminv(FAR_Trained(k,1));')
end

%% plot
%Hit rate
fig1=figure;
for k=1:size(Mouse_list_DT,1)
    Mouse=char(Mouse_list_DT(k));
    temp=[HR_D1(k,1) HR_Trained(k,1)];
    plot(temp','color',[0.5,0.5,0.5]);
    hold on
end

eval('temp1=[nanmean(HR_D1,1)  NaN];')
eval('temp2=[NaN nanmean(HR_Trained,1)];')
eval('SemH=[nanstd(HR_D1,[],1); NaN];')
eval('SemM=[NaN; nanstd(HR_Trained,[],1)];')
errorbar(temp1,SemH,'bo');
errorbar(temp2,SemM,'ro');

title('Hit rate','fontweight','bold','fontsize',12,'fontname','times new roman');
xlim([0.5 2.5]);
NumTicks = 4;
L1 = get(gca,'XLim');
set(gca,'XTick',linspace(L1(1),L1(2),NumTicks))
set(gca,'XTickLabel',{'','D1','Trained',''})
ylabel('p(Lick)')

p_value1=signrank(HR_D1,HR_Trained);
if p_value1<0.05
    xlabel(['p=' num2str(p_value1)],'color','r')
else
    xlabel(['p=' num2str(p_value1)])
end


%False Alarm rate
fig2=figure;
for k=1:size(Mouse_list_DT,1)
    Mouse=char(Mouse_list_DT(k));
    temp=[FAR_D1(k,1) FAR_Trained(k,1)];
    plot(temp','color',[0.5,0.5,0.5]);
    hold on
end

eval('temp1=[nanmean(FAR_D1,1)  NaN];')
eval('temp2=[NaN nanmean(FAR_Trained,1)];')
eval('SemH=[nanstd(FAR_D1,[],1); NaN];')
eval('SemM=[NaN; nanstd(FAR_Trained,[],1)];')
errorbar(temp1,SemH,'bo');
errorbar(temp2,SemM,'ro');

title('False Alarm rate','fontweight','bold','fontsize',12,'fontname','times new roman');
xlim([0.5 2.5]);
NumTicks = 4;
L1 = get(gca,'XLim');
set(gca,'XTick',linspace(L1(1),L1(2),NumTicks))
set(gca,'XTickLabel',{'','D1','Trained',''})
ylabel('p(Lick)')

p_value2=signrank(FAR_D1,FAR_Trained);
if p_value2<0.05
    xlabel(['p=' num2str(p_value2)],'color','r')
else
    xlabel(['p=' num2str(p_value2)])
end

%d prime
fig3=figure;
for k=1:size(Mouse_list_DT,1)
    Mouse=char(Mouse_list_DT(k));
    temp=[dprime_D1(k,1) dprime_Trained(k,1)];
    plot(temp','color',[0.5,0.5,0.5]);
    hold on
end

eval('temp1=[nanmean(dprime_D1,1)  NaN];')
eval('temp2=[NaN nanmean(dprime_Trained,1)];')
eval('SemH=[nanstd(dprime_D1,[],1); NaN];')
eval('SemM=[NaN; nanstd(dprime_Trained,[],1)];')
errorbar(temp1,SemH,'bo');
errorbar(temp2,SemM,'ro');

title('d prime','fontweight','bold','fontsize',12,'fontname','times new roman');
xlim([0.5 2.5]);
ylim([-1 4]);
NumTicks = 4;
L1 = get(gca,'XLim');
set(gca,'XTick',linspace(L1(1),L1(2),NumTicks))
set(gca,'XTickLabel',{'','D1','Trained',''})
ylabel('d '' ')

p_value3=signrank(dprime_D1,dprime_Trained);
if p_value3<0.05
    xlabel(['p=' num2str(p_value3)],'color','r')
else
    xlabel(['p=' num2str(p_value3)])
end



%% Get HR, FAR and dprime D1 vs Exposed

HR_D1_X=NaN(size(Mouse_list_X,1),1);
FAR_D1_X=NaN(size(Mouse_list_X,1),1);
dprime_D1_X=NaN(size(Mouse_list_X,1),1);
HR_Exposed=NaN(size(Mouse_list_X,1),1);
FAR_Exposed=NaN(size(Mouse_list_X,1),1);
dprime_Exposed=NaN(size(Mouse_list_X,1),1);

for k=1:size(Mouse_list_X,1)
    Mouse=char(Mouse_list_X(k));
    eval('h_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==1 & LFP_Data.Trial_ID==1)+0.5];')
    eval('stim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==1 & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0])+1];')
    eval('HR_D1_X(k,1)=h_nb/stim_nb;') % with loglinear correction for HR and FAR
    eval('fa_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==1 & LFP_Data.Trial_ID==3)+0.5];')
    eval('nostim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & LFP_Data.Session_Counter==1 & [LFP_Data.Trial_ID==2 | LFP_Data.Trial_ID==3])+1];')
    eval('FAR_D1_X(k,1)=fa_nb/nostim_nb;') % with loglinear correction for HR and FAR
    eval('dprime_D1_X(k,1)=norminv(HR_D1_X(k,1))-norminv(FAR_D1_X(k,1));')
    
    eval('h_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==EDM(k,1) | LFP_Data.Session_Counter==EDM(k,2) | LFP_Data.Session_Counter==EDM(k,3)]  & LFP_Data.Trial_ID==1)+0.5];')
    eval('stim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==EDM(k,1) | LFP_Data.Session_Counter==EDM(k,2) | LFP_Data.Session_Counter==EDM(k,3)] & [LFP_Data.Trial_ID==1 | LFP_Data.Trial_ID==0])+1];')
    eval('HR_Exposed(k,1)=h_nb/stim_nb;') % with loglinear correction for HR and FAR
    eval('fa_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==EDM(k,1) | LFP_Data.Session_Counter==EDM(k,2) | LFP_Data.Session_Counter==EDM(k,3)] & LFP_Data.Trial_ID==3)+0.5];')
    eval('nostim_nb=[sum(strcmp(LFP_Data.Mouse_Name,Mouse)==1 & [LFP_Data.Session_Counter==EDM(k,1) | LFP_Data.Session_Counter==EDM(k,2) | LFP_Data.Session_Counter==EDM(k,3)] & [LFP_Data.Trial_ID==2 | LFP_Data.Trial_ID==3])+1];')
    eval('FAR_Exposed(k,1)=fa_nb/nostim_nb;') % with loglinear correction for HR and FAR
    eval('dprime_Exposed(k,1)=norminv(HR_Exposed(k,1))-norminv(FAR_Exposed(k,1));')
end

%% plot
%Hit rate
fig4=figure;
for k=1:size(Mouse_list_X,1)
    Mouse=char(Mouse_list_X(k));
    temp=[HR_D1_X(k,1) HR_Exposed(k,1)];
    plot(temp','color',[0.5,0.5,0.5]);
    hold on
end

eval('temp1=[nanmean(HR_D1_X,1)  NaN];')
eval('temp2=[NaN nanmean(HR_Exposed,1)];')
eval('SemH=[nanstd(HR_D1_X,[],1); NaN];')
eval('SemM=[NaN; nanstd(HR_Exposed,[],1)];')
errorbar(temp1,SemH,'bo');
errorbar(temp2,SemM,'go');

title('Hit rate','fontweight','bold','fontsize',12,'fontname','times new roman');
xlim([0.5 2.5]);
ylim([0 1]);
NumTicks = 4;
L1 = get(gca,'XLim');
set(gca,'XTick',linspace(L1(1),L1(2),NumTicks))
set(gca,'XTickLabel',{'','D1','Exposed',''})
ylabel('p(Lick)')

p_value4=signrank(HR_D1_X,HR_Exposed);
if p_value4<0.05
    xlabel(['p=' num2str(p_value4)],'color','r')
else
    xlabel(['p=' num2str(p_value4)])
end


%False Alarm rate
fig5=figure;
for k=1:size(Mouse_list_X,1)
    Mouse=char(Mouse_list_X(k));
    temp=[FAR_D1_X(k,1) FAR_Exposed(k,1)];
    plot(temp','color',[0.5,0.5,0.5]);
    hold on
end

eval('temp1=[nanmean(FAR_D1_X,1)  NaN];')
eval('temp2=[NaN nanmean(FAR_Exposed,1)];')
eval('SemH=[nanstd(FAR_D1_X,[],1); NaN];')
eval('SemM=[NaN; nanstd(FAR_Exposed,[],1)];')
errorbar(temp1,SemH,'bo');
errorbar(temp2,SemM,'go');

title('False Alarm rate','fontweight','bold','fontsize',12,'fontname','times new roman');
xlim([0.5 2.5]);
ylim([0 1]);
NumTicks = 4;
L1 = get(gca,'XLim');
set(gca,'XTick',linspace(L1(1),L1(2),NumTicks))
set(gca,'XTickLabel',{'','D1','Exposed',''})
ylabel('p(Lick)')

p_value5=signrank(FAR_D1_X,FAR_Exposed);
if p_value5<0.05
    xlabel(['p=' num2str(p_value5)],'color','r')
else
    xlabel(['p=' num2str(p_value5)])
end

%d prime
fig6=figure;
for k=1:size(Mouse_list_X,1)
    Mouse=char(Mouse_list_X(k));
    temp=[dprime_D1_X(k,1) dprime_Exposed(k,1)];
    plot(temp','color',[0.5,0.5,0.5]);
    hold on
end

eval('temp1=[nanmean(dprime_D1_X,1)  NaN];')
eval('temp2=[NaN nanmean(dprime_Exposed,1)];')
eval('SemH=[nanstd(dprime_D1_X,[],1); NaN];')
eval('SemM=[NaN; nanstd(dprime_Exposed,[],1)];')
errorbar(temp1,SemH,'bo');
errorbar(temp2,SemM,'go');

title('d prime','fontweight','bold','fontsize',12,'fontname','times new roman');
xlim([0.5 2.5]);
ylim([-1 4]);
NumTicks = 4;
L1 = get(gca,'XLim');
set(gca,'XTick',linspace(L1(1),L1(2),NumTicks))
set(gca,'XTickLabel',{'','D1','Exposed',''})
ylabel('d '' ')

p_value6=signrank(dprime_D1_X,dprime_Exposed);
if p_value6<0.05
    xlabel(['p=' num2str(p_value6)],'color','r')
else
    xlabel(['p=' num2str(p_value6)])
end

%%
clear all