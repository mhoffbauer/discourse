require 'spec_helper'

describe BadgeGranter do

  let(:badge) { Fabricate(:badge) }
  let(:user) { Fabricate(:user) }

  describe 'grant' do

    it 'grants a badge' do
      user_badge = BadgeGranter.grant(badge, user)
      user_badge.should be_present
    end

    it 'sets granted_at' do
      time = Time.zone.now
      Timecop.freeze time

      user_badge = BadgeGranter.grant(badge, user)
      user_badge.granted_at.should eq(time)

      Timecop.return
    end

    it 'sets granted_by if the option is present' do
      admin = Fabricate(:admin)
      user_badge = BadgeGranter.grant(badge, user, granted_by: admin)
      user_badge.granted_by.should eq(admin)
    end

    it 'defaults granted_by to the system user' do
      user_badge = BadgeGranter.grant(badge, user)
      user_badge.granted_by_id.should eq(Discourse.system_user.id)
    end

    it 'does not allow a regular user to grant badges' do
      user_badge = BadgeGranter.grant(badge, user, granted_by: Fabricate(:user))
      user_badge.should_not be_present
    end

    it 'increments grant_count on the badge' do
      BadgeGranter.grant(badge, user)
      badge.reload.grant_count.should eq(1)
    end

  end

  describe 'revoke' do

    let!(:user_badge) { BadgeGranter.grant(badge, user) }

    it 'revokes the badge and decrements grant_count' do
      badge.reload.grant_count.should eq(1)
      BadgeGranter.revoke(user_badge)
      UserBadge.where(user: user, badge: badge).first.should_not be_present
      badge.reload.grant_count.should eq(0)
    end

  end

end
