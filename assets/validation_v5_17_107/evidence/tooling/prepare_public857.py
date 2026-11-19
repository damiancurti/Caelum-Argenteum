"""Copy portable native runners and deterministic binding generation."""
from pathlib import Path
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');helper=Path(__file__).resolve().parent
out=root/'assets/validation_v5_17_107';out.mkdir(exist_ok=False)
names=['prepare_wardrobe_data857.py','run_wardrobe857.py','run_wardrobe_equipment857.py','run_wardrobe_ownership857.py','run_wardrobe_continuity857.py','wardrobe_probe857.zs','wardrobe_equipment857.zs','wardrobe_ownership857.zs','wardrobe_continuity857.zs']
for name in names:
    source=(helper/name).read_text(encoding='utf-8')
    source=source.replace("Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')","Path(__file__).resolve().parents[2]")
    (out/name).write_text(source,encoding='utf-8',newline='\n')
print('Portable issue857 tooling prepared; evidence archive pending.')
