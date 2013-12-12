module ProjectChangesHelper
  def format_diff_blocks(blocks, mode = :inline)
    rows = []
    blocks[0].zip(blocks[1]).each do |old_block, new_block|
      if old_block.nil? && new_block.nil?
        if mode == :inline
          rows << '<tr class="change-omission"><td class="linenumber">...</td>' +
            '<td class="linenumber">...</td>' +
            '<td class="content">unchanged text not included</td></tr>'
        else
          rows << '<tr class="change-omission"><td class="linenumber">...</td>' +
            '<td class="content">Unchanged text not included</td>' +
            '<td class="linenumber second">...</td>' +
            '<td class="content">Unchanged text not included</td></tr>'
        end
      else
        block = old_block || new_block
        type = ''
        type = 'change-modify'   if block.type == '!'
        type = 'change-addition' if block.type == '+'
        type = 'change-deletion' if block.type == '-'
        block.lines.each_with_index do |line, i|
          old_line = old_block ? old_block.start_line + i : ''
          new_line = new_block ? new_block.start_line + i : ''
          old_type = old_block ? type : 'change-null'
          new_type = new_block ? type : 'change-null'
          if i == 0
            old_type += ' first'
            new_type += ' first'
          end
          if i == block.lines.length-1
            old_type += ' last'
            new_type += ' last'
          end
          if mode == :inline
            rows << "<tr class='line'><td class='linenumber #{type}' data-content='#{old_line}'></td>" +
              "<td class='linenumber #{type}' data-content='#{new_line}'></td>" +
              "<td class='content inline #{type}'>#{line}</td></tr>"
          else
            old_text = old_block ? old_block.lines[i] : ''
            new_text = new_block ? new_block.lines[i] : ''
            rows << "<tr class='line'><td class='linenumber #{old_type}' data-content='#{old_line}'></td>" +
              "<td class='content #{old_type}'>#{old_text}</td>" +
              "<td class='linenumber second #{new_type}' data-content='#{new_line}'></td>" +
              "<td class='content #{new_type}'>#{new_text}</td></tr>"
          end
        end
      end
    end
    rows.join('')
  end
end
