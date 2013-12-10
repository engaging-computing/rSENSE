require 'nokogiri'

module HomeHelper
  def mobileParse(i)
    if not i.content.nil?
      first_paragraph = Nokogiri::HTML.parse(i.content).css('p').first
      if first_paragraph.nil?
        i.content
      else
        raw(first_paragraph.text)
      end
    else
      ""
    end
  end
end
