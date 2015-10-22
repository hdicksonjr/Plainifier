# require Word
class Sentence

  attr_reader :word_array, :final_translated

	def initialize(raw_input)
		@word_array = []
    @sentence_hash = {}
		@final_translated = nil
		self.parse(raw_input)
    self.translate
	end

	def has_adjacent_punctuation?(word)
	  tailing_punctuation_regex = /\A[a-zA-Z'"\d-]*[:!,;.?]+\z/
		tailing_punctuation_regex === word
	end

	def tokenize_adjacent_punctuation(word)
		tailing_punctuation_token_regex = /[:!,;.?]+\z/
		punctuation = tailing_punctuation_token_regex.match(word)
		[word.chomp!(punctuation[0]), punctuation[0]]
	end

	def parse(raw_input)

    raw_input.split().each do |word|
      word.strip!

			if has_adjacent_punctuation?(word)
				tokens = tokenize_adjacent_punctuation(word)
				tokens.each do |t|

				  @word_array << Token.new(t)
				end
			else
				@word_array << Token.new(word) 
			end
			puts @word_array
		end
	end

	def final_translated
	  @final_translated
	end

  def translate

		@word_array.each do |word|
		  word.translate
		end
		@final_translated = ""
		@word_array.each do |word|
			if word.final_use.include?(" ")
				child_sentence = Sentence.new(word.final_use)
				@final_translated += child_sentence.final_translated
			else
				@final_translated += word.final_use
			end
			@final_translated += " "
		end
	end

	def compare_tags
	  @word_array.each do |word|
		  if word.pos_tag[:certainty]
				## 
			end
		end
	end
end

