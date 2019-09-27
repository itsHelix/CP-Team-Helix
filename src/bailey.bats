#!/usr/bin/env bats

# CIS 1.1.1: Disable unused filesystems
filesystem_mounting_disabled_boolean() {
  result1="$(modprobe -n -v ${$1})"
  result2="$(lsmod | grep ${$1})"
  return [ result1 -eq "install /bin/true" && result2 -eq "" ]
}

@test "cramfs mounting disabled" {
  [ filesystem_mounting_disabled_boolean cramfs ]
}
@test "freevxfs mounting disabled" {
  [ filesystem_mounting_disabled_boolean freevxfs ]
}
@test "jffs2 mounting disabled" {
  [ filesystem_mounting_disabled_boolean jffs2 ]
}
@test "hfs mounting disabled" {
  [ filesystem_mounting_disabled_boolean hfs ]
}
@test "hfsplus mounting disabled" {
  [ filesystem_mounting_disabled_boolean hfsplus ]
}
@test "udf mounting disabled" {
  [ filesystem_mounting_disabled_boolean udf ]
}
