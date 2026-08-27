#!/usr/bin/env bash

# Internal validation helpers shared by runtime modules.

_blm_is_nonnegative_integer() {
  [[ $1 =~ ^[0-9]+$ ]]
}

_blm_is_positive_integer() {
  [[ $1 =~ ^[1-9][0-9]*$ ]]
}
