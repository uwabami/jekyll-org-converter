#! /usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
require 'org-ruby'
require 'pp'
module Orgmode
  # monkey patch Orgmode::to_html inline_formatter
  class HtmlOutputBuffer < OutputBuffer

    alias_method :_orig_add_line_attributes, :add_line_attributes
    def add_line_attributes(headline)
      _orig_add_line_attributes(headline)
      @output << "<a id=\"#{headline.headline_text}\"><span class='anchor'>_</span></a>"
    end

    alias_method :_orig_inline_formatting, :inline_formatting
    def inline_formatting(str)
      @re_help.rewrite_emphasis str do |marker, s|
        if marker == "=" or marker == "~"
          s = escapeHTML s
          "<#{Tags[marker][:open]}>#{s}</#{Tags[marker][:close]}>"
        else
          quote_tags("<#{Tags[marker][:open]}>") + s +
            quote_tags("</#{Tags[marker][:close]}>")
        end
      end

      if @options[:use_sub_superscripts] then
        @re_help.rewrite_subp str do |type, text|
          if type == "_" then
            quote_tags("<sub>") + text + quote_tags("</sub>")
          elsif type == "^" then
            quote_tags("<sup>") + text + quote_tags("</sup>")
          end
        end
      end

      @re_help.rewrite_links str do |link, defi|
        [link, defi].compact.each do |text|
          # We don't support search links right now. Get rid of it.
          # -> Support search links!!
          text.sub!(/\A(file:[^\s]+)::([^\s]*?)\Z/, "\\1#\\2")
          text.sub!(/\Afile:(?=[^\s]+\Z)/, "")
        end

        # We don't add a description for images in links, because its
        # empty value forces the image to be inlined.
        defi ||= link unless link =~ @re_help.org_image_file_regexp

        if defi =~ @re_help.org_image_file_regexp
          defi = quote_tags "<img src=\"#{defi}\" alt=\"#{defi}\" />"
        end

        if defi
          link = @options[:link_abbrevs][link] if @options[:link_abbrevs].has_key? link
          quote_tags("<a href=\"#{link}\">") + defi + quote_tags("</a>")
        else
          quote_tags "<img src=\"#{link}\" alt=\"#{link}\" />"
        end
      end

      if @output_type == :table_row
        str.gsub! /^\|\s*/, quote_tags("<td>")
        str.gsub! /\s*\|$/, quote_tags("</td>")
        str.gsub! /\s*\|\s*/, quote_tags("</td><td>")
      end

      if @output_type == :table_header
        str.gsub! /^\|\s*/, quote_tags("<th>")
        str.gsub! /\s*\|$/, quote_tags("</th>")
        str.gsub! /\s*\|\s*/, quote_tags("</th><th>")
      end

      if @options[:export_footnotes] then
        @re_help.rewrite_footnote str do |name, defi|
          # TODO escape name for url?
          @footnotes[name] = defi if defi
          quote_tags("<sup><a class=\"footref\" name=\"fnr.#{name}\" href=\"#fn.#{name}\">") +
            name + quote_tags("</a></sup>")
        end
      end

      # Two backslashes \\ at the end of the line make a line break without breaking paragraph.
      if @output_type != :table_row and @output_type != :table_header then
        str.sub! /\\\\$/, quote_tags("<br />")
      end

      escape_string! str
      Orgmode.special_symbols_to_html str
      str = @re_help.restore_code_snippets str
    end
  end
end
