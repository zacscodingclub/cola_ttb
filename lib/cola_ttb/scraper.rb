require "open-uri"
require "mechanize"
require "nokogiri"

module ColaTTB
  class Scraper
    SEARCH_URL         = "https://www.ttbonline.gov/colasonline/publicSearchColasBasic.do"
    BEVERAGE_PRINT_URL = "https://www.ttbonline.gov/colasonline/viewColaDetails.do?action=publicFormDisplay&ttbid="

    def self.call
      search_criteria = {
        :dateCompletedFrom     => 03/20/2017,
        :dateCompletedTo       => 03/23/2017,
        :productOrFancifulName => "%",
        :productNameSearchType => "E",
        :classTypeFrom         => 901,
        :classTypeTo           => 956,
        :originCode            => "%",    => "%",
      }
    end


    def self.mechanize_setup
      mech = Mechanize.new
      mech.user_agent = 'Windows Mozilla'
      mech
    end
  end
end
