function varargout = lvd_editEventGUI(varargin)
% LVD_EDITEVENTGUI MATLAB code for lvd_editEventGUI.fig
%      LVD_EDITEVENTGUI, by itself, creates a new LVD_EDITEVENTGUI or raises the existing
%      singleton*.
%
%      H = LVD_EDITEVENTGUI returns the handle to a new LVD_EDITEVENTGUI or the handle to
%      the existing singleton*.
%
%      LVD_EDITEVENTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LVD_EDITEVENTGUI.M with the given input arguments.
%
%      LVD_EDITEVENTGUI('Property','Value',...) creates a new LVD_EDITEVENTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lvd_editEventGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lvd_editEventGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lvd_editEventGUI

% Last Modified by GUIDE v2.5 04-Jan-2019 09:15:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lvd_editEventGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @lvd_editEventGUI_OutputFcn, ...
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


% --- Executes just before lvd_editEventGUI is made visible.
function lvd_editEventGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lvd_editEventGUI (see VARARGIN)

    % Choose default command line output for lvd_editEventGUI
    handles.output = hObject;

    event = varargin{1};
    setappdata(hObject,'event',event);

    populateGUI(handles, event);
    
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes lvd_editEventGUI wait for user response (see UIRESUME)
    uiwait(handles.lvd_editEventGUI);


function populateGUI(handles, event)
    set(handles.eventNameText,'String',event.name);
    
    termCond = event.termCond;
    set(handles.termCondNameLabel,'String',termCond.getName());
    
    set(handles.actionsListbox,'String',event.getActionsListboxStr());
    set(handles.actionsListbox,'Value',1);
    
    handles.colorSpecCombo.String = ColorSpecEnum.getListboxStr();
    [~,ind] = ColorSpecEnum.getEnumForListboxStr(event.colorLineSpec.color.name);
    handles.colorSpecCombo.Value = ind;
    
    handles.lineSpecCombo.String = LineSpecEnum.getListboxStr();
    [~,ind] = LineSpecEnum.getEnumForListboxStr(event.colorLineSpec.lineSpec.name);
    handles.lineSpecCombo.Value = ind;
    
    handles.integratorCombo.String = IntegratorEnum.getListBoxStrs();
    ind = IntegratorEnum.getIndOfListboxStr(event.integrator.nameStr);
    handles.integratorCombo.Value = ind;
    integratorCombo_Callback(handles.integratorCombo, [], handles);
    
    handles.checkSoITransCheckbox.Value = double(event.checkForSoITrans);
    
    handles.intStepSizeText.String = fullAccNum2Str(event.integrationStep);

% --- Outputs from this function are returned to the command line.
function varargout = lvd_editEventGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    if(isempty(handles))
        varargout{1} = [];
    else
        event = getappdata(handles.lvd_editEventGUI,'event');
        
        evtName = get(handles.eventNameText,'String');
        event.name = evtName;
        
        nameStr = handles.colorSpecCombo.String(handles.colorSpecCombo.Value);
        [enum,~] = ColorSpecEnum.getEnumForListboxStr(nameStr);
        event.colorLineSpec.color = enum;
    
        nameStr = handles.lineSpecCombo.String(handles.lineSpecCombo.Value);
        [enum,~] = LineSpecEnum.getEnumForListboxStr(nameStr);
    	event.colorLineSpec.lineSpec = enum;
        
        contents = cellstr(get(handles.integratorCombo,'String'));
        nameStr = contents{get(handles.integratorCombo,'Value')};
        [~,m] = IntegratorEnum.getIndOfListboxStr(nameStr);
        event.integrator = m;
        
        event.checkForSoITrans = logical(handles.checkSoITransCheckbox.Value);
        
        event.integrationStep = str2double(get(handles.intStepSizeText,'String'));
        
        close(handles.lvd_editEventGUI);
    end

% --- Executes on button press in saveAndCloseButton.
function saveAndCloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAndCloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = validateInputs(handles);

    if(isempty(errMsg))
       uiresume(handles.lvd_editEventGUI);
    else
        msgbox(errMsg,'Errors were found while editing the event.','error');
    end  
    
    
function errMsg = validateInputs(handles)
    errMsg = {};
    
    value = str2double(get(handles.intStepSizeText,'String'));
    enteredStr = get(handles.intStepSizeText,'String');
    numberName = 'Integrator Output Step Size';
    lb = -Inf;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(handles.lvd_editEventGUI);


function eventNameText_Callback(hObject, eventdata, handles)
% hObject    handle to eventNameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eventNameText as text
%        str2double(get(hObject,'String')) returns contents of eventNameText as a double


% --- Executes during object creation, after setting all properties.
function eventNameText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventNameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in actionsListbox.
function actionsListbox_Callback(hObject, eventdata, handles)
% hObject    handle to actionsListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns actionsListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from actionsListbox
    if(strcmpi(get(handles.lvd_editEventGUI,'SelectionType'),'open'))
        event = getappdata(handles.lvd_editEventGUI,'event');
        lv = event.script.lvdData.launchVehicle;
        
        if(not(isempty(event.getActionsListboxStr())))
            selActionInd = get(handles.actionsListbox,'Value');
            action = event.getActionForInd(selActionInd);

            action.openEditActionUI(action, lv);

            actionsListBoxStr = event.getActionsListboxStr();

            if(not(isempty(actionsListBoxStr)))
                set(handles.actionsListbox,'String',actionsListBoxStr);
            else
                set(handles.actionsListbox,'String','');
                set(handles.actionsListbox,'Value',1);
            end
        end
    end


