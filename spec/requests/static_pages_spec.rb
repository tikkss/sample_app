# encoding: utf-8
require 'spec_helper'

describe "Static pages" do
  describe "Home page" do
    before { visit root_path }
    
    it { expect(page).to      have_selector('h1', text: 'Sample App') }
    it { expect(page).to      have_title(full_title('')) }
    it { expect(page).not_to  have_title("| Home") }
  end

  describe "Help page" do
    before { visit help_path }
    
    it { expect(page).to have_selector('h1', text: 'Help') }
    it { expect(page).to have_title(full_title('Help')) }
  end

  describe "About page" do
    before { visit about_path }
    
    it { expect(page).to have_selector('h1', text: 'About Us') }
    it { expect(page).to have_title(full_title("About Us")) }
  end
  
  describe "Contact page" do
    before { visit contact_path }
    
    it { expect(page).to have_selector('h1', text: 'Contact') }
    it { expect(page).to have_title(full_title("Contact")) }
  end
end