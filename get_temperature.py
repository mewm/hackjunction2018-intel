#!/usr/bin/env python3
import sys
import maincore
import time
if __name__ == '__main__':
    node = sys.argv[1]
    maincore.main('model 0 0x1102 0x8231 '+ node +' 0 0x2a1f', node)
    
    

