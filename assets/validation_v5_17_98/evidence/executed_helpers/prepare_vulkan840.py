"""Build a bounded private Vulkan CPU-call tracer from the accepted presentation layer."""
from pathlib import Path
import hashlib,json,subprocess,os
root=Path(__file__).resolve().parents[2]
work=root/'build/v517/work-713'
out=work/'build/issue840-vulkan05';out.mkdir(exist_ok=False)
original=work/'assets/validation_v5_12_7/presentation_layer.cpp'
source=original.read_text(encoding='utf-8')
calls=[
 ('VkResult','vkCreateShaderModule','VkDevice device, const VkShaderModuleCreateInfo* info, const VkAllocationCallbacks* alloc, VkShaderModule* shader','device,info,alloc,shader'),
 ('VkResult','vkCreateGraphicsPipelines','VkDevice device, VkPipelineCache cache, uint32_t count, const VkGraphicsPipelineCreateInfo* info, const VkAllocationCallbacks* alloc, VkPipeline* result','device,cache,count,info,alloc,result'),
 ('VkResult','vkCreateComputePipelines','VkDevice device, VkPipelineCache cache, uint32_t count, const VkComputePipelineCreateInfo* info, const VkAllocationCallbacks* alloc, VkPipeline* result','device,cache,count,info,alloc,result'),
 ('VkResult','vkAcquireNextImageKHR','VkDevice device, VkSwapchainKHR swapchain, uint64_t timeout, VkSemaphore semaphore, VkFence fence, uint32_t* index','device,swapchain,timeout,semaphore,fence,index'),
 ('VkResult','vkQueueSubmit','VkQueue queue, uint32_t count, const VkSubmitInfo* info, VkFence fence','queue,count,info,fence'),
 ('VkResult','vkWaitForFences','VkDevice device, uint32_t count, const VkFence* fences, VkBool32 all, uint64_t timeout','device,count,fences,all,timeout'),
 ('VkResult','vkDeviceWaitIdle','VkDevice device','device'),
 ('VkResult','vkQueueWaitIdle','VkQueue queue','queue'),
 ('VkResult','vkAllocateMemory','VkDevice device, const VkMemoryAllocateInfo* info, const VkAllocationCallbacks* alloc, VkDeviceMemory* memory','device,info,alloc,memory'),
 ('VkResult','vkMapMemory','VkDevice device, VkDeviceMemory memory, VkDeviceSize offset, VkDeviceSize size, VkMemoryMapFlags flags, void** data','device,memory,offset,size,flags,data'),
 ('VkResult','vkCreateImage','VkDevice device, const VkImageCreateInfo* info, const VkAllocationCallbacks* alloc, VkImage* image','device,info,alloc,image'),
 ('VkResult','vkCreateBuffer','VkDevice device, const VkBufferCreateInfo* info, const VkAllocationCallbacks* alloc, VkBuffer* buffer','device,info,alloc,buffer'),
 ('VkResult','vkResetCommandPool','VkDevice device, VkCommandPool pool, VkCommandPoolResetFlags flags','device,pool,flags'),
 ('VkResult','vkResetFences','VkDevice device, uint32_t count, const VkFence* fences','device,count,fences'),
 ('void','vkUpdateDescriptorSets','VkDevice device, uint32_t writeCount, const VkWriteDescriptorSet* writes, uint32_t copyCount, const VkCopyDescriptorSet* copies','device,writeCount,writes,copyCount,copies'),
]
fields=' '.join(f'PFN_{name} {name};' for _,name,_,_ in calls)
old='struct Device { PFN_vkGetDeviceProcAddr get; PFN_vkQueuePresentKHR present; };'
assert source.count(old)==1
source=source.replace(old,'struct Device { PFN_vkGetDeviceProcAddr get; PFN_vkQueuePresentKHR present; '+fields+' };')
old='devices[Key(*device)]={get,(PFN_vkQueuePresentKHR)get(*device,"vkQueuePresentKHR")};'
assert source.count(old)==1
source=source.replace(old,'devices[Key(*device)]={get,(PFN_vkQueuePresentKHR)get(*device,"vkQueuePresentKHR"),'+','.join(f'(PFN_{name})get(*device,"{name}")' for _,name,_,_ in calls)+'};')
insert=r'''
// CPU time spent inside selected Vulkan API calls, not GPU execution time.
namespace {
FILE* apiFile=nullptr; bool apiAttempted=false; unsigned long long apiRows=0;
void CloseAPI(){std::lock_guard<std::mutex> lock(output);if(apiFile){std::fprintf(apiFile,"# complete rows=%llu\n",apiRows);std::fclose(apiFile);apiFile=nullptr;}}
void RecordAPI(const char* name,double entry,double returned,int result,const char* detail=""){
 if(returned-entry<1.0 && std::strncmp(name,"vkCreate",8)!=0 && std::strcmp(name,"vkAllocateMemory")!=0)return;
 std::lock_guard<std::mutex> lock(output);
 if(!apiAttempted){apiAttempted=true;auto path=std::getenv("CA_PRESENT_TRACE");if(path){
  char target[4096];int n=std::snprintf(target,sizeof(target),"%s.api.csv",path);
  if(n>0 && n<int(sizeof(target)))apiFile=CreateTrace(target);
  if(apiFile){std::setvbuf(apiFile,nullptr,_IOFBF,65536);std::fprintf(apiFile,"PID,Thread,API,EntryQPCms,ReturnQPCms,Durationms,Result,Detail\n");std::atexit(CloseAPI);}
 }}
 if(!apiFile)return;
 if(apiRows>=120000){std::fprintf(apiFile,"# bounded_stop rows=%llu\n",apiRows);std::fclose(apiFile);apiFile=nullptr;return;}
 std::fprintf(apiFile,"%lu,%lu,%s,%.6f,%.6f,%.6f,%d,%s\n",GetCurrentProcessId(),GetCurrentThreadId(),name,entry,returned,returned-entry,result,detail);++apiRows;
}
}
'''
for result,name,signature,args in calls:
    handle=args.split(',')[0]
    invocation=f'auto callResult=next({args});' if result!='void' else f'next({args});'
    ret='return callResult;' if result!='void' else ''
    result_value='int(callResult)' if result!='void' else '0'
    detail=''
    if name=='vkCreateImage':detail='char detail[128];std::snprintf(detail,sizeof(detail),"width=%u height=%u format=%d mips=%u",info->extent.width,info->extent.height,int(info->format),info->mipLevels);'
    elif name=='vkCreateBuffer':detail='char detail[128];std::snprintf(detail,sizeof(detail),"bytes=%llu usage=%u",(unsigned long long)info->size,info->usage);'
    elif name=='vkCreateShaderModule':detail='char detail[128];std::snprintf(detail,sizeof(detail),"bytes=%llu",(unsigned long long)info->codeSize);'
    extra=',detail' if detail else ''
    insert+=f'''static VKAPI_ATTR {result} VKAPI_CALL Trace_{name}({signature}){{
 PFN_{name} next;{{std::lock_guard<std::mutex> lock(ownership);next=devices.at(Key({handle})).{name};}}
 double entry=Clock();{invocation}double returned=Clock();{detail}RecordAPI("{name}",entry,returned,{result_value}{extra});{ret}
}}
'''
anchor='extern "C" __declspec(dllexport) VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL vkGetInstanceProcAddr(VkInstance instance,const char* name){'
assert source.count(anchor)==1
source=source.replace(anchor,insert+'\n'+anchor)
anchor=' if(!std::strcmp(name,"vkQueuePresentKHR"))return (PFN_vkVoidFunction)Present;'
assert source.count(anchor)==2
source=source.replace(anchor,anchor+'\n'+'\n'.join(f' if(!std::strcmp(name,"{name}"))return (PFN_vkVoidFunction)Trace_{name};' for _,name,_,_ in calls))
cpp=out/'presentation_layer.cpp';cpp.write_text(source,encoding='utf-8')
compiler=root/'build/v515/tools/mingw64/bin/g++.exe'
headers=root/'build/v515/tools/gzdoom-g4.14.2/libraries/ZVulkan/include'
binary=out/'ca_presentation.dll'
command=[str(compiler),'-std=c++17','-O2','-shared','-static','-static-libgcc','-static-libstdc++','-Wl,--no-insert-timestamp','-I'+str(headers),str(cpp),'-o',str(binary)]
environment=os.environ.copy();environment['PATH']=str(compiler.parent)+os.pathsep+environment.get('PATH','')
subprocess.run(command,check=True,env=environment)
(out/'ca_presentation.json').write_bytes((root/'build/v515/tools/presentation/ca_presentation.json').read_bytes())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
record=dict(issue=840,command=command,source_sha256=sha(cpp),binary_sha256=sha(binary),original_source_sha256=sha(original),compiler_sha256=sha(compiler),minimum_recorded_cpu_ms=1.0,also_records_all_creation_and_allocation_calls=True,maximum_rows=120000,calls=[c[1] for c in calls],qualification='Private diagnostic child-process layer only. Selected API CPU durations, not GPU timing. All intercepted creation/allocation calls, plus other selected calls >=1ms. Original presentation timing is retained; no engine, installed layer or production setting is replaced.')
(out/'build.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
print(json.dumps(record,indent=2))
