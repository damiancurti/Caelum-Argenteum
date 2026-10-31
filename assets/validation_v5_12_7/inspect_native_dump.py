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
images={}
def image_memory(address,size):
    # Minidumps may omit executable unwind sections. Read only immutable PE
    # sections of the matching installed image, never reconstructed heap data.
    module=next((m for m in dump.modules.modules if m.baseaddress<=address<m.baseaddress+m.size),None)
    if module is None:raise ValueError('Address is outside the recorded modules')
    if module.name not in images:
        data=Path(module.name).read_bytes();pe=struct.unpack_from('<I',data,60)[0]
        if data[pe:pe+4]!=b'PE\0\0':raise ValueError('Not a PE image')
        count=struct.unpack_from('<H',data,pe+6)[0];optional=struct.unpack_from('<H',data,pe+20)[0]
        timestamp=struct.unpack_from('<I',data,pe+8)[0]
        if timestamp!=module.timestamp:raise ValueError('Installed image timestamp differs from dump')
        sections=[]
        for i in range(count):
            entry=pe+24+optional+40*i
            virtual,raw_size,raw=struct.unpack_from('<III',data,entry+12)
            flags=struct.unpack_from('<I',data,entry+36)[0]
            if not flags&0x80000000:sections.append((virtual,raw_size,raw))
        images[module.name]=(data,sections)
    data,sections=images[module.name];rva=address-module.baseaddress
    for virtual,length,raw in sections:
        if virtual<=rva and rva+size<=virtual+length:return data[raw+rva-virtual:raw+rva-virtual+size]
    raise ValueError('Missing immutable image section')

@Read
def read_memory(process,address,buffer,size,read):
    try:
        try:data=reader.read(address,size)
        except Exception:data=image_memory(address,size)
        c.memmove(buffer,data,len(data));read[0]=len(data);return len(data)==size
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
stack_candidates=[]
try:
    stack=reader.read(rsp,4096)
    for offset in range(0,len(stack)-7,8):
        address=struct.unpack_from('<Q',stack,offset)[0]
        if not any(m.name.lower().endswith('gzdoom.exe') and m.baseaddress<=address<m.baseaddress+m.size for m in dump.modules.modules):continue
        resolved=symbol(address)
        if resolved['name'] and resolved['name']!="`string'" and int(resolved['displacement'],16)<4096:
            stack_candidates.append(dict(stack_offset=offset,**resolved))
except Exception:pass
def unwind_image_stack():
    # Explicit PE unwind metadata provides an independent, bounded check when
    # StackWalk64 cannot reconstruct a minidump. Unsupported operations stop it.
    with args.dump.open('rb') as stream:
        stream.seek(descriptor.Rva);raw=stream.read(descriptor.DataSize)
    registers=[struct.unpack_from('<Q',raw,120+i*8)[0] for i in range(16)]
    pc=struct.unpack_from('<Q',raw,248)[0];output=[];tables={}
    def memory(address,size):
        try:return reader.read(address,size)
        except Exception:return image_memory(address,size)
    def number(address):return struct.unpack('<Q',memory(address,8))[0]
    for _ in range(32):
        if not pc:break
        frame=symbol(pc);frame['stack']=hex(registers[4]);output.append(frame)
        module=next((m for m in dump.modules.modules if m.baseaddress<=pc<m.baseaddress+m.size),None)
        if module is None:break
        try:
            if module.name not in tables:
                data=Path(module.name).read_bytes();pe=struct.unpack_from('<I',data,60)[0]
                if data[pe:pe+4]!=b'PE\0\0' or struct.unpack_from('<I',data,pe+8)[0]!=module.timestamp:
                    raise ValueError('Installed image differs from the recorded PE timestamp')
                address,length=struct.unpack_from('<II',data,pe+24+112+24)
                table=memory(module.baseaddress+address,length)
                tables[module.name]=list(struct.iter_unpack('<III',table))
            rva=pc-module.baseaddress
            entry=next((e for e in tables[module.name] if e[0]<=rva<e[1]),None)
            while entry:
                begin,end,unwind=entry;address=module.baseaddress+unwind
                header=memory(address,4);version=header[0]&7;flags=header[0]>>3
                if version not in (1,2):raise ValueError('Unsupported unwind version')
                codes=memory(address+4,header[2]*2);i=0
                while i<header[2]:
                    offset,encoded=codes[i*2:i*2+2];operation=encoded&15;info=encoded>>4;i+=1
                    extra={1:1 if info==0 else 2,4:1,5:2,8:1,9:2}.get(operation,0)
                    operand=int.from_bytes(codes[i*2:(i+extra)*2],'little');i+=extra
                    if rva-begin<offset:continue
                    if operation==0:registers[info]=number(registers[4]);registers[4]+=8
                    elif operation==1:registers[4]+=operand*8 if info==0 else operand
                    elif operation==2:registers[4]+=info*8+8
                    elif operation==3:registers[4]=registers[header[3]&15]-(header[3]>>4)*16
                    elif operation==4:registers[info]=number(registers[4]+operand*8)
                    elif operation==5:registers[info]=number(registers[4]+operand)
                    elif operation in (8,9):pass
                    else:raise ValueError(f'Unsupported unwind operation {operation}')
                if flags&4:entry=struct.unpack('<III',memory(address+4+((header[2]+1)&~1)*2,12))
                else:entry=None
            pc=number(registers[4]);registers[4]+=8
        except Exception as exc:
            frame['unwind_stopped']=str(exc);break
    return output
result=dict(dump=str(args.dump),thread=exception.ThreadId,exception=str(exception.ExceptionRecord.ExceptionCode),
            fault=symbol(exception.ExceptionRecord.ExceptionAddress),frames=frames,
            metadata_unwind=unwind_image_stack(),
            raw_stack_candidates=stack_candidates,
            qualification='Partial unwind; raw stack candidates are untrusted values, NOT a call stack. Nearest driver exports are not private function symbols or proof of the originating failure.')
args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,indent=2))
