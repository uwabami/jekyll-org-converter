#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-

module Jekyll
  # Judge the file is Org mode?
  module Utils
    alias_method :_orig_has_yaml_header?, :has_yaml_header?

    def has_yaml_header?(file)
      if File.extname(file) =~ /org/
        true
      else
        _orig_has_yaml_header?(file)
      end
    end
  end
end
