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
struct Device { PFN_vkGetDeviceProcAddr get; PFN_vkQueuePresentKHR present; };
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
 auto result=create(physical,info,alloc,device);if(result==VK_SUCCESS){std::lock_guard<std::mutex> lock(ownership);devices[Key(*device)]={get,(PFN_vkQueuePresentKHR)get(*device,"vkQueuePresentKHR")};}return result;
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
extern "C" __declspec(dllexport) VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL vkGetInstanceProcAddr(VkInstance instance,const char* name){
 if(!std::strcmp(name,"vkGetInstanceProcAddr"))return (PFN_vkVoidFunction)vkGetInstanceProcAddr;
 if(!std::strcmp(name,"vkGetDeviceProcAddr"))return (PFN_vkVoidFunction)vkGetDeviceProcAddr;
 if(!std::strcmp(name,"vkCreateInstance"))return (PFN_vkVoidFunction)CreateInstance;
 if(!std::strcmp(name,"vkDestroyInstance"))return (PFN_vkVoidFunction)DestroyInstance;
 if(!std::strcmp(name,"vkCreateDevice"))return (PFN_vkVoidFunction)CreateDevice;
 if(!std::strcmp(name,"vkDestroyDevice"))return (PFN_vkVoidFunction)DestroyDevice;
 if(!std::strcmp(name,"vkQueuePresentKHR"))return (PFN_vkVoidFunction)Present;
 PFN_vkGetInstanceProcAddr get;{std::lock_guard<std::mutex> lock(ownership);auto it=instances.find(Key(instance));if(it==instances.end())return nullptr;get=it->second.get;}return get(instance,name);
}
extern "C" __declspec(dllexport) VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL vkGetDeviceProcAddr(VkDevice device,const char* name){
 if(!std::strcmp(name,"vkGetDeviceProcAddr"))return (PFN_vkVoidFunction)vkGetDeviceProcAddr;
 if(!std::strcmp(name,"vkDestroyDevice"))return (PFN_vkVoidFunction)DestroyDevice;
 if(!std::strcmp(name,"vkQueuePresentKHR"))return (PFN_vkVoidFunction)Present;
 PFN_vkGetDeviceProcAddr get;{std::lock_guard<std::mutex> lock(ownership);auto it=devices.find(Key(device));if(it==devices.end())return nullptr;get=it->second.get;}return get(device,name);
}
extern "C" __declspec(dllexport) VKAPI_ATTR VkResult VKAPI_CALL vkNegotiateLoaderLayerInterfaceVersion(VkNegotiateLayerInterface* version){
 if(version->loaderLayerInterfaceVersion<2)return VK_ERROR_INITIALIZATION_FAILED;
 version->loaderLayerInterfaceVersion=2;version->pfnGetInstanceProcAddr=vkGetInstanceProcAddr;version->pfnGetDeviceProcAddr=vkGetDeviceProcAddr;version->pfnGetPhysicalDeviceProcAddr=Physical;return VK_SUCCESS;
}
