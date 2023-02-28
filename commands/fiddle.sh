#!/usr/bin/env bash

fiddle() {


  # Absolute path
  absoluteConfigDir=$(getAbsoluteConfigDir "milan.test")

buildRdiffPurgeCommand "${absoluteConfigDir}"
buildRdiffListIncrementsCommand "${absoluteConfigDir}"

}
