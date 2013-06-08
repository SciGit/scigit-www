#!/usr/bin/env ruby
# encoding: utf-8

require 'ydocx/builder'
require 'diff/lcs'

module YDocx
  class Differ
    Block = Struct.new(:start_line, :type, :lines)

    def initialize
      @cur_change_id = 1
    end
    def get_text(chunk)
      if chunk.empty?
        ''
      elsif chunk[0].is_a? Image
        [chunk[0].img_hash]
      elsif chunk[0].is_a? Cell
        [chunk[0].blocks]
      else
        chunk.join('')
      end
    end
    # percent similarity of two text blocks
    def text_similarity(text1, text2)
      lcs = Diff::LCS.LCS(text1, text2)
      lcs_len = 0
      lcs.each do |run|
        lcs_len += run.length
      end
      tlen = 0
      (text1 + text2).each do |run|
        tlen += run.length
      end
      if tlen == 0
        return 1
      else
        return 2.0 * lcs_len / tlen
      end
    end
    def get_detail_blocks(blocks1, blocks2)
      n = blocks1.length
      m = blocks2.length
      if n == 0 || m == 0
        return [[blocks1, blocks2]]
      end
      if n*m > 10000
        # assume it's all different QQ
        return [[blocks1, []], [[], blocks2]]
      end
      lcs = Array.new(n+1) { Array.new(m+1, 0) }
      action = Array.new(n+1) { Array.new(m+1, -1) }
      text1 = blocks1.map { |b| b.get_chunks.map(&method(:get_text)) }
      text2 = blocks2.map { |b| b.get_chunks.map(&method(:get_text)) }
        
      blocks1.reverse.each_with_index do |a, ii|
        blocks2.reverse.each_with_index do |b, jj|
          i = n-1-ii
          j = m-1-jj
          sim = (a.class == b.class ? text_similarity(text1[i], text2[j]) : 0)
          # printf "%d %d = %d\n", i, j, sim
          lcs[i][j] = lcs[i+1][j]
          action[i][j] = 0
          if lcs[i][j+1] > lcs[i][j]
            lcs[i][j] = lcs[i][j+1]
            action[i][j] = 1
          end
          if sim >= 0.5 && lcs[i+1][j+1] + sim > lcs[i][j]
            lcs[i][j] = lcs[i+1][j+1] + sim
            action[i][j] = 2
          end
        end
      end
      
      i = 0
      j = 0
      lblocks = []
      rblocks = []
      diff_blocks = []
      while i < n || j < m        
        if j == m || action[i][j] == 0
          lblocks << blocks1[i]
          i += 1
        elsif i == n || action[i][j] == 1
          rblocks << blocks2[j]
          j += 1
        else
          unless lblocks.empty? && rblocks.empty?
            if lblocks.empty? || rblocks.empty?
              diff_blocks << [lblocks.dup, rblocks.dup]
            else
              diff_blocks << [lblocks.dup, []]
              diff_blocks << [[], rblocks.dup]
            end
            lblocks = []
            rblocks = []
          end
          diff_blocks << [[blocks1[i]], [blocks2[j]]]
          i += 1
          j += 1
        end
      end
      unless lblocks.empty? && rblocks.empty?
        if lblocks.empty? || rblocks.empty?
          diff_blocks << [lblocks.dup, rblocks.dup]
        else
          diff_blocks << [lblocks.dup, []]
          diff_blocks << [[], rblocks.dup]
        end
      end
      diff_blocks
    end
    def get_diff_change_array(list1, list2)
      change_id = [Array.new(list1.length), Array.new(list2.length)]
      Diff::LCS.diff(list1, list2).each do |diff|
        count = diff.map { |c| c.action }.uniq.length
        if count == 1
          cid = -1
        else
          cid = @cur_change_id
          @cur_change_id += 1
        end
        diff.each do |change|
          change_id[change.action == '-' ? 0 : 1][change.position] = cid
        end
      end
      change_id
    end
    def get_paragraph_diff(p1, p2, result)
      chunks = [p1.get_chunks, p2.get_chunks]
      change_id = get_diff_change_array(chunks[0], chunks[1])
      
      for i in 0..1
        p = Paragraph.new
        p.align = [p1,p2][i].align
        group = RunGroup.new
        prev_table = nil
        chunks[i].each_with_index do |chunk, j|
          if change_id[i][j]
            if change_id[i][j] >= 1
              group.css_class = (sprintf 'modify modify-%d', change_id[i][j])
            elsif i == 0
              group.css_class = 'delete'
            else
              group.css_class = 'add'
            end
            if chunk == [Run.new("\n")]
              group.runs << Run.new("&crarr;\n")
            else
              group.runs += chunk
            end
          else
            p.runs << group unless group.runs.empty?
            group = RunGroup.new
            p.runs += chunk
          end
        end
        p.runs << group unless group.runs.empty?
        p.merge_runs
        result[i] << p
      end
    end
    def get_table_diff(t1, t2, result)
      tables = [Table.new, Table.new]
      get_detail_blocks(t1.rows, t2.rows).each do |rblock|
        if rblock[0].empty?
          rblock[1].map { |r| r.cells.map { |c| c.css_class = 'add' } }
          tables[1].rows += rblock[1]
        elsif rblock[1].empty?
          rblock[0].map { |r| r.cells.map { |c| c.css_class = 'delete' } }
          tables[0].rows += rblock[0]
        else # should be 1 row in each
          change_id = get_diff_change_array(rblock[0].first.cells, rblock[1].first.cells)
          for i in 0..1
            rblock[i].first.cells.each_with_index do |cell, j|
              if change_id[i][j]
                if change_id[i][j] >= 1
                  cell.css_class = (sprintf 'modify modify-%d', change_id[i][j])
                elsif i == 0
                  cell.css_class = 'delete'
                else
                  cell.css_class = 'add'
                end
              end
            end
          end
          tables[0].rows += rblock[0]
          tables[1].rows += rblock[1]
        end
      end
      result[0] << tables[0]
      result[1] << tables[1]
    end
    def diff(doc1, doc2)
      blocks1 = doc1.blocks
      blocks2 = doc2.blocks
      result = {:inline => [[], []], :side => [[], []]}

      pg = [1, 1]
      lblocks = []
      rblocks = []
      inline_blocks = []
      Diff::LCS.sdiff(blocks1, blocks2).each do |change|
        if change.action == '='
          inline_blocks << [lblocks.dup, rblocks.dup] unless lblocks.empty? && rblocks.empty?
          inline_blocks << [[blocks1[change.old_position]], [blocks2[change.new_position]]]
          lblocks = []
          rblocks = []
        else
          lblocks << blocks1[change.old_position] unless change.old_element.nil?
          rblocks << blocks2[change.new_position] unless change.new_element.nil?
        end
      end
      inline_blocks << [lblocks.dup, rblocks.dup] unless lblocks.empty? && rblocks.empty?
      inline_blocks.each do |blocks|
        html_blocks = blocks.map do |block|
          block.map { |b| Builder.build_html(b) }
        end
        if blocks[0] == blocks[1]
          result[:inline][0] << Block.new(pg[0], '=', html_blocks[0])
          result[:inline][1] << Block.new(pg[1], '=', html_blocks[1])
          pg[0] += html_blocks[0].length
          pg[1] += html_blocks[1].length
        else
          unless blocks[0].empty?
            result[:inline][0] << Block.new(pg[0], '-', html_blocks[0])
            result[:inline][1] << nil
            pg[0] += html_blocks[0].length
          end
          unless blocks[1].empty?
            result[:inline][0] << nil
            result[:inline][1] << Block.new(pg[1], '+', html_blocks[1])
            pg[1] += html_blocks[1].length
          end
        end
      end
      
      text1 = blocks1.map { |b| b.get_chunks.map(&method(:get_text)) }
      text2 = blocks2.map { |b| b.get_chunks.map(&method(:get_text)) }
      
      lblocks = []
      rblocks = []
      diff_blocks = []
      Diff::LCS.sdiff(text1.map(&:hash), text2.map(&:hash)).each do |change|
        if change.action == '='
          diff_blocks << [lblocks.dup, rblocks.dup] unless lblocks.empty? && rblocks.empty?
          diff_blocks << [[blocks1[change.old_position]], [blocks2[change.new_position]]]
          lblocks = []
          rblocks = []
        else
          lblocks << blocks1[change.old_position] unless change.old_element.nil?
          rblocks << blocks2[change.new_position] unless change.new_element.nil?
        end
      end
      diff_blocks << [lblocks.dup, rblocks.dup] unless lblocks.empty? && rblocks.empty?
      
      pg = [1, 1]
      diff_blocks.each do |dblock|
        get_detail_blocks(dblock[0], dblock[1]).each do |block|
          type = ['=', '=']
          blocks = [[], []]
          if block[0].empty?
            blocks[1] = block[1]
            type[1] = '+'
          elsif block[1].empty?
            blocks[0] = block[0]
            type[0] = '-'
          elsif block[0] != block[1]
            # Each block should only contain 1 element
            type = ['!', '!']
            if block[0].first.is_a? Paragraph
              get_paragraph_diff(block[0].first, block[1].first, blocks)
            else
              get_table_diff(block[0].first, block[1].first, blocks)
            end
          else
            blocks[0] = block[0]
            blocks[1] = block[1]
          end
          blocks = blocks.map do |block|
            block.map { |b| Builder.build_html(b) }
          end
          for i in 0..1
            if blocks[i].empty?
              result[:side][i] << nil
            else
              result[:side][i] << Block.new(pg[i], type[i], blocks[i])
              pg[i] += blocks[i].length
            end
          end
        end
      end
      
      result 
    end
  end
end
