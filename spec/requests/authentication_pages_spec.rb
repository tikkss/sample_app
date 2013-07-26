# encoding: utf-8
require 'spec_helper'

describe "Authentication" do
  describe "signin page" do
    before { visit signin_path }
    
    it { expect(page).to have_selector('h1', text: 'Sign in') }
    it { expect(page).to have_title(full_title('Sign in')) }
  end
  
  describe "signin" do
    before { visit signin_path }
    
    let(:submit) { "Sign in" }
    
    describe "サインインに失敗した場合：" do
      before { click_button submit }
      
      describe "submitクリック後のエラー画面：" do
        it { expect(page).to have_title(full_title('Sign in')) }
        it { expect(page).to have_error_message("Invalid") }
        
        describe "エラー画面から別画面に遷移：" do
          before { click_link 'Home' }
          
          it { expect(page).not_to have_selector("div.alert.alert-error") }
        end
      end
    end
    
    describe "サインインに成功した場合：" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }
      
      it { expect(page).to have_title(user.name) }
      it { expect(page).to have_link("Profile", href: user_path(user)) }
      it { expect(page).to have_link("Sign out") }
      it { expect(page).not_to have_link("Sign in") }
      
      describe "サインアウトした場合：" do
        before { click_link 'Sign out' }
        it { expect(page).to have_link("Sign in") }
        it { expect(page).not_to have_link("Sign out") }
      end
    end
  end
end
