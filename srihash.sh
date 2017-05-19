#!/bin/bash

# Simple bash script that generates the Subresource Integrity (SRI) hash for a remote resource
# Source: https://github.com/ping/srihash/
#
# Usage:
#   ./srihash.sh 'https://url/to/a.css'
#   ./srihash.sh 'https://url/to/a.css' 'https://url/to/another.js'
# Use sha256 instead
#   ./srihash.sh 'sha256' 'https://url/to/a.css'
# Use sha512 instead
#   ./srihash.sh 'sha512' 'https://url/to/a.css'
#
set -e

# default algo, options: 'sha256' 'sha384' 'sha512'
hashalgo='sha384'

# terminal colors
bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
blue=`tput setaf 4`
reset=`tput sgr0`

allhtmlsrc=''
for f in "$@"
do
    if [ "${f:0:3}" = 'sha' ]; then
        hashalgo="$f"
        continue
    elif [ "${f:0:4}" != 'http' ]; then
        echo "${red}Invalid URL: $f ${reset}"
        continue
    fi
    echo "==== ${bold}Generating hash for: $f${reset} ===="
    for h in 'sha256' 'sha384' 'sha512'
    do
        if [ "$h" = "$hashalgo" ]; then
            hshval="$h-$(curl -sL $f | openssl dgst -$h -binary | openssl base64 -A)"
            echo "${bold}${green}$hshval${reset}"
            if [[ "$f" == *'.js' ]]; then
                htmlsrc="<script src=\"$f\"\n integrity=\"$hshval\"\n crossorigin=\"anonymous\"></script>"
                echo -e "$htmlsrc"
                if [ -n "$allhtmlsrc" ]; then
                    allhtmlsrc="$allhtmlsrc\n"
                fi
                allhtmlsrc="$allhtmlsrc$htmlsrc"
            elif [[ "$f" == *'.css' ]]; then
                htmlsrc="<link rel=\"stylesheet\" href=\"$f\"\n integrity=\"$hshval\"\n crossorigin=\"anonymous\">"
                echo -e "$htmlsrc"
                if [ -n "$allhtmlsrc" ]; then
                    allhtmlsrc="$allhtmlsrc\n"
                fi
                allhtmlsrc="$allhtmlsrc$htmlsrc"
            fi
        fi
    done
done
if [ -n "$allhtmlsrc" ]; then
    echo -e -n "$allhtmlsrc" | pbcopy
fi
