require 'spec_helper'

describe NoCms::Blocks::Layout do

  context "when looking for a layout" do

    before do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: :string,
              body: :text
            }
          }
        }
      end
    end

    it "should find the declared layouts" do
      expect(NoCms::Blocks::Layout.find('title-long_text')).to_not be_nil
    end

    it "should not find undeclared layouts" do
      expect(NoCms::Blocks::Layout.find('this-layout-is-not-real')).to be_nil
    end

  end

  context "when getting layout configuration" do
    before do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: title_configuration[:type],
              body: body_configuration
            }
          }
        }
      end
    end

    let(:title_configuration) { { type: :string } }
    let(:body_configuration) { { type: :text } }

    subject { NoCms::Blocks::Layout.find('title-long_text') }

    it "should recover the configuration for quickly configured fields" do
      expect(subject.fields[:title]).to eq title_configuration
    end

    it "should recover the configuration for verbosing configured fields" do
      expect(subject.fields[:body]).to eq body_configuration
    end

  end

end