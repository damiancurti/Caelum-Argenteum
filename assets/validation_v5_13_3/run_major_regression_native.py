"""Recheck the accepted sequence fixture with all Major handlers integrated."""
from run_moon_native import main

if __name__ == '__main__':
    main('probe.zs', 'CA440', 'major-regression', 'CA440 Major integrated regression', 600)
