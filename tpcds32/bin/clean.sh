#!/bin/bash

BASE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"

rm -rf "${BASE_DIR}"/gen_data/*
rm -rf "${BASE_DIR}"/gen_queries/*
rm -rf "${BASE_DIR}"/output/*
