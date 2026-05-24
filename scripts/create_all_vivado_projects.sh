#!/bin/bash

# @author Markus Remy

VIVADO="vivado"

SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

CREATION_SCRIPT="$(find "$SCRIPT_DIR/../hw" -name "create_vivado_project.tcl" | head -n 1)"

if [ -z "$CREATION_SCRIPT" ]; then
    echo "ERROR: create_vivado_project.tcl not found!"
    exit 1
fi

if ! "$VIVADO" -mode batch -source "$CREATION_SCRIPT"; then
    echo "CREATING PROJECT FAILED!"
    exit 1
else
    echo "SUCCESSFULLY CREATED PROJECT!"
fi