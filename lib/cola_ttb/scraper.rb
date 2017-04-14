require "open-uri"
require "mechanize"
require "nokogiri"
require "pry"

module ColaTTB
  class Scraper
    class << self
      BASE_URL           = "https://www.ttbonline.gov/colasonline"
      SEARCH_URL         = "/publicSearchColasBasic.do"
      CSV_URL            = "/publicSaveSearchResultsToFile.do?path=/publicSearchColasBasicProcess"
      BEVERAGE_PRINT_URL = "/viewColaDetails.do?action=publicFormDisplay&ttbid="

      def scrape_by_date(date = Date.today)
        agent          = mechanize_setup
        today          = date
        formatted_date = today.strftime("%m/%d/%Y")

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
        file.save("./tmp/date/#{today.strftime("%Y_%m_%d")}.csv")
      end

      def scrape_csv(file)
        csv = ColaTTB::CSVHandler.new(file)

        ttb_ids = csv.parse

        ttb_ids.map do |id|
          scrape_by_ttd_id(id)
        end
      end

      def scrape_by_ttd_id(id)
        # input id
        # output Application struct
        binding.pry
        agent = mechanize_setup

        file = agent.get(BASE_URL + BEVERAGE_PRINT_URL + id.to_s)
        build_application_struct(file)
      end

      private

      def mechanize_setup
        mech = Mechanize.new
        mech.user_agent = Mechanize::AGENT_ALIASES.keys.sample
        mech.html_parser = Nokogiri::XML
        mech
      end

      def search_criteria
        {
          :dateCompletedFrom     => formatted_date,
          :dateCompletedTo       => formatted_date,
          :productOrFancifulName => "%",
          :productNameSearchType => "E",
          :classTypeFrom         => 901,
          :classTypeTo           => 956,
          :originCode            => "%"
        }
      end

      def build_application_struct(file)
        # Struct.new(
        #   ttb_id: file.css('.data+ table .data').text,
        #   date_of_application: file.css('table .boldlabel').at("div:contains('16.')").next_element.text,
        #   date_issued: file.css('table .boldlabel').at("div:contains('19.')").next_element.text,
        #   status: file.css('table .boldlabel').at("div:contains('STATUS')").next_element.children[0].text.split("THE STATUS IS").last.strip,
        #   application_type: get_application_type(file),
        #   beer: {
        #     source: '',
        #     type: '',
        #     serial_number: file.css('.label').at("div:contains('4. S')").next_element.text,
        #     brand_name: file.css('table .boldlabel').at("div:contains('6. B')").next_element.text,
        #     fanciful_name: file.css('table .boldlabel').at("div:contains('7. F')").next_element.text,
        #     label: file.css('img').last
        #   },
        #   brewery: {
        #     name: ,
        #     plant_registry: ,
        #     address: {
        #
        #     },
        #     contact: {
        #       name: file.css('.label').at("div:contains('18. P')").next_element.text.strip.gsub(/[\n\t]]/,'').split.join(' '),
        #       phone_number: file.css('.label').at("div:contains('12.')").next_element.text,
        #       email: file.css('.boldlabel').at("div:contains('13.')").next_element.text.strip
        #     }
        #   }
        # )
      end


      def get_application_type(file)
        elements = file.css('.label').at("div:contains('14. ')").next_element.children[1]
      end
    end
  end
end
