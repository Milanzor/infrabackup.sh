#!/usr/bin/env bash

fiddle() {


  # Absolute path
  absoluteConfigDir=$(getAbsoluteConfigDir "milan.test")
  LOG_DIRECTORY=$(getConfigValue $absoluteConfigDir "log_directory")


}
