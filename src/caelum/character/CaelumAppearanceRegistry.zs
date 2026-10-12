// Registro de prefijos dinámicos; esta clase nunca se instancia.
class CaelumAppearanceRegistry : Actor
{
    static clearscope double StandingHeight(int identity,bool gloved)
    {
        static const double heights[] = {170, 170, 170, 170, 172, 172, 172, 172, 171, 171, 171, 171, 175, 175, 175, 175, 175, 175, 175, 175, 173, 173, 173, 173, 173, 173, 173, 173};
        return heights[Clamp(identity,0,13)*2+int(gloved)];
    }
    States
    {
    Spawn:
    P000:
        P000 A 1;
    Q000:
        Q000 A 1;
    P001:
        P001 A 1;
    Q001:
        Q001 A 1;
    P002:
        P002 A 1;
    Q002:
        Q002 A 1;
    P003:
        P003 A 1;
    Q003:
        Q003 A 1;
    P004:
        P004 A 1;
    Q004:
        Q004 A 1;
    P005:
        P005 A 1;
    Q005:
        Q005 A 1;
    P006:
        P006 A 1;
    Q006:
        Q006 A 1;
    P007:
        P007 A 1;
    Q007:
        Q007 A 1;
    P008:
        P008 A 1;
    Q008:
        Q008 A 1;
    P009:
        P009 A 1;
    Q009:
        Q009 A 1;
    P010:
        P010 A 1;
    Q010:
        Q010 A 1;
    P011:
        P011 A 1;
    Q011:
        Q011 A 1;
    P012:
        P012 A 1;
    Q012:
        Q012 A 1;
    P013:
        P013 A 1;
    Q013:
        Q013 A 1;
    P014:
        P014 A 1;
    Q014:
        Q014 A 1;
    P015:
        P015 A 1;
    Q015:
        Q015 A 1;
    P016:
        P016 A 1;
    Q016:
        Q016 A 1;
    P017:
        P017 A 1;
    Q017:
        Q017 A 1;
    P018:
        P018 A 1;
    Q018:
        Q018 A 1;
    P019:
        P019 A 1;
    Q019:
        Q019 A 1;
    P020:
        P020 A 1;
    Q020:
        Q020 A 1;
    P021:
        P021 A 1;
    Q021:
        Q021 A 1;
    P022:
        P022 A 1;
    Q022:
        Q022 A 1;
    P023:
        P023 A 1;
    Q023:
        Q023 A 1;
    P024:
        P024 A 1;
    Q024:
        Q024 A 1;
    P025:
        P025 A 1;
    Q025:
        Q025 A 1;
    P026:
        P026 A 1;
    Q026:
        Q026 A 1;
    P027:
        P027 A 1;
    Q027:
        Q027 A 1;
    P028:
        P028 A 1;
    Q028:
        Q028 A 1;
    P029:
        P029 A 1;
    Q029:
        Q029 A 1;
    P030:
        P030 A 1;
    Q030:
        Q030 A 1;
    P031:
        P031 A 1;
    Q031:
        Q031 A 1;
    P032:
        P032 A 1;
    Q032:
        Q032 A 1;
    P033:
        P033 A 1;
    Q033:
        Q033 A 1;
    P034:
        P034 A 1;
    Q034:
        Q034 A 1;
    P035:
        P035 A 1;
    Q035:
        Q035 A 1;
    P036:
        P036 A 1;
    Q036:
        Q036 A 1;
    P037:
        P037 A 1;
    Q037:
        Q037 A 1;
    P038:
        P038 A 1;
    Q038:
        Q038 A 1;
    P039:
        P039 A 1;
    Q039:
        Q039 A 1;
    P040:
        P040 A 1;
    Q040:
        Q040 A 1;
    P041:
        P041 A 1;
    Q041:
        Q041 A 1;
    P042:
        P042 A 1;
    Q042:
        Q042 A 1;
    P043:
        P043 A 1;
    Q043:
        Q043 A 1;
    P044:
        P044 A 1;
    Q044:
        Q044 A 1;
    P045:
        P045 A 1;
    Q045:
        Q045 A 1;
    P046:
        P046 A 1;
    Q046:
        Q046 A 1;
    P047:
        P047 A 1;
    Q047:
        Q047 A 1;
    P048:
        P048 A 1;
    Q048:
        Q048 A 1;
    P049:
        P049 A 1;
    Q049:
        Q049 A 1;
    P050:
        P050 A 1;
    Q050:
        Q050 A 1;
    P051:
        P051 A 1;
    Q051:
        Q051 A 1;
    P052:
        P052 A 1;
    Q052:
        Q052 A 1;
    P053:
        P053 A 1;
    Q053:
        Q053 A 1;
    P054:
        P054 A 1;
    Q054:
        Q054 A 1;
    P055:
        P055 A 1;
    Q055:
        Q055 A 1;
    P056:
        P056 A 1;
    Q056:
        Q056 A 1;
    P057:
        P057 A 1;
    Q057:
        Q057 A 1;
    P058:
        P058 A 1;
    Q058:
        Q058 A 1;
    P059:
        P059 A 1;
    Q059:
        Q059 A 1;
    P060:
        P060 A 1;
    Q060:
        Q060 A 1;
    P061:
        P061 A 1;
    Q061:
        Q061 A 1;
    P062:
        P062 A 1;
    Q062:
        Q062 A 1;
    P063:
        P063 A 1;
    Q063:
        Q063 A 1;
    P064:
        P064 A 1;
    Q064:
        Q064 A 1;
    P065:
        P065 A 1;
    Q065:
        Q065 A 1;
    P066:
        P066 A 1;
    Q066:
        Q066 A 1;
    P067:
        P067 A 1;
    Q067:
        Q067 A 1;
    P068:
        P068 A 1;
    Q068:
        Q068 A 1;
    P069:
        P069 A 1;
    Q069:
        Q069 A 1;
    P070:
        P070 A 1;
    Q070:
        Q070 A 1;
    P071:
        P071 A 1;
    Q071:
        Q071 A 1;
    P072:
        P072 A 1;
    Q072:
        Q072 A 1;
    P073:
        P073 A 1;
    Q073:
        Q073 A 1;
    P074:
        P074 A 1;
    Q074:
        Q074 A 1;
    P075:
        P075 A 1;
    Q075:
        Q075 A 1;
    P076:
        P076 A 1;
    Q076:
        Q076 A 1;
    P077:
        P077 A 1;
    Q077:
        Q077 A 1;
    P078:
        P078 A 1;
    Q078:
        Q078 A 1;
    P079:
        P079 A 1;
    Q079:
        Q079 A 1;
    P080:
        P080 A 1;
    Q080:
        Q080 A 1;
    P081:
        P081 A 1;
    Q081:
        Q081 A 1;
    P082:
        P082 A 1;
    Q082:
        Q082 A 1;
    P083:
        P083 A 1;
    Q083:
        Q083 A 1;
    SourceDOID:
        DOID A 1;
    SourceDOWK:
        DOWK A 1;
    SourceDORN:
        DORN A 1;
    SourceRSDO:
        RSDO A 1;
    SourceDOMI:
        DOMI A 1;
    SourceCAGN:
        CAGN A 1;
    SourceCAGC:
        CAGC A 1;
    SourceSHGW:
        SHGW A 1;
        Stop;
    }
}
