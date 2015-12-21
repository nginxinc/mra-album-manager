FactoryGirl.define do
  factory :album do

    factory :album_with_images do
      transient do
        images_count 5
      end

      after(:create) do |album, evaluator|
        create_list(:image, evaluator.images_count, album: album)
      end
    end
  end

  factory :image do
    album
  end
end