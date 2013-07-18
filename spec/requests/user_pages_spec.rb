# encoding: utf-8
require 'spec_helper'

describe "User pages" do
  describe "signup page" do
    before { visit signup_path }
    
    it { expect(page).to have_selector('h1', text: 'Sign up') }
    it { expect(page).to have_title(full_title('Sign up')) }
  end
  
  describe "signup" do
    before { visit signup_path }
    
    let(:submit) { "Create my account" }
    
    describe "入力情報が不正な場合：" do
      it "ユーザが作成されないこと" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end
    
    describe "入力情報が正常な場合：" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end
      
      it "ユーザが作成されること" do
        expect { click_button submit }.to change(User, :count)
      end
    end
  end
  
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    
    it { expect(page).to have_selector('h1', text: user.name) }
    it { expect(page).to have_title(user.name) }
  end
end