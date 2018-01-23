require 'rails_helper'

RSpec.describe "GitHub issues", type: :feature do

  context 'signed in with a project selected' do
    before {sign_in_user_and_select_project}

    context 'reporting an issue' do

      context 'when on the workbench', js: true do

        specify 'a GitHub issues slideout is accesible' do 
          expect(page).to have_selector('.slide-github-integration .slide-panel-circle-icon')
          page.execute_script('document.querySelector(".slide-github-integration .slide-panel-circle-icon").click()')
        end
      end
    end
  end
end
