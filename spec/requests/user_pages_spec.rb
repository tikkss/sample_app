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
      
      describe "submitクリック後のエラー画面：" do
        before { click_button submit }
        
        it { expect(page).to have_selector('h1', text: 'Sign up') }
        it { expect(page).to have_content('error') }
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
      
      describe "submitクリック後のユーザ詳細画面：" do
        before { click_button submit }
        let(:user) { User.find_by_email("user@example.com")}
        
        it { expect(page).to have_title(user.name) }
        it { expect(page).to have_selector('div.alert.alert-success', text: 'Welcome') }
        it { expect(page).to have_link('Sign out') }
      end
    end
  end
  
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    
    it { expect(page).to have_selector('h1', text: user.name) }
    it { expect(page).to have_title(user.name) }
  end
  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end
    
    describe "page" do
      it { expect(page).to have_selector('h1', text: 'Update your profile') }
      it { expect(page).to have_title("Edit user") }
      it { expect(page).to have_link('change', href: 'http://gravatar.com/emails') }
    end
    
    describe "入力情報が不正な場合：" do
      before { click_button "Save changes" }
      
      it { expect(page).to have_selector('h1', text: 'Update your profile') }
      it { expect(page).to have_content('error') }
    end
    
    describe "入力情報が正常な場合：" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end
      
      it { expect(page).to have_title('New Name') }
      it { expect(page).to have_selector('div.alert.alert-success') }
      it { expect(page).to have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to   eq new_name }
      specify { expect(user.reload.email).to  eq new_email }
    end
  end
  
  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    
    before(:each) do
      sign_in user
      visit users_path
    end
    
    it { expect(page).to have_title('All users') }
    it { expect(page).to have_selector('h1', text: 'All users') }
    
    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }
      
      it { expect(page).to have_selector("div.pagination") }
      
      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end
    
    describe "delete links" do
      it { expect(page).not_to have_link('delete') }
      
      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end
        
        it { expect(page).to have_link('delete', href: user_path(User.first)) }
        it { expect(page).not_to have_link('delete', href: user_path(admin)) }
      end
    end
  end
end
