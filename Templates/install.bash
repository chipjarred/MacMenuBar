#!/bin/bash

TEMPLATE_FOLDER="${HOME}/Library/Developer/Xcode/Templates"

find . -type f | grep -v install\.bash | grep -v '\.DS_Store' | cpio -pmd "${TEMPLATE_FOLDER}"
