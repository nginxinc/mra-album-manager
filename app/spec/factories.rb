#
#  factories.rb
#  AlbumManager
#
#  Copyright © 2017 NGINX Inc. All rights reserved.
#

FactoryGirl.define do
  factory :album do

    factory :album_with_images do
      transient do
        images_count 5
      end

      after(:create) do |album, evaluator|
        images = create_list(:image, evaluator.images_count, album: album)
        album.poster_image = images.first
        album.save!
      end
    end
  end

  factory :image do
    album
  end
end