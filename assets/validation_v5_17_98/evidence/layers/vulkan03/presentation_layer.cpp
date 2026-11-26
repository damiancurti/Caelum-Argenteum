// Diagnostic explicit Vulkan layer. Enabled only in selected child processes.
// Measures actual vkQueuePresentKHR requests/returns, NOT monitor scanout.
#define VK_NO_PROTOTYPES
#include <vulkan/vulkan.h>
#include <vulkan/vk_layer.h>
#include <windows.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <mutex>
#include <io.h>
#include <fcntl.h>
#include <sys/stat.h>

namespace {
void* Key(void* handle) { return handle ? *static_cast<void**>(handle) : nullptr; }
struct Instance { VkInstance handle; PFN_vkGetInstanceProcAddr get; PFN_GetPhysicalDeviceProcAddr physical; };
struct Device { PFN_vkGetDeviceProcAddr get; PFN_vkQueuePresentKHR present; PFN_vkCreateGraphicsPipelines vkCreateGraphicsPipelines; PFN_vkCreateComputePipelines vkCreateComputePipelines; PFN_vkAcquireNextImageKHR vkAcquireNextImageKHR; PFN_vkQueueSubmit vkQueueSubmit; PFN_vkWaitForFences vkWaitForFences; PFN_vkDeviceWaitIdle vkDeviceWaitIdle; PFN_vkQueueWaitIdle vkQueueWaitIdle; PFN_vkAllocateMemory vkAllocateMemory; PFN_vkMapMemory vkMapMemory; PFN_vkCreateImage vkCreateImage; PFN_vkCreateBuffer vkCreateBuffer; PFN_vkResetCommandPool vkResetCommandPool; PFN_vkResetFences vkResetFences; PFN_vkUpdateDescriptorSets vkUpdateDescriptorSets; };
std::map<void*,Instance> instances;
std::map<void*,Device> devices;
std::mutex ownership, output;
FILE* file=nullptr; bool attempted=false,finished=false; unsigned long long rows=0;
FILE* CreateTrace(const char* path) {
 // MSVCRT does not implement the C11 fopen "x" mode; preserve exclusive creation.
 int fd=_open(path,_O_CREAT|_O_EXCL|_O_WRONLY|_O_BINARY,_S_IREAD|_S_IWRITE);
 if(fd<0)return nullptr;
 FILE* stream=_fdopen(fd,"w");if(!stream)_close(fd);return stream;
}
double started=0;
double Clock() { LARGE_INTEGER t,f; QueryPerformanceCounter(&t);QueryPerformanceFrequency(&f);return double(t.QuadPart)*1000.0/double(f.QuadPart); }
void Close() { std::lock_guard<std::mutex> lock(output);if(file){std::fprintf(file,"# complete rows=%llu\n",rows);std::fclose(file);file=nullptr;}finished=true; }
void Record(const VkPresentInfoKHR* info,double entry,double returned,VkResult result) {
 std::lock_guard<std::mutex> lock(output);
 if(!attempted){attempted=true;started=entry;auto path=std::getenv("CA_PRESENT_TRACE");if(path){file=CreateTrace(path);if(file){std::setvbuf(file,nullptr,_IOFBF,65536);std::fprintf(file,"PID,Swapchain,EntryQPCms,ReturnQPCms,Result\n");std::atexit(Close);}}}
 if(!file || finished)return;
 if(entry-started>900000.0 || rows>=120000){std::fprintf(file,"# bounded_stop rows=%llu\n",rows);std::fclose(file);file=nullptr;finished=true;return;}
 for(uint32_t i=0;i<info->swapchainCount;i++){
  auto item=info->pResults ? info->pResults[i] : result;
  std::fprintf(file,"%lu,%p,%.6f,%.6f,%d\n",GetCurrentProcessId(),(void*)info->pSwapchains[i],entry,returned,int(item));++rows;
 }
}
template<class T> T* Chain(const void* p,VkStructureType type){
 for(auto n=(T*)p;n;n=(T*)n->pNext)if(n->sType==type && n->function==VK_LAYER_LINK_INFO)return n;
 return nullptr;
}
}

extern "C" __declspec(dllexport) VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL vkGetInstanceProcAddr(VkInstance,const char*);
extern "C" __declspec(dllexport) VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL vkGetDeviceProcAddr(VkDevice,const char*);

