#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
require 'org-ruby'

module Jekyll
  module Converters
    class Org < Converter
      safe true
      priority :low

      def matches(ext)
        ext =~ /^\.org$/i
      end

      def output_ext(ext)
        '.html'
      end

      def convert(content)
        # ad hoc file link conversion
        content.gsub(/<a href="([^(http:\/\/|https:\/\/|mailto:)]\S+)\.org/,
                     "<a href=\"\\1.html")
      end

    end

  end
end
