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
      before { sign_in user }
      
      it { expect(page).to have_title(user.name) }
      it { expect(page).to have_link("Users", href: users_path) }
      it { expect(page).to have_link("Profile", href: user_path(user)) }
      it { expect(page).to have_link("Settings", href: edit_user_path(user)) }
      it { expect(page).to have_link("Sign out") }
      it { expect(page).not_to have_link("Sign in") }
      
      describe "サインアウトした場合：" do
        before { click_link 'Sign out' }
        it { expect(page).to have_link("Sign in") }
        it { expect(page).not_to have_link("Sign out") }
      end
    end
  end
  
  describe "authorization" do
    describe "サインインしていないユーザ：" do
      let(:user) { FactoryGirl.create(:user) }
      
      describe "in the UsersController" do
        describe "edit page" do
          before { visit edit_user_path(user) }
          it { expect(page).to have_title("Sign in") }
        end
        
        describe "submitting to the update action" do
          before { put user_path(user) }
          it { expect(response).to redirect_to(signin_path) }
        end
        
        describe "index page" do
          before { visit users_path }
          it { expect(page).to have_title("Sign in") }
        end
      end
      
      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end
        
        describe "サインイン後" do
          it "should render the desired protected page" do
            expect(page).to have_title("Edit user")
          end
        end
      end
    end
    
    describe "本人以外のユーザ：" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }
      
      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { expect(page).not_to have_title("Edit user") }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end
    
    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }
      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }        
      end
    end
  end
end
