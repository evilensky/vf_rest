require 'oauth'
require 'rubygems'
require 'nokogiri'
require 'sqlite3'

$consumer = OAuth::Consumer.new(
                                  :site => "https://vfurnprd1.library.northwestern.edu")

$db = SQLite3::Database.open('assets.db')

#request an individual page and return the XML body
def pull_page(page)
  current_assets = $consumer.request(:get, "/apis/assets/?page=#{page}")
  return current_assets.body
end

#scrape the individual list of asset IDs from the page
def get_assets_from_page(page)
  asset_list = Nokogiri::XML(page)
  id = asset_list.xpath("/response/assets/asset/id")
end

#return the number of pages to scrape (number of assets, 100 assets per page)
def get_number_of_assets
  num_results = Nokogiri::XML($consumer.request(:get, "/apis/assets").body)
  num_result  = num_results.xpath("//@numResults").inner_text.to_i
  num_pages = (num_result.round(4) / 100).ceil
end

#get the assets and for each asset on the page, request the page and yield
def scrape_pages
  num_pages = get_number_of_assets
  (1..num_pages).each do |i| 
    current_page_assets = pull_page(i)
    get_assets_from_page(current_page_assets).each do |z|
      stripped_tags = z.inner_text
      current_asset = $consumer.request(:get, "/apis/assets/asset-#{stripped_tags}")
      yield current_asset
    end
  end
end

#empty the database
$db.execute ("drop table if exists VF_ASSETS")      
$db.execute ("Create table if not exists VF_ASSETS (id PRIMARY KEY, title TEXT, description TEXT, runtime INTEGER, created TEXT)")      
      
      #insert this into the DB.
      ##todo, try making a hashmap in stead of hardcoding
      scrape_pages do |asset|
          xml_asset = Nokogiri::XML(asset.body)
          csv_asset_id    = xml_asset.xpath("/response/asset/id").inner_text
          csv_asset_title = xml_asset.xpath("/response/asset/title").inner_text
          csv_asset_description = xml_asset.xpath("/response/asset/description").inner_text
          csv_asset_runtime = xml_asset.xpath("/response/asset/runtime").inner_text
          csv_asset_created = xml_asset.xpath("/response/asset/created").inner_text
          $db.execute("INSERT into VF_ASSETS (id, title, description, runtime, created) VALUES(?,?,?,?,?)", csv_asset_id, csv_asset_title, csv_asset_description, csv_asset_runtime, csv_asset_created)
      end