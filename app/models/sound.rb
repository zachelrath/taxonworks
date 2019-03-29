# A Sound represents a sound file stored on disk.
#
# This class relies on Active Storage to handle attached sound files.
#
class Sound < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  has_one_attached :sound_file

  # @param [ActionController::Parameters] params
  # @return [Scope]
  def self.find_for_autocomplete(params)
    where(id: params[:term]).with_project_id(params[:project_id])
  end
end
