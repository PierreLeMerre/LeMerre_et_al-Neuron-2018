function varargout = Silicon_Probe_dataViewer(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Silicon_Probe_dataViewer_OpeningFcn, ...
    'gui_OutputFcn',  @Silicon_Probe_dataViewer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%UPDATE TIME SERIES
function handles2give = UpdateTimeSeries(handles2give)

%% General parameters
% LineWidth = 1.0;
FontSize = 12;
sr=30000;
RasterMarkerSIZE=10;

data = handles2give.data;
SelectedTrial = handles2give.TrialNumber;
TrialOnset=handles2give.AllTrialOnsets(SelectedTrial);
PreTime=-5;
PostTime=5;
%% Update Information Display
set(handles2give.InformationDisplay_MouseName_Tag, 'String', handles2give.MouseName);
set(handles2give.InformationDisplay_SessionNumber_Tag, 'String', handles2give.SessionNumber);

if strcmp(handles2give.Session_Type,'DT')
    set(handles2give.InformationDisplay_SessionType_Tag, 'String', 'Detection Task');
else
    set(handles2give.InformationDisplay_SessionType_Tag, 'String', 'Neutral Exposure');
end

ExtractSessionStartTime = datestr(handles2give.Session_StartTime(1:6));
set(handles2give.InformationDisplay_SessionStartTime_Tag, 'String', ExtractSessionStartTime);

set(handles2give.InformationDisplay_TrialNumber_Tag, 'String', handles2give.TrialNumber);
TrialTags={'Miss','Hit','Correct Rejection','False Alarm'};
set(handles2give.InformationDisplay_TrialType_Tag, 'String', TrialTags{handles2give.Trial_ID(SelectedTrial)+1});
ExtractTrialStartTime =round(handles2give.AllTrialOnsets(SelectedTrial)/300)/100;
set(handles2give.InformationDisplay_TrialStartTime_Tag, 'String', ExtractTrialStartTime);
%%
MarkerColors=[1 0 0;0 .8 0;0 0 1];
ColorCounter=0;
AllClusters=data.Cell_Cluster(strcmp([data.Mouse_Name{:}],handles2give.MouseName));
AllClusters=AllClusters(handles2give.DepthIndex);
for iCluster=1:numel(AllClusters)
    if ColorCounter<size(MarkerColors,1)
        ColorCounter=ColorCounter+1;
    else
        ColorCounter=1;
    end
    TheseSpikeTimes=cell2mat(data.Cell_SpikeTimes{(data.Cell_Cluster==AllClusters(iCluster))' & strcmp([data.Mouse_Name{:}],handles2give.MouseName)});
    RasterSpikes=round((TheseSpikeTimes(TheseSpikeTimes>=TrialOnset+PreTime*sr & TheseSpikeTimes<TrialOnset+PostTime*sr)-TrialOnset)/sr*1000);
    axes(handles2give.Spike_Axes);
    if ~isempty(RasterSpikes)
        plot( RasterSpikes./1000,iCluster,'Marker','.','Color',MarkerColors(ColorCounter,:),'MarkerSize',RasterMarkerSIZE)
        hold on
    end
end
% set(gca,'YTICK',1:iCluster,'YTICKLabel',Clusters_depth(DepthIndex))
ylim([0 iCluster+1])
YLIMS=ylim;
plot([0 0],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)
LickOnset=(handles2give.LickOnsets(SelectedTrial))/sr;
plot([LickOnset LickOnset],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)
hold off
xlabel('Time (s)','FontSize',FontSize)
ylabel('Units sorted by depth','FontSize',FontSize)
% set(handles2give.Spike_Axes,'YTick',[])
set(gca,'TickDir','out');
set(gca,'Box','off');
xlim([handles2give.TimeAxisMin handles2give.TimeAxisMax]);


% --- Executes just before Silicon_Probe_dataViewer is made visible.
function Silicon_Probe_dataViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Silicon_Probe_dataViewer (see VARARGIN)

% Choose default command line output for Silicon_Probe_dataViewer
handles.output = hObject;


%% Initialize the path
handles.SpikeDir = '';
set(handles.SpikeFileTag,'String',handles.SpikeDir);

%% Set axis scaling
handles.TimeAxisMin = -3; set(handles.TimeAxisMinTag,'String',num2str(handles.TimeAxisMin));
handles.TimeAxisMax = 2; set(handles.TimeAxisMaxTag,'String',num2str(handles.TimeAxisMax));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Silicon_Probe_dataViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Silicon_Probe_dataViewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in MouseName_Popupmenu.
function MouseName_Popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to MouseName_Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MouseName_Popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MouseName_Popupmenu

handles.MouseName = handles.MouseNameList{get(handles.MouseName_Popupmenu,'Value')};




% Reading Cluster_depth, session info and trial times
Clusters_depth=handles.data.Cell_Coordinates(strcmp([handles.data.Mouse_Name{:}],handles.MouseName),3);
[~,DepthIndex]=sort(Clusters_depth);
handles.DepthIndex=fliplr(DepthIndex);

handles.Session_StartTime=unique(handles.data.Session_StartTime(strcmp([handles.data.Mouse_Name{:}],handles.MouseName),:),'rows');
handles.Session_Type=handles.data.Session_Type{find(strcmp([handles.data.Mouse_Name{:}],handles.MouseName),1,'first')};


AllTrialOnsets=horzcat(unique(cell2mat([handles.data.Session_StimTimes_Hit{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])),...
    unique(cell2mat([handles.data.Session_StimTimes_Miss{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])),...
    unique(cell2mat([handles.data.Session_StimTimes_CorrectRejection{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])),...
    unique(cell2mat([handles.data.Session_StimTimes_FalseAlarm{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])));

handles.Trial_ID=[ones(1,numel(unique(cell2mat([handles.data.Session_StimTimes_Hit{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}]))))...
    zeros(1,numel(unique(cell2mat([handles.data.Session_StimTimes_Miss{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}]))))...
    2.*ones(1,numel(unique(cell2mat([handles.data.Session_StimTimes_CorrectRejection{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}]))))...
    3.*ones(1,numel(unique(cell2mat([handles.data.Session_StimTimes_FalseAlarm{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}]))))];

handles.LickOnsets=horzcat(unique(cell2mat([handles.data.Session_FirstLickTimes_Hit{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])),...
    nan(1,numel(unique(cell2mat([handles.data.Session_StimTimes_Miss{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])))),...
    nan(1,numel(unique(cell2mat([handles.data.Session_StimTimes_CorrectRejection{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])))),...
    unique(cell2mat([handles.data.Session_FirstLickTimes_FalseAlarm{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])));

handles.LickOnsets=handles.LickOnsets-AllTrialOnsets;

[handles.AllTrialOnsets,IndicesOrder]=sort(AllTrialOnsets);
handles.Trial_ID=handles.Trial_ID(IndicesOrder);
handles.LickOnsets=handles.LickOnsets(IndicesOrder);
handles.Session_Counter=1;

%% Set session number
handles.SessionNumberList = 1;
set(handles.SessionNumber_Popupmenu,'String',handles.SessionNumberList);
set(handles.SessionNumber_Popupmenu,'Value',1);
handles.SessionNumber = handles.SessionNumberList(get(handles.SessionNumber_Popupmenu,'Value'));
% 
%% Set trial number
handles.TrialNumberList =1:numel(handles.AllTrialOnsets);
set(handles.TrialNumber_Popupmenu,'String',handles.TrialNumberList);
set(handles.TrialNumber_Popupmenu,'Value',1);
handles.TrialNumber = handles.TrialNumberList(get(handles.TrialNumber_Popupmenu,'Value'));
% 
%% Set axes
handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MouseName_Popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MouseName_Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SessionNumber_Popupmenu.
function SessionNumber_Popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to SessionNumber_Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SessionNumber_Popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SessionNumber_Popupmenu

handles.SessionNumber = handles.SessionNumberList(get(handles.SessionNumber_Popupmenu,'Value'));

handles.TrialNumberList = unique(handles.data.Trial_Counter(strcmp([handles.data.Mouse_Name{:}],handles.MouseName) & handles.data.Session_Counter == handles.SessionNumber));
set(handles.TrialNumber_Popupmenu,'String',handles.TrialNumberList);
% handles.TrialNumber = handles.TrialNumberList(1);
% set(handles.TrialNumber_Popupmenu,'Value',handles.TrialNumber);
handles.TrialNumber = handles.TrialNumberList(1);
%set(handles.TrialNumber_Popupmenu,'Value',handles.TrialNumber);
set(handles.TrialNumber_Popupmenu,'Value',1);

handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SessionNumber_Popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SessionNumber_Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TrialNumber_Popupmenu.
function TrialNumber_Popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to TrialNumber_Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TrialNumber_Popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TrialNumber_Popupmenu

handles.TrialNumber = handles.TrialNumberList(get(handles.TrialNumber_Popupmenu,'Value'));

handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TrialNumber_Popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialNumber_Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%
% --- Change Axes Scale ---
%

function TimeAxisMinTag_Callback(hObject, eventdata, handles)
% hObject    handle to TimeAxisMinTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeAxisMinTag as text
%        str2double(get(hObject,'String')) returns contents of TimeAxisMinTag as a double

handles.TimeAxisMin = round(str2double(get(handles.TimeAxisMinTag,'String'))*100)/100;

% Change the text
set(handles.TimeAxisMinTag,'String',num2str(handles.TimeAxisMin));

handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TimeAxisMinTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeAxisMinTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TimeAxisMaxTag_Callback(hObject, eventdata, handles)
% hObject    handle to TimeAxisMaxTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeAxisMaxTag as text
%        str2double(get(hObject,'String')) returns contents of TimeAxisMaxTag as a double

handles.TimeAxisMax = round(str2double(get(handles.TimeAxisMaxTag,'String'))*100)/100;

% Change the text
set(handles.TimeAxisMaxTag,'String',num2str(handles.TimeAxisMax));

handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TimeAxisMaxTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeAxisMaxTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in ResetScalingPushbutton.
function ResetScalingPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetScalingPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.TimeAxisMin = -3;
handles.TimeAxisMax = 2;

% Change the text
set(handles.TimeAxisMinTag,'String',num2str(handles.TimeAxisMin));
set(handles.TimeAxisMaxTag,'String',num2str(handles.TimeAxisMax));

handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in MoveBackButton.
function MoveBackButton_Callback(hObject, eventdata, handles)
% hObject    handle to MoveBackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
move_time = (handles.TimeAxisMax - handles.TimeAxisMin) * 0.2;
handles.TimeAxisMin = handles.TimeAxisMin - move_time;
handles.TimeAxisMax = handles.TimeAxisMax - move_time;
set(handles.TimeAxisMinTag,'String',num2str(handles.TimeAxisMin));
set(handles.TimeAxisMaxTag,'String',num2str(handles.TimeAxisMax));
handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in MoveForwardsButton.
function MoveForwardsButton_Callback(hObject, eventdata, handles)
% hObject    handle to MoveForwardsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
move_time = (handles.TimeAxisMax - handles.TimeAxisMin) * 0.2;
handles.TimeAxisMin = handles.TimeAxisMin + move_time;
handles.TimeAxisMax = handles.TimeAxisMax + move_time;
set(handles.TimeAxisMinTag,'String',num2str(handles.TimeAxisMin));
set(handles.TimeAxisMaxTag,'String',num2str(handles.TimeAxisMax));
handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in AutoscaleButton.
function AutoscaleButton_Callback(hObject, eventdata, handles)
% hObject    handle to AutoscaleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.LFPAxisMin = min(handles.LFP_wS1);
handles.LFPAxisMax = max(handles.LFP_wS1);
handles.WhiskerAxisMin = min(handles.WhiskerAngle);
handles.WhiskerAxisMax = max(handles.WhiskerAngle);
handles.PiezoAxisMin = min(handles.Piezo);
handles.PiezoAxisMax = max(handles.Piezo);
handles.TimeAxisMin = min(handles.LFPTimeVector);
handles.TimeAxisMax = max(handles.LFPTimeVector);

% Change the text
set(handles.TimeAxisMinTag,'String',num2str(handles.TimeAxisMin));
set(handles.TimeAxisMaxTag,'String',num2str(handles.TimeAxisMax));

handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);



function SpikeFileTag_Callback(hObject, eventdata, handles)
% hObject    handle to SpikeFileTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SpikeFileTag as text
%        str2double(get(hObject,'String')) returns contents of SpikeFileTag as a double


% --- Executes during object creation, after setting all properties.
function SpikeFileTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpikeFileTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.Spikefilename, handles.SpikeDir] = uigetfile('*.mat') ;
% handles.SpikeDir=uigetdir;
set(handles.SpikeFileTag,'String',handles.Spikefilename);

%% Load data
MatlabFile = fullfile(handles.SpikeDir,handles.Spikefilename);
load(MatlabFile,'spike_data');
handles.data = spike_data;

%% Set mouse name
handles.MouseNameList = unique([handles.data.Mouse_Name{:}]);
set(handles.MouseName_Popupmenu,'String',handles.MouseNameList);
set(handles.MouseName_Popupmenu,'Value',1);
handles.MouseName = handles.MouseNameList{get(handles.MouseName_Popupmenu,'Value')};

%% Selecting data for this mouse
Clusters_depth=handles.data.Cell_Coordinates(strcmp([handles.data.Mouse_Name{:}],handles.MouseName),3);
[~,DepthIndex]=sort(Clusters_depth);
handles.DepthIndex=fliplr(DepthIndex);

handles.Session_StartTime=unique(spike_data.Session_StartTime(strcmp([handles.data.Mouse_Name{:}],handles.MouseName),:),'rows');
handles.Session_Type=spike_data.Session_Type{find(strcmp([handles.data.Mouse_Name{:}],handles.MouseName),1,'first')};


%% Creating required fields for the GUI
AllTrialOnsets=horzcat(unique(cell2mat([handles.data.Session_StimTimes_Hit{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])),...
    unique(cell2mat([handles.data.Session_StimTimes_Miss{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])),...
    unique(cell2mat([handles.data.Session_StimTimes_CorrectRejection{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])),...
    unique(cell2mat([handles.data.Session_StimTimes_FalseAlarm{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])));

handles.Trial_ID=[ones(1,numel(unique(cell2mat([handles.data.Session_StimTimes_Hit{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}]))))...
    zeros(1,numel(unique(cell2mat([handles.data.Session_StimTimes_Miss{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}]))))...
    2.*ones(1,numel(unique(cell2mat([handles.data.Session_StimTimes_CorrectRejection{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}]))))...
    3.*ones(1,numel(unique(cell2mat([handles.data.Session_StimTimes_FalseAlarm{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}]))))];

handles.LickOnsets=horzcat(unique(cell2mat([handles.data.Session_FirstLickTimes_Hit{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])),...
    nan(1,numel(unique(cell2mat([handles.data.Session_StimTimes_Miss{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])))),...
    nan(1,numel(unique(cell2mat([handles.data.Session_StimTimes_CorrectRejection{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])))),...
    unique(cell2mat([handles.data.Session_FirstLickTimes_FalseAlarm{strcmp([handles.data.Mouse_Name{:}],handles.MouseName)}])));


handles.LickOnsets=handles.LickOnsets-AllTrialOnsets;

[handles.AllTrialOnsets,IndicesOrder]=sort(AllTrialOnsets);
handles.Trial_ID=handles.Trial_ID(IndicesOrder);
handles.LickOnsets=handles.LickOnsets(IndicesOrder);
handles.Session_Counter=1;


%% Set session number
handles.SessionNumberList = 1;
set(handles.SessionNumber_Popupmenu,'String',handles.SessionNumberList);
set(handles.SessionNumber_Popupmenu,'Value',1);
handles.SessionNumber = handles.SessionNumberList(get(handles.SessionNumber_Popupmenu,'Value'));
% 
%% Set trial number
handles.TrialNumberList =1:numel(handles.AllTrialOnsets);
set(handles.TrialNumber_Popupmenu,'String',handles.TrialNumberList);
set(handles.TrialNumber_Popupmenu,'Value',1);
handles.TrialNumber = handles.TrialNumberList(get(handles.TrialNumber_Popupmenu,'Value'));
% 
%% Set axes
handles = UpdateTimeSeries(handles);

guidata(hObject, handles);


% --- Executes on button press in PreviousTrialButton.
function PreviousTrialButton_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousTrialButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TrialNumberValueOld = get(handles.TrialNumber_Popupmenu,'Value');
if TrialNumberValueOld==1
    set(handles.TrialNumber_Popupmenu,'Value',TrialNumberValueOld);
else
    set(handles.TrialNumber_Popupmenu,'Value',TrialNumberValueOld-1);
end
handles.TrialNumber=handles.TrialNumberList(get(handles.TrialNumber_Popupmenu,'Value'));

handles = UpdateTimeSeries(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in NextTrialButton.
function NextTrialButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextTrialButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TrialNumberValueOld = get(handles.TrialNumber_Popupmenu,'Value');
if TrialNumberValueOld==numel(handles.TrialNumberList)
    set(handles.TrialNumber_Popupmenu,'Value',TrialNumberValueOld);
else
    set(handles.TrialNumber_Popupmenu,'Value',TrialNumberValueOld+1);
end
handles.TrialNumber=handles.TrialNumberList(get(handles.TrialNumber_Popupmenu,'Value'));

handles = UpdateTimeSeries(handles);
% Update handles structure
guidata(hObject, handles);

