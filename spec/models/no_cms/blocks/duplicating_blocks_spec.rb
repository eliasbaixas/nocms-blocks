require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when duplicating a block without translations" do

    let(:block_title) { Faker::Lorem.sentence }
    let(:image_attributes) {  }
    let(:block) do
      NoCms::Blocks::Block.create layout: 'title-long_text',
        title: block_title,
        body: Faker::Lorem.paragraph,
        logo: attributes_for(:test_image),
        background: attributes_for(:test_image),
        header: attributes_for(:test_image)
    end


    let(:dupped_block) { block.dup }


    before(:all) do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: { type: :string, translated: false },
              body: { type: :text, translated: false, duplicate: :nullify },
              logo: { type: TestImage, translated: false, duplicate: :dup },
              background: { type: TestImage, translated: false, duplicate: :nil },
              header: { type: TestImage, translated: false, duplicate: :link }
            }
          }
        }
      end
    end

    before { dupped_block.save! }

    subject { NoCms::Blocks::Block.find dupped_block.id }

    it "should have the same layout" do
      expect(subject.layout).to eq block.layout
    end

    it "should have the same text" do
      expect(subject.title).to eq block_title
    end

    it "should nullify the field configured to be nullified" do
      expect(subject.body).to be_nil
    end

    it "should duplicate an Active Record field configured to be duplicated" do
      expect(subject.logo).to_not be_new_record
      expect(subject.logo).to_not eq block.logo
    end

    it "should return a new record when an AR field is configured to nullify" do
      expect(subject.background).to be_new_record
    end

    it "should link an Active Record field configured to be linked" do
      expect(subject.header).to eq block.header
    end

  end

  context "when duplicating a block with translations" do

    let(:block_title_es) { Faker::Lorem.sentence }
    let(:block_title_en) { Faker::Lorem.sentence }
    let(:block) do
      NoCms::Blocks::Block.create layout: 'title-long_text',
        logo: attributes_for(:test_image),
        background: attributes_for(:test_image),
        header: attributes_for(:test_image),
        translations_attributes: [
          {
            locale: 'es',
            title: block_title_es,
            body: Faker::Lorem.paragraph,
            logo: attributes_for(:test_image),
            background: attributes_for(:test_image),
            header: attributes_for(:test_image)
          },
          {
            locale: 'en',
            title: block_title_en,
            body: Faker::Lorem.paragraph,
            logo: attributes_for(:test_image),
            background: attributes_for(:test_image),
            header: attributes_for(:test_image)
          }
        ]
    end

    let(:dupped_block) { block.dup }


    before(:all) do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: :string,
              description: { type: :string, translated: false },
              body: { type: :text, duplicate: :nullify },
              logo: { type: TestImage, duplicate: :dup },
              background: { type: TestImage, duplicate: :nil },
              header: { type: TestImage, duplicate: :link }
            }
          }
        }
      end
    end

    before { dupped_block.save! }

    subject { NoCms::Blocks::Block.find dupped_block.id }

    it "should have the same layout" do
      expect(subject.layout).to eq block.layout
    end

    it "should have the same text" do
      [:es, :en].each do |locale|
        I18n.with_locale(locale) { expect(subject.title).to eq send("block_title_#{locale}") }
      end
    end

    it "should nullify the field configured to be nullified" do
      [:es, :en].each do |locale|
        I18n.with_locale(locale) { expect(subject.body).to be_nil }
      end
    end

    it "should duplicate an Active Record field configured to be duplicated" do
      [:es, :en].each do |locale|
        expect(subject.logo).to_not be_new_record
        expect(subject.logo).to_not eq block.logo
      end
    end

    it "should return a new record when an AR field is configured to nullify" do
      [:es, :en].each do |locale|
        expect(subject.background).to be_new_record
      end
    end

    it "should link an Active Record field configured to be linked" do
      [:es, :en].each do |locale|
        expect(subject.header).to eq block.header
      end
    end

  end

end
