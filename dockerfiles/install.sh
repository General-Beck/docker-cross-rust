#!/bin/sh

TOOLS='clang lld'
PROJECTS='libunwind compiler-rt libcxx libcxxabi'
ARCH="$(uname -m)"
TARGETS='X86'
ROOT=$(dirname $(readlink -f "$0"))

PATH=/"$ARCH"-unknown-linux-musl/bin:"$PATH"
LD_LIBRARY_PATH=/"$ARCH"-unknown-linux-musl/lib

if [ ! -d $ROOT/src ]; then
  echo no sources found, run sync
  exit 1
fi

if [ ! -d $ROOT/build ]; then
  mkdir $ROOT/build || $(echo 'failed to create directory' && exit 1)
fi

cd $ROOT/build || $(echo 'failed to change directory' && exit 1)

for TOOL in $TOOLS; do
  if [ ! -e $ROOT/src/llvm/tools/$TOOL ]; then
    ln -s $ROOT/src/$TOOL $ROOT/src/llvm/tools/$TOOL
  fi
done

for PRJ in $PROJECTS; do
  if [ ! -e $ROOT/src/llvm/projects/$PRJ ]; then
    ln -s $ROOT/src/$PRJ $ROOT/src/llvm/projects/$PRJ
  fi
done

if [ ! -d $ROOT/build/llvm ]; then
  mkdir $ROOT/build/llvm || $(echo 'failed to create directory' && exit 1)
fi

cd $ROOT/build/llvm || $(echo 'failed to change directory' && exit 1)

ninja install || exit 42

cd /"$ARCH"-unknown-linux-musl/bin || $(echo 'failed to change directory' && exit 1)
ln -s llvm-ar ar
ln -s llvm-ranlib ranlib
ln -s llvm-objcopy objcopy
ln -s llvm-objcopy strip
ln -s llvm-objdump objdump
ln -s llvm-nm nm
ln -s clang cc
ln -s clang++ c++
ln -s ld.lld ld
cd / || $(echo 'failed to change directory' && exit 1)
tar cvfz "$ARCH"-unknown-linux-musl.tar.gz "$ARCH"-unknown-linux-musl || exit 46
mkdir -p /artifact || $(echo 'failed to change directory' && exit 1)
mv -v "$ARCH"-unknown-linux-musl.tar.gz /artifact
