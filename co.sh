#!/bin/bash
. ./repo.sh

cd ..
GitCheck ${common[@]}
GitCheck ${zip[@]}
GitCheck ${fvimSuits[@]}

