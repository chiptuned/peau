#include <new>
using namespace std;

#include "mex.h"
#include "uEye.h"
#include "uEyeMex.h"

#define BITDEPTH 8
#define BYTESPERPIXEL 1

#define PAUSE Sleep(20);

// Camera handles - list of cameras connected to the computer
// When sending a camera handle from Matlab, this determines the index in the
// list of camera handles stored in the mex file.
// The value of the camera handle is the camera ID.
static HIDS *CAMERA_HANDLE;

// Number of camera handles stored in mex file (may be different to actual 
// number of cameras connected to computer if this changes after initialization
static INT NCAM;

// Camera IDs
static INT *CAMERA_ID;

// Array of sensor information
static SENSORINFO *SENSOR_INFO;


// Image handles to memory locations to capture image data
static char **IMAGE_HANDLE;
  
// Array of image IDs
static INT *IMAGE_ID;

// List of connect cameras
static UEYE_CAMERA_LIST *CAMERA_LIST;


// Mutex for thread safe synchronization
static HANDLE MUTEX;

// ****************************************************************************
// M E X   F U N C T I O N
// ****************************************************************************
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

 int n;
 INT hCam;
 UINT64 Camera_Function;
 
 // ------------------------------------------------------------------------
 // Ensure data is deallocated in case mex CamFunction is cleared
 // ------------------------------------------------------------------------
 mexAtExit(&MyExit);
 
 // ------------------------------------------------------------------------
 // Check if mutex exists & attempt to create.
 // ------------------------------------------------------------------------
 if (MUTEX==NULL)
  MUTEX = CreateMutex(NULL, FALSE, NULL);
 
 // ------------------------------------------------------------------------
 // Mutex couldn't be created - abort program
 // ------------------------------------------------------------------------
 if (MUTEX==NULL)
  mexErrMsgTxt("Could not create mutex");
 
 // ------------------------------------------------------------------------
 // Check if camera handles have been created
 // Ensure only one thread attempts to access CAMERA_HANDLE at a time
 // ------------------------------------------------------------------------
 WaitForSingleObject(MUTEX, INFINITE);
 if (CAMERA_HANDLE==NULL)
  InitialiseCameras();
 if (!ReleaseMutex(MUTEX))
  mexErrMsgTxt("Could not release mutex");
 
 // ------------------------------------------------------------------------
 // Check that the first input is a number
 // This is used to determine which 'function' to implement
 // ------------------------------------------------------------------------
 if (nrhs<1)
  return;
 if (!mxIsNumeric(prhs[0]))
  mexErrMsgTxt("First input must be numeric!");
 else
  Camera_Function = (UINT64) mxGetScalar(prhs[0]);

 // ------------------------------------------------------------------------
 // Run sub-function based on camera function:
 //  Functions which require no camera handle
 //  Functions that set properties (requires additional input parameter)
 //  Function that get properties (requires output)
 //  Grab function
 // ------------------------------------------------------------------------
 if (Camera_Function & UI_NO_DEVICE_ID) {
  // ---------------------
  // No device ID required
  // ---------------------
  
  if (Camera_Function & UI_SET_PARAM) {
   // Check for input parameter
   if (nrhs<2)
    mexErrMsgTxt("Must supply set parameter");
   
   // Set parameter
   SetNoDeviceIDFunction(Camera_Function, prhs[1]);
  } else {
   // Get value
   plhs[0] = GetNoDeviceIDFunction(Camera_Function);
  }
 } else {
  // ------------------
  // Device ID required
  // ------------------
  
  // Check for device ID
  if (nrhs<2 || !mxIsNumeric(prhs[1]))
   mexErrMsgTxt("Must supply camera handle.");

  // Get camera handle
  hCam = (INT)mxGetScalar(prhs[1]) - 1;

  // Check camera handle is valid
  if (hCam>=NCAM)
   mexErrMsgTxt("Invalid camera handle");
  
  if (Camera_Function & UI_GRAB)
   // GRAB IMAGE
   plhs[0] = GrabFunction(hCam);
  else if (Camera_Function & UI_SET_PARAM) {
   // SET A PARAMETER
   if (Camera_Function & UI_RANGE)
    // Set range
    SetRangeFunction(Camera_Function, hCam, prhs[2]);
   else
    // Set camera parameter
    SetFunction(Camera_Function, hCam, prhs[2]);
  } else {
   // GET A PARAMETER
   if (Camera_Function & UI_RANGE)
    // Get a range
    plhs[0] = GetRangeFunction(Camera_Function, hCam);
   else
    // Get a camera value
    plhs[0] = GetFunction(Camera_Function, hCam);
  }
 }
}

