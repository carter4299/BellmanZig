#! /bin/bash
#
#        It's like looking in a mirror, only not.
#                         💭
#    🤓                   🗿
# MAKEFILE              do.sh

check_venv() {
    if [ -d "venv" ]; then
        echo "venv already exists"
        source venv/bin/activate
    else
        echo "Creating venv"
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    fi
}


if [ $# -eq 0 ]; then
    echo "No arguments supplied: py <gen|init>"
    exit 1
fi

if [ "$1" == "gen" ]; then
    check_venv
    echo "Generating data.csv"
    python3 scripts/gen.py
elif [ "$1" == "init" ]; then
    check_venv
    echo "Initializing data.db"
    python3 scripts/init.py
elif [ "$1" == "build" ]; then
    zig build -Doptimize=ReleaseFast
elif [ "$1" == "run" ]; then
    zig build run -Doptimize=Debug
else
    echo "Invalid argument: py <gen|init|build|run>"
    exit 1
fi
