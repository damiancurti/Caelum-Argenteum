"""Reuse #431's observer with separate #432 output ownership."""
from pathlib import Path
import importlib.util
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('profile',ROOT/'assets/validation_v5_11_0/run_profile.py')
profile=importlib.util.module_from_spec(spec)
spec.loader.exec_module(profile)
profile.OUT=ROOT/'build/issue432/performance'
if __name__=='__main__':profile.main()
