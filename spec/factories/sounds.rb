FactoryBot.define do
  factory :sound, class: Sound, traits: [:creator_and_updater] do
    factory :valid_sound do
      sound_file { fixture_file_upload((Rails.root + 'spec/files/sounds/tone.wav'), 'audio/wav') }
    end
  end
end
