include "../cfg.nim"
import os
import osproc
import strutils

proc cfg =
    if welcometxt:
        echo "Welcome to shell HSH."
