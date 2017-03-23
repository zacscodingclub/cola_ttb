module ColaTtb
  class Scraper
    SEARCH_URL         = "https://www.ttbonline.gov/colasonline/publicSearchColasBasic.do"
    BEVERAGE_PRINT_URL = "https://www.ttbonline.gov/colasonline/viewColaDetails.do?action=publicFormDisplay&ttbid="

    def self.call

    end
    def self.mechanize_setup
      mech = Mechanize.new
      mech.user_agent = 'Windows Mozilla'
      mech
    end
  end
end
