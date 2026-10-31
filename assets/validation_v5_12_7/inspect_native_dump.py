"""Read a retained GZDoom minidump using Windows DbgHelp and matching public PDBs.

Requires minidump==0.0.24 in --dependencies; no process is attached or modified.
The symbols are from the official GZDoom g4.14.2 release, not an engine rebuild.
"""
import argparse,ctypes as c,json,struct,sys
from pathlib import Path

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('dump',type=Path);parser.add_argument('--dependencies',type=Path,required=True)
parser.add_argument('--symbols',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();sys.path.insert(0,str(args.dependencies.resolve()))
from minidump.minidumpfile import MinidumpFile

class Address(c.Structure):
    _fields_=[('Offset',c.c_uint64),('Segment',c.c_uint16),('Mode',c.c_uint32)]
class Frame(c.Structure):
    _fields_=[('PC',Address),('Return',Address),('Frame',Address),('Stack',Address),('Store',Address),
              ('Function',c.c_void_p),('Params',c.c_uint64*4),('Far',c.c_uint32),('Virtual',c.c_uint32),
              ('Reserved',c.c_uint64*3),('KdHelp',c.c_byte*112)]

dump=MinidumpFile.parse(str(args.dump));reader=dump.get_reader();exception=dump.exception.exception_records[0]
kernel=c.WinDLL('kernel32',use_last_error=True);kernel.GetCurrentProcess.restype=c.c_void_p
handle=kernel.GetCurrentProcess();dbg=c.WinDLL('dbghelp',use_last_error=True)
dbg.SymInitializeW.argtypes=[c.c_void_p,c.c_wchar_p,c.c_int];dbg.SymInitializeW.restype=c.c_int
dbg.SymLoadModuleExW.argtypes=[c.c_void_p,c.c_void_p,c.c_wchar_p,c.c_wchar_p,c.c_uint64,c.c_uint32,c.c_void_p,c.c_uint32]
dbg.SymLoadModuleExW.restype=c.c_uint64
dbg.SymFromAddr.argtypes=[c.c_void_p,c.c_uint64,c.POINTER(c.c_uint64),c.c_void_p];dbg.SymFromAddr.restype=c.c_int
if not dbg.SymInitializeW(handle,str(args.symbols.resolve()),False):raise OSError(c.get_last_error())
for module in dump.modules.modules:
    dbg.SymLoadModuleExW(handle,None,module.name,None,module.baseaddress,module.size,None,0)

def symbol(address):
    buffer=c.create_string_buffer(88+2048);struct.pack_into('<I',buffer,0,88);struct.pack_into('<I',buffer,80,2048)
    displacement=c.c_uint64();okay=dbg.SymFromAddr(handle,address,c.byref(displacement),buffer)
    module=next((m.name for m in dump.modules.modules if m.baseaddress<=address<m.baseaddress+m.size),None)
    return dict(address=hex(address),module=module,name=buffer.raw[84:].split(b'\0')[0].decode(errors='replace') if okay else None,
                displacement=hex(displacement.value) if okay else None)

Read=c.WINFUNCTYPE(c.c_int,c.c_void_p,c.c_uint64,c.c_void_p,c.c_uint32,c.POINTER(c.c_uint32))
@Read
def read_memory(process,address,buffer,size,read):
    try:
        data=reader.read(address,size);c.memmove(buffer,data,len(data));read[0]=len(data);return len(data)==size
    except Exception:read[0]=0;return False

descriptor=exception.ThreadContext
with args.dump.open('rb') as stream:
    stream.seek(descriptor.Rva);context=c.create_string_buffer(stream.read(descriptor.DataSize))
rsp=struct.unpack_from('<Q',context,152)[0];rbp=struct.unpack_from('<Q',context,160)[0];rip=struct.unpack_from('<Q',context,248)[0]
frame=Frame();frame.PC.Offset=rip;frame.Frame.Offset=rbp;frame.Stack.Offset=rsp
frame.PC.Mode=frame.Frame.Mode=frame.Stack.Mode=3
dbg.StackWalk64.argtypes=[c.c_uint32,c.c_void_p,c.c_void_p,c.POINTER(Frame),c.c_void_p,c.c_void_p,c.c_void_p,c.c_void_p,c.c_void_p]
dbg.StackWalk64.restype=c.c_int
frames=[];seen=set()
for _ in range(40):
    if not dbg.StackWalk64(0x8664,handle,None,c.byref(frame),context,read_memory,dbg.SymFunctionTableAccess64,dbg.SymGetModuleBase64,None):break
    key=(frame.PC.Offset,frame.Stack.Offset)
    if key in seen or not frame.PC.Offset:break
    seen.add(key);resolved=symbol(frame.PC.Offset)
    if resolved['module'] is None or resolved['name']=="`string'":break
    frames.append(resolved)
result=dict(dump=str(args.dump),thread=exception.ThreadId,exception=str(exception.ExceptionRecord.ExceptionCode),
            fault=symbol(exception.ExceptionRecord.ExceptionAddress),frames=frames,
            qualification='Partial unwind; nearest driver exports are not private function symbols or proof of the originating failure.')
args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,indent=2))
