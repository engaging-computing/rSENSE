require 'nokogiri'

module HomeHelper
  def mobileParse(i)
    if Nokogiri.HTML(i.content).search('p').length != 0
      first_paragraph = Nokogiri.HTML(i.content).search('p').first
      raw(first_paragraph.text)
    else
      ''
    end
  end
end
