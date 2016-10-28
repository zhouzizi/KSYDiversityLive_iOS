#ifndef __FUNAMA_H
#define __FUNAMA_H
#ifdef _WIN32
#define FUNAMA_API __declspec(dllexport)
#else
#define FUNAMA_API
#endif

/**
\brief Initialization, must be called exactly once before all other functions.
	The buffers should NEVER be freed while the other functions are still being called.
	You can call this function multiple times to "switch pointers".
\param v2data should point to contents of the "v2.bin" we provide
\param ardata should point to contents of the "ar.bin" we provide
*/
FUNAMA_API void fuInit(float* v2data,float* ardata);
/**
\brief Call this function when the GLES context has been lost and recreated.
	That isn't a normal thing, so this function could leak resources on each call.
*/
FUNAMA_API void fuOnDeviceLost();
/**
\brief Call this function to reset the face tracker on camera switches
*/
FUNAMA_API void fuOnCameraChange();
/**
\brief Create an accessory item from a binary package, you can discard the data after the call.
	This function MUST be called in the same GLES context / thread as fuRenderItems.
\param data is the pointer to the data
\param sz is the data size, we use plain int to avoid cross-language compilation issues
\return an integer handle representing the item
*/
FUNAMA_API int fuCreateItemFromPackage(void* data,int sz);
/**
\brief Destroy an accessory item.
	This function MUST be called in the same GLES context / thread as the original fuCreateItemFromPackage.
\param item is the handle to be destroyed
*/
FUNAMA_API void fuDestroyItem(int item);
/**
\brief Destroy all accessory items ever created.
	This function MUST be called in the same GLES context / thread as the original fuCreateItemFromPackage.
*/
FUNAMA_API void fuDestroyAllItems();
/**
\brief Render a list of items on top of a GLES texture or a memory buffer.
	This function needs a GLES 2.0+ context.
\param texid specifies a GLES texture. Set it to 0u if you want to render to a memory buffer.
\param img specifies a memory buffer. Set it to NULL if you want to render to a texture.
	If img is non-NULL, it will be overwritten by the rendered image when fuRenderItems returns
\param w specifies the image width
\param h specifies the image height
\param frameid specifies the current frame id. 
	To get animated effects, please increase frame_id by 1 whenever you call this.
\param p_items points to the list of items
\param n_items is the number of items
\return a new GLES texture containing the rendered image in the texture mode
*/
FUNAMA_API int fuRenderItems(int texid,int* img,int w,int h,int frame_id, int* p_items,int n_items);

/*\brief An I/O format where `ptr` points to a BGRA buffer. It matches the camera format on iOS. */
#define FU_FORMAT_BGRA_BUFFER 0
/*\brief An I/O format where `ptr` points to a single GLuint that is a RGBA texture. It matches the hardware encoding format on Android. */
#define FU_FORMAT_RGBA_TEXTURE 1
/*\brief An I/O format where `ptr` points to an NV21 buffer. It matches the camera preview format on Android. */
#define FU_FORMAT_NV21_BUFFER 2
/*\brief An output-only format where `ptr` is NULL. The result is directly rendered onto the current GL framebuffer. */
#define FU_FORMAT_GL_CURRENT_FRAMEBUFFER 3
/*\brief An I/O format where `ptr` points to a RGBA buffer. */
#define FU_FORMAT_RGBA_BUFFER 4
/*\brief An input-only format where `ptr` points to a TCameraDesc struct. The input is directly taken from the specified camera. w and h are taken as the preferred image size*/
#define FU_FORMAT_CAMERA 5
typedef struct{
	int camera_id;//<which camera should we use, 0 for front, 1 for back
}TCameraDesc;
/**
\brief Generalized interface for rendering a list of items.
	This function needs a GLES 2.0+ context.
\param out_format is the output format
\param out_ptr receives the rendering result, which is either a GLuint texture handle or a memory buffer
\param in_format is the input format
\param in_ptr points to the input image, which is either a GLuint texture handle or a memory buffer
\param w specifies the image width
\param h specifies the image height
\param frameid specifies the current frame id. 
	To get animated effects, please increase frame_id by 1 whenever you call this.
\param p_items points to the list of items
\param n_items is the number of items
\return a GLuint texture handle containing the rendering result if out_format isn't FU_FORMAT_GL_CURRENT_FRAMEBUFFER
*/
FUNAMA_API int fuRenderItemsEx(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items);
/**
\brief Set an item parameter to a double value
\param item specifies the item
\param name is the parameter name
\param value is the parameter value to be set
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuItemSetParamd(int item,char* name,double value);
/**
\brief Set an item parameter to a double array
\param item specifies the item
\param name is the parameter name
\param value points to an array of doubles
\param n specifies the number of elements in value
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuItemSetParamdv(int item,char* name,double* value,int n);
/**
\brief Set an item parameter to a string value
\param item specifies the item
\param name is the parameter name
\param value is the parameter value to be set
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuItemSetParams(int item,char* name,char* value);
/**
\brief Turn off the camera
*/
FUNAMA_API void fuTurnOffCamera();
///**
//\brief Get the camera image size
//\param pret points to two integers, which receive the size
//*/
//FUNAMA_API void fuGetCameraImageSize(int* pret);
/**
\brief Get the face tracking status
\return zero for not tracking, non-zero for tracking
*/
FUNAMA_API int fuIsTracking();

#endif
