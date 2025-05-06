SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

c2nim $SCRIPT_DIR/gentest.c2nim $1 --stdints