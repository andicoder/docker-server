#!/usr/bin/env python3
import sys
import time
import calc_consumption
import sbf2vz
import os

def main(argv):
    while True:
        os.system("/usr/src/app/sbf2vz.py")
        os.system("/usr/src/app/calc_consumption.py")
        time.sleep(10 * 60)


if __name__ == "__main__":
    main(sys.argv[1:])