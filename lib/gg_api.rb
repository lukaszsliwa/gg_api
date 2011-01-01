# -*- encoding: utf-8 -*-
libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'gg_api/version'
require 'gg_api/client'
require 'gg_api/gg_object'
require 'gg_api/exceptions'
