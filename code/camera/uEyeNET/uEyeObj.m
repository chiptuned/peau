% Author: Dr Adam S Wyatt
classdef uEyeObj < CameraInterface
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % P R O P E R T I E S (SetAccess=protected)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 properties (SetAccess=protected)
  CameraObj;
  ImgInfo;
 end
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % P R O P E R T I E S (Dependent)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 properties (Dependent)
  Exposure;
  Gain;
  PixelClock;
  BlackLevel;
  HorizontalBinning;
  VerticalBinning;
  HorizontalSubsampling;
  VerticalSubsampling;
  AOI;
 end
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % P R O P E R T I E S (Dependent, SetAccess=private)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 properties (Dependent, SetAccess=private)
  CameraID;
  DeviceID;
  SensorInfo;
  CameraInfo;
  ExposureRange;
  PixelClockRange;
 end
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % P R O P E R T I E S (Constant, Hidden)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 properties (Constant, Hidden)
  MaxCameraID = 254;
 end
 

 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % M E T H O D S - CONSTRUCTOR/DESCTRUCTOR
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 methods
 
  % ====================================================================
 
  function obj = uEyeObj(varargin)
   
   obj@CameraInterface(varargin);
   
    
   % Load uEyeDotNet assembly
   obj.LoadAssembly('uEyeDotNet');
   
   % Create camera object
   obj.CameraObj = uEye.Camera;
   
   CamID = obj.FindArg(varargin, 'CameraID');
   if ~isempty(CamID)
    try
     obj.Initialize(CamID);
    end
   end
%    try
%     obj.CameraObj = uEye.Camera(obj.GetCameraID(varargin));
%    end
    
   
  end % function obj = uEyeObj(varargin)
  
  % ====================================================================

  function delete(obj)
   try
    % Close camera
    obj.Close;

    % Delete camera
    delete(obj.CameraObj);
   end

  end % function delete(obj)
  
 end % methods (Constructor/destructor)

 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % M E T H O D S - SET/GET
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 methods
  