// ****************************************************************************
// I N I T I A L I S E   C A M E R A S
// ****************************************************************************
void InitialiseCameras(void) {
 int n;
 IS_RECT AOI;
 
 mexPrintf("Initializing cameras and allocating data memory ...\n");

 // ------------------------------------------------------------------------
 // Get number of connected cameras
 // ------------------------------------------------------------------------
 if (is_GetNumberOfCameras(&NCAM)!=IS_SUCCESS)
  mexErrMsgTxt("Could not get number of cameras");

 // ------------------------------------------------------------------------
 // Check at least one camera is connected
 // ------------------------------------------------------------------------
 if (NCAM<1 || NCAM==NULL)
  mexErrMsgTxt("No cameras connected");
 
 // ------------------------------------------------------------------------
 // Create memory for camera list
 // ------------------------------------------------------------------------
 if (CAMERA_LIST!=NULL)
  delete [] CAMERA_LIST;
 CAMERA_LIST = (UEYE_CAMERA_LIST*) new (nothrow) BYTE [sizeof(DWORD)
  + NCAM * sizeof(UEYE_CAMERA_INFO)];
 if (CAMERA_LIST==NULL)
  mexErrMsgTxt("Could not create camera list");
 
 // ------------------------------------------------------------------------
 // Set size of camera list inside structure
 // ------------------------------------------------------------------------
 CAMERA_LIST->dwCount = NCAM;
 
 // ------------------------------------------------------------------------
 // Get camera list
 // ------------------------------------------------------------------------
 if (is_GetCameraList(CAMERA_LIST)!=IS_SUCCESS)
  mexErrMsgTxt("Could not get camera list");
 
 // ------------------------------------------------------------------------
 // Create array of camera handles
 // ------------------------------------------------------------------------
 if (CAMERA_HANDLE!=NULL)
  delete [] CAMERA_HANDLE;
 CAMERA_HANDLE = new (nothrow) HIDS [NCAM];
 if (CAMERA_HANDLE==NULL)
  mexErrMsgTxt("Could not create array of camera handles");
 
 // ------------------------------------------------------------------------
 // Create array of camera IDs
 // ------------------------------------------------------------------------
 if (CAMERA_ID!=NULL)
  delete [] CAMERA_ID;
 CAMERA_ID = new (nothrow) INT [NCAM];
 if (CAMERA_ID==NULL)
  mexErrMsgTxt("Could not create array of camera IDs");
 
 // ------------------------------------------------------------------------
 // Create sensor info arrays
 // ------------------------------------------------------------------------
 if (SENSOR_INFO!=NULL)
  delete [] SENSOR_INFO;
 SENSOR_INFO = new (nothrow) SENSORINFO [NCAM];
 if (SENSOR_INFO==NULL)
  mexErrMsgTxt("Could not create sensor info array");
 
 // ------------------------------------------------------------------------
 // Create image handles
 // ------------------------------------------------------------------------
 if (IMAGE_HANDLE!=NULL)
  delete [] IMAGE_HANDLE;
 IMAGE_HANDLE = new (nothrow) char* [NCAM];
 if (IMAGE_HANDLE==NULL)
  mexErrMsgTxt("Could not create image handle array");
 
 // ------------------------------------------------------------------------
 // Create image id array
 // ------------------------------------------------------------------------
 if (IMAGE_ID!=NULL)
  delete [] IMAGE_ID;
 IMAGE_ID = new (nothrow) INT [NCAM];
 if (IMAGE_ID==NULL)
  mexErrMsgTxt("Could not create image ID array");
 
 for (n=0; n<NCAM; n++) {
  // --------------------------------------------------------------------
  // Obtain camera ID
  // --------------------------------------------------------------------
  CAMERA_ID[n] = (INT)CAMERA_LIST->uci[n].dwCameraID;
  CAMERA_HANDLE[n] = (HIDS) CAMERA_ID[n];
  
  // --------------------------------------------------------------------
  // Intialise camera
  // --------------------------------------------------------------------
  if (is_InitCamera(CAMERA_HANDLE+n, NULL)!=IS_SUCCESS)
   mexErrMsgTxt("Could not initialise camera");
  
  // --------------------------------------------------------------------
  // Set to 8-bit monochrome (temporary measure for now)
  // --------------------------------------------------------------------
  if (is_SetColorMode(CAMERA_HANDLE[n], IS_CM_MONO8)!=IS_SUCCESS)
   mexErrMsgTxt("Could not set camera to monochrome");
  
  // --------------------------------------------------------------------
  // Get sensor information
  // --------------------------------------------------------------------
  if (is_GetSensorInfo(CAMERA_HANDLE[n], SENSOR_INFO+n)!=IS_SUCCESS)
   mexErrMsgTxt("Could not get sensor info");
  
  // --------------------------------------------------------------------
  // Set image acquisition mode to manual
  // --------------------------------------------------------------------
  if (is_SetDisplayMode(CAMERA_HANDLE[n], IS_SET_DM_DIB)!=IS_SUCCESS)
   mexErrMsgTxt("Could not set image acquistion mode");
  
  // --------------------------------------------------------------------
  // Set trigger to software
  // --------------------------------------------------------------------
  if (is_SetExternalTrigger(CAMERA_HANDLE[n], IS_SET_TRIGGER_SOFTWARE)
    !=IS_SUCCESS)
   mexErrMsgTxt("Could not set software trigger");
  
  
  // --------------------------------------------------------------------
  // Diasble binning
  // --------------------------------------------------------------------
  if (is_SetBinning(CAMERA_HANDLE[n], IS_BINNING_DISABLE)!=IS_SUCCESS)
   mexErrMsgTxt("Could not disable binning");
  
  // --------------------------------------------------------------------
  // Disable subsampling
  // --------------------------------------------------------------------
  if (is_SetSubSampling(CAMERA_HANDLE[n], IS_SUBSAMPLING_DISABLE)
   !=IS_SUCCESS)
   mexErrMsgTxt("Could not disable sub sampling");
  
  // --------------------------------------------------------------------
  // Set AOI to full chip
  // --------------------------------------------------------------------
  AOI.s32X = 0;
  AOI.s32Y = 0;
  AOI.s32Width = SENSOR_INFO[n].nMaxWidth;
  AOI.s32Height = SENSOR_INFO[n].nMaxHeight;
  if (is_AOI(CAMERA_HANDLE[n], IS_AOI_IMAGE_SET_AOI, (void*)&AOI, 
    sizeof(AOI))!=IS_SUCCESS)
   mexErrMsgTxt("Could not set AOI");

  // --------------------------------------------------------------------
  // Allocate image memory and ID
  // --------------------------------------------------------------------
  IMAGE_ID[n] = NULL;
  IMAGE_HANDLE[n] = NULL;
  if (is_AllocImageMem(CAMERA_HANDLE[n], SENSOR_INFO[n].nMaxWidth, 
    SENSOR_INFO[n].nMaxHeight, BITDEPTH, IMAGE_HANDLE+n, 
    IMAGE_ID+n)!=IS_SUCCESS)
   mexErrMsgTxt("Could not allocate image memory");
  
  if (is_SetImageMem(CAMERA_HANDLE[n], IMAGE_HANDLE[n], IMAGE_ID[n])
    !=IS_SUCCESS)
   mexErrMsgTxt("Could not set image memory");
  
 }
}

