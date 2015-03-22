#! /usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-
require 'org-ruby'

module Jekyll
  # Handling Org options as YAML front matter, escape liquid tag
  module Convertible
    alias_method :_orig_read_yaml, :read_yaml

    def read_yaml(base, name, opts = {})
      if name =~ /org$/
        content = File.read(site.in_source_dir(base, name),
                            merged_file_read_opts(opts))
        if File.exist?('_html_tags.yml')
          org_content = Orgmode::Parser.new(content,
                                            markup_file: '_html_tags.yml')
        else
          org_content = Orgmode::Parser.new(content)
        end
        yaml_front_matter = {}
        org_content.in_buffer_settings.each_pair do |k, v|
          yaml_front_matter.merge!(k.downcase => v)
        end
        yaml_front_matter = yaml_front_matter.delete_if { |k, v| k == 'html' }
        self.data = SafeYAML.load(yaml_front_matter.to_yaml + "---\n")
        if yaml_front_matter.key?('liquid')
          self.content = org_content.to_html
          self.content = self.content.gsub('&#8216;', "'")
          self.content = self.content.gsub('&#8217;', "'")
        else
          self.content = <<ORG
{% raw %}
#{org_content.to_html}
{% endraw %}
ORG
        end
      else
        _orig_read_yaml(base, name, opts)
      end
    end
  end
end
