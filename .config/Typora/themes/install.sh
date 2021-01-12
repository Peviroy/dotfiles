#!/bin/bash
if ! [ -x "$(command -v curl)" ] || ! [ -x "$(command -v unzip)" ]; then
	  echo 'Error: curl or unzip is not installed.' >&2
	  exit 1
fi

ARCHIVE_NAME="NexT.zip"

# use proxy to speeds up if it exists
if [ -x "$(command -v proxychains)" ]; then
	proxychains curl -C - https://github.com/BillChen2K/typora-theme-next/releases/download/1.1.1/typora-theme-next.zip -L -o $ARCHIVE_NAME
else
	curl -C - https://github.com/BillChen2K/typora-theme-next/releases/download/1.1.1/typora-theme-next.zip -L -o $ARCHIVE_NAME
fi

unzip -o NexT.zip -x 'README.md' '__MACOSX/*'
