function varargout = Chronic_LFP_dataViewer(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Chronic_LFP_dataViewer_OpeningFcn, ...
    'gui_OutputFcn',  @Chronic_LFP_dataViewer_OutputFcn, ...
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
LineWidth = 1.0;
FontSize = 12;
sr=2000;
data = handles2give.data;
SelectedTrial = strcmp(data.Mouse_Name,handles2give.MouseName) & ...
    data.Session_Counter == handles2give.SessionNumber & ...
    data.Trial_Counter == handles2give.TrialNumber;

%% Update Information Display
set(handles2give.InformationDisplay_MouseName_Tag, 'String', handles2give.MouseName);
set(handles2give.InformationDisplay_SessionNumber_Tag, 'String', handles2give.SessionNumber);

if strcmp(data.Session_Type(SelectedTrial),'DT')
    set(handles2give.InformationDisplay_SessionType_Tag, 'String', 'Detection Task');
else
    set(handles2give.InformationDisplay_SessionType_Tag, 'String', 'Neutral Exposure');
end

% set(handles2give.InformationDisplay_SessionType_Tag, 'String', data.Session_Type(SelectedTrial));

ExtractSessionStartTime = data.Session_StartTime(SelectedTrial,:)';
% ExtractSessionStartTime = datestr(datetime(ExtractSessionStartTime1));
ExtractSessionStartTime =datestr(cell2mat(ExtractSessionStartTime'));
set(handles2give.InformationDisplay_SessionStartTime_Tag, 'String', ExtractSessionStartTime);
set(handles2give.InformationDisplay_TrialNumber_Tag, 'String', handles2give.TrialNumber);
TrialTags={'Miss','Hit','Correct Rejection','False Alarm'};
set(handles2give.InformationDisplay_TrialType_Tag, 'String', TrialTags{data.Trial_ID(SelectedTrial)+1});
ExtractTrialStartTime = data.Trial_StartTime(SelectedTrial)/sr;
ExtractFirstLickTime = data.Trial_FirstLickTime(SelectedTrial)/sr;

set(handles2give.InformationDisplay_TrialStartTime_Tag, 'String', ExtractTrialStartTime);

%% Plot wS1 LFP
ExtractLFP_wS1 = data.Trial_LFP_wS1(SelectedTrial,:);
handles2give.LFP_wS1 = ExtractLFP_wS1 * 1000;
handles2give.LFPTimeVector = (1:(length(handles2give.LFP_wS1)))./sr-3;
axes(handles2give.LFP_wS1_Axes);
plot(handles2give.LFPTimeVector, handles2give.LFP_wS1,'Color',[200 0 0]./255,'LineWidth',LineWidth);
set(gca,'FontSize',FontSize);
ylabel('wS1','FontWeight','Bold','FontSize',FontSize);
axis([handles2give.TimeAxisMin handles2give.TimeAxisMax handles2give.LFPAxisMin handles2give.LFPAxisMax]);
YLIMS=ylim;
hold on
plot([0 0],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)
plot([ExtractFirstLickTime ExtractFirstLickTime],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)

hold off
set(gca,'XTickLabel',[]);
set(gca,'TickDir','out');
box(gca,'off');


%% Plot wS2 LFP
ExtractLFP_wS2 = data.Trial_LFP_wS2(SelectedTrial,:);
handles2give.LFP_wS2 = ExtractLFP_wS2 * 1000;
axes(handles2give.LFP_wS2_Axes);
plot(handles2give.LFPTimeVector, handles2give.LFP_wS2,'Color',[255 100 0]./255,'LineWidth',LineWidth);
set(gca,'FontSize',FontSize);
ylabel('wS2','FontWeight','Bold','FontSize',FontSize);
axis([handles2give.TimeAxisMin handles2give.TimeAxisMax handles2give.LFPAxisMin handles2give.LFPAxisMax]);
YLIMS=ylim;
hold on
plot([0 0],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)
plot([ExtractFirstLickTime ExtractFirstLickTime],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)

set(gca,'XTickLabel',[]);
hold off
set(gca,'TickDir','out');
box(gca,'off');

%% Plot wM1 LFP
ExtractLFP_wM1 = data.Trial_LFP_wM1(SelectedTrial,:);
handles2give.LFP_wM1 = ExtractLFP_wM1 * 1000;
axes(handles2give.LFP_wM1_Axes);
plot(handles2give.LFPTimeVector, handles2give.LFP_wM1,'Color',[255 200 0]./255,'LineWidth',LineWidth);
set(gca,'FontSize',FontSize);
ylabel('wM1','FontWeight','Bold','FontSize',FontSize);
axis([handles2give.TimeAxisMin handles2give.TimeAxisMax handles2give.LFPAxisMin handles2give.LFPAxisMax]);
YLIMS=ylim;
hold on
plot([0 0],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)
plot([ExtractFirstLickTime ExtractFirstLickTime],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)

hold off
set(gca,'XTickLabel',[]);
set(gca,'TickDir','out');
box(gca,'off');

%% Plot PtA LFP
ExtractLFP_PtA = data.Trial_LFP_PtA(SelectedTrial,:);
handles2give.LFP_PtA = ExtractLFP_PtA * 1000;
axes(handles2give.LFP_PtA_Axes);
plot(handles2give.LFPTimeVector, handles2give.LFP_PtA,'Color',[0 180 100]./255,'LineWidth',LineWidth);
set(gca,'FontSize',FontSize);
ylabel('PtA','FontWeight','Bold','FontSize',FontSize);
axis([handles2give.TimeAxisMin handles2give.TimeAxisMax handles2give.LFPAxisMin handles2give.LFPAxisMax]);
YLIMS=ylim;
hold on
plot([0 0],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)
plot([ExtractFirstLickTime ExtractFirstLickTime],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)

hold off
set(gca,'XTickLabel',[]);
set(gca,'TickDir','out');
box(gca,'off');

%% Plot dCA1 LFP
ExtractLFP_dCA1 = data.Trial_LFP_dCA1(SelectedTrial,:);
handles2give.LFP_dCA1 = ExtractLFP_dCA1 * 1000;
axes(handles2give.LFP_dCA1_Axes);
plot(handles2give.LFPTimeVector, handles2give.LFP_dCA1,'Color',[0 100 255]./255,'LineWidth',LineWidth);
set(gca,'FontSize',FontSize);
ylabel('dCA1','FontWeight','Bold','FontSize',FontSize);
axis([handles2give.TimeAxisMin handles2give.TimeAxisMax handles2give.LFPAxisMin handles2give.LFPAxisMax]);
YLIMS=ylim;
hold on
plot([0 0],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)
plot([ExtractFirstLickTime ExtractFirstLickTime],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)

hold off
set(gca,'XTickLabel',[]);
set(gca,'TickDir','out');
box(gca,'off')

%% Plot mPFC LFP
ExtractLFP_mPFC = data.Trial_LFP_mPFC(SelectedTrial,:);
handles2give.LFP_mPFC = ExtractLFP_mPFC * 1000;
axes(handles2give.LFP_mPFC_Axes);
plot(handles2give.LFPTimeVector, handles2give.LFP_mPFC,'Color',[0 0 150]./255,'LineWidth',LineWidth);
set(gca,'FontSize',FontSize);
ylabel('mPFC','FontWeight','Bold','FontSize',FontSize);
axis([handles2give.TimeAxisMin handles2give.TimeAxisMax handles2give.LFPAxisMin handles2give.LFPAxisMax]);
YLIMS=ylim;
hold on
plot([0 0],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)
plot([ExtractFirstLickTime ExtractFirstLickTime],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)

hold off
set(gca,'XTickLabel',[]);
set(gca,'TickDir','out');
box(gca,'off');

%% Plot EMG 
ExtractEMG = data.Trial_EMG(SelectedTrial,:);
handles2give.EMG = ExtractEMG * 1000;
axes(handles2give.EMG_Axes);
plot(handles2give.LFPTimeVector, handles2give.EMG,'Color','k','LineWidth',LineWidth);
set(gca,'FontSize',FontSize);
xlabel(['Time (s)'],'FontWeight','Bold','FontSize',FontSize);
ylabel('EMG','FontWeight','Bold','FontSize',FontSize);
axis([handles2give.TimeAxisMin handles2give.TimeAxisMax handles2give.LFPAxisMin handles2give.LFPAxisMax]);
YLIMS=ylim;
hold on
plot([0 0],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)
plot([ExtractFirstLickTime ExtractFirstLickTime],YLIMS,'--','color',[.5 .5 .5],'LineWidth',1)

hold off
set(gca,'TickDir','out');
box(gca,'off');



% --- Executes just before Chronic_LFP_dataViewer is made visible.
function Chronic_LFP_dataViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Chronic_LFP_dataViewer (see VARARGIN)

% Choose default command line output for Chronic_LFP_dataViewer
handles.output = hObject;


%% Initialize the path
handles.LPFDir = '';
set(handles.LFPFileTag,'String',handles.LPFDir);

%% Set axis scaling
handles.LFPAxisMin = -1; set(handles.LFPAxisMinTag,'String',num2str(handles.LFPAxisMin));
handles.LFPAxisMax = 1; set(handles.LFPAxisMaxTag,'String',num2str(handles.LFPAxisMax));

handles.TimeAxisMin = -3; set(handles.TimeAxisMinTag,'String',num2str(handles.TimeAxisMin));
handles.TimeAxisMax = 2; set(handles.TimeAxisMaxTag,'String',num2str(handles.TimeAxisMax));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Chronic_LFP_dataViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Chronic_LFP_dataViewer_OutputFcn(hObject, eventdata, handles)
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

handles.SessionNumberList = unique(handles.data.Session_Counter(strcmp(handles.data.Mouse_Name,handles.MouseName)));
set(handles.SessionNumber_Popupmenu,'String',handles.SessionNumberList);
handles.SessionNumber = 1;
set(handles.SessionNumber_Popupmenu,'Value',1);

handles.TrialNumberList = unique(handles.data.Trial_Counter(strcmp(handles.data.Mouse_Name,handles.MouseName) & handles.data.Session_Counter == handles.SessionNumber));
% handles.TrialNumberList=handles.TrialNumberList-min(handles.TrialNumberList)+1;
set(handles.TrialNumber_Popupmenu,'String',handles.TrialNumberList);
handles.TrialNumber = 1;
set(handles.TrialNumber_Popupmenu,'Value',1);

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

handles.TrialNumberList = unique(handles.data.Trial_Counter(strcmp(handles.data.Mouse_Name,handles.MouseName) & handles.data.Session_Counter == handles.SessionNumber));
handles.TrialNumberList=sort(handles.TrialNumberList);
% handles.TrialNumberList =handles.TrialNumberList - min(handles.TrialNumberList)+1;
set(handles.TrialNumber_Popupmenu,'String',handles.TrialNumberList);
handles.TrialNumber = handles.TrialNumberList(1);
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


function TimeAxisMinTag_Callback(hObject, eventdata, handles)
% hObject    handle to TimeAxisMinTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeAxisMinTag as text
%        str2double(get(hObject,'String')) returns contents of TimeAxisMinTag as a double

handles.TimeAxisMin = round(str2double(get(handles.TimeAxisMinTag,'String'))*1000)/1000;

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

handles.TimeAxisMax = round(str2double(get(handles.TimeAxisMaxTag,'String'))*1000)/1000;

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


function LFPAxisMinTag_Callback(hObject, eventdata, handles)
% hObject    handle to LFPAxisMinTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LFPAxisMinTag as text
%        str2double(get(hObject,'String')) returns contents of LFPAxisMinTag as a double

handles.LFPAxisMin = round(str2double(get(handles.LFPAxisMinTag,'String'))*100)/100;

% Change the text
set(handles.LFPAxisMinTag,'String',num2str(handles.LFPAxisMin));

handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function LFPAxisMinTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LFPAxisMinTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LFPAxisMaxTag_Callback(hObject, eventdata, handles)
% hObject    handle to LFPAxisMaxTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LFPAxisMaxTag as text
%        str2double(get(hObject,'String')) returns contents of LFPAxisMaxTag as a double

handles.LFPAxisMax = round(str2double(get(handles.LFPAxisMaxTag,'String'))*100)/100;

% Change the text
set(handles.LFPAxisMaxTag,'String',num2str(handles.LFPAxisMax));

handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function LFPAxisMaxTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LFPAxisMaxTag (see GCBO)
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

handles.LFPAxisMin = -1;
handles.LFPAxisMax = 1;
handles.WhiskerAxisMin = -360;
handles.WhiskerAxisMax = 360;
handles.PiezoAxisMin = -1;
handles.PiezoAxisMax = 1;
handles.TimeAxisMin = -3;
handles.TimeAxisMax = 2;

% Change the text
set(handles.LFPAxisMinTag,'String',num2str(handles.LFPAxisMin));
set(handles.LFPAxisMaxTag,'String',num2str(handles.LFPAxisMax));
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
move_time = (handles.TimeAxisMax - handles.TimeAxisMin) * 0.8;
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
move_time = (handles.TimeAxisMax - handles.TimeAxisMin) * 0.8;
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
handles.TimeAxisMin = round(min(handles.LFPTimeVector));
handles.TimeAxisMax = round(max(handles.LFPTimeVector));

% Change the text
set(handles.LFPAxisMinTag,'String',num2str(handles.LFPAxisMin));
set(handles.LFPAxisMaxTag,'String',num2str(handles.LFPAxisMax));
set(handles.TimeAxisMinTag,'String',num2str(handles.TimeAxisMin));
set(handles.TimeAxisMaxTag,'String',num2str(handles.TimeAxisMax));

handles = UpdateTimeSeries(handles);

% Update handles structure
guidata(hObject, handles);



function LFPFileTag_Callback(hObject, eventdata, handles)
% hObject    handle to LFPFileTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LFPFileTag as text
%        str2double(get(hObject,'String')) returns contents of LFPFileTag as a double


% --- Executes during object creation, after setting all properties.
function LFPFileTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LFPFileTag (see GCBO)
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

[handles.LFPfilename, handles.LFPDir] = uigetfile('*.mat') ;
set(handles.LFPFileTag,'String',handles.LFPfilename);

%% Load data
MatlabFile = fullfile(handles.LFPDir,handles.LFPfilename);
load(MatlabFile);
handles.data = LFP_Data;

%% Set mouse name
handles.MouseNameList = unique(handles.data.Mouse_Name);
set(handles.MouseName_Popupmenu,'String',handles.MouseNameList);
set(handles.MouseName_Popupmenu,'Value',1);
handles.MouseName = handles.MouseNameList{get(handles.MouseName_Popupmenu,'Value')};

%% Set session number
handles.SessionNumberList = unique(handles.data.Session_Counter(strcmp(handles.data.Mouse_Name,handles.MouseName)));
set(handles.SessionNumber_Popupmenu,'String',handles.SessionNumberList);
set(handles.SessionNumber_Popupmenu,'Value',1);
handles.SessionNumber = handles.SessionNumberList(get(handles.SessionNumber_Popupmenu,'Value'));

%% Set trial number
handles.TrialNumberList = unique(handles.data.Trial_Counter(strcmp(handles.data.Mouse_Name,handles.MouseName) & handles.data.Session_Counter == handles.SessionNumber));
% handles.TrialNumberList = handles.TrialNumberList - min(handles.TrialNumberList) +1;
set(handles.TrialNumber_Popupmenu,'String',handles.TrialNumberList);
set(handles.TrialNumber_Popupmenu,'Value',1);
handles.TrialNumber = handles.TrialNumberList(get(handles.TrialNumber_Popupmenu,'Value'));

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


