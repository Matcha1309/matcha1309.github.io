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

end

Liquid::Template.register_tag("details", Jekyll::Details)

