require "open-uri"
require "mechanize"
require "nokogiri"
require "pry"

module ColaTTB
  class Scraper
    BASE_URL           = "https://www.ttbonline.gov/colasonline"
    SEARCH_URL         = "/publicSearchColasBasic.do"
    CSV_URL            = "/publicSaveSearchResultsToFile.do?path=/publicSearchColasBasicProcess"
    BEVERAGE_PRINT_URL = "/viewColaDetails.do?action=publicFormDisplay&ttbid="

    def self.call(date = Date.today)
      today          = date
      formatted_date = today.strftime("%m/%d/%Y")

      search_criteria = {
        :dateCompletedFrom     => formatted_date,
        :dateCompletedTo       => formatted_date,
        :productOrFancifulName => "%",
        :productNameSearchType => "E",
        :classTypeFrom         => 901,
        :classTypeTo           => 956,
        :originCode            => "%"
      }

      agent = mechanize_setup
      page = agent.get(BASE_URL + SEARCH_URL)
      form = page.form_with :name => 'searchCriteriaForm'

      form['searchCriteria.dateCompletedFrom']     = search_criteria[:dateCompletedFrom]
      form['searchCriteria.dateCompletedTo']       = search_criteria[:dateCompletedTo]
      form['searchCriteria.productOrFancifulName'] = search_criteria[:productOrFancifulName]
      form['searchCriteria.productNameSearchType'] = search_criteria[:productNameSearchType]
      form['searchCriteria.classTypeFrom']         = search_criteria[:classTypeFrom]
      form['searchCriteria.classTypeTo']           = search_criteria[:classTypeTo]
      form['searchCriteria.originCode']            = search_criteria[:originCode]

      results_page = form.submit

      file = agent.get(BASE_URL + CSV_URL)
      file.save("./tmp/#{today.strftime("%Y_%m_%d")}.csv")
    end

    def self.mechanize_setup
      mech = Mechanize.new
      mech.user_agent = Mechanize::AGENT_ALIASES.keys.sample
      mech
    end
  end
end