// ****************************************************************************
// M Y   E X I T
// ****************************************************************************
void MyExit(void)
{
 int n;
 
 mexPrintf("MexAtExit called ...\n");
 
 if (NCAM!=NULL && NCAM>0 && CAMERA_HANDLE!=NULL)
  for (n=0; n<NCAM; n++)
   if (is_ExitCamera(CAMERA_HANDLE[n])!=IS_SUCCESS)
    mexWarnMsgTxt("Could not close camera");
 
 if (IMAGE_HANDLE!=NULL)
  delete [] IMAGE_HANDLE;
 
 if (IMAGE_ID!=NULL)
  delete [] IMAGE_ID;
 
 if (SENSOR_INFO!=NULL)
  delete [] SENSOR_INFO;
 
 if (CAMERA_LIST!=NULL)
  delete [] CAMERA_LIST;
 
 if (CAMERA_ID!=NULL)
  delete [] CAMERA_ID;
 
 if (CAMERA_HANDLE!=NULL)
  delete [] CAMERA_HANDLE;
 
 if (MUTEX!=NULL)
  CloseHandle(MUTEX);
}


// ****************************************************************************
// S E T   F U N C T I O N   ( N O   D E V I C E   I D )
// ****************************************************************************
void SetNoDeviceIDFunction(UINT64 Camera_Function, const mxArray *param) {
}

