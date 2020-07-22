module OpenFoodNetwork
  class EnterpriseIssueValidator
    include Rails.application.routes.url_helpers
    include Spree::TestingSupport::UrlHelpers

    def initialize(enterprise)
      Honeycomb.start_span(name: 'enterprise_issue_validator_initialize') do |span|
        @enterprise = enterprise
      end
    end

    def issues
      Honeycomb.start_span(name: 'enterprise_issue_validator_issues') do |span|
        Honeycomb.add_field_to_trace('enterprise_id', @enterprise.id)
        span.add_field('shipping_methods_ok', shipping_methods_ok?)
        span.add_field('payment_methods_ok', payment_methods_ok?)
        issues = []

        unless shipping_methods_ok?
          issues << {
            description: I18n.t('admin.enterprise_issues.has_no_shipping_methods', enterprise: @enterprise.name),
            link: "<a class='button fullwidth' href='#{spree.new_admin_shipping_method_path}'>#{I18n.t('admin.enterprise_issues.create_new')}</a>"
          }
        end

        unless payment_methods_ok?
          issues << {
            description: I18n.t('admin.enterprise_issues.has_no_payment_methods', enterprise: @enterprise.name),
            link: "<a class='button fullwidth' href='#{spree.new_admin_payment_method_path}'>#{I18n.t('admin.enterprise_issues.create_new')}</a>"
          }
        end

        issues
      end
    end

    def issues_summary(opts = {})
      Honeycomb.start_span(name: 'enterprise_issue_validator_issues_summary') do |span|
        span.add_field('shipping_methods_ok', shipping_methods_ok?)
        span.add_field('payment_methods_ok', payment_methods_ok?)
        span.add_field('confirmation_only', opts[:confirmation_only])
        if    !opts[:confirmation_only] && !shipping_methods_ok? && !payment_methods_ok?
          I18n.t(:no_shipping_or_payment)
        elsif !opts[:confirmation_only] && !shipping_methods_ok?
          I18n.t(:no_shipping)
        elsif !opts[:confirmation_only] && !payment_methods_ok?
          I18n.t(:no_payment)
        end
      end
    end

    def warnings
      warnings = []

      unless @enterprise.visible
        warnings << {
          description: I18n.t('admin.enterprise_issues.not_visible', enterprise: @enterprise.name),
          link: "<a class='button fullwidth' href='#{edit_admin_enterprise_path(@enterprise)}'>#{I18n.t(:edit)}</a>"
        }
      end

      warnings
    end

    private

    def shipping_methods_ok?
      # Refactor into boolean
      return true unless @enterprise.is_distributor

      @enterprise.shipping_methods.any?
    end

    def payment_methods_ok?
      return true unless @enterprise.is_distributor

      @enterprise.payment_methods.available.any?
    end
  end
end
