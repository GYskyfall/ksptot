function varargout = lvd_EditInitialStateGUI(varargin)
% LVD_EDITINITIALSTATEGUI MATLAB code for lvd_EditInitialStateGUI.fig
%      LVD_EDITINITIALSTATEGUI, by itself, creates a new LVD_EDITINITIALSTATEGUI or raises the existing
%      singleton*.
%
%      H = LVD_EDITINITIALSTATEGUI returns the handle to a new LVD_EDITINITIALSTATEGUI or the handle to
%      the existing singleton*.
%
%      LVD_EDITINITIALSTATEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LVD_EDITINITIALSTATEGUI.M with the given input arguments.
%
%      LVD_EDITINITIALSTATEGUI('Property','Value',...) creates a new LVD_EDITINITIALSTATEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lvd_EditInitialStateGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lvd_EditInitialStateGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lvd_EditInitialStateGUI

% Last Modified by GUIDE v2.5 23-Sep-2018 17:40:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lvd_EditInitialStateGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @lvd_EditInitialStateGUI_OutputFcn, ...
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


% --- Executes just before lvd_EditInitialStateGUI is made visible.
function lvd_EditInitialStateGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to lvd_EditInitialStateGUI (see VARARGIN)

    % Choose default command line output for lvd_EditInitialStateGUI
    handles.output = hObject;

    maData = varargin{1};
    setappdata(hObject,'maData',maData);
    
    lvdData = varargin{2};
    setappdata(hObject,'lvdDta',lvdData);
    
    handles.ma_MainGUI = varargin{3};
    
    populateGUI(handles, maData, lvdData)

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes lvd_EditInitialStateGUI wait for user response (see UIRESUME)
    uiwait(handles.lvd_EditInitialStateGUI);

    
function populateGUI(handles, maData, lvdData)
    initStateModel = lvdData.initStateModel;
    
    bodyInfo = initStateModel.centralBody;
    populateBodiesCombo(handles, handles.centralBodyCombo, false);
    value = findValueFromComboBox(bodyInfo.name, handles.centralBodyCombo);
	handles.centralBodyCombo.Value = value;
    
    handles.orbitTypeCombo.String = OrbitStateEnum.getListBoxStr();
    [value, ~] = OrbitStateEnum.getIndForClass(class(initStateModel.orbitModel));
    handles.orbitTypeCombo.Value = value;
    
    orbitTypeCombo_Callback(handles.orbitTypeCombo, [], handles);
    
    handles.utText.String = fullAccNum2Str(initStateModel.time);
    
    elemVector = initStateModel.orbitModel.getElementVector();
    handles.orbit1Text.String = fullAccNum2Str(elemVector(1));
    handles.orbit2Text.String = fullAccNum2Str(elemVector(2));
    handles.orbit3Text.String = fullAccNum2Str(elemVector(3));
    handles.orbit4Text.String = fullAccNum2Str(elemVector(4));
    handles.orbit5Text.String = fullAccNum2Str(elemVector(5));
    handles.orbit6Text.String = fullAccNum2Str(elemVector(6));
    
    handles.frontalAreaText.String = fullAccNum2Str(initStateModel.aero.area);
    handles.dragCoeffText.String = fullAccNum2Str(initStateModel.aero.Cd);
    
% --- Outputs from this function are returned to the command line.
function varargout = lvd_EditInitialStateGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    if(isempty(handles))
        varargout{1} = false;
    else  
        lvdData = getappdata(handles.lvd_EditInitialStateGUI,'lvdDta');
        initStateModel = lvdData.initStateModel;
        
        bodyInfo = getSelectedBodyInfo(handles);
        initStateModel.centralBody = bodyInfo;
        
        contents = cellstr(get(handles.orbitTypeCombo,'String'));
        selOrbitType = contents{get(handles.orbitTypeCombo,'Value')};
        
        [~,enum] = OrbitStateEnum.getIndForName(selOrbitType);
        orbitClass = enum.class;

        orbit1Elem = str2double(handles.orbit1Text.String);
        orbit2Elem = str2double(handles.orbit2Text.String);
        orbit3Elem = str2double(handles.orbit3Text.String);
        orbit4Elem = str2double(handles.orbit4Text.String);
        orbit5Elem = str2double(handles.orbit5Text.String);
        orbit6Elem = str2double(handles.orbit6Text.String);
        
        orbitModel = feval(sprintf('%s',orbitClass), orbit1Elem, orbit2Elem, orbit3Elem, orbit4Elem, orbit5Elem, orbit6Elem);
        initStateModel.orbitModel = orbitModel;
        
        initStateModel.time = str2double(handles.utText.String);
        
        initStateModel.aero.area = str2double(handles.frontalAreaText.String);
        initStateModel.aero.Cd = str2double(handles.dragCoeffText.String);
        
        varargout{1} = true;
        close(handles.lvd_EditInitialStateGUI);
    end    


