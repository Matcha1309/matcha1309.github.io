module Jekyll

  class Details < Liquid::Block

    def initialize(tag_name, summary, tokens)
      super
      @summary = summary.to_s.gsub(/^("|')|("|')$/, '').strip
    end

    def render(context)
      @md_converter = context.registers[:site].find_converter_instance(::Jekyll::Converters::Markdown)
      @content = super.to_s
      %Q[<details>
          <summary>
            #{@md_converter.convert(@summary).to_s.gsub(/^<p>/, '').gsub(/<\/p>$/, '')}
          </summary>
          #{@md_converter.convert(@content)}
        </details>
        ]
    end
  end

  class Strip < Liquid::Block
    def render(context)
      @md_converter = context.registers[:site].find_converter_instance(::Jekyll::Converters::Markdown)
      content = super.to_s.strip
      lines = content.split("\n").reject(&:empty?)
      fraction = 1.0 / lines.length.to_f
      output = '<div class="strip">'
      lines.each_with_index do |line, index|
        parsed_line = @md_converter.convert(line.strip)
        parsed_line = parsed_line.gsub(/^<p>/, "").gsub(/<\/p>$/, "")
        output += %Q[<div class="strip-line">#{parsed_line}</div>]
      end
      output += "</div>"
      return output
    end
  end


end

Liquid::Template.register_tag("details", Jekyll::Details)
Liquid::Template.register_tag("strip", Jekyll::Strip)
