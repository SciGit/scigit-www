#!/usr/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'pathname'
require 'ydocx/markup_method'

module YDocx
  class Builder
    include MarkupMethod
    def self.build_html(node)
      compile(node, :html)
    end
    def self.build_page(contents)
      body = ''
      contents.to_markup.each do |element|
        body << build_tag(element[:tag], element[:content], element[:attributes], :html)
      end
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          doc.head {
            doc.meta :charset => 'utf-8'
            doc.title @title
            doc.link :rel => 'stylesheet', :type => 'text/css', :href => 'assets/style.css'
            doc.script :src => 'assets/script.js'
          }
          doc.body { doc << body }
        }
      end
      builder.to_html
    end
   private
    def self.compile(node, mode)
      element = node.to_markup
      build_tag(element[:tag], element[:content], element[:attributes], mode)
    end
    def self.build_tag(tag, content, attributes, mode=:html)
      if tag == :br and mode != :xml
        return "<br/>"
      elsif content.nil? or content.empty?
        return '' if attributes.nil? # without img
      end
      _content = ''
      if content.is_a? Array
        content.each do |c|
          next if c.nil? or c.empty?
          if c.is_a? Hash
            _content << build_tag(c[:tag], c[:content], c[:attributes], mode)
          elsif c.is_a? String
            _content << (mode == :html ? c : c.chomp.to_s)
          end
        end
      elsif content.is_a? Hash
        _content = build_tag(content[:tag], content[:content], content[:attributes], mode)
      elsif content.is_a? String        
        _content = content
      end
      _tag = tag.to_s
      _attributes = ''
      unless attributes.empty?
        attributes.each_pair do |key, value|
          next if mode == :xml and key.to_s =~ /(id|style|colspan)/u
          _attributes << " #{key.to_s}=\"#{value.to_s}\""
        end
      end
      if mode == :xml
        case _tag.to_sym
        when :span    then _tag = 'underline'
        when :strong  then _tag = 'bold'
        when :em      then _tag = 'italic'
        when :p       then _tag = 'paragraph'
        when :h2, :h3 then _tag = 'heading'
        when :sup     then _tag = 'superscript' # text
        when :sub     then _tag = 'subscript'   # text
        end
      end
      if tag == :img
        return "<#{_tag}#{_attributes}/>"
      else
        return "<#{_tag}#{_attributes}>#{_content}</#{_tag}>"
      end
    end
  end
end
