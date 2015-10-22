# this is a script to create records for all allowed words
# in Special English
# I scraped the original list from this: https://simple.wikipedia.org/wiki/Wikipedia:VOA_Special_English_Word_Book
# and organized them by part of speech.
require 'sequel'

DB = Sequel.postgres('plainifier', :host=>'localhost')

Dir["./models/*.rb"].each {|file| require file }

file_names = ["ad", "conj", "noun", "prep", "pro", "verb"]

file_names.each do |file_name|

	File.open("./dictionary/#{file_name}.txt").each_line do |line|
	  line.gsub!("\n", "")
		@word = Word.find(:name => line)

		if @word
			@word.special = true
			@word.save_changes
		end
	end
end
