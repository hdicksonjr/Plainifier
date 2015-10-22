require 'pry'

class Token
  
	attr_reader :pos_tag, :not_translated
	attr_writer :not_translated

  def initialize(spelling)
	  @alternative = nil
		@spelling = spelling.downcase
    @pos_tag = {:tag => nil, :certainty => 0}
		@usage_count = {}
		@default_usage = nil
		@match_word = Word.find(:name => @spelling)
		@not_translated = false
	end

	def set_pos_tag
		count = 0
		total_count = 0

		if @usage_count.length == 1
      @pos_tag[:certainty] = 10 
			@pos_tag[:tag] = @usage_count.first[0]
		else
			@usage_count.each do |k, v|
				if v > count
					count = v
					# @default_usage = k
					@pos_tag[:tag] = k
				end
				total_count += v
			end
			@pos_tag[:certainty] = (count / total_count.to_f) * 10
		end

	end

	def final_use
	  if @alternative == nil 
			@spelling
		elsif @alternative == "nbrfdef" 
		  @not_translated = true
		  @spelling
		else
			@alternative
	  end
	end

	def entry_has_no_uses?
	  @pos_tag[:tag] == nil
	end

	def is_verb?
	  verb_tags = ["be", "bed", "bed*", "bedz", "beg", "bem", "bem*", "ben",
		"ber", "ber*", "bez", "bez*", "do", "do*", "do+ppss", "dod", "dod*", "doz",
		"doz*", "hv", "hv*", "hv+to", "hvd", "hvd*", "hvg", "hvn", "hvz", "hvz*",
		"vb", "vbd", "vbg", "vbn", "vbz", "md", "md*"] 
		p " in verb tags method:"

		unless entry_has_no_uses? 
			verb_tags.include?(Tag.find(:id => @pos_tag[:tag]).name)
		end
	end

	def is_punctuation_token?(token)
		punctuation_regex = /\A[:!,;.?*~\/\\\()\{}]+\z/
		punctuation_regex === token
	end

	def create_usages_for_new_word(word)
		usages = []

		if is_punctuation_token?(word.name)
			tag = Tag.find_or_create(:name => word.name)
			usages << Usage.find_or_create(:word_id => word.id, :tag_id => tag.id)
		else
			data = DictRef.query(word, "d")
			data2 = DictRef.query(word)
			if data
				data.body["meaning"].each do |k, v|
					# make some helper in Usage so you can just map POS's directly to tags.
					# This should not be done in token's model
					tag = Tag.find(:name => Tag.map_POS(k))
					break if !tag
					usages << Usage.find_or_create(:word_id => word.id, :tag_id => tag.id)
				end
			else
				false
			end

		end
		usages
	end

	def query_for_lemma(word)

	  words_api_response = DictRef.query(word)
		mw_api_response = DictRef.mw_t_query(word)
		lemma = false

		if words_api_response && words_api_response.body["response"] == @spelling
			lemma = @spelling
		elsif words_api_response && words_api_response.body["response"] !=
			@spelling
			lemma = words_api_response.body["response"]
			add_lemma(lemma)
			lemma
		elsif mw_api_response
			mw_api_response.css("term hw").each do |t|
			  if t.text != @spelling
					lemma = t.text
					add_lemma(lemma)
				end
			end
			lemma
		else
			raise "no Lemma identified"
		end

	end

	def conjugate
	  word_record = Word.find(:name => @alternative)
    # looking for a usage here that has the current stem as a lemma and the
		# proper pos tag so we can find the corresponding word. otherwise we need
		# to find a way to conjugate.
	  usage = Usage.find(:tag_id => @pos_tag[:tag], :lemma_id => word_record.id)

		if usage
			@alternative = Word.find(:id => usage.word_id)
		else
			ConjugationEngine.conjugate(@alternative, @pos_tag[:tag])
		end
	end

	def is_special_token?(word)
	  if is_punctuation_token?(word)
      true
		elsif is_numeric?
		  true
		else
			false
		end
	end

	def find_lemma(response)
		add_lemma(response)
		lemma = Word.find(:name => response.body["response"])
	end

	def translate

		@spelling = is_genitive?
		record = Word.find_or_create(:name => @spelling)

		unless is_special_token?(@spelling)
			query_matching_tags(record)

			if is_verb?
				lemma = query_for_lemma(@spelling)
				if lemma
					lemma_record = Word.find_or_create(:name => lemma)
					if !lemma_record.special
						replacement = find_valid_alternative(lemma_record.name)
						if replacement != "nbrfdef"
							@alternative = replacement
							conjugate
						else
							@alternative = DictRef.fetch_wordnik_def(lemma, @pos_tag[:tag])
						end
					end
				end
			elsif !record.special
				# look up most common tag for word
				replacement = find_valid_alternative(@spelling)
				if replacement == "nbrfdef"
					response = DictRef.query(@spelling, "d", @pos_tag[:tag])
					if response == false
						@alternative = DictRef.fetch_wordnik_def(@spelling, @pos_tag[:tag])
					end
				else 
					@alternative = replacement
				end
			end
		end

	end

	def is_numeric?
		numeric_pattern = /\D*\d+\D*/
		numeric_pattern === @spelling
	end

	def is_genitive?
	  genitive_pattern = /\A[a-z]+'s\z/
		genitive_pattern === @spelling ? @spelling[0..-3] : @spelling
	end

  def make_record(word)
	  query(word)
	end

  def find_valid_alternative(word)

	  response = DictRef.query(word)
		replacement = "nbrfdef"

		if response
			association_words = response.body["assoc_word"]
      # may want to consider referencing "assoc_word_ex" rather than
			#'assoc_word'. it is slighlty more extensive
			association_words.each do |w|
			  w_ref = Word.find_or_create(:name => w)
				if w_ref.special
					replacement = w
					if @pos_tag[:tag]
            original_word_ref = Word.find_or_create(:name => word)
						usages = create_usages_for_new_word(original_word_ref)
						usage = Usage.join(:words, :id=>:word_id).where(:name => word).first
						usage.update(:alternative_id => w_ref.id)
					end
					break
				end
			end
		end

		replacement

	end


	def add_lemma(lemma)

		word = Word.find(:name => @spelling)
		usage = Usage.find(:word_id => word.id, :tag_id => @pos_tag[:tag])
		lemma_record = Word.find_or_create(:name => lemma)
		usage.update(:lemma_id => lemma_record.id)
	end

	def query_matching_tags(word)
	  usages = Usage.where(:word_id => word.id)
		if usages.count == 0
			# does a pos tag need to be set here?
			create_usages_for_new_word(word) 
		else
			usages.each do |usage|
				@usage_count[usage.tag.id] = usage.count
			end
		end
		set_pos_tag
	end
end

