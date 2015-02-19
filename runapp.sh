#!/bin/bash

R -e "shiny::runApp('$1', port = 5000)"