% --- Executes during object creation, after setting all properties.
function actionsListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actionsListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addActionButton.
function addActionButton_Callback(hObject, eventdata, handles)
% hObject    handle to addActionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    event = getappdata(handles.lvd_editEventGUI,'event');
    lv = event.script.lvdData.launchVehicle;
    actionStrs = EventActionEnum.getActionTypeNameStrs();

    [dialogInd,tf] = listdlg('ListString',actionStrs, ...
                             'Name','Select Action', ...
                             'PromptString',{'Select the action you wish to add','to this event:'}, ...
                             'SelectionMode','single', ...
                             'ListSize',[210 300]);
    
    if(tf == 1)
        [m,~] = enumeration('EventActionEnum');
        inds = strcmpi({m.nameStr},actionStrs{dialogInd});
        
        actionEnum = m(inds);
        
        newAction = feval(actionEnum.classNameStr);
        addActionTf = newAction.openEditActionUI(newAction, lv);
        
        if(addActionTf)
            event.addAction(newAction);
        end
        
        set(handles.actionsListbox,'String',event.getActionsListboxStr());
        
        if(handles.actionsListbox.Value <= 0)
            handles.actionsListbox.Value = 1;
        elseif(handles.actionsListbox.Value > length(handles.actionsListbox.String))
            handles.actionsListbox.Value = length(handles.actionsListbox.String);
        end
    end
    
% --- Executes on button press in removeActionButton.
function removeActionButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeActionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    event = getappdata(handles.lvd_editEventGUI,'event');

    selActionInd = get(handles.actionsListbox,'Value');
    event.removeActionByInd(selActionInd);
    
    set(handles.actionsListbox,'String',event.getActionsListboxStr());
    
    aListBosStr = get(handles.actionsListbox,'String');
    if(iscell(aListBosStr) && length(aListBosStr)<selActionInd)
        set(handles.actionsListbox,'Value',length(aListBosStr));
    end

% --- Executes on button press in editTermCondParamsButton.
function editTermCondParamsButton_Callback(hObject, eventdata, handles)
% hObject    handle to editTermCondParamsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    event = getappdata(handles.lvd_editEventGUI,'event');
    lvd_editEvtTermCond(event);
    
    termCond = event.termCond;
    set(handles.termCondNameLabel,'String',termCond.getName());

% --- Executes when user attempts to close lvd_editEventGUI.
function lvd_editEventGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to lvd_editEventGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
    delete(hObject);


% --- Executes on selection change in colorSpecCombo.
function colorSpecCombo_Callback(hObject, eventdata, handles)
% hObject    handle to colorSpecCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colorSpecCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colorSpecCombo


% --- Executes during object creation, after setting all properties.
function colorSpecCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorSpecCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lineSpecCombo.
function lineSpecCombo_Callback(hObject, eventdata, handles)
% hObject    handle to lineSpecCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lineSpecCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lineSpecCombo


% --- Executes during object creation, after setting all properties.
function lineSpecCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineSpecCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkSoITransCheckbox.
function checkSoITransCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to checkSoITransCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSoITransCheckbox


% --- Executes on selection change in integratorCombo.
function integratorCombo_Callback(hObject, eventdata, handles)
% hObject    handle to integratorCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns integratorCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from integratorCombo
    contents = cellstr(get(hObject,'String'));
    
    if(get(hObject,'Value') < 1 || get(hObject,'Value') > length(contents))
        nameStr = contents{1};
    else
        nameStr = contents{get(hObject,'Value')};
    end

    [~,m] = IntegratorEnum.getIndOfListboxStr(nameStr);
    handles.integratorDetailLabel.String = m.descStr;

% --- Executes during object creation, after setting all properties.
function integratorCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to integratorCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on lvd_editEventGUI or any of its controls.
function lvd_editEventGUI_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lvd_editEventGUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
    switch(eventdata.Key)
        case 'return'
            saveAndCloseButton_Callback(handles.saveAndCloseButton, [], handles);
        case 'enter'
            saveAndCloseButton_Callback(handles.saveAndCloseButton, [], handles);
        case 'escape'
            close(handles.lvd_editEventGUI);
    end


function intStepSizeText_Callback(hObject, eventdata, handles)
% hObject    handle to intStepSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intStepSizeText as text
%        str2double(get(hObject,'String')) returns contents of intStepSizeText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function intStepSizeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intStepSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in editForceModelsButton.
function editForceModelsButton_Callback(hObject, eventdata, handles)
% hObject    handle to editForceModelsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    event = getappdata(handles.lvd_editEventGUI,'event');
    
    fms = event.forceModels;
    initSelInds = [];
    for(i=1:length(fms))
        if(fms(i).canBeDisabled)
            initSelInds(end+1) = ForceModelsEnum.getIndOfDisablableListboxStrsForModel(fms(i).model); %#ok<AGROW>
        end
    end
    
    [Selection,ok] = listdlgARH('ListString',ForceModelsEnum.getListBoxStrsOfDisablableModels(), ...
                                'SelectionMode', 'multiple', ...
                                'ListSize', [300, 300], ...
                                'Name', 'Select Force Models', ...
                                'PromptString', {'Select the Force Models you wish to have enabled during this','event.  Gravity is always enabled.  Disabling Thrust during','periods of coasting may improve performance considerably.'}, ...
                                'InitialValue', initSelInds);

	if(ok == 1)
        m = ForceModelsEnum.getEnumsOfDisablableForceModels();
        event.forceModels = [ForceModelsEnum.getAllForceModelsThatCannotBeDisabled(), m(Selection)'];
	end
