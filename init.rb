Redmine::Plugin.register :redmine_email_whitelist do
  name 'Redmine Email Whitelist'
  author 'Leander Kretschmer'
  description 'Plugin to whitelist and blacklist email domains for outgoing emails'
<<<<<<< HEAD
  version '1.0.0'
=======
  version '1.2.3'
>>>>>>> 8ec79329cbc22aae2fa7fffadbe19d8373cf039d
  url 'https://github.com/leanderkretschmer/redmine_email_whitelist'
  author_url 'https://github.com/leanderkretschmer'
  requires_redmine version_or_higher: '6.0.0'

  settings default: {
    'allowed_email_domains' => '',
    'disallowed_email_domains' => ''
  }, partial: 'settings/email_whitelist_settings'
end

# Hook to intercept outgoing emails
require_dependency 'mailer'
module RedmineEmailWhitelist
  module MailerPatch
    def deliver_mail(mail)
      # Get settings
      allowed_domains = Setting.plugin_redmine_email_whitelist['allowed_email_domains'].to_s.split(',').map(&:strip).reject(&:blank?)
      disallowed_domains = Setting.plugin_redmine_email_whitelist['disallowed_email_domains'].to_s.split(',').map(&:strip).reject(&:blank?)

      # Check if whitelist is enabled (if allowed_domains is not empty)
      if allowed_domains.any?
        # Filter recipients based on whitelist
        mail.to = filter_recipients(mail.to, allowed_domains, disallowed_domains) if mail.to
        mail.cc = filter_recipients(mail.cc, allowed_domains, disallowed_domains) if mail.cc
        mail.bcc = filter_recipients(mail.bcc, allowed_domains, disallowed_domains) if mail.bcc
      elsif disallowed_domains.any?
        # Only blacklist is active
        mail.to = filter_recipients_blacklist_only(mail.to, disallowed_domains) if mail.to
        mail.cc = filter_recipients_blacklist_only(mail.cc, disallowed_domains) if mail.cc
        mail.bcc = filter_recipients_blacklist_only(mail.bcc, disallowed_domains) if mail.bcc
      end

      # Only deliver if there are still recipients
      if mail.to.present? || mail.cc.present? || mail.bcc.present?
        super(mail)
      else
        Rails.logger.warn "Email blocked by whitelist/blacklist rules: #{mail.subject}"
      end
    end

    private

    def filter_recipients(recipients, allowed_domains, disallowed_domains)
      return [] unless recipients
      
      recipients.select do |email|
        email = email.to_s.strip
        next false if email.blank?
        
        # Check blacklist first
        if disallowed_domains.any? && domain_matches?(email, disallowed_domains)
          Rails.logger.info "Email blocked by blacklist: #{email}"
          next false
        end
        
        # Check whitelist
        if allowed_domains.any?
          if domain_matches?(email, allowed_domains)
            Rails.logger.info "Email allowed by whitelist: #{email}"
            next true
          else
            Rails.logger.info "Email blocked by whitelist: #{email}"
            next false
          end
        end
        
        # If no whitelist domains specified, allow all (except blacklisted)
        true
      end
    end

    def filter_recipients_blacklist_only(recipients, disallowed_domains)
      return [] unless recipients
      
      recipients.select do |email|
        email = email.to_s.strip
        next false if email.blank?
        
        if domain_matches?(email, disallowed_domains)
          Rails.logger.info "Email blocked by blacklist: #{email}"
          next false
        end
        
        true
      end
    end

    def domain_matches?(email, domains)
      email_domain = email.split('@').last&.downcase
      return false unless email_domain
      
      domains.any? do |domain|
        domain = domain.downcase.strip
        if domain.start_with?('*@')
          # Pattern like *@example.com
          pattern_domain = domain[2..-1]
          email_domain == pattern_domain
        elsif domain.include?('@')
          # Full email address like user@example.com
          email.downcase == domain
        else
          # Just domain like example.com
          email_domain == domain
        end
      end
    end
  end
end

# Apply the patch using prepend (Rails 7 compatible)
Mailer.prepend RedmineEmailWhitelist::MailerPatch
