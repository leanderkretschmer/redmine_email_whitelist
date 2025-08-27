require File.expand_path('../../test_helper', __FILE__)

class EmailWhitelistTest < ActiveSupport::TestCase
  include RedmineEmailWhitelist::MailerPatch

  def setup
    @mailer = Mailer.new
  end

  def test_domain_matches_with_simple_domain
    assert domain_matches?('user@example.com', ['example.com'])
    assert domain_matches?('admin@example.com', ['example.com'])
    assert !domain_matches?('user@other.com', ['example.com'])
  end

  def test_domain_matches_with_wildcard_domain
    assert domain_matches?('user@example.com', ['*@example.com'])
    assert domain_matches?('admin@example.com', ['*@example.com'])
    assert !domain_matches?('user@other.com', ['*@example.com'])
  end

  def test_domain_matches_with_specific_email
    assert domain_matches?('user@example.com', ['user@example.com'])
    assert !domain_matches?('admin@example.com', ['user@example.com'])
    assert !domain_matches?('user@other.com', ['user@example.com'])
  end

  def test_domain_matches_case_insensitive
    assert domain_matches?('USER@EXAMPLE.COM', ['example.com'])
    assert domain_matches?('user@example.com', ['EXAMPLE.COM'])
    assert domain_matches?('User@Example.com', ['*@EXAMPLE.COM'])
  end

  def test_filter_recipients_with_whitelist
    allowed_domains = ['example.com', '*@trusted.com']
    disallowed_domains = []
    
    recipients = ['user@example.com', 'admin@trusted.com', 'user@blocked.com']
    filtered = filter_recipients(recipients, allowed_domains, disallowed_domains)
    
    assert_includes filtered, 'user@example.com'
    assert_includes filtered, 'admin@trusted.com'
    assert_not_includes filtered, 'user@blocked.com'
  end

  def test_filter_recipients_with_blacklist
    allowed_domains = []
    disallowed_domains = ['spam.com', '*@blocked.com']
    
    recipients = ['user@example.com', 'admin@spam.com', 'user@blocked.com']
    filtered = filter_recipients(recipients, allowed_domains, disallowed_domains)
    
    assert_includes filtered, 'user@example.com'
    assert_not_includes filtered, 'admin@spam.com'
    assert_not_includes filtered, 'user@blocked.com'
  end

  def test_filter_recipients_with_combined_lists
    allowed_domains = ['example.com', '*@trusted.com']
    disallowed_domains = ['bad@example.com', '*@blocked.com']
    
    recipients = ['user@example.com', 'bad@example.com', 'admin@trusted.com', 'user@blocked.com']
    filtered = filter_recipients(recipients, allowed_domains, disallowed_domains)
    
    assert_includes filtered, 'user@example.com'
    assert_not_includes filtered, 'bad@example.com'  # Blacklisted
    assert_includes filtered, 'admin@trusted.com'
    assert_not_includes filtered, 'user@blocked.com'  # Blacklisted
  end

  def test_filter_recipients_with_empty_lists
    allowed_domains = []
    disallowed_domains = []
    
    recipients = ['user@example.com', 'admin@any.com']
    filtered = filter_recipients(recipients, allowed_domains, disallowed_domains)
    
    assert_equal recipients, filtered
  end

  def test_filter_recipients_with_nil_recipients
    allowed_domains = ['example.com']
    disallowed_domains = []
    
    filtered = filter_recipients(nil, allowed_domains, disallowed_domains)
    assert_equal [], filtered
  end

  def test_filter_recipients_with_empty_strings
    allowed_domains = ['example.com']
    disallowed_domains = []
    
    recipients = ['user@example.com', '', '   ', nil]
    filtered = filter_recipients(recipients, allowed_domains, disallowed_domains)
    
    assert_includes filtered, 'user@example.com'
    assert_not_includes filtered, ''
    assert_not_includes filtered, '   '
    assert_not_includes filtered, nil
  end

  private

  def domain_matches?(email, domains)
    @mailer.send(:domain_matches?, email, domains)
  end

  def filter_recipients(recipients, allowed_domains, disallowed_domains)
    @mailer.send(:filter_recipients, recipients, allowed_domains, disallowed_domains)
  end
end
