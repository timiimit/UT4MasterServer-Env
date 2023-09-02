#!/bin/sh

# fix dns records to point to our machine
ut4ms cloudflare dns update $(ut4ms ip)

# start server
ut4ms server start
