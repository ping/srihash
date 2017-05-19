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
# Example:
# ./srihash.sh 'https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css' 'https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/js/bootstrap.min.js'
# ==== Generating hash for: https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css ====
# sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u
# <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css"
#  integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u"
#  crossorigin="anonymous">
# ==== Generating hash for: https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/js/bootstrap.min.js ====
# sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa
# <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/js/bootstrap.min.js"
#  integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa"
#  crossorigin="anonymous"></script>
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
                echo -e -n "$htmlsrc" | pbcopy
            elif [[ "$f" == *'.css' ]]; then
                htmlsrc="<link rel=\"stylesheet\" href=\"$f\"\n integrity=\"$hshval\"\n crossorigin=\"anonymous\">"
                echo -e "$htmlsrc"
                echo -e -n "$htmlsrc" | pbcopy
            fi
        fi
    done
done