function bodyInfo = getSelectedBodyInfo(handles)
	maData = getappdata(handles.lvd_EditInitialStateGUI,'maData');
    celBodyData = maData.celBodyData;
    
    bodyStr = handles.centralBodyCombo.String;
    bodyName = lower(strtrim(bodyStr{handles.centralBodyCombo.Value}));
    bodyInfo = celBodyData.(bodyName);
    

function errMsg = validateInputs(handles)
    errMsg = {};
    bodyInfo = getSelectedBodyInfo(handles);
    
    ut = str2double(get(handles.utText,'String'));
    enteredStr = get(handles.utText,'String');
    numberName = 'Epoch (UT)';
    lb = 0;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(ut, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    orbitTypeStrs = handles.orbitTypeCombo.String;
    orbitType = orbitTypeStrs{handles.orbitTypeCombo.Value};
    [~,enum] = OrbitStateEnum.getIndForName(orbitType);
    orbitClass = enum.class;
    
    errMsg = feval(sprintf('%s.validateInputOrbit',orbitClass),errMsg, handles.orbit1Text, handles.orbit2Text, handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, handles.orbit6Text, bodyInfo);
    
    area = str2double(get(handles.frontalAreaText,'String'));
    enteredStr = get(handles.frontalAreaText,'String');
    numberName = 'Frontal Area';
    lb = 0;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(area, numberName, lb, ub, isInt, errMsg, enteredStr);

    cD = str2double(get(handles.dragCoeffText,'String'));
    enteredStr = get(handles.dragCoeffText,'String');
    numberName = 'Drag Coefficient';
    lb = 0;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(cD, numberName, lb, ub, isInt, errMsg, enteredStr);    
    
    
    
    
% --- Executes on selection change in orbitTypeCombo.
function orbitTypeCombo_Callback(hObject, eventdata, handles)
% hObject    handle to orbitTypeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns orbitTypeCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from orbitTypeCombo
    contents = cellstr(get(hObject,'String'));
    sel = contents{get(hObject,'Value')};
    
    [~, enum] = OrbitStateEnum.getIndForName(sel);
    
    elemNames = enum.elemNames;
    unitNames = enum.unitNames;
    
    handles.orbit1Label.String = elemNames{1};
    handles.orbit2Label.String = elemNames{2};
    handles.orbit3Label.String = elemNames{3};
    handles.orbit4Label.String = elemNames{4};
    handles.orbit5Label.String = elemNames{5};
    handles.orbit6Label.String = elemNames{6};
    
    handles.orbit1UnitLabel.String = unitNames{1};
    handles.orbit2UnitLabel.String = unitNames{2};
    handles.orbit3UnitLabel.String = unitNames{3};
    handles.orbit4UnitLabel.String = unitNames{4};
    handles.orbit5UnitLabel.String = unitNames{5};
    handles.orbit6UnitLabel.String = unitNames{6};
    
    

% --- Executes during object creation, after setting all properties.
function orbitTypeCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbitTypeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in centralBodyCombo.
function centralBodyCombo_Callback(hObject, eventdata, handles)
% hObject    handle to centralBodyCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns centralBodyCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from centralBodyCombo


% --- Executes during object creation, after setting all properties.
function centralBodyCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to centralBodyCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function utText_Callback(hObject, eventdata, handles)
% hObject    handle to utText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of utText as text
%        str2double(get(hObject,'String')) returns contents of utText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function utText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to utText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optUtCheckbox.
function optUtCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to optUtCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optUtCheckbox



function utLbText_Callback(hObject, eventdata, handles)
% hObject    handle to utLbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of utLbText as text
%        str2double(get(hObject,'String')) returns contents of utLbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function utLbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to utLbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function utUbText_Callback(hObject, eventdata, handles)
% hObject    handle to utUbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of utUbText as text
%        str2double(get(hObject,'String')) returns contents of utUbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function utUbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to utUbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit1Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit1Text as text
%        str2double(get(hObject,'String')) returns contents of orbit1Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit1Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit1Checkbox.
function optOrbit1Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit1Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit1Checkbox



function orbit1LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit1LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit1LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit1LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit1LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit1LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit1UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit1UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit1UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit1UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit1UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit1UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit2Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit2Text as text
%        str2double(get(hObject,'String')) returns contents of orbit2Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit2Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit2Checkbox.
function optOrbit2Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit2Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit2Checkbox



function orbit2LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit2LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit2LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit2LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit2LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit2LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit2UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit2UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit2UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit2UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit2UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit2UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit3Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit3Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit3Text as text
%        str2double(get(hObject,'String')) returns contents of orbit3Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit3Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit3Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit3Checkbox.
function optOrbit3Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit3Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit3Checkbox



function orbit3LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit3LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit3LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit3LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit3LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit3LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit3UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit3UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit3UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit3UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit3UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit3UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit4Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit4Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit4Text as text
%        str2double(get(hObject,'String')) returns contents of orbit4Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit4Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit4Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit4Checkbox.
function optOrbit4Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit4Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit4Checkbox



function orbit4LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit4LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit4LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit4LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit4LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit4LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit4UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit4UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit4UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit4UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit4UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit4UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit5Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit5Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit5Text as text
%        str2double(get(hObject,'String')) returns contents of orbit5Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit5Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit5Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit5Checkbox.
function optOrbit5Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit5Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit5Checkbox



function orbit5LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit5LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit5LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit5LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit5LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit5LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit5UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit5UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit5UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit5UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit5UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit5UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit6Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit6Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit6Text as text
%        str2double(get(hObject,'String')) returns contents of orbit6Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit6Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit6Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit6Checkbox.
function optOrbit6Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit6Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit6Checkbox



function orbit6LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit6LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit6LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit6LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit6LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit6LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit6UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit6UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit6UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit6UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit6UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit6UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in editLvAndStageStatesButton.
function editLvAndStageStatesButton_Callback(hObject, eventdata, handles)
% hObject    handle to editLvAndStageStatesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    lvdData = getappdata(handles.lvd_EditInitialStateGUI,'lvdDta');
    lvd_EditLvAndStagesStatesGUI(lvdData);

    

function frontalAreaText_Callback(hObject, eventdata, handles)
% hObject    handle to frontalAreaText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frontalAreaText as text
%        str2double(get(hObject,'String')) returns contents of frontalAreaText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function frontalAreaText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frontalAreaText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dragCoeffText_Callback(hObject, eventdata, handles)
% hObject    handle to dragCoeffText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dragCoeffText as text
%        str2double(get(hObject,'String')) returns contents of dragCoeffText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function dragCoeffText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dragCoeffText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in editSteeringButton.
function editSteeringButton_Callback(hObject, eventdata, handles)
% hObject    handle to editSteeringButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    lvdData = getappdata(handles.lvd_EditInitialStateGUI,'lvdDta');
    initStateModel = lvdData.initStateModel;
    lv = lvdData.launchVehicle;
    
    initStateModel.steeringModel.openEditSteeringModelUI(lv);

% --- Executes on button press in editThrottleButton.
function editThrottleButton_Callback(hObject, eventdata, handles)
% hObject    handle to editThrottleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    lvdData = getappdata(handles.lvd_EditInitialStateGUI,'lvdDta');
    initStateModel = lvdData.initStateModel;
    lv = lvdData.launchVehicle;

    initStateModel.throttleModel.openEditThrottleModelUI(lv);

% --- Executes on button press in saveAndCloseButton.
function saveAndCloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAndCloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = validateInputs(handles);

    if(isempty(errMsg))
        uiresume(handles.lvd_EditInitialStateGUI);
    else
        msgbox(errMsg,'Errors were found while editing the initial state.','error');
    end

    

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(handles.lvd_EditInitialStateGUI);