classdef uEyeMexObj < handle
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %% properties
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 properties
  Transpose = true;
 end
 
 properties (SetAccess=private)
  CamHndl;
  CamID;
  DevID;
 end % properties
 
 properties (Dependent)
  Exposure;
  PixelClock;
 end
 
 properties (Dependent, SetAccess=private)
  ExposureRange;
  ClockValues;
  SensorSize;
 end
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %% methods
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 methods
  
  % --------------------------------------------------------------------

  function obj = uEyeMexObj(varargin)
   
   IDs = uEyeMex(uEyeEnum.NoDeviceID + uEyeEnum.CameraID);
   if isempty(IDs)
    error('uEye:NoCamera', 'No cameras connected');
   end
   
   if nargin<1
    obj.CamHndl = 1;
    obj.CamID = IDs(1);
   else
    hndl = find(IDs==varargin{1});
    if isempty(hndl)
     warning('Could not find camera - using 1st camera found');
     obj = uEyeMexObj;
     return
    end
    obj.CamHndl = hndl;
    obj.CamID = IDs(hndl);
   end
  end % function uEyeMexObj
    
  % --------------------------------------------------------------------

  function I = Grab(obj)
   if obj.Transpose
    I = uEyeMex(+uEyeEnum.Grab, obj.CamHndl)';
   else
    I = uEyeMex(+uEyeEnum.Grab, obj.CamHndl);
   end
  end % function Grab
  
  % --------------------------------------------------------------------
  
  function exposure = get.Exposure(obj)
   exposure = uEyeMex(uEyeEnum.GetParam + uEyeEnum.Exposure, ...
    obj.CamHndl);
  end % function get.Exposure
  
  % --------------------------------------------------------------------
  
  function set.Exposure(obj, exposure)
   uEyeMex(uEyeEnum.SetParam + uEyeEnum.Exposure, ...
    obj.CamHndl, exposure);
  end % function set.Exposure

  % --------------------------------------------------------------------
  
  function rng = get.ExposureRange(obj)
   rng = uEyeMex(uEyeEnum.GetParam + uEyeEnum.Range ...
    + uEyeEnum.Exposure, obj.CamHndl);
   rng = struct('Min', rng(1), 'Max', rng(2), 'Inc', rng(3));
  end % function get.ExposureRange
  
  % --------------------------------------------------------------------
  
  function clck = get.PixelClock(obj)
   clck = uEyeMex(uEyeEnum.GetParam + uEyeEnum.PixelClock, obj.CamHndl);
  end % function get.PixelClock
  
  % --------------------------------------------------------------------
  
  function set.PixelClock(obj, clck)
   if any(clck==obj.ClockValues)
    uEyeMex(uEyeEnum.SetParam + uEyeEnum.PixelClock, obj.CamHndl, clck);
   else
    warning('Incorrect clock value');
   end
  end % function set.PixelClock

  % --------------------------------------------------------------------
  
  function CV = get.ClockValues(obj)
    CV = uEyeMex(uEyeEnum.GetParam + uEyeEnum.Range ...
    + uEyeEnum.PixelClock, obj.CamHndl);
  end % function get.ClockValues

  % --------------------------------------------------------------------
  
  function sz = get.SensorSize(obj)
   % Note:
   %  Matlab uses Fortran arrays (column based), uEyeMex is
   %  C-based (row based) and therefore the image size needs to be
   %  transposed
   if obj.Transpose
    sz = uEyeMex(uEyeEnum.GetParam + uEyeEnum.Sensor, obj.CamHndl);
   else
    sz = fliplr(uEyeMex(uEyeEnum.GetParam + uEyeEnum.Sensor, ...
     obj.CamHndl));
   end
  end
  
  % --------------------------------------------------------------------
  
 end % methods
 
 
end % classdef