static VKAPI_ATTR VkResult VKAPI_CALL CreateInstance(const VkInstanceCreateInfo* info,const VkAllocationCallbacks* alloc,VkInstance* instance){
 auto chain=Chain<VkLayerInstanceCreateInfo>(info->pNext,VK_STRUCTURE_TYPE_LOADER_INSTANCE_CREATE_INFO);if(!chain)return VK_ERROR_INITIALIZATION_FAILED;
 auto link=chain->u.pLayerInfo;auto get=link->pfnNextGetInstanceProcAddr;auto physical=link->pfnNextGetPhysicalDeviceProcAddr;
 auto create=(PFN_vkCreateInstance)get(VK_NULL_HANDLE,"vkCreateInstance");chain->u.pLayerInfo=link->pNext;
 auto result=create(info,alloc,instance);if(result==VK_SUCCESS){std::lock_guard<std::mutex> lock(ownership);instances[Key(*instance)]={*instance,get,physical};}return result;
}
static VKAPI_ATTR void VKAPI_CALL DestroyInstance(VkInstance instance,const VkAllocationCallbacks* alloc){
 Instance data;{std::lock_guard<std::mutex> lock(ownership);data=instances.at(Key(instance));instances.erase(Key(instance));}
 ((PFN_vkDestroyInstance)data.get(instance,"vkDestroyInstance"))(instance,alloc);
}
static VKAPI_ATTR VkResult VKAPI_CALL CreateDevice(VkPhysicalDevice physical,const VkDeviceCreateInfo* info,const VkAllocationCallbacks* alloc,VkDevice* device){
 auto chain=Chain<VkLayerDeviceCreateInfo>(info->pNext,VK_STRUCTURE_TYPE_LOADER_DEVICE_CREATE_INFO);if(!chain)return VK_ERROR_INITIALIZATION_FAILED;
 auto link=chain->u.pLayerInfo;auto get=link->pfnNextGetDeviceProcAddr;Instance instance;
 {std::lock_guard<std::mutex> lock(ownership);instance=instances.at(Key(physical));}
 auto create=(PFN_vkCreateDevice)link->pfnNextGetInstanceProcAddr(instance.handle,"vkCreateDevice");chain->u.pLayerInfo=link->pNext;
 auto result=create(physical,info,alloc,device);if(result==VK_SUCCESS){std::lock_guard<std::mutex> lock(ownership);devices[Key(*device)]={get,(PFN_vkQueuePresentKHR)get(*device,"vkQueuePresentKHR"),(PFN_vkCreateGraphicsPipelines)get(*device,"vkCreateGraphicsPipelines"),(PFN_vkCreateComputePipelines)get(*device,"vkCreateComputePipelines"),(PFN_vkAcquireNextImageKHR)get(*device,"vkAcquireNextImageKHR"),(PFN_vkQueueSubmit)get(*device,"vkQueueSubmit"),(PFN_vkWaitForFences)get(*device,"vkWaitForFences"),(PFN_vkDeviceWaitIdle)get(*device,"vkDeviceWaitIdle"),(PFN_vkQueueWaitIdle)get(*device,"vkQueueWaitIdle"),(PFN_vkAllocateMemory)get(*device,"vkAllocateMemory"),(PFN_vkMapMemory)get(*device,"vkMapMemory"),(PFN_vkCreateImage)get(*device,"vkCreateImage"),(PFN_vkCreateBuffer)get(*device,"vkCreateBuffer"),(PFN_vkResetCommandPool)get(*device,"vkResetCommandPool"),(PFN_vkResetFences)get(*device,"vkResetFences"),(PFN_vkUpdateDescriptorSets)get(*device,"vkUpdateDescriptorSets")};}return result;
}
static VKAPI_ATTR void VKAPI_CALL DestroyDevice(VkDevice device,const VkAllocationCallbacks* alloc){
 Device data;{std::lock_guard<std::mutex> lock(ownership);data=devices.at(Key(device));devices.erase(Key(device));}
 ((PFN_vkDestroyDevice)data.get(device,"vkDestroyDevice"))(device,alloc);
}
static VKAPI_ATTR VkResult VKAPI_CALL Present(VkQueue queue,const VkPresentInfoKHR* info){
 PFN_vkQueuePresentKHR next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(queue)).present;}
 double entry=Clock();auto result=next(queue,info);double returned=Clock();Record(info,entry,returned,result);return result;
}
static VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL Physical(VkInstance instance,const char* name){
 Instance data;{std::lock_guard<std::mutex> lock(ownership);auto it=instances.find(Key(instance));if(it==instances.end())return nullptr;data=it->second;}
 return data.physical ? data.physical(instance,name) : data.get(instance,name);
}

