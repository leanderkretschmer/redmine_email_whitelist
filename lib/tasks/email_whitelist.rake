namespace :email_whitelist do
  desc "Install email whitelist plugin"
  task :install => :environment do
    puts "Installing Redmine Email Whitelist Plugin..."
    
    # Create default settings if they don't exist
    unless Setting.plugin_redmine_email_whitelist
      Setting.plugin_redmine_email_whitelist = {
        'allowed_email_domains' => '',
        'disallowed_email_domains' => ''
      }
      puts "✓ Default settings created"
    else
      puts "✓ Settings already exist"
    end
    
    puts "✓ Plugin installation completed"
    puts ""
    puts "Next steps:"
    puts "1. Go to Administration → Settings → Email notification"
    puts "2. Configure the 'Email Domain Restrictions' section"
    puts "3. Restart your Redmine server"
  end

  desc "Uninstall email whitelist plugin"
  task :uninstall => :environment do
    puts "Uninstalling Redmine Email Whitelist Plugin..."
    
    # Remove plugin settings
    Setting.where("name LIKE 'plugin_redmine_email_whitelist%'").destroy_all
    puts "✓ Plugin settings removed"
    
    puts "✓ Plugin uninstallation completed"
    puts ""
    puts "Note: You may need to manually remove the plugin files from the plugins directory"
  end

  desc "Test email whitelist configuration"
  task :test_config => :environment do
    puts "Testing Email Whitelist Configuration..."
    
    settings = Setting.plugin_redmine_email_whitelist
    if settings
      puts "✓ Plugin settings found"
      puts "  Allowed domains: #{settings['allowed_email_domains'] || '(none)'}"
      puts "  Disallowed domains: #{settings['disallowed_email_domains'] || '(none)'}"
    else
      puts "✗ Plugin settings not found"
    end
    
    # Test domain matching logic
    puts ""
    puts "Testing domain matching logic..."
    
    test_emails = [
      'user@example.com',
      'admin@trusted.com',
      'spam@blocked.com'
    ]
    
    test_domains = [
      'example.com',
      '*@trusted.com',
      'spam@blocked.com'
    ]
    
    test_emails.each do |email|
      test_domains.each do |domain|
        # This is a simplified test - in real usage, the logic is in the MailerPatch
        email_domain = email.split('@').last&.downcase
        domain_pattern = domain.downcase.strip
        
        if domain_pattern.start_with?('*@')
          pattern_domain = domain_pattern[2..-1]
          matches = email_domain == pattern_domain
        elsif domain_pattern.include?('@')
          matches = email.downcase == domain_pattern
        else
          matches = email_domain == domain_pattern
        end
        
        puts "  #{email} matches #{domain}: #{matches ? '✓' : '✗'}"
      end
    end
  end
end
