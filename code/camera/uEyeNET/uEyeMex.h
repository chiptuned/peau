#define UI_GRAB      (1ULL)

#define UI_EXPOSURE     (1ULL<<1)
#define UI_PIXELCLOCK    (1ULL<<2)
#define UI_SENSOR     (1ULL<<3)

#define UI_CAMERA_ID    (1UL<<1)
#define UI_CAMERA_IS_OPEN   (1UL<<2)

#define UI_SET_PARAM    (1ULL<<40)
#define UI_GET_PARAM    (1ULL<<41)
#define UI_RANGE     (1ULL<<42)
#define UI_NO_DEVICE_ID    (1ULL<<43)

void InitialiseCameras(void);
void MyExit(void);

// Function to set a parameter that does not require a camera handle
void SetNoDeviceIDFunction(UINT64 Camera_Function, const mxArray *param);

// Function to get a parameter that does not require a camera handle
mxArray* GetNoDeviceIDFunction(UINT64 Camera_Function);

// Function to set a parameter that requires a camera handle
void SetFunction(UINT64 Camera_Function, INT hCam, const mxArray *param);

// Function to get a parameter that requires a camera handle
mxArray* GetFunction(UINT64 Camera_Function, INT hCam);

// Function to set a parameter range that requires a camera handle
void SetRangeFunction(UINT64 Camera_Function, INT hCam, const mxArray *param);

// Function to get a parameter range that requires a camera handle
mxArray* GetRangeFunction(UINT64 Camera_Function, INT hCam);

// Function to peform image capture
mxArray* GrabFunction(INT hCam);

// void CloseCameras(void);
// void ClearImages(void);
// void InitializeMex(void);