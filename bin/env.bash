set -euo pipefail

system=$(uname)
if [[ $system == "Linux" ]]; then
    ext="so"
elif [[ $system == "Darwin" ]]; then
    ext="dylib"
else
    echo "Unsupported system: $system"
    exit 1
fi

here=$(cd "$(dirname "$BASH_SOURCE")"; pwd)

PROJECT_ROOT=$(cd "$here/.."; pwd)
export PROJECT_ROOT

export TARGET=${TARGET:-debug}
export MODULE_DIR="$PROJECT_ROOT/target/$TARGET"
export MODULE_ORIGINAL=${MODULE_ORIGINAL:-libtree_sitter_dyn.$ext}
export MODULE_NAME=${MODULE_NAME:-tree-sitter-dyn}
export MODULE_RENAMED=${MODULE_NAME}.$ext
export TEST_FILE=tree-sitter-tests.el
export EMACS=${EMACS:-emacs}
