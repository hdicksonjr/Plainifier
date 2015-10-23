describe Token do

  describe '#final_use' do

    context "token is special" do
      token = Token.new("hi")
      it "returns original parameter" do
        expect(token.final_use).to eq("hi")
      end
    end

    context "token is not special" do

      token = Token.new("stifle")
      it "does not return original use" do
        expect(token.final_use).not_to be("stifle")
      end
    end

  end
end

