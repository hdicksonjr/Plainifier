# A script used to train the database by reading in a tagged
# version of the Brown Corpus originally found here: 
# https://archive.org/details/BrownCorpus
#

require 'sequel'
DB = Sequel.postgres('plainifier', :host=>'localhost')

Dir["./models/*.rb"].each {|file| require file }

def read_file(file_name)
  File.open("./brown/#{file_name}")
end

def parse_file_string(contents)

  words = contents.split(" ")
  words.each do |block|
    block.downcase!
    word_regex = /.*[a-z]+.*\/.*[a-z]+.*/
    if word_regex === block
      word_and_tag = block.split("/")
      word_and_tag.each {|b| b.strip!}
      save_record(word_and_tag)
    end
  end

end

def manage_loop

  letter = "a"
  number = "01"
  file_name = "c#{letter}#{number}"

  while letter != "r"
    p "looping file: #{file_name}"

    if File.exist?("./brown/#{file_name}")
      file = read_file(file_name)
      contents = file.read
      parse_file_string(contents)
      number.next!
      p "file exists: #{file_name}"
    else
      letter.next!
      number = "01"
      p "file does not exist, so changing letters"
    end

    file_name = "c#{letter}#{number}"
  end

end

def save_record(word_data)

  @word = Word.find_or_create(:name => word_data[0])
  @tag = Tag.find_or_create(:name => word_data[1])
  @usage = Usage.find(:word => @word, :tag => @tag)

  if @usage
    count = @usage.count += 1
    @usage.save_changes
  else 
    Usage.create(:word => @word, :tag => @tag)
  end

end

manage_loop

