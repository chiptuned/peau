classdef uEyeEnum < uint64
 
 enumeration
  Grab (1)

  Exposure (bitshift(1, 1))
  PixelClock (bitshift(1, 2))
  Sensor (bitshift(1, 3))
  
  CameraID (bitshift(1, 1))
  CameraIsOpen (bitshift(1, 2))
  
  SetParam (bitshift(1, 40))
  GetParam (bitshift(1, 41))
  Range (bitshift(1, 42))
  NoDeviceID (bitshift(1, 43))
 end
end