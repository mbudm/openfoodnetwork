require 'open_food_network/enterprise_issue_validator'

class Api::Admin::ForOrderCycle::EnterpriseSerializer < ActiveModel::Serializer
  attributes :id, :name, :managed,
             :issues_summary_supplier, :issues_summary_distributor,
             :is_primary_producer, :is_distributor, :sells

  def issues_summary_supplier
    Honeycomb.start_span(name: 'enterprise_serializer_issues_summary_supplier') do |span|
      issues =
        OpenFoodNetwork::EnterpriseIssueValidator.
          new(object).
          issues_summary(confirmation_only: true)

      if issues.nil? && products.empty?
        issues = "no products in inventory"
      end
      issues
    end
  end

  def issues_summary_distributor
    OpenFoodNetwork::EnterpriseIssueValidator.new(object).issues_summary
  end

  def managed
    Enterprise.managed_by(options[:spree_current_user]).include? object
  end

  private

  def products_scope
    
    Honeycomb.start_span(name: 'enterprise_serializer_products_scope') do |span|
      products_relation = object.supplied_products
      if order_cycle.prefers_product_selection_from_coordinator_inventory_only?
        products_relation = products_relation.
          visible_for(order_cycle.coordinator).
          select('DISTINCT spree_products.*')
      end
      Honeycomb.add_field_to_trace('order_cycle_id', order_cycle.id)
      span.add_field('products_count', products_relation.count)
      products_relation
    end
  end

  def products
    Honeycomb.start_span(name: 'enterprise_serializer_products') do |span|
      @products ||= products_scope
    end
  end

  def order_cycle
    options[:order_cycle]
  end
end
