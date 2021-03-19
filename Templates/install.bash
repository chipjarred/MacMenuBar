#!/bin/bash

TEMPLATE_FOLDER="${HOME}/Library/Developer/Xcode/Templates"

find . -type f | grep -v install\.bash | cpio -pmd "${TEMPLATE_FOLDER}"
