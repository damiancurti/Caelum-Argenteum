"""Reuse the accepted serial native runner with #433 output ownership."""
from pathlib import Path
import importlib.util
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('native',ROOT/'assets/validation_5103/run_native.py')
native=importlib.util.module_from_spec(spec);spec.loader.exec_module(native)
native.OUT=ROOT/'build/issue433'
if __name__=='__main__':native.main()