// ****************************************************************************
// G E T   F U N C T I O N   ( N O   D E V I C E   I D )
// ****************************************************************************
mxArray* GetNoDeviceIDFunction(UINT64 Camera_Function){
 mxArray *mxReturn;
 int n;
 
 if (Camera_Function & UI_CAMERA_ID) {
  // GET LIST OF CAMERA IDs
  // ====================================================================
  double *ptr;
  
  // Create mxArray
  mxReturn = mxCreateDoubleMatrix((mwSize)NCAM, (mwSize)1, mxREAL);
  ptr = mxGetPr(mxReturn);
  
  // Copy camera IDs to mxArray
  for (n=0; n<NCAM; n++, ptr++)
   *ptr = (double)CAMERA_ID[n];
  
 } else
  mxReturn = mxCreateDoubleMatrix(0, 0, mxREAL);
 
 return mxReturn;
}

// ****************************************************************************
// S E T   F U N C T I O N   ( D E V I C E   I D )
// ****************************************************************************
void SetFunction(UINT64 Camera_Function, INT hCam, const mxArray *param){
 
 if (Camera_Function & UI_EXPOSURE) {

  // SET EXPOSURE
  // ====================================================================
  double exposure;
  
  // Check input is numeric
  if (!mxIsNumeric(param))
   mexErrMsgTxt("Input parameter needs to be a double");
  
  // Get input exposure value
  exposure = mxGetScalar(param);
  
  // Set exposure value
  if (is_Exposure(CAMERA_HANDLE[hCam], IS_EXPOSURE_CMD_SET_EXPOSURE,
    (void *)&exposure, sizeof(double))!=IS_SUCCESS)
   mexErrMsgTxt("Could not set exposure");
 } else if (Camera_Function & UI_PIXELCLOCK) {

  // SET PIXEL CLOCK
  // ====================================================================
  UINT clock;
  
  // Check input is numeric
  if (!mxIsNumeric(param))
   mexErrMsgTxt("Input parameter needs to be a double");
  
  // Get input exposure value
  clock = (UINT)mxGetScalar(param);
  
  // Set exposure value
  if (is_PixelClock(CAMERA_HANDLE[hCam], IS_PIXELCLOCK_CMD_SET,
    (void *)&clock, sizeof(UINT))!=IS_SUCCESS)
   mexErrMsgTxt("Could not set exposure");
 }

}

// ****************************************************************************
// G E T   F U N C T I O N   ( D E V I C E   I D )
// ****************************************************************************
mxArray* GetFunction(UINT64 Camera_Function, INT hCam){
 mxArray *mxReturn;
 int n;
 
 if (Camera_Function & UI_EXPOSURE) {

  // GET EXPOSURE 
  // ====================================================================
  double exposure;
  
  // Get current camera exposure
  if (is_Exposure(CAMERA_HANDLE[hCam], IS_EXPOSURE_CMD_GET_EXPOSURE,
    (void *)&exposure, sizeof(double))!=IS_SUCCESS)
   mexErrMsgTxt("Could not get exposure");
  
  // Create mxArray (double scalar) / set output exposure value
  mxReturn = mxCreateDoubleScalar(exposure);
  
  
 } else if (Camera_Function & UI_PIXELCLOCK) {
  
  // GET PIXEL CLOCK VALUE
  // ====================================================================
  UINT clock;
  
  // Get current pixel clock value
  if (is_PixelClock(CAMERA_HANDLE[hCam], IS_PIXELCLOCK_CMD_GET,
    (void *)&clock, sizeof(UINT))!=IS_SUCCESS)
   mexErrMsgTxt("Could not get pixel clock value");
  
  // Create mxArray (double scalar) and set value
  mxReturn = mxCreateDoubleScalar((double)clock);
  
 } else if (Camera_Function & UI_SENSOR) {
  
  // GET SENSOR SIZE
  // ====================================================================
  double *sz;
  
  // Create mxArray
  mxReturn = mxCreateDoubleMatrix(1, 2, mxREAL);
  sz = mxGetPr(mxReturn);
  
  // Set sensor values
  sz[0] = (double)SENSOR_INFO[hCam].nMaxHeight;
  sz[1] = (double)SENSOR_INFO[hCam].nMaxWidth;
  
 } else
  mxReturn = mxCreateDoubleMatrix(0, 0, mxREAL);
 
 return mxReturn;
}

