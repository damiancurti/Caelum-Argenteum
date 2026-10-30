"""Reuse the accepted #431 observer for normal formation campaign costs."""
from pathlib import Path
import importlib.util
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('profile',ROOT/'assets/validation_v5_11_0/run_profile.py')
profile=importlib.util.module_from_spec(spec);spec.loader.exec_module(profile)
profile.OUT=ROOT/'build/issue429/performance'
if __name__=='__main__':profile.main()
