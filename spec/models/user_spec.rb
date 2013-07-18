# encoding: utf-8
# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
  before { @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar") }
  
  it { expect(@user).to respond_to(:name) }
  it { expect(@user).to respond_to(:email) }
  it { expect(@user).to respond_to(:password_digest) }
  it { expect(@user).to respond_to(:password) }
  it { expect(@user).to respond_to(:password_confirmation) }
  it { expect(@user).to respond_to(:authenticate) }
  
  it { expect(@user).to be_valid }
  
  describe '#name が空白の場合：' do
    before { @user.name = " " }
    it { expect(@user).not_to be_valid }
  end
  describe '#name が長すぎる場合：' do
    before { @user.name = "a" * 51 }
    it { expect(@user).not_to be_valid }
  end
  
  describe '#email が空白の場合：' do
    before { @user.email = " " }
    it { expect(@user).not_to be_valid }
  end
  describe '#email が不正な場合：' do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
    addresses.each do |invalid_address|
      before { @user.email = invalid_address }
      it { expect(@user).not_to be_valid }
    end
  end
  describe '#email が正常な場合：' do
    addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    addresses.each do |valid_address|
      before { @user.email = valid_address }
      it { expect(@user).to be_valid }
    end
  end
  describe '#email が既に存在する場合：' do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    it { expect(@user).not_to be_valid }
  end
  describe '#email が大文字小文字混在する場合：' do
    let(:mixed_case_email) { 'Foo@ExAMPle.CoM' }
    
    it '保存後に、全て小文字になっていること' do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end
  
  describe '#password が空白の場合：' do
    before { @user.password = @user.password_confirmation = ' ' }
    it { expect(@user).not_to be_valid }
  end
  describe '#password が#password_confirmationと一致しない場合：' do
    before { @user.password_confirmation = 'mismatch' }
    it { expect(@user).not_to be_valid}
  end
  
  describe '#password_confirmation がnilの場合：' do
    before { @user.password_confirmation = nil }
    it { expect(@user).not_to be_valid }
  end
  
  describe '#authenticate の検証：' do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }
    
    describe '#password が一致する場合：' do
      it { expect(@user).to eq found_user.authenticate(@user.password) }
    end
    describe '#password が一致しない場合：' do
      let(:user_for_invalid_password) { found_user.authenticate('invalid') }
      
      it { expect(@user).not_to eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end
end
