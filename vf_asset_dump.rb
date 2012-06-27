require 'oauth'
require 'rubygems'
require 'nokogiri'



$consumer = OAuth::Consumer.new( "r3TuFAfozlh9TA0o7-eBNQ", "0-Jiel4hMz5uDzwtJKt_Iw", 
                                  :site => "https://vfurnprd1.library.northwestern.edu",
                                  )
                     
num_pages = 65

def pull_page(page)
  current_assets = $consumer.request(:get, "/apis/assets/?page=#{page}")
  return current_assets.body
end

def get_assets_from_page(page)
  asset_list = Nokogiri::XML(page)
  id = asset_list.xpath("/response/assets/asset/id") 
  return id
end


def scrape_pages
  (1..65).each do |i| 
    current_page_assets = pull_page(i)
    get_assets_from_page(current_page_assets).each do |z|
      stripped_tags = z.inner_text
      current_asset = $consumer.request(:get, "/apis/assets/asset-#{stripped_tags}")
      yield current_asset
    
    end
  end
end

scrape_pages do |f| puts