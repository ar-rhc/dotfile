#!/usr/bin/env python3
import sys
import os
import time

WHITE = '0xffcad3f5'
RED = '0xffed8796'

def format_seconds(seconds: int) -> str:
    parts = []
    if seconds >= 3600:
        for dur in (3600, 60, 1):
            parts.append(str(seconds // dur).zfill(2))
            seconds %= dur
    else:
        for dur in (60, 1):
            parts.append(str(seconds // dur).zfill(2))
            seconds %= dur
    return ':'.join(parts)

def set_label(label: str, color: str = WHITE):
    os.system(f'sketchybar --set timer label="{label}" label.color={color}')

def stopwatch(start: int):
    while True:
        delta = int(time.time()) - start
        set_label(format_seconds(delta), WHITE)
        time.sleep(1)

def countdown(end_time: int):
    while True:
        delta = end_time - int(time.time())
        if delta <= 0:
            break
        color = RED if delta < 60 else WHITE
        set_label(format_seconds(delta), color)
        time.sleep(1)

    set_label('Time Up!', WHITE)
    for _ in range(3):
        os.system('afplay /System/Library/Sounds/Funk.aiff')
    set_label('')

def main(argv):
    start = int(time.time())
    if len(argv) == 1:
        stopwatch(start)
    elif len(argv) == 2:
        try:
            seconds = int(argv[1])
        except ValueError:
            set_label('Invalid input', RED)
            time.sleep(2)
            set_label('')
            return
        countdown(start + seconds)

if __name__ == '__main__':
    main(sys.argv)