%   function val = get.BlackLevel(obj)
%    [err, val] = obj.CameraObj.BlackLevel.Get;
%    if strcmp(char(err), 'SUCCESS') && strcmp(char(val), 'Enable')
%     val = true;
%    else
%     val = false;
%    end
%   end
%   
%   function set.BlackLevel(obj, val)
%    err = char(obj.CameraObj.BlackLevel.Set);
%    if ~isequal(err, uEye.Defines.Status.SUCCESS)
%     error(obj.Identifier('setAutoBlackLevelFailed'), ...
%      'Could not set auto black level:\n%s\n', err);
%    end
%   end
  
  % ====================================================================
  
  function val = get.Exposure(obj)
   [err, val] = obj.CameraObj.Timing.Exposure.Get;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getExposureFailed'), ...
     'Could not get exposure value:\n%s\n', char(err));
   end
  end % function val = get.Exposure(obj)
  
  % ====================================================================
  
  function set.Exposure(obj, val)
   err = obj.CameraObj.Timing.Exposure.Set(val);
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('setExposureFailed'), ...
     'Could not set exposure value:\n%s\n', char(err));
   end
   
   % Notify event
   obj.notify('ExposureChanged');
  end % function set.Exposure(obj, val)
   
  % ====================================================================
  
  function val = get.PixelClock(obj)
   [err, val] = obj.CameraObj.Timing.PixelClock.Get;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getPixelClockFailed'), ...
     'Could not get pixel clock value:\n%s\n', char(err));
   end
  end % function val = get.PixelClock(obj)
  
  % ====================================================================
  
  function set.PixelClock(obj, val)
   err = obj.CameraObj.Timing.PixelClock.Set(val);
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('setPixelClockFailed'), ...
     'Could not set pixel clock value:\n%s\n', char(err));
   end
   
   % Notify event
   obj.notify('PixelClockChanged');
  end % function set.PixelClock(obj, val)
  
  % ====================================================================
  
  function val = get.AOI(obj)
   [err, x, y, w, h] = obj.CameraObj.Size.AOI.Get;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getAOIFailed'), ...
     'Could not set pixel clock value:\n%s\n', char(err));
   end
   val = struct('Left', x, 'Top', y, 'Width', w, 'Height', h);
  end % function val = get.AOI(obj)
  
  % ====================================================================
  
  % Set camera area of interest (AOI) and free/allocate image memory
  % accordingly
  function set.AOI(obj, val)
   
   % Get maximumum sensor size
   MaxSize = obj.SensorInfo.MaxSize;
   
   % Get current values
   CurrentSize = obj.AOI;
   
   % Check if input is a vector [Left Top] or [Left Top Width Height]
   if ischar(val) && strcmpi(val, 'Full')
    val = struct('Left', 0, 'Top', 0, ...
     'Width', MaxSize.Width, 'Height', MaxSize.Height);
   elseif isnumeric(val) 
    if numel(val)==2
     val = struct('Left', val(1), 'Top', val(2));
    else
     val = struct('Left', val(1), 'Top', val(2), ...
      'Width', val(3), 'Height', val(4));
    end
   end
   
   % Check for & coerce left value
   if ~isfield(val, 'Left')
    val.Left = CurrentSize.Left;
   else
    if val.Left<0
     val.Left = 0;
    end
   end
   
   % Check for & coerce top value
   if ~isfield(val, 'Top')
    val.Top = CurrentSize.Top;
   else
    if val.Top<0
     val.Top = 0;
    end
   end
   
   % Check for & coerce Width value
   if ~isfield(val, 'Width')
    val.Width = CurrentSize.Width;
   end
   val.Width = min(val.Width, MaxSize.Width-val.Left);

   % Check for & coerce Height value
   if ~isfield(val, 'Height')
    val.Height = CurrentSize.Height;
   end
   val.Height = min(val.Height, MaxSize.Height-val.Top);

   % Check if values changed
   if ~isequal(val, CurrentSize)
    
    % Change AOI
    err = obj.CameraObj.Size.AOI.Set( ...
      val.Left, val.Top, val.Width, val.Height);
    if ~isequal(err, uEye.Defines.Status.SUCCESS)
     error(obj.Identifier('setAOIFailed'), ...
      'Could not set AOI value:\n%s\n', char(err));
    % Check if image size has changed
    elseif CurrentSize.Width~=val.Width ...
      || CurrentSize.Height~=val.Height
     % Free old images and allocate new memory
     obj.FreeImages;
     obj.AllocateImageMemory;
    end
    
    % Notify event
    obj.notify('AOIChanged');
   end
  end % function set.AOI(obj, val)
 
  
  % ====================================================================

  function val = get.CameraID(obj)
   [err, val] = obj.CameraObj.Device.GetCameraID;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getCameraIDFailed'), ...
     'Could not obtain camera ID:\n%s\n', char(err));
   end
  end % function val = get.CameraID(obj)
  
  % ====================================================================
 
  function val = get.DeviceID(obj)
   [err, val] = obj.CameraObj.Device.GetDeviceID;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getDeviceIDFailed'), ...
     'Could not obtain device ID:\n%s\n', char(err));
   end
  end % function val = get.DeviceID(obj)
  
  % ====================================================================

  function val = get.SensorInfo(obj)
   [err, val] = obj.CameraObj.Information.GetSensorInfo;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getSensorInfoFailed'), ...
     'Could not obtain sensor information:\n%s\n', char(err));
   end
  end % function val = get.SensorInfo(obj)
  
  % ====================================================================
  
  function val = get.CameraInfo(obj)
   [err, val] = obj.CameraObj.Information.GetCameraInfo;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getCameraInfoFailed'), ...
     'Could not obtain camera information:\n%s\n', char(err));
   end
  end % function val = get.CameraInfo(obj)

  % ====================================================================
 
  function val = get.ExposureRange(obj)
   [err, val] = obj.CameraObj.Timing.Exposure.GetRange;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getExposureRangeFailed'), ...
     'Could not obtain the exposure range:\n%s\n', char(err));
   end
   val = struct( ...
    'Minimum', val.Minimum, ...
    'Maximum', val.Maximum, ...
    'Increment', val.Increment);
  end
  
  % ====================================================================
 
  function val = get.PixelClockRange(obj)
   [err, val] = obj.CameraObj.Timing.PixelClock.GetRange;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getExposureRangeFailed'), ...
     'Could not obtain the exposure range:\n%s\n', char(err));
   end
   val = struct( ...
    'Minimum', val.Minimum, ...
    'Maximum', val.Maximum, ...
    'Increment', val.Increment);
  end
  
  % ====================================================================
  
 end % methods
 
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % M E T H O D S (Sealed) - INTERFACE IMPLEMENTATION
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 methods (Sealed)
  
  % ====================================================================
  
  function Initialize(obj, varargin)
   if isempty(obj.CameraObj)
    obj.CameraObj = uEye.Camera;
   end
   
   if nargin==1
    CamID = obj.GetCameraID('CameraID', 0);
   elseif nargin==2
    CamID = obj.GetCameraID('CameraID', varargin{1});
   else
    CamID = obj.GetCameraID(varargin);
   end
   
   % Check if device is already open
   if obj.CameraObj.IsOpened && obj.CameraID==CamID
    warning(obj.Identifier('isOpen'), ...
     'Camera is alreay open');
   else
    if obj.CameraObj.IsOpened
     obj.Close;
    end
    
    % Try to initialize
    err = obj.CameraObj.Init(CamID);
    if ~isequal(err, uEye.Defines.Status.SUCCESS)
     % Initialization failed
     error(obj.Identifier('initializationFailed'), ...
      'Could not initialize camera:\n%s\n', char(err));
    end
    
    % Set colormode to 8 bit greyscale (will change implementation
    % at a later date to support colour mode / 10 bit etc.
    obj.CameraObj.PixelFormat.Set( ...
     uEye.Defines.ColorMode.SensorRaw8);
    
    % Allocate image memory
    obj.AllocateImageMemory;
   end
  end % function Initialize(obj, varargin)
  
  % ====================================================================
  
  function Close(obj)
   % Free allocated memory
   obj.FreeImages;

   err = obj.CameraObj.Exit;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('closeFailed'), ...
     'Could not close camera:\n%s\n', char(err));
   end
  end % function Close(obj)
  
  % ====================================================================

  function FreeImages(obj, ImgIDs)
   if ~exist('ImgIDs', 'var') || isempty(ImgIDs)
    err = obj.CameraObj.Memory.Free(obj.GetImgIDs);
    if ~isequal(err, uEye.Defines.Status.SUCCESS)
     warning(obj.Identifier('freeMemoryFailed'), ...
      'Could not free memory:\n%s\n', char(err));
    end
   else
    err = obj.CameraObj.Memory.Free(ImgIDs);
    if ~isequal(err, uEye.Defines.Status.SUCCESS)
     warning(obj.Identifier('freeMemoryFailed'), ...
      'Could not free memory:\n%s\n', char(err));
    end
   end
  end % function FreeImages(obj, ImgIDs)

  % ====================================================================

  function ImgIDs = GetImgIDs(obj)
   [err, ImgIDs] = obj.CameraObj.Memory.GetList;
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('getImgIDsFailed'), ...
     'Could not get list of image IDs:\n%s\n', char(err));
   end
  end % function ImgIDs = GetImgIDs(obj)
  
  % ====================================================================

  function AllocateImageMemory(obj)
   % Allocate memory
   [err, obj.ImgInfo.ID] = obj.CameraObj.Memory.Allocate(true);
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('imageAllocateFailed'), ...
     'Could not allocate image:\n%s\n', char(err));
   end

   % Obtain image information
   [err, obj.ImgInfo.Width, obj.ImgInfo.Height, obj.ImgInfo.Bits, ...
    obj.ImgInfo.Pitch] = obj.CameraObj.Memory.Inquire(obj.ImgInfo.ID);
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('imageAllocationFailed'), ...
     'Could not allocate image:\n%s\n', char(err));
   end
  end % function AllocateImageMemory(obj)
  
  % ====================================================================

  function I = GrabImage(obj, varargin)
   if isempty(obj.ImgInfo)
    obj.AllocateImageMemory;
   end

   % Acquire image
   % ----------------------------------------------------------------
   
   % Check for time out
   TimeOut = obj.FindArg(varargin, 'TimeOut');
   if ~isempty(TimeOut) && isnumeric(TimeOut)
    err = obj.CameraObj.Acquisition.Freeze(TimeOut);
   else
    % Check for no wait flag
    NoWait = obj.FindArg(varargin, 'NoWait');
    if ~isempty(NoWait) && NoWait
     err = obj.CameraObj.Acquisition.Freeze(...
      uEye.Defines.DeviceParameter.DontWait);
    else
     err = obj.CameraObj.Acquisition.Freeze(...
      uEye.Defines.DeviceParameter.Wait);
    end
   end
   
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error(obj.Identifier('freezeFailed'), ...
     'Could not grab image:\n%s\n', char(err));
   end
   
   if nargout>0
    I = obj.ReadImage;

    % Notify event
    obj.notify('ImageGrabbed');
   end
   
  end % function I = GrabImage(obj)
  
  % ====================================================================
  
  function I = ReadImage(obj, ID)
   if nargin<2 || isempty(ID)
    ID = obj.ImgInfo.ID;
   end
   
   % Extract image
   [err, I] = obj.CameraObj.Memory.CopyToArray(ID); 
   if ~isequal(err, uEye.Defines.Status.SUCCESS)
    error('Could not obtain image data');
   end

   % Reshape image
   I = reshape(uint8(I), [obj.ImgInfo.Width, obj.ImgInfo.Height, ...
    obj.ImgInfo.Bits/8]);
  end
  
  % ====================================================================
  
 end % methods (Interface implementation)

  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % M E T H O D S   (ACCESS=PRIVATE)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 methods (Access=private)
  
  % ====================================================================

  function camID = GetCameraID(obj, varargin)
   
   % Get camera ID (if given)
   camID = obj.FindArg(varargin, 'CameraID');
   
   if isempty(camID) || ~isscalar(camID) || ~isnumeric(camID)
    camID = 0;
   elseif camID<0
    camID = 0;
   elseif camID>obj.MaxCameraID
    camID=obj.MaxCameraID;
   end % if
   
   
   % Check if using device ID
   UseDevID = obj.FindArg(varargin, 'UseDeviceID');
   
   if ~isempty(UseDevID) && UseDevID
    camID = bitor(camID, ...
     int32(uEye.Defines.DeviceEnumeration.UseDeviceID));
   end % if
  end % function camID = GetCameraID(obj, varargin)
  
  % ====================================================================

 end % methods (Access=private)
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % M E T H O D S   (STATIC)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 methods (Static)
  
  % ====================================================================
  
  % Check if required .NET assemblies have been loaded; load if required
  function LoadAssembly(varargin)
   
   % Get list of loaded assemblies
   asm = System.AppDomain.CurrentDomain.GetAssemblies;
   
   % Get assembly info as cellstring
   Lines = cell(asm.Length, 1);
   for n=1:asm.Length
    temp = asm.Get(n-1);
    Lines{n} = char(temp.FullName);
   end
     
   % Loop through inputs and check if library is loaded
   for narg=1:nargin
    str = varargin{narg};
    
    % Check if library is loaded (should be 1st part of string)
    if ~any(strncmpi(Lines, str, length(str)))
     
     % Add assembly (must be located in object folder)
     NET.addAssembly(fullfile(...
      fileparts(which('uEyeNET.uEyeObj')), ...
      [str '.dll']));
    end
   end
  
  end % function LoadAssembly
  
  % ====================================================================
  
  % Return warning/error identification string
  function str = Identifier(str)
   str = ['STFC:uEyeNET:' strrep(str, ' ', '_')];
  end % function str = Identifier(str)
   
  % ====================================================================
    
 end % methods (Static)
 
end % classdef