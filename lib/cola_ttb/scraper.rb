require "open-uri"
require "mechanize"
require "nokogiri"
require "pry"

module ColaTTB
  class Scraper
    class << self
      BASE_URL           = "https://www.ttbonline.gov"
      SEARCH_URL         = "/colasonline/publicSearchColasBasic.do"
      CSV_URL            = "/colasonline/publicSaveSearchResultsToFile.do?path=/publicSearchColasBasicProcess"
      BEVERAGE_URL       = "?action=publicDisplaySearchBasic&ttbid="
      BEVERAGE_PRINT_URL = "/colasonline/viewColaDetails.do?action=publicFormDisplay&ttbid="

      def scrape_by_date(today = Date.today)
        agent          = mechanize_setup
        formatted_date = today.strftime("%m/%d/%Y")

        page = agent.get(BASE_URL + SEARCH_URL)
        form = page.form_with :name => 'searchCriteriaForm'

        form['searchCriteria.dateCompletedFrom']     = formatted_date
        form['searchCriteria.dateCompletedTo']       = formatted_date
        form['searchCriteria.productOrFancifulName'] = search_criteria[:productOrFancifulName]
        form['searchCriteria.productNameSearchType'] = search_criteria[:productNameSearchType]
        form['searchCriteria.classTypeFrom']         = search_criteria[:classTypeFrom]
        form['searchCriteria.classTypeTo']           = search_criteria[:classTypeTo]
        form['searchCriteria.originCode']            = search_criteria[:originCode]

        results_page = form.submit
        file = agent.get(BASE_URL + CSV_URL)
        return if file.body.size < 100
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
        #     17298001000631
        # COLAs Online will now only accept JPEG type
        # images (.jpg, .jpeg, .jpe). Trying to upload a TIFF type image will result in an error.
        # .split(/.jpg|.jpeg|.jpe/)
        begin
          agent = mechanize_setup
          page = agent.get(BASE_URL + BEVERAGE_PRINT_URL + id.to_s)

          images = page.search("img")
          images.each do |img|
            if img.attributes["alt"].nil?
              puts "No alt text for image #{img.attributes["src"].value}"
              next
            end
            image_attrs = parse_image_download_path(img.attributes["src"].value)
            puts "Downloading #{image_attrs[:filename]}"
            i = agent.get(BASE_URL + image_attrs[:path])
            i.save("./tmp/img/#{id}_#{image_attrs[:filename]}")
          end

          build_application_struct(page)
        rescue Exception => e
          puts "Error downloading TTD ID #{id}"
        ensure
          agent.shutdown
        end
      end

      private

      def mechanize_setup
        Mechanize.new do |agent|
          agent.user_agent = Mechanize::AGENT_ALIASES.keys.sample
          agent.html_parser = Nokogiri::XML
        end
      end

      def search_criteria
        {
          :productOrFancifulName => "%",
          :productNameSearchType => "E",
          :classTypeFrom         => 901,
          :classTypeTo           => 956,
          :originCode            => "%"
        }
      end

      def parse_image_download_path(uri)
        p = URI::encode(uri.gsub("=l", "&filetype=l"))
        fn = uri.split("filename=")[1].split("=")[0]
        {
          path: p,
          filename: fn
        }
      end

      def build_application_struct(file)
        puts file
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
        inputs = elements.css('input')
      end
    end
  end
end
