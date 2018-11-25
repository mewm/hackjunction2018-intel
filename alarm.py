#!/usr/bin/env python3
import sys
import maincore
import time
import os
if __name__ == '__main__':
    node = sys.argv[1]
    message = sys.argv[2]
    maincore.main('model 0 0x0000 0xfbf105 '+ node +' 0 ' + message, node)

    
    
    

