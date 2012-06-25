require 'rubygems'
require 'nokogiri' 

class ParseVFLinksPage
  attr_accessor :file
  attr_accessor :target_div
  attr_accessor :xpath

  def dump_link_data(target_div)
    @vf_link_admin_page = Nokogiri::HTML(open(@file))
    @vf_link_admin_page_text = @vf_link_admin_page.xpath("/html/body/div/center/form/div[3]/div[#{target_div}]").inner_text
  end
  
  def parse_link_data(target_div)
    @  
      
end


(1..20).each do |i|
  do_dump = ParseVFLinksPage.new
  do_dump.file = "/Users/evl771/Downloads/run.php.html"
  do_dump.target_div = i
  do_dump.dump_link_data(i)
  
end

