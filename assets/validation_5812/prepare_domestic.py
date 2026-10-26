"""Prepare deterministic domestic hygiene checks using real campaign maps."""
from pathlib import Path
import zipfile
here=Path(__file__).resolve().parent
out=here.parents[1]/'build/issue502-hygiene'
members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n',
         'checks.zs':(here/'domestic_checks.zs').read_bytes(),
         'MAPINFO':b'GameInfo { AddEventHandlers="CA502DomesticChecks" }\n',
         'MENUDEF':b'ListMenu CaelumLiveMenu { Class CA502DomesticMenu }\n'}
with zipfile.ZipFile(out/'domestic-checks.pk3','w',zipfile.ZIP_STORED) as z:
    for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
bridge=out/'domestic-bridge';bridge.mkdir(exist_ok=True)
(bridge/'domestic-legacy-checks.pk3').write_bytes((out/'domestic-checks.pk3').read_bytes())
legacy=(here/'domestic_checks.zs').read_bytes().split(b'class CA502DomesticChecks')[0]+b'''class CA502DomesticChecks : EventHandler {
override void NetworkProcess(ConsoleEvent e){
let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
let v=CaelumCityMerchant.Find(0);if(v==null)return;v.EnsureStock(u);
CaelumMaterialPickup soap;for(Inventory item=v.Inv;item!=null;item=item.Inv){let m=CaelumMaterialPickup(item);if(m!=null && m.GetSpecialType()==CaelumHygieneData.SOAP)soap=m;}
if(e.Name=='ca502d_old_save'){soap.Amount=1420;v.WalletCopper=321;let p=CA502DomesticProof(u.GiveInventoryType('CA502DomesticProof'));p.Soap=soap.Amount;p.Wallet=v.WalletCopper;Console.Printf("CA502D PASS original native shop saves partial stock and wallet");}
else if(e.Name=='ca502d_old_verify'){let p=CA502DomesticProof(u.FindInventory('CA502DomesticProof'));Console.Printf("CA502D %s original runtime rollback retains shop state",p!=null && soap.Amount==p.Soap && v.WalletCopper==p.Wallet?"PASS":"FAIL");}
else return;Console.Printf("CA502D LEGACY");}}
'''
members['checks.zs']=legacy
members['MENUDEF']=b''
with zipfile.ZipFile(out/'domestic-legacy-checks.pk3','w',zipfile.ZIP_STORED) as z:
    for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
scripts={
 'domestic-economy':'wait 1; netevent ca502d_economy; wait 3; quit',
 'domestic-manual':'wait 1; god; netevent ca502d_manual; bind F1 "netevent ca502d_manual"; bind F2 "netevent ca502d_read"; bind F3 "netevent ca502d_no_soap"; bind F4 "netevent ca502d_buy"; bind F5 "netevent ca502d_pause"',
 'domestic-controls':'wait 1; netevent ca502d_manual; wait 70; netevent ca502d_read; netevent ca502d_no_soap; wait 70; netevent ca502d_read; netevent ca502d_buy; wait 70; netevent ca502d_read; netevent ca502d_pause; wait 3; quit',
 'domestic-core':'wait 350; netevent ca502d_market; wait 3; changemap CAH000; wait 100; netevent ca502d_house; wait 3; netevent ca502d_clean; wait 3; netevent ca502d_save; wait 3; save ca502d-current; wait 3; quit',
 'domestic-load':'wait 1; netevent ca502d_load; wait 3; wait 3; quit',
 'domestic-hub':'wait 1; changemap MAP03; wait 100; netevent ca502d_return; wait 3; changemap CAH000; wait 100; netevent ca502d_load; wait 3; wait 3; quit',
 'domestic-shortages':'wait 1; netevent ca502d_shortages; wait 3; quit',
 'domestic-clock':'wait 1; netevent ca502d_auto_start; wait 350; netevent ca502d_auto_check; wait 3; quit',
 'domestic-skipped':'wait 1; netevent ca502d_skipped; wait 3; quit',
 'domestic-old-save':'wait 350; netevent ca502d_old_save; wait 3; save ca502d-old; wait 3; quit',
 'domestic-old-verify':'wait 1; netevent ca502d_old_verify; wait 3; quit',
 'domestic-legacy':'wait 35; netevent ca502d_legacy; wait 3; save ca502d-migrated; wait 3; quit'}
for name,text in scripts.items():(out/(name+'.cfg')).write_text(text+'\n',encoding='utf-8',newline='\n')
print('Prepared domestic hygiene fixtures.')
