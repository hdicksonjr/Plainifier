require "unirest"
require "nokogiri"
require "wordnik"

module DictRef

	Wordnik.configure do |config|
		config.api_key = ENV["WORDNIK"]
		config.response_format = 'json'
	end

	def self.fetch_wordnik_def(word, tag)
		if tag
			tag_record = Tag.find(:id => tag)
			pos = Tag.map_tag_to_tag_family(tag_record)
			response = Wordnik.word.get_definitions(word, :use_canonical => false, :part_of_speech => pos)
		else
			response = Wordnik.word.get_definitions(word, :use_canonical => false)
		end
		DictRef.clean_def_response(response[0]["text"])

	end

	def self.query(word, query_key="a", *pos_tag)

		query_types = { "d" => "definition", "a" => "association"}

	  entry = word.is_a?(Word) ? word.name : word
		response = 
		Unirest.get("https://twinword-word-graph-dictionary.p.mashape.com/#{query_types[query_key]}/?entry=#{entry}",
		headers:{
			"X-Mashape-Key" => ENV['MASHAPE'],
			"Accept" => "application/json"
		})

		if self.response_is_valid?(response.body["result_code"])

			if pos_tag.length > 0
				tag = Tag.find(:id => pos_tag)
				response.body["meaning"].each do |k, v|
				  if Tag.map_POS(k) == Tag.map_tag_to_tag_family(tag)
						return DictRef.clean_def_response(v)
						break
					end
				end
			else
				response
			end
		else
			false
		end
	end

	def self.clean_def_response(definition_string)
	  interjection_regex = /\(.*\)/
	  response_string = definition_string.sub(interjection_regex, "")
		response_string = response_string.split(",")
		response_string[0]
	end

	def self.mw_query(word)
	  response =
		Unirest.get("http://www.dictionaryapi.com/api/v1/references/collegiate/xml/#{word}?key=#{ENV['MW']}")
    # might remove this query entirely. I don't see any reason to use MW and/or XML
		# parsed = Nokogiri::XML(response.body)
		# parsed.css("entry dt").text
	end

	def self.mw_t_query(word)
	  response =
		Unirest.get("http://www.dictionaryapi.com/api/v1/references/thesaurus/xml/#{word}?key=#{ENV['MWT']}")
    # may remove MW queries entirely
		# parsed = Nokogiri::XML(response.body)
	end

	def self.response_is_valid?(result_code) 
    # regex to check for a response code in 400's 
		bad_result_code_regex = /\A4\d*/
		
		!(bad_result_code_regex === result_code)
	end

	def self.reverso_query(base, tag)
	  response =
		Unirest.get("conjugator.reverso.net/conjugation-english-verb-#{base}.html")
		parsed = Nokogiri::HTML(response.body)
	end

end