// ****************************************************************************
// G E T   F U N C T I O N   R A N G E   ( D E V I C E   I D )
// ****************************************************************************
mxArray* GetRangeFunction(UINT64 Camera_Function, INT hCam){
 mxArray *mxReturn;
 int n;
 
 if (Camera_Function & UI_EXPOSURE) {

  // GET EXPOSURE RANGE
  // ====================================================================
  double *range;
  
  // Create output mxArray
  mxReturn = mxCreateDoubleMatrix(3, 1, mxREAL);
  range = mxGetPr(mxReturn);
  
  // Get exposure range
  if (is_Exposure(CAMERA_HANDLE[hCam], IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE,
    (void *)range, 3*sizeof(double))!=IS_SUCCESS)
   mexErrMsgTxt("Could not get exposure range");
  
 } else if (Camera_Function & UI_PIXELCLOCK) {
  
  // GET LIST OF CLOCK VALUES
  // ====================================================================
  UINT N=0, *clock;
  
  // Get number of pixel clock values
  if (is_PixelClock(CAMERA_HANDLE[hCam], IS_PIXELCLOCK_CMD_GET_NUMBER,
    (void *)&N, sizeof(N))!=IS_SUCCESS)
   mexErrMsgTxt("Could not get number of pixel clock values");
  
  // Create mxArray
  mxReturn = mxCreateNumericMatrix((mwSize)N, 1, mxUINT32_CLASS, mxREAL);
  clock = (UINT*)mxGetData(mxReturn);
  
  // Obtain clock settings
  if (is_PixelClock(CAMERA_HANDLE[hCam], IS_PIXELCLOCK_CMD_GET_LIST,
    (void *)clock, N*sizeof(UINT))!=IS_SUCCESS)
   mexErrMsgTxt("Could not get list of pixel clock values");
  
 } else
  mxReturn = mxCreateDoubleMatrix(0, 0, mxREAL);
 
 return mxReturn;
}

void SetRangeFunction(UINT64 Camera_Function, INT hCam, const mxArray *param) {
}

// ****************************************************************************
// G R A B   I M A G E
// ****************************************************************************
mxArray* GrabFunction(INT hCam) {
 mxArray *mxImg;
 char *img;
 DWORD width, height;
 
 // Get sensor size
 width = SENSOR_INFO[hCam].nMaxWidth;
 height = SENSOR_INFO[hCam].nMaxHeight;

 // Generate Matlab memory
 img = (char *)mxMalloc(sizeof(char)*width*height);
 if (img==NULL)
  mexErrMsgTxt("Could not create image memory");

 // Generate empty mxArray
 mxImg =  mxCreateNumericMatrix(0, 0, mxUINT8_CLASS, mxREAL);
 
 // Set mxArray dimensions
 mxSetM(mxImg, width);
 mxSetN(mxImg, height);
 
 // set mxArray pointer to img
 mxSetData(mxImg, img);

 // Capture frame
 if (is_FreezeVideo(CAMERA_HANDLE[hCam], IS_WAIT)!=IS_SUCCESS)
  mexErrMsgTxt("Could not capture frame");

 // Copy frame memory to mxArray
 is_CopyImageMem(CAMERA_HANDLE[hCam], IMAGE_HANDLE[hCam], 
   IMAGE_ID[hCam], img); 

 // Return mxArray
 return mxImg;
}