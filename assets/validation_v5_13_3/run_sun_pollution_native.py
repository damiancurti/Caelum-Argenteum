"""Verify local pollution sources, interval closure and saved containment."""
from run_moon_native import main

if __name__ == '__main__':
    main('sun_pollution.zs', 'CA440DIRTY', 'sun-pollution', 'CA440 Sun pollution', 700)