// CPU time spent inside selected Vulkan API calls, not GPU execution time.
namespace {
FILE* apiFile=nullptr; bool apiAttempted=false; unsigned long long apiRows=0;
void CloseAPI(){std::lock_guard<std::mutex> lock(output);if(apiFile){std::fprintf(apiFile,"# complete rows=%llu\n",apiRows);std::fclose(apiFile);apiFile=nullptr;}}
void RecordAPI(const char* name,double entry,double returned,int result){
 if(returned-entry<1.0)return;
 std::lock_guard<std::mutex> lock(output);
 if(!apiAttempted){apiAttempted=true;auto path=std::getenv("CA_PRESENT_TRACE");if(path){
  char target[4096];int n=std::snprintf(target,sizeof(target),"%s.api.csv",path);
  if(n>0 && n<int(sizeof(target)))apiFile=CreateTrace(target);
  if(apiFile){std::setvbuf(apiFile,nullptr,_IOFBF,65536);std::fprintf(apiFile,"PID,Thread,API,EntryQPCms,ReturnQPCms,Durationms,Result\n");std::atexit(CloseAPI);}
 }}
 if(!apiFile)return;
 if(apiRows>=120000){std::fprintf(apiFile,"# bounded_stop rows=%llu\n",apiRows);std::fclose(apiFile);apiFile=nullptr;return;}
 std::fprintf(apiFile,"%lu,%lu,%s,%.6f,%.6f,%.6f,%d\n",GetCurrentProcessId(),GetCurrentThreadId(),name,entry,returned,returned-entry,result);++apiRows;
}
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkCreateGraphicsPipelines(VkDevice device, VkPipelineCache cache, uint32_t count, const VkGraphicsPipelineCreateInfo* info, const VkAllocationCallbacks* alloc, VkPipeline* result){
 PFN_vkCreateGraphicsPipelines next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkCreateGraphicsPipelines;}
 double entry=Clock();auto callResult=next(device,cache,count,info,alloc,result);double returned=Clock();RecordAPI("vkCreateGraphicsPipelines",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkCreateComputePipelines(VkDevice device, VkPipelineCache cache, uint32_t count, const VkComputePipelineCreateInfo* info, const VkAllocationCallbacks* alloc, VkPipeline* result){
 PFN_vkCreateComputePipelines next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkCreateComputePipelines;}
 double entry=Clock();auto callResult=next(device,cache,count,info,alloc,result);double returned=Clock();RecordAPI("vkCreateComputePipelines",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkAcquireNextImageKHR(VkDevice device, VkSwapchainKHR swapchain, uint64_t timeout, VkSemaphore semaphore, VkFence fence, uint32_t* index){
 PFN_vkAcquireNextImageKHR next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkAcquireNextImageKHR;}
 double entry=Clock();auto callResult=next(device,swapchain,timeout,semaphore,fence,index);double returned=Clock();RecordAPI("vkAcquireNextImageKHR",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkQueueSubmit(VkQueue queue, uint32_t count, const VkSubmitInfo* info, VkFence fence){
 PFN_vkQueueSubmit next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(queue)).vkQueueSubmit;}
 double entry=Clock();auto callResult=next(queue,count,info,fence);double returned=Clock();RecordAPI("vkQueueSubmit",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkWaitForFences(VkDevice device, uint32_t count, const VkFence* fences, VkBool32 all, uint64_t timeout){
 PFN_vkWaitForFences next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkWaitForFences;}
 double entry=Clock();auto callResult=next(device,count,fences,all,timeout);double returned=Clock();RecordAPI("vkWaitForFences",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkDeviceWaitIdle(VkDevice device){
 PFN_vkDeviceWaitIdle next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkDeviceWaitIdle;}
 double entry=Clock();auto callResult=next(device);double returned=Clock();RecordAPI("vkDeviceWaitIdle",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkQueueWaitIdle(VkQueue queue){
 PFN_vkQueueWaitIdle next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(queue)).vkQueueWaitIdle;}
 double entry=Clock();auto callResult=next(queue);double returned=Clock();RecordAPI("vkQueueWaitIdle",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkAllocateMemory(VkDevice device, const VkMemoryAllocateInfo* info, const VkAllocationCallbacks* alloc, VkDeviceMemory* memory){
 PFN_vkAllocateMemory next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkAllocateMemory;}
 double entry=Clock();auto callResult=next(device,info,alloc,memory);double returned=Clock();RecordAPI("vkAllocateMemory",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkMapMemory(VkDevice device, VkDeviceMemory memory, VkDeviceSize offset, VkDeviceSize size, VkMemoryMapFlags flags, void** data){
 PFN_vkMapMemory next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkMapMemory;}
 double entry=Clock();auto callResult=next(device,memory,offset,size,flags,data);double returned=Clock();RecordAPI("vkMapMemory",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkCreateImage(VkDevice device, const VkImageCreateInfo* info, const VkAllocationCallbacks* alloc, VkImage* image){
 PFN_vkCreateImage next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkCreateImage;}
 double entry=Clock();auto callResult=next(device,info,alloc,image);double returned=Clock();RecordAPI("vkCreateImage",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkCreateBuffer(VkDevice device, const VkBufferCreateInfo* info, const VkAllocationCallbacks* alloc, VkBuffer* buffer){
 PFN_vkCreateBuffer next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkCreateBuffer;}
 double entry=Clock();auto callResult=next(device,info,alloc,buffer);double returned=Clock();RecordAPI("vkCreateBuffer",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkResetCommandPool(VkDevice device, VkCommandPool pool, VkCommandPoolResetFlags flags){
 PFN_vkResetCommandPool next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkResetCommandPool;}
 double entry=Clock();auto callResult=next(device,pool,flags);double returned=Clock();RecordAPI("vkResetCommandPool",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR VkResult VKAPI_CALL Trace_vkResetFences(VkDevice device, uint32_t count, const VkFence* fences){
 PFN_vkResetFences next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkResetFences;}
 double entry=Clock();auto callResult=next(device,count,fences);double returned=Clock();RecordAPI("vkResetFences",entry,returned,int(callResult));return callResult;
}
static VKAPI_ATTR void VKAPI_CALL Trace_vkUpdateDescriptorSets(VkDevice device, uint32_t writeCount, const VkWriteDescriptorSet* writes, uint32_t copyCount, const VkCopyDescriptorSet* copies){
 PFN_vkUpdateDescriptorSets next;{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key(device)).vkUpdateDescriptorSets;}
 double entry=Clock();next(device,writeCount,writes,copyCount,copies);double returned=Clock();RecordAPI("vkUpdateDescriptorSets",entry,returned,0);
}

extern "C" __declspec(dllexport) VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL vkGetInstanceProcAddr(VkInstance instance,const char* name){
 if(!std::strcmp(name,"vkGetInstanceProcAddr"))return (PFN_vkVoidFunction)vkGetInstanceProcAddr;
 if(!std::strcmp(name,"vkGetDeviceProcAddr"))return (PFN_vkVoidFunction)vkGetDeviceProcAddr;
 if(!std::strcmp(name,"vkCreateInstance"))return (PFN_vkVoidFunction)CreateInstance;
 if(!std::strcmp(name,"vkDestroyInstance"))return (PFN_vkVoidFunction)DestroyInstance;
 if(!std::strcmp(name,"vkCreateDevice"))return (PFN_vkVoidFunction)CreateDevice;
 if(!std::strcmp(name,"vkDestroyDevice"))return (PFN_vkVoidFunction)DestroyDevice;
 if(!std::strcmp(name,"vkQueuePresentKHR"))return (PFN_vkVoidFunction)Present;
 if(!std::strcmp(name,"vkCreateGraphicsPipelines"))return (PFN_vkVoidFunction)Trace_vkCreateGraphicsPipelines;
 if(!std::strcmp(name,"vkCreateComputePipelines"))return (PFN_vkVoidFunction)Trace_vkCreateComputePipelines;
 if(!std::strcmp(name,"vkAcquireNextImageKHR"))return (PFN_vkVoidFunction)Trace_vkAcquireNextImageKHR;
 if(!std::strcmp(name,"vkQueueSubmit"))return (PFN_vkVoidFunction)Trace_vkQueueSubmit;
 if(!std::strcmp(name,"vkWaitForFences"))return (PFN_vkVoidFunction)Trace_vkWaitForFences;
 if(!std::strcmp(name,"vkDeviceWaitIdle"))return (PFN_vkVoidFunction)Trace_vkDeviceWaitIdle;
 if(!std::strcmp(name,"vkQueueWaitIdle"))return (PFN_vkVoidFunction)Trace_vkQueueWaitIdle;
 if(!std::strcmp(name,"vkAllocateMemory"))return (PFN_vkVoidFunction)Trace_vkAllocateMemory;
 if(!std::strcmp(name,"vkMapMemory"))return (PFN_vkVoidFunction)Trace_vkMapMemory;
 if(!std::strcmp(name,"vkCreateImage"))return (PFN_vkVoidFunction)Trace_vkCreateImage;
 if(!std::strcmp(name,"vkCreateBuffer"))return (PFN_vkVoidFunction)Trace_vkCreateBuffer;
 if(!std::strcmp(name,"vkResetCommandPool"))return (PFN_vkVoidFunction)Trace_vkResetCommandPool;
 if(!std::strcmp(name,"vkResetFences"))return (PFN_vkVoidFunction)Trace_vkResetFences;
 if(!std::strcmp(name,"vkUpdateDescriptorSets"))return (PFN_vkVoidFunction)Trace_vkUpdateDescriptorSets;
 PFN_vkGetInstanceProcAddr get;{std::lock_guard<std::mutex> lock(ownership);auto it=instances.find(Key(instance));if(it==instances.end())return nullptr;get=it->second.get;}return get(instance,name);
}
extern "C" __declspec(dllexport) VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL vkGetDeviceProcAddr(VkDevice device,const char* name){
 if(!std::strcmp(name,"vkGetDeviceProcAddr"))return (PFN_vkVoidFunction)vkGetDeviceProcAddr;
 if(!std::strcmp(name,"vkDestroyDevice"))return (PFN_vkVoidFunction)DestroyDevice;
 if(!std::strcmp(name,"vkQueuePresentKHR"))return (PFN_vkVoidFunction)Present;
 if(!std::strcmp(name,"vkCreateGraphicsPipelines"))return (PFN_vkVoidFunction)Trace_vkCreateGraphicsPipelines;
 if(!std::strcmp(name,"vkCreateComputePipelines"))return (PFN_vkVoidFunction)Trace_vkCreateComputePipelines;
 if(!std::strcmp(name,"vkAcquireNextImageKHR"))return (PFN_vkVoidFunction)Trace_vkAcquireNextImageKHR;
 if(!std::strcmp(name,"vkQueueSubmit"))return (PFN_vkVoidFunction)Trace_vkQueueSubmit;
 if(!std::strcmp(name,"vkWaitForFences"))return (PFN_vkVoidFunction)Trace_vkWaitForFences;
 if(!std::strcmp(name,"vkDeviceWaitIdle"))return (PFN_vkVoidFunction)Trace_vkDeviceWaitIdle;
 if(!std::strcmp(name,"vkQueueWaitIdle"))return (PFN_vkVoidFunction)Trace_vkQueueWaitIdle;
 if(!std::strcmp(name,"vkAllocateMemory"))return (PFN_vkVoidFunction)Trace_vkAllocateMemory;
 if(!std::strcmp(name,"vkMapMemory"))return (PFN_vkVoidFunction)Trace_vkMapMemory;
 if(!std::strcmp(name,"vkCreateImage"))return (PFN_vkVoidFunction)Trace_vkCreateImage;
 if(!std::strcmp(name,"vkCreateBuffer"))return (PFN_vkVoidFunction)Trace_vkCreateBuffer;
 if(!std::strcmp(name,"vkResetCommandPool"))return (PFN_vkVoidFunction)Trace_vkResetCommandPool;
 if(!std::strcmp(name,"vkResetFences"))return (PFN_vkVoidFunction)Trace_vkResetFences;
 if(!std::strcmp(name,"vkUpdateDescriptorSets"))return (PFN_vkVoidFunction)Trace_vkUpdateDescriptorSets;
 PFN_vkGetDeviceProcAddr get;{std::lock_guard<std::mutex> lock(ownership);auto it=devices.find(Key(device));if(it==devices.end())return nullptr;get=it->second.get;}return get(device,name);
}
extern "C" __declspec(dllexport) VKAPI_ATTR VkResult VKAPI_CALL vkNegotiateLoaderLayerInterfaceVersion(VkNegotiateLayerInterface* version){
 if(version->loaderLayerInterfaceVersion<2)return VK_ERROR_INITIALIZATION_FAILED;
 version->loaderLayerInterfaceVersion=2;version->pfnGetInstanceProcAddr=vkGetInstanceProcAddr;version->pfnGetDeviceProcAddr=vkGetDeviceProcAddr;version->pfnGetPhysicalDeviceProcAddr=Physical;return VK_SUCCESS;
}
