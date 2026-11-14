"""Inspect nine native weapon assembly drops for #725."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'validation_v5_17_1'))
from run_coin_presentation import main
if __name__=='__main__':main('assembly_components')
