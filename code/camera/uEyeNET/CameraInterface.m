% Author: Dr Adam S Wyatt
classdef (Abstract) CameraInterface < Object & handle
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % P R O P E R T I E S (SetAccess=protected)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 properties (Abstract, SetAccess=protected)
  CameraObj;
  ImgInfo;
 end
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % P R O P E R T I E S (Dependent)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 properties (Abstract, Dependent)
  Exposure;
  PixelClock;
  AOI;
%   BlackLevel;
%   Gain;
 end
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % P R O P E R T I E S (SetAccess=private)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 properties (Abstract, Dependent, SetAccess=private)
  CameraID;
  DeviceID;
  SensorInfo;
  CameraInfo;
  ExposureRange;
  PixelClockRange;
 end
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % P R O P E R T I E S (Abstract, Constant, Hidden)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 properties (Abstract, Constant, Hidden)
  MaxCameraID;
 end
 
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % M E T H O D S
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 methods
  
  Initialize(obj, varargin);
  Close(obj);
  FreeImages(obj);
  ImgIDs(obj);
  AllocateImageMemory(obj);
  I = GrabImage(obj, varargin);
  I = ReadImage(obj, ID);
  
  % ====================================================================
  
  function obj = CameraInterface(varargin)
   obj@uiobjects.Object(varargin);
  end % function obj = camera(varargin)
    
  % ====================================================================

 end % methods
 
 methods (Abstract)
 end % methods (Abstract)
 
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % E V E N T S
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 events
  ExposureChanged;
  PixelClockChanged;
  AOIChanged;
  ImageGrabbed;
 end % events
 
end % classdef
