#!/bin/sh
set -eu

# Usage: sh Scripts/gnscharts.sh PROJECT_NAME TARGET_NAME PROJECT_CODE HONESTCODE_BLUEPRINT_NAME STAGE
APP_BINARY="$(find ~/Library/Developer/Xcode/DerivedData/$1*/Build/Intermediates/CodeCoverage/Products/*/$2.app/$2)"
COVERAGE_PROFDATA="$(find ~/Library/Developer/Xcode/DerivedData/$1*/Build/Intermediates/CodeCoverage/Coverage.profdata)"
COVERAGE_PERCENT="$(xcrun llvm-cov report -instr-profile $COVERAGE_PROFDATA $APP_BINARY | awk '/TOTAL/ {print $4}' | tr . ,)"
echo Coverage - $COVERAGE_PERCENT -
LINES_OF_CODE="$(find . \( -path ./Pods -prune -o -path ./fastlane -prune -o -path ./\*Tests\* -prune \) -o \( -iname \*.swift -o -iname \*.m \) -print0 | xargs -0 wc -l | awk '{print $1}' | tail -1)"
echo Lines - $LINES_OF_CODE -
curl --user "${GNSUSER}" "https://devops.intelygenz.com/rest/projectState.aspx?projectCode=$3&cdPiece=ios&atddBlueprintName=$4cdStageName=$5&cdStageStatus=1&codeLinesOfCode=$LINES_OF_CODE&codeUTCover=${COVERAGE_PERCENT%%%}" > /dev/null
