require 'nokogiri'

module HomeHelper
  def mobileParse(i)
    if not i.content.nil?
      first_paragraph = Nokogiri::HTML.parse(i.content).css('p').first
      raw(first_paragraph.text)
    else
      ""
    end
  end
end
