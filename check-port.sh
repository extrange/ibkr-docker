#!/bin/bash

# Check if both ports are open
if lsof -i :8888 | grep -q LISTEN && lsof -i :4002 | grep -q LISTEN; then
  exit 0
else
  exit 1
fi