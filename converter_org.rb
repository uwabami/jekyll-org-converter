#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
require 'org-ruby'

module Jekyll
  # Add New Converter handling org-mode
  # main logic -> @see org_convertible.rb
  class OrgConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /^\.org$/i
    end

    def output_ext(ext)
      '.html'
    end

    def convert(content)
      content
    end
  end
end